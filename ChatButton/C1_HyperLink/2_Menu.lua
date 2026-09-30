local function Save()
    return WoWToolsPlusSave['ChatButton_HyperLink'] or {}
end


--主菜单
--#####
local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2, col
    local isInBat= InCombatLockdown()

--超链接图标
    sub= root:CreateCheckbox(
        (C_SocialRestrictions.IsChatDisabled() and '|cff828282' or '')
        ..WoWTools_HyperLink.addName,
    function()
        return Save().linkIcon
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

--图标尺寸
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().iconSize or 0
        end, setValue=function(value)
            Save().iconSize=value
            WoWTools_HyperLink:Link_Icon_Settings()
        end,
        name=WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
        minValue=0,
        maxValue=32,
        step=1,
        --bit='%.2f',
        tooltip=function(tooltip)
            local s= Save().iconSize or 0
            s= s<8 and 0 or s
            tooltip:AddLine('|T134414..:'..s..':'..s..'|t')
            if not Save().notShowItemCount then
                WoWTools_Print(select(2, C_Item.GetItemInfo(6948)), '')
            end
        end
    })
    sub:CreateSpacer()

--关键词, 内容颜色，和频道名称替换
    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.Language.key,
    function()
        return not Save().disabledKeyColor
    end, function()
        Save().disabledKeyColor= not Save().disabledKeyColor and true or nil
        for t in pairs(WoWToolsPlusPlayerDate['HyperLinkColorText']) do
            WoWTools_Print(t)
            break
        end
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.HyperLink.KeyColor'])

--设置关键词
    sub2:CreateButton(
        (InCombatLockdown() and '|cff626262' or '')
        ..'|A:mechagon-projects:0:0|a'
        ..WoWTools_L['Set keywords'],
    function()
        if not WoWTools_HyperLink.Category then
            WoWTools_PanelMixin:Open()
        end
        WoWTools_PanelMixin:Open(WoWTools_HyperLink.Category, WoWTools_HyperLink.addName)
        return MenuResponse.Open
    end)

--玩家信息
    sub2= sub:CreateCheckbox(
        WoWTools_L.PLAYER_MESSAGES,
    function()
        return not Save().notShowPlayerInfo
    end, function()
        Save().notShowPlayerInfo= not Save().notShowPlayerInfo and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.HyperLink.PlayerInfo'])
        tooltip:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo('player', nil, nil, {reLink=true}), WoWTools_TextMixin:GetEnabeleDisable(true))
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine(WoWTools_ColorMixin:SetStringColor(UnitName('player')), WoWTools_TextMixin:GetEnabeleDisable(false))
    end)


--物品数量
    sub2= sub:CreateCheckbox(
        WoWTools_L['ITEMS+AUCTION_HOUSE_QUANTITY_LABEL'],
    function()
        return not Save().notShowItemCount
    end, function()
        Save().notShowItemCount= not Save().notShowItemCount and true or nil
        WoWTools_Print(select(2, C_Item.GetItemInfo(6948)), '')
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.HyperLink.ItemCount'])
        tooltip:AddLine(WoWTools_ItemMixin:GetCount(6948, {isWoW=true}), nil)
    end)


--地图标记
    sub2= sub:CreateCheckbox(
        WoWTools_L.MAP_PIN,
    function()
            return not Save().notShowMapPin
    end, function()
        Save().notShowMapPin= not Save().notShowMapPin and true or nil
        WoWTools_Print(WoWTools_DataMixin.Icon.icon2, '30.00 45.50')
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.HyperLink.MapPin'])
        tooltip:AddDoubleLine('[30.00 45.50]')
    end)


    sub:CreateDivider()
--CVar 名称
    sub2=sub:CreateCheckbox(
        'CVar '..(WoWTools_L.LFG_LIST_TITLE ),
    function()
        return Save().showCVarName
    end, function()
        Save().showCVarName= not Save().showCVarName and true or nil
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.HyperLink.CVarName'])
    sub2= sub2:CreateButton(
        WoWTools_L['Test'],
    function()
        if InCombatLockdown() then
            return
        end
        local value= C_CVar.GetCVar('guildMemberNotify')
       if C_CVar.SetCVar('guildMemberNotify', value=='0' and '1' or '0') then
            C_Timer.After(0.3, function()
                C_CVar.SetCVar('guildMemberNotify', value)
            end)
        end
        return MenuResponse.Open
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.HyperLink.CVarTest'])

--关闭聊天
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


--事件声音
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
        return Save().setPlayerSound
    end, function()
        Save().setPlayerSound= not Save().setPlayerSound and true or nil

        if Save().setPlayerSound then
            WoWTools_DataMixin:PlaySound()--播放, 声音
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

--打开，音频
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



--文本转语音   
    WoWTools_MenuMixin:TTsMenu(root)
    root:CreateDivider()

--表情，按钮
    --WoWTools_HyperLink:EmojiButton_Menu(self, root)

--颜色选择器    
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


--etrace
    sub=root:CreateButton('|A:minimap-genericevent-hornicon:0:0|a|cffff00ffETR|rACE', function()
        if EventTrace and EventTrace:IsVisible() then
            EventTrace:Hide()
        else
            if not EventTrace then
                UIParentLoadAddOn("Blizzard_EventTrace")
            end
            EventTrace:Show()
        end

        return MenuResponse.Open
    end)

    sub2=sub:CreateCheckbox(
        'Plus',
    function()
        return not Save().hideEventTracePlus
    end, function()
        Save().hideEventTracePlus= not Save().hideEventTracePlus and true or nil
        WoWTools_HyperLink:Init_EventTrace()
        if Save().hideEventTracePlus then
            WoWTools_Print(
                WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_L.REQUIRES_RELOAD
            )
        end
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.HyperLink.EventTracePlus'])

    sub2=sub:CreateCheckbox(
        'Print',
    function()
        return Save().eventTracePrint
    end, function()
        Save().eventTracePrint= not Save().eventTracePrint and true or nil
        WoWTools_Print(
            WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
            Save().eventTracePrint and
                '|cnGREEN_FONT_COLOR:'..(WoWTools_L.START)
                or ('|cnWARNING_FONT_COLOR:'..(WoWTools_L['CLEAR_ALL~3']))
            )
        WoWTools_HyperLink:Init_EventTrace()
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.HyperLink.EventTracePrint'])

    local tab= WoWTools_HyperLink:Get_EventTrace_Print_Tab()
    local newTab={}
    for event, data in pairs(tab) do
        table.insert(newTab, {event= event, index= data.index, num=data.num, arg= data.arg})
    end

    if #newTab>0 then
        table.sort(newTab, function(a, b) return a.index> b.index end)

        sub:CreateDivider()
        for _, info in pairs(newTab) do
            sub2=sub:CreateButton(
                (select(2, math.modf((info.index-1)/2))==0 and '|cff10d3c8' or '|cffd3a21b')..info.index..') '
                ..info.event..' '..info.num,
            function(data)
                WoWTools_ChatMixin:Chat(data.event, nil, true)
                return MenuResponse.Open
            end, info)
            sub2:SetTooltip(function(tooltip, desc)
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..(WoWTools_L.CLUB_FINDER_LINK_POST_IN_CHAT)..WoWTools_DataMixin.Icon.left)
                for arg1, num in pairs(desc.data.arg) do
                    tooltip:AddDoubleLine(arg1, num)
                end
            end)
        end
        WoWTools_MenuMixin:SetScrollMode(sub)
    end



--fstack
    sub=root:CreateButton('|A:QuestLegendaryTurnin:0:0|a|cff00ff00FST|rACK', function ()
        if not C_AddOns.IsAddOnLoaded("Blizzard_DebugTools") then
            C_AddOns.LoadAddOn("Blizzard_DebugTools")
        end
        FrameStackTooltip_ToggleDefaults()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function (tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.HyperLink.FStack'])
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Alt|r '..(WoWTools_L.HUD_EDIT_MODE_SWITCH))
        tooltip:AddLine(' ')
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl|r '..(WoWTools_L.SHOW))
        tooltip:AddLine(' ')
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Shift|r '..(WoWTools_L['TEXTURES_SUBHEADER+INFO']))
        tooltip:AddLine(' ')
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+C|r '.. (WoWTools_L.CALENDAR_COPY_EVENT)..' \"File\" '..(WoWTools_L.TYPE))
    end)

    WoWTools_OtherMixin:OpenOption(sub, 'Plus')


--添加按钮
    root:CreateDivider()

--/reload
    sub=WoWTools_MenuMixin:Reload(root, false)

--添加按钮
    sub2=sub:CreateCheckbox(
        WoWTools_L['Add button'],
    function ()
        return not Save().not_Add_Reload_Button
    end, function ()
        Save().not_Add_Reload_Button= not Save().not_Add_Reload_Button and true or nil
        if not Save().not_Add_Reload_Button then
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
end


function WoWTools_HyperLink:Init_Menu()
    WoWTools_ChatMixin:GetButtonForName('HyperLink'):SetupMenu(Init_Menu)
end