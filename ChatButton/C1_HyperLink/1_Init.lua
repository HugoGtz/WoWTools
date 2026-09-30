local P_Save={

    linkIcon=true, --超链接，图标
    --notShowPlayerInfo=true,--不处理，玩家信息
    showCVarName=nil,

    channels={--频道名称替换 
        --['世界'] = '[世]',
    },
    disabledKeyColor= true,--禁用，内容颜色，和频道名称替换

    --groupWelcomeText= WoWTools_DataMixin.Player.IsCN and '{rt1}欢迎{rt1}' or '{rt1}Hi{rt1}',

    --guildWelcomeText= WoWTools_DataMixin.Player.IsCN and '宝贝，欢迎你加入' or EMOTE103_CMD1:gsub('/',''),

    welcomeOnlyHomeGroup=true,--仅限, 手动组队

    Cvar={},
    --disabledNPCTalking=true,--禁用，隐藏NPC发言    

    not_Add_Reload_Button= true,--添加 RELOAD 按钮
    autoHideTableAttributeDisplay=true,--自动关闭，Fstack

    --hideEventTracePlus=true 隐藏 EventTrace Plus
    --eventTracePrint 事件输出

    showCopyChatButton=true,--显示 复制聊天 按钮
    --copyChatSetText=nil,--处理，文本

}

local function Save()
    return WoWToolsPlusSave['ChatButton_HyperLink'] or {}
end


local function Init()
    local btn= WoWTools_ChatMixin:GetButtonForName('HyperLink')
    WoWTools_HyperLink:Init_EventTrace()
    WoWTools_HyperLink:Blizzard_Settings()
    WoWTools_HyperLink:Init_Menu()

    btn.eventSoundTexture= btn:CreateTexture(nil,'OVERLAY')
    btn.eventSoundTexture:SetPoint('BOTTOMLEFT',4, 4)
    btn.eventSoundTexture:SetSize(12,12)
    btn.eventSoundTexture:SetAtlas('chatframe-button-icon-voicechat')

    function btn:set_tooltip()
        local isDisabled= C_SocialRestrictions.IsChatDisabled()
        GameTooltip:AddDoubleLine(WoWTools_HyperLink.addName, WoWTools_TextMixin:GetEnabeleDisable(not isDisabled and Save().linkIcon))
        if isDisabled then
            GameTooltip:AddDoubleLine('|cnWARNING_FONT_COLOR:' ..(WoWTools_L.RESTRICT_CHAT_CONFIG_DISABLE), WoWTools_TextMixin:GetEnabeleDisable(true))
        end
        GameTooltip:Show()
    end

    function btn:set_OnMouseDown()
        Save().linkIcon= not Save().linkIcon and true or false
        WoWTools_HyperLink:Init_Link_Icon()
        local isDisabled= C_SocialRestrictions.IsChatDisabled()
        WoWTools_Print(
            WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_TextMixin:GetEnabeleDisable(not isDisabled and Save().linkIcon)
        )
        if Save().linkIcon and isDisabled and not WoWTools_FrameMixin:IsLocked(SettingsPanel) then
            Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID)--ItemRef.lua
        end
    end

    WoWTools_HyperLink:Init_Link_Icon()--超链接，图标
    WoWTools_HyperLink:Init_Event_Sound()--播放, 事件声音

--聊天频道，名称 增强
    WoWTools_DataMixin:Hook(ChannelRosterButtonMixin, 'UpdateName', function(self)
        if self:IsLocalPlayer() then
            local region= WoWTools_RealmMixin:Get_Region(WoWTools_DataMixin.Player.Realm)
            self.Name:SetText(
                (region and region.col or '')
                ..'|A:recipetoast-icon-star:0:0|a'
                ..(WoWTools_L.COMBATLOG_FILTER_STRING_ME)
            )
        else
            local guid
            if canaccessvalue(self.playerLocation) and self.playerLocation then
                guid=self.playerLocation:GetGUID()
            end
            local name= self:GetMemberName()
            if canaccessvalue(name) and name then
                local t=''
--欧美，服务器语言
                local region= WoWTools_RealmMixin:Get_Region(name:match('%-(.+)') or '', guid)
                if region then
                    t= t..region.col
                end
--种族
                t= t..(WoWTools_UnitMixin:GetRaceIcon(nil, guid) or '')
--职业
                t= t..(WoWTools_UnitMixin:GetClassIcon(nil, guid) or '')
--等级
                local data= WoWTools_DataMixin.PlayerInfo[guid]
                if data then
--专精
                    if data.specID then
                        t= t..'|T'..(select(4, GetSpecializationInfoByID(data.specID)) or 0)..':0|t'
                    end
--装等
                    if data.itemLevel then
                        t= t..'|cnGREEN_FONT_COLOR:[|r|cffffffff'..data.itemLevel..'|r|cnGREEN_FONT_COLOR:]|r'
                    end
                end
--处理，服务器名称
                if name:find('%-') then
                    if name:find('%-'..WoWTools_DataMixin.Player.Realm) then
                        t= t..name:gsub('%-'..WoWTools_DataMixin.Player.Realm, '')
                    elseif C_PlayerInfo.UnitIsSameServer(self.playerLocation) then
                        t= t..name..'|cnGREEN_FONT_COLOR:*|r'
                    end
                else
                    t= t..name
                end

                self.Name:SetText(t)
            end
        end
    end)

    Init=function()end
end


local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')

panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['ChatButton_HyperLink']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['ChatButton_HyperLink'], P_Save)
            P_Save=nil

            Save().disabledTalkingPringText= nil
            WoWToolsPlusSave['ChatButton_Markers']= nil--12.0不能用了

            WoWToolsPlusPlayerDate['HyperLinkColorText']= WoWToolsPlusPlayerDate['HyperLinkColorText'] or {[ACHIEVEMENTS]=true}
            WoWToolsPlusPlayerDate['HyperLinkGuildWelcomeText']= WoWToolsPlusPlayerDate['HyperLinkGuildWelcomeText'] or (WoWTools_DataMixin.Player.IsCN and '欢迎' or EMOTE103_CMD1:gsub('/',''))
            WoWToolsPlusPlayerDate['HyperLinkGroupWelcomeText']= WoWToolsPlusPlayerDate['HyperLinkGroupWelcomeText'] or (WoWTools_DataMixin.Player.IsCN and '{rt1}欢迎{rt1}' or '{rt1}Hi{rt1}')

            WoWTools_HyperLink.addName= '|A:voicechat-icon-STT-on:0:0|a'..(WoWTools_L['COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK+EMBLEM_SYMBOL'])


            if WoWTools_ChatMixin:CreateButton('HyperLink', WoWTools_HyperLink.addName) then
                Init()
                self:RegisterEvent('PLAYER_ENTERING_WORLD')--需要这个，表情，中文化，需要这个
            else

                self:SetScript('OnEvent', nil)
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        --WoWTools_HyperLink:Init_NPC_Talking()--隐藏NPC发言
        WoWTools_HyperLink:Init_Reload()--添加 RELOAD 按钮
        --WoWTools_HyperLink:Init_EmojiButton()
        --WoWTools_HyperLink:Init_CopyChat()
    end
end)

