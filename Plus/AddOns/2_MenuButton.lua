
local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, num

    num= CountTable(WoWTools_AddOnsMixin:Save().fast or {})

    sub=root:CreateCheckbox(
        (num==0 and '|cff626262' or '')
        ..(WoWTools_L['Shortcut list '])
        ..num,
    function()
        return not WoWTools_AddOnsMixin:Save().hideLeftList
    end, function()
        WoWTools_AddOnsMixin:Save().hideLeftList= not WoWTools_AddOnsMixin:Save().hideLeftList and true or nil
         WoWTools_AddOnsMixin:Init_Left_Buttons()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.AddOns.LeftList'])
        tooltip:AddLine(WoWTools_L['HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT+ADDON_LIST'])
        tooltip:AddLine(WoWTools_L.SETTINGS_KEYBINDINGS_LABEL)
    end)

    WoWTools_MenuMixin:Scale(self, sub, function()
        return WoWTools_AddOnsMixin:Save().leftListScale or 1
    end, function(value)
        WoWTools_AddOnsMixin:Save().leftListScale= value
         WoWTools_AddOnsMixin:Init_Left_Buttons()
    end)
    sub:CreateDivider()

    local sub2=sub:CreateButton(
        (num==0 and '|cff626262' or '')
        ..(WoWTools_L.CLEAR_ALL),
    function()
        StaticPopup_Show('WoWTools_OK',
            (WoWTools_L.CLEAR_ALL)
            ..'|n'..(WoWTools_L['Shortcut list']),
            nil,
            {SetValue=function()
                WoWTools_AddOnsMixin:Save().fast={}
                WoWTools_AddOnsMixin:Init_Left_Buttons()
            end}
        )
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.AddOns.LeftListClear'])




    
    sub=root:CreateCheckbox(
        (WoWTools_L['ADDONS+EMBLEM_SYMBOL']),
    function()
        return WoWTools_AddOnsMixin:Save().load_list
    end, function()
        WoWTools_AddOnsMixin:Save().load_list= not WoWTools_AddOnsMixin:Save().load_list and true or nil
        WoWTools_AddOnsMixin:Init_Bottom_Buttons()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.AddOns.BottomList'])
        tooltip:AddLine(WoWTools_L['Only with icons'])
        tooltip:AddLine(WoWTools_L.SPELL_FAILED_ALREADY_OPEN)
    end)

    sub2=sub:CreateCheckbox(
        WoWTools_L['Position: top'],
    function()
        return WoWTools_AddOnsMixin:Save().load_list_top
    end, function()
        WoWTools_AddOnsMixin:Save().load_list_top= not WoWTools_AddOnsMixin:Save().load_list_top and true or nil
        WoWTools_AddOnsMixin:Init_Bottom_Buttons()
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.AddOns.BottomListTop'])

    sub2=sub:CreateCheckbox(
        WoWTools_L['Icon only'],
    function()
        return WoWTools_AddOnsMixin:Save().load_list_onlyIcon
    end, function()
        WoWTools_AddOnsMixin:Save().load_list_onlyIcon= not WoWTools_AddOnsMixin:Save().load_list_onlyIcon and true or false
        WoWTools_AddOnsMixin:Init_Bottom_Buttons()
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.AddOns.BottomListIconOnly'])

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return WoWTools_AddOnsMixin:Save().load_list_size or 22
        end, setValue=function(value)
            WoWTools_AddOnsMixin:Save().load_list_size= value
            WoWTools_AddOnsMixin:Init_Bottom_Buttons()
        end,
        name=WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
        minValue=8,
        maxValue=72,
        step=1,
    })
    sub:CreateSpacer()













    num= CountTable(WoWTools_AddOnsMixin:Save().buttons or {})

    sub=root:CreateCheckbox(
        (num==0 and '|cff626262' or '')
        ..(WoWTools_L['Shortcut list ~2'])
        ..num,
    function()
        return not WoWTools_AddOnsMixin:Save().hideRightList
    end, function()
        WoWTools_AddOnsMixin:Save().hideRightList= not WoWTools_AddOnsMixin:Save().hideRightList and true or nil
        WoWTools_AddOnsMixin:Init_Right_Buttons()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.AddOns.RightList'])
        tooltip:AddLine(WoWTools_L['HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT+ADDON_LIST'])
        tooltip:AddLine(WoWTools_L.PAPERDOLL_NEWEQUIPMENTSET)
    end)

    WoWTools_MenuMixin:Scale(self, sub, function()
        return WoWTools_AddOnsMixin:Save().rightListScale or 1
    end, function(value)
        WoWTools_AddOnsMixin:Save().rightListScale= value
        WoWTools_AddOnsMixin:Init_Right_Buttons()
    end)

    sub:CreateDivider()
    sub2=sub:CreateButton(
        (num==0 and '|cff626262' or '')
        ..(WoWTools_L.CLEAR_ALL),
    function()
        StaticPopup_Show('WoWTools_OK',
            (WoWTools_L.CLEAR_ALL)
            ..'|n'..(WoWTools_L['Shortcut list~2']),
            nil,
            {SetValue=function()
                WoWTools_AddOnsMixin:Save().buttons={}
                WoWTools_AddOnsMixin:Init_Right_Buttons()
            end}
        )
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.AddOns.RightListClear'])













    sub=root:CreateCheckbox(
        (WoWTools_L.INFO)..' Plus',
    function()
        return not WoWTools_AddOnsMixin:Save().disabledInfoPlus
    end, function()
        WoWTools_AddOnsMixin:Save().disabledInfoPlus= not WoWTools_AddOnsMixin:Save().disabledInfoPlus and true
        if not WoWTools_AddOnsMixin:Save().disabledInfoPlus then
            WoWTools_Print(
                WoWTools_AddOnsMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_L.REQUIRES_RELOAD
            )
        end
        WoWTools_AddOnsMixin:Init_Info_Plus()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.AddOns.InfoPlus'])
        tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
    end)

    root:CreateDivider()
    sub=WoWTools_MenuMixin:Reload(root)

--BG Alpha
    WoWTools_MenuMixin:BgAplha(sub,
    function()--GetValue
        return WoWTools_AddOnsMixin:Save().bgAlpha or 0.5
    end, function(value)--SetValue
        WoWTools_AddOnsMixin:Save().bgAlpha= value
        WoWTools_AddOnsMixin:Init_Left_Buttons()
        WoWTools_AddOnsMixin:Init_Bottom_Buttons()
        WoWTools_AddOnsMixin:Init_Right_Buttons()
    end, function()--RestFunc
        WoWTools_AddOnsMixin:Save().bgAlpha= nil
        WoWTools_AddOnsMixin:Init_Left_Buttons()
        WoWTools_AddOnsMixin:Init_Bottom_Buttons()
        WoWTools_AddOnsMixin:Init_Right_Buttons()
    end)--onlyRoot

    sub:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(sub, {name=WoWTools_AddOnsMixin.addName})
end

























local function Init()
    local btn= CreateFrame('DropdownButton', 'WoWToolAddOnsOptionsMenuButton', AddonListCloseButton,'WoWToolsMenuTemplate')
    --WoWTools_ButtonMixin:Menu(AddonListCloseButton, {
      --  name='WoWToolAddOnsOptionsMenuButton'
    --})
    btn:SetPoint('RIGHT', AddonListCloseButton, 'LEFT', -2, 0)

    --AddonListCloseButton:SetFrameStrata(AddonList.TitleContainer:GetFrameStrata())
    --AddonListCloseButton:GetFrameLevel(AddonList.TitleContainer:GetFrameLevel()+1)

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        if WoWTools_AddOnsMixin:Save().load_list_top  then
            GameTooltip:SetOwner(AddonList, "ANCHOR_RIGHT")
        else
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        end
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_AddOnsMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(' ', (WoWTools_L.SLASH_TEXTTOSPEECH_MENU)..WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)

    btn:SetupMenu(Init_Menu)

    Init=function()end
end











function WoWTools_AddOnsMixin:Init_Menu_Button()
    Init()
end