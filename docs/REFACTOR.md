# Plan de refactor de WoWToolsPlus

Objetivo: que el código sea fácil de entender y de cambiar **sin cambiar lo que hace el addon en el juego**.
Cada paso es pequeño, va en su propio commit, pasa la revisión automática (CI) y se prueba en el juego.

## Situación de partida (medida con scripts y el grafo de CodeGraphContext)

| Síntoma | Cantidad |
|---|---|
| Módulos con su propio marco `ADDON_LOADED` + `arg1=='WoWToolsPlus'` | 48 |
| Copias de `local function Save()` | 180 |
| Funciones "de una sola vez" hechas a mano (`Init=function()end`) | 169 |
| Esperas a addons de Blizzard (`Events[arg1]` y similares) | 96 |
| Archivos de arranque (`1_Init.lua`) | 34 (7.800 líneas) |
| Funciones con complejidad > 100 | 8 (la mayor: 263) |

## Reglas

1. **Mismo comportamiento.** Un refactor no cambia lo que ve el jugador; si hace falta un cambio de comportamiento, va en un commit aparte.
2. **Un módulo por commit**, del más pequeño al más grande.
3. **Nada se da por bueno sin CI en verde y una prueba en el juego** (lista de comprobación de cada módulo abajo).
4. **Los ajustes guardados no se tocan**: mismas claves en `WoWToolsPlusSave`, así nadie pierde su configuración.

---

## Fase R1 — API común de módulos

Nuevo archivo `1_Mixin/Module.lua` con una sola función para registrar un módulo:

```lua
local M = WoWTools_Module:Register({
    key      = 'Plus_Mail',          -- clave en WoWToolsPlusSave (la de siempre)
    name     = 'Module.Mail',        -- clave de WoWTools_L para el nombre
    icon     = 'UI-HUD-Minimap-Mail-Mouseover',
    group    = 'Items',              -- grupo del panel principal
    defaults = { ... },              -- valores por defecto (SetDefaults)
    tooltip  = 'Tip.Mail.Enable',
    reload   = true,                 -- "requiere recargar" al cambiar la casilla
    onEnable = function(M, save) ... end,              -- arranque del módulo
    blizzard = { Blizzard_MailFrame = function(M) ... end }, -- al cargar esa ventana de Blizzard
})
-- En los demás archivos del módulo:
M:Save().algo
```

Lo que hace por dentro, igual para todos:
- Espera a `ADDON_LOADED` de WoWToolsPlus (un único marco para todo el addon).
- Aplica `SetDefaults`, crea `addName` con icono y la casilla del panel en su grupo.
- Si el módulo está desactivado, no arranca nada.
- `onEnable` se ejecuta **una sola vez** (se acaba el truco `Init=function()end`).
- `onLoad` se ejecuta siempre, aunque el módulo esté desactivado (páginas de opciones propias, contadores).
- `events` = eventos del juego con un único marco para todos los módulos (devolver true deja de escucharlo).
- Las funciones de `blizzard` se ejecutan cuando esa ventana está cargada (ya o más tarde), con `EventUtil.ContinueOnAddOnLoaded`.

Además:
- `WoWTools_Once(fn)`: envoltorio "ejecutar una vez" para los casos sueltos.
- El panel principal agrupa por `group` en lugar de adivinarlo por el nombre (`Organize_Main` se simplifica).

Y el **sistema de estilo** `WoWTools_Style` (ver `docs/MEJORAS.md`, sección 5): estilo minimalista oscuro común.

**Entregable:** la API y el estilo, con pruebas (ver R6), y **un módulo pequeño migrado** como ejemplo (Selector de color).

## Fase R2 — Migrar los módulos (uno por commit)

Orden, de menos a más riesgo:

1. Pequeños: Selector de color, Eventos festivos, Establo de cazador, Gemas, Profesiones, Vivienda, Macros.
2. Medianos: Correo, Subasta, Monedas, Reputación, Colecciones, Logros, Lista de amigos, Rastreador de objetivos, Micromenú, Cursor, Atributos, Marcos de unidad, Hechizos, Personaje, Guía de aventuras, Gestor de addons.
3. Grandes: Míticas+, Herramientas (y cada botón), Botón de chat (y cada submódulo), Mover marcos, Estilo de barras de acción.

Por cada módulo: quitar su marco `ADDON_LOADED`, sus copias de `Save()` y sus `Init=function()end`, y aplicar `WoWTools_Style` a lo que dibuja.

## Fase R3 — Un solo sistema para esperar ventanas de Blizzard

`WoWTools_MoveMixin.Events`, `WoWTools_TextureMixin.Events` y los `if arg1=='Blizzard_X'` pasan al campo `blizzard` de R1.
Se eliminan los despachadores propios de Mover marcos y Texturas.

## Fase R4 — Partir las funciones gigantes

Sin cambiar comportamiento: extraer trozos con nombre (crear marco, menú, actualizar, tooltip).

| Función | Líneas | Complejidad |
|---|---|---|
| `ChatButton/C5_LFD/Queue_Status.lua` → `Set_Queue_Status` | 297 | 262 |
| `Plus_Item/0_SetupInfo.lua` → `Get_Info` | 518 | 241 |
| `Plus/Encounter/Plus.lua` → `Init` | 592 | 158 |
| `Plus_Tooltip/f_Unit_Player.lua` → `Set_Unit_Player` | 309 | 143 |
| `Plus/Attributes/5_Blizzard_Settings.lua` → `Init_Options` | 638 | 120 |
| `Plus/Unit/PlayerFrame.lua` → `Init` | 557 | 111 |
| `Plus/Friends/Blizzard_FriendsFrame.lua` → `Init` | 342 | 100 |

Meta: ninguna función por encima de ~40 de complejidad ni de ~150 líneas.

## Fase R5 — Orden y nombres

- Carpetas: agrupar en `Core/` (0_Data, 1_Mixin, 2_Template), `Modules/<Módulo>/`.
- Nombres de archivo con erratas: `Foucs.lua`, `Durabiliy.lua`, `Calendar_Uptate.lua`, `Item_PoaperDll.lua`, `Reaml.lua`, `L4_UsaItems`…
- Quitar del `.toc` los nombres antiguos de SavedVariables (migración ya hecha).
- Quitar los 10 `onlyChinese` inertes que quedan.
- Endurecer `luacheck` poco a poco (activar variables sin usar, W211/W311) a medida que se limpian.

## Fase R6 — Pruebas automáticas

Pruebas con `busted` sobre las funciones puras, con la API de WoW simulada, y añadirlas a la CI:
resolvedor de `WoWTools_L`, `TextMixin:Magic`, `TextMixin:sub` (UTF-8), `MK`, `SetDefaults`,
`Organize_Main`, búsqueda de portales de Míticas+ y la nueva API de módulos.

---

## Lista de comprobación en el juego (tras cada paso)

- [ ] `/reload` sin errores en BugSack.
- [ ] El módulo aparece en su grupo del panel, con su descripción; activar/desactivar funciona (con `/reload` si lo pide).
- [ ] La ventana de Blizzard que mejora el módulo se abre y se ve como antes.
- [ ] Los ajustes que tenías siguen iguales.

## Estado

- [x] Antes de R1: quitar lo que sobra (docs/MEJORAS.md, sección 1)


- [x] R1 API común + Selector de color (pendiente de probar en el juego)
  - [x] Sistema de estilo `WoWTools_Style` (1_Mixin/Style.lua) aplicado al Selector de color
  - [x] API de módulos `WoWTools_Module:Register` + despachador único de eventos
  - [x] Escaneo de bolsas compartido (ver docs/MEJORAS.md, sección 4)
  - [x] Selector de color migrado a la API
- [ ] R2 migración de módulos (21/28; faltan Personaje, Míticas+, Herramientas, Botón de chat, Mover marcos, Texturas/Barras de acción, Otros)
- [ ] R3 esperas de Blizzard unificadas
- [ ] R4 funciones gigantes (0/7; `Init_TypeTabs_Data` se fue con la ventana de objetos)
- [ ] R5 orden y nombres
- [ ] R6 pruebas automáticas
