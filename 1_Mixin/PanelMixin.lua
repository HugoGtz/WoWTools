--[[
Panel de Blizzard (Opciones › AddOns). La categoría principal "WoWToolsPlus" es un lienzo (canvas)
que dibuja el Centro de control (1_Mixin/ControlCenter.lua). Las subpáginas de los módulos
(AddSubCategory) siguen siendo páginas verticales de Blizzard que cuelgan de ella.

Las llamadas sin categoría (OnlyCheck, Check_Button... que antes iban a la página principal) ya no
crean nada en Blizzard: se guardan en WoWTools_PanelMixin.Legacy y el Centro de control las muestra
(como interruptor del módulo que las creó o como tarjeta propia). Devuelven un objeto que se puede
pasar como root a otras llamadas: sus hijas también se guardan.
]]

local MainFrame= CreateFrame('Frame')--lienzo de la categoría principal (lo rellena el Centro de control)
MainFrame:Hide()

local Category, Layout = Settings.RegisterCanvasLayoutCategory(MainFrame, '|TInterface\\AddOns\\WoWToolsPlus\\Source\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r|cff00ccffPlus|r')
if Layout and Layout.AddAnchorPoint then--el lienzo ocupa toda la zona de contenido del panel
    Layout:AddAnchorPoint('TOPLEFT', 0, 0)
    Layout:AddAnchorPoint('BOTTOMRIGHT', 0, 0)
end
Settings.RegisterAddOnCategory(Category)

WoWTools_PanelMixin={
    Category= Category,
    Frame= MainFrame,
    Legacy= {},        --casillas y botones sueltos (sin categoría), en orden de creación
    SubCategories= {}, --{name=, category=, layout=, parent=, module=, enable=} de cada AddSubCategory
                       --(enable: su casilla "Activar", {get=, set=, tooltip=})
}

local LayoutOf= {}--categoría -> layout (las subpáginas creadas con AddSubCategory)
local SubOf= {}--categoría -> registro de WoWTools_PanelMixin.SubCategories

local function Plain(text)
    return type(text)=='string' and text:gsub('|A.-|a', ''):gsub('|T.-|t', ''):gsub('|c%x%x%x%x%x%x%x%x', ''):gsub('|cn.-:', ''):gsub('|r', '') or ''
end

--Interruptor del módulo en el Centro de control: la casilla "Activar" de su subpágina,
--o la casilla con el nombre del módulo que se está cargando (p. ej. Emotes en la página del Botón de chat)
local function Note_Enable(category, name, getValue, setValue, tooltip)
    if not (getValue and setValue) then
        return
    end
    local sub= category and SubOf[category]
    if sub and not sub.enable and name==WoWTools_L.ENABLE then
        sub.enable= {get= getValue, set= setValue, tooltip= tooltip}
    end
    local M= WoWTools_Module and WoWTools_Module.Current
    if M and not M.subToggle and M.addName and Plain(name)~='' and Plain(name)==Plain(M.addName) then
        M.subToggle= {get= getValue, set= setValue, tooltip= tooltip}
    end
end


local variableIndex=0
local function Set_VariableIndex()
    variableIndex= variableIndex+1
    return 'WoWToolsPanelVariable'..variableIndex
end
local function Set_SearchTags_Text(tags)
    if tags then
        tags= tags:gsub('|A.-|a', '')
        tags= tags:gsub('|T.-|t', '')
        tags= tags:gsub('|c........', '')
        tags= tags:gsub('|r', '')
    else
         tags=''
    end
    return tags
end




--------------------------------------------------------------------------------
--Elementos sueltos (antes en la página principal): se guardan para el Centro de control
--------------------------------------------------------------------------------

local Noop= function() end
local ProxyMeta= {__index= function() return Noop end}--métodos de initializer que no hacen nada

local function IsProxy(root)
    return type(root)=='table' and rawget(root, 'WoWToolsLegacy')~=nil
end

local function Capture(kind, tab, root)
    local entry= {
        kind= kind,
        tab= tab,
        module= WoWTools_Module and WoWTools_Module.Current or nil,
        children= {},
    }
    if IsProxy(root) then
        entry.parent= root.WoWToolsLegacy
        table.insert(root.WoWToolsLegacy.children, entry)
    else
        table.insert(WoWTools_PanelMixin.Legacy, entry)
    end
    entry.proxy= setmetatable({WoWToolsLegacy= entry}, ProxyMeta)
    return entry.proxy
end


--Categoría y layout de destino; nil si iba a la página principal (entonces se guarda)
local function Target(tab, root, needLayout)
    if IsProxy(root) then
        return
    end
    local category= tab.category
    local layout= tab.layout or (category and LayoutOf[category])
    if not layout and category and SettingsPanel and SettingsPanel.GetLayout then
        layout= SettingsPanel:GetLayout(category)
    end
    if (not category and not tab.layout) or category==Category or layout==Layout then
        return
    end
    if needLayout and not layout then
        return
    end
    return category, layout
end




--Settings.OpenToCategory(categoryID, scrollToElementName)
--Sin categoría (o la principal): abre el Centro de control; con name, en la página de ese módulo.
function WoWTools_PanelMixin:Open(category, name)
    if not (category and category.GetID) or category==Category then
        if WoWTools_ControlCenter then
            WoWTools_ControlCenter:Open(name)
        elseif not InCombatLockdown() then
            Settings.OpenToCategory(Category:GetID())
        end
        return
    end
    if InCombatLockdown() then
        return
    end
    Category.expanded=true
    name= name or category:GetName()
    category.OnEvaluateState= category.OnEvaluateState or function()end
    Settings.OpenToCategory(category:GetID(), name)
end


function WoWTools_PanelMixin:AddSubCategory(tab)
    local disabled
    if type(tab.disabled)=='function' then
        disabled= tab.disabled()
    else
        disabled= tab.disabled
    end

    local name= (disabled and '|cff828282' or '')..tab.name
    local parent= tab.category or Category

    local category, layout
    if tab.frame then
        category, layout= Settings.RegisterCanvasLayoutSubcategory(parent, tab.frame, name)
    else
        category, layout= Settings.RegisterVerticalLayoutSubcategory(parent, name)--Blizzard_SettingsInbound.lua
    end

    if category then
        if layout then
            LayoutOf[category]= layout
        end
        local sub= {
            name= tab.name,
            category= category,
            layout= layout,
            parent= parent,
            module= WoWTools_Module and WoWTools_Module.Current or nil,
        }
        SubOf[category]= sub
        table.insert(self.SubCategories, sub)
    end
    return category, layout
end


function WoWTools_PanelMixin:Header(layout, title)
    if not layout or layout==Layout then--la página principal ya no es una lista: los títulos sueltos se ignoran
        return
    end
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(title))
end

--Settings.RegisterProxySetting(categoryTbl, variable, variableType, name, defaultValue, getValue, setValue)



--Muchos SetValue alternan (x= not x) en vez de asignar el valor recibido.
--Con "Predeterminados" se llamaban aunque el valor ya fuera el correcto e invertían la casilla:
--solo se llaman si el valor booleano cambia de verdad.
local function Bool_Setter(getValue, setValue)
    if not setValue or not getValue then
        return setValue
    end
    return function(value, ...)
        if (not getValue()) ~= (not value) then
            return setValue(value, ...)
        end
    end
end
WoWTools_PanelMixin.Bool_Setter= Bool_Setter

--Valor por defecto: tab.default si se indica (valor de fábrica); si no, el valor actual al registrar.
local function Get_Default(default, getValue, value2)
    if default~=nil then
        return default
    end
    return getValue() or value2
end

function WoWTools_PanelMixin:OnlyCheck(tab, root)
    local category= Target(tab, root)
    if not category then
        return Capture('check', tab, root)
    end
    local setting=Settings.RegisterProxySetting(
        category,
        Set_VariableIndex(),
        Settings.VarType.Boolean,
        tab.name,
        Get_Default(tab.default, tab.GetValue, tab.value),
        tab.GetValue,
        Bool_Setter(tab.GetValue, tab.SetValue or tab.func)
    )

    local sub= Settings.CreateCheckbox(category, setting, tab.tooltip)
    Note_Enable(category, tab.name, tab.GetValue, setting and Bool_Setter(tab.GetValue, tab.SetValue or tab.func), tab.tooltip)

    if root then
        sub:SetParentInitializer(root)
    end

    return sub
end

--CreateSettingsButtonInitializer(name, buttonText, buttonClick, tooltip, addSearchTags)
function WoWTools_PanelMixin:OnlyButton(tab, root)
    local _, layout= Target(tab, root, true)
    if not layout then
        return Capture('button', tab, root)
    end
    local sub= CreateSettingsButtonInitializer(--Blizzard_SettingControls.lua
        tab.title or tab.name or '',
        tab.buttonText or '',
        tab.SetValue,
        tab.tooltip or tab.buttonText or tab.title or nil,
        Set_SearchTags_Text(tab.addSearchTags or tab.title or tab.buttonText)
    )
    layout:AddInitializer(sub)

    if root then
        sub:SetParentInitializer(root)
    end

    return sub
end


function WoWTools_PanelMixin:OnlyMenu(tab, root)
    local category= Target(tab, root)
    if not category then
        return Capture('menu', tab, root)
    end
    local setting= Settings.RegisterProxySetting(--categoryTbl, variable, variableType, name, defaultValue, getValue, setValue
        category,
        Set_VariableIndex(),
        Settings.VarType.Number,
        tab.name,
        tab.GetValue(),
        tab.GetValue,
        tab.SetValue or tab.func
    )

    local sub= Settings.CreateDropdown(--setting, options, tooltip
        category,
        setting,
        tab.GetOptions,
        tab.tooltip
    )

    if root then
        sub:SetParentInitializer(root)
    end

    return sub
end

--Blizzard_SettingControls.lua
--CreateSettingsCheckboxDropdownInitializer(cbSetting, cbLabel, cbTooltip, dropdownSetting, dropdownOptions, dropDownLabel, dropDownTooltip)
function WoWTools_PanelMixin:CheckMenu(tab, root)
    local category, layout= Target(tab, root, true)
    if not category then
        return Capture('checkMenu', tab, root)
    end
    local cbSetting=Settings.RegisterProxySetting(
        category,--categoryTbl
        Set_VariableIndex(),--variable
        Settings.VarType.Boolean,--variableType
        tab.name,--name
        Get_Default(tab.default, tab.GetValue),--defaultValue
        tab.GetValue,--getValue
        Bool_Setter(tab.GetValue, tab.SetValue or tab.func)--setValue
    )

    local dropdownSetting= Settings.RegisterProxySetting(--categoryTbl, variable, variableType, name, defaultValue, getValue, setValue
        category,
        Set_VariableIndex(),
        Settings.VarType.Number,
        tab.name,
        tab.DropDownGetValue(),
        tab.DropDownGetValue,
        tab.DropDownSetValue
    )

	local data =
	{
		name = tab.name,
		tooltip = tab.tooltip,
		cbSetting = cbSetting,
		cbLabel = tab.CheckBoxName or tab.name,
		cbTooltip = tab.CheckBoxTooltip or tab.tooltip,
		dropdownSetting = dropdownSetting,
		dropdownOptions = tab.GetOptions,
		dropDownLabel = tab.DropDownName or tab.name,
		dropDownTooltip = tab.DropDownTooltip or tab.tooltip,
	};
	local sub= Settings.CreateSettingInitializer("SettingsCheckboxDropdownControlTemplate", data)
    layout:AddInitializer(sub)

    if root then
        sub:SetParentInitializer(root)
    end

    return sub
end



--CreateSettingsCheckboxWithButtonInitializer(setting, buttonText, buttonClick, evaluateState, clickRequiresSet, tooltip)

function WoWTools_PanelMixin:Check_Button(tab, root)
    local category, layout= Target(tab, root, true)
    if not category then
        return Capture('checkButton', tab, root)
    end
    local checkSetting=Settings.RegisterProxySetting(
        category,
        Set_VariableIndex(),
        Settings.VarType.Boolean,
        tab.checkName,
        Get_Default(tab.default, tab.GetValue),
        tab.GetValue,
        Bool_Setter(tab.GetValue, tab.SetValue)
    )
    Note_Enable(category, tab.checkName, tab.GetValue, Bool_Setter(tab.GetValue, tab.SetValue), tab.tooltip)
    local sub= CreateSettingsCheckboxWithButtonInitializer(
        checkSetting,--setting
        tab.buttonText,--buttonText
        tab.buttonFunc,--buttonClick
        nil,--evaluateState
        tab.tooltip--tooltip
    )
    layout:AddInitializer(sub)

    if root then
        sub:SetParentInitializer(root)
    end
    return sub
end


function WoWTools_PanelMixin:Check_Slider(tab, root)
    local category, layout= Target(tab, root, true)
    if not category then
        return Capture('checkSlider', tab, root)
    end
    local checkSetting=Settings.RegisterProxySetting(
        category,
        Set_VariableIndex(),
        Settings.VarType.Boolean,
        tab.checkName,
        Get_Default(tab.checkDefault, tab.checkGetValue),
        tab.checkGetValue,
        Bool_Setter(tab.checkGetValue, tab.checkSetValue)
    )

    local sliderSetting = Settings.RegisterProxySetting(
        category,
        Set_VariableIndex(),
        Settings.VarType.Number,
        tab.sliderName or tab.checkName,
        tab.sliderGetValue(),
        tab.sliderGetValue,
        tab.sliderSetValue
    )

    local options = Settings.CreateSliderOptions(tab.minValue, tab.maxValue, tab.step);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
       return WoWTools_DataMixin:GetFormatter1to10(value or 1, 0, 1)
    end)

    local sub = CreateSettingsCheckboxSliderInitializer(
        checkSetting,
        tab.checkName,
        tab.checkTooltip or tab.tooltip,

        sliderSetting,
        options,
        tab.sliderName or tab.checkName,
        tab.siderTooltip or tab.checkTooltip or tab.tooltip
    )

    Settings.SetOnValueChangedCallback(sliderSetting:GetVariable(), tab.sliderSetValue)
    layout:AddInitializer(sub)

    if root then
        sub:SetParentInitializer(root)
    end
    return sub
end



function WoWTools_PanelMixin:OnlySlider(tab, root)
    local category= Target(tab, root)
    if not category then
        return Capture('slider', tab, root)
    end
    local setting = Settings.RegisterProxySetting(
        category,
        Set_VariableIndex(),
        Settings.VarType.Number,
        tab.name,
        tab.GetValue(),
        tab.GetValue,
        tab.SetValue
    )

    local options = Settings.CreateSliderOptions(tab.minValue, tab.maxValue, tab.setp);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return WoWTools_DataMixin:GetFormatter1to10(value or 1, 0, 1)
    end)

    local sub=Settings.CreateSlider(category, setting, options, tab.tooltip);
    Settings.SetOnValueChangedCallback(setting:GetVariable(), tab.SetValue)

    if root then
        sub:SetParentInitializer(root)
    end

    return sub
end


function WoWTools_PanelMixin:ReloadButton(tab)
    local rest= WoWTools_ButtonMixin:Cbtn(tab.panel, {isUI=true, size=25})
    rest:SetNormalAtlas('bags-button-autosort-up')
    rest:SetPushedAtlas('bags-button-autosort-down')
    rest:SetPoint('TOPRIGHT',0,8)
    rest.addName=tab.addName
    rest.func=tab.clearfunc
    rest.clearTips=tab.clearTips
    rest:SetScript('OnClick', function(frame)
        StaticPopup_Show('WoWTools_RestData',
            frame.addName or WoWTools_DataMixin.addName,
            nil,
            frame.func
        )
    end)
    rest:SetScript('OnLeave', GameTooltip_Hide)
    rest:SetScript('OnEnter', function(frame)
        GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(frame.clearTips or WoWTools_L['Current save'])
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, frame.addName)
        GameTooltip:Show()
    end)

    local reload= CreateFrame('Button', nil, tab.panel, 'WoWToolsButtonTemplate')
    reload:SetNormalTexture('Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up')
    reload:SetPoint('TOPLEFT',-12, 8)
    reload.tooltip=WoWTools_DataMixin.Icon.icon2..(WoWTools_L.RELOADUI)
    reload:SetScript('OnClick', function() WoWTools_DataMixin:Reload() end)

    if tab.disabledfunc then
        local check=WoWTools_ButtonMixin:Cbtn(tab.panel, {
            isCheck=true,
            text=WoWTools_TextMixin:GetEnabeleDisable(true),
            isRightText=true,
        })
        --check.Text:SetText(WoWTools_TextMixin:GetEnabeleDisable(true))
        check:SetChecked(tab.checked)
        check:SetPoint('LEFT', reload, 'RIGHT')
        check:SetScript('OnClick', tab.disabledfunc)
        check:SetScript('OnLeave', GameTooltip_Hide)
        check.addName= tab.addName
        check:SetScript('OnEnter', function(frame)
            GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(WoWTools_L['Enable/Disable'])
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, frame.addName)
            GameTooltip:Show()
        end)
    end
    if tab.restTips then
        local needReload= tab.panel:CreateFontString(nil, 'BORDER', 'ChatFontNormal') --WoWTools_LabelMixin:Create(tab.panel)
        needReload:SetText('|A:common-icon-rotateright:0:0|a'..(WoWTools_L.REQUIRES_RELOAD)..'|A:common-icon-rotateleft:0:0|a')
        needReload:SetPoint('BOTTOMRIGHT')
    end
end


--Compatibilidad: la página principal ya no es una lista que haya que reorganizar (la agrupa el Centro de control)
function WoWTools_PanelMixin:Organize_Main()
end

function WoWTools_PanelMixin:GetMainCount()
    return 0
end
