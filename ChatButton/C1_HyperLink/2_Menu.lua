--#####
local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2, col
    local isInBat= InCombatLockdown()

    sub= root:CreateCheckbox(
        (C_SocialRestrictions.IsChatDisabled() and '|cff828282' or '')
        ..WoWTools_HyperLink.addName,
    function()
        return WoWTools_HyperLink:Save().linkIcon
    end,
        self.set_OnMouseDown
    )
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.HyperLink.LinkIcon'])
        if C_SocialRestrictions.IsChatDisabled() then
            tooltip:AddLine(WoWTools_L.SOCIALS)
            tooltip:AddLine(WoWTools_L.RESTRICT_CHAT_CONFIG_DISABLE)
        end
    end)

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return WoWTools_HyperLink:Save().iconSize or 0
        end, setValue=function(value)
            WoWTools_HyperLink:Save().iconSize=value
            WoWTools_HyperLink:Link_Icon_Settings()
        end,
        name=WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
        minValue=0,
        maxValue=32,
        step=1,
        --bit='%.2f',
        tooltip=function(tooltip)
            local s= WoWTools_HyperLink:Save().iconSize or 0
            s= s<8 and 0 or s
            tooltip:AddLine('|T134414..:'..s..':'..s..'|t')
            if not WoWTools_HyperLink:Save().notShowItemCount then
                WoWTools_Print(select(2, C_Item.GetItemInfo(6948)), '')
            end
        end
    })
    sub:CreateSpacer()

    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.Language.key,
    function()
        return not WoWTools_HyperLink:Save().disabledKeyColor
    end, function()
        WoWTools_HyperLink:Save().disabledKeyColor= not WoWTools_HyperLink:Save().disabledKeyColor and true or nil
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.HyperLink.KeyColor'])

    sub2:CreateButton(
        (InCombatLockdown() and '|cff626262' or '')
        ..'|A:mechagon-projects:0:0|a'
        ..WoWTools_L['Set keywords'],
    function()
        WoWTools_PanelMixin:Open(nil, WoWTools_HyperLink.addName)--página del módulo en el Centro de control
        return MenuResponse.Open
    end)

    sub2= sub:CreateCheckbox(
        WoWTools_L.PLAYER_MESSAGES,
    function()
        return not WoWTools_HyperLink:Save().notShowPlayerInfo
    end, function()
        WoWTools_HyperLink:Save().notShowPlayerInfo= not WoWTools_HyperLink:Save().notShowPlayerInfo and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.HyperLink.PlayerInfo'])
        tooltip:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo('player', nil, nil, {reLink=true}), WoWTools_TextMixin:GetEnabeleDisable(true))
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine(WoWTools_ColorMixin:SetStringColor(UnitName('player')), WoWTools_TextMixin:GetEnabeleDisable(false))
    end)


    sub2= sub:CreateCheckbox(
        WoWTools_L['ITEMS+AUCTION_HOUSE_QUANTITY_LABEL'],
    function()
        return not WoWTools_HyperLink:Save().notShowItemCount
    end, function()
        WoWTools_HyperLink:Save().notShowItemCount= not WoWTools_HyperLink:Save().notShowItemCount and true or nil
        WoWTools_Print(select(2, C_Item.GetItemInfo(6948)), '')
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.HyperLink.ItemCount'])
        tooltip:AddLine(WoWTools_ItemMixin:GetCount(6948, {isWoW=true}), nil)
    end)


    sub2= sub:CreateCheckbox(
        WoWTools_L.MAP_PIN,
    function()
            return not WoWTools_HyperLink:Save().notShowMapPin
    end, function()
        WoWTools_HyperLink:Save().notShowMapPin= not WoWTools_HyperLink:Save().notShowMapPin and true or nil
        WoWTools_Print(WoWTools_DataMixin.Icon.icon2, '30.00 45.50')
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.HyperLink.MapPin'])
        tooltip:AddDoubleLine('[30.00 45.50]')
    end)


    sub:CreateDivider()
    sub2=sub:CreateCheckbox(
        (C_SocialRestrictions.IsChatDisabled() and '|cnWARNING_FONT_COLOR:' or '')
        ..(WoWTools_L.RESTRICT_CHAT_CONFIG_DISABLE),
    function()
       return C_SocialRestrictions.IsChatDisabled()
    end, function()
        if not WoWTools_FrameMixin:IsLocked(SettingsPanel) then
            Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID, RESTRICT_CHAT_CONFIG_DISABLE)--ItemRef.lua
        end
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function (tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.HyperLink.ChatDisabled'])
        tooltip:AddLine(WoWTools_L.SETTINGS_TITLE)
        tooltip:AddLine(WoWTools_L.SOCIALS)
    end)


    col= isInBat and '|cff828282' or (
            not C_CVar.GetCVarBool('Sound_EnableAllSound')
            or C_CVar.GetCVar('Sound_MasterVolume')=='0'
            or C_CVar.GetCVar('Sound_DialogVolume')=='0'
            or not C_CVar.GetCVarBool('Sound_EnableDialog')
            or InCombatLockdown()
        ) and '|cff626262' or ''

    sub=root:CreateCheckbox(
        col
        ..'|A:chatframe-button-icon-voicechat:0:0|a'
        ..(WoWTools_L['EVENTS_LABEL+SOUND']),
    function()
        return WoWTools_HyperLink:Save().setPlayerSound
    end, function()
        WoWTools_HyperLink:Save().setPlayerSound= not WoWTools_HyperLink:Save().setPlayerSound and true or nil

        if WoWTools_HyperLink:Save().setPlayerSound then
            WoWTools_DataMixin:PlaySound()
        end

        WoWTools_HyperLink:Init_Event_Sound()
    end)

    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.HyperLink.EventSound'])
        tooltip:AddLine(WoWTools_L.SLASH_STOPWATCH_PARAM_PLAY1)
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_DataMixin:Get_CVar_Tooltips({name='Sound_EnableAllSound', msg=WoWTools_L.ENABLE_SOUND}))
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_DataMixin:Get_CVar_Tooltips({name='Sound_MasterVolume', msg=WoWTools_L.MASTER_VOLUME}))
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_DataMixin:Get_CVar_Tooltips({name='Sound_DialogVolume', msg=WoWTools_L.DIALOG_VOLUME}))
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_DataMixin:Get_CVar_Tooltips({name='Sound_EnableDialog', msg=WoWTools_L['ENABLE_DIALOG~2'] }))
    end)

    sub2=sub:CreateButton(
        col..(WoWTools_L.AUDIO_LABEL),
    function()
        if not WoWTools_FrameMixin:IsLocked(SettingsPanel) then
            Settings.OpenToCategory(Settings.AUDIO_CATEGORY_ID)--ItemRef.lua
        end
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_L.OPTIONS)
    end)



    WoWTools_MenuMixin:TTsMenu(root)
    root:CreateDivider()

    --WoWTools_HyperLink:EmojiButton_Menu(self, root)

    root:CreateButton(
        '|A:colorblind-colorwheel:0:0|a'..(WoWTools_L.COLOR_PICKER),
    function()
        if ColorPickerFrame:IsShown() then
            ColorPickerFrame:Hide()
        else
            WoWTools_ColorMixin:ShowColorFrame(nil, nil, nil, 1)
        end
        return MenuResponse.Open
    end)



    root:CreateDivider()

--/reload
    sub=WoWTools_MenuMixin:Reload(root, false)

    sub2=sub:CreateCheckbox(
        WoWTools_L['Add button'],
    function ()
        return not WoWTools_HyperLink:Save().not_Add_Reload_Button
    end, function ()
        WoWTools_HyperLink:Save().not_Add_Reload_Button= not WoWTools_HyperLink:Save().not_Add_Reload_Button and true or nil
        if not WoWTools_HyperLink:Save().not_Add_Reload_Button then
            WoWTools_Print(
                WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_L.REQUIRES_RELOAD
            )
        end
    end)
    sub2:SetTooltip(function (tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.HyperLink.ReloadButton'])
        tooltip:AddLine(WoWTools_L.ADD)
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_L.MAINMENU_BUTTON)
        tooltip:AddLine(WoWTools_L.OPTIONS)
    end)

    root:CreateDivider()
    WoWTools_ChatMixin:Open_SettingsPanel(root, WoWTools_HyperLink.addName)
end


function WoWTools_HyperLink:Init_Menu()
    WoWTools_ChatMixin:GetButtonForName('HyperLink'):SetupMenu(Init_Menu)
end