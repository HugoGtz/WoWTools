--Estilo común "minimalista oscuro" del addon (docs/STYLE.md).
--Solo para marcos PROPIOS del addon: nunca se aplica a ventanas de Blizzard.
--Todas las funciones son idempotentes (llamarlas dos veces no duplica texturas)
--y, si el marco está protegido y estamos en combate, se aplazan hasta salir del combate.

WoWTools_Style= {}
local Style= WoWTools_Style

local WHITE= 'Interface\\Buttons\\WHITE8x8'
local MASK_ATLAS= 'UI-HUD-CoolDownManager-Mask'--la misma máscara que las barras de acción




--------------------------------------------------------------------------------
--Tokens
--------------------------------------------------------------------------------

--Colores {r, g, b, a}
Style.Color= {
    bg=       {0, 0, 0, 0.70},--fondo de panel
    header=   {0, 0, 0, 0.85},--cabecera
    border=   {1, 1, 1, 0.10},--borde de 1 px
    button=   {1, 1, 1, 0.05},--relleno de botón plano en reposo
    text=     {1, 1, 1, 1},   --texto normal
    muted=    {0.70, 0.70, 0.70, 1},--texto atenuado (secundario)
    disabled= {0.50, 0.50, 0.50, 1},--texto desactivado
    accent=   {0, 0.80, 1, 1},--se sustituye por el color de la clase al cargar
    inset=    {0, 0, 0, 0.30},--zona hundida (barra lateral del Centro de control)
    track=    {1, 1, 1, 0.15},--carril de interruptores, deslizadores y barras de desplazamiento
    warning=  {1, 0.82, 0, 1},--avisos (requiere /reload)
}

--Opacidades de estado
Style.Alpha= {
    hover=    0.15,--relleno de fila/botón al pasar el ratón (acento)
    selected= 0.25,--relleno de fila activa (acento)
    active=   0.60,--borde al pasar el ratón o activo (acento)
    disabled= 0.40,--marco desactivado
}

--Tamaños (rejilla de 4 px)
Style.Size= {
    grid=   4, --unidad base
    pad=    4, --margen interior de los paneles
    gap=    2, --separación mínima entre celdas (media unidad, solo para rejillas de iconos)
    row=    20,--alto de fila
    header= 20,--alto de cabecera
    border= 1, --grosor del borde (en píxeles físicos)
    crop=   0.08,--recorte de los iconos
    icon= {small=16, normal=20, large=32},
    control= 24,--alto de los controles (botón de texto, desplegable, campo, deslizador)
    option=  32,--alto mínimo de una fila de opción
    card=    76,--alto de una tarjeta de módulo
    nav=     28,--alto de un elemento de la barra lateral
    sidebar= 176,--ancho de la barra lateral
    switch= {w=32, h=16, knob=12},
    slider= {track=4, thumb=12, value=44},
    scrollbar= 4,--ancho visible de la barra de desplazamiento
}

--Objetos de fuente de Blizzard (respetan la escala y el idioma; sin THICKOUTLINE)
Style.Font= {
    small=  'GameFontHighlightSmall', --10
    normal= 'GameFontHighlight',      --12
    medium= 'GameFontHighlightMedium',--14
    large=  'GameFontHighlightLarge', --16
}




--------------------------------------------------------------------------------
--Utilidades internas
--------------------------------------------------------------------------------

local Bordered= setmetatable({}, {__mode='k'})--marcos con borde: se recalcula el píxel al cambiar la escala
local Accented= setmetatable({}, {__mode='k'})--objetos que usan el color de acento: se repintan en SetAccent
local Queue= {}--llamadas aplazadas por el combate

local EventFrame= CreateFrame('Frame')


local function Unpack(c, alpha)
    return c[1], c[2], c[3], alpha or c[4] or 1
end

local function AccentRGBA(alpha)
    local c= Style.Color.accent
    return c[1], c[2], c[3], alpha or 1
end


--Estado guardado en el propio objeto (una sola tabla por objeto)
local function State(obj)
    local st= obj.WoWToolsStyle
    if not st then
        st= {}
        obj.WoWToolsStyle= st
    end
    return st
end


local function CanStyle(obj)
    if not obj or type(obj)~='table' or not obj.GetObjectType then
        return false
    end
    if obj.IsForbidden and obj:IsForbidden() then
        return false
    end
    return true
end


--Si el marco está protegido y estamos en combate, se guarda la llamada para después
local function Defer(func, ...)
    local obj= ...
    if InCombatLockdown() and obj and obj.IsProtected and obj:IsProtected() then
        table.insert(Queue, {func= func, n= select('#', ...), ...})
        EventFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
        return true
    end
end


--Tamaño en unidades de la interfaz que equivale a N píxeles físicos (borde nítido con cualquier escala)
local function PixelSize(region, n)
    n= n or 1
    if PixelUtil and PixelUtil.GetNearestPixelSize and region.GetEffectiveScale then
        return PixelUtil.GetNearestPixelSize(n, region:GetEffectiveScale(), n)
    end
    return n
end


local function NewTexture(frame, layer, sublevel)
    local t= frame:CreateTexture(nil, layer, nil, sublevel)
    t:SetTexture(WHITE)
    return t
end


--Coloca los 4 lados del borde (izquierda/derecha sin solaparse con arriba/abajo)
local function Layout_Border(frame)
    local st= frame.WoWToolsStyle
    if not st then
        return
    end
    local px= PixelSize(frame, Style.Size.border)
    if st.headerLine then
        st.headerLine:SetHeight(px)
    end
    local e= st.edges
    if not e then
        return
    end

    e.top:ClearAllPoints()
    e.top:SetPoint('TOPLEFT')
    e.top:SetPoint('TOPRIGHT')
    e.top:SetHeight(px)

    e.bottom:ClearAllPoints()
    e.bottom:SetPoint('BOTTOMLEFT')
    e.bottom:SetPoint('BOTTOMRIGHT')
    e.bottom:SetHeight(px)

    e.left:ClearAllPoints()
    e.left:SetPoint('TOPLEFT', 0, -px)
    e.left:SetPoint('BOTTOMLEFT', 0, px)
    e.left:SetWidth(px)

    e.right:ClearAllPoints()
    e.right:SetPoint('TOPRIGHT', 0, -px)
    e.right:SetPoint('BOTTOMRIGHT', 0, px)
    e.right:SetWidth(px)
end


local function Set_BorderColor(frame, r, g, b, a)
    local e= frame.WoWToolsStyle and frame.WoWToolsStyle.edges
    if e then
        for _, t in pairs(e) do
            t:SetVertexColor(r, g, b, a)
        end
    end
end


local function Create_Border(frame)
    local st= State(frame)
    if not st.edges then
        st.edges= {
            top=    NewTexture(frame, 'BORDER', -8),
            bottom= NewTexture(frame, 'BORDER', -8),
            left=   NewTexture(frame, 'BORDER', -8),
            right=  NewTexture(frame, 'BORDER', -8),
        }
        Bordered[frame]= true
        frame:HookScript('OnShow', Layout_Border)--la escala efectiva puede haber cambiado
    end
    for _, t in pairs(st.edges) do
        t:Show()
    end
    Layout_Border(frame)
end


--Color del borde según el estado: activo o con el ratón encima = acento
local function Refresh_State(frame)
    local st= frame.WoWToolsStyle
    if not st then
        return
    end
    local lit= st.active or st.hover

    if st.edges and st.border~=false then
        if lit then
            Set_BorderColor(frame, AccentRGBA(Style.Alpha.active))
        else
            Set_BorderColor(frame, Unpack(Style.Color.border))
        end
    end

    if st.fill then
        if st.hover and not st.active then
            st.fill:SetVertexColor(AccentRGBA(Style.Alpha.hover))
            st.fill:Show()
        elseif st.active then
            st.fill:SetVertexColor(AccentRGBA(st.hover and Style.Alpha.selected+Style.Alpha.hover or Style.Alpha.selected))
            st.fill:Show()
        else
            st.fill:Hide()
        end
    end
end


local function On_Enter(frame)
    local st= frame.WoWToolsStyle
    if st and not (frame.IsEnabled and not frame:IsEnabled()) then
        st.hover= true
        Refresh_State(frame)
    end
end

local function On_Leave(frame)
    local st= frame.WoWToolsStyle
    if st then
        st.hover= nil
        Refresh_State(frame)
    end
end


--Relleno de acento para hover/activo + scripts de ratón (una sola vez)
local function Add_Hover(frame)
    local st= State(frame)
    if not st.fill then
        st.fill= NewTexture(frame, 'BACKGROUND', -7)
        st.fill:SetAllPoints(frame)
        st.fill:Hide()
        frame:HookScript('OnEnter', On_Enter)
        frame:HookScript('OnLeave', On_Leave)
        Accented[frame]= Refresh_State
    end
end


--Quita el arte de las plantillas de Blizzard (UIPanelButtonTemplate, SearchBoxTemplate...) del marco propio
local function Hide_TemplateArt(frame)
    for _, key in pairs({'Left', 'Middle', 'Right', 'Mid', 'LeftDisabled', 'MiddleDisabled', 'RightDisabled'}) do
        local t= frame[key]
        if t and t.Hide and t.IsObjectType and t:IsObjectType('Texture') then
            t:SetAlpha(0)
            t:Hide()
        end
    end
end




--------------------------------------------------------------------------------
--API
--------------------------------------------------------------------------------

--Fondo plano negro al 70 % (opts.header: 85 %) y borde de 1 px blanco al 10 %
--opts: {alpha=0.7, color={r,g,b,a}, header=true, border=false, hideArt=true}
function Style:Panel(frame, opts)
    if not CanStyle(frame) or Defer(Style.Panel, frame, opts) then
        return frame
    end
    opts= opts or {}
    local st= State(frame)

    if not st.bg then
        st.bg= NewTexture(frame, 'BACKGROUND', -8)
        st.bg:SetAllPoints(frame)
    end
    local c= opts.color or (opts.header and Style.Color.header) or Style.Color.bg
    st.bg:SetVertexColor(Unpack(c, opts.alpha))
    st.bg:Show()

    st.border= opts.border
    if opts.border~=false then
        Create_Border(frame)
    elseif st.edges then
        for _, t in pairs(st.edges) do
            t:Hide()
        end
    end

    if opts.hideArt then
        Hide_TemplateArt(frame)
    end

    Refresh_State(frame)
    return frame
end


--Cabecera: franja al 85 %, separador de 1 px y título en color de acento
--opts: {height=20, size='normal', kind='accent', justifyH='LEFT'}
--Devuelve el FontString del título. El contenido debe empezar en y = -Style.Size.header.
function Style:Header(frame, title, opts)
    if not CanStyle(frame) or Defer(Style.Header, frame, title, opts) then
        return frame and frame.WoWToolsStyle and frame.WoWToolsStyle.headerText
    end
    opts= opts or {}
    local st= State(frame)
    local h= opts.height or Style.Size.header

    if not st.headerBg then
        st.headerBg= NewTexture(frame, 'BACKGROUND', -6)
        st.headerLine= NewTexture(frame, 'BORDER', -7)
        st.headerText= frame:CreateFontString(nil, 'OVERLAY')
    end

    st.headerBg:ClearAllPoints()
    st.headerBg:SetPoint('TOPLEFT')
    st.headerBg:SetPoint('TOPRIGHT')
    st.headerBg:SetHeight(h)
    st.headerBg:SetVertexColor(Unpack(Style.Color.header))

    st.headerLine:ClearAllPoints()
    st.headerLine:SetPoint('TOPLEFT', st.headerBg, 'BOTTOMLEFT')
    st.headerLine:SetPoint('TOPRIGHT', st.headerBg, 'BOTTOMRIGHT')
    st.headerLine:SetHeight(PixelSize(frame, Style.Size.border))
    st.headerLine:SetVertexColor(Unpack(Style.Color.border))

    local text= st.headerText
    self:Text(text, opts.size or 'normal', opts.kind or 'accent')
    text:ClearAllPoints()
    text:SetPoint('LEFT', st.headerBg, 'LEFT', Style.Size.pad*2, 0)
    text:SetPoint('RIGHT', st.headerBg, 'RIGHT', -Style.Size.pad*2, 0)
    text:SetJustifyH(opts.justifyH or 'LEFT')
    text:SetWordWrap(false)
    text:SetText(title or '')

    Bordered[frame]= true
    return text
end


--Fila: relleno de acento al 15 % al pasar el ratón (25 % si está activa, ver SetActive)
--opts: {height=true|número (true = 20 px), border=false}
function Style:Row(button, opts)
    if not CanStyle(button) or Defer(Style.Row, button, opts) then
        return button
    end
    opts= opts or {}
    local st= State(button)
    st.border= false--las filas no llevan borde propio
    Add_Hover(button)

    if opts.height then
        button:SetHeight(opts.height==true and Style.Size.row or opts.height)
    end

    local fs= button.GetFontString and button:GetFontString()
    if fs and not st.textDone then
        self:Text(fs, 'normal', 'text')
        st.textDone= true
    end

    Refresh_State(button)
    return button
end


--Icono: recorte del 8 % y máscara redondeada (como las barras de acción)
--size: número, o 'small' (16) / 'normal' (20) / 'large' (32); nil = no cambia el tamaño
--opts: {mask=false (sin máscara), crop=0.08}
--Llamar DESPUÉS de SetTexture/SetAtlas. Con atlas no se recorta (ya viene ajustado).
function Style:Icon(texture, size, opts)
    if not CanStyle(texture) or not texture.SetTexCoord then
        return texture
    end
    opts= opts or {}

    if size then
        local s= type(size)=='number' and size or Style.Size.icon[size] or Style.Size.icon.normal
        texture:SetSize(s, s)
    end

    local isAtlas= texture.GetAtlas and texture:GetAtlas()
    if not isAtlas then
        local c= opts.crop or Style.Size.crop
        texture:SetTexCoord(c, 1-c, c, 1-c)
    end

    if opts.mask~=false then
        local owner= texture:GetParent()
        if not texture.WoWToolsStyleMask and owner and owner.CreateMaskTexture then
            local mask= owner:CreateMaskTexture()
            mask:SetAtlas(MASK_ATLAS)
            mask:SetPoint('TOPLEFT', texture, 0.5, -0.5)
            mask:SetPoint('BOTTOMRIGHT', texture, -0.5, 0.5)
            texture:AddMaskTexture(mask)
            texture.WoWToolsStyleMask= mask
        end
    end
    return texture
end


--Botón plano: sin arte de Blizzard, relleno blanco al 5 %, borde de 1 px,
--acento al pasar el ratón y 40 % de opacidad desactivado.
--opts: {icon=true (solo icono: sin fondo ni borde, mantiene la NormalTexture), keepHighlight=true}
function Style:Button(button, opts)
    if not CanStyle(button) or Defer(Style.Button, button, opts) then
        return button
    end
    opts= opts or {}
    local st= State(button)

    if not opts.keepHighlight then
        if button.ClearHighlightTexture then
            button:ClearHighlightTexture()
        end
        if button.ClearPushedTexture then
            button:ClearPushedTexture()
        end
    end

    if opts.icon then
        st.border= false
    else
        Hide_TemplateArt(button)
        if button.ClearNormalTexture and not button.Icon then
            button:ClearNormalTexture()
        end
        if button.ClearDisabledTexture then
            button:ClearDisabledTexture()
        end
        self:Panel(button, {color= Style.Color.button})
        st.border= nil
    end

    Add_Hover(button)

    local fs= button.GetFontString and button:GetFontString()
    if fs and not st.textDone then
        self:Text(fs, 'normal', 'text')
        st.textDone= true
    end

    if not st.buttonHooks and button.IsEnabled then
        st.buttonHooks= true
        button:HookScript('OnDisable', function(b)
            b:SetAlpha(Style.Alpha.disabled)
            On_Leave(b)
        end)
        button:HookScript('OnEnable', function(b)
            b:SetAlpha(1)
        end)
        if not button:IsEnabled() then
            button:SetAlpha(Style.Alpha.disabled)
        end
    end

    Refresh_State(button)
    return button
end


--Botón de icono de las barras (chat, Herramientas): icono cuadrado redondeado como las barras de acción,
--borde de 1 px y tinte de acento al pasar el ratón o pulsado. No usa scripts (solo texturas de estado),
--así que el módulo puede hacer SetScript('OnEnter') antes o después.
--Espera btn.texture (icono) y, si existe, btn.IconMask. El aro btn.border solo se ve si el módulo
--lo pone en 'bag-border' para marcar un estado (p. ej. Monturas).
local function Crop(texture)
    if not (texture.GetAtlas and texture:GetAtlas()) then
        local c= Style.Size.crop
        texture:SetTexCoord(c, 1-c, c, 1-c)
    end
end

local function Set_ButtonTint(btn)
    local st= btn.WoWToolsStyle
    st.highlight:SetVertexColor(AccentRGBA(Style.Alpha.hover))
    st.pushed:SetVertexColor(AccentRGBA(Style.Alpha.selected))
end

function Style:IconButton(btn)
    if not CanStyle(btn) or not btn.texture or Defer(Style.IconButton, btn) then
        return btn
    end
    local st= State(btn)
    local px= PixelSize(btn, Style.Size.border)

    btn.texture:ClearAllPoints()
    btn.texture:SetPoint('TOPLEFT', px, -px)
    btn.texture:SetPoint('BOTTOMRIGHT', -px, px)

    if not st.iconDone then
        st.iconDone= true

        btn.IconMask= btn.IconMask or btn:CreateMaskTexture()
        btn.IconMask:SetAtlas(MASK_ATLAS)
        btn.texture:RemoveMaskTexture(btn.IconMask)
        btn.texture:AddMaskTexture(btn.IconMask)

        Crop(btn.texture)
        hooksecurefunc(btn.texture, 'SetTexture', Crop)

        if btn.border then
            btn.border:SetShown(btn.border:GetAtlas()=='bag-border')
            hooksecurefunc(btn.border, 'SetAtlas', function(t, atlas)
                t:SetShown(atlas=='bag-border')
            end)
        end

        btn:SetHighlightTexture(WHITE, 'ADD')
        btn:SetPushedTexture(WHITE)
        st.highlight= btn:GetHighlightTexture()
        st.pushed= btn:GetPushedTexture()
        st.pushed:SetBlendMode('ADD')
        Accented[btn]= Set_ButtonTint
        Create_Border(btn)
        Set_BorderColor(btn, Unpack(Style.Color.border))
    end

    btn.IconMask:ClearAllPoints()
    btn.IconMask:SetAllPoints(btn.texture)
    for _, t in pairs({st.highlight, st.pushed}) do--al botón y no al icono: hay módulos que encogen el icono
        t:ClearAllPoints()
        t:SetPoint('TOPLEFT', px, -px)
        t:SetPoint('BOTTOMRIGHT', -px, px)
    end
    Set_ButtonTint(btn)
    return btn
end


--Campo de texto: panel plano y borde de acento mientras tiene el foco
--opts: igual que Panel (alpha...)
function Style:Input(editBox, opts)
    if not CanStyle(editBox) or Defer(Style.Input, editBox, opts) then
        return editBox
    end
    opts= opts or {}
    opts.hideArt= true
    self:Panel(editBox, opts)

    local st= State(editBox)
    if not st.inputHooks then
        st.inputHooks= true
        editBox:HookScript('OnEditFocusGained', function(e) Style:SetActive(e, true) end)
        editBox:HookScript('OnEditFocusLost', function(e) Style:SetActive(e, false) end)
        Accented[editBox]= Refresh_State
    end
    return editBox
end


--Texto con objeto de fuente de Blizzard y sombra de 1 px
--size: 'small' | 'normal' | 'medium' | 'large' o un número (10/12/14/16)
--kind: 'text' (normal) | 'muted' | 'disabled' | 'accent'
function Style:Text(fontString, size, kind)
    if not CanStyle(fontString) or not fontString.SetFontObject then
        return fontString
    end
    if type(size)=='number' then
        size= (size<=10 and 'small') or (size<=12 and 'normal') or (size<=14 and 'medium') or 'large'
    end
    local font= _G[Style.Font[size or 'normal'] or Style.Font.normal]
    if font then
        fontString:SetFontObject(font)
    end
    fontString:SetShadowOffset(1, -1)
    fontString:SetShadowColor(0, 0, 0, 1)

    kind= kind or 'text'
    if kind=='accent' then
        fontString:SetTextColor(AccentRGBA(1))
        Accented[fontString]= function(fs) fs:SetTextColor(AccentRGBA(1)) end
    else
        fontString:SetTextColor(Unpack(Style.Color[kind] or Style.Color.text))
        Accented[fontString]= nil
    end
    return fontString
end


--Estado activo (seleccionado / con foco): borde de acento al 60 % y, en filas, relleno al 25 %
function Style:SetActive(frame, active)
    if not CanStyle(frame) or not frame.WoWToolsStyle then
        return
    end
    frame.WoWToolsStyle.active= active and true or nil
    Accented[frame]= Refresh_State
    Refresh_State(frame)
end


--Contorno de acento de 1 px alrededor de cualquier región (también texturas sueltas).
--Es un único marco compartido: Style:Outline(region) lo muestra, Style:Outline(nil) lo oculta.
local OutlineFrame
function Style:Outline(region)
    if not region then
        if OutlineFrame then
            OutlineFrame:Hide()
        end
        return
    end
    if not CanStyle(region) then
        return
    end
    local parent= region:IsObjectType('Texture') and region:GetParent() or region
    if not parent or (parent.IsProtected and parent:IsProtected() and InCombatLockdown()) then
        return
    end

    if not OutlineFrame then
        OutlineFrame= CreateFrame('Frame')
        OutlineFrame:EnableMouse(false)
        Create_Border(OutlineFrame)
        OutlineFrame:SetScript('OnHide', function(self)
            self:Hide()
        end)
    end
    OutlineFrame:SetParent(parent)
    OutlineFrame:SetFrameLevel(math.min(parent:GetFrameLevel()+10, 10000))
    local px= PixelSize(parent, 1)
    OutlineFrame:ClearAllPoints()
    OutlineFrame:SetPoint('TOPLEFT', region, -px, px)
    OutlineFrame:SetPoint('BOTTOMRIGHT', region, px, -px)
    Layout_Border(OutlineFrame)
    Set_BorderColor(OutlineFrame, AccentRGBA(Style.Alpha.active))
    OutlineFrame:Show()
end


--Múltiplos de la rejilla de 4 px: Style:Space(2) = 8
function Style:Space(n)
    return (n or 1)*Style.Size.grid
end


--Color de acento. SetAccent() sin valores vuelve al color de la clase.
function Style:SetAccent(r, g, b, notSave)
    local custom= r and g and b
    if not custom then
        r, g, b= self:GetClassAccent()
    end
    local c= Style.Color.accent
    c[1], c[2], c[3]= r, g, b

    if not notSave and type(WoWToolsPlusSave)=='table' then
        WoWToolsPlusSave['Style']= WoWToolsPlusSave['Style'] or {}
        WoWToolsPlusSave['Style'].accent= custom and {r, g, b} or nil
    end

    for obj, func in pairs(Accented) do
        func(obj)
    end
end


function Style:GetAccent()
    local c= Style.Color.accent
    return c[1], c[2], c[3]
end


function Style:GetClassAccent()
    local _, classFile= UnitClass('player')
    local color= classFile and (
        (C_ClassColor and C_ClassColor.GetClassColor(classFile))
        or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile])
    )
    if color then
        return color.r, color.g, color.b
    end
    return 0, 0.8, 1
end




--------------------------------------------------------------------------------
--Componentes (constructores): interruptor, deslizador, desplegable, muestra de color,
--campo de texto, botón de texto, desplazamiento, elemento de barra lateral y tarjeta.
--Son marcos propios (no protegidos). Avisan de lo que hace el jugador con un campo de
--función (onChange / onCommit); los Set* hechos por código no lo llaman.
--------------------------------------------------------------------------------

--Línea de 1 px (separador) con el color del borde. vertical=true: línea vertical.
function Style:Line(frame, vertical, layer)
    local t= NewTexture(frame, layer or 'BORDER')
    t:SetVertexColor(Unpack(Style.Color.border))
    if vertical then
        t:SetWidth(PixelSize(frame, 1))
    else
        t:SetHeight(PixelSize(frame, 1))
    end
    return t
end


--Pinta una textura con el color de acento (alpha opcional) y la repinta en SetAccent
function Style:Accent(texture, alpha)
    if not CanStyle(texture) then
        return texture
    end
    local function Paint(t)
        t:SetVertexColor(AccentRGBA(alpha or 1))
    end
    Accented[texture]= Paint
    Paint(texture)
    return texture
end


--Atlas (si existe) o textura; si el atlas no existe se usa fallback. Llamar a Style:Icon después para recortar.
function Style:SetIcon(texture, icon, fallback)
    if not CanStyle(texture) then
        return
    end
    if type(icon)=='string' and not icon:find('[\\/]') then
        if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(icon) then
            texture:SetAtlas(icon)
            return true
        end
        icon= nil
    end
    texture:SetTexture(icon or fallback or 134400)--134400: signo de interrogación
    texture:SetTexCoord(0, 1, 0, 1)--quita las coordenadas de un atlas anterior (marcos reciclados)
    return icon~=nil
end


--Tooltip con título y descripción (textos o funciones que los devuelven). Usa HookScript.
local function Tooltip_OnEnter(frame)
    local title, text= frame.tooltipTitle, frame.tooltipText
    if type(title)=='function' then
        title= title(frame)
    end
    if type(text)=='function' then
        text= text(frame)
    end
    if (not title or title=='') and (not text or text=='') then
        return
    end
    GameTooltip:SetOwner(frame, frame.tooltipAnchor or 'ANCHOR_RIGHT')
    GameTooltip:ClearLines()
    if title and title~='' then
        GameTooltip_SetTitle(GameTooltip, title)
    end
    if text and text~='' then
        GameTooltip_AddNormalLine(GameTooltip, text, true)
    end
    GameTooltip:Show()
end

local function Tooltip_OnLeave(frame)
    if GameTooltip:IsOwned(frame) then
        GameTooltip:Hide()
    end
end

function Style:SetTooltip(frame, title, text, anchor)
    if not CanStyle(frame) then
        return frame
    end
    frame.tooltipTitle, frame.tooltipText, frame.tooltipAnchor= title, text, anchor
    local st= State(frame)
    if not st.tooltipHooks then
        st.tooltipHooks= true
        frame:HookScript('OnEnter', Tooltip_OnEnter)
        frame:HookScript('OnLeave', Tooltip_OnLeave)
    end
    return frame
end


local function Disable_Alpha(frame)
    if not frame.WoWToolsStyle.alphaHooks then
        frame.WoWToolsStyle.alphaHooks= true
        frame:HookScript('OnDisable', function(self)
            self:SetAlpha(Style.Alpha.disabled)
            On_Leave(self)
        end)
        frame:HookScript('OnEnable', function(self)
            self:SetAlpha(1)
        end)
    end
end

local function Play(on)
    if SOUNDKIT and PlaySound then
        PlaySound(on and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    end
end




--Interruptor 32x16: carril blanco al 15 % (apagado) o acento al 60 % (encendido) y botón de 12 px.
--Área de clic ampliada 4 px por lado. b.onChange(b, valor). b:SetChecked(v) / b:GetChecked().
local function Paint_Switch(b)
    local st= b.WoWToolsStyle
    local S= Style.Size.switch
    local inset= (S.h-S.knob)/2
    b.Knob:ClearAllPoints()
    if b.checked then
        st.track:SetVertexColor(AccentRGBA(Style.Alpha.active))
        b.Knob:SetVertexColor(Unpack(Style.Color.text))
        b.Knob:SetPoint('RIGHT', -inset, 0)
    else
        st.track:SetVertexColor(Unpack(Style.Color.track))
        b.Knob:SetVertexColor(Unpack(Style.Color.muted))
        b.Knob:SetPoint('LEFT', inset, 0)
    end
    Refresh_State(b)
end

function Style:CreateSwitch(parent)
    local S= Style.Size.switch
    local b= CreateFrame('Button', nil, parent)
    b:SetSize(S.w, S.h)
    b:SetHitRectInsets(-self:Space(1), -self:Space(1), -self:Space(1), -self:Space(1))

    local st= State(b)
    st.track= NewTexture(b, 'BACKGROUND', -6)
    st.track:SetAllPoints()
    Create_Border(b)
    b.Knob= NewTexture(b, 'ARTWORK')
    b.Knob:SetSize(S.knob, S.knob)

    b.SetChecked= function(frame, value)
        frame.checked= value and true or false
        Paint_Switch(frame)
    end
    b.GetChecked= function(frame)
        return frame.checked
    end

    b:SetScript('OnClick', function(frame)
        frame:SetChecked(not frame.checked)
        Play(frame.checked)
        if frame.onChange then
            frame:onChange(frame.checked)
        end
    end)
    b:HookScript('OnEnter', On_Enter)
    b:HookScript('OnLeave', On_Leave)
    Disable_Alpha(b)
    Accented[b]= Paint_Switch
    b:SetChecked(false)
    return b
end




--Deslizador: carril de 4 px, relleno de acento, tirador de 12 px y valor editable a la derecha (44 px).
--f:SetRange(min, max, step), f:SetValue(v), f:GetValue(), f.format= '%.2f' | function(v) | nil, f:SetEnabled(bool)
--f.onChange(f, valor): al arrastrar o al escribir un valor y pulsar Intro.
local function Slider_Text(f, value)
    local fmt= f.format
    if type(fmt)=='function' then
        return fmt(value) or ''
    elseif type(fmt)=='string' then
        return format(fmt, value)
    elseif (f.step or 0)>=1 then
        return format('%d', value)
    end
    return format('%.2f', value)
end

local function Slider_Round(f, value)
    local mn, mx, step= f.min, f.max, f.step
    value= math.max(mn, math.min(mx, value or mn))
    if step and step>0 then
        value= mn+ math.floor((value-mn)/step+ 0.5)*step
    end
    return math.max(mn, math.min(mx, value))
end

local function Paint_Slider(f)
    f.Fill:SetVertexColor(AccentRGBA(1))
    if f.hover then
        f.Thumb:SetVertexColor(AccentRGBA(1))
    else
        f.Thumb:SetVertexColor(Unpack(Style.Color.text))
    end
end

function Style:CreateSlider(parent, width)
    local S= Style.Size.slider
    local f= CreateFrame('Frame', nil, parent)
    f:SetSize(width or self:Space(40), Style.Size.control)
    f.min, f.max, f.step, f.value= 0, 1, 0.1, 0

    local box= CreateFrame('EditBox', nil, f)
    box:SetSize(S.value, Style.Size.control- self:Space(1))
    box:SetPoint('RIGHT')
    box:SetAutoFocus(false)
    box:SetJustifyH('CENTER')
    box:SetFontObject(_G[Style.Font.small])
    box:SetTextInsets(2, 2, 0, 0)
    box:SetScript('OnEnterPressed', function(e)
        local value= tonumber((e:GetText() or ''):gsub(',', '.'):match('[-%d%.]+') or '')
        e:ClearFocus()
        if value then
            f:SetValue(value)
            if f.onChange then
                f:onChange(f.value)
            end
        end
    end)
    box:SetScript('OnEscapePressed', function(e)
        e:ClearFocus()
    end)
    box:SetScript('OnEditFocusLost', function(e)
        e:SetText(Slider_Text(f, f.value))
    end)
    self:Input(box)
    f.Value= box

    local s= CreateFrame('Slider', nil, f)
    s:SetOrientation('HORIZONTAL')
    s:SetPoint('LEFT')
    s:SetPoint('RIGHT', box, 'LEFT', -self:Space(2), 0)
    s:SetHeight(S.thumb)
    s:SetHitRectInsets(0, 0, -self:Space(1), -self:Space(1))
    s:SetThumbTexture(WHITE)
    if s.SetObeyStepOnDrag then
        s:SetObeyStepOnDrag(true)
    end
    local thumb= s:GetThumbTexture()
    thumb:SetSize(S.thumb, S.thumb)

    local track= NewTexture(s, 'BACKGROUND')
    track:SetPoint('LEFT')
    track:SetPoint('RIGHT')
    track:SetHeight(S.track)
    track:SetVertexColor(Unpack(Style.Color.track))

    local fill= NewTexture(s, 'BORDER')
    fill:SetPoint('LEFT', track)
    fill:SetPoint('RIGHT', thumb, 'CENTER')
    fill:SetHeight(S.track)

    f.Slider, f.Thumb, f.Fill= s, thumb, fill

    s:SetScript('OnValueChanged', function(_, value, userInput)
        value= Slider_Round(f, value)
        f.value= value
        if not box:HasFocus() then
            box:SetText(Slider_Text(f, value))
        end
        if userInput and f.onChange then
            f:onChange(value)
        end
    end)
    s:SetScript('OnEnter', function()
        f.hover= true
        Paint_Slider(f)
    end)
    s:SetScript('OnLeave', function()
        f.hover= nil
        Paint_Slider(f)
    end)

    f.SetRange= function(frame, mn, mx, step)
        frame.min, frame.max, frame.step= mn or 0, mx or 1, step
        s:SetMinMaxValues(frame.min, frame.max)
        if step and step>0 then
            s:SetValueStep(step)
        end
    end
    f.SetValue= function(frame, value)
        value= Slider_Round(frame, tonumber(value) or frame.min)
        frame.value= value
        s:SetValue(value)
        box:SetText(Slider_Text(frame, value))
    end
    f.GetValue= function(frame)
        return frame.value
    end
    f.SetEnabled= function(frame, enabled)
        s:SetEnabled(enabled and true or false)
        box:SetEnabled(enabled and true or false)
        frame:SetAlpha(enabled and 1 or Style.Alpha.disabled)
    end

    Accented[f]= Paint_Slider
    Paint_Slider(f)
    return f
end




--Desplegable: botón plano con el valor elegido y flecha; abre el menú de Blizzard con opciones de radio.
--b.values= {{value=, text=}, ...} o function(b) que devuelve esa lista. b:SetValue(v). b.onChange(b, valor).
local function Dropdown_List(b)
    local list= b.values
    if type(list)=='function' then
        list= list(b)
    end
    return type(list)=='table' and list or {}
end

local function Dropdown_Label(b)
    for _, item in ipairs(Dropdown_List(b)) do
        if item.value==b.value then
            return item.text
        end
    end
    return b.value~=nil and tostring(b.value) or ''
end

function Style:CreateDropdown(parent, width)
    local b= CreateFrame('Button', nil, parent)
    b:SetSize(width or self:Space(40), Style.Size.control)

    b.Arrow= b:CreateTexture(nil, 'ARTWORK')
    b.Arrow:SetSize(self:Space(3), self:Space(3))
    b.Arrow:SetPoint('RIGHT', -self:Space(2), 0)
    self:SetIcon(b.Arrow, 'uitools-icon-chevron-down', 'Interface\\Buttons\\Arrow-Down-Up')

    b.Text= b:CreateFontString(nil, 'OVERLAY')
    b.Text:SetPoint('LEFT', self:Space(2), 0)
    b.Text:SetPoint('RIGHT', b.Arrow, 'LEFT', -self:Space(1), 0)
    b.Text:SetJustifyH('LEFT')
    b.Text:SetWordWrap(false)

    b:SetScript('OnClick', function(frame)
        if not MenuUtil then
            return
        end
        MenuUtil.CreateContextMenu(frame, function(_, root)
            if root.SetScrollMode then
                root:SetScrollMode(Style:Space(75))
            end
            for _, item in ipairs(Dropdown_List(frame)) do
                root:CreateRadio(item.text,
                    function(value) return frame.value==value end,
                    function(value)
                        frame:SetValue(value)
                        if frame.onChange then
                            frame:onChange(value)
                        end
                        return MenuResponse and MenuResponse.Close
                    end,
                item.value)
            end
        end)
    end)
    self:Button(b)
    self:Text(b.Text, 'normal', 'text')

    b.SetValue= function(frame, value)
        frame.value= value
        frame.Text:SetText(Dropdown_Label(frame))
    end
    b.GetValue= function(frame)
        return frame.value
    end
    b.SetValues= function(frame, values)
        frame.values= values
        frame.Text:SetText(Dropdown_Label(frame))
    end
    return b
end




--Muestra de color 40x24 con el código #RRGGBB a su izquierda; abre el selector de color de Blizzard.
--b:SetColor(r, g, b, a), b.hasAlpha= true, b.onChange(b, r, g, b, a) (también al cancelar: vuelve al color anterior).
local function Open_ColorPicker(b)
    if not (ColorPickerFrame and ColorPickerFrame.SetupColorPickerAndShow) then
        return
    end
    local r, g, bl, a= b.r or 1, b.g or 1, b.b or 1, b.a or 1
    local function Apply()
        local nr, ng, nb= ColorPickerFrame:GetColorRGB()
        local na= a
        if b.hasAlpha and ColorPickerFrame.GetColorAlpha then
            na= ColorPickerFrame:GetColorAlpha()
        end
        b:SetColor(nr, ng, nb, na)
        if b.onChange then
            b:onChange(nr, ng, nb, na)
        end
    end
    ColorPickerFrame:SetupColorPickerAndShow({
        r= r, g= g, b= bl, opacity= a,
        hasOpacity= b.hasAlpha and true or false,
        swatchFunc= Apply,
        opacityFunc= Apply,
        cancelFunc= function()
            b:SetColor(r, g, bl, a)
            if b.onChange then
                b:onChange(r, g, bl, a)
            end
        end,
    })
end

function Style:CreateColorSwatch(parent)
    local b= CreateFrame('Button', nil, parent)
    b:SetSize(self:Space(10), Style.Size.control)
    local st= State(b)
    st.bg= NewTexture(b, 'BACKGROUND', -8)
    st.bg:SetAllPoints()
    st.bg:SetVertexColor(Unpack(Style.Color.button))
    Create_Border(b)

    b.Swatch= NewTexture(b, 'ARTWORK')
    b.Swatch:SetPoint('TOPLEFT', self:Space(1), -self:Space(1))
    b.Swatch:SetPoint('BOTTOMRIGHT', -self:Space(1), self:Space(1))

    b.Hex= b:CreateFontString(nil, 'OVERLAY')
    b.Hex:SetPoint('RIGHT', b, 'LEFT', -self:Space(2), 0)
    self:Text(b.Hex, 'small', 'muted')

    b.SetColor= function(frame, r, g, bl, a)
        frame.r, frame.g, frame.b, frame.a= r or 1, g or 1, bl or 1, a or 1
        frame.Swatch:SetVertexColor(frame.r, frame.g, frame.b, frame.a)
        frame.Hex:SetText(format('#%02X%02X%02X', frame.r*255+0.5, frame.g*255+0.5, frame.b*255+0.5))
    end
    b:SetScript('OnClick', Open_ColorPicker)
    b:HookScript('OnEnter', On_Enter)
    b:HookScript('OnLeave', On_Leave)
    Disable_Alpha(b)
    Accented[b]= Refresh_State
    b:SetColor(1, 1, 1, 1)
    return b
end




--Campo de texto plano. Guarda al pulsar Intro o al perder el foco; Esc deshace.
--e:SetValue(texto), e.placeholder (texto atenuado si está vacío), e.onCommit(e, texto), e.onTextChanged(e, texto, userInput)
local function Input_Placeholder(e)
    e.Placeholder:SetShown(not e:HasFocus() and (e:GetText() or '')=='')
end

function Style:CreateInput(parent, width)
    local e= CreateFrame('EditBox', nil, parent)
    e:SetSize(width or self:Space(40), Style.Size.control)
    e:SetAutoFocus(false)
    e:SetFontObject(_G[Style.Font.normal])
    e:SetTextInsets(self:Space(2), self:Space(2), 0, 0)

    e.Placeholder= e:CreateFontString(nil, 'OVERLAY')
    e.Placeholder:SetPoint('LEFT', self:Space(2), 0)
    e.Placeholder:SetPoint('RIGHT', -self:Space(2), 0)
    e.Placeholder:SetJustifyH('LEFT')
    e.Placeholder:SetWordWrap(false)
    self:Text(e.Placeholder, 'normal', 'disabled')

    e:SetScript('OnEnterPressed', function(frame)
        frame:ClearFocus()
    end)
    e:SetScript('OnEscapePressed', function(frame)
        frame.cancel= true
        frame:SetText(frame.value or '')
        frame:ClearFocus()
    end)
    e:SetScript('OnEditFocusGained', Input_Placeholder)
    e:SetScript('OnEditFocusLost', function(frame)
        Input_Placeholder(frame)
        if frame.cancel then
            frame.cancel= nil
            return
        end
        local text= frame:GetText() or ''
        if text~=(frame.value or '') then
            frame.value= text
            if frame.onCommit then
                frame:onCommit(text)
            end
        end
    end)
    e:SetScript('OnTextChanged', function(frame, userInput)
        Input_Placeholder(frame)
        if frame.onTextChanged then
            frame:onTextChanged(frame:GetText() or '', userInput)
        end
    end)
    self:Input(e)--después de SetScript (usa HookScript)

    e.SetValue= function(frame, text)
        frame.value= text~=nil and tostring(text) or ''
        frame:SetText(frame.value)
        Input_Placeholder(frame)
    end
    e.SetPlaceholder= function(frame, text)
        frame.Placeholder:SetText(text or '')
        Input_Placeholder(frame)
    end
    return e
end




--Botón de texto plano (alto 24, ancho según el texto). opts: {icon=atlas o textura, fallback=textura, width=número}
--b:SetLabel(texto) cambia el texto y recalcula el ancho.
function Style:CreateButton(parent, text, opts)
    opts= opts or {}
    local b= CreateFrame('Button', nil, parent)
    b:SetHeight(opts.height or Style.Size.control)

    b.Label= b:CreateFontString(nil, 'OVERLAY')
    b.Label:SetWordWrap(false)
    self:Text(b.Label, 'normal', 'text')

    if opts.icon then
        b.Icon= b:CreateTexture(nil, 'ARTWORK')
        b.Icon:SetSize(Style.Size.icon.small, Style.Size.icon.small)
        b.Icon:SetPoint('LEFT', self:Space(2), 0)
        self:SetIcon(b.Icon, opts.icon, opts.fallback)
        b.Label:SetPoint('LEFT', b.Icon, 'RIGHT', self:Space(1), 0)
    else
        b.Label:SetPoint('CENTER')
    end

    b.SetLabel= function(frame, label)
        frame.Label:SetText(label or '')
        if not opts.width then
            local w= math.ceil(frame.Label:GetStringWidth() or 0)+ Style:Space(6)
            if frame.Icon then
                w= w+ Style.Size.icon.small+ Style:Space(1)
            end
            frame:SetWidth(math.max(w, Style:Space(16)))
        end
    end
    if opts.width then
        b:SetWidth(opts.width)
    end
    self:Button(b)
    b:SetLabel(text)
    return b
end




--Zona desplazable: ScrollFrame + hijo (sf.Child) + barra fina de 4 px a la derecha (solo si hace falta).
--sf:SetContentHeight(alto), sf:ScrollTo(y), rueda del ratón = 48 px.
local function Paint_ScrollBar(bar)
    if bar.hover or bar.drag then
        bar.Thumb:SetVertexColor(AccentRGBA(Style.Alpha.active))
    else
        bar.Thumb:SetVertexColor(Unpack(Style.Color.track))
    end
end

function Style:CreateScroll(parent)
    local sf= CreateFrame('ScrollFrame', nil, parent)
    local child= CreateFrame('Frame', nil, sf)
    child:SetSize(1, 1)
    sf:SetScrollChild(child)
    sf.Child= child

    local bar= CreateFrame('Slider', nil, sf)
    bar:SetOrientation('VERTICAL')
    bar:SetWidth(self:Space(2))
    bar:SetPoint('TOPRIGHT', 0, 0)
    bar:SetPoint('BOTTOMRIGHT', 0, 0)
    bar:SetThumbTexture(WHITE)
    bar.Thumb= bar:GetThumbTexture()
    bar.Thumb:SetWidth(Style.Size.scrollbar)
    bar:SetMinMaxValues(0, 0)
    bar:SetValue(0)
    bar:Hide()
    sf.Bar= bar

    bar:SetScript('OnValueChanged', function(_, value)
        sf:SetVerticalScroll(value)
    end)
    bar:SetScript('OnEnter', function(b) b.hover= true Paint_ScrollBar(b) end)
    bar:SetScript('OnLeave', function(b) b.hover= nil Paint_ScrollBar(b) end)
    bar:SetScript('OnMouseDown', function(b) b.drag= true Paint_ScrollBar(b) end)
    bar:SetScript('OnMouseUp', function(b) b.drag= nil Paint_ScrollBar(b) end)
    Accented[bar]= Paint_ScrollBar
    Paint_ScrollBar(bar)

    sf.UpdateRange= function(frame)
        local h= frame:GetHeight() or 0
        local total= child:GetHeight() or 0
        local range= math.max(0, total- h)
        frame.range= range
        bar:SetMinMaxValues(0, range)
        bar:SetShown(range>0)
        if range>0 and total>0 then
            bar.Thumb:SetHeight(math.max(Style:Space(6), h*h/total))
        end
        if (frame:GetVerticalScroll() or 0)>range then
            frame:ScrollTo(range)
        end
    end
    sf.SetContentHeight= function(frame, height)
        child:SetHeight(math.max(1, height or 1))
        frame:UpdateRange()
    end
    sf.ScrollTo= function(frame, y)
        y= math.max(0, math.min(frame.range or 0, y or 0))
        frame:SetVerticalScroll(y)
        bar:SetValue(y)
    end

    sf:EnableMouseWheel(true)
    sf:SetScript('OnMouseWheel', function(frame, delta)
        frame:ScrollTo((frame:GetVerticalScroll() or 0)- delta*Style:Space(12))
    end)
    sf:SetScript('OnSizeChanged', function(frame, width)
        child:SetWidth(math.max(1, width or 1))
        frame:UpdateRange()
    end)
    return sf
end




--Elemento de barra lateral (alto 28): icono de 16, texto y contador a la derecha.
--Seleccionado: relleno de acento al 25 % y barra de acento de 2 px a la izquierda. b:SetSelected(bool)
function Style:CreateNavItem(parent)
    local b= CreateFrame('Button', nil, parent)
    b:SetHeight(Style.Size.nav)

    b.Bar= NewTexture(b, 'ARTWORK', 1)
    b.Bar:SetPoint('TOPLEFT')
    b.Bar:SetPoint('BOTTOMLEFT')
    b.Bar:SetWidth(PixelSize(b, 2))
    b.Bar:Hide()
    Accented[b.Bar]= function(t) t:SetVertexColor(AccentRGBA(1)) end
    b.Bar:SetVertexColor(AccentRGBA(1))

    b.Icon= b:CreateTexture(nil, 'ARTWORK')
    b.Icon:SetPoint('LEFT', self:Space(3), 0)
    b.Icon:SetSize(Style.Size.icon.small, Style.Size.icon.small)

    b.Count= b:CreateFontString(nil, 'OVERLAY')
    b.Count:SetPoint('RIGHT', -self:Space(3), 0)
    self:Text(b.Count, 'small', 'muted')

    b.Text= b:CreateFontString(nil, 'OVERLAY')
    b.Text:SetPoint('LEFT', b.Icon, 'RIGHT', self:Space(2), 0)
    b.Text:SetPoint('RIGHT', b.Count, 'LEFT', -self:Space(1), 0)
    b.Text:SetJustifyH('LEFT')
    b.Text:SetWordWrap(false)
    self:Text(b.Text, 'normal', 'muted')

    self:Row(b)

    b.SetSelected= function(frame, selected)
        frame.selected= selected and true or nil
        Style:SetActive(frame, selected)
        frame.Bar:SetShown(selected and true or false)
        Style:Text(frame.Text, 'normal', selected and 'text' or 'muted')
    end
    return b
end




--Tarjeta de módulo (alto 76): icono de 32, título, descripción de 2 líneas, interruptor arriba a la derecha
--y pie ("Ajustes ›") que se ilumina con el ratón encima. Toda la tarjeta es clicable (OnClick del que la usa).
--c:SetDimmed(bool): módulo desactivado (icono gris y textos atenuados).
function Style:CreateCard(parent)
    local pad= self:Space(3)
    local c= CreateFrame('Button', nil, parent)
    c:SetHeight(Style.Size.card)

    c.Icon= c:CreateTexture(nil, 'ARTWORK')
    c.Icon:SetPoint('TOPLEFT', pad, -pad)
    c.Icon:SetSize(Style.Size.icon.large, Style.Size.icon.large)

    c.Switch= self:CreateSwitch(c)
    c.Switch:SetPoint('TOPRIGHT', -pad, -pad)

    c.Title= c:CreateFontString(nil, 'OVERLAY')
    c.Title:SetPoint('TOPLEFT', c.Icon, 'TOPRIGHT', pad, 0)
    c.Title:SetPoint('RIGHT', c.Switch, 'LEFT', -self:Space(2), 0)
    c.Title:SetJustifyH('LEFT')
    c.Title:SetWordWrap(false)

    c.Desc= c:CreateFontString(nil, 'OVERLAY')
    c.Desc:SetPoint('TOPLEFT', c.Title, 'BOTTOMLEFT', 0, -self:Space(1))
    c.Desc:SetPoint('RIGHT', -pad, 0)
    c.Desc:SetJustifyH('LEFT')
    c.Desc:SetJustifyV('TOP')
    if c.Desc.SetMaxLines then
        c.Desc:SetMaxLines(2)
    end

    c.Footer= c:CreateFontString(nil, 'OVERLAY')
    c.Footer:SetPoint('BOTTOMRIGHT', -pad, self:Space(2))

    c.Badge= c:CreateFontString(nil, 'OVERLAY')
    c.Badge:SetPoint('BOTTOMLEFT', pad, self:Space(2))
    c.Badge:SetPoint('RIGHT', c.Footer, 'LEFT', -self:Space(2), 0)
    c.Badge:SetJustifyH('LEFT')
    c.Badge:SetWordWrap(false)
    self:Text(c.Badge, 'small', 'warning')

    self:Button(c)
    self:Text(c.Footer, 'small', 'muted')
    c:HookScript('OnEnter', function(frame)
        Style:Text(frame.Footer, 'small', 'accent')
    end)
    c:HookScript('OnLeave', function(frame)
        Style:Text(frame.Footer, 'small', 'muted')
    end)

    c.SetDimmed= function(frame, dimmed)
        frame.Icon:SetDesaturated(dimmed and true or false)
        frame.Icon:SetAlpha(dimmed and Style.Alpha.disabled or 1)
        Style:Text(frame.Title, 'normal', dimmed and 'muted' or 'text')
        Style:Text(frame.Desc, 'small', dimmed and 'disabled' or 'muted')
    end
    c:SetDimmed(false)
    return c
end




--------------------------------------------------------------------------------
--Eventos: combate, escala de la interfaz y acento guardado
--------------------------------------------------------------------------------

do
    local c= Style.Color.accent
    c[1], c[2], c[3]= Style:GetClassAccent()
end

EventFrame:RegisterEvent('ADDON_LOADED')
EventFrame:RegisterEvent('UI_SCALE_CHANGED')
EventFrame:RegisterEvent('DISPLAY_SIZE_CHANGED')

EventFrame:SetScript('OnEvent', function(self, event, arg1)
    if event=='PLAYER_REGEN_ENABLED' then
        self:UnregisterEvent(event)
        local list= Queue
        Queue= {}
        for _, call in ipairs(list) do
            call.func(Style, unpack(call, 1, call.n))
        end

    elseif event=='ADDON_LOADED' then
        if arg1=='WoWToolsPlus' then
            local save= type(WoWToolsPlusSave)=='table' and WoWToolsPlusSave['Style']
            local accent= save and save.accent
            if accent and accent[1] then
                Style:SetAccent(accent[1], accent[2], accent[3], true)
            else
                Style:SetAccent(nil, nil, nil, true)
            end
            self:UnregisterEvent(event)
        end

    else--UI_SCALE_CHANGED, DISPLAY_SIZE_CHANGED
        for frame in pairs(Bordered) do
            if not InCombatLockdown() or not frame:IsProtected() then
                Layout_Border(frame)
            end
        end
    end
end)
