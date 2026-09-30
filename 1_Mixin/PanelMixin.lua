--插件名称
local Category, Layout = Settings.RegisterVerticalLayoutCategory('|TInterface\\AddOns\\WoWToolsPlus\\Source\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r|cff00ccffPlus|r')
Settings.RegisterAddOnCategory(Category)

WoWTools_PanelMixin={}


--创建, 添加控制面板
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



--打开，选项
--Settings.OpenToCategory(categoryID, scrollToElementName)
function WoWTools_PanelMixin:Open(category, name)
    if InCombatLockdown() then
        return
    end

    category= (category and category.GetID) and category or Category
    Category.expanded=true

    
        name= name or category:GetName()
    

    category.OnEvaluateState= category.OnEvaluateState or function()end

    Settings.OpenToCategory(category:GetID(), name)
end


--添加，子目录
function WoWTools_PanelMixin:AddSubCategory(tab)
    local disabled
    if type(tab.disabled)=='function' then
        disabled= tab.disabled()
    else
        disabled= tab.disabled
    end

    local name= (disabled and '|cff828282' or '')..tab.name

    if tab.frame then
        return Settings.RegisterCanvasLayoutSubcategory(tab.category or Category, tab.frame, name)
    else
        return Settings.RegisterVerticalLayoutSubcategory(tab.category or Category, name)--Blizzard_SettingsInbound.lua
    end
end


--添加，标题
function WoWTools_PanelMixin:Header(layout, title)
    layout= layout or Layout
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

--Valor por defecto: tab.default si se indica (valor de fábrica); si no, el valor actual al registrar.
local function Get_Default(default, getValue, value2)
    if default~=nil then
        return default
    end
    return getValue() or value2
end

--添加，Check
function WoWTools_PanelMixin:OnlyCheck(tab, root)
    local setting=Settings.RegisterProxySetting(
        tab.category or Category,
        Set_VariableIndex(),
        Settings.VarType.Boolean,
        tab.name,
        Get_Default(tab.default, tab.GetValue, tab.value),
        tab.GetValue,
        Bool_Setter(tab.GetValue, tab.SetValue or tab.func)
    )

    local sub= Settings.CreateCheckbox(tab.category or Category, setting, tab.tooltip)

    if root then
        sub:SetParentInitializer(root)
    end

    return sub
end

--添加，按钮
--CreateSettingsButtonInitializer(name, buttonText, buttonClick, tooltip, addSearchTags)
function WoWTools_PanelMixin:OnlyButton(tab, root)
    local layout= tab.layout or Layout
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


--添加，下拉菜单
function WoWTools_PanelMixin:OnlyMenu(tab, root)
    local setting= Settings.RegisterProxySetting(--categoryTbl, variable, variableType, name, defaultValue, getValue, setValue
        tab.category or Category,
        Set_VariableIndex(),
        Settings.VarType.Number,
        tab.name,
        tab.GetValue(),
        tab.GetValue,
        tab.SetValue or tab.func
    )

    local sub= Settings.CreateDropdown(--setting, options, tooltip
        tab.category or Category,
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
    local layout= tab.layout or Layout
    local cbSetting=Settings.RegisterProxySetting(
        tab.category or Category,--categoryTbl
        Set_VariableIndex(),--variable
        Settings.VarType.Boolean,--variableType
        tab.name,--name
        Get_Default(tab.default, tab.GetValue),--defaultValue
        tab.GetValue,--getValue
        Bool_Setter(tab.GetValue, tab.SetValue or tab.func)--setValue
    )

    local dropdownSetting= Settings.RegisterProxySetting(--categoryTbl, variable, variableType, name, defaultValue, getValue, setValue
        tab.category or Category,
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


--添加，Check 和 按钮

--CreateSettingsCheckboxWithButtonInitializer(setting, buttonText, buttonClick, evaluateState, clickRequiresSet, tooltip)

function WoWTools_PanelMixin:Check_Button(tab, root)
    local layout= tab.layout or Layout
    local checkSetting=Settings.RegisterProxySetting(
        tab.category or Category,
        Set_VariableIndex(),
        Settings.VarType.Boolean,
        tab.checkName,
        Get_Default(tab.default, tab.GetValue),
        tab.GetValue,
        Bool_Setter(tab.GetValue, tab.SetValue)
    )
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
    local layout= tab.layout or Layout
    local checkSetting=Settings.RegisterProxySetting(
        tab.category or Category,
        Set_VariableIndex(),
        Settings.VarType.Boolean,
        tab.checkName,
        Get_Default(tab.checkDefault, tab.checkGetValue),
        tab.checkGetValue,
        Bool_Setter(tab.checkGetValue, tab.checkSetValue)
    )

    local sliderSetting = Settings.RegisterProxySetting(
        tab.category or Category,
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



--添加，划动条
function WoWTools_PanelMixin:OnlySlider(tab, root)
    local setting = Settings.RegisterProxySetting(
        tab.category or Category,
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

    local sub=Settings.CreateSlider(tab.category or Category, setting, options, tab.tooltip);
    Settings.SetOnValueChangedCallback(setting:GetVariable(), tab.SetValue)

    if root then
        sub:SetParentInitializer(root)
    end

    return sub
end


--重新加载UI, 重置, 按钮
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

--[[
Reorganiza la página principal (fork): los módulos se registran en el orden en que carga cada archivo.
Aquí se agrupan por tema, con un encabezado por grupo, y se ordenan por nombre dentro de cada grupo.
startIndex: primer elemento que se reorganiza (lo anterior, p. ej. "General", se deja igual).
groups: { {title='Interfaz', names={addName, ...}}, ... }. Lo que no encaje va al grupo "Otros".
Si la estructura interna de Blizzard no es la esperada, no se toca nada.
]]
local function Get_Init_Name(init)
    local data= type(init)=='table' and init.data
    if type(data)~='table' then
        return
    end
    if data.setting and data.setting.GetName then
        return data.setting:GetName()
    end
    return data.name
end

local function Get_Parent(init)
    return init.parentInitializer or (init.GetParentInitializer and init:GetParentInitializer())
end

local function Plain_Name(name)
    return (name or ''):gsub('|A.-|a', ''):gsub('|T.-|t', ''):gsub('|c%x%x%x%x%x%x%x%x', ''):gsub('|cn.-:', ''):gsub('|r', ''):gsub('^%s+', '')
end

function WoWTools_PanelMixin:Organize_Main(startIndex, groups, otherTitle)
    local ok, err= pcall(function()
        local list= Layout.GetInitializers and Layout:GetInitializers()
        if type(list)~='table' or #list<startIndex then
            return
        end

        --Bloques: un elemento principal y los hijos que lo siguen
        local blocks= {}
        for index= startIndex, #list do
            local init= list[index]
            local isHeader= init.GetTemplate and init:GetTemplate()=='SettingsListSectionHeaderTemplate'
            if isHeader then
                --los encabezados sueltos antiguos se descartan; se crean de nuevo por grupo
            else
            if Get_Parent(init) and #blocks>0 then
                table.insert(blocks[#blocks].items, init)
            else
                table.insert(blocks, {name= Get_Init_Name(init), items= {init}})
            end
            end
        end

        local groupBlocks= {}
        local other= {}
        for _, block in ipairs(blocks) do
            local found
            if block.name then
                for gIndex, group in ipairs(groups) do
                    for _, name in ipairs(group.names) do
                        if name and name~='' and block.name:find(name, 1, true) then
                            found= gIndex
                            break
                        end
                    end
                    if found then
                        break
                    end
                end
            end
            if found then
                groupBlocks[found]= groupBlocks[found] or {}
                table.insert(groupBlocks[found], block)
            elseif block.name then--los encabezados sueltos antiguos (sin nombre) se descartan
                table.insert(other, block)
            end
        end

        local function Sort(tab)
            table.sort(tab, function(a, b)
                local x, y= Plain_Name(a.name), Plain_Name(b.name)
                if strcmputf8i then
                    return strcmputf8i(x, y)<0
                end
                return x<y
            end)
        end

        local newList= {}
        for index= 1, startIndex-1 do
            newList[index]= list[index]
        end
        local function Add(title, tab)
            if not tab or #tab==0 then
                return
            end
            Sort(tab)
            table.insert(newList, CreateSettingsListSectionHeaderInitializer(title))
            for _, block in ipairs(tab) do
                for _, init in ipairs(block.items) do
                    table.insert(newList, init)
                end
            end
        end
        for gIndex, group in ipairs(groups) do
            Add(group.title, groupBlocks[gIndex])
        end
        Add(otherTitle, other)

        wipe(list)
        for index, init in ipairs(newList) do
            list[index]= init
        end
    end)
end

function WoWTools_PanelMixin:GetMainCount()
    local list= Layout.GetInitializers and Layout:GetInitializers()
    return type(list)=='table' and #list or 0
end
