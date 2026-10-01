# Estilo común: `WoWTools_Style`

Estilo "minimalista oscuro" para todo lo que dibuja el addon (reglas en `MEJORAS.md`, sección 5).
Código: `1_Mixin/Style.lua` (se carga después de los demás `1_Mixin`). Módulo de referencia ya migrado:
**Selector de color** (`Plus/Color/*`).

## Tokens

Cámbialos solo en `Style.lua`; los módulos los leen, nunca copian los números.

| Token | Valor | Uso |
|---|---|---|
| `Style.Color.bg` | negro 70 % | fondo de panel |
| `Style.Color.header` | negro 85 % | cabecera |
| `Style.Color.border` | blanco 10 % | borde de 1 px |
| `Style.Color.button` | blanco 5 % | relleno de botón plano |
| `Style.Color.text` / `muted` / `disabled` | blanco / gris 70 % / gris 50 % | texto |
| `Style.Color.accent` | color de la clase (o el elegido con `SetAccent`) | hover, activo, títulos |
| `Style.Alpha.hover` / `selected` / `active` / `disabled` | 0.15 / 0.25 / 0.60 / 0.40 | estados |
| `Style.Size.grid` / `pad` / `gap` | 4 / 4 / 2 | rejilla, margen interior, hueco entre iconos |
| `Style.Size.row` / `header` | 20 / 20 | alto de fila y de cabecera |
| `Style.Size.icon.small` / `normal` / `large` | 16 / 20 / 32 | iconos |
| `Style.Size.crop` | 0.08 | recorte de iconos |
| `Style.Font.small` / `normal` / `medium` / `large` | `GameFontHighlightSmall` / `GameFontHighlight` / `...Medium` / `...Large` | fuentes |

Los colores son tablas `{r, g, b, a}`. `Style:Space(n)` devuelve `n * 4`.

## Funciones

Todas son idempotentes (se pueden llamar otra vez para cambiar opciones sin duplicar texturas) y devuelven el objeto.
Si el marco está protegido y estás en combate, la llamada se aplaza hasta `PLAYER_REGEN_ENABLED`.

| Función | Qué hace |
|---|---|
| `Style:Panel(frame, opts)` | Fondo plano (`WHITE8x8`) y borde de 1 px nítido con cualquier escala. `opts`: `alpha`, `color`, `header=true` (85 %), `border=false`, `hideArt=true` (oculta `Left/Middle/Right` de plantillas). |
| `Style:Header(frame, title, opts)` | Franja de 20 px arriba, separador de 1 px y título en color de acento. Devuelve el FontString. El contenido empieza en `y = -Style.Size.header`. `opts`: `height`, `size`, `kind`, `justifyH`. |
| `Style:Row(button, opts)` | Fila: acento al 15 % con el ratón encima, 25 % si está activa. `opts.height=true` la deja en 20 px. |
| `Style:Icon(texture, size, opts)` | Recorte del 8 % y máscara redondeada (`UI-HUD-CoolDownManager-Mask`, la de las barras de acción). `size`: número o `'small'`/`'normal'`/`'large'`. `opts.mask=false` sin máscara. Llámala después de `SetTexture`/`SetAtlas`; con atlas no recorta. |
| `Style:Button(button, opts)` | Botón plano: quita el arte de Blizzard, relleno al 5 %, borde, acento al pasar el ratón y 40 % de opacidad desactivado. `opts.icon=true`: solo icono (sin fondo ni borde, conserva la NormalTexture). |
| `Style:Input(editBox, opts)` | Campo plano; borde de acento mientras tiene el foco. |
| `Style:Text(fontString, size, kind)` | Objeto de fuente de Blizzard + sombra de 1 px. `size`: `'small'`/`'normal'`/`'medium'`/`'large'` o 10/12/14/16. `kind`: `'text'`/`'muted'`/`'disabled'`/`'accent'`. |
| `Style:SetActive(frame, bool)` | Estado activo/seleccionado: borde de acento al 60 % (y relleno en filas). |
| `Style:Outline(region)` | Contorno de acento compartido alrededor de cualquier región, también texturas sueltas. `Style:Outline(nil)` lo oculta. |
| `Style:SetAccent(r, g, b)` / `:GetAccent()` | Cambia el acento (se guarda en `WoWToolsPlusSave.Style`) y repinta lo que lo usa. `SetAccent()` sin valores vuelve al color de la clase. |

## Ejemplos

```lua
local Style= WoWTools_Style

--Panel con cabecera y filas
local panel= CreateFrame('Frame', nil, parent)
panel:SetSize(200, Style.Size.header + Style:Space(1) + 5*Style.Size.row)
Style:Panel(panel)
Style:Header(panel, WoWTools_L['Mi.Titulo'])

for i= 1, 5 do
    local row= CreateFrame('Button', nil, panel)
    row:SetPoint('TOPLEFT', 0, -(Style.Size.header + Style:Space(1) + (i-1)*Style.Size.row))
    row:SetPoint('RIGHT')
    Style:Row(row, {height=true})

    row.icon= row:CreateTexture(nil, 'ARTWORK')
    row.icon:SetPoint('LEFT', Style:Space(1), 0)
    row.icon:SetTexture(134400)
    Style:Icon(row.icon, 'small')

    row.text= row:CreateFontString(nil, 'OVERLAY')
    row.text:SetPoint('LEFT', row.icon, 'RIGHT', Style:Space(1), 0)
    Style:Text(row.text, 'normal', 'text')
end

--Botón de solo icono
local btn= WoWTools_ButtonMixin:Cbtn(panel, {atlas='common-icon-zoomin', size=Style.Size.icon.normal})
btn:SetScript('OnEnter', ...)    --primero los SetScript
Style:Button(btn, {icon=true})   --después el estilo (usa HookScript)
```

Rejilla de muestras como en el Selector de color: celdas de 16/20 px con `Style.Size.gap` entre ellas,
margen `Style.Size.pad` y el contenido debajo de la cabecera (`Plus/Color/Select_Color.lua`, `Set_Cell`/`Set_PanelSize`).

## Cómo migrar un módulo

1. Crea los contenedores como marcos propios (hijos de tu marco, nunca de una ventana de Blizzard) y llama a `Style:Panel` / `Style:Header`.
2. Cambia los tamaños fijos por los tokens (`Style.Size.*`) y los colores por `Style.Color.*`.
3. Iconos: `Style:Icon`. Botones: `Style:Button`. Textos nuevos: `Style:Text` en vez de `WoWTools_LabelMixin:Create(..., {size=12})`.
4. Textos visibles nuevos en `0_Data/0_Locale.lua` (enUS y esES).
5. Comprueba que el comportamiento no cambia: mismos clics, tooltips y menús.

## Qué NO hacer

- No aplicar el estilo a ventanas ni botones de Blizzard (`ColorPickerFrame`, `CharacterFrame`...): solo a marcos que crea el addon.
- No llamar a `Style:Button` / `Style:Row` / `Style:Input` **antes** de `SetScript('OnEnter'|'OnLeave'|'OnEditFocusGained'...)`: `SetScript` borra los `HookScript` del estilo.
- No usar `THICKOUTLINE` ni `SetFont` con tamaño fijo: usa `Style:Text` (fuentes de Blizzard, respetan la escala y el idioma).
- No usar texturas de marco de Blizzard (`DialogBorderTemplate`, botones rojos `UIPanelButtonTemplate`) en ventanas nuevas.
- No copiar números (0.7, 20, 4...) en los módulos: lee los tokens.
- No crear bordes con `SetBackdrop` y `edgeSize` fijo: se emborronan con escalas no enteras (el estilo usa `PixelUtil`).
- No poner `Style:Icon` con recorte sobre atlas ya ajustados (lo detecta solo si llamas después de `SetAtlas`).
- `Style:Button` con `opts.icon` quita las texturas de resaltado y pulsado del botón; si las necesitas, pasa `keepHighlight=true`.
