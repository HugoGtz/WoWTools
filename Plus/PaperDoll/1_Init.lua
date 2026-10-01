local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub

    sub=root:CreateCheckbox(
        WoWTools_L.TRADESKILL_FILTER_SLOTS,
    function()
        return not WoWTools_PaperDollMixin:Save().hide
    end, function()
        WoWTools_PaperDollMixin:Save().hide= not WoWTools_PaperDollMixin:Save().hide and true or nil
        WoWTools_PaperDollMixin:Init_Item_PoaperDll()
    end, {rightText= WoWTools_PaperDollMixin:Save().statFontSize or 12})
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.PaperDoll.Slots'])
    WoWTools_MenuMixin:SetRightText(sub)

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        name= WoWTools_L.FONT_SIZE,
        getValue=function()
            return WoWTools_PaperDollMixin:Save().statFontSize or 12
        end, setValue=function(value)
            WoWTools_PaperDollMixin:Save().statFontSize= value
            WoWTools_PaperDollMixin:Init_Item_PoaperDll()
        end,
        minValue=8,
        maxValue=18,
        step=1,
        --bit--='%.1f'
        --tooltip--function, string, table
    })
    sub:CreateSpacer()




    local equipNum= #C_EquipmentSet.GetEquipmentSetIDs()
    sub=root:CreateCheckbox(
        (equipNum>0 and '' or DISABLED_FONT_COLOR:GenerateHexColorMarkup())
        ..WoWTools_PaperDollMixin.addName2,
    function()
        return not WoWTools_PaperDollMixin:Save().EquipSet.disabled
    end, function()
        WoWTools_PaperDollMixin:Save().EquipSet.disabled= not WoWTools_PaperDollMixin:Save().EquipSet.disabled and true or nil
        WoWTools_PaperDollMixin:Init_EquipSetButton()
    end, {rightText=equipNum})
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.PaperDoll.EquipSetButton'])
    WoWTools_MenuMixin:SetRightText(sub)

    WoWTools_MenuMixin:RestPoint(self, sub, WoWTools_PaperDollMixin:Save().EquipSet.point, function()
        WoWTools_PaperDollMixin:Save().EquipSet.point=nil
        WoWTools_PaperDollMixin:Init_EquipSetButton()
        return MenuResponse.Open
    end)


    sub=root:CreateCheckbox(
        WoWTools_PaperDollMixin.addName2..' Plus',
    function()
        return not WoWTools_PaperDollMixin:Save().notEquipSetPLus
    end, function()
        WoWTools_PaperDollMixin:Save().notEquipSetPLus= not WoWTools_PaperDollMixin:Save().notEquipSetPLus and true or nil
        WoWTools_PaperDollMixin:Init_EquipSetPlus()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.PaperDoll.EquipSetPlus'])

    
    if WoWTools_DataMixin.Player.Ver>=120005 then
        root:CreateDivider()
        sub=root:CreateCheckbox(
            WoWTools_L.STAT_CATEGORY_ATTRIBUTES,
        function()
            return not WoWTools_PaperDollMixin:Save().notStatusPlus
        end, function ()
            WoWTools_PaperDollMixin:Save().notStatusPlus= not WoWTools_PaperDollMixin:Save().notStatusPlus and true or nil
            WoWTools_PaperDollMixin:Init_Status()
        end)
        sub:SetTooltip(function(tooltip)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.PaperDoll.Stats'])
            GameTooltip_AddErrorLine(tooltip, WoWTools_L.REQUIRES_RELOAD)
        end)
    end

    sub=root:CreateCheckbox(
        WoWTools_L['Attribute decimals'],
    function()
        return not WoWTools_PaperDollMixin:Save().notStatusPlusFunc
    end, function ()
        WoWTools_PaperDollMixin:Save().notStatusPlusFunc= not WoWTools_PaperDollMixin:Save().notStatusPlusFunc and true or nil
        WoWTools_PaperDollMixin:Init_Status_Bit()
    end, {rightText= WoWTools_PaperDollMixin:Save().itemLevelBit or -1})
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.PaperDoll.StatDecimals'])
        tooltip:AddLine((WoWTools_L.SPELL_HASTE)..': |cffffffff9037|r|cnGREEN_FONT_COLOR:[+13%]|r  13|cffff00ff.69|r%')
        tooltip:AddLine(' ')
        GameTooltip_AddErrorLine(tooltip, WoWTools_L.REQUIRES_RELOAD)
    end)
    WoWTools_MenuMixin:SetRightText(sub)


    local bitColor=  WoWTools_PaperDollMixin:Save().notStatusPlusFunc and '|cff626262' or ''
    for i=-1, 4 do
        local tipSub= sub:CreateRadio(
            bitColor
            ..(i==-1 and (WoWTools_L.NONE)
             or ((WoWTools_L['Decimals '])..i)),
        function(data)
            return WoWTools_PaperDollMixin:Save().itemLevelBit==data.bit
        end, function(data)
            WoWTools_PaperDollMixin:Save().itemLevelBit= data.bit
            WoWTools_PaperDollMixin:UpdateStats()
            return MenuResponse.Refresh
        end, {bit=i})
        WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.PaperDoll.DecimalsCount'])
    end



    root:CreateDivider()
    local tipSub= root:CreateCheckbox(
        WoWTools_L.VAS_REALM_LABEL,
    function()
        return not WoWTools_PaperDollMixin:Save().notRealm
    end, function()
        WoWTools_PaperDollMixin:Save().notRealm= not WoWTools_PaperDollMixin:Save().notRealm and true or nil
        WoWTools_PaperDollMixin:Init_Reaml()
    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.PaperDoll.Realm'])



    local tipSub= root:CreateCheckbox(
        WoWTools_L.LEVEL,
    function()
        return not WoWTools_PaperDollMixin:Save().notLevel
    end, function()
        WoWTools_PaperDollMixin:Save().notLevel= not WoWTools_PaperDollMixin:Save().notLevel and true or nil
        WoWTools_PaperDollMixin:Init_SetLevel()

    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.PaperDoll.Level'])

    root:CreateDivider()
    sub=root:CreateCheckbox(
        WoWTools_L['Flyout'],
    function()
        return not WoWTools_PaperDollMixin:Save().notFlyout
    end, function()
        WoWTools_PaperDollMixin:Save().notFlyout= not WoWTools_PaperDollMixin:Save().notFlyout and true or false
        WoWTools_PaperDollMixin:Init_EquipmentFlyout()
    end, {rightText=WoWTools_PaperDollMixin:Save().flyoutScale or 1})
    WoWTools_MenuMixin:SetRightText(sub)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.PaperDoll.Flyout'])
        tooltip:AddLine('EquipmentFlyoutFrame')
    end)

    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return WoWTools_PaperDollMixin:Save().flyoutScale or 1
    end, function(value)
        WoWTools_PaperDollMixin:Save().flyoutScale= value
        WoWTools_PaperDollMixin:Init_EquipmentFlyout()
    end, function()
        WoWTools_PaperDollMixin:Save().flyoutScale= nil
        WoWTools_PaperDollMixin:Init_EquipmentFlyout()
    end)

    sub=root:CreateCheckbox(
        'Tab',
    function()
        return not WoWTools_PaperDollMixin:Save().notTabPlus
    end, function()
        WoWTools_PaperDollMixin:Save().notTabPlus= not WoWTools_PaperDollMixin:Save().notTabPlus and true or nil
        WoWTools_PaperDollMixin:Init_TabPlus()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.PaperDoll.Tabs'])
        tooltip:AddLine(WoWTools_L.PAPERDOLL_SIDEBAR_STATS)
        tooltip:AddLine(WoWTools_L.PAPERDOLL_SIDEBAR_TITLES)
        tooltip:AddLine(WoWTools_L.GEARSETS_TITLE)
    end)

    root:CreateDivider()
    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_PaperDollMixin.addName})

--reload
    WoWTools_MenuMixin:Reload(sub)
end


local function Init()
    local menu= CreateFrame('DropdownButton', 'WoWToolsPaperDollMenuButton', PaperDollFrame, 'WoWToolsMenuTemplate')
    menu:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT')
    menu:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)
    menu:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
    menu:SetupMenu(Init_Menu)


    WoWTools_PaperDollMixin:Init_EquipSetPlus()

    if WoWTools_PaperDollMixin.Init_Status then
        WoWTools_PaperDollMixin:Init_Status()
    end
    WoWTools_PaperDollMixin:Init_Status_Bit()

    WoWTools_PaperDollMixin:Init_Reaml()
    WoWTools_PaperDollMixin:Init_SetLevel()

    WoWTools_PaperDollMixin:Init_EquipmentFlyout()
    WoWTools_PaperDollMixin:Init_TabPlus()

    WoWTools_PaperDollMixin:Init_Item_PoaperDll()
end


--Arreglos de los ajustes guardados: se hacen siempre al cargar (también con el módulo desactivado)
local function Init_Save()
    if not WoWTools_PaperDollMixin:Save().EquipSet then
        WoWTools_PaperDollMixin:Save().EquipSet= {
            disabled= WoWTools_PaperDollMixin:Save().equipment,
            point= WoWTools_PaperDollMixin:Save().Equipment,
            toRight= WoWTools_PaperDollMixin:Save().EquipmentH,
            scale= WoWTools_PaperDollMixin:Save().equipmentFrameScale,
            strata= WoWTools_PaperDollMixin:Save().trackButtonStrata,

            itemLevel= WoWTools_PaperDollMixin:Save().trackButtonShowItemLeve,
            itemLevelScale= WoWTools_PaperDollMixin:Save().trackButtonTextScale,
        }
        WoWTools_PaperDollMixin:Save().equipment= nil
        WoWTools_PaperDollMixin:Save().Equipment= nil
        WoWTools_PaperDollMixin:Save().EquipmentH= nil
        WoWTools_PaperDollMixin:Save().equipmentFrameScale=nil
        WoWTools_PaperDollMixin:Save().trackButtonStrata= nil

        WoWTools_PaperDollMixin:Save().trackButtonTextScale= nil
        WoWTools_PaperDollMixin:Save().trackButtonShowItemLeve= nil
    end

    if WoWTools_DataMixin.Player.Ver>=120005 and WoWTools_PaperDollMixin:Save().PAPERDOLL_STATCATEGORIES then
        WoWTools_PaperDollMixin:Save().PAPERDOLL_STATCATEGORIES= nil
        WoWTools_PaperDollMixin:Save().notStatusPlus=nil
    end

    WoWTools_PaperDollMixin.addName2= '|A:bags-icon-equipment:0:0|a'..(WoWTools_L.EQUIPMENT_MANAGER)

    --WoWTools_PaperDollMixin.addName3= '|A:loottoast-arrow-orange:0:0|a'..(STAT_CATEGORY_ATTRIBUTES)
end




--Opciones del Centro de control (docs/SETTINGS.md): los mismos campos que el menú de la ficha de personaje
local function Call(func)
    return function(M)
        if M.started and M[func] then
            M[func](M)
        end
    end
end

--Interruptor "Mostrar X" sobre un campo invertido (notX/hide)
local function Show(field, text, tooltip, func, extra)
    local opt= {type='check', key=field, text=text, tooltip=tooltip, apply=Call(func),
        get= function(save) return not save[field] end,
        set= function(save, value) save[field]= not value and true or nil end,
    }
    for k, v in pairs(extra or {}) do
        opt[k]= v
    end
    return opt
end

--Botón de equipamientos: sus ajustes están en save.EquipSet
local function Set_Disabled(save)
    return save.EquipSet.disabled
end
local function Set_Check(field, text, tooltip, extra)
    local opt= {type='check', key='EquipSet.'..field, text=text, tooltip=tooltip, indent=true, disabled=Set_Disabled,
        get= function(save) return save.EquipSet[field] and true or false end,
        set= function(save, value) save.EquipSet[field]= value and true or nil end,
        apply= Call('Init_EquipSetButton'),
    }
    for k, v in pairs(extra or {}) do
        opt[k]= v
    end
    return opt
end

local StrataList= {}
for _, strata in ipairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
    table.insert(StrataList, {value=strata, text=function() return strata end})
end

local Decimals= {{value=-1, text='NONE'}}
for i=0, 4 do
    table.insert(Decimals, {value=i, text=function() return WoWTools_L['Decimals ']..i end})
end

local Options= {
    {type='section', text='GENERAL'},
    Show('hide', 'TRADESKILL_FILTER_SLOTS', 'Tip.PaperDoll.Slots', 'Init_Item_PoaperDll'),
    {type='slider', key='statFontSize', text='FONT_SIZE', tooltip='Tip.PaperDoll.FontSize', indent=true, min=8, max=18, step=1,
        disabled= function(save) return save.hide end,
        get= function(save) return save.statFontSize or 12 end,
        set= function(save, value) save.statFontSize= value end,
        apply= Call('Init_Item_PoaperDll'),
    },
    Show('notStatusPlus', 'STAT_CATEGORY_ATTRIBUTES', 'Tip.PaperDoll.Stats', 'Init_Status', {reload=true,
        hidden= function() return WoWTools_DataMixin.Player.Ver<120005 end}),
    {type='note', text='Tip.PaperDoll.StatsMenu', indent=true,
        hidden= function(save) return WoWTools_DataMixin.Player.Ver<120005 or save.notStatusPlus end},
    Show('notStatusPlusFunc', 'Attribute decimals', 'Tip.PaperDoll.StatDecimals', 'Init_Status_Bit', {reload=true}),
    {type='dropdown', key='itemLevelBit', text='Decimals', tooltip='Tip.PaperDoll.DecimalsCount', indent=true, values=Decimals,
        disabled= function(save) return save.notStatusPlusFunc end,
        get= function(save) return save.itemLevelBit or -1 end,
        set= function(save, value) save.itemLevelBit= value end,
        apply= Call('UpdateStats'),
    },
    Show('notRealm', 'VAS_REALM_LABEL', 'Tip.PaperDoll.Realm', 'Init_Reaml'),
    Show('notLevel', 'LEVEL', 'Tip.PaperDoll.Level', 'Init_SetLevel'),
    Show('notFlyout', 'Flyout', 'Tip.PaperDoll.Flyout', 'Init_EquipmentFlyout', {
        set= function(save, value) save.notFlyout= not value end}),--el menú guarda true/false
    {type='slider', key='flyoutScale', text='HOUSING_EXPERT_DECOR_SUBMODE_SCALE', tooltip='Tip.Menu.Scale', indent=true,
        min=0.4, max=4, step=0.1, format='%.1f',
        disabled= function(save) return save.notFlyout end,
        get= function(save) return save.flyoutScale or 1 end,
        set= function(save, value) save.flyoutScale= value end,
        apply= Call('Init_EquipmentFlyout'),
    },
    Show('notTabPlus', 'Tab', 'Tip.PaperDoll.Tabs', 'Init_TabPlus'),

    {type='section', text='EQUIPMENT_MANAGER'},
    Show('notEquipSetPLus', function() return WoWTools_L.EQUIPMENT_MANAGER..' Plus' end, 'Tip.PaperDoll.EquipSetPlus', 'Init_EquipSetPlus'),
    {type='check', key='EquipSet.disabled', text='Equipment sets button', tooltip='Tip.PaperDoll.EquipSetButton',
        get= function(save) return not save.EquipSet.disabled end,
        set= function(save, value) save.EquipSet.disabled= not value and true or nil end,
        apply= Call('Init_EquipSetButton'),
    },
    Set_Check('toRight', 'HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT~3', 'Tip.PaperDoll.SetToRight'),
    Set_Check('itemLevel', 'ITEM_UPGRADE_STAT_AVERAGE_ITEM_LEVEL', 'Tip.PaperDoll.SetItemLevel'),
    {type='check', key='EquipSet.notNumItem', text='AUCTION_HOUSE_QUANTITY_LABEL', tooltip='Tip.PaperDoll.SetNumItems', indent=true, disabled=Set_Disabled,
        get= function(save) return not save.EquipSet.notNumItem end,
        set= function(save, value) save.EquipSet.notNumItem= not value and true or nil end,
        apply= Call('Init_EquipSetButton'),
    },

    {type='section', text=function() return WoWTools_L['Appearance']..': '..WoWTools_L.EQUIPMENT_MANAGER end},
    {type='slider', key='EquipSet.scale', text='HOUSING_EXPERT_DECOR_SUBMODE_SCALE', tooltip='Tip.Menu.Scale', min=0.4, max=4, step=0.1, format='%.1f',
        disabled=Set_Disabled,
        get= function(save) return save.EquipSet.scale or 1 end,
        set= function(save, value) save.EquipSet.scale= value end,
        apply= Call('Init_EquipSetButton'),
    },
    {type='slider', key='EquipSet.itemLevelScale', text=function() return WoWTools_L.ITEM_UPGRADE_STAT_AVERAGE_ITEM_LEVEL..': '..WoWTools_L.HOUSING_EXPERT_DECOR_SUBMODE_SCALE end,
        tooltip='Tip.Menu.Scale', min=0.4, max=4, step=0.1, format='%.1f',
        disabled= function(save) return save.EquipSet.disabled or not save.EquipSet.itemLevel end,
        get= function(save) return save.EquipSet.itemLevelScale or 1 end,
        set= function(save, value) save.EquipSet.itemLevelScale= value end,
        apply= Call('Init_EquipSetButton'),
    },
    {type='slider', key='EquipSet.bgAlpha', text='BACKGROUND+HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', tooltip='Tip.Menu.BgAlpha',
        min=0, max=1, step=0.1, format='%.1f',
        disabled=Set_Disabled,
        get= function(save) return save.EquipSet.bgAlpha or 0.5 end,
        set= function(save, value) save.EquipSet.bgAlpha= value end,
        apply= Call('Init_EquipSetButton'),
    },
    {type='dropdown', key='EquipSet.strata', text='Strata', tooltip='Tip.Menu.Strata', values=StrataList,
        disabled=Set_Disabled,
        get= function(save) return save.EquipSet.strata or 'MEDIUM' end,
        set= function(save, value) save.EquipSet.strata= value end,
        apply= Call('Init_EquipSetButton'),
    },
    {type='button', key='EquipSet.point', text='RESET_POSITION', buttonText='RESET', tooltip='Tip.PaperDoll.SetResetPosition',
        disabled= function(save) return save.EquipSet.disabled or not save.EquipSet.point end,
        func= function(M, save)
            save.EquipSet.point= nil
            Call('Init_EquipSetButton')(M)
        end,
    },

    {type='section', text='Advanced'},
    {type='check', key='EquipSet.useSecureAction', text='Secure buttons (SecureActionButton)', tooltip='Tip.PaperDoll.SetSecure', reload=true,
        disabled=Set_Disabled,
        get= function(save) return save.EquipSet.useSecureAction and true or false end,
        set= function(save, value) save.EquipSet.useSecureAction= value and true or nil end,
    },
    {type='button', key='EquipSet.reset', text='RESET_ALL_BUTTON_TEXT', buttonText='RESET', tooltip='Tip.PaperDoll.SetResetAll', confirm=true,
        func= function(M, save)
            save.EquipSet= {}
            Call('Init_EquipSetButton')(M)
        end,
    },
}




WoWTools_Module:Register({
    key= 'Plus_PaperDoll',
    name= 'CHARACTER',
    icon= WoWTools_DataMixin.Player.Sex==Enum.UnitSex.Female and 'charactercreate-gendericon-female-selected' or 'charactercreate-gendericon-male-selected',
    group= 'Character',
    defaults= {
        StatusPlus_OnEnter_show_menu=true,
        itemLevelBit= 1,
        itemSlotScale=1,

        EquipSet={
            disabled= true,
        },
    },
    tooltip= 'Tip.PaperDoll.Module',
    mixin= WoWTools_PaperDollMixin,
    options= Options,
    onLoad= Init_Save,
    onEnable= Init,
    blizzard= {Blizzard_InspectUI= function()
        WoWTools_PaperDollMixin:Init_InspectUI()
    end},
    events= {
        PLAYER_ENTERING_WORLD= function()
            WoWTools_PaperDollMixin:Init_EquipSetButton()
            return true
        end,
        SOCKET_INFO_UPDATE= function()
            if PaperDollItemsFrame:IsShown() then
                WoWTools_PaperDollMixin:UpdateStats()
            end
        end,
    },
})
