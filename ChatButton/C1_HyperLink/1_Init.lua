local P_Save={

    linkIcon=true,

    channels={
    },
    disabledKeyColor= true,



    welcomeOnlyHomeGroup=true,

    Cvar={},

    not_Add_Reload_Button= true,
    autoHideTableAttributeDisplay=true,


    showCopyChatButton=true,

}

local Init= WoWTools_Once(function()
    local btn= WoWTools_ChatMixin:GetButtonForName('HyperLink')
    WoWTools_HyperLink:Blizzard_Settings()
    WoWTools_HyperLink:Init_Menu()

    btn.eventSoundTexture= btn:CreateTexture(nil,'OVERLAY')
    btn.eventSoundTexture:SetPoint('BOTTOMLEFT',4, 4)
    btn.eventSoundTexture:SetSize(12,12)
    btn.eventSoundTexture:SetAtlas('chatframe-button-icon-voicechat')

    function btn:set_tooltip()
        local isDisabled= C_SocialRestrictions.IsChatDisabled()
        GameTooltip:AddDoubleLine(WoWTools_HyperLink.addName, WoWTools_TextMixin:GetEnabeleDisable(not isDisabled and WoWTools_HyperLink:Save().linkIcon))
        if isDisabled then
            GameTooltip:AddDoubleLine('|cnWARNING_FONT_COLOR:' ..(WoWTools_L.RESTRICT_CHAT_CONFIG_DISABLE), WoWTools_TextMixin:GetEnabeleDisable(true))
        end
        GameTooltip:Show()
    end

    function btn:set_OnMouseDown()
        WoWTools_HyperLink:Save().linkIcon= not WoWTools_HyperLink:Save().linkIcon and true or false
        WoWTools_HyperLink:Init_Link_Icon()
        local isDisabled= C_SocialRestrictions.IsChatDisabled()
        WoWTools_Print(
            WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_TextMixin:GetEnabeleDisable(not isDisabled and WoWTools_HyperLink:Save().linkIcon)
        )
        if WoWTools_HyperLink:Save().linkIcon and isDisabled and not WoWTools_FrameMixin:IsLocked(SettingsPanel) then
            Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID)--ItemRef.lua
        end
    end

    WoWTools_HyperLink:Init_Link_Icon()
    WoWTools_HyperLink:Init_Event_Sound()

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
                local region= WoWTools_RealmMixin:Get_Region(name:match('%-(.+)') or '', guid)
                if region then
                    t= t..region.col
                end
                t= t..(WoWTools_UnitMixin:GetRaceIcon(nil, guid) or '')
                t= t..(WoWTools_UnitMixin:GetClassIcon(nil, guid) or '')
                local data= WoWTools_DataMixin.PlayerInfo[guid]
                if data then
                    if data.specID then
                        t= t..'|T'..(select(4, GetSpecializationInfoByID(data.specID)) or 0)..':0|t'
                    end
                    if data.itemLevel then
                        t= t..'|cnGREEN_FONT_COLOR:[|r|cffffffff'..data.itemLevel..'|r|cnGREEN_FONT_COLOR:]|r'
                    end
                end
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

end)


WoWTools_Module:Register({
    key= 'ChatButton_HyperLink', name= 'COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK+EMBLEM_SYMBOL', icon= 'voicechat-icon-STT-on',
    parent= 'ChatButton', defaults= P_Save, mixin= WoWTools_HyperLink,
    onEnable= function()
        WoWTools_HyperLink:Save().disabledTalkingPringText= nil
        WoWToolsPlusSave['ChatButton_Markers']= nil

        WoWToolsPlusPlayerDate['HyperLinkColorText']= WoWToolsPlusPlayerDate['HyperLinkColorText'] or {[ACHIEVEMENTS]=true}

        if WoWTools_ChatMixin:CreateButton('HyperLink', WoWTools_HyperLink.addName) then
            Init()
            --se queda escuchando: cada PLAYER_ENTERING_WORLD
            WoWTools_ChatMixin:OnEnterWorld(function()
                WoWTools_HyperLink:Init_Reload()
            end, true)
        end
    end,
})
