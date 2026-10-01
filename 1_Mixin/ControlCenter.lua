--[[
Centro de control: la página "WoWToolsPlus" de Opciones › AddOns (docs/SETTINGS.md).
  Cabecera (nombre, versión, buscador) · barra lateral (General, grupos, Automatizaciones)
  · tarjetas de módulos · página de cada módulo (esquema `options`) · resultados de búsqueda
  · barra "N cambios requieren /reload".
Lee WoWTools_Module.List, y lo que el panel guardó de las llamadas sueltas (WoWTools_PanelMixin.Legacy)
y de las subpáginas de Blizzard (WoWTools_PanelMixin.SubCategories), para que no se pierda nada.
El contenido se crea al abrir el panel la primera vez y los marcos se reciclan.
/wtp abre el Centro de control (/wtp texto: busca), y también el compartimento de addons del minimapa.
]]

WoWTools_ControlCenter= {}
local CC= WoWTools_ControlCenter
local Style= WoWTools_Style
local Options= WoWTools_Options

local function T(key, ...)
    return Options:Text(key, ...) or ''
end
local function Plain(text)
    return Options:Plain(text)
end
local function Same(a, b)
    a, b= Plain(a), Plain(b)
    return a~='' and a==b
end
local function Space(n)
    return Style:Space(n)
end

local PAD= Space(4)    --margen de la zona de contenido
local GAP= Space(2)    --separación entre tarjetas
local FIELD= Space(44) --ancho de deslizadores, desplegables y campos
local LOGO= 'Interface\\AddOns\\WoWToolsPlus\\Source\\Texture\\WoWtools.tga'
local BRAND= '|cffff00ffWoW|r|cff00ff00Tools|r|cff00ccffPlus|r'


--Grupos de la barra lateral. mixins/extra: para colocar lo que no es un módulo registrado (por su nombre).
CC.Groups= {
    {id='Interface', title='Module group: Interface', icon='Interface\\Icons\\INV_Misc_Gear_01',
        mixins={'WoWTools_MoveMixin', 'WoWTools_CursorMixin', 'WoWTools_UnitMixin', 'WoWTools_AttributesMixin', 'WoWTools_MainMenuMixin', 'WoWTools_ColorMixin', 'WoWTools_ObjectiveMixin', 'WoWTools_ActionBarsMixin'},
        extra={'Auto-fill confirmation words'}},
    {id='Chat', title='Module group: Chat and social', icon='Interface\\Icons\\INV_Misc_Note_01',
        mixins={'WoWTools_ChatMixin', 'WoWTools_FriendsMixin'}},
    {id='Items', title='Module group: Items and gold', icon='Interface\\Icons\\INV_Misc_Bag_08',
        mixins={'WoWTools_MailMixin', 'WoWTools_AuctionHouseMixin', 'WoWTools_CurrencyMixin', 'WoWTools_ProfessionMixin', 'WoWTools_GemMixin'}},
    {id='Character', title='Module group: Character and collections', icon='Interface\\Icons\\INV_Chest_Chain',
        mixins={'WoWTools_PaperDollMixin', 'WoWTools_SpellMixin', 'WoWTools_MacroMixin', 'WoWTools_CollectionMixin', 'WoWTools_FactionMixin', 'WoWTools_HunterMixin', 'WoWTools_HouseMixin'}},
    {id='World', title='Module group: World and dungeons', icon='Interface\\Icons\\INV_Misc_Map_01',
        mixins={'WoWTools_EncounterMixin', 'WoWTools_ChallengeMixin', 'WoWTools_HolidayMixin'}},
    {id='Tools', title='Module group: Tools', icon='Interface\\Icons\\Trade_Engineering',
        mixins={'WoWTools_ToolsMixin', 'WoWTools_AddOnsMixin', 'WoWTools_OtherMixin'}},
}
local OTHER_ICON= 'Interface\\Icons\\INV_Misc_QuestionMark'
local GENERAL_ICON= 'Interface\\Icons\\INV_Misc_Wrench_01'
local AUTOMATION_ICON= 'Interface\\Icons\\Spell_Nature_TimeStop'




--------------------------------------------------------------------------------
--Modelo: tarjetas a partir de los módulos y de lo que guardó el panel
--------------------------------------------------------------------------------

local CHECK_KINDS= {check=true, checkButton=true, checkSlider=true, checkMenu=true}

local function Legacy_Name(entry)
    local t= entry.tab
    return t.name or t.checkName or t.title or t.buttonText
end

local function Legacy_Tooltip(entry)
    local tip= entry.tab.tooltip or entry.tab.checkTooltip
    if type(tip)=='function' then
        local ok, text= pcall(tip)
        tip= ok and text or nil
    end
    return type(tip)=='string' and tip or nil
end

local function Needs_Reload(text)
    local reload= WoWTools_L.REQUIRES_RELOAD
    return type(text)=='string' and type(reload)=='string' and reload~='' and text:find(reload, 1, true)~=nil
end

--Texto de la descripción sin el aviso de /reload (ya lo muestra el Centro de control)
local function Clean_Desc(text)
    if type(text)~='string' then
        return text
    end
    local reload= WoWTools_L.REQUIRES_RELOAD
    if type(reload)=='string' and reload~='' then
        local i= text:find(reload, 1, true)
        if i then
            text= text:sub(1, i-1)..text:sub(i+#reload)
        end
    end
    text= text:gsub('|cnWARNING_FONT_COLOR:%s*$', ''):gsub('[|n%s]+$', '')
    return text
end

local function Entry_Toggle(entry)
    local get, set= entry.tab.GetValue or entry.tab.checkGetValue, entry.tab.SetValue or entry.tab.func or entry.tab.checkSetValue
    if not (CHECK_KINDS[entry.kind] and get and set) then
        return
    end
    return {
        get= function() return get() and true or false end,
        set= function(value)
            if (not get())~=(not value) then
                set(value)
            end
        end,
        reload= Needs_Reload(Legacy_Tooltip(entry)),
    }
end

--Opciones del esquema equivalentes a lo guardado (y a sus hijas). withSelf=false: sin la casilla propia
local function Entry_Options(entry, withSelf)
    local list= {}
    local function Add(e, isSelf)
        local t= e.tab
        local name= Plain(Legacy_Name(e) or '')
        local tip= Legacy_Tooltip(e)
        local text= function() return name end
        local tooltip= tip and function() return tip end or nil
        local reload= Needs_Reload(tip)

        if CHECK_KINDS[e.kind] and not isSelf then
            local toggle= Entry_Toggle(e)
            if toggle then
                list[#list+1]= {type='check', text=text, tooltip=tooltip, reload=reload,
                    get=function() return toggle.get() end, set=function(_, value) toggle.set(value) end}
            end
        end

        if e.kind=='checkButton' and t.buttonFunc then
            list[#list+1]= {type='button', text=text, buttonText=function() return Plain(t.buttonText) end, tooltip=tooltip,
                func=function() t.buttonFunc() end}
        elseif e.kind=='button' and t.SetValue then
            list[#list+1]= {type='button', text=text, buttonText=function() return Plain(t.buttonText or name) end, tooltip=tooltip,
                func=function() t.SetValue() end}
        elseif (e.kind=='slider' or e.kind=='checkSlider') then
            local get= e.kind=='slider' and t.GetValue or t.sliderGetValue
            local set= e.kind=='slider' and t.SetValue or t.sliderSetValue
            if get and set then
                list[#list+1]= {type='slider', text=function() return Plain(t.sliderName or name) end, tooltip=tooltip, reload=reload,
                    min=t.minValue or 0, max=t.maxValue or 1, step=t.step or t.setp,
                    get=function() return get() end, set=function(_, value) set(nil, nil, value) end}
            end
        elseif e.kind=='menu' or e.kind=='checkMenu' then
            local get= e.kind=='menu' and t.GetValue or t.DropDownGetValue
            local set= e.kind=='menu' and (t.SetValue or t.func) or t.DropDownSetValue
            if get and set and t.GetOptions then
                list[#list+1]= {type='dropdown', text=function() return Plain(t.DropDownName or name) end, tooltip=tooltip, reload=reload,
                    values=function()
                        local out= {}
                        local ok, data= pcall(t.GetOptions)
                        for _, item in ipairs(ok and type(data)=='table' and data or {}) do
                            out[#out+1]= {value=item.value, text=Plain(item.label or item.text or tostring(item.value))}
                        end
                        return out
                    end,
                    get=function() return get() end, set=function(_, value) set(value) end}
            end
        end

        for _, child in ipairs(e.children) do
            Add(child)
        end
    end
    Add(entry, not withSelf)
    return list
end


local function Match_Group(name)
    for _, g in ipairs(CC.Groups) do
        for _, mixin in ipairs(g.mixins or {}) do
            local m= _G[mixin]
            if type(m)=='table' and type(rawget(m, 'addName'))=='string' and Same(m.addName, name) then
                return g.id
            end
        end
        for _, key in ipairs(g.extra or {}) do
            if Same(T(key), name) then
                return g.id
            end
        end
    end
end


local function Module_Toggle(M, sub)
    local def= M.def
    if def.toggle==false then
        return
    elseif def.panel==false and def.toggle~=true then
        if M.legacyToggle then
            return M.legacyToggle
        end
        local enable= M.subToggle or (sub and sub.enable)--su casilla en una subpágina de Blizzard
        if enable then
            return {
                get= function() return enable.get() and true or false end,
                set= function(value) enable.set(value) end,
                reload= def.reload~=false,
            }
        end
        return
    end
    return {
        get= function() return M:IsEnabled() end,
        set= function(value) M:SetEnabled(value) end,
        reload= def.reload~=false,
    }
end

local function Child_Toggle(parentM, M, sub)
    local custom= parentM and parentM.def.childToggle
    if type(custom)=='table' and custom.get and custom.set then
        return {
            get= function() return custom.get(parentM, M) and true or false end,
            set= function(value) custom.set(parentM, M, value) end,
            reload= custom.reload~=false,
        }
    end
    return Module_Toggle(M, sub)
end


local Model

function CC:BuildModel()
    local model= {groups={}, order={}, cards={}, all={}}
    for _, g in ipairs(self.Groups) do
        local group= {id=g.id, title=T(g.title), icon=g.icon, cards={}}
        model.groups[g.id]= group
        table.insert(model.order, group)
    end
    model.groups.Other= {id='Other', title=T('OTHER'), icon=OTHER_ICON, cards={}}

    local Panel= WoWTools_PanelMixin
    local subs= Panel.SubCategories
    local usedSub= {}
    local function Find_Sub(M)
        for i, sub in ipairs(subs) do
            if not usedSub[i] and sub.module==M then
                usedSub[i]= true
                return sub
            end
        end
        for i, sub in ipairs(subs) do
            if not usedSub[i] and (Same(sub.name, M.addName) or Same(sub.name, M.name)) then
                usedSub[i]= true
                return sub
            end
        end
    end

    local function Add(card, groupID)
        card.group= model.groups[groupID] or model.groups.Other
        model.cards[card.key]= card
        table.insert(model.all, card)
        if not card.parentCard then
            table.insert(card.group.cards, card)
        end
        return card
    end

    --Casillas sueltas: la que lleva el nombre del módulo que la creó es su interruptor; las demás, tarjetas propias
    local features= {}
    for index, entry in ipairs(Panel.Legacy) do
        local M= entry.module
        if M and CHECK_KINDS[entry.kind] and (M.legacyEntry==entry or (not M.legacyEntry and (Same(Legacy_Name(entry), M.addName) or Same(Legacy_Name(entry), M.name)))) then
            M.legacyEntry= entry
            M.legacyToggle= Entry_Toggle(entry)
        else
            table.insert(features, {index=index, entry=entry})
        end
    end

    --Módulos
    local function Module_Card(M, parentCard)
        local def= M.def
        local sub= Find_Sub(M)
        local card= {
            key= 'mod:'..M.key,
            kind= 'module',
            M= M,
            name= M.name or M.key,
            icon= M.icon,
            desc= def.tooltip and T(def.tooltip) or nil,
            parentCard= parentCard,
            toggle= parentCard and Child_Toggle(parentCard.M, M, sub) or Module_Toggle(M, sub),
            sub= sub,
            children= {},
            features= {},
        }
        if def.options then
            card.page= {id=card.key, M=M, options=def.options}
        end
        if M.legacyEntry then
            local extra= Entry_Options(M.legacyEntry, false)
            if #extra>0 then
                card.legacyPage= {id=card.key..':legacy', M=M, options=extra}
            end
        end
        return card
    end

    for _, M in ipairs(WoWTools_Module.List) do
        if M.name and not M.parent then
            local card= Module_Card(M)
            if M.group or card.page or card.sub then
                Add(card, M.group or 'Other')
                for _, child in ipairs(WoWTools_Module:GetChildren(M.key)) do
                    if child.name then
                        local childCard= Add(Module_Card(child, card), M.group or 'Other')
                        table.insert(card.children, childCard)
                    end
                end
            end
        end
    end

    --Tarjetas de las casillas sueltas (p. ej. Estilo de barras de acción, Autocompletar DELETE)
    for _, item in ipairs(features) do
        local entry= item.entry
        local rawName= Legacy_Name(entry) or ''
        local owner= entry.module and model.cards['mod:'..entry.module.key]
        local tip= Legacy_Tooltip(entry)
        local card= {
            key= 'entry:'..item.index,
            kind= 'entry',
            entry= entry,
            name= Plain(rawName),
            icon= Options:GetInlineIcon(rawName) or (entry.module and entry.module.icon),
            desc= tip,
            toggle= Entry_Toggle(entry),
            owner= owner,
            children= {},
            features= {},
        }
        local extra= Entry_Options(entry, false)
        if #extra>0 then
            card.legacyPage= {id=card.key, options=extra}
        end
        Add(card, Match_Group(rawName) or (entry.module and entry.module.group) or 'Other')
        if owner then
            table.insert(owner.features, card)
        end
    end

    --Subpáginas de Blizzard sin módulo (por si queda alguna)
    for i, sub in ipairs(subs) do
        if not usedSub[i] and sub.parent==Panel.Category then
            Add({
                key= 'sub:'..i,
                kind= 'sub',
                name= Plain(sub.name),
                icon= Options:GetInlineIcon(sub.name),
                sub= sub,
                children= {},
                features= {},
            }, Match_Group(sub.name) or 'Other')
        end
    end

    local function Sort(list)
        table.sort(list, function(a, b)
            if strcmputf8i then
                return strcmputf8i(a.name, b.name)<0
            end
            return a.name<b.name
        end)
    end
    for _, group in pairs(model.groups) do
        Sort(group.cards)
    end
    if #model.groups.Other.cards>0 then
        table.insert(model.order, model.groups.Other)
    end

    Model= model
    return model
end

function CC:GetModel()
    return Model or self:BuildModel()
end


--Interruptor de una tarjeta (con aviso de /reload)
function CC:SetCardEnabled(card, value)
    local toggle= card.toggle
    if not toggle then
        return
    end
    local before= toggle.get()
    toggle.set(value)
    if toggle.reload then
        Options:Track('toggle:'..card.key, tostring(before), tostring(toggle.get()), card.name)
    end
end

function CC:IsCardEnabled(card)
    if card.toggle then
        return card.toggle.get()
    end
    return true
end

--¿Tiene algo que ajustar? (para el pie de la tarjeta)
local function Has_Settings(card)
    return card.page or card.legacyPage or card.sub or (card.M and (card.M.def.openSettings or card.M.def.button))
        or #card.children>0 or #card.features>0
end

local function Open_Classic(card)
    local def= card.M and card.M.def
    if card.sub and card.sub.category and not InCombatLockdown() then
        Settings.OpenToCategory(card.sub.category:GetID())
    elseif def and def.openSettings then
        def.openSettings(card.M, card.M:Save())
    end
end

--Ruta "Grupo › Padre › Módulo"
local function Card_Path(card, withSelf)
    local parts= {card.group and card.group.title or ''}
    if card.parentCard then
        table.insert(parts, card.parentCard.name)
    end
    if withSelf then
        table.insert(parts, card.name)
    end
    return table.concat(parts, ' › ')
end




--------------------------------------------------------------------------------
--Marcos: raíz, cabecera, barra lateral, contenido y barra de recarga
--------------------------------------------------------------------------------

local Root, Search, Sidebar, Scroll, Child, ReloadBar
local NavItems= {}
local Route, LastRoute
local Built

local Pools= {}
local ActiveRows= {}
local HiddenState= {}
local Y, W

local function Acquire(kind, create)
    local pool= Pools[kind]
    if not pool then
        pool= {free={}, used={}}
        Pools[kind]= pool
    end
    local frame= table.remove(pool.free) or create()
    table.insert(pool.used, frame)
    frame:SetParent(Child)
    frame:ClearAllPoints()
    frame:Show()
    return frame
end

local function ReleaseAll()
    for _, pool in pairs(Pools) do
        for _, frame in ipairs(pool.used) do
            frame:Hide()
            frame:ClearAllPoints()
            table.insert(pool.free, frame)
        end
        wipe(pool.used)
    end
    wipe(ActiveRows)
    wipe(HiddenState)
    Style:Outline(nil)
end

--Coloca un bloque en la columna de contenido (x relativo al margen)
local function Place(frame, height, x, width)
    frame:SetPoint('TOPLEFT', Child, 'TOPLEFT', PAD+(x or 0), -Y)
    frame:SetSize(width or W, height)
end

local function New_FontString(frame, size, kind, wrap)
    local fs= frame:CreateFontString(nil, 'OVERLAY')
    fs:SetJustifyH('LEFT')
    fs:SetJustifyV('TOP')
    fs:SetWordWrap(wrap and true or false)
    Style:Text(fs, size, kind)
    return fs
end

local function Text_Height(fs, width, text)
    fs:SetWidth(width)
    fs:SetText(text or '')
    if not text or text=='' then
        return 0
    end
    return math.ceil(fs:GetStringHeight() or 0)
end




--Bloques reutilizables -------------------------------------------------------

local function Block_Title(title, sub)
    local f= Acquire('title', function()
        local frame= CreateFrame('Frame', nil, Child)
        frame.Title= New_FontString(frame, 'large', 'text', true)
        frame.Title:SetPoint('TOPLEFT')
        frame.Sub= New_FontString(frame, 'normal', 'muted', true)
        return frame
    end)
    local h= Text_Height(f.Title, W, title)
    local sh= Text_Height(f.Sub, W, sub)
    f.Sub:ClearAllPoints()
    f.Sub:SetPoint('TOPLEFT', f.Title, 'BOTTOMLEFT', 0, -Space(1))
    Place(f, h+(sh>0 and Space(1)+sh or 0))
    Y= Y+ h+(sh>0 and Space(1)+sh or 0)+ Space(4)
    return f
end


local function Block_Section(text)
    local f= Acquire('section', function()
        local frame= CreateFrame('Frame', nil, Child)
        frame.Text= New_FontString(frame, 'normal', 'accent')
        frame.Text:SetPoint('LEFT', 0, 0)
        frame.Text:SetPoint('RIGHT', 0, 0)
        frame.Line= Style:Line(frame)
        frame.Line:SetPoint('BOTTOMLEFT')
        frame.Line:SetPoint('BOTTOMRIGHT')
        return frame
    end)
    f.Text:SetText(text or '')
    Place(f, Space(6))
    Y= Y+ Space(6)+ Space(1)
    return f
end


local function Block_Note(text, kind)
    local f= Acquire('note', function()
        local frame= CreateFrame('Frame', nil, Child)
        frame.Text= New_FontString(frame, 'normal', 'muted', true)
        frame.Text:SetPoint('TOPLEFT', 0, -Space(2))
        return frame
    end)
    Style:Text(f.Text, 'normal', kind or 'muted')
    local h= Text_Height(f.Text, W, text)
    Place(f, h+ Space(4))
    Y= Y+ h+ Space(4)
    return f
end


local function Block_Empty(title, hint)
    local f= Acquire('empty', function()
        local frame= CreateFrame('Frame', nil, Child)
        frame.Title= New_FontString(frame, 'medium', 'muted', true)
        frame.Title:SetJustifyH('CENTER')
        frame.Title:SetPoint('TOP', 0, -Space(8))
        frame.Hint= New_FontString(frame, 'normal', 'disabled', true)
        frame.Hint:SetJustifyH('CENTER')
        frame.Hint:SetPoint('TOP', frame.Title, 'BOTTOM', 0, -Space(2))
        return frame
    end)
    local h= Text_Height(f.Title, W, title)
    local hh= Text_Height(f.Hint, W, hint)
    Place(f, Space(8)+h+Space(2)+hh+Space(8))
    Y= Y+ Space(16)+h+hh+Space(2)
    return f
end




--Tarjetas ---------------------------------------------------------------------

local function Card_Refresh(c)
    local card= c.card
    local enabled= CC:IsCardEnabled(card)
    c:SetDimmed(not enabled)
    c.Switch:SetShown(card.toggle~=nil)
    if card.toggle then
        c.Switch:SetChecked(enabled)
    end
    c.Badge:SetText(Options:IsPending('toggle:'..card.key) and T('Requires /reload') or '')
end

local function Block_Card(card, x, width)
    local c= Acquire('card', function()
        local frame= Style:CreateCard(Child)
        frame:SetScript('OnClick', function(self)
            CC:Go({kind='card', key=self.card.key, from=Route})
        end)
        frame.Switch.onChange= function(switch, value)
            CC:SetCardEnabled(switch:GetParent().card, value)
            CC:Refresh()
        end
        Style:SetTooltip(frame, function(self) return self.card.name end, function(self)
            local card2= self.card
            local text= card2.desc and Clean_Desc(card2.desc) or nil
            if card2.toggle and card2.toggle.reload then
                text= (text and text..'|n|n' or '')..'|cnWARNING_FONT_COLOR:'..T('Toggling requires /reload')..'|r'
            end
            return text
        end)
        return frame
    end)
    c.card= card
    Style:SetIcon(c.Icon, card.icon, OTHER_ICON)
    Style:Icon(c.Icon, 'large')
    c.Title:SetText(card.name)
    c.Desc:SetText(card.desc and Plain(Clean_Desc(card.desc)) or '')
    c.Footer:SetText(Has_Settings(card) and T('Settings ›') or T('Details ›'))
    Card_Refresh(c)
    c:SetPoint('TOPLEFT', Child, 'TOPLEFT', PAD+x, -Y)
    c:SetSize(width, Style.Size.card)
    return c
end


local function Block_Cards(cards)
    local cols= W>=Space(140) and 2 or 1
    local width= (W- GAP*(cols-1))/cols
    for i, card in ipairs(cards) do
        local col= (i-1)%cols
        Block_Card(card, col*(width+GAP), width)
        if col==cols-1 or i==#cards then
            Y= Y+ Style.Size.card+ GAP
        end
    end
end




--Filas de opciones -----------------------------------------------------------

local Controls= {
    check= function() return Style:CreateSwitch(Child) end,
    slider= function() return Style:CreateSlider(Child, FIELD) end,
    dropdown= function() return Style:CreateDropdown(Child, FIELD) end,
    color= function() return Style:CreateColorSwatch(Child) end,
    input= function() return Style:CreateInput(Child, FIELD) end,
    button= function() return Style:CreateButton(Child, '') end,
}

local function Control_Width(opt, control)
    if opt.type=='check' then
        return Style.Size.switch.w
    elseif opt.type=='color' then
        return Space(10)+Space(16)--muestra + código
    elseif opt.type=='button' then
        return control:GetWidth()
    end
    return opt.width or FIELD
end

local function Control_SetEnabled(control, opt, enabled)
    if control.SetEnabled then
        control:SetEnabled(enabled)
    end
    if opt.type=='input' and not enabled then
        control:ClearFocus()
    end
end

--Lee el valor y lo pone en el control (sin avisar)
local function Control_Load(control, opt)
    local t= opt.type
    if t=='check' then
        control:SetChecked(Options:GetValue(opt))
    elseif t=='slider' then
        control:SetValue(Options:GetValue(opt))
    elseif t=='dropdown' then
        control:SetValue(Options:GetValue(opt))
    elseif t=='color' then
        control:SetColor(Options:GetValue(opt))
    elseif t=='input' then
        if not control:HasFocus() then
            local value= Options:GetValue(opt)
            control:SetValue(value~=nil and tostring(value) or '')
        end
    end
end

local function After_Change(row)
    CC:UpdateRows(row)
end

local function Control_Setup(control, opt, row)
    local t= opt.type
    if t=='check' then
        control.onChange= function(_, value)
            Options:SetValue(opt, value)
            After_Change(row)
        end
    elseif t=='slider' then
        control:SetRange(opt.min or 0, opt.max or 1, opt.step)
        control.format= opt.format
        control.onChange= function(_, value)
            Options:SetValue(opt, value)
            After_Change(row)
        end
    elseif t=='dropdown' then
        control.values= function()
            local list= opt.values
            if type(list)=='function' then
                list= list(Options:GetSave(opt.page), opt.page.M)
            end
            local out= {}
            for _, item in ipairs(type(list)=='table' and list or {}) do
                out[#out+1]= {value=item.value, text=T(item.text)}
            end
            return out
        end
        control.onChange= function(_, value)
            Options:SetValue(opt, value)
            After_Change(row)
        end
    elseif t=='color' then
        control.hasAlpha= opt.hasAlpha
        control.onChange= function(_, r, g, b, a)
            if opt.hasAlpha then
                Options:SetValue(opt, r, g, b, a)
            else
                Options:SetValue(opt, r, g, b)
            end
            After_Change(row)
        end
    elseif t=='input' then
        control:SetWidth(opt.width or FIELD)
        if control.SetNumeric then
            control:SetNumeric(false)
        end
        control:SetMaxLetters(opt.maxLetters or 0)
        control:SetPlaceholder(opt.placeholder and T(opt.placeholder) or '')
        control.onCommit= function(frame, text)
            if opt.numeric then
                local value= tonumber(text)
                if not value then
                    Control_Load(frame, opt)
                    return
                end
                Options:SetValue(opt, value)
            else
                Options:SetValue(opt, text)
            end
            After_Change(row)
        end
    elseif t=='button' then
        control:SetLabel(T(opt.buttonText or opt.text))
        control:SetScript('OnClick', function()
            Options:Run(opt)
            After_Change(row)
        end)
    end
    Control_Load(control, opt)
end


local function Row_Create()
    local row= CreateFrame('Button', nil, Child)
    row.Label= New_FontString(row, 'normal', 'text', true)
    row.Desc= New_FontString(row, 'small', 'muted', true)
    row:SetScript('OnClick', function(self)--clic en la fila de un interruptor = clic en el interruptor
        local control= self.control
        if self.opt and self.opt.type=='check' and control and control:IsEnabled() then
            control:Click()
        end
    end)
    Style:SetTooltip(row, function(self) return self.opt and T(self.opt.text) end, function(self)
        local opt= self.opt
        local text= opt and opt.tooltip and T(opt.tooltip, Options:GetSave(opt.page), opt.page.M) or nil
        if opt and opt.reload then
            text= (text and text..'|n|n' or '')..'|cnWARNING_FONT_COLOR:'..T('Requires /reload')..'|r'
        end
        return text
    end)
    Style:Row(row)
    return row
end

local function Block_Row(opt)
    local row= Acquire('row', Row_Create)
    row.opt= opt
    local control= Acquire('control:'..opt.type, Controls[opt.type])
    control:SetParent(row)
    row.control= control
    Control_Setup(control, opt, row)

    local inner= Space(2)--margen interior: el relleno de la fila sobresale 8 px por cada lado
    local cw= Control_Width(opt, control)
    local indent= opt.indent and Space(4) or 0
    local lw= W- cw- Space(4)- indent

    local desc= opt.desc and T(opt.desc, Options:GetSave(opt.page), opt.page.M) or nil
    if opt.reload then
        desc= (desc and desc..' · ' or '')..'|cnWARNING_FONT_COLOR:'..T('Requires /reload')..'|r'
    end
    local lh= Text_Height(row.Label, lw, T(opt.text, Options:GetSave(opt.page), opt.page.M))
    local dh= Text_Height(row.Desc, lw, desc)
    local h= math.max(Style.Size.option, inner+ lh+ (dh>0 and Space(1)+dh or 0)+ inner)

    row.Label:ClearAllPoints()
    row.Desc:ClearAllPoints()
    if dh>0 then
        row.Label:SetPoint('TOPLEFT', inner+indent, -inner)
        row.Desc:SetPoint('TOPLEFT', row.Label, 'BOTTOMLEFT', 0, -Space(1))
    else
        row.Label:SetPoint('LEFT', inner+indent, 0)
    end
    control:SetPoint('RIGHT', row, 'RIGHT', -inner, 0)

    Place(row, h, -inner, W+ inner*2)
    Y= Y+ h
    table.insert(ActiveRows, row)
    return row
end


local function Block_Button(text, icon, func)
    local b= Acquire('action', function()
        local button= Style:CreateButton(Child, '', {icon=OTHER_ICON})
        button:SetScript('OnClick', function(self)
            if self.func then
                self.func()
            end
        end)
        return button
    end)
    Style:SetIcon(b.Icon, icon, OTHER_ICON)
    b:SetLabel(text)
    b.func= func
    return b
end




--Filas de submódulo y resultados de búsqueda ----------------------------------

local function Link_Create(withSwitch)
    return function()
        local b= CreateFrame('Button', nil, Child)
        b:SetHeight(Space(10))
        b.Icon= b:CreateTexture(nil, 'ARTWORK')
        b.Icon:SetPoint('LEFT', Space(2), 0)
        b.Icon:SetSize(Style.Size.icon.normal, Style.Size.icon.normal)
        b.Arrow= b:CreateTexture(nil, 'ARTWORK')
        b.Arrow:SetSize(Space(3), Space(3))
        b.Arrow:SetPoint('RIGHT', -Space(2), 0)
        Style:SetIcon(b.Arrow, 'uitools-icon-chevron-right', 'Interface\\ChatFrame\\ChatFrameExpandArrow')
        local right= b.Arrow
        if withSwitch then
            b.Switch= Style:CreateSwitch(b)
            b.Switch:SetPoint('RIGHT', b.Arrow, 'LEFT', -Space(3), 0)
            b.Switch.onChange= function(switch, value)
                CC:SetCardEnabled(switch:GetParent().card, value)
                CC:Refresh()
            end
            right= b.Switch
        end
        b.Title= New_FontString(b, 'normal', 'text')
        b.Title:SetPoint('TOPLEFT', b.Icon, 'TOPRIGHT', Space(2), 2)
        b.Title:SetPoint('RIGHT', right, 'LEFT', -Space(2), 0)
        b.Sub= New_FontString(b, 'small', 'muted')
        b.Sub:SetPoint('TOPLEFT', b.Title, 'BOTTOMLEFT', 0, -2)
        b.Sub:SetPoint('RIGHT', right, 'LEFT', -Space(2), 0)
        b:SetScript('OnClick', function(self)
            if self.func then
                self.func()
            end
        end)
        Style:Row(b)
        return b
    end
end

local function Block_Link(kind, icon, title, sub, func, card)
    local b= Acquire(kind, Link_Create(kind=='child'))
    Style:SetIcon(b.Icon, icon, OTHER_ICON)
    Style:Icon(b.Icon, 'normal')
    b.Title:SetText(title or '')
    b.Sub:SetText(sub or '')
    b.func= func
    b.card= card
    if b.Switch then
        b.Switch:SetShown(card and card.toggle~=nil)
        local enabled= not card or CC:IsCardEnabled(card)
        if card and card.toggle then
            b.Switch:SetChecked(enabled)
        end
        Style:Text(b.Title, 'normal', enabled and 'text' or 'muted')
        b.Icon:SetDesaturated(not enabled)
    end
    Place(b, Space(10), -Space(2), W+ Space(4))
    Y= Y+ Space(10)
    return b
end




--Páginas ----------------------------------------------------------------------

--Opciones de una página. Devuelve el número de filas dibujadas.
local function Render_Options(page, card)
    local count= 0
    local pendingSection
    for _, opt in ipairs(Options:Resolve(page)) do
        local hidden= Options:IsHidden(opt)
        if opt.hidden~=nil then
            HiddenState[opt.id]= hidden
        end
        if opt.type=='section' then
            pendingSection= not hidden and opt or nil
        elseif not hidden then
            if pendingSection then--la sección solo se dibuja si tiene algo debajo
                Block_Section(T(pendingSection.text))
                pendingSection= nil
            end
            if opt.type=='note' then
                Block_Note(T(opt.text, Options:GetSave(page), page.M), opt.kind)
            elseif opt.type=='children' then
                for _, child in ipairs(card and card.children or {}) do
                    Block_Link('child', child.icon, child.name, child.desc and Plain(Clean_Desc(child.desc)) or nil, function()
                        CC:Go({kind='card', key=child.key, from=Route})
                    end, child)
                end
            else
                Block_Row(opt)
            end
            count= count+1
        end
    end
    CC:UpdateRows()
    return count
end

local function Page_HasChildren(page)
    if not page then
        return false
    end
    for _, opt in ipairs(Options:Resolve(page)) do
        if opt.type=='children' then
            return true
        end
    end
end


local function Render_Group(group)
    local enabled= 0
    for _, card in ipairs(group.cards) do
        if CC:IsCardEnabled(card) then
            enabled= enabled+1
        end
    end
    Block_Title(group.title, format(T('%d modules, %d enabled'), #group.cards, enabled))
    if #group.cards==0 then
        Block_Empty(T('Nothing here yet'), nil)
        return
    end
    Block_Cards(group.cards)
end


local function Render_General()
    Block_Title(T('GENERAL'), T('Addon-wide settings'))
    if Options.General then
        Render_Options(Options.General)
    end
end


--Opciones marcadas con automation=true de todos los módulos
local function Collect_Automation()
    local list= {}
    for _, card in ipairs(CC:GetModel().all) do
        if card.page then
            local opts= {}
            for _, opt in ipairs(Options:Resolve(card.page)) do
                if opt.automation then
                    table.insert(opts, opt)
                end
            end
            if #opts>0 then
                table.insert(list, {card=card, options=opts})
            end
        end
    end
    return list
end

local function Render_Automation()
    Block_Title(T('Automations'), T('Everything the addon does on its own'))
    local list= Collect_Automation()
    if #list==0 then
        Block_Empty(T('Nothing here yet'), T('Tip.ControlCenter.Automation'))
        return
    end
    for _, item in ipairs(list) do
        Block_Section(item.card.name)
        for _, opt in ipairs(item.options) do
            if not Options:IsHidden(opt) then
                Block_Row(opt)
            end
        end
    end
    CC:UpdateRows()
end


local function Hero_Create()
    local f= CreateFrame('Frame', nil, Child)
    f.Icon= f:CreateTexture(nil, 'ARTWORK')
    f.Icon:SetPoint('TOPLEFT')
    f.Icon:SetSize(Style.Size.icon.large, Style.Size.icon.large)
    f.Switch= Style:CreateSwitch(f)
    f.Switch:SetPoint('TOPRIGHT', 0, -Space(1))
    f.Switch.onChange= function(switch, value)
        CC:SetCardEnabled(f.card, value)
        CC:Refresh()
    end
    f.State= New_FontString(f, 'small', 'muted')
    f.State:SetPoint('RIGHT', f.Switch, 'LEFT', -Space(2), 0)
    f.Title= New_FontString(f, 'large', 'text', true)
    f.Desc= New_FontString(f, 'normal', 'muted', true)
    f.Badge= New_FontString(f, 'small', 'warning', true)
    return f
end

local function Render_Card(card)
    --Ruta y volver
    local crumb= Acquire('crumb', function()
        local frame= CreateFrame('Frame', nil, Child)
        frame.Back= Style:CreateButton(frame, '', {icon='uitools-icon-chevron-left', fallback='Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up'})
        frame.Back:SetPoint('LEFT')
        frame.Back:SetScript('OnClick', function() CC:Back() end)
        frame.Path= New_FontString(frame, 'small', 'muted')
        frame.Path:SetPoint('LEFT', frame.Back, 'RIGHT', Space(3), 0)
        frame.Path:SetPoint('RIGHT')
        return frame
    end)
    crumb.Back:SetLabel(T('Back'))
    local c= Style.Color.text
    crumb.Path:SetText(Card_Path(card, false)..' › '..format('|cff%02x%02x%02x', c[1]*255, c[2]*255, c[3]*255)..card.name..'|r')
    Place(crumb, Style.Size.control)
    Y= Y+ Style.Size.control+ Space(4)

    --Cabecera del módulo
    local hero= Acquire('hero', Hero_Create)
    hero.card= card
    local enabled= CC:IsCardEnabled(card)
    Style:SetIcon(hero.Icon, card.icon, OTHER_ICON)
    Style:Icon(hero.Icon, 'large')
    hero.Icon:SetDesaturated(not enabled)
    hero.Switch:SetShown(card.toggle~=nil)
    hero.State:SetShown(card.toggle~=nil)
    if card.toggle then
        hero.Switch:SetChecked(enabled)
        hero.State:SetText(enabled and T('State: on') or T('State: off'))
    end
    local textX= Style.Size.icon.large+ Space(3)
    local textW= W- textX- (card.toggle and Space(28) or 0)
    hero.Title:ClearAllPoints()
    hero.Title:SetPoint('TOPLEFT', textX, 0)
    local th= Text_Height(hero.Title, textW, card.name)
    hero.Desc:ClearAllPoints()
    hero.Desc:SetPoint('TOPLEFT', hero.Title, 'BOTTOMLEFT', 0, -Space(1))
    local dh= Text_Height(hero.Desc, textW, card.desc and Clean_Desc(card.desc) or nil)
    local badge
    if card.toggle and card.toggle.reload then
        badge= Options:IsPending('toggle:'..card.key) and T('Changed: reload to apply') or T('Toggling requires /reload')
    end
    hero.Badge:ClearAllPoints()
    hero.Badge:SetPoint('TOPLEFT', hero.Desc, 'BOTTOMLEFT', 0, dh>0 and -Space(1) or 0)
    local bh= Text_Height(hero.Badge, textW, badge)
    local h= math.max(Style.Size.icon.large, th+ (dh>0 and Space(1)+dh or 0)+ (bh>0 and Space(1)+bh or 0))
    Place(hero, h)
    Y= Y+ h+ Space(4)

    --Botones: página clásica de Blizzard / menú, y el botón del módulo
    local x= 0
    local def= card.M and card.M.def
    if card.sub or (def and def.openSettings) then
        local b= Block_Button(T('More settings'), 'OptionsIcon-Brown', function() Open_Classic(card) end)
        b:SetPoint('TOPLEFT', Child, 'TOPLEFT', PAD+x, -Y)
        x= x+ b:GetWidth()+ GAP
    end
    if def and def.button and def.button.func then
        local b= Block_Button(T(def.button.text), card.icon, function()
            def.button.func(card.M, card.M:Save())
        end)
        b:SetPoint('TOPLEFT', Child, 'TOPLEFT', PAD+x, -Y)
        x= x+ b:GetWidth()+ GAP
    end
    if x>0 then
        Y= Y+ Style.Size.control+ Space(4)
    end

    --Opciones
    local count= 0
    if card.page then
        if card.toggle and not enabled then
            Block_Note(T('Module is disabled: changes apply when you enable it.'), 'muted')
        end
        count= count+ Render_Options(card.page, card)
    end
    if card.legacyPage then
        if card.page then
            Block_Section(T('More options'))
        end
        count= count+ Render_Options(card.legacyPage, card)
    end
    if #card.features>0 then
        Block_Section(T('Features'))
        local page= {id=card.key..':features', options={}}
        for _, feature in ipairs(card.features) do
            local feature2= feature
            if feature2.toggle then
                table.insert(page.options, {type='check', text=function() return feature2.name end,
                    tooltip= feature2.desc and function() return Clean_Desc(feature2.desc) end or nil,
                    reload= feature2.toggle.reload,
                    reloadId= 'toggle:'..feature2.key,--el mismo aviso que el interruptor de su tarjeta
                    get=function() return feature2.toggle.get() end,
                    set=function(_, value) feature2.toggle.set(value) end})
            end
        end
        count= count+ Render_Options(page, card)
    end
    if #card.children>0 and not Page_HasChildren(card.page) then
        Block_Section(T('Submodules'))
        for _, child in ipairs(card.children) do
            Block_Link('child', child.icon, child.name, child.desc and Plain(Clean_Desc(child.desc)) or nil, function()
                CC:Go({kind='card', key=child.key, from=Route})
            end, child)
            count= count+1
        end
    end
    if count==0 then
        Block_Note(card.sub and T('Tip.ControlCenter.Classic') or T('This module has no options here yet.'), 'muted')
    end
end




--Búsqueda ---------------------------------------------------------------------

function CC:Find(query)
    query= Options:Fold(query or '')
    local results= {}
    if query=='' then
        return results
    end
    local model= self:GetModel()

    for _, card in ipairs(model.all) do
        if Options:Match(query, card.name, card.desc, card.group and card.group.title) then
            table.insert(results, {icon=card.icon, title=card.name, path=Card_Path(card, false), route={kind='card', key=card.key}})
        end
    end

    local function Scan(page, card, icon, path, route)
        for _, opt in ipairs(Options:Resolve(page)) do
            if opt.type~='section' and opt.type~='children' and not Options:IsHidden(opt) then
                local ok, text= pcall(T, opt.text, Options:GetSave(page), page.M)
                local tip= opt.tooltip and type(opt.tooltip)=='string' and T(opt.tooltip) or nil
                local desc= opt.desc and type(opt.desc)=='string' and T(opt.desc) or nil
                local section= opt.section and T(opt.section.text) or nil
                if ok and text and Options:Match(query, text, tip, desc, section) then
                    table.insert(results, {icon=icon, title=Plain(text), path=path..(section and ' › '..section or ''), route={kind=route.kind, key=route.key, focus=opt.id}})
                end
            end
        end
    end
    if Options.General then
        Scan(Options.General, nil, GENERAL_ICON, T('GENERAL'), {kind='general'})
    end
    for _, card in ipairs(model.all) do
        local path= Card_Path(card, true)
        if card.page then
            Scan(card.page, card, card.icon, path, {kind='card', key=card.key})
        end
        if card.legacyPage then
            Scan(card.legacyPage, card, card.icon, path, {kind='card', key=card.key})
        end
    end
    return results
end

local function Render_Search(query)
    local results= CC:Find(query)
    Block_Title(format(T('Results for "%s"'), query), format(T('%d results'), #results))
    if #results==0 then
        Block_Empty(T('Nothing found'), T('Try another word, or check the spelling.'))
        return
    end
    for i, item in ipairs(results) do
        if i>60 then
            break
        end
        Block_Link('result', item.icon, item.title, item.path, function()
            local route= item.route
            CC:Go({kind=route.kind, key=route.key, focus=route.focus, from=Route})
        end)
    end
end




--Barra lateral ----------------------------------------------------------------

local function Nav_Routes()
    local list= {{route={kind='general'}, text=T('GENERAL'), icon=GENERAL_ICON}}
    for _, group in ipairs(CC:GetModel().order) do
        table.insert(list, {route={kind='group', id=group.id}, text=group.title, icon=group.icon, count=#group.cards, group=true})
    end
    if #Collect_Automation()>0 then
        table.insert(list, {route={kind='automation'}, text=T('Automations'), icon=AUTOMATION_ICON})
    end
    return list
end

local function Route_Section(route)
    if not route then
        return
    end
    if route.kind=='card' then
        local card= CC:GetModel().cards[route.key]
        return card and {kind='group', id=card.group.id}
    elseif route.kind=='search' then
        return
    end
    return route
end

local function Refresh_Sidebar()
    local current= Route_Section(Route)
    local y= -Space(2)
    local routes= Nav_Routes()
    for i, item in ipairs(routes) do
        local b= NavItems[i]
        if not b then
            b= Style:CreateNavItem(Sidebar)
            b:SetScript('OnClick', function(self)
                Search:SetValue('')
                Search:ClearFocus()
                CC:Go(self.route)
            end)
            NavItems[i]= b
        end
        if item.group and i==2 then--título "Módulos" antes del primer grupo
            Sidebar.Label:ClearAllPoints()
            Sidebar.Label:SetPoint('TOPLEFT', Space(3), y- Space(2))
            y= y- Space(7)
        end
        b.route= item.route
        b:ClearAllPoints()
        b:SetPoint('TOPLEFT', 0, y)
        b:SetPoint('RIGHT')
        Style:SetIcon(b.Icon, item.icon, OTHER_ICON)
        Style:Icon(b.Icon, 'small')
        b.Text:SetText(item.text)
        b.Count:SetText(item.count and tostring(item.count) or '')
        b:SetSelected(current and current.kind==item.route.kind and current.id==item.route.id)
        b:Show()
        y= y- Style.Size.nav
        if i==1 then
            y= y- Space(1)
        end
    end
    for i= #routes+1, #NavItems do
        NavItems[i]:Hide()
    end
end




--Barra de recarga -------------------------------------------------------------

local function Refresh_ReloadBar()
    if not ReloadBar then
        return
    end
    local n= Options:GetPendingCount()
    ReloadBar:SetShown(n>0)
    if n>0 then
        ReloadBar.Text:SetText(format(n==1 and T('%d change requires /reload') or T('%d changes require /reload'), n))
    end
    Scroll:ClearAllPoints()
    Scroll:SetPoint('TOPLEFT', Sidebar, 'TOPRIGHT', 0, 0)
    Scroll:SetPoint('BOTTOMRIGHT', n>0 and ReloadBar or Root, n>0 and 'TOPRIGHT' or 'BOTTOMRIGHT', 0, 0)
end




--Construcción -----------------------------------------------------------------

local function Get_Version()
    local version= C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata('WoWToolsPlus', 'Version')
    if not version or version=='' or version:find('^@') then
        return 'dev'
    end
    return version
end

local function Build(parent)
    Built= true
    Root= CreateFrame('Frame', nil, parent)
    Root:SetAllPoints()
    Style:Panel(Root, {border=false})

    --Cabecera: logo, nombre, versión y buscador
    local header= CreateFrame('Frame', nil, Root)
    header:SetPoint('TOPLEFT')
    header:SetPoint('TOPRIGHT')
    header:SetHeight(Space(12))
    Style:Panel(header, {header=true, border=false})
    local line= Style:Line(header)
    line:SetPoint('BOTTOMLEFT')
    line:SetPoint('BOTTOMRIGHT')

    local logo= header:CreateTexture(nil, 'ARTWORK')
    logo:SetSize(Space(6), Space(6))
    logo:SetPoint('LEFT', PAD, 0)
    logo:SetTexture(LOGO)

    local title= New_FontString(header, 'large', 'text')
    title:SetPoint('LEFT', logo, 'RIGHT', Space(2), 0)
    title:SetText(BRAND)

    local version= New_FontString(header, 'small', 'muted')
    version:SetPoint('BOTTOMLEFT', title, 'BOTTOMRIGHT', Space(2), 1)
    version:SetText(Get_Version())

    Search= Style:CreateInput(header, Space(56))
    Search:SetPoint('RIGHT', -PAD, 0)
    Search:SetTextInsets(Space(7), Space(7), 0, 0)
    Search.Placeholder:ClearAllPoints()
    Search.Placeholder:SetPoint('LEFT', Space(7), 0)
    Search.Placeholder:SetPoint('RIGHT', -Space(7), 0)
    Search:SetPlaceholder(T('Search modules and options'))
    local glass= Search:CreateTexture(nil, 'OVERLAY')
    glass:SetSize(Style.Size.icon.small- Space(1), Style.Size.icon.small- Space(1))
    glass:SetPoint('LEFT', Space(2), 0)
    Style:SetIcon(glass, 'common-search-magnifyingglass', 'Interface\\Common\\UI-Searchbox-Icon')
    glass:SetVertexColor(unpack(Style.Color.muted))
    local clear= CreateFrame('Button', nil, Search)
    clear:SetSize(Style.Size.icon.small, Style.Size.icon.small)
    clear:SetPoint('RIGHT', -Space(1), 0)
    clear.Icon= clear:CreateTexture(nil, 'ARTWORK')
    clear.Icon:SetAllPoints()
    Style:SetIcon(clear.Icon, 'common-search-clearbutton', 'Interface\\FriendsFrame\\ClearBroadcastIcon')
    clear:SetScript('OnClick', function()
        Search:SetValue('')
        Search:ClearFocus()
        CC:Search('')
    end)
    Style:SetTooltip(clear, T('CLEAR_ALL'))
    clear:Hide()
    Search.Clear= clear
    Search.onTextChanged= function(frame, text, userInput)
        frame.value= text--Esc solo quita el foco (no borra lo escrito)
        clear:SetShown(text~='')
        if userInput then
            CC:Search(text)
        end
    end
    Search.onCommit= function() end
    Style:SetTooltip(Search, T('Search modules and options'), T('Tip.ControlCenter.Search'))

    --Barra lateral
    Sidebar= CreateFrame('Frame', nil, Root)
    Sidebar:SetPoint('TOPLEFT', header, 'BOTTOMLEFT')
    Sidebar:SetPoint('BOTTOMLEFT')
    Sidebar:SetWidth(Style.Size.sidebar)
    Style:Panel(Sidebar, {color=Style.Color.inset, border=false})
    local sideLine= Style:Line(Sidebar, true)
    sideLine:SetPoint('TOPRIGHT')
    sideLine:SetPoint('BOTTOMRIGHT')
    Sidebar.Label= New_FontString(Sidebar, 'small', 'disabled')
    Sidebar.Label:SetText(T('Modules'))
    local hint= New_FontString(Sidebar, 'small', 'disabled')
    hint:SetPoint('BOTTOMLEFT', Space(3), Space(3))
    hint:SetText('/wtp')

    --Barra de recarga (abajo, a la derecha de la barra lateral)
    ReloadBar= CreateFrame('Frame', nil, Root)
    ReloadBar:SetPoint('BOTTOMLEFT', Sidebar, 'BOTTOMRIGHT')
    ReloadBar:SetPoint('BOTTOMRIGHT')
    ReloadBar:SetHeight(Space(10))
    Style:Panel(ReloadBar, {header=true, border=false})
    local accentLine= Style:Line(ReloadBar)
    accentLine:SetPoint('TOPLEFT')
    accentLine:SetPoint('TOPRIGHT')
    Style:Accent(accentLine, Style.Alpha.active)
    local reloadIcon= ReloadBar:CreateTexture(nil, 'ARTWORK')
    reloadIcon:SetSize(Style.Size.icon.small, Style.Size.icon.small)
    reloadIcon:SetPoint('LEFT', PAD, 0)
    Style:SetIcon(reloadIcon, 'common-icon-rotateright', 'Interface\\Buttons\\UI-RefreshButton')
    ReloadBar.Button= Style:CreateButton(ReloadBar, T('Reload now'))
    ReloadBar.Button:SetPoint('RIGHT', -PAD, 0)
    ReloadBar.Button:SetScript('OnClick', function() Options:Reload() end)
    ReloadBar.Text= New_FontString(ReloadBar, 'normal', 'warning')
    ReloadBar.Text:SetPoint('LEFT', reloadIcon, 'RIGHT', Space(2), 0)
    ReloadBar.Text:SetPoint('RIGHT', ReloadBar.Button, 'LEFT', -Space(2), 0)
    ReloadBar:Hide()

    --Contenido desplazable
    Scroll= Style:CreateScroll(Root)
    Child= Scroll.Child
    Scroll:HookScript('OnSizeChanged', function()
        if Root:IsVisible() and not CC.pendingRender then
            CC.pendingRender= true
            C_Timer.After(0, function()
                CC.pendingRender= nil
                CC:Refresh()
            end)
        end
    end)

    Options:OnPendingChanged(Refresh_ReloadBar)
    Refresh_ReloadBar()
end




--Navegación -------------------------------------------------------------------

function CC:Render(keepScroll)
    if not Built or not Route then
        return
    end
    local scroll= keepScroll and Scroll:GetVerticalScroll() or 0
    ReleaseAll()
    W= math.max(Space(60), (Scroll:GetWidth() or 0)- PAD*2)
    Y= PAD

    local kind= Route.kind
    if kind=='general' then
        Render_General()
    elseif kind=='automation' then
        Render_Automation()
    elseif kind=='search' then
        Render_Search(Route.query or '')
    elseif kind=='card' then
        local card= self:GetModel().cards[Route.key]
        if card then
            Render_Card(card)
        else
            Route= {kind='group', id='Interface'}
            return self:Render()
        end
    else
        local group= self:GetModel().groups[Route.id] or self:GetModel().order[1]
        Render_Group(group)
    end

    Scroll:SetContentHeight(Y+ PAD)
    Scroll:ScrollTo(scroll)
    Refresh_Sidebar()
    Refresh_ReloadBar()

    if Route.focus then--resultado de búsqueda: lleva a la opción y la resalta
        local focus= Route.focus
        Route.focus= nil
        for _, row in ipairs(ActiveRows) do
            if row.opt and row.opt.id==focus then
                local _, _, _, _, top= row:GetPoint(1)
                Scroll:ScrollTo(-(top or 0)- Space(10))
                Style:Outline(row)
                C_Timer.After(2, function()
                    if row.opt and row.opt.id==focus then
                        Style:Outline(nil)
                    end
                end)
                break
            end
        end
    end
end

function CC:Refresh()
    self:Render(true)
end

function CC:Go(route)
    if route.kind~='search' then
        LastRoute= route
    end
    Route= route
    self:Render(false)
end

function CC:Back()
    local from= Route and Route.from
    if from then
        Route= from
        self:Render(false)
        return
    end
    local card= Route and Route.kind=='card' and self:GetModel().cards[Route.key]
    if card and card.parentCard then
        self:Go({kind='card', key=card.parentCard.key})
    elseif card then
        self:Go({kind='group', id=card.group.id})
    else
        self:Go({kind='group', id='Interface'})
    end
end

function CC:Search(text)
    text= (text or ''):gsub('^%s+', ''):gsub('%s+$', '')
    if text=='' then
        if Route and Route.kind=='search' then
            Route= Route.from or LastRoute or {kind='group', id='Interface'}
            self:Render(false)
        end
        return
    end
    local from= Route and (Route.kind=='search' and Route.from or Route) or nil
    Route= {kind='search', query=text, from=from}
    self:Render(false)
end


--Tras un cambio: estado activado/atenuado de cada fila y valores (salvo la fila que se está tocando).
--Si cambia lo que se ve (hidden), se vuelve a dibujar la página.
function CC:UpdateRows(except)
    local relayout
    for _, row in ipairs(ActiveRows) do
        local opt= row.opt
        if opt then
            local disabled= Options:IsDisabled(opt)
            Control_SetEnabled(row.control, opt, not disabled)
            row.Label:SetAlpha(disabled and Style.Alpha.disabled or 1)
            row.Desc:SetAlpha(disabled and Style.Alpha.disabled or 1)
            if row~=except then
                Control_Load(row.control, opt)
            end
            if opt.hidden~=nil and HiddenState[opt.id]~=nil and HiddenState[opt.id]~=Options:IsHidden(opt) then
                relayout= true
            end
        end
    end
    if except and not relayout then--opciones ocultas que deberían verse ahora
        for id, hidden in pairs(HiddenState) do
            if hidden then
                for _, opt in ipairs(Options:Resolve(except.opt.page)) do
                    if opt.id==id and not Options:IsHidden(opt) then
                        relayout= true
                    end
                end
            end
        end
    end
    if relayout and not self.pendingRender then
        self.pendingRender= true
        C_Timer.After(0, function()
            self.pendingRender= nil
            self:Refresh()
        end)
    end
end




--Abrir ------------------------------------------------------------------------

--Destino: nil (última página), clave de módulo, nombre de módulo (con o sin icono) o 'general'
local function Resolve_Target(target)
    if not target or target=='' then
        return LastRoute or {kind='group', id='Interface'}
    elseif target=='general' then
        return {kind='general'}
    end
    local model= CC:GetModel()
    if model.cards['mod:'..tostring(target)] then
        return {kind='card', key='mod:'..target}
    end
    for _, card in ipairs(model.all) do
        if Same(card.name, target) or (card.M and Same(card.M.addName, target)) or (card.sub and Same(card.sub.name, target)) then
            return {kind='card', key=card.key}
        end
    end
    return {kind='search', query=Plain(target)}
end

local CombatFrame
local function Notice(text)
    if UIErrorsFrame then
        UIErrorsFrame:AddMessage(text, 1, 0.82, 0)
    else
        print(text)
    end
end

function CC:Open(target)
    if InCombatLockdown() then
        Notice(T('Cannot open options in combat: they will open when combat ends.'))
        self.queued= target or true
        if not CombatFrame then
            CombatFrame= CreateFrame('Frame')
            CombatFrame:SetScript('OnEvent', function(frame)
                frame:UnregisterAllEvents()
                local queued= CC.queued
                CC.queued= nil
                CC:Open(queued~=true and queued or nil)
            end)
        end
        CombatFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
    self.target= target or false
    Settings.OpenToCategory(WoWTools_PanelMixin.Category:GetID())
    if Root and Root:IsVisible() then
        self:OnShow()
    end
end

function CC:IsShown()
    return Root and Root:IsVisible() and true or false
end

function CC:Toggle()
    if self:IsShown() and SettingsPanel then
        if SettingsPanel.Close then
            SettingsPanel:Close()
        else
            HideUIPanel(SettingsPanel)
        end
    else
        self:Open()
    end
end

--Al mostrarse el lienzo: se construye la primera vez y se rehace el modelo (pueden haber llegado módulos)
function CC:OnShow()
    local frame= WoWTools_PanelMixin.Frame
    if frame:GetNumPoints()==0 and frame:GetParent() then--por si el panel no lo ancló
        frame:SetAllPoints(frame:GetParent())
    end
    if not Built then
        Build(WoWTools_PanelMixin.Frame)
    end
    self:BuildModel()
    local target= self.target
    self.target= nil
    if target~=nil and target~=false then
        local route= Resolve_Target(target)
        if route.kind=='search' then
            Search:SetValue(route.query)
            self:Search(route.query)
            return
        end
        self:Go(route)
    elseif not Route then
        self:Go(Resolve_Target(nil))
    else
        self:Render(true)
    end
end

WoWTools_PanelMixin.Frame:HookScript('OnShow', function()
    CC:OnShow()
end)
WoWTools_PanelMixin.Frame:HookScript('OnHide', function()
    if Search then
        Search:ClearFocus()
    end
    Style:Outline(nil)
end)




--/wtp y compartimento de addons -----------------------------------------------

SLASH_WOWTOOLSPLUS1= '/wtp'
SlashCmdList['WOWTOOLSPLUS']= function(msg)
    msg= (msg or ''):gsub('^%s+', ''):gsub('%s+$', '')
    if msg=='' then
        CC:Toggle()
    else
        CC:Open(msg)
    end
end

function WoWToolsPlus_OnAddonCompartmentClick()
    CC:Toggle()
end

function WoWToolsPlus_OnAddonCompartmentEnter(_, button)
    GameTooltip:SetOwner(button or UIParent, 'ANCHOR_LEFT')
    GameTooltip:ClearLines()
    GameTooltip_SetTitle(GameTooltip, WoWTools_DataMixin and WoWTools_DataMixin.addName or BRAND)
    GameTooltip_AddNormalLine(GameTooltip, T('Click: open the control center'), true)
    GameTooltip_AddNormalLine(GameTooltip, '/wtp', true)
    GameTooltip:Show()
end

function WoWToolsPlus_OnAddonCompartmentLeave()
    GameTooltip:Hide()
end
