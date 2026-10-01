# Revisión B — Plus (parte 1): WorldMap, Gossip, Challenge, PaperDoll, MiniMap, Merchant, Encounter, Mail, Unit

Alcance: unas 40.000 líneas de Lua. Todo lo que sigue lo he comprobado leyendo el código. Cuando algo depende de datos del cliente que no puedo confirmar sin jugar (texto exacto de un global en esES, comportamiento del servidor), lo marco con **(verificar en juego)**.

Notas generales:
- No encontré llamadas a APIs globales retiradas (`GetSpellInfo`, `GetItemInfo`, `GetContainerItemInfo`, `UnitAura`, `EasyMenu`, `UIDropDownMenu_*`, `SendChatMessage` global…). El autor ya migró a `C_Item`/`C_Spell`/`C_Container`/`C_ChatInfo`.
- El autor también tiene en cuenta los valores secretos de 12.0 (`canaccessvalue`/`issecretvalue`). Hay pocos huecos, y se listan abajo.
- Los fallos serios están casi todos en las **acciones automáticas**, que vienen **activadas por defecto** para cualquier usuario: `Plus_Gossip` trae `gossip=true`, `unique=true` y `quest=true` (Gossip/1_Init.lua:65-80), y `Plus_SellBuy` deja `notSellBoss` y `notAutoRepairAll` sin definir, así que esas funciones están activas.

---

## CRÍTICO

### C1. El botón "X" de cada carta en el buzón borra cartas CON objetos sin pedir confirmación
- **Archivo:** `Mail/A_InBox.lua:59`
  ```lua
  if canDelete and (not money or money==0) and (not CODAmount or CODAmount==0) and (not itemCount or itemCount) then
      DeleteInboxItem(openMailID)
  ```
- **Problema:** `(not itemCount or itemCount)` siempre es verdadero cuando `itemCount` es un número. En la práctica la comprobación de objetos adjuntos desaparece. Si la carta se puede borrar (`InboxItemCanDelete`: cartas de NPC o del sistema, cartas devueltas a ti, etc.) y no lleva oro, se llama a `DeleteInboxItem` directamente. Así se salta el `StaticPopup "DELETE_MAIL"` que Blizzard muestra en `OpenMail_Delete` cuando hay objetos.
- **Escenario:** en el buzón, el jugador pulsa la X (`btn.DeleteButton`, línea 380, visible para todo lo que no sea de la casa de subastas, línea 538) en una carta del sistema o de un NPC con un objeto, o en una carta propia devuelta con materiales. El objeto se destruye al momento y no hay forma de recuperarlo.
- **Arreglo:** `(not itemCount or itemCount==0)`. Si no, dejar siempre que actúe `OpenMail_Delete`, que ya muestra la confirmación.
- En la misma función, línea 50: `text= text:gsub(' ','') and nil or text` siempre deja `nil` (gsub devuelve una cadena, que es verdadera). El cuerpo de la carta nunca se imprime. Arreglo: `if text:gsub('%s','')=='' then text=nil end`.

### C2. Venta automática de botín de jefe (BoP) activada por defecto, aunque se desmarque "vender basura"
- **Archivos:** `Merchant/SellJunk.lua:168-205` (marcado) y `Merchant/0_MerchantMixin.lua:27-35` (venta), llamado desde `SellJunk.lua:76-80`.
- **Problema:** con cada `ENCOUNTER_LOOT_RECEIVED` propio dentro de una instancia, cualquier arma o armadura BoP de calidad ≤ épica se guarda en `bossItems` si se cumple una de estas dos condiciones:
  - su nivel está 30 o más por debajo de tu nivel medio, o
  - (**nivel máximo** y **expansión anterior**) (línea 184).

  En el siguiente `MERCHANT_SHOW` se vende sola (hasta 11 por visita). Tres agravantes:
  1. `notSellBoss` es `nil` por defecto, así que la función viene activa.
  2. El checkbox visible, "Auto vender basura" (`notSellJunk`), **no la desactiva**. `set_sell_junk` sigue vendiendo lo marcado como jefe o personalizado.
  3. El marcado se registra a nivel de archivo aunque el módulo Merchant esté desactivado (el `Frame` de la línea 167 siempre existe).
- **Escenario:** un jugador de nivel máximo hace una raid antigua para transmog o monturas. Abre un vendedor para reparar y el addon le vende todas las piezas de la raid, incluidos abalorios o armas con efectos que quería guardar. Solo se recuperan desde "recomprar" hasta hacer logout.
- **Arreglo:** poner `notSellBoss=true` por defecto (opt-in). Hacer que el checkbox cubra todas las ventas automáticas, o añadir uno propio para "jefes". Excluir las piezas con apariencia no coleccionada (`C_TransmogCollection.PlayerHasTransmogByItemInfo`) y las que tengan "Uso:" o "Equipar:" especiales.

---

## ALTO

### A1. El diálogo se cierra solo cuando el NPC solo ofrece misiones
- **Archivo:** `Gossip/Gossip.lua:961-988`
- **Problema:** `GreetingFrame:settings` llama a `C_GossipInfo.CloseGossip()` si `#C_GossipInfo.GetOptions()==0`. `GetOptions()` **no incluye** las misiones disponibles ni las activas, y el título (`GossipGreetingTextMixin.Setup`) se dibuja siempre.
- **Escenario:** un NPC en el GossipFrame solo tiene misiones (sin opciones de diálogo). Pasa en alguno de estos casos: la misión es trivial y el seguimiento de misiones triviales está apagado; el NPC está en `Save().NPC`; o `quest` está desactivado. A los 0,1 s la ventana se cierra y el jugador no puede aceptar ni entregar nada sin mantener un modificador.
- **Arreglo:** añadir `and C_GossipInfo.GetNumAvailableQuests()==0 and C_GossipInfo.GetNumActiveQuests()==0`.

### A2. Entrega automática de misiones que consumen objetos, divisas u oro
- **Archivo:** `Gossip/Quest.lua:571-633` (progreso → `QuestProgressCompleteButton_OnClick`), `:724-729` y `:738-743` (`QuestFrameCompleteQuestButton:Click()` en OnShow).
- **Problema:** con `quest=true` (el valor por defecto) se completa cualquier misión que se pueda completar. No se mira si pide oro (`GetQuestMoneyToGet()`), divisas (`GetNumQuestCurrencies()`) u objetos (`GetNumQuestItems()`).
- **Escenario:** misiones repetibles de reputación que consumen materiales caros, donaciones de oro, o entregas de divisa. El jugador habla con el NPC y pierde los recursos sin haberlo elegido.
- **Arreglo:** no completar automáticamente si `GetQuestMoneyToGet()>0` o si hay objetos o divisas requeridos, salvo que la misión esté en `questOption`.

### A3. Auto-selección de opciones de diálogo demasiado amplia
- **Archivo:** `Gossip/Gossip.lua:784-822`
- **Problema:**
  - Se elige automáticamente cualquier opción cuyo nombre contenga `QUESTS_LABEL` ("Misiones"), `LOOT_JOURNAL_LEGENDARIES_SOURCE_QUEST` o `RENOWN_LEVEL_UP_SKIP_BUTTON` ("Saltar"). Eso es buscar texto localizado dentro de una frase: acierta o falla según el idioma, y además `find` recibe esos textos como patrón Lua.
  - Con `unique=true` (por defecto), si solo hay **una** opción se selecciona siempre, con independencia de lo que haga: iniciar un evento o encuentro, teletransportar, "saltar la campaña", etc.
- **Escenario:** en una mazmorra, el NPC que inicia un evento con rol o un jefe tiene una sola opción y el evento empieza solo. En un cliente en español, cualquier opción que contenga "Saltar" (por ejemplo, saltar un capítulo de la historia) se acepta sin preguntar.
- **Arreglo:**
  - Usar solo `info.flags` (`QuestLabelPrepend`) y `info.status`, sin comparar texto.
  - Para `unique`, excluir las opciones con `info.icon` de combate o evento, y las que tengan `Enum.GossipOptionRecFlags` distinto de 0.
  - Poner `unique=false` por defecto.
  - Si se sigue buscando texto, usar `find(x, 1, true)`.

### A4. Entrada automática en profundidades (Delves) a los 3 s, activada por defecto
- **Archivo:** `Gossip/Gossip_Delves.lua:260-297` → `Run()` (`:128-151`) → `EnterDelveButton:Click()`.
- **Problema:** con `Save().gossip` (true por defecto), al abrir el selector de dificultad arranca un temporizador de 3 s que pulsa "Entrar", con el último nivel o con el máximo. Solo se cancela con Alt o tocando el desplegable.
- **Escenario:** el jugador abre el selector para mirar las recompensas y a los 3 s le teletransporta dentro.
- **Arreglo:** hacerlo opt-in con su propio flag (`autoEnterDelve`) en vez de reutilizar `gossip`.
- **Bug adicional:** `maxCheck` (línea 163) y `completeCheck` (línea 216) usan el **mismo nombre global**, `'WoWToolsDelveDifficultyMaxCheck'`. El segundo sobrescribe `_G` del primero. Arreglo: renombrar a `...CompleteCheck`.
- **Menor:** `Get_Options` llama a `C_DelvesUI.RequestPartyEligibilityForDelveTiers` una vez por nivel dentro del bucle (línea 76). Basta con llamarlo una vez fuera.

### A5. Se modifican `StaticPopupDialogs` de Blizzard (taint) y se ocultan los avisos de bloqueo
- **Archivo:** `Gossip/StaticPopupDialogs.lua:22-24`
  ```lua
  StaticPopupDialogs["ERROR_CINEMATIC"].timeout= timeout and 1 or nil
  StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"].timeout= timeout   -- 0.1 s
  ```
- **Problema:**
  1. Escribir en las tablas de diálogos de Blizzard las ensucia (taint), y eso acaba en "La interfaz ha bloqueado una acción" en otros popups.
  2. El aviso ADDON_ACTION_FORBIDDEN se cierra a los 0,1 s: el usuario nunca ve qué addon está rompiendo algo.
  3. Línea 45: `EventRegistry:UnregisterCallback('ADDON_LOADED', FORBIDDEN_ID)` usa el evento equivocado (debería ser `'ADDON_ACTION_FORBIDDEN'`) y no pone `FORBIDDEN_ID=nil`, así que el callback nunca se desregistra.
- **Arreglo:** quitar esas asignaciones. Si se quiere avisar, basta con escuchar el evento e imprimirlo en el chat. Corregir el nombre del evento en la línea 45.

### A6. "Restablecer posición" del botón de diálogo da un error de Lua
- **Archivo:** `Gossip/1_Init.lua:146`: `_G['WoWToolsGossipButton']:set_Point()`
- **Problema:** el método se llama `set_point` (Gossip/Gossip.lua:208). Lua distingue mayúsculas, así que se produce `attempt to call method 'set_Point' (a nil value)` cada vez que se pulsa el botón del panel de opciones.
- **Arreglo:** `:set_point()`.

### A7. El intercambio de especialización de botín no restaura lo que el jugador tenía
- **Archivo:** `Encounter/LootSpec.lua:385-437`
- **Problema:** en `ENCOUNTER_START` se guarda `logID= curID` (la especialización **actual**), no el valor previo de `GetLootSpecialization()`. En `ENCOUNTER_END` se pone esa especialización fija.
- **Escenario:** el jugador tenía el botín en "Especialización actual" (0). Después del jefe queda fijado en una especialización concreta. Si luego cambia de especialización, sigue recibiendo botín de la anterior. Si tenía otra especialización elegida, se pierde.
- **Arreglo:** `logID = GetLootSpecialization()` (aunque sea 0), y restaurar con `SetLootSpecialization(logID)`.

### A8. El botón de encantamiento del personaje puede "usar" un objeto equivocado
- **Archivo:** `PaperDoll/Item_PoaperDll.lua:205-213`
- **Problema:** en `BAG_UPDATE_DELAYED`, si ya no hay pergamino de encantamiento (`tab2==nil`), el atributo `item` **se queda con el bag/slot anterior** y el botón sigue visible. En combate la visibilidad tampoco se actualiza.
- **Escenario:** el jugador usa el pergamino y en ese hueco de la bolsa entra otro objeto (un consumible, un contenedor o equipo). Al volver a pulsar el botón se usa o se equipa ese objeto.
- **Arreglo:** si `tab2` es nil, llamar a `SetAttribute("item", nil)` y a `self:Hide()` (fuera de combate).
- **Relacionado (líneas 160-164):** el botón seguro se crea y recibe `SetAttribute` y `SetPoint` sin comprobar el combate. Si se crea en combate, da ADDON_ACTION_BLOCKED. Arreglo: salir con `if InCombatLockdown() then return end` antes de crearlo.

---

## MEDIO

### M1. El algoritmo que elige la recompensa de misión está roto
- **Archivo:** `Gossip/Quest.lua:108-138` (solo actúa con `autoSelectReward`)
- **Problemas:**
  - `if not (notColleced and upItem) and count and sellPrice` debería ser `or`. Tal como está, **el precio de venta sustituye a la mejora de equipo o al objeto no coleccionado** cuando otro objeto vale más.
  - `bestLevel<lv` compara el nivel del objeto **equipado**, no la mejora (itemLevel − lv).
  - Se usa `itemLevel` de `C_Item.GetItemInfo` (el nivel base) en vez del nivel real escalado (`GetDetailedItemLevelInfo` / `WoWTools_ItemMixin:GetItemLevel`).
- **Escenario:** la opción 1 es una mejora de +10 y la opción 2 una pieza inútil que vale más oro. Se elige la 2.
- **Arreglo:** calcular una puntuación por objeto (mejora > sin coleccionar > precio) y quedarse con la máxima.
- **Además:** al marcar el checkbox de una recompensa (línea 57), se llama a `CompleteQuest()` en el acto. Resulta inesperado: marcar una preferencia no debería entregar la misión.

### M2. Checkbox "misión disponible": datos obsoletos por la closure
- **Archivo:** `Gossip/Gossip.lua:670-682`
- **Problema:** `set_data(data)` usa `text= info.title`, donde `info` es el parámetro de la **primera** llamada a `Create_AvailableQuestCheck`, no `data`. Además calcula `questID` con fallback a `GetID()`, pero guarda `self.questID= data.questID` sin ese fallback.
- **Escenario:** los botones se reciclan. `Save().questOption[questID]` guarda el título de otra misión, y el checkbox puede mostrarse sin `questID`, lo que imprime "Ninguno ID".
- **Arreglo:** `text= data.title` y `self.questID= questID`.
- **Lo mismo en `Gossip.lua:551`:** `info.name and info.name~=self.name` debería usar `info2.name`.

### M3. Reparación con fondos de la hermandad sin mirar el límite diario
- **Archivo:** `Merchant/Repair.lua:76-80`
- **Problema:** solo se comprueba `GetGuildBankMoney()>=Co`. No se tiene en cuenta `GetGuildBankWithdrawMoney()`, que es el límite diario del rango.
- **Escenario:** la reparación con la hermandad falla en silencio, pero el contador `RepairSave().guild` suma el coste igualmente y no se paga con el oro propio.
- **Arreglo:** `local limit=GetGuildBankWithdrawMoney(); if CanGuildBankRepair() and (limit==-1 or limit>=Co) and GetGuildBankMoney()>=Co then ...`.

### M4. Recompra automática recorriendo índices hacia delante
- **Archivo:** `Merchant/Buyback.lua:44-52`
- **Problema:** `for index=1,num do ... BuybackItem(index)`. Al recomprar, la lista se desplaza. Si el servidor responde antes de que acabe el bucle, se recompra el objeto equivocado o se salta alguno **(verificar en juego)**.
- **Arreglo:** recorrer de `num` a 1.

### M5. Recolocar objetos en el correo depende de que `canSendTab` se actualice al instante
- **Archivo:** `Mail/Item_FastButton.lua:517-528`
- **Problema:** dentro del bucle siempre se usa `self.canSendTab[1]`, y esa tabla solo se recalcula en el hook de `SendMailFrame_Update`. Si ese evento no se dispara de forma síncrona, todos los objetos van al mismo hueco: se intercambian o se quedan en el cursor **(verificar en juego)**.
- **Arreglo:** recalcular localmente los huecos libres con `HasSendMailItem(i)` en cada iteración, y salir cuando no queden.

### M6. Destinatario, asunto y cuerpo del correo se rellenan con lo último enviado
- **Archivo:** `Mail/1_Init.lua:149-160`
- **Problema:** al abrir el buzón por primera vez se escriben `lastSendPlayer`, `lastSendSub` y `lastSendBody`.
- **Escenario:** el jugador adjunta oro u objetos pensando en otra persona y se lo envía al destinatario anterior.
- **Arreglo:** que sea opcional, o al menos resaltar el campo en otro color.
- **Menor:** el asunto por defecto es `EMOTE56_CMD1:gsub('/','')` (línea 72), un comando de emote localizado. En español queda un asunto sin sentido. Mejor dejarlo vacío.

### M7. El anuncio al insertar la piedra angular no se envía nunca
- **Archivo:** `Challenge/z_ChallengesKeystoneFrame.lua:140-144`
- **Problema:** `Set_SlotKeystoneSay` sale si `ChallengesKeystoneFrame:IsVisible()`, pero se engancha a `OnKeystoneSlotted`, que se ejecuta precisamente con ese marco abierto. La condición parece invertida, y la función `slotKeystoneSay` nunca envía el mensaje.
- **Arreglo:** quitar esa condición (o poner `not ...IsVisible()` si la intención era otra).

### M8. Variable global sin querer
- **Archivo:** `Challenge/z_Say_ChallengeComplete.lua:345`
- **Problema:** `EndKeystoneSayText= ...` crea una **variable global**. Lo correcto sería `WoWToolsPlayerDate.EndKeystoneSayText`. Resultado: el texto por defecto nunca se aplica y se ensucia `_G`.
- **Arreglo:** usar `WoWToolsPlayerDate.EndKeystoneSayText = WoWToolsPlayerDate.EndKeystoneSayText or ...`.

### M9. Se escriben campos del WorldMapFrame (taint)
- **Archivo:** `WorldMap/z_UI.lua:167-177`
- **Problema:** se asigna `WorldMapFrame.minimizedWidth` y `minimizedHeight`, y se llama a `UpdateMaximizedSize()` y `Maximize()` desde código de addon. El WorldMapFrame es una fuente conocida de taint: ADDON_ACTION_BLOCKED al seguir misiones o usar objetos de misión desde el mapa en combate.
- **Arreglo:** redimensionar con `SetSize` en un hook posterior, sin tocar las claves internas, o documentar que esta opción puede causar bloqueos.

### M10. `SendPlayerPoint` puede dar error si no hay posición
- **Archivo:** `WorldMap/0_WorldMapMixin.lua:80-84`
- **Problema:** `C_Map.GetPlayerMapPosition` puede devolver `nil` en escenarios o zonas con la posición restringida en 12.0. Sin embargo `CanSetUserWaypointOnMap` puede ser true. Entonces `UiMapPoint.CreateFromVector2D(mapID, nil)` falla con un error de nil.
- **Arreglo:** `if pos then ... end`, y si no, usar la rama de texto.

### M11. PlayerChoice: elección automática cuando solo hay una opción
- **Archivo:** `Gossip/Gossip_PlayerChoice.lua:96-116`
- **Problema:** con `unique=true` (por defecto), si solo hay una opción con `spellID`, se envía la respuesta sola.
- **Otro detalle:** la línea 97 muta `optionFrame.optionInfo.rarity`, que es una tabla de Blizzard.
- **Arreglo:** respetar un flag separado y copiar la tabla en vez de mutarla.

### M12. La tecla Shift apaga para siempre el despojo automático (CVar)
- **Archivo:** `Merchant/LootFrame.lua:51-53` (solo si `notAutoLootPlus=false`, que por defecto solo ocurre en las cuentas del autor)
- **Problema:** mantener Shift al despojar (el modificador estándar de Blizzard para invertir el despojo automático en ese momento) pone `autoLootDefault=0` de forma **permanente**.
- **Arreglo:** no tocar el CVar. Si hay Shift, simplemente no ejecutar `LootSlot`.

### M13. La distancia al compañero de grupo se muestra al cuadrado
- **Archivo:** `Unit/PartyFrame.lua:407-409`
- **Problema:** se muestra `UnitDistanceSquared` tal cual. A 40 m aparece "1.6k".
- **Arreglo:** `math.sqrt(distanceSquared)`.

### M14. Tooltip de objetos del mundo sin protección frente a valores secretos
- **Archivo:** `WorldMap/PlayerPin.lua:627-636`
- **Problema:** solo se comprueba `InCombatLockdown()`. En 12.0, `data.lines[1].leftText` puede ser secreto dentro de instancias aunque no haya combate, y luego se usa como clave en `WoWTools_TextMixin:CN` **(verificar en juego)**.
- **Arreglo:** `if not canaccessvalue(data.lines[1].leftText) then return end`.

### M15. El global `MERCHANT_ITEMS_PER_PAGE` se sobrescribe
- **Archivo:** `Merchant/Plus_WidthX2.lua:446, 458, 292`
- **Problema:** es un global que lee `MerchantFrame_Update`. Sobrescribirlo ensucia (taint) todo ese flujo. Hoy no hay APIs protegidas en ese camino, pero es frágil y choca con otros addons de vendedor.
- **Arreglo:** mantener la paginación propia en una variable local y hacer hook en vez de reemplazar el global. Si no, documentar la incompatibilidad.

---

## BAJO

- **B1 `Challenge/ChallengesUI_Porta.lua:62-64`:** en `PLAYER_REGEN_ENABLED` se hace `SetShown(true)` sin mirar `Save().hidePort`. Los portales reaparecen después de cada combate aunque el usuario los haya ocultado.
- **B2 `Challenge/z_ChallengesKeystoneFrame.lua:550-559`:** `HasSlottedKeystone()` y dos `SetEnabled` se ejecutan en cada fotograma, fuera de la limitación de frecuencia. Conviene moverlos dentro del bloque de 0,8 s o dispararlos con `CHALLENGE_MODE_KEYSTONE_SLOTTED`.
- **B3 `Challenge/z_AvailableRewards.lua:67`:** `RegisterUnitEvent('UNIT_SPELLCAST_SENT')` se llama sin unidad. Debería ser `RegisterUnitEvent('UNIT_SPELLCAST_SENT','player')`.
- **B4 `Challenge/z_AvailableRewards.lua:96-99`:** se detecta la Gran Cámara comparando el **nombre del objetivo** con `RATED_PVP_WEEKLY_VAULT`, un texto de interfaz que no tiene por qué coincidir con el nombre del objeto en esES/esMX. El propio archivo tiene los spellID en el comentario de cabecera (449976, 392391, 1271478). Mejor comparar el 4.º argumento, `spellID`.
- **B5 `MiniMap/Zoom.lua:123`:** con `value=='max'` se pasa `Minimap:GetZoomLevels()` a `SetZoom`, pero los índices válidos van de 0 a `levels-1`. Debería ser `max-1`.
- **B6 `Gossip/Quest.lua:206-240` (`autoSortQuest`):** quita el seguimiento de todas las misiones que no estén "en el mapa". Borra el seguimiento manual del jugador. Es opt-in, pero conviene advertirlo en el tooltip.
- **B7 `Encounter/0_EncounterMixin.lua:20-28`:** `GetBossNameSort` corta el nombre del jefe en el primer `-`, `,` o `<`. Por ejemplo, "The One-Armed Bandit" queda en "The One". Si hay que acortar, mejor limitar la longitud.
- **B8 `Mail/A_InBox.lua:474`:** para detectar la casa de subastas se compara `sender==BUTTON_LAG_AUCTIONHOUSE`. Las cartas de subasta caducada o cancelada no traen factura, así que dependen de que el remitente coincida exactamente con ese texto de interfaz **(verificar en esES)**. Si no coincide, esas cartas muestran el botón X del punto C1.
- **B9 `Merchant/SellJunk.lua:172`:** `playerName:find(UnitName('player'))` usa el nombre como patrón. Mejor `find(name,1,true)` o comparar con `Ambiguate`.
- **B10 `Unit/PlayerFrame.lua:594-620`:** con la rueda del ratón sobre el marco del jugador se cambia la dificultad de mazmorra. Es fácil hacerlo sin querer.

---

## LOCALIZACIÓN

Resumen de conteos:
- 3 textos en chino sin alternativa, que ven todos los usuarios, más 3 cadenas chinas visibles en la UI de fuentes (L1-L3).
- 33 alternativas en inglés escrito a mano (no salen en español).
- 109 usos de `format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, A, B)` para componer frases.
- Varios globales de Blizzard reutilizados con un significado distinto al suyo.

Se buscó lógica que analice texto chino (`find`/`match`/`gsub` con literales chinos) y **no se encontró** en este alcance. Todos los patrones de tooltip usan globales de Blizzard (`ITEM_LEVEL`, `ENCHANTED_TOOLTIP_LINE`…).

### Texto chino visible para todos
| Archivo:línea | Problema | Arreglo |
|---|---|---|
| `WorldMap/z_Plus.lua:101` | `(WoWTools_DataMixin and '章节' or 'ChapterIDs')`: la condición siempre es verdadera y todos ven "章节" | `WoWTools_DataMixin.onlyChinese and '章节' or 'Capítulos'`, o `QUEST_LOG_CAMPAIGN_CHAPTER`/similar |
| `WorldMap/z_Plus.lua:105` | `campaign.isWarCampaign and '阵营战役' or WAR_CAMPAIGN`: las campañas de guerra muestran chino | `campaign.isWarCampaign and (onlyChinese and '阵营战役' or WAR_CAMPAIGN)` |
| `PaperDoll/EquipSetButton.lua:25` y `:614` | `MicroButtonTooltipText('角色信息', "TOGGLECHARACTER0")`: el primer elemento del menú sale en chino | `onlyChinese and '角色信息' or CHARACTER_BUTTON` |
| `Gossip/Gossip_EditUI.lua:801, 810` | El checkbox "修改字体" y el tooltip "黑体字" se muestran a todos (la condición `onlyChinese` está comentada, líneas 795-797). Además fuerza `Fonts\\ARHei.ttf` | Restaurar la condición o traducir el texto |

### Inglés escrito a mano o en otro idioma (no aparece en español)
- `Gossip/Gossip_EditUI.lua:442`: `'Numeri'` (es **italiano**). Usar `'Número'` o un global.
- `Gossip/Gossip_Menu.lua:56`: 'When there is only one option, automatic dialogue.'
- `WorldMap/0_WorldMapMixin.lua:124`, `4_XY_Map.lua:23,26,64,74,261,263`, `5_XY_Player.lua:28`: "Cannot set waypoints on this map", "Not found uiMapID", "Error XY".
- `MiniMap/2_Menu.lua:37,133,150`, `Collection_Icon.lua:433,450,818,835,956,1134`: 'Border alpha', 'Background alpha', 'Memory will continue to increase'…
- `MiniMap/TimeManager.lua:637`: 'ServerTime'. Existe `TIMEMANAGER_TOOLTIP_REALMTIME`.
- `PaperDoll/EquipSetButton.lua:94`, `Unit/PlayerFrame.lua:372`, `Challenge/ChallengesUI_Affix.lua:217`, `ChallengesUI_Menu.lua:382`, `WorldMap/z_UI.lua:248`.
- `Challenge/z_Say_ChallengeComplete.lua:90-94, 345`: el texto por defecto del chat de grupo sale en inglés en la región EU (3), aunque el cliente esté en español. Añadir `(LOCALE_esES or LOCALE_esMX) and '{rt1}¿Seguimos? '`.
- `Challenge/z_ChallengesKeystoneFrame.lua:391, 397`: 'Stop! Stop! Stop!' para las regiones que no son CN. Aceptable en el chat, pero en el tooltip podría ser localizado.

### Globales de Blizzard reutilizados con otro significado (quedan raros en español)
- `Challenge/z_ChallengesKeystoneFrame.lua:191`: el botón "Insertar" usa `COMMUNITIES_ADD_DIALOG_INVITE_LINK_JOIN`, que significa **"Unirse"**.
- `Unit/0_UnitMixin.lua:836, 846`: "Distancia máx./mín." usa `FARCLIP`, que significa **"Distancia de visión"** (gráficos).
- `Merchant/BuyItem.lua` (`TUTORIAL_TITLE20` como "Comprando") y `SellJunk.lua:147-150` (`AUCTION_PRICE_PER_STACK` como "grupos"): el significado no encaja.
- `Mail/A_InBox.lua:605-611`: `ITEM_TEXT_FROM` ("De") quitando las comas produce "3De". Mejor `format('%d %s', n, (onlyChinese and '发信人' or FROM))`.
- **109 usos** de `format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, A, B)` para unir dos palabras ("Auto" + "Diálogo"). En enUS el patrón es "%s %s". En otros idiomas el orden o el conector pueden cambiar **(verificar en esES)**, y el resultado suele ser una traducción literal poco natural ("Auto Vender Basura"). Un archivo de locale mínimo (esES/esMX) con ~40 claves resolvería casi todo.

### Datos
- `Gossip/Gossip_TextData.lua:33`: `pt='Азсуна'` (cirílico en portugués). `:22` y `:42` tienen `es=''` y `de=''`. Se gestionan bien (se descartan), pero faltan las traducciones: Nagrand → "Nagrand" y Ardenweald → "Ardenweald".
- `WorldMap/1_Init.lua:94`: una chincheta de datos por defecto con `name='草药学'` sin alternativa. Si se muestra, sale en chino. Usar `C_TradeSkillUI.GetProfessionInfoBySkillLineID(182).professionName`.

---

## UI / PULIDO

- **U1 `Mail/B_Set_UI.lua:95-116`:** se recoloca todo el SendMailFrame con desplazamientos mágicos (`384-338, 424-512`, `-80`, `-75`). Choca con Postal y TSM. Además, `SendMailCostMoneyFrame` se oculta al enfocar el cuerpo, así que el coste de envío desaparece justo al escribir.
- **U2 `Challenge/z_AvailableRewards.lua:21-33`:** el icono de la Gran Cámara es un `Frame` sin padre, posicionado en `CENTER -100,60`. No escala con UIParent ni se oculta con Alt+Z.
- **U3 `Unit/TargetFrame.lua:36-39`:** el rango y la velocidad del objetivo se pintan a la izquierda del TargetFrame (x=22). Se solapan con el retrato y con los iconos de PvP, que se reducen a 0,6.
- **U4:** las etiquetas `Merchant/Repair.lua` (MK de oro encima de los botones), `SellJunk.lua:153` (contador de basura) y `Mail/A_InBox.lua` (índice, typeTexture de 150×16, delete, outItemOrMoney) añaden muchas capas pequeñas con tamaños fijos. Recargan la interfaz y se solapan con el texto original en idiomas con textos largos, como el español. Conviene un modo "compacto" o permitir ocultarlas.
- **U5 `Gossip/Gossip.lua:497-508`:** en cada opción de diálogo, el checkbox y el ID se colocan a la derecha y se recorta el ancho del texto. Con textos largos en español la opción se corta o se solapa con el ID.
- **U6 `WorldMap/2_Menu.lua:441-442`:** `SetFrameLevel(999)` y la capa `HIGH` sobre el mapa pueden tapar desplegables de otros addons.
- **U7:** muchos `print()` en cada acción automática (misiones, diálogos, ventas, reparación, recompensas, especialización de botín). Llenan el chat. Convendría un único ajuste de "verbosidad".
