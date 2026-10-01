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
