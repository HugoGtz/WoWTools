# Ajustes: Centro de control y esquema `options`

Los ajustes de WoWToolsPlus están en una sola página, **Opciones › AddOns › WoWToolsPlus**, el **Centro de control**.
Se abre también con `/wtp` (`/wtp texto` abre directamente la búsqueda) y desde el compartimento de addons del minimapa.

Código:

| Archivo | Qué hace |
|---|---|
| `1_Mixin/PanelMixin.lua` | Crea la categoría principal (lienzo) y las subpáginas de Blizzard (`AddSubCategory`). Las llamadas sin categoría ya no crean nada en Blizzard: se guardan para el Centro de control. |
| `1_Mixin/Options.lua` | `WoWTools_Options`: lógica del esquema sin marcos (textos, valores, `/reload` pendientes, búsqueda). |
| `1_Mixin/ControlCenter.lua` | `WoWTools_ControlCenter`: el dibujo (cabecera, barra lateral, tarjetas, páginas, búsqueda, barra de recarga), `/wtp` y el compartimento. |
| `1_Mixin/Style.lua` | Componentes: interruptor, deslizador, desplegable, muestra de color, campo, botón, desplazamiento, barra lateral y tarjeta (ver `STYLE.md`). |
| `0_Data/z_Panel.lua` | Página **General** (ajustes del addon, color de acento, datos y restablecimiento). |

## Cómo se ve

```
┌──────────────────────────────────────────────────────────────────────────┐
│ [logo] WoWToolsPlus  1.2.3                          [🔍 Buscar módulos…] │ cabecera 48 px
├──────────────┬───────────────────────────────────────────────────────────┤
│ General      │ Interfaz                                                  │
│ MÓDULOS      │ 8 módulos, 6 activados                                    │
│▌Interfaz   8 │ ┌───────────────────────────────────────────────────────┐ │
│ Chat y …   3 │ │[ic] Selector de color                          [■□]   │ │ tarjeta 76 px
│ Objetos…   5 │ │     Descripción corta del módulo en dos líneas…       │ │
│ Personaje  9 │ │                                         Ajustes ›     │ │
│ Mundo…     4 │ └───────────────────────────────────────────────────────┘ │
│ Herramient 3 │ …                                                         │
│ Automatiz.   │                                                           │
│              ├───────────────────────────────────────────────────────────┤
│ /wtp         │ ⟳ 2 cambios requieren /reload              [Recargar ahora] │ solo si hay cambios
└──────────────┴───────────────────────────────────────────────────────────┘
```

- **Barra lateral** (176 px): General, los grupos con su número de módulos y Automatizaciones (solo si algún módulo
  tiene opciones con `automation=true`). El elegido lleva relleno y barra de acento.
- **Tarjetas**: icono, nombre, descripción (el `tooltip` del módulo), interruptor y pie "Ajustes ›" (o "Detalles ›" si no
  tiene nada que ajustar). Desactivado = icono gris y textos atenuados. Una columna, o dos si el contenido mide 560 px o más.
  Clic en la tarjeta: página del módulo.
- **Página de módulo**: "‹ Volver" y la ruta `Grupo › (Padre ›) Módulo`; cabecera con icono, nombre, descripción,
  interruptor y aviso si activarlo requiere `/reload`; botones "Más ajustes" (su subpágina de Blizzard o `openSettings`) y
  el `button` del módulo; después las secciones de `options`, sus funciones sueltas y sus submódulos.
- **Fila de opción**: etiqueta a la izquierda (y `desc` atenuada debajo), control a la derecha, `tooltip` al pasar el ratón.
  Clic en la fila de un interruptor = clic en el interruptor. Atenuada (40 %) si `disabled`.
- **Búsqueda**: módulos (nombre, descripción, grupo) y opciones (texto, tooltip, desc, sección), sin distinguir tildes ni
  mayúsculas. Cada resultado lleva a su página; si es una opción, la página se desplaza hasta ella y la resalta.
- **Barra de recarga**: cuenta los cambios con `reload=true` (y los interruptores de módulos que piden `/reload`).
  Si vuelves un ajuste a su valor original, deja de contar.

## Declarar las opciones de un módulo

En el `def` de `WoWTools_Module:Register` (ver la cabecera de `1_Mixin/Module.lua`):

```lua
WoWTools_Module:Register({
    key= 'Plus_Color', name= 'Module.Color picker', icon= 'colorblind-colorwheel', group= 'Interface',
    tooltip= 'Tip.Color.Enable',
    options= {
        {type='section', text='GENERAL'},
        {type='check', text='Show in combat', tooltip='Tip.Color.ShowCombat',
            get= function(save) return save.showCombat end,
            set= function(save, value) save.showCombat= value or nil end,
            apply= function(M) M:Refresh() end},

        {type='section', text='Appearance'},
        {type='slider', text='SCALE', min=0.4, max=2, step=0.05, format='%.2f',
            get= function(save) return save.scale or 1 end,
            set= function(save, value) save.scale= value end,
            apply= function(M, save) M.frame:SetScale(save.scale) end,
            disabled= function(save) return not save.showCombat end},
        {type='dropdown', text='Anchor', reload=true,
            values= {{value='LEFT', text='Left'}, {value='RIGHT', text='Right'}},
            get= function(save) return save.anchor or 'LEFT' end,
            set= function(save, value) save.anchor= value end},
        {type='color', text='Accent color', hasAlpha=true,
            get= function(save) local c= save.color return c.r, c.g, c.b, c.a end,
            set= function(save, r, g, b, a) save.color= {r=r, g=g, b=b, a=a} end},

        {type='section', text='Advanced'},
        {type='input', text='Custom text', placeholder='Type here',
            get= function(save) return save.text end,
            set= function(save, text) save.text= text~='' and text or nil end},
        {type='button', text='Reset position', buttonText='RESET', confirm=true,
            func= function(M, save) save.point= nil M:SetPoint() end},
        {type='note', text='Tip.Color.Note'},
        {type='children'},
    },
})
```

`options` también puede ser `function(M, save) return {...} end` (se evalúa al abrir la página y al buscar: que sea rápida y sin
efectos secundarios).

### Campos comunes

| Campo | Tipo | Uso |
|---|---|---|
| `type` | texto | `section`, `check`, `slider`, `dropdown`, `color`, `input`, `button`, `note`, `children` (otros se ignoran) |
| `text` | clave de `WoWTools_L` o `function(save, M)` | Etiqueta. Si la clave no existe se muestra tal cual. **Siempre con su entrada en enUS y esES.** |
| `key` | texto | Id estable de la opción (`<página>:<key>`). Sin `key` se usa la posición. Ponlo si la opción tiene `reload=true`. |
| `tooltip` | clave o `function(save, M)` | Texto al pasar el ratón (puede ser largo). |
| `desc` | clave o `function(save, M)` | Descripción corta, siempre visible y atenuada debajo de la etiqueta. Úsala poco. |
| `get` | `function(save, M)` | Valor actual. `save` es `M:Save()` (respeta un `Save` sobrescrito, p. ej. por personaje). |
| `set` | `function(save, valor, M)` | Guarda el valor. Color: `function(save, r, g, b, a, M)`. |
| `apply` | `function(M, save, valor)` | Se llama después de cada cambio: refresca el módulo en vivo. |
| `reload` | booleano | El cambio necesita `/reload`: se marca en la fila y suma en la barra de recarga. |
| `disabled` | booleano o `function(save, M)` | Fila atenuada y control bloqueado (p. ej. depende de otra opción). Se recalcula tras cada cambio. |
| `hidden` | booleano o `function(save, M)` | No se dibuja. Si cambia tras un cambio, la página se vuelve a dibujar. Una `section` sin nada visible debajo no se dibuja. |
| `indent` | booleano | Sangría de 16 px (opción que depende de la anterior). |
| `noCombat` | booleano | Bloqueada en combate y su `apply` se aplaza hasta salir del combate (para tocar marcos protegidos). |
| `automation` | booleano | Además sale en la página **Automatizaciones** (todo lo que el addon hace solo: aceptar, vender, reparar…). |

### Tipos

| Tipo | Control (a la derecha) | Campos propios | `get` devuelve |
|---|---|---|---|
| `section` | Título en color de acento con línea de 1 px | `text` (recomendadas: `'GENERAL'`, `'Appearance'`, `'Advanced'`) | — |
| `check` | Interruptor 32×16 | — | booleano |
| `slider` | Deslizador de 176 px con el valor editable (acepta coma decimal) | `min`, `max`, `step`, `format` (`'%.2f'`, o `function(v) return texto end`; por defecto entero si `step>=1`) | número |
| `dropdown` | Botón con el valor y flecha; menú de Blizzard con opciones de radio | `values`: lista `{ {value=, text=clave}, ... }` o `function(save, M)` que la devuelve | el `value` elegido |
| `color` | Muestra 40×24 con `#RRGGBB`; abre el selector de color de Blizzard (Cancelar vuelve al color anterior) | `hasAlpha` | `r, g, b, a` |
| `input` | Campo de 176 px. Guarda con Intro o al perder el foco; Esc deshace | `placeholder`, `numeric` (convierte a número; si no lo es, deshace), `maxLetters`, `width` | texto (o número) |
| `button` | Botón de texto | `buttonText` (por defecto `text`), `func(M, save)`, `confirm` (`true` o clave: pide confirmación) | — |
| `note` | Texto atenuado a todo el ancho | `text`, `kind` (`'muted'`, `'warning'`) | — |
| `children` | Lista de submódulos (`def.parent`) con icono, descripción, interruptor y flecha a su página | — | — |

Si un módulo tiene submódulos y su esquema no lleva `{type='children'}`, la lista se añade al final igualmente.

## Interruptor del módulo

| `def` | Interruptor en la tarjeta |
|---|---|
| normal | Sí: `M:SetEnabled(v)` (guarda `save.disabled`, llama a `onToggle` y, con `reload=false`, arranca el módulo si no estaba). Por defecto pide `/reload`. |
| `panel=false` | Solo si el módulo creó su propia casilla: con `OnlyCheck` sin categoría en `onLoad` (con el nombre del módulo) o una casilla `WoWTools_L.ENABLE` en su subpágina. |
| `toggle=true` | Siempre (interruptor estándar), aunque tenga `panel=false`. |
| `toggle=false` | Nunca (el módulo no se puede desactivar). |
| `onToggle=function(M, enabled, save)` | Para aplicar el cambio en vivo; combínalo con `reload=false`. |
| `childToggle={get=function(M, child) end, set=function(M, child, v) end}` | En el padre: cómo se activan sus submódulos (p. ej. `disabledADD[nombre]` del padre). Sin él, cada submódulo usa su propio `SetEnabled`. |

## Lo que todavía no está en el esquema

Mientras un módulo no tenga `options`, su página muestra la descripción, el interruptor y **Más ajustes**, que abre su
subpágina de Blizzard (`AddSubCategory`, se enlaza sola por módulo o por nombre) o llama a `def.openSettings(M, save)`
(p. ej. para abrir su menú). Las subpáginas de Blizzard siguen funcionando y cuelgan de la categoría WoWToolsPlus.

Las llamadas a `WoWTools_PanelMixin:OnlyCheck`, `Check_Button`, `OnlyButton`, `OnlySlider`, `OnlyMenu`, `CheckMenu` y
`Check_Slider` **sin categoría** se guardan en `WoWTools_PanelMixin.Legacy` y el Centro de control las convierte:

- si la casilla lleva el nombre del módulo que se estaba cargando (`WoWTools_Module.Current`), es el interruptor de ese módulo;
- si no, es una **tarjeta propia** (función suelta, p. ej. "Estilo de barras de acción" o "Autocompletar palabras de
  confirmación"), colocada en el grupo que corresponde a su nombre (`CC.Groups[].mixins`/`extra`) o en el de su módulo,
  y además aparece en la sección **Funciones** de la página de su módulo;
- las que se crearon pasándoles una de ellas como `root` salen como opciones de su página.

Para migrar un módulo: escribe su `options`, quita sus llamadas a `WoWTools_PanelMixin` y su `AddSubCategory`, y comprueba
en el juego que la búsqueda encuentra sus opciones.

## API de `WoWTools_Options` (por si hace falta desde fuera)

| Función | Qué hace |
|---|---|
| `:Text(clave o función, ...)` | Texto visible (`WoWTools_L`). |
| `:Plain(texto)` / `:Fold(texto)` | Sin iconos ni colores / además en minúsculas y sin tildes. |
| `:Resolve(página)` | Lista validada de opciones de `{id=, M=, save=, options=}`. |
| `:GetValue(opt)` / `:SetValue(opt, ...)` / `:Run(opt)` | Leer, escribir (con `apply` y `/reload`) y pulsar un botón. |
| `:Track(id, antes, después, texto)` | Anota un cambio que requiere `/reload` (se borra si se vuelve al valor original). |
| `:GetPendingCount()` / `:IsPending(id)` / `:OnPendingChanged(func)` / `:Reload()` | Barra de recarga. |
| `:SetGeneral(lista, saveFunc)` | Página General (la usa `0_Data/z_Panel.lua`). |

`WoWTools_ControlCenter:Open(destino)` abre el Centro de control (destino: clave de módulo, nombre, `'general'` o texto a
buscar); `:Toggle()`, `:IsShown()`. `WoWTools_PanelMixin:Open()` sin categoría (lo usan los menús de "Opciones") también
abre el Centro de control, en la página del módulo si se le pasa su nombre. En combate no se puede abrir el panel de
opciones: avisa y se abre al terminar el combate.
