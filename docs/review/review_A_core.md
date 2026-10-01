# Revisión A — Núcleo (0_Data, 1_Mixin, 2_Template, Z_Other, Container, Source)

Addon: WoWTools (Interface 120005, Midnight). Solo lectura: no se modificó ningún archivo fuente.
Alcance: se leyeron completos todos los `.lua` de 0_Data (salvo el volcado de datos `5_MapIDAchievements.lua`, que se analizó con script), 1_Mixin, 2_Template y Z_Other; en Container se leyeron completos Bank/1_Init, WoWData, Init_AllBank, Init_Plus (parcial), Plus_Money, Bag/*, Guild/Sort e Item_In_Out (parcial). En los demás se buscaron patrones concretos con grep. `Source/` solo contiene librerías de terceros y texturas, así que no tiene código propio que revisar.

Orden de carga relevante (WoWTools.toc): Libs → `0_Data/1_DataMixin` → `0_Data/z_Panel` → `0_Data/2_DataMixin_WoW` → … → `1_Mixin/*` → `2_Template/*` → Plus_* … → `Container/*` → `Z_Other/*` → ChatButton.

Convención: **[Verificado]** = comprobado leyendo el código y los llamadores. **[Riesgo]** = depende de un comportamiento del cliente que no puedo comprobar fuera del juego. Hay que confirmarlo en el juego.

---

## CRÍTICO

### C1. Se ocultan todos los errores Lua por defecto — `Z_Other/HelpTip.lua:64-70` [Verificado]
```lua
if ScriptErrorsFrame:IsShown() then ScriptErrorsFrame:Hide() end
ScriptErrorsFrame:HookScript('OnShow', function(self) self:Hide() end)
```
- El módulo "HelpTip" (ocultar tutoriales) viene **activado por defecto**: `WoWTools_OtherMixin:AddOption` devuelve `enabled = not disabledADD[name]` y `disabledADD` empieza vacío (`Z_Other/0_Init.lua:21,52`). Además de los tutoriales, oculta la ventana de errores de Blizzard cada vez que aparece.
- Escenario: el usuario activa `/console scriptErrors 1` para depurar el addon y no ve ningún error, ni de WoWTools ni de otros addons. Esto choca directamente con el objetivo de "arreglar bugs".
- Solución: borrar las líneas 64-70 o ponerlas tras una opción separada, desactivada por defecto ("Ocultar ventana de errores Lua").

---

## ALTO

### A1. Error Lua en clientes no chinos al pasar el ratón por el botón "Destruir" en combate — `Container/Bag/DeleteItem.lua:359` [Verificado]
```lua
GameTooltip_AddErrorLine(GameTooltip, WoWTools_DataMixin.onlyChinese and '战斗中', HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
```
- Falta el `or`: en esES/enUS el texto vale `false` y la cadena global acaba como parámetro `wrap`. `AddLine(false)` lanza un error.
- Escenario: en combate (con la opción "En combate" desactivada), el jugador pasa el ratón sobre el icono de papelera de la bolsa y salta el error.
- Solución: `WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT`.

### A2. El tooltip de pestañas del banco sale siempre en chino — `Container/Bank/Init_Plus.lua:228` [Verificado]
```lua
format(WoWTools_DataMixin and '指定到：|cnHIGHLIGHT_FONT_COLOR:%s|r' or BANK_TAB_DEPOSIT_ASSIGNMENTS, text)
```
- La condición es `WoWTools_DataMixin` (una tabla, siempre verdadera), no `.onlyChinese`.
- Escenario: en esES, al pasar sobre una pestaña del banco con filtros asignados aparece "指定到：…".
- Solución: `WoWTools_DataMixin.onlyChinese and … or BANK_TAB_DEPOSIT_ASSIGNMENTS`.

### A3. `MK()` escala mal los números en clientes no chinos — `0_Data/3_DataMixn_Func.lua:156-194` [Verificado]
- `>=1e8` se divide entre 1e8 y se marca como `'m'`. Entre 1e3 y 1e8 se divide entre 1e3 con `'k'`. Eso tiene sentido en chino (亿/万), pero en español/inglés da resultados absurdos:
  - 150.000.000 → "1.5m" (debería ser 150M).
  - 25.000.000 → "25000k".
- Se usa para oro (banco de banda, `Plus_Money.lua`, `Init_Plus.lua:95`), cantidades de objetos y contadores.
- Solución: si no es chino, usar `>=1e9 → 'B'` (/1e9), `>=1e6 → 'M'` (/1e6) y `>=1e3 → 'k'`. Los números negativos tampoco se tratan.

### A4. Comparador de ordenación inválido en la lista "Objetos de la banda" — `0_Data/z_WoWItemList.lua:1065-1077` [Verificado]
```lua
return v1.guid==Player.GUID or v1.itemLevel>v2.itemLevel or v1.score>v2.score or ...
```
- No es un orden estricto: `cmp(a,b)` y `cmp(b,a)` pueden ser ambos verdaderos (a tiene más nivel de objeto y b más puntuación). `DataProvider:Sort` usa `table.sort`, que con comparadores incoherentes puede lanzar `invalid order function for sorting` o dejar la lista desordenada.
- Escenario: más de 6-8 alters con mezcla de ilvl y puntuación M+; al abrir la ventana salta un error o la lista cambia de orden en cada búsqueda.
- Solución: comparador jerárquico:
  ```lua
  if (v1.guid==me) ~= (v2.guid==me) then return v1.guid==me end
  if v1.itemLevel~=v2.itemLevel then return v1.itemLevel>v2.itemLevel end
  if v1.score~=v2.score then return v1.score>v2.score end
  ...
  return v1.guid<v2.guid
  ```

### A5. La ordenación del banco de hermandad falla con objetos sin caché y además ordena mal — `Container/Guild/Sort.lua:45-128` [Verificado]
- En la línea 48 se usa `C_Item.GetItemInfo(itemLink)`, que devuelve nil si el objeto no está en caché. Luego el `table.sort` de las líneas 66-80 compara `a.icon < b.icon`, `a.rarity > b.rarity`, `a.subType < b.subType` con nil y lanza "attempt to compare nil with number" (pasa la primera vez que se abre una pestaña).
- Además, en el intercambio de las líneas 107-110, el objeto desplazado conserva su `slot` antiguo. En la siguiente iteración se coge el hueco equivocado y un objeto ya colocado (con `slot==indexSlot`) no vuelve a revisarse. El orden final puede quedar mal.
- Solución: precargar con `C_Item.GetItemInfoInstant(link)` (classID, subClassID e icono son síncronos), usar `or 0` en todos los campos y, tras cada intercambio, actualizar también el `slot` del objeto que ocupaba `indexSlot`. Lo más robusto es recalcular el estado leyendo `GetGuildBankItemLink` en cada paso.

### A6. Spam de `NotifyInspect` en bandas en cada GROUP_ROSTER_UPDATE — `0_Data/6_Cached.lua:98-147,241-242` → `Plus/Unit/0_UnitMixin.lua:744-776` [Verificado]
- Cada GROUP_ROSTER_UPDATE (evento muy frecuente en banda) programa hasta 40 `C_Timer.After(1..40, NotifyInspect)`. No hay deduplicación, ni comprobación de combate, ni cancelación.
- Escenario: en una banda de 20-30 personas con cambios de roster o rol, se acumulan cientos de timers. El servidor limita las inspecciones, así que la inspección de otros addons (Details, RaiderIO) y la del propio jugador fallan, y hay CPU desperdiciada.
- Solución: cola única con throttle (1 inspección cada ~1,5 s), un set de GUIDs pendientes, saltar si `InCombatLockdown()` o si ya hay datos recientes (<5 min), y cancelar la cola al salir del grupo.

### A7. Se guarda la facción del jugador en lugar de la de la unidad inspeccionada — `0_Data/6_Cached.lua:39` [Verificado]
```lua
local faction= UnitFactionGroup('player')
```
- Escenario: al inspeccionar a un jugador de la facción contraria (bandas de facción cruzada), `PlayerInfo[guid].faction` queda con tu facción. Los iconos y colores que dependen de ella salen mal.
- Solución: `UnitFactionGroup(unit)`.

### A8. Cálculo de "semana" en hora local: borra o conserva bloqueos erróneamente — `0_Data/1_DataMixin.lua:53-67` y `0_Data/2_DataMixin_WoW.lua:487-503` [Verificado]
- `GetWeek()` usa `date('*t')` local, a medianoche, y no la hora real del reinicio (US: martes 15:00 UTC; EU: miércoles 04:00 UTC). Solo se calcula al cargar (`Player.Week`).
- Escenario EU: el miércoles a las 00:30 locales entras con un alter. La semana ya "cambió", así que se borran bandas y mazmorras de todos los personajes. Después `UPDATE_INSTANCE_INFO` guarda los bloqueos antiguos (aún válidos hasta las 04:00) con la semana nueva y se quedan como "de esta semana" hasta que vuelvas a entrar con ese personaje.
- En los años de 53 semanas, el valor 52 se repite o salta en torno al 1 de enero.
- Solución: clave de semana basada en el servidor:
  ```lua
  floor((GetServerTime() + C_DateAndTime.GetSecondsUntilWeeklyReset()) / 604800)
  ```
  y recalcularla al volver a entrar en el mundo.
- Extra: `tab.Keystone.day` nunca se asigna (`grep`: solo se lee en las líneas 494 y 497), así que el reinicio diario para Timerunning es código muerto.

### A9. `ScaleFrame` nunca detecta el combate — `1_Mixin/Frame.lua:79` [Verificado]
```lua
if WoWTools_FrameMixin.IsLocked(frame) then   -- llamada con '.', no ':'
```
- Con la llamada con punto, `self=frame` y el parámetro `frame=nil`, así que `IsLocked` siempre devuelve nil. Además, aunque devolviera true, solo imprime y **no hace `return`**: sigue a `SetScale` y a `set_scale()`.
- Escenario: Alt+rueda sobre un marco protegido en combate provoca ADDON_ACTION_BLOCKED o taint.
- Solución: `if self:IsLocked(frame) then print(...) return value end`.

### A10. Valores por defecto peligrosos: autocompletar "DELETE" en todos los diálogos de confirmación — `Z_Other/DELETE.lua:8-13` [Verificado]
- Viene activado por defecto (mismo mecanismo que C1). `hooksecurefunc('ConfirmationEditBoxMatches')` rellena la palabra de confirmación en **cualquier** diálogo que la pida: destruir objetos épicos, borrar la comunidad o hermandad (`CONFIRM_DESTROY_COMMUNITY`), destruir decoración de vivienda… Además baja `acceptDelay` a 0,5 s.
- Escenario: un doble clic accidental destruye un objeto valioso.
- Solución: desactivarlo por defecto (`disabledADD.DELETE=true` en los valores iniciales) y limitarlo a la lista blanca `DELETE_GOOD_ITEM` / `DELETE_GOOD_QUEST_ITEM`.
- Nota de taint: modificar `StaticPopupDialogs["UNLEARN_SKILL"|"DELETE_GOOD_ITEM"...].acceptDelay` (líneas 2-6) y `StaticPopupDialogs['GAME_SETTINGS_APPLY_DEFAULTS'].acceptDelay` (`1_Mixin/StaticPopupDialogs.lua:42`) escribe en tablas de Blizzard. La lectura de un valor contaminado dentro de `StaticPopup_Show` extiende el taint al diálogo. **[Riesgo]** de "Acción bloqueada" si el OnAccept llama a funciones protegidas.

### A11. "Desactivar todo" en los filtros de bolsa activa todos los flags en el servidor — `Container/Bag/Container_Menu.lua:338-342` [Verificado]
```lua
C_Container.SetBagSlotFlag(data.bagID, flag, true)            -- debería ser false
ContainerFrameSettingsManager:SetFilterFlag(data.bagID, flag, false)
```
- Escenario: el jugador pulsa "Desactivar todo" y la bolsa pasa a aceptar todas las categorías. La UI local muestra que no, hasta /reload.
- Solución: pasar `false` en `SetBagSlotFlag`.

### A12. Datos de logros triplicados: contadores ×3 y entradas repetidas — `0_Data/5_MapIDAchievements.lua` + `Z_Other/Achievements.lua:16-68` [Verificado con script]
- Las 243 listas por mapa tienen duplicados: 10.905 IDs en total, 7.270 repetidos. Por ejemplo, el mapa 998 tiene 39 entradas y solo 13 únicas.
- `Get_List_Tab` cuenta cada entrada: el botón muestra "15/39" en vez de "5/13" y cada logro aparece 3 veces en el menú.
- Además, `table.sort(mapData)` en la línea 26 ordena la tabla global en cada llamada.
- Solución: deduplicar al cargar (set temporal) o limpiar el archivo de datos con un script.

---

## MEDIO

### M1. La búsqueda trata el texto del usuario como patrón Lua — `0_Data/z_WoWItemList.lua` (59 `:find(findText)`, p. ej. líneas 89, 90, 199, 1010-1027) [Verificado]
- El texto de la búsqueda se pasa a `string.find` sin `plain=true`.
- Escenario: escribir `[`, `(` o `%` lanza "malformed pattern" en cada pulsación. `-` y `.` dan coincidencias falsas.
- Además, `:upper()` solo convierte ASCII, así que "é" y "É" no coinciden (típico en nombres en español).
- Solución: `name:find(findText, 1, true)`. Para mayúsculas/minúsculas, usar `strlower` o `string.utf8lower` si está disponible.

### M2. `WoWTools_DataMixin:Load(id,'club')` nunca hace nada — `0_Data/3_DataMixn_Func.lua:98` [Verificado]
- Compara `elseif id=='club'` en lugar de `typeString=='club'`. Lo llaman `ChatButton/C6_World/3_Menu.lua:25` y `2_SetButton.lua:151`, sin efecto.
- Solución: `elseif typeString=='club' then`.

### M3. `SecondsToFullTime` muestra los minutos como segundos — `1_Mixin/Time.lua:107` [Verificado]
- `str .. minutes ..'s'` debería ser `seconds`. Ejemplo: 2h 30m 15s se muestra como "2h30m30s" (se usa para el tiempo jugado).

### M4. Error si se llama a `ItemLocationMixin:GetItemTexture()` — `1_Mixin/ItemLocation.lua:179` [Verificado, latente]
- Llama a `self:itemID()`, un método que no existe. Hoy no tiene llamadores, pero es una trampa.
- Solución: `self:GetItemID()`.

### M5. Tooltips con parámetros equivocados — `1_Mixin/SetTooltip.lua` [Verificado]
- **L487:** `local areaPoiID= data.uiMapID`. Cualquier `data` con `uiMapID` entra en `set_areaPoiID(tooltip, uiMapID, uiMapID)` y muestra el POI equivocado o nada. Solución: `data.areaPoiID`.
- **L539 y L543:** el título usa el `questID` local (de `data.questID`) en lugar de `frame.questID`, así que sale "" cuando solo viene el frame.
- **L285-288:** el comparador del `table.sort` no hace `return` (y `strcmputf8i` devuelve un número). Las mazmorras del enlace de puntuación M+ no se ordenan. Solución: `return strcmputf8i(a.mapName, b.mapName) < 0`.

### M6. El nombre de dificultad heredada muestra el ID numérico — `1_Mixin/Map.lua:155-158` [Verificado]
- `format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, difficultyID, '10')` da "3 10" o "5 10" en lugar de "Clásico 10". Se pierde también "Heroico" en 5 y 6.
- Solución: `format('%s %s', difficultyName, '10')`, o `GetDifficultyInfo(difficultyID)`.

### M7. Tabla de reinos: nombres US que no coinciden y reinos españoles mal etiquetados — `1_Mixin/Realm.lua` [Verificado]
- **US (líneas 82-135):** las claves tienen espacios ("Aerie Peak", "Area 52", "Moon Guard"…), pero `Player.Realm` elimina los espacios (`1_DataMixin.lua:48`) y el reino de `UnitName` viene normalizado sin espacios. Unos 60 reinos US nunca coinciden.
- **EU:** `["C'Thun"]` y `["ColinasPardas"]` están como `enGB` (líneas 48-49), pero son reinos **esES**; `CultedelaRivenoire` es frFR. Con "Azjol-Nerub" (con guion) tampoco coincide la clave `AzjolNerub`.
- Escenario: un jugador en esES ve la etiqueta "GB" en compañeros de C'Thun o Colinas Pardas.
- Solución: normalizar las claves con `gsub('[%s%-]','')` al construir la tabla y corregir los tres idiomas.

### M8. Precedencia de operadores: se sobrescriben métodos también en la bolsa combinada — `Container/Bag/Container_Menu.lua:38` [Verificado]
- `if not self~=ContainerFrameCombinedBags then` se evalúa como `(not self) ~= X`, que siempre es verdadero. Se sustituyen `GetPaddingWidth` y `CalculateWidth` también en la bolsa combinada, que tiene su propio cálculo, y el ancho sale mal.
- Solución: `if self ~= ContainerFrameCombinedBags then`.
- Nota: además, sustituir métodos de ContainerFrame contamina la generación de los botones seguros de objeto. **[Riesgo]** de acciones bloqueadas si las bolsas se regeneran en combate; `Update_Frame` (líneas 53-66) llama a `ContainerFrame_GenerateFrame` desde el menú sin comprobar combate. La opción está desactivada por defecto, salvo para el autor.

### M9. Recompensa "mejor calidad" que en realidad es la última — `1_Mixin/Quest.lua:104-140` [Verificado]
- `bestQuality` nunca se actualiza dentro del bucle, así que gana la última recompensa. Solución: `bestQuality = quality` al elegir.
- **L456:** `GetAvailableQuestInfo(questLogIndex)` es para las misiones disponibles del NPC en el diálogo actual, no para índices del registro, así que fuera del diálogo el icono sale nil o equivocado.
- **L23:** `IsValidQuestID('abc')` compara una cadena con un número y lanza un error.

### M10. `CSlider`: parámetros inconsistentes — `1_Mixin/Slider.lua:63-73` [Verificado]
- `if tab.tip then SetScript('OnEnter', tab.tips)`: la documentación usa `tips`. Si se pasa `tips`, se ignora; si se pasa `tip`, se asigna un handler nil.
- Si falta `tab.setp`, `SetValueStep(nil)` y `'Setp: '..nil` fallan al pasar el ratón. Además "Setp" es inglés, con errata y sin localizar.
- La rueda está invertida: hacia arriba baja el valor.
- No hay `SetObeyStepOnDrag(true)`, así que al arrastrar se devuelven decimales.

### M11. Colores por especialización que colisionan en idiomas no chinos — `Z_Other/ClassMenuColor.lua:104-121,127-143` [Verificado]
- La tabla usa el **nombre** de la especialización como clave. Solo se separan Escarcha de DK (251) y de mago (64) con sufijos, y además la búsqueda de 64 falla porque se guardó sin sufijo.
- En esES/enUS colisionan "Sagrado" (paladín/sacerdote), "Restauración" (druida/chamán) y "Escarcha" (DK/mago): una de las dos clases sale con el icono y el color de la otra.
- `hooksecurefunc(MenuUtil,'SetElementText')` añade initializers a **todos** los menús del juego, incluidos los de Blizzard (menú contextual de unidad). **[Riesgo]** de taint en entradas protegidas.
- Solución: usar `desc.data.specID` cuando exista y limitar el hook a menús concretos con `Menu.ModifyMenu`.

### M12. Error por concatenar nil — `Z_Other/Talking.lua:98-105` [Verificado]
- La condición es `(text or voHandle)`, pero luego se hace `'|cff00ff00'..name..'|r'` y `..text..`. Si `text` o `name` son nil (cabeza parlante solo con voz), salta un error.
- Solución: `(name or '')` y `(text or '')`.
- Además, ocultar todas las cabezas parlantes viene activado por defecto (`Save().disabled` es nil). Ver UI.

### M13. "Restablecer posición" no hace nada — `Z_Other/DormantSeeds.lua:316` [Verificado]
- Borra `Save().Point`, pero la posición se guarda en `Save().point` (líneas 49 y 105).
- Además, `Init()` al desactivar llama a `set_Shown(false)`, que sigue mostrando el botón dentro de la zona (`show or (uiMapID and …)`).
- El tooltip (L323) usa `GetName(2200)` con un uiMapID como si fuera un itemID.

### M14. Mensajes y funciones invertidas — [Verificado]
- `Z_Other/ScrappingMachine.lua:559` y `Z_Other/Achievements.lua:755`: `GetEnabeleDisable(Save().disabled)` imprime "Activado" al desactivar.
- `Z_Other/ScrappingMachine.lua:503`: `if not spellID or self:IsMouseOver() then return` está dentro de OnEnter, así que siempre retorna y el tooltip del hechizo de desguace nunca aparece. Solución: quitar `or self:IsMouseOver()`.

### M15. "Restablecer valores por defecto" del panel restaura los valores de la carga, no los reales — `1_Mixin/PanelMixin.lua:169-177,232-240,260-278,334-342,368-386,417-425` [Verificado]
- `defaultValue = tab.GetValue()`, es decir, el valor actual al registrar. Muchos `SetValue` ignoran el argumento y simplemente alternan (p. ej. `0_Data/z_Panel.lua:190`, `233`; `Z_Other/0_Init.lua:29`).
- Escenario: el botón "Predeterminados" de la categoría WoWTools en Opciones no devuelve los valores de fábrica y puede invertir casillas.
- Solución: pasar un default real en `tab.default` y hacer que `SetValue(value)` asigne el valor recibido en lugar de alternar.
- Nota: en `OnlySlider` y `Check_Slider` el mismo `SetValue` se registra como setter del proxy (recibe `value`) y como `SetOnValueChangedCallback` (recibe `owner, setting, value`). Los llamadores usan `(_,_,value2)` y el primer disparo llega con nil (p. ej. `Plus_Item/1_Init.lua:28` pone `size=10` momentáneamente). Funciona de rebote, pero es frágil.

### M16. Sustitución de métodos de BankPanel (taint) — `Container/Bank/Init_AllBank.lua:49,158,353`, `Init_Plus.lua:108` [Riesgo]
- Se reemplazan `BankPanel:RefreshHeaderText`, `GenerateItemSlotsForSelectedTab`, `DepositButton:UpdateTextForBankType` y `BankPanel:RequestTitleRefresh`. Así, los botones de objeto del banco se crean desde código del addon, y BankFrame (un UIPanel gestionado) queda contaminado.
- Escenario: abrir o cerrar paneles o interactuar con el banco justo al entrar en combate, con "Acción bloqueada por un addon".
- Mitigación: usar `hooksecurefunc` y post-procesado en lugar de reemplazar, o como mínimo no tocar métodos cuando `allBank` está desactivado (el reemplazo de `RequestTitleRefresh` es incondicional).
- Rendimiento: con `allBank`, cada BAG_UPDATE de una pestaña no seleccionada llama a `MarkDirty` (L371-375), que regenera ~588 botones por cada depósito.

### M17. Desactivar el banco en Opciones lo inicializa — `Container/Bank/1_Init.lua:105-109` [Verificado]
- `SetValue` llama a `Init()` tanto al activar como al desactivar. Al desmarcar la casilla se instalan todos los hooks y reemplazos del banco.
- Solución: `if not Save().disabled then Init() end` y avisar de que hace falta /reload.

### M18. Riesgo de orden de ADDON_LOADED en instalación limpia — `0_Data/z_Panel.lua:266-274` [Riesgo]
- `WoWToolsSave['WoWTools_Settings']= …` asume que `WoWToolsSave` existe, pero se inicializa en `2_DataMixin_WoW.lua:433` (un callback de EventRegistry registrado **después** en el orden de carga). Si el frame de z_Panel recibe ADDON_LOADED antes, en una instalación sin SavedVariables da "attempt to index nil".
- Solución: `WoWToolsSave = WoWToolsSave or {}` al principio del handler de z_Panel (no cuesta nada).

### M19. Etiquetas de retirar dinero que dicen "Depositar" — `Container/Bank/Plus_Money.lua` [Verificado]
- **L358-359:** el menú "提取" (retirar) comprueba `CanDepositMoney` y en otros idiomas muestra `DEPOSIT`.
- **L447:** "全部提取" (retirar todo) cae a `format(…, ALL, DEPOSIT)`.
- **L463:** '填充' cae a `DEPOSIT`.
- **L404:** el tooltip de retiro automático usa `Save_Tooltip` (el de depositar).
- Solución: usar `WITHDRAW`, `CanWithdrawMoney` y `Out_Tooltip`.

### M20. `TextMixin:sub` corta UTF-8 a mitad de carácter en idiomas no chinos — `1_Mixin/Text.lua:180-182` [Verificado]
- Solo detecta chino (bytes 0xE4-0xE9). Para "é", "ñ", cirílico o coreano hace `text:sub(1, n)` por bytes y puede dejar un byte suelto, que se muestra como "?" o hace desaparecer el texto.
- Solución: usar siempre el bucle UTF-8 (líneas 184-210) o `strutf8sub` / `utf8.offset` si están disponibles.

### M21. Radios de transparencia que nunca aparecen marcados — `1_Mixin/Menu.lua:349-358` [Verificado]
- `for i=0, 1.0, 0.1` acumula error de coma flotante (0.30000000000000004…; el último valor es 0.9999999 y no 1.0). La comparación `GetValue()==alpha` con el valor guardado del slider (`tonumber(format('%.1f'))`) falla en varios pasos y la opción 1.0 no existe.
- Solución: `for k=0,10 do local i=k/10 …`.

### M22. Otros bugs lógicos pequeños [Verificado]
- `Container/Bank/WoWData.lua:111`: `ipairs` sobre una tabla indexada por itemID nunca itera, así que la comprobación "ya guardado" es código muerto y se re-escanea siempre. Usar `next(...)`.
- `1_Mixin/Button.lua:110-112`: `btn:GetText()` en los CheckButton creados no devuelve nada (falta `return`).
- `1_Mixin/Cooldown.lua:77-79,86-87`: los lanzamientos y canalizaciones de otras unidades usan `start=GetTime()` en lugar de `startTime/1000`, así que el barrido empieza lleno aunque el lanzamiento vaya por la mitad. `Reverse` solo se aplica al crear el Cooldown.
- `Z_Other/Brewfest.lua:168`: `self.Timer=nil` debería ser `self.Time=nil` (el contador no se reinicia).
- `0_Data/2_DataMixin_WoW.lua:200-221`: en cada BAG_UPDATE_DELAYED hay 2 `GetItemCount` por hueco (unos 150 huecos, ~300 llamadas). Mejor agrupar por itemID primero y llamar una vez por objeto único.
- `Z_Other/Achievements.lua:569`: `flags==0x20000` debería ser `bit.band(flags, ACHIEVEMENT_FLAGS_ACCOUNT)~=0`.
- `Container/Bank/Plus_Money.lua:265,429`: se pone `OnUpdate` a un slider del menú (frame del pool) sin limpiarlo en `OnHide`. **[Riesgo]** si el pool de plantillas del menú es compartido: un slider reutilizado en otro menú seguiría ejecutando `SetEnabled(Save().autoSaveMoney)`.

---

## BAJO

- `0_Data/3_DataMixn_Func.lua:18-37`: en `Hook`, la comprobación `IsForbidden` no sirve: `select(2, o:IsForbidden())` siempre es nil y después se llama a `hooksecurefunc` igualmente.
- `0_Data/3_DataMixn_Func.lua:259-265`: `format('%.1f', C_CVar.GetCVar(name))` falla si el CVar no existe o no es numérico.
- `0_Data/3_DataMixn_Func.lua:310-315`: `GetFormatter1to10` es la identidad; `RoundToSignificantDigits(v, maxValue)` usa `maxValue` como número de decimales, lo que no tiene sentido.
- `0_Data/1_DataMixin.lua:283`: `if not _G[SLASH_INFOSLASH1]` es `_G[nil]`, una comprobación inútil (y puede pisar un `/info` de otro addon).
- `0_Data/1_DataMixin.lua:97`: `IsMaxLevel` se calcula al cargar. Se actualiza en PLAYER_LEVEL_UP, pero no con cambios de expansión o en Timerunning.
- `1_Mixin/Label.lua:192`: `itemQuality>=1` con nil si el objeto no está en caché (latente: hoy solo hay divisas en la lista).
- `1_Mixin/Aura.lua:45-47`: `spellTab[data.spellId]` con `spellId` secreto (12.0, en combate, unidades ajenas) lanza un error por usar un secreto como clave. `canaccessvalue(data)` no protege los campos. Hoy solo se usa con 'player' (`Plus/Gossip/Gossip.lua:61`).
- `1_Mixin/LoadUI.lua:391`: `renownLevelsInfo[#renownLevelsInfo].level` falla con una lista vacía. `LoadUI.lua:556` escribe en `DelvesCompanionConfigurationFrame` (taint).
- `1_Mixin/Menu_List.lua:386`: se usa `GameTooltip` en lugar del parámetro `tooltip`.
- `Container/Bag/0_BagMixin.lua:200-205,224-229`: los IDs de bolsas de banco `NUM_TOTAL_EQUIPPED_BAG_SLOTS+1..7` están obsoletos desde el banco por pestañas de 11.2.
- `Container/Bag/DeleteItem.lua:178-181`: por precedencia, con `auto` activo `rightText` es solo el código de color (texto vacío).
- `Container/Bag/DeleteItem.lua:396,430`: el tooltip cambia `C_Container.SetItemSearch` y al salir lo pone a '', con lo que borra la búsqueda que tuviera el usuario.
- `Z_Other/Brewfest.lua:213`: `CreateMacro('Ram', …)` crea una macro duplicada en cada Shift+clic y no comprueba combate.
- `Z_Other/Fstack.lua:249`: `text:match('Frame Attributes %- (.+)')` solo funciona con el título en inglés.
- `Z_Other/HelpTip.lua:100-102`: también oculta SplashFrame ("Novedades") en cada inicio de sesión.

---

## UI / PULIDO

- **Valores por defecto intrusivos** (todo activado sin preguntar): ocultar tutoriales **y la ventana de errores** (C1), autocompletar DELETE (A10), ocultar todas las cabezas parlantes (`Talking.lua`), el marco de marcadores de banda (`MakerFrame.lua`) y los colores en menús de clase (`ClassMenuColor.lua`). Recomiendo activar solo lo inocuo y que el resto sea opcional.
- **Fuente forzada:** `1_Mixin/Label.lua:39,63-69`. `size` vale 12 por defecto y la condición `onlyChinese or size` siempre se cumple, así que **todas** las etiquetas creadas con el mixin pasan a 12 px con OUTLINE (`notFlag` es la única salida) e ignoran el objeto de fuente y la escala de texto del usuario. Solución: aplicar `SetFont` solo si se pasa `tab.size` explícitamente y conservar las flags originales.
- **Menús con scroll más altos que la pantalla:** `1_Mixin/Menu.lua:870`, `math.max(20*35, GetScreenHeight()-70)`. Con una escala de UI de 1.0 (alto ≈768) el menú mide 700 px o más y puede salirse. Usar `math.min`.
- **Rueda invertida** en `CSlider` (`Slider.lua:40-44`) y en el slider del menú (`Menu.lua:111-115`): arriba = menos, al revés que en la UI de Blizzard.
- **Botón y texto en chino en español:** `Menu.lua:552` (`MicroButtonTooltipText('天赋和法术书', …)`) y la línea "Bug" en inglés (L559). Usar `TALENTS_BUTTON` o `PLAYERSPELLS_BUTTON`.
- **Etiqueta del banco** `Container/Bank/Init_Plus.lua:86,102`: se sustituye el texto de la pestaña por `ACCOUNT_QUEST_LABEL` ("Banda") y `BANK` con `SetText` una sola vez. Si Blizzard actualiza el texto (cambio de pestaña), se pierde o se recorta.
- **Posiciones:** la mayoría de marcos usan `WoWTools_MoveMixin:Setup` (fuera de este alcance). Brewfest y DormantSeeds guardan la posición a mano, con claves inconsistentes (`Point` / `point`, M13).
- **Tooltip del Frame Stack y del banco:** `BankPanel.MoneyFrame:SetFrameStrata('HIGH')` (`Plus_Money.lua:731`) puede quedar por encima de otros diálogos (p. ej. los de StaticPopup en DIALOG no, pero sí ventanas MEDIUM del usuario).

---

## LOCALIZACIÓN (esES/esMX/enUS)

**Modelo:** `onlyChinese = LOCALE_zhCN or Save().onlyChinese`. En esES se usan las globales de Blizzard, que salen traducidas. zhTW no entra en `onlyChinese` (usa las globales, correcto). La tabla `Language` de `1_DataMixin.lua:175-235` sí cubre `esES`/`esMX` ('Capa', 'Palabras clave').

1. **Chino visible sin fallback (bugs reales):** 3 casos.
   - `Container/Bank/Init_Plus.lua:228` (A2)
   - `1_Mixin/Menu.lua:552` (texto del menú "天赋和法术书")
   - `Container/Bag/DeleteItem.lua:359` (A1: además provoca un error)

   Mi escaneo (script) encontró 144 líneas con chino sin `onlyChinese` en el alcance. El resto son datos internos (tabla `WoWTools_ChallengesSpellData` de `4_DataMixn_NeedUpdate.lua`, cuyos `spellDes`/`spellName` no se usan fuera, y `name` solo con `onlyChinese`), claves internas de `Map.lua:75-123`, `ClassName_CN` (protegido en su uso), mensajes de depuración solo para el autor (`husandro`) o los mensajes de chat para la región CN/TW (`MakerFrame.lua:477,486`). `Container/Guild/2_Menu.lua:87` es un falso positivo: está dentro de un `if onlyChinese`.
2. **Inglés literal que no se traduce:** 17 fallbacks `onlyChinese and '…' or 'English'`: 'WoWTools Data', 'Clear input data', 'Clear WoW data', 'Realm', 'Strata', 'Story', 'Tab'×2, 'Index'×2, 'Interval', 'No data', 'Errors may occur', 'DormantSeeds', 'Difficulty can be changed', 'ChatBox input text', 'Veteran'. A eso se suman concatenaciones como `CLEAR_ALL..' WoW data'` (`z_WoWItemList.lua`), `'Setp: '` (Slider), `'Bug'` (Menu.lua:559), `'Region'` y `'STOP STOP STOP'` (MakerFrame para EU/US). Recomiendo una tabla `L` mínima con esES/esMX para estas ~25 cadenas.
3. **Frases compuestas con `CLUB_FINDER_LOOKING_FOR_CLASS_SPEC`:** 67 usos en el alcance (391 en todo el addon). Se usa como "pegar dos palabras" (`format(X, ADD, ITEMS)`). **[Riesgo]:** no puedo ver el valor esES/esMX desde aquí. Si incluye preposición o reordena (`%2$s %1$s`), todas estas etiquetas quedan antinaturales o invertidas en español. Conviene comprobarlo en el juego con `/dump CLUB_FINDER_LOOKING_FOR_CLASS_SPEC` y, si procede, sustituirlo por `'%s %s'` o por cadenas propias.
4. **Lógica que depende del texto:**
   - `Z_Other/ClassMenuColor.lua` usa el nombre de la especialización como clave: colisiones en esES (M11).
   - `Container/Guild/Sort.lua:160`: `REVERSE_CLEAN_UP_BAGS_TEXT:gsub(HUD_EDIT_MODE_BAGS_LABEL, BANK)` distingue mayúsculas; si en esES "Bolsas" y "bolsas" no coinciden, la etiqueta sigue diciendo "bolsas".
   - `Container/Bag/Container_Menu.lua:83`: `EQUIP_CONTAINER_REAGENT:gsub(EQUIPSET_EQUIP,'')` es la misma idea.
   - `Z_Other/Achievements.lua:483`: `rewardText:match(SCENARIO_BONUS_REWARD..'(.+)')` depende del formato exacto por idioma.
   - `Z_Other/Fstack.lua:249`: solo en inglés.
   - `0_Data/z_WoWItemList.lua:1193`: usa `CHALLENGE_MODE_KEYSTONE_NAME` (correcto) más patrones chinos de respaldo (inofensivos).
   - Mayúsculas y recortes: `:upper()` solo ASCII (M1) y `TextMixin:sub` por bytes (M20) afectan a las tildes y la ñ.
5. **No encontré** en este alcance parseo de tooltips o hechizos con texto chino que rompa la lógica en otros idiomas: el parseo usa globales o `WoWTools_TextMixin:Magic`. Ojo: `Magic` (`Text.lua:105-134`) nunca escapa `%` porque `find=true` se activa siempre, así que una global con "%" literal (p. ej. "100%") genera un patrón mal formado.

---

## Notas de 12.0 (Midnight) / secretos
- El código comprueba de forma general `canaccessvalue`, `canaccesstable`, `issecretvalue` y `canaccesssecrets` (bien).
- Puntos donde un secreto podría usarse como clave o compararse:
  - `Aura.lua:47` (latente).
  - `Brewfest.lua:167` (`info.spellId==43052` en UNIT_AURA; fuera de instancia, poco probable).
  - `6_Cached.lua:138-141` (`GroupGuid[UnitName(unit)]`). **[Riesgo]** si en 12.0 algún nombre de miembro es secreto en contenido restringido.
- APIs revisadas sin incidencias: `C_Item.*`, `C_Spell.*`, `C_Container.*`, `C_Bank.*`, la API de Settings 11.x, y `StaticPopup` con `GetEditBox`/`GetButton1` (API 11.2).
