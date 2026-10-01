# Revisión WoWTools — Plus/ (parte 2)

Alcance: PetBattle, Attributes, Macro, Collection, Faction, AddOns, AuctionHouse, Currency, Color, MainMenu, Target, Spell, Holiday, Friends, Cursor, Professions, Hunter, Gem, House, ObjectiveTracker (unos 38k líneas).
Método: lectura del código de los módulos de más riesgo; `luac -p` para comprobar la sintaxis de todos los .lua del alcance (todos compilan); `luac -l` para extraer escrituras y lecturas de globales; grep dirigido a APIs antiguas, a patrones con texto chino y a fallbacks en inglés.
No se encontraron llamadas a APIs globales eliminadas (GetSpellInfo, GetItemInfo, UnitAura, GetAddOnInfo, etc.): el código ya usa C_Spell/C_Item/C_AddOns.
Archivos no cargados (están comentados en el .toc con `##`): Target/isMeFrame.lua, Target/numFrame.lua, Attributes/Speed_Dragonriding, Speed_Target (.bak).

Los puntos marcados "(verificar en juego)" dependen de cómo se comporta la API en 12.0 y no solo del código. El fallo de código en sí está confirmado.

---

## CRÍTICO

### C1. Faction: el filtro de chat de reputación lanza un error de Lua en cada subida de reputación (clientes no chinos)
- **Archivo:** Plus/Faction/z_CHAT_MSG.lua:135-136 y 44-54
- **Problema:** en la línea 135 la global `FACTION_STANDING_INCREASED` se sustituye por su versión convertida en patrón (`WoWTools_TextMixin:Magic`, que convierte `%s`→`(.-)`, `%d`→`(%d+)` y `.`→`%.`). Después, en las líneas 51 y 53, esa misma variable se usa como cadena de **formato**: `format(FACTION_STANDING_INCREASED, cnName, num)`. `WoWTools_TextMixin:CN()` devuelve el propio texto cuando no está en modo chino (1_Mixin/Text.lua:156-164), así que `cnName` siempre tiene valor y siempre se entra en esa rama.
- **Escenario:** cliente esES/enUS con la opción por defecto `factionUpdateTips=true` (Faction/1_Init.lua:11). Al matar un mob que da reputación, `format("...con (.-) ha aumentado en (%d+)%.", "Nombre", 250)` falla con "bad argument #2 to 'format' (number expected, got string)" o "invalid option '%.'". Sale un error de Lua dentro del filtro de chat en cada ganancia de reputación y el mensaje puede no mostrarse.
- **Solución:** guardar los patrones en variables locales distintas (`local PAT_INC = Magic(FACTION_STANDING_INCREASED)`) y usar la global original solo para `format`. Otra opción es no reformatear cuando `not WoWTools_DataMixin.onlyChinese` y limitarse a añadir el sufijo. Añadir también `if not canaccessvalue(text) then return end`.
- Extra: en la línea 62, `info.atla` es una errata de `info.atlas`, así que el icono de atlas nunca se muestra.

### C2. Attributes/Speed_Vehicle: error de Lua cada 0,3 s mientras el botón de salir del vehículo está visible
- **Archivo:** Plus/Attributes/Speed_Vehicle.lua:40
- **Problema:** el campo se crea como `frame.speedText` (línea 16), pero en el OnUpdate se usa `self.speedtext:SetText(...)` (con "t" minúscula), que es nil. Además, la lista de las líneas 7-12 repite nombres, así que se crea el label dos veces y se engancha OnUpdate dos veces en el mismo botón.
- **Escenario:** el jugador sube a un vehículo o a un taxi (grifo). Aparece `MainMenuBarVehicleLeaveButton`/`MainActionBarVehicleLeaveButton` y se produce "attempt to index field 'speedtext' (a nil value)" unas 3 veces por segundo. El módulo se activa por defecto (Attributes/0_Init.lua:109).
- **Solución:** cambiar a `self.speedText`, quitar los duplicados de la tabla o usar `if frame and not frame.speedText then`.

---

## ALTO

### A1. AuctionHouse: `z_AccountStore` indexa `AccountStoreFrame` en PLAYER_LOGIN
- **Archivo:** Plus/AuctionHouse/z_AccountStore.lua:7; se llama desde Plus/AuctionHouse/1_Init.lua:153-154
- **Problema:** `AccountStoreFrame.CategoryList.ScrollBox` se lee directamente al iniciar sesión. En el resto del addon este frame se trata como opcional o de carga bajo demanda (Plus_Tooltip/z_Events.lua:479 lo engancha en el ADDON_LOADED de `Blizzard_AccountStore`; Plus/MainMenu/Store.lua:74 y 98 hacen `if AccountStoreFrame`).
- **Escenario:** si `Blizzard_AccountStore` no está cargado al iniciar sesión, salta "attempt to index global 'AccountStoreFrame' (a nil value)" en cada login. (Verificar en juego con `/dump C_AddOns.IsAddOnLoaded('Blizzard_AccountStore')` justo al entrar.)
- **Solución:** llamar a Init_AccountStore desde el ADDON_LOADED de `Blizzard_AccountStore`, o `if not AccountStoreFrame then return end` más un EventUtil.ContinueOnAddOnLoaded.

### A2. AuctionHouse: doble clic en "Mis subastas" cancela la subasta sin confirmar (se pierde el depósito)
- **Archivo:** Plus/AuctionHouse/C_AllAuctionsList.lua:218-242
- **Problema:** `OnDoubleClick` → `C_AuctionHouse.CancelAuction(auctionID)` directamente, sin el StaticPopup de Blizzard (CANCEL_AUCTION_CONFIRMATION).
- **Escenario:** un doble clic casual en una fila de la lista cancela la subasta y se pierde el depósito. Además, el botón extra "Cancelar" (líneas 92-130) cancela **la subasta con menos tiempo restante** entre las filas visibles, no la seleccionada. Queda junto al botón de Blizzard "Cancelar subasta" y en español se confunden.
- **Solución:** pedir confirmación (`StaticPopup_Show('WoWTools_OK', ...)`) o usar Alt+doble clic, y renombrar el botón a algo como "Cancelar la más antigua".

### A3. AuctionHouse: doble clic en la lista de compra pulsa "Comprar ya" y cierra el StaticPopup1 aunque sea de otra cosa
- **Archivo:** Plus/AuctionHouse/A_BrowseResultsFrame.lua:419-437
- **Problema:** el doble clic hace `BuyoutButton:Click()`. Si `StaticPopup1` está visible, lo oculta sin comprobar de qué diálogo se trata.
- **Escenario:** con un popup ajeno abierto (resurrección, invitación a grupo, confirmar objeto ligado), un doble clic en la lista lo cierra. Sin popup abierto, el doble clic inicia la compra (sigue saliendo la confirmación de Blizzard).
- **Solución:** comprobar `StaticPopup_FindVisible("BUYOUT_AUCTION")` (u otro diálogo concreto) en vez de `StaticPopup1`, o quitar la función.

### A4. AuctionHouse: al vaciar o bajar el precio, el objeto se expulsa y se añade para siempre a la lista oculta
- **Archivo:** Plus/AuctionHouse/B_Sell_Other.lua:369-409
- **Problema:** en el hook de `UpdateTotalPrice`, si `unitPrice <= vendorPrice` el itemID se mete en `Save().hideSellItem`, se hace `ClearPostItem()` y se carga el siguiente objeto. Con el precio vacío o a 0, `unitPrice` pasa a valer 1 (línea 377), con lo que siempre es menor que el precio de venta al vendedor.
- **Escenario:** el jugador borra la casilla de oro para escribir otro precio, o escribe "5" antes de "50". El objeto desaparece del marco de venta y queda oculto para siempre de la lista lateral (hay que ir al menú, "Ocultar objetos", para recuperarlo).
- **Solución:** solo avisar (texto rojo "Peligro"), sin tocar Save ni ClearPostItem, o hacerlo como mucho al pulsar "Publicar". Ignorar `unitPrice==0`.

### A5. Macro: la protección `IsLocked(MacroFrame)` nunca bloquea nada en combate
- **Archivo:** 1_Mixin/Frame.lua:10-26 (helper compartido); se usa en Plus/Macro/0_MacroMixin.lua:15,30,45 y en MacroButton_Plus.lua:8,70
- **Problema:** `IsLocked` devuelve `frame:IsProtected() and InCombatLockdown()`. `MacroFrame` no es un frame protegido, así que siempre devuelve false. `CreateMacro`/`EditMacro`/`DeleteMacro` no se pueden usar en combate; el propio autor lo comenta en 0_MacroMixin.lua:37 ("战斗中，出现错误").
- **Escenario:** en combate, cambiar el icono desde la lista (Select_Button.lua:163, List_Bottom.lua:505) o crear una macro desde NewEmptyButton / List_Bottom provoca ADDON_ACTION_BLOCKED ("WoWTools ha sido bloqueado...").
- **Solución:** en las funciones de macro, usar `InCombatLockdown()` directamente, o que `IsLocked` acepte un flag `alwaysCheckCombat`.

### A6. Cursor/GCD: comparaciones con valores de cooldown sin proteger (valores secretos de 12.0)
- **Archivo:** Plus/Cursor/GCD.lua:103-115
- **Problema:** `data.startTime > 0 and data.duration > 0` se usa sin `canaccesstable`/`canaccessvalue`. El helper compartido sí se protege (1_Mixin/Cooldown.lua:68 `if canaccesstable(data)`).
- **Escenario:** en Midnight los cooldowns pueden devolverse como secretos en combate. Si el GCD (61304) llega secreto, cada SPELL_UPDATE_COOLDOWN en combate da "attempt to compare a secret value". (Verificar en juego si 61304 está en la lista blanca.)
- **Solución:** `if not canaccesstable(data) then return end` y, mejor aún, usar la API de duración de 12.0 (`C_Spell.GetSpellCooldownDuration` con `Cooldown:SetCooldownFromDurationObject`) si está disponible.

### A7. Hunter: "Ordenar mascotas" desordena el establo y el orden descendente usa índices inválidos
- **Archivo:** Plus/Hunter/All_List.lua:38-86
- **Problemas:**
  1. `local all= #AllListFrame.Buttons` (línea 76): la tabla tiene claves de 6 a 205 (línea 165) sin el índice 1, así que `#` da 0 o un valor indefinido. `newIndex = all-i+1` da valores ≤0 y se llama a `C_StableInfo.SetPetSlot(slot, -N)`.
  2. Los `slotID` de `tab` se leen una sola vez. Cada `SetPetSlot` intercambia mascotas, así que las llamadas siguientes mueven mascotas equivocadas y el resultado final no queda ordenado.
  3. Se ordena por `get_text_byte(name)` (suma de bytes), que no es orden alfabético.
  4. Se lanzan hasta 200 `SetPetSlot` en el mismo frame y el servidor puede limitarlas.
- **Solución:** calcular la permutación final y aplicarla de forma incremental (un movimiento cada vez, releyendo `GetStablePetInfo` después de `PET_STABLE_UPDATE`). Ordenar con `strcmputf8i(a.name, b.name)` y usar como tope `NUM_PET_SLOTS_HUNTER`.

---

## MEDIO

### M1. Faction/AuctionHouse/Attributes/etc.: las SavedVariables no incorporan claves nuevas
- **Archivos:** Attributes/0_Init.lua:88, AuctionHouse/1_Init.lua:103, Target/1_Init.lua:81, ObjectiveTracker/1_Init_Plus.lua:311, Professions/1_Init.lua:16, Faction/1_Init.lua:35, y más.
- **Problema:** se usa el patrón `WoWToolsSave[x] = WoWToolsSave[x] or P_Save`. Si el usuario ya tenía la tabla de una versión anterior, las claves nuevas nunca se añaden.
- **Escenario:** una save antigua sin `textColor` hace fallar Attributes/1_Setup.lua:924 (`Save().textColor.r`). Una sin `SellItemDefaultPrice` o `hideSellItem` hace fallar AuctionHouse/B_Sell_Other.lua:322 y 401 al poner un objeto en venta.
- **Solución:** una función común que haga el merge (`for k,v in pairs(P_Save) do if save[k]==nil then save[k]=CopyTable(v) end end`).

### M2. Attributes: relayout completo sin límite en cada UNIT_AURA del jugador
- **Archivo:** Plus/Attributes/2_Button.lua:281-292 → 1_Setup.lua:857-955
- **Problema:** cada `UNIT_AURA` del jugador (decenas por segundo en combate) llama a `Frame_Init()`, que recorre las 13 filas, llama a todas las APIs de stats y hace `ClearAllPoints`/`SetPoint`.
- **Solución:** agrupar con `C_Timer.After(0.2)` y una bandera, o usar los eventos específicos (`COMBAT_RATING_UPDATE`, `UNIT_STATS`, `MASTERY_UPDATE`, ...). Nota: el frame MASTERY registra `MASTERY_UPDATE` (1_Setup.lua:801) pero no tiene OnEvent, así que ese evento no hace nada.

### M3. Target/questFrame: temporizadores acumulados y un escaneo de tooltip por nameplate
- **Archivo:** Plus/Target/questFrame.lua:238-240
- **Problema:** cada `UNIT_QUEST_LOG_CHANGED`/`QUEST_POI_UPDATE`/`SCENARIO_CRITERIA_UPDATE` crea un `C_Timer.After(2, Check_AllPlate)` nuevo y cada uno hace `C_TooltipInfo.GetUnit` para todas las nameplates. En zonas con mucha actividad de misiones se juntan decenas de escaneos.
- **Solución:** un solo temporizador que se reinicia (`if self.timer then self.timer:Cancel() end`).

### M4. Spell/ActionButton_UpdateRange: comparación sin proteger y llamada a métodos de botones seguros
- **Archivo:** Plus/Spell/ActionButton_UpdateRange.lua:17-22, 35, 45
- **Problema:** `C_ActionBar.IsActionInRange(self.action)==false` se compara sin `canaccessvalue`, y cualquier valor secreto hace fallar el hook (verificar en 12.0). Además, desde el hook inseguro se llama a `frame:UpdateUsable()` de los botones de acción seguros, lo que ensucia de taint el estado del botón.
- **Solución:** proteger el valor con `canaccessvalue` y cambiar solo `icon:SetVertexColor` sin llamar de nuevo a `UpdateUsable`.

### M5. Professions/Gem: un botón seguro dentro del marco hace que el marco quede protegido
- **Archivos:** Plus/Professions/ProfessionsFrame_Button.lua:28-52, 62-67; Plus/Gem/1_Init.lua:461-465 (padre `Frame` creado en la línea 1025 como hijo de ItemSocketingFrame)
- **Problema:** un `SecureActionButton` hijo de ProfessionsFrame o ItemSocketingFrame hace que el padre sea protegido de forma implícita. Por eso el código cierra ProfessionsFrame en `PLAYER_REGEN_DISABLED`, y en combate no se puede abrir ni cerrar (ADDON_ACTION_BLOCKED). El autor lo reconoce en el menú ("BUG").
- **Solución:** poner el botón seguro con padre UIParent y colocarlo junto al marco con SetPoint, ocultándolo con `RegisterStateDriver(btn, "visibility", "[combat] hide; show")` o mostrarlo y ocultarlo fuera de combate.

### M6. AddOns: cargar un "perfil" de addons cambia los addons de todos los personajes
- **Archivo:** Plus/AddOns/5_RightList.lua:43-61 (también Plus.lua:431-441)
- **Problema:** `C_AddOns.EnableAddOn(i)` y `DisableAddOn(i)` se llaman sin el argumento `character`, lo que aplica el cambio a todos los personajes.
- **Escenario:** cargar un perfil en un personaje desactiva addons en los alters que tenían otra configuración.
- **Además:** hay una incoherencia en el segundo argumento de `GetAddOnEnableState`: 0_AddOnsMixin.lua:53 y 5_RightList.lua:272 pasan el GUID, pero 4_BottomList.lua:58 pasa `UnitName("player")`. Unificar con lo que use AddonList en 12.0.

### M7. Spell/Spec_Button: un clic izquierdo cambia de especialización sin confirmar
- **Archivo:** Plus/Spell/Spec_Button.lua:178-185, 206-208
- **Problema:** `OnMouseDown` con el botón izquierdo llama a `C_SpecializationInfo.SetSpecialization`. Con los botones sueltos en UIParent, un clic accidental empieza un cambio de especialización. Además, `set_shown` (254-261) usa `not InCombatLockdown()` durante `PLAYER_REGEN_DISABLED`, cuando todavía devuelve false, así que la ocultación en combate nunca se aplica.
- **Solución:** usar OnClick con un modificador (Shift+clic) o una confirmación, y en `set_shown` fiarse solo del parámetro `isInCombat`.

### M8. ObjectiveTracker: "Limpiar todo" deja de seguir todas las misiones con un solo clic
- **Archivo:** Plus/ObjectiveTracker/0_ObjectiveMixin.lua:5-29 (se usa en 1_Init_Plus.lua:95-237)
- **Problema:** es un botón de 22 px al lado de minimizar, sin confirmación, y quita el seguimiento de todas las misiones, logros o recetas.
- **Solución:** exigir Shift+clic o confirmación. Además, 1_Init_Plus.lua:74-85 cambia el tamaño de `QuestObjectiveItemButton` (un botón seguro), lo que ensucia de taint el layout del tracker (el propio menú avisa "Wrong when there is any item button").

### M9. PetBattle/TypeButton: abre el Diario de mascotas al terminar cada combate de mascotas
- **Archivo:** Plus/PetBattle/TypeButton.lua:434-445
- **Problema:** en `PET_BATTLE_CLOSE`, si "Revivir mascotas" no está en cooldown, se llama a `ToggleCollectionsJournal(2)` sin ninguna opción para desactivarlo.
- **Solución:** hacerlo configurable (desactivado por defecto).

### M10. ObjectiveTracker/AuctionHouse: al desactivar desde el panel se ejecuta Init()
- **Archivos:** ObjectiveTracker/1_Init_Plus.lua:319-329; AuctionHouse/1_Init.lua:131-135
- **Problema:** `SetValue` llama a `Init()` sin mirar el nuevo estado, así que al desmarcar "activar" se instalan los hooks igualmente hasta hacer /reload.
- **Solución:** `if not Save().disabled then Init() end`.

### M11. Professions/TrainerUI: "Aprender todo" no tiene en cuenta el gasto acumulado
- **Archivo:** Plus/Professions/TrainerUI.lua:47-66
- **Problema:** se compara `money <= GetMoney()` en cada vuelta, pero `GetMoney()` no se actualiza dentro del mismo frame, así que se mandan compras de más y salen errores de "No tienes suficiente dinero". Además, las dos ramas de color (25-29) usan verde, por lo que el aviso de oro insuficiente nunca sale en rojo.
- **Solución:** llevar la cuenta con `cost + money <= GetMoney()` y usar `|cnWARNING_FONT_COLOR:` en la rama `else`.

### M12. Target/targetFrame: acceso sin comprobar a subframes de la nameplate
- **Archivo:** Plus/Target/targetFrame.lua:25, 38-45, 56-63
- **Problema:** se asume que existen `UnitFrame.SoftTargetFrame.Icon`, `RaidTargetFrame.RaidTargetIcon`, `ClassificationFrame.classificationIndicator` y `WidgetContainer`. Si la nameplate de 12.0 o un addon de nameplates cambia esa estructura, sale un error en cada cambio de objetivo. (Verificar con la nameplate de 12.0.)
- **Solución:** comprobar cada campo (`local rt = UnitFrame.RaidTargetFrame; if rt and rt.RaidTargetIcon and ...`).

---

## BAJO

- **Attributes/3_Tooltip.lua:27**: cuando no hay buffs se concatena `tooltipText..effectiveStatDisplay` y el número del stat principal sale duplicado ("1234512345").
- **Attributes/3_Tooltip.lua:94**: `WoWTools_DataMixin:MK(3, frame.value - stat)` tiene los argumentos al revés, así que siempre muestra "- 3". La línea 92 compara `stat` (base) con `frame.value` (efectivo).
- **Attributes/3_Tooltip.lua:122 y 170**: `format('%.2f%%', critChance + 0.5)`. El +0,5 venía del redondeo con `%d` de Blizzard; con `%.2f` hace que el crítico y la celeridad salgan 0,5 % más altos.
- **Attributes/3_Tooltip.lua:199-207**: `nil,nil,nil,true` va dentro de `format()` en vez de `AddLine`, así que la línea de versatilidad no se ajusta (wrap).
- **Attributes/1_Setup.lua:123**: `'/'..BreakUpLargeNumbers(value)` debería usar `value2`.
- **Attributes/5_Blizzard_Settings.lua:442 y 474**: se asignan las globales `GreenColor` y `RedColor` (fuga de globales). No son las locales de 1_Setup.lua:7-8, así que el color de la barra no cambia hasta pulsar "reset".
- **Gem/1_Init.lua:479**: `SetDesaturated(num and num>0)` está invertido: el icono sale gris cuando hay cargas.
- **Collection/ClassList.lua:170**: `SetPoint('TOPLEFT', ListButton, 'BOTTOMLEFT', 0 -80)` pasa x=-80 y ninguna y (falta la coma). La lista de clases queda desplazada 80 px a la izquierda.
- **ObjectiveTracker/1_Init_Plus.lua:126**: `GetAchievementCriteriaInfoByID(achievementID, index)` recibe un índice donde se espera criteriaID; debe ser `GetAchievementCriteriaInfo(achievementID, index)`.
- **MainMenu/Character.lua:34**: `topoint=self.text2` debería ser `self.Text2`. En la línea 68 `'|cff626262:'` añade un ":" que se ve en el tooltip.
- **Faction/z_CHAT_MSG.lua:62**: la errata `info.atla` ya se menciona en C1.
- **Professions/ProfessionsFrame_Button.lua:147-152**: `tab[3]==10` compara un índice de `GetProfessions()` con un skillLine, y `table.remove` se hace sobre una tabla con huecos.
- **Holiday/Calendar_Uptate.lua:15**: se concatena el fileID del icono como texto. En la línea 63 el atlas del día usa `date('%d')` local y no se actualiza al pasar la medianoche.
- **Spell/Spell_Flyout.lua:90**: el patrón ptBR `'Teleporta para a entrada de (.-)'` sin ancla final captura "" (cadena vacía, que en Lua cuenta como verdadero), así que la etiqueta sale vacía en ptBR.
- **Cursor/Cursor.lua:207**: el bucle `for i=max(#Pool+#Used,maxParticles)+1, #Pool` nunca se ejecuta y no oculta las partículas sobrantes.
- **AddOns/Plus.lua:367-383**: el hook de "Desactivar todo" vuelve a activar `WoWTools_Chinese` en todos los clientes no zhCN (datos chinos que no se usan si no está `onlyChinese`).
- **PetBattle/Click_To_Move.lua:452-457**: cambia `PrestigePortrait:SetScale(0.6)` en el PlayerFrame (frame protegido) y cuelga el botón de ese contenido. Hay riesgo de taint y el módulo "Clic para mover" está en la carpeta PetBattle.

---

## UI / pulido

- **Target/2_Blizzard_Settings.lua:506**: `'|Acommon-icon-rotateright:0:0|a'` no tiene el ":" después de `|A`, así que el atlas se ve como texto roto.
- **Currency/z_TrackButton.lua:986**: dice `'Atl+'` en vez de `'Alt+'`.
- **AuctionHouse/C_AllAuctionsList.lua:94-98**: el texto del botón "Cancelar" es ambiguo (ver A2).
- **Holiday/1_Init.lua:39-52**: abre y cierra el calendario al iniciar sesión para forzar la carga (se ve un parpadeo). Mejor `C_AddOns.LoadAddOn("Blizzard_Calendar")` + `C_Calendar.OpenCalendar()`.
- **Friends/Blizzard_FriendsFrame.lua:243-249**: `C_Texture.GetTitleIconTexture` es asíncrono y añade el icono a `text` después de que se haya usado, así que casi nunca aparece.
- **Attributes/2_Button.lua:44**: el texto de chat usa `UnitHealthMax('player')` sin `canaccessvalue`. Si en 12.0 resulta ser secreto en combate, `MK()` fallaría.

---

## LOCALIZACIÓN

Resumen de conteos (grep en el alcance):
- **Fallbacks literales en inglés:** unas 25 cadenas del tipo `onlyChinese and '中文' or 'English'` (en una sola línea), más varias en varias líneas. En un cliente español salen en inglés. Ejemplos:
  - AddOns/2_MenuButton.lua:29, 57, 137, 165: `'Solution List'` es además una **mala traducción** de 方案列表/快捷键列表; debería ser "Perfiles" o "Lista de perfiles".
  - Attributes/5_Blizzard_Settings.lua:76, 153, 389, 605, 624 (`'value: '`, `'bit'`, `'Uppercase'`, `'Lowercase'`); Attributes/3_Tooltip.lua:422 `'Vehicle'` (existe la global `VEHICLE`).
  - Macro/2_Menu.lua:89 `'Button Plus'`, 372 `'Please do not use in combat'`; Macro/1_Init.lua:74; Macro/List_Bottom.lua:672 `'PetDismiss'`.
  - Color/2_Menu.lua:44, 96, 180; ObjectiveTracker/2_Menu.lua:180-181; Collection/ClassList.lua:154; Currency/z_TrackButton.lua:553 `'Pickup'`; Target/2_Blizzard_Settings.lua:506, 579; Cursor/2_Blizzard_Settings.lua:612 `'Random '`; Spell/2_Options.lua:41 `'SpellFlyout'`; AddOns/5_RightList_NewButton.lua:215 `'Selected'`.
- **Frases compuestas con `format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, A, B)`:** 90 usos (más 3 de `GARRISON_FOLLOWER_NAME`). Esta global está pensada para "Especialización Clase", no para unir palabras sueltas, y el orden y las preposiciones cambian según el idioma. En esES puede dar frases como "Ocultar Objetos" o "Bloquear Desactivar" sin sentido. Comprobar en juego con `/dump CLUB_FINDER_LOOKING_FOR_CLASS_SPEC`. Ejemplos: AuctionHouse/B_Sell_Menu.lua:32, 61, 143, 150; PetBattle/Click_To_Move.lua:96-97, 119, 418; Attributes/4_Menu.lua (reset valores).
- **Globales usadas fuera de contexto:** `SLASH_STOPWATCH_PARAM_STOP2` como "limpiar" (7 usos), `VOICEMACRO_1_Sc_0` como "¡Peligro!" (3), `NPE_ABANDON_A_RETURN` como "Volver" (Holiday/Calendar_Uptate.lua:70), `SLASH_PING1` (6), `HUD_EDIT_MODE_*` en muchos textos genéricos (95). En español pueden salir textos raros ("/cronómetro detener" o un grito de voz).
- **Lógica que depende del texto:**
  - Spell/Spell_Flyout.lua:76-92: los patrones en chino (77-79) solo afectan a zhCN (sin problema). El patrón español (83) solo cubre la forma "Teletransporte a la entrada del X." y no "de la"/"de"/"al"; con otro texto se usa el nombre del hechizo (impacto bajo). Mejor usar la tabla `ChallengesSpellTabs` (nombre de mazmorra por spellID) en todos los idiomas, no solo en `onlyChinese` (línea 155).
  - Faction/z_CHAT_MSG.lua: ver C1.
  - Attributes/5_Blizzard_Settings.lua:264, Cursor/2_Blizzard_Settings.lua:110, Hunter/UI.lua:89: `GLOBAL:gsub(OTRA_GLOBAL,'')` para quitar palabras funciona en inglés, pero en español puede dejar restos ("Calidad de sombras" → " de sombras").
  - AddOns/Plus.lua:405: compara con '加载过期插件', pero tiene el fallback `ADDON_FORCE_LOAD` (correcto).
- **Chino sin comprobación de `onlyChinese`:** no se encontró ninguno que se vea en clientes no chinos. Los casos detectados (Macro/z_MacroFrame_UI.lua:165, Hunter/Plus.lua:261, Attributes/5_Blizzard_Settings.lua:24, 39) están dentro de un `if onlyChinese`.
