


local function Set_Sctipt(object)
    object:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    object:SetScript('OnEnter', function(self)
        self:SetAlpha(0.3)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip_SetTitle(GameTooltip, WoWTools_DataMixin.Icon.icon2..self.tooltip)
        GameTooltip:Show()
    end)
end



local function Create_Texture(btn)
    if btn.allText then
        return
    end

    btn.allText= WoWTools_LabelMixin:Create(btn)--, {color=true})
    btn.allText:SetPoint('TOPLEFT', btn.Icon, 'BOTTOMLEFT')
    btn.allText.tooltip= (WoWTools_L.CLUB_FINDER_SORT_BY_MOST_MEMBERS)
                ..'|n'..(WoWTools_L.GUILD_MEMBERS_ONLINE)
                ..'|n'..(WoWTools_L.GUILDCONTROL_GUILDRANKS)
    Set_Sctipt(btn.allText)


    btn.inviteTexture= btn:CreateTexture(nil, 'BORDER',nil, 2)
    btn.inviteTexture:SetPoint('RIGHT',-6,0)
    btn.inviteTexture:SetSize(20,20)
    btn.inviteTexture:SetAtlas('communities-icon-invitemail')
    btn.inviteTexture.tooltip= WoWTools_L.CLUB_FINDER_APPLICANTS
    Set_Sctipt(btn.inviteTexture)

    btn.msgTexture= btn:CreateTexture(nil, 'BORDER', nil, 2)
    btn.msgTexture:SetPoint('RIGHT',-6,-20)
    btn.msgTexture:SetSize(20,20)
    btn.msgTexture:SetAtlas('communities-icon-notification')
    btn.msgTexture.tooltip= WoWTools_L.COMMUNITIES_CHAT_FRAME_UNREAD_MESSAGES_NOTIFICATION
    Set_Sctipt(btn.msgTexture)

    btn.factionTexture= btn:CreateTexture(nil, 'BORDER', nil, 2)
    btn.factionTexture:SetPoint('RIGHT',-6,20)
    btn.factionTexture:SetSize(20,20)
    btn.factionTexture:SetAtlas('CrossedFlags')
    btn.factionTexture.tooltip= WoWTools_L.COMMUNITIES_EDIT_DIALOG_CROSS_FACTION
    Set_Sctipt(btn.factionTexture)

end



--local COMMUNITIES_DELETE_CONFIRM_STRING= COMMUNITIES_DELETE_CONFIRM_STRING
local function Init()
    WoWTools_DataMixin:Hook(CommunitiesListEntryMixin, 'Init', function(btn, elementData)
        local clubID= btn.clubId

        local hasInvite, hasMessage, faction, text

        if canaccessvalue(clubID) and clubID
            and canaccesstable(elementData)
            and elementData
            and canaccesstable(elementData.clubInfo)
            and elementData.clubInfo
            and canaccessvalue(elementData.clubInfo.crossFaction)
        then
            Create_Texture(btn)

            local online, all= WoWTools_GuildMixin:GetNumOnline(clubID)
            if online and all then
                text= online..'/'..all
            end
            local info = C_Club.GetMemberInfoForSelf(clubID)
            if info and info.guildRank then
                text= (text and text..' ' or '')..info.guildRank
            end

            hasInvite=  WoWTools_GuildMixin:GetApplicantList(clubID) and true or false
            hasMessage= WoWTools_GuildMixin:DoesCommunityHaveUnreadMessages(clubID)
            --faction= elementData.clubInfo.crossFaction and 'CrossedFlags' or false
            faction= elementData.clubInfo.crossFaction and true or false

            btn.allText:SetTextColor(btn.Name:GetTextColor())
        end
        if btn.allText then
            btn.allText:SetText(text or '' )
            btn.inviteTexture:SetShown(hasInvite)
            btn.msgTexture:SetShown(hasMessage)
            btn.factionTexture:SetShown(faction)
        end
    end)



    Init=function()end
end




function WoWTools_GuildMixin:Plus_CommunitiesFrame()
    Init()
end