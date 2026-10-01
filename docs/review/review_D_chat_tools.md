# Revisión D: ChatButton, Tools, Plus_Item, Plus_Move, Plus_Texture, Plus_Tooltip

Alcance: WoWTools (Interface 120005, Midnight). Solo lectura, no se editó ningún archivo.
`ChatButton/C3_Marker_bak/*` no se carga desde el .toc, así que queda fuera.
Todas las rutas son relativas a `/Users/asymm-hugo/personal/WoWTools/`.

Contexto que conviene tener presente:
- `WoWTools_DataMixin.onlyChinese` vale `LOCALE_zhCN or Save().onlyChinese` (0_Data/z_Panel.lua:277). En un cliente esES/enUS vale false salvo que el usuario active el modo chino.
- Muchos valores por defecto son `WoWTools_DataMixin.Player.husandro`. Solo son true en las cuentas del autor, así que en la cuenta del usuario esas funciones empiezan desactivadas. Donde algo está activo "para todos" lo indico expresamente.

---

## CRÍTICO

### C1. Susurro automático "{rt1}Hi{rt1}" a cualquiera que entra a tu grupo, activo para TODOS por defecto
- **Archivo:** `ChatButton/C1_HyperLink/z_Welcome.lua:25` y `:34`
- **Problema:** hay dos errores de precedencia de operadores.
  - Línea 25: `if not Save().guildWelcome and Save().groupWelcome then return end`. Lua lo evalúa como `(not guild) and group`. Con los valores por defecto (`groupWelcome=false`, `guildWelcome=false`, ver `C1_HyperLink/1_Init.lua:15,18`) la condición es false, **no hace return** y registra el callback de `CHAT_MSG_SYSTEM`.
  - Línea 34: `Save().groupWelcome and text:match(raidMS) or text:match(partyMS)` se evalúa como `(group and raid) or party`. Cualquier mensaje "X se ha unido al grupo" pasa aunque `groupWelcome` esté desactivado.
  - Con `welcomeOnlyHomeGroup=true` (por defecto) y siendo líder, se llama a `WoWTools_ChatMixin:Chat(texto, group)`. Eso hace `SendChatMessage(..., 'WHISPER', nil, nombre)`.
- **Escenario:** eres líder de un grupo normal e invitas a un amigo o a alguien de /2. Recibe al instante el susurro "{rt1}Hi{rt1}" (región EU/US) sin que hayas activado nada. Además, `Init` se sustituye por una función vacía (línea 58), así que desactivar la opción en el menú no desregistra el evento.
- **Arreglo:**
  ```lua
  if not (Save().guildWelcome or Save().groupWelcome) then return end
  ...
  local group= Save().groupWelcome and (text:match(raidMS) or text:match(partyMS))
  ```
  Y dentro del callback, volver a comprobar `Save().groupWelcome` y `Save().guildWelcome` en cada llamada.

### C2. Se pierden mensajes de chat: susurros de Battle.net y todo mensaje "secreto" de 12.0
- **Archivo:** `ChatButton/C1_HyperLink/z_Link_Icon.lua:585-588` (junto con `1_Mixin/Text.lua:260-268`)
- **Problema:** `New_AddMessage` sustituye `ChatFrame1` y de `ChatFrame3` en adelante `.AddMessage` (líneas 663-690). Empieza con:
  ```lua
  if not s or WoWTools_TextMixin:CanText(s) then return end
  ```
  `CanText` devuelve una cadena, que es un valor verdadero, cuando el texto es un *secret value* o cuando contiene `|K...|k`. Entonces la función hace `return` **sin llamar a `self.P_AddMessage`**, y el mensaje nunca se muestra.
- **Escenario:**
  - Cualquier susurro de Battle.net o aviso "Amigo X se ha conectado" lleva el nombre protegido `|Kq..|k`, así que desaparece de la ventana principal.
  - En 12.0, dentro de encuentros, M+ o JcJ puntuado, los textos de chat llegan como secret values. Todo el chat de grupo o banda desaparece.
  - `linkIcon=true` está activo por defecto para todos.
- **Arreglo:** en esos casos, pasar el mensaje sin tocarlo:
  ```lua
  if not s then return self.P_AddMessage(self, s, ...) end
  if WoWTools_TextMixin:CanText(s) then return self.P_AddMessage(self, s, ...) end
  ```
  A medio plazo conviene no reemplazar `AddMessage`, sino usar filtros `ChatFrame_AddMessageEventFilter` con una comprobación de `canaccessvalue`.

---

## ALTO

### A1. Auto-salida de mazmorra: el aviso dice 5 s, desaparece a los 5 s, pero te expulsa a los 30 s. Los timers no se pueden cancelar.
- **Archivo:** `ChatButton/C5_LFD/Exit_Instance.lua:111-121` y `:184-225`
- **Problema:**
  - Con `LFG_COMPLETION_REWARD` se usa `leaveSce=30`, pero el popup tiene `timeout=Save().sec` (3-5 s) y su texto dice "Salir: Instancia 5 segundos".
  - Cuando el popup caduca, `OnCancel` recibe `'timeout'`, no `'clicked'`, así que `ExitIns` sigue a true y a los 30 s llamas a `LeaveParty` sin ningún aviso visible.
  - Cada `LOOT_CLOSED` (se registra dentro de la instancia, línea 126) lanza otro `C_Timer.After`, que no se puede cancelar, en cuanto el popup ya no es visible.
  - Si pulsas "Cancelar" (`ExitIns=nil`) y luego despojas un cofre, `LOOT_CLOSED` vuelve a poner `ExitIns=true` y el timer antiguo de 30 s te saca igualmente.
- **Escenario:** acabas la mazmorra aleatoria, cancelas la salida para despojar o vender. Al abrir un cadáver te echa del grupo.
  - Opción opt-in: por defecto es `leaveInstance=husandro`.
- **Arreglo:**
  - Usar `C_Timer.NewTimer` y guardar el handle: cancelarlo en `OnCancel`, con modificador y en cada nuevo disparo.
  - Poner `timeout` igual a `leaveSce`.
  - Construir el texto del popup en `OnShow`, con el valor real de segundos.
  - Ignorar `LOOT_CLOSED` si el usuario ya canceló en esta instancia.

### A2. El auto-roll pide NECESIDAD en objetos que no son mejora ni coleccionables
- **Archivo:** `ChatButton/C5_LFD/Roll.lua:116`
- **Problema:** `elseif classID==0 or subclassID==0 then set_RollOnLoot(rollID, 1)`. El valor 1 es Necesidad. `subclassID==0` coincide con muchas cosas, por ejemplo:
  - Armas `0` = Hachas de una mano.
  - Armadura `0` = Misceláneo (anillos, collares, abalorios).
  - Bienes comerciables `0`.

  Un anillo, collar o abalorio que no mejora tu equipo (el bucle de la línea 78 no hace return) acaba en esta rama y se tira Necesidad.
- **Además:**
  - En la línea 62-69 se tira Necesidad (1) por una apariencia no coleccionada. Existe `Enum.LootRollType.Transmog` (4); lo correcto es usar Transmog o Codicia para no quitar mejoras a otros.
  - `CONFIRM_LOOT_ROLL` se auto-confirma por defecto (`Exit_Instance.lua:168-172`, `disabled_CONFIRM_LOOT_ROLL=nil`). Resultado: el objeto BoP queda ligado sin confirmación.
- **Escenario:** en una mazmorra con el auto-roll activo (opt-in), te llevas con Necesidad un collar que el tanque necesitaba. Resulta embarazoso delante del grupo.
- **Arreglo:** eliminar `or subclassID==0`, o limitarlo a `classID==Enum.ItemClass.Consumable`. Usar `rollType=4` (Transmog) para las apariencias.

### A3. Reemplazo global de funciones de Blizzard en Plus_Tooltip, activo por defecto
- **Archivo:** `Plus_Tooltip/1_Init.lua:517-538`
- **Problema:** con `disabledFix={}` (por defecto) se redefinen globalmente `SetTooltipMoney` y `UnitFrame_UpdateTooltip`.
  - `UnitFrame_UpdateTooltip` se llama desde el `OnEnter` de PlayerFrame, TargetFrame y los marcos de grupo, que son botones seguros de unidad.
  - `SetTooltipMoney` se llama desde el procesado de tooltips de objeto (precio de venta).

  Las dos pasan a ejecutarse con taint de WoWTools. En 12.0, el código de Blizzard contaminado que toca valores secretos (salud o nombres de unidad en combate) lanza errores del tipo "attempt to compare/perform arithmetic on a secret value (tainted by WoWTools)". Además, las versiones de reemplazo no controlan `money==nil`.
- **Escenario:** en combate pasas el ratón por un marco de unidad y salta un error de Lua o de taint atribuido a WoWTools. También pueden aparecer líneas de dinero mal formateadas.
- **Arreglo:** no reemplazar estas funciones. Si hace falta corregir algo, usar `hooksecurefunc` o `TooltipDataProcessor.AddTooltipPostCall`. Cambiar el valor por defecto a desactivado.

### A4. `CompactRaidFrameManager_Expand` y `_Collapse` sustituidas por versiones inseguras
- **Archivo:** `Plus_Move/z_Events.lua:827-870`
- **Problema:** se redefinen globalmente. Dentro hacen `displayFrame:Show()/Hide()` y `BottomButtons:Show()/Hide()` sin comprobar `CanChangeAttribute`. `displayFrame` contiene botones seguros (marcadores de mundo y demás), así que en combate esos Show/Hide son acciones protegidas.
- **Escenario:** en banda, en combate, pulsas la pestaña del gestor de banda y aparece `ADDON_ACTION_BLOCKED`. El taint puede propagarse a otras rutas del gestor.
- **Arreglo:** no redefinir. Usar `hooksecurefunc('CompactRaidFrameManager_Expand', ...)` para reposicionar y reescalar, y hacerlo solo fuera de combate.

### A5. Aceptación automática de invocaciones y "gracias" automático al grupo, activos por defecto
- **Archivo:** `ChatButton/C4_Invite/Summon.lua:21-66`, `C4_Invite/4_Invite.lua:88-94,131`
- **Problema:**
  - `Summon=true` por defecto: se acepta cualquier invocación a los 3 s.
  - `notSummonChat=nil`: en grupos de 5 envía un mensaje al canal de grupo.
  - En EU/US el texto es `'{rt1}thx{rt1}, sum me'`. "Sum me" significa "invócame" y se envía justo después de haber sido invocado, así que suena raro. Un jugador hispanohablante de EU envía ese texto en inglés.
  - Se sobrescribe directamente `StaticPopupDialogs["CONFIRM_SUMMON"].OnHide` (línea 68), que es un riesgo de taint del sistema StaticPopup.
- **Arreglo:**
  - Poner `Summon` y el mensaje de chat en false por defecto.
  - Usar un texto localizado como `SUMMON..' '..THANKS`, o dejar el mensaje vacío.
  - Usar `hooksecurefunc` o un `OnHide` encadenado en lugar de asignar.

### A6. Filtros de chat sin protección frente a valores secretos (12.0)
- **Archivos:** `ChatButton/C10_Emoji/10_Emoji.lua:49-57`, `ChatButton/C6_World/Filter.lua:434-474`, `ChatButton/C9_Say/9_Say.lua:74-91`
- **Problema:**
  - El filtro de emojis está activo por defecto en SAY, PARTY, RAID, INSTANCE_CHAT, WHISPER... (`Channels={}` hace que se añada a todos). Hace `str:gsub` y luego `str ~= msg` sobre `msg` sin `canaccessvalue`.
  - `Filter.lua` usa `msg` y `guid` como claves de tabla (`FilterTextTab[msg]`).
  - `getWhisper` compara `Name_Realm~=name`.

  En 12.0, comparar o indexar con un secret value produce un error.
- **Escenario:** en M+ o en un jefe, cada mensaje de grupo genera un error de Lua en el filtro. BugSack o BugGrabber se llenan, y el mensaje puede no mostrarse si el filtro falla.
- **Arreglo:** al principio de cada filtro, `if not canaccessvalue(msg) then return false end`, y lo mismo para `name` y `guid`.

### A7. Mensajes automáticos sin comprobar el bloqueo de chat de 12.0 ni el tipo de grupo
- **Archivo:** `ChatButton/0_ChatMixin.lua:30-35`
- **Problema:**
  - `if select(2, IsInInstance())~='none' and GetNumGroupMembers()>0 then SendChatMessage(text,'INSTANCE_CHAT')` falla si estás en un grupo manual dentro de una instancia (el error es "No estás en un grupo de instancia"). Debería usarse `IsInGroup(LE_PARTY_CATEGORY_INSTANCE)`.
  - Ninguna ruta de envío automático (bienvenida, invocación, roll, emoji con clic derecho, `C8_Group` con la rueda) comprueba `C_ChatInfo.InChatMessagingLockdown()`, si existe en esta build, antes de enviar en instancia durante un encuentro.
- **Arreglo:** usar `IsInGroup(LE_PARTY_CATEGORY_INSTANCE)` para INSTANCE_CHAT y `IsInGroup(LE_PARTY_CATEGORY_HOME)` junto con `IsInRaid(LE_PARTY_CATEGORY_HOME)` para PARTY y RAID. Salir antes si hay bloqueo de chat.

### A8. OpenItems equipa armas o armaduras con apariencia no coleccionada, y las liga (por defecto)
- **Archivo:** `Tools/B3_OpenItems/4_Get_Item.lua:144-151`, `1_Init.lua:151` (`mago=true`), `2_Button.lua:137-147`
- **Problema:**
  - El botón hace `/use bolsa hueco` sobre cualquier arma o armadura con apariencia no aprendida. Eso **equipa** la pieza, sustituye la que llevabas y la liga si era BoE, lo que destruye su valor en la subasta.
  - Solo cierra Mercader, Correo y Desguace. Con el **Banco**, el **Comercio** o el **Banco de hermandad** abiertos, `/use` mueve el objeto al banco o a la ventana de comercio.
- **Arreglo:**
  - `mago=false` por defecto.
  - Excluir objetos BoE sin ligar (`C_Item.IsBound(ItemLocation)` en false).
  - Cerrar o comprobar también `BankFrame`, `TradeFrame`, `GuildBankFrame` y `AccountBankPanel`.

### A9. Posible corrupción de SavedVariables: `Esc` apunta a la propia tabla raíz
- **Archivo:** `Plus_Move/1_Init.lua:193`
- **Problema:** `Save().Esc= Save() or P_Save.Esc` (falta `.Esc`) crea una referencia cíclica: `WoWToolsSave.Plus_Move.Esc == WoWToolsSave.Plus_Move`. El serializador de SavedVariables de WoW no está pensado para ciclos. Como mínimo, la estructura guardada queda mal. Según cómo rompa el ciclo, puede duplicar datos en cada sesión.
- **Arreglo:** `Save().Esc= Save().Esc or P_Save.Esc`, más una migración que limpie el valor si ya es `Save()`:
  ```lua
  if Save().Esc == Save() then Save().Esc = {} end
  ```

---

## MEDIO

### M1. Mount: la variable `ShiJI` es global por error, así que el intercambio Chopper/Mechano-Hog nunca funciona
- **Archivo:** `Tools/B1_Mount/Button.lua:6-11`
- **Problema:** `set_ShiJI()` se define antes de `local ShiJI` (línea 11), así que asigna a una **global** `ShiJI`. El resto del archivo (líneas 80 y 220) lee la local, que siempre vale nil. Resultado: la sustitución por facción (179244/179245) no se hace y el fallback final `or ShiJI` vale nil. Además, contamina `_G`.
- **Arreglo:** mover `local ShiJI` por encima de `set_ShiJI`.

### M2. Mount: se pasan spellID donde la API espera mountID
- **Archivo:** `Tools/B1_Mount/Button.lua:117` y `:447-451`
- **Problema:**
  - `C_MountJournal.GetMountUsabilityByID(tab[index], true)` recibe un spellID. La comprobación de usabilidad no sirve.
  - En combate, `mountID = ... or 368896` hace `SummonByID(368896)`, pero 368896 es un spellID.
  - `getRandomRoll` hace una sola tirada: si esa montura no es usable devuelve nil y se cae a otra categoría, por ejemplo una terrestre en zona de vuelo.
- **Arreglo:** convertir con `C_MountJournal.GetMountFromSpell(spellID)` antes de llamar. Reintentar hasta N veces o filtrar primero la lista de usables.

### M3. Mount: precedencia de operadores en la elección de montura
- **Archivo:** `Tools/B1_Mount/Button.lua:212-221`
- **Problema:** la expresión `((isAdvancedFlyable or usable(368896)) and aura and getRandomRoll('Flying') or getRandomRoll('Dragonriding'))` devuelve una montura de surcacielos aunque no estés en zona de vuelo avanzado. Además, se evalúa antes que la rama acuática (`IsSubmerged`).
- **Arreglo:** envolver la rama Dragonriding en `isAdvancedFlyableArea and (...)` y comprobar `IsSubmerged()` antes.

### M4. Mount: recálculo excesivo con `SPELL_DATA_LOAD_RESULT`
- **Archivo:** `Tools/B1_Mount/Button.lua:597-601`
- **Problema:** cada `SPELL_DATA_LOAD_RESULT` con éxito del juego (tooltips, libro de hechizos y otros addons lo disparan con mucha frecuencia) ejecuta `checkSpell`, `XDInt`, `checkMount` y `setClickAtt` completos. Además, `PLAYER_STARTED_MOVING` y `PLAYER_STOPPED_MOVING` vuelven a tirar una montura aleatoria cada vez que te mueves.
- **Arreglo:** filtrar por los IDs que interesan, igual que hace `LL_MagePortal.lua:~300`. Aplicar un throttle de unos 0,2 s con `C_Timer`.

### M5. Invitaciones: rechazar en zona de descanso pone al que invita en lista negra permanente
- **Archivo:** `ChatButton/C4_Invite/Inv_StaticPopup.lua:128-136` junto con `:21-28`
- **Problema:** la rama "no agrupar en zona de descanso" usa `Decline`, y `Decline` incrementa `Save().InvNoFriend[guid]`. A partir de entonces esa persona se auto-rechaza siempre, en cualquier zona (rama de la línea 99).
- **Arreglo:** una función `DeclineOnly()` que no registre al que invita, para el caso de descanso.

### M6. Roll: el "máximo" que se guarda no es el máximo
- **Archivo:** `ChatButton/C2_Roll/2_Roll.lua:110-126` y `:283`
- **Problema:**
  - `max` nunca se actualiza, así que `maxTab` acaba siendo la última tirada mayor que 0.
  - `if tab==100` compara una tabla con un número.
  - `table.sort(_tabNew, ...)` ordena una tabla hash indexada por nombre, lo que no hace nada. El orden del menú es aleatorio.
- **Arreglo:** `if tab.roll>max then max=tab.roll; maxTab=tab end`. Construir `_tabNew` como array y ordenar por `index`.

### M7. Plus_Move: `ipairs(UIPanelWindows)` nunca itera
- **Archivo:** `Plus_Move/1_Init.lua:152`
- **Problema:** `UIPanelWindows` es un diccionario indexado por nombre, así que `ipairs` no devuelve nada. Los paneles que no están en `Frames` o `Events` nunca se hacen movibles.
- **Arreglo:** usar `pairs`, teniendo en cuenta que eso activará Setup en muchos paneles; conviene revisar la lista.

### M8. Plus_Move: tocar `UIPanelWindows` y los atributos `UIPanelLayout-*` desde código inseguro
- **Archivo:** `Plus_Move/0b_ScaleSizeButton_Mixin.lua:161-231`
- **Problema:** la opción "Bloquear posición" hace `UIPanelWindows[name]=nil` y `SetAttribute("UIPanelLayout-...")`, y además hay un hook de `UpdateUIPanelPositions` (`1_Init.lua:165`). Todo esto contamina el gestor de paneles de UIParent, que es una fuente clásica de "Interfaz bloqueada por un addon" al abrir paneles en combate. La opción es opt-in, pero debería avisar del riesgo.

### M9. Plus_Move: posiciones de SetupButton que se guardan pero nunca se restauran
- **Archivo:** `Plus_Move/0a_Setup_Mixin.lua:253-255` junto con `2_Add_Button.lua:169-174`
- **Problema:** para los marcos movidos con asa (ZoneAbilityFrame, UIWidgetPowerBarContainerFrame, PetBattleFrame.BottomFrame), `Setup` recibe `tab.frame` y por eso no llama a `Set_Frame_Point`. Con "Guardar posición" activo, la posición se guarda en `point[...]` pero al recargar vuelve a la de Blizzard. La excepción es QueueStatusButton, que tiene su propio hook.
- **Arreglo:** si hay `target`, llamar también a `Set_Frame_Point(target, name)`.

### M10. Plus_Move: se escalan marcos de Blizzard para todos, al cargar y sin comprobar combate
- **Archivo:** `Plus_Move/1_Init.lua:10-14` y `2_Add_Button.lua:~160-165`
- **Problema:** por defecto se aplica `scale=0.85` a `ZoneAbilityFrame`, `UIWidgetPowerBarContainerFrame` y `BankFrame`, y `frame:SetScale()` se llama directamente en `SetupButton` sin `IsLocked`. Tras un `/reload` en combate, ZoneAbilityFrame (con botones seguros) está protegido y la llamada queda bloqueada.
- **Arreglo:** `scale={}` por defecto y usar `Set_Frame_Scale` (el helper con cola de `PLAYER_REGEN_ENABLED`).

### M11. HyperLink: palabras clave del usuario usadas como patrones Lua
- **Archivo:** `ChatButton/C1_HyperLink/z_Link_Icon.lua:643-647`
- **Problema:** `s:gsub(k, ...)` usa `k` sin escapar. Una palabra clave con `[`, `(`, `%`, `-` o `.` provoca el error "malformed pattern" dentro de `AddMessage`, y la ventana de chat deja de mostrar mensajes. En la línea 638, `s:gsub(unitName, ...)` tiene el mismo problema.
- **Arreglo:** `s:gsub(WoWTools_TextMixin:Magic(k), ...)`, o mejor `string.find(s, k, 1, true)` con una sustitución sin patrones.

### M12. Ready check: `math.mix` no existe y hay código muerto
- **Archivo:** `ChatButton/C8_Group/Ready_Auto.lua:40-47`
- **Problema:** `timeLeft` se asigna siempre en la línea 40, así que el `if not timeLeft` nunca se ejecuta. Si se llegara a ejecutar, `math.mix` lanzaría un error. La intención era probablemente `math.min`.
- **Arreglo:** `timeLeft = math.min(Save().autoReadySeconds or 3, Get_LeftTime() or 35)`.

### M13. Historial de susurros: crece sin límite y guarda tokens BNet de sesión
- **Archivo:** `ChatButton/C9_Say/9_Say.lua:74-91`
- **Problema:**
  - Solo se recorta la lista principal a 120 contactos (líneas 602-606). La lista `msg` de cada contacto crece indefinidamente en SavedVariables, con todo el texto de los susurros.
  - En los susurros BNet, `name` es un token `|K..|k` que depende de la sesión. Al usarlo desde el historial en otra sesión (línea 254, `ChatFrame_SendBNetTell`), puede abrir un susurro a otro amigo o fallar.
- **Arreglo:**
  - Limitar `msg` a unos 50 mensajes por contacto.
  - Para BNet, guardar `bnSenderID` o la BattleTag (`C_BattleNet.GetAccountInfoByID`) en lugar del token.

### M14. RepopMe: se libera el espíritu automáticamente sin respetar la piedra de alma o la reencarnación
- **Archivo:** `ChatButton/C5_LFD/RepopMe.lua:58-61`
- **Problema:** `ReMe=true` está activo por defecto (campos de batalla o zonas JcJ). En `PLAYER_DEAD` llama a `RepopMe()` enseguida, sin comprobar `HasSoulstone()` ni `C_DeathInfo.GetSelfResurrectOptions()`, y sin tecla modificadora.
- **Escenario:** mueres en un campo de batalla con piedra de alma o con Reencarnación disponible, y la pierdes.
- **Arreglo:** `if #C_DeathInfo.GetSelfResurrectOptions()>0 or IsModifierKeyDown() then return end`.

### M15. Filtro de "spam" del canal mundo: contadores inflados y reglas solo en inglés
- **Archivo:** `ChatButton/C6_World/Filter.lua:447-470`
- **Problema:**
  - El filtro se ejecuta una vez por cada ventana de chat que muestra el canal, así que `num` se multiplica.
  - `msg:find('WTS')` solo detecta inglés y distingue mayúsculas ("VENDO" o "wts" no se detectan).
  - Cualquier mensaje más largo que `myChatFilterNum` de un desconocido se bloquea, lo que incluye mensajes legítimos.
- **Arreglo:** cachear por `lineID` (el argumento 11) para contar una sola vez, y permitir patrones configurables.

### M16. Plus_Item: trabajo pesado en `UpdateCooldown` de cada botón de bolsa
- **Archivo:** `Plus_Item/ContainerFrame1.lua:43-45`
- **Problema:** `SetupInfo`, que escanea el tooltip con `C_TooltipInfo.GetBagItem`, se ejecuta en cada `UpdateCooldown` de cada botón. Con las bolsas abiertas en combate, `BAG_UPDATE_COOLDOWN` y `SPELL_UPDATE_COOLDOWN` lo disparan en todos los huecos.
- **Arreglo:** hacer hook de `UpdateItems` o `Update` y cachear por `itemLink`.

### M17. Plus_Item: `BossBanner_ConfigureLootFrame` enganchado dos veces
- **Archivo:** `Plus_Item/Events.lua:173` y `Plus_Item/Frames.lua:4`
- **Problema:** las dos entradas se ejecutan desde `1_Init.lua:70-89`. `SetItemStats` se aplica dos veces por cada objeto del banner.
- **Arreglo:** eliminar una de las dos.

### M18. Tooltip CVars: `graphicsViewDistance` se pone a 0 al salir
- **Archivo:** `Plus_Tooltip/1_Init.lua:645-660`
- **Problema:** con `setCVar` activo (opt-in), `PLAYER_LEAVING_WORLD` fija la distancia de visión a 0 y la restaura en el siguiente `PLAYER_ENTERING_WORLD`. Si se desactiva o desinstala el addon, o si el cliente se cierra de golpe, la distancia de visión se queda en el mínimo permanentemente.
- **Arreglo:** eliminar esta función, o restaurar el valor también en `PLAYER_LOGOUT` y documentarla.

---

## BAJO

- **B1** `Tools/0_ToolsButtonMixin.lua:143,150,152`: `LeftNewLineButton` es global por falta de `local`. Contamina `_G` y puede chocar con otros addons.
- **B2** `ChatButton/C5_LFD/Exit_Instance.lua:99`: `if event=='' then` es código muerto. `ISLAND_COMPLETED` es contenido obsoleto.
- **B3** `ChatButton/C5_LFD/Roll.lua:14`: la lógica de `notPrint` está invertida: imprime solo cuando `notPrint==true`.
- **B4** `ChatButton/C4_Invite/Inv_StaticPopup.lua:160-197`: se sobrescriben `StaticPopupDialogs["PARTY_INVITE"].button3`, `.OnAlt` y `.OnUpdate` directamente. Hay riesgo de taint del sistema StaticPopup y de romper otros addons que también lo modifican.
- **B5** `ChatButton/C1_HyperLink/z_Link_Icon.lua:632`: `s:match(LOOT_ITEM)` usa la cadena global sin procesar como patrón (`%s` significa "espacio" en un patrón Lua). Casi nunca coincide, así que es código muerto en la práctica. Si llega a coincidir, sustituye un fragmento incorrecto.
- **B6** `ChatButton/C1_HyperLink/z_Link_Icon.lua:92-99`: los reinos con guion (por ejemplo Azjol-Nerub o Aggra-Português) no se acortan, porque `'%-'..server` no escapa el guion interno.
- **B7** `ChatButton/C1_HyperLink/z_Welcome.lua:6-8`: los patrones creados con `gsub("%%s","(.+)")` no escapan `.`, `(` ni `-` de las cadenas localizadas.
- **B8** `ChatButton/C1_HyperLink/z_Welcome.lua:42-53`: cada miembro de la hermandad que tenga el addon envía su propia bienvenida, lo que genera spam en /g.
- **B9** `Tools/B1_Mount/1_Init.lua:150`: `P_Mouts_Tab.Items` es una errata (debe ser `Item`), así que la migración de datos antiguos pierde la lista de objetos.
- **B10** `Tools/B1_Mount/UI_Collections.lua:131-163`: se reemplaza globalmente `MountJournal_FullUpdate` (se restaura al pulsar Reset). El taint del diario de monturas es tolerable, pero conviene usar filtros de DataProvider.
- **B11** `Plus_Texture/ChatBubbles.lua:30-52`: el estilo se aplica en el mismo evento de chat, antes de que exista el bocadillo, así que el bocadillo actual sale sin estilo. Usar `C_Timer.After(0, ...)`. Si `chatBubbleSacal` es nil (SavedVariables antiguas), `SetScale(nil)` falla. Al reaplicar con `set=true`, los desplazamientos se dividen otra vez y el texto se desplaza.
- **B12** `Plus_Tooltip/f_Unit_Player.lua:181-185`: `lineLeft2:GetText()` se usa sin `canaccessvalue`, al contrario que en la línea 110. `text:match('(.-)%-')` corta nombres de hermandad que contienen guiones.
- **B13** `ChatButton/C5_LFD/LFGList_Plus.lua:305-333`: el doble clic en un resultado llama a `SignUpButton:Click()` y a `LFGListApplicationDialog.SignUpButton:Click()`. Funciona porque hay un evento de hardware, pero contamina LFGList, con riesgo de `ADDON_ACTION_BLOCKED` en otras acciones de LFG.
- **B14** `Tools/B3_OpenItems/4_Get_Item.lua:207-225` (`alt=true` por defecto): la heurística de "objeto usable con hechizo" puede consumir fichas de reputación o conocimiento ligadas a la cuenta en el personaje equivocado.

---

## LOCALIZACIÓN (esES/esMX, enUS)

### Resumen de recuentos
- **Cadenas CJK sin control `onlyChinese`, visibles en clientes no chinos: 5 visibles reales.** El script detectó 198, pero casi todas están bien controladas en varias líneas, forman parte de tablas de datos o son `print` de depuración para `husandro`.
  - `ChatButton/C5_LFD/2_Menu.lua:883, 928, 1049` y `ChatButton/C5_LFD/Queue_Status.lua:509, 612`: `MicroButtonTooltipText('队伍查找器', "TOGGLEGROUPFINDER")` muestra chino en el tooltip. Arreglo: `MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLEGROUPFINDER")`.
- **Falsos positivos que menciona el encargo:**
  - `Tools/B1_Mount/1_Init.lua:183` está dentro de `if onlyChinese and not LOCALE_zhCN`, así que es correcto.
  - Los nombres de ciudad de `Tools/LL_MagePortal/LL_MagePortal.lua:9-46` solo se usan con `onlyChinese` (línea 214). En los demás idiomas la etiqueta se obtiene del nombre del hechizo con `Get_Spell_Label` (líneas 78-86). En esES, "Teletransporte: Orgrimmar" se muestra como "Orgrimmar", lo cual está bien.
- **Textos en inglés literal que se ven en español: unos 29 fallbacks `or 'English'`**, más literales sueltos. Ejemplos:
  - `'Test'` (C1_HyperLink/2_Menu.lua:144, C4_Invite/Init_Menu.lua:200)
  - `'Welcome to join'` (C1_HyperLink/2_Menu.lua:298,342)
  - `'Players around'` (C4_Invite/Init_Menu.lua:74)
  - `'Word count'` (C6_World/Filter.lua:258)
  - `'Clear input data'` (z_Emote.lua:1121,1125)
  - `'Mount show'` (B1_Mount/Menu.lua:541, Button.lua:501)
  - `'Random'` (B2_Hearthstone/1_Init.lua:434, L0_UseToy.lua:624)
  - `'Press the Esc key to hide the frame'` (Plus_Move/0b...:350)
  - `'When show, custom position'` (Plus_Move/0b...:238)
  - `'Unified/Separated'` y `'Portrait'` (Plus_Texture/2_Init_BGMenu_Frame.lua:483,780)
  - `'Fix'` (Plus_Tooltip/1_Init.lua:304)
  - `'World Preload Non Critical'` (z_CVar_Set.lua:46)
  - `'|cnGREEN_FONT_COLOR:Rest|r'` (C4_Invite/Resting.lua:18,23)
  - Mensajes de chat enviados: `'{rt1}Hi{rt1}'`, `'{rt1}thx{rt1}, sum me'` y `'STOP STOP STOP'`. Estos se envían en inglés a otros jugadores en EU aunque el cliente esté en español.
- **Frases compuestas pegando GlobalStrings: unos 120 usos de `format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, A, B)`.** Reparto: ChatButton 72, Tools 24, Plus_Tooltip 13, Plus_Move 5, Plus_Item 4, Plus_Texture 2. Esa cadena es "%s %s" (clase y especialización). En español da órdenes y concordancias forzadas ("Auto Limpiar", "Salir Instancia Campos de batalla") y, si alguna localización la reordena, las frases salen invertidas. Arreglo: una tabla local de traducciones (`L["..."]`) con esES y enUS.
- **Análisis de texto dependiente del idioma:**
  - `1_Mixin/Text.lua:180-182` (`WoWTools_TextMixin:sub`): solo trata como multibyte el rango CJK (`\228-\233`). En español corta por **bytes**, así que cualquier abreviatura puede partir una letra acentuada (á é í ó ú ñ ocupan 2 bytes) y mostrar un carácter roto. Lo usan `Plus_Item/0_SetupInfo.lua:59-71` (abreviaturas de estadísticas), `:98-101` (Coleccionado), `:509` (ubicación de la piedra de hogar), `:524` (piedra angular) y `:655` (conjunto de equipo). Arreglo: usar `utf8` o `strlenutf8` y cortar por caracteres para cualquier byte mayor o igual que 0xC0.
  - `ChatButton/C1_HyperLink/z_Link_Icon.lua:24` y `C6_World/2_SetButton.lua:30`: `'大脚世界频道'` es un canal chino. No rompe nada, pero no aporta en EU.
  - `Plus_Item/0_SetupInfo.lua:24`: `ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s', ...)` solo funciona si la localización usa exactamente `%s/%s`. Hay que comprobar en esES que el nivel de mejora aparece en los iconos de las bolsas.

---

## UI / PULIDO

- **U1** `ChatButton/1_Init.lua:358-360`: la barra de chat solo se limita a la pantalla cuando está anclada al chat (`SetClampedToScreen(toChatFrame)`). Movida libremente, se puede arrastrar fuera de la pantalla y perder. `RegisterForDrag('')` con una cadena vacía es poco claro; mejor `RegisterForDrag()`.
- **U2** `Plus_Move/1_Init.lua:6`: `SavePoint` está desactivado por defecto para todos menos el autor. El usuario mueve un panel y, al reabrirlo, Blizzard lo devuelve a su sitio sin explicación. Conviene activarlo por defecto o mostrar un aviso la primera vez que se arrastra.
- **U3** `Plus_Move/z_Events.lua:736-743`: todos los StaticPopup se hacen movibles. Con posición guardada, popups diferentes caen en el mismo sitio y se superponen, porque se pierde el apilado de `StaticPopup_SetUpPosition`.
- **U4** `ChatButton/C5_LFD/Exit_Instance.lua:184-190`: el texto del popup se construye una sola vez en `Init` con `Save().sec`, así que cambiar los segundos en el menú no lo actualiza. Además no coincide con los 30 s reales (ver A1).
- **U5** `Tools/LL_MagePortal/LL_MagePortal.lua:9,14`: en la Horda aparecen dos botones "Lunargenta" (1259190 de Midnight y 32272 antiguo) con la misma etiqueta. Hay que diferenciarlos, por ejemplo con "(Midnight)".
- **U6** `Plus_Texture/ActionButton.lua:21-32`: `AssistedCombatRotationFrame` pasa a estrato BACKGROUND con escala 0,9, así que el indicador del Asistente de combate puede quedar tapado por el icono. Hay que verificarlo visualmente.
- **U7** `ChatButton/C8_Group/Ready_Auto.lua:77,163-174`: `ReadyCheckFrame:SetHeight(124)` y tres radio buttons anclados fuera del marco, a la izquierda (`'RIGHT', ReadyCheckListenerFrame, 'LEFT'`). Con marcos de grupo a la izquierda se solapan, y los textos en español son más largos que en chino.
- **U8** Los tamaños fijos (botones de 30 px, asas de 23 px, `SetWidth(295)` y similares) no escalan con la escala de la interfaz. Las cadenas en español, más largas, se desbordan en los tooltips compuestos con `CLUB_FINDER_LOOKING_FOR_CLASS_SPEC`.

---

## Qué está bien (para no romperlo)
- Los botones seguros de Tools (monturas, juguetes, piedra de hogar, portales) comprueban siempre `CanChangeAttribute()` y reintentan en `PLAYER_REGEN_ENABLED`, lo cual es correcto.
- Plus_Move usa `IsLocked()` (protegido y en combate) de forma sistemática, y para detener el arrastre en combate usa una cola de `PLAYER_REGEN_DISABLED`.
- Hay bastante uso de `canaccessvalue` en los módulos de Hermandad, Tooltip y Combat. Las omisiones concretas se señalan arriba.
