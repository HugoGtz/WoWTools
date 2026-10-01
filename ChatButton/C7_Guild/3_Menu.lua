
local function Get_Guild_Name()
    local clubID= C_Club.GetGuildClubId()
    local clubInfo = canaccessvalue(clubID) and clubID and C_Club.GetClubInfo(clubID) or {}--C_Club.GetClubInfo(clubID) C_ClubFinder.GetRecruitingClubInfoFromClubID() ClubFinderGetCurrentClubListingInfo(guildClubId)
    local guildName, guildRankName, guildRankIndex, realm= GetGuildInfo('player')
    local canGuildInvite= CanGuildInvite()
    local findDay= canGuildInvite and WoWTools_GuildMixin:GetClubFindDay(clubID)

    local name= (guildName or (canaccessvalue(clubInfo.name) and clubInfo.name) or (WoWTools_L['LFG_LIST_GUILD_MEMBER~2']))
        ..(realm and (
            WoWTools_DataMixin.Player[realm] and '|cnGREEN_FONT_COLOR:*|r' or '-'..realm
        ) or '')

    name= WoWTools_TextMixin:sub(name, WoWTools_GuildMixin:Save().subGuildName, nil, nil)

    return (canaccessvalue(clubInfo.isCrossFaction) and '|A:'..(clubInfo.isCrossFaction and 'CrossedFlags' or WoWTools_DataMixin.Icon[WoWTools_DataMixin.Player.Faction])..':0:0|a' or '')
    ..(canGuildInvite and '|cff00ccff' or '|cff828282')
    ..WoWTools_GuildMixin:Get_Rank_Texture(guildRankIndex, false)
    ..(name)
    ..'|r'
    ..(guildRankName and guildRankIndex and guildRankIndex>1 and ' '.. guildRankName or '')
    ..(findDay and ' '..format(WoWTools_L.CLUB_FINDER_DAYS_UNTIL_EXPIRE , findDay) or '')
end










local function Init_Guild_Menu(self, root)
    local sub, sub2


    sub= root:CreateButton(
        Get_Guild_Name(),
    function()
        WoWTools_ChatMixin:Chat(WoWTools_GuildMixin:GetClubLink(),
            nil,
            ChatEdit_GetActiveWindow() and true or false
        )
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        local clubID= C_Club.GetGuildClubId()
        local clubInfo = clubID and C_Club.GetClubInfo(clubID)
        if not canaccesstable(clubInfo) or not clubInfo
            or not canaccessvalue(clubID) or not clubID
            or not canaccessvalue(clubInfo.isCrossFaction) then
            return
        end

        local canGuildInvite= CanGuildInvite()
        local findDay= canGuildInvite and clubID and WoWTools_GuildMixin:GetClubFindDay(clubID)

        if clubInfo.description and clubInfo.description~='' then
            tooltip:AddLine(clubInfo.description, nil, nil, nil,true)
            tooltip:AddLine(' ')
        end

        tooltip:AddDoubleLine(
            '|A:'..(clubInfo.isCrossFaction and 'CrossedFlags' or WoWTools_DataMixin.Icon[WoWTools_DataMixin.Player.Faction])..':0:0|a'
            ..(WoWTools_L.COMMUNITIES_EDIT_DIALOG_CROSS_FACTION),
            WoWTools_TextMixin:GetYesNo(clubInfo.isCrossFaction)
        )

        if findDay then
            tooltip:AddDoubleLine(
                '|A:characterupdate_clock-icon:0:0|a'
                ..(WoWTools_L.GUILD_FINDER_POSTING_GOING_TO_EXPIRE),
                format(WoWTools_L.CLUB_FINDER_DAYS_UNTIL_EXPIRE , findDay)
            )
        end

        tooltip:AddDoubleLine('clubID', clubID)

        if WoWTools_GuildMixin:GetClubLink(clubID) then--11.1.5
            tooltip:AddLine(' ')
            tooltip:AddDoubleLine('|cff00ccff'..(WoWTools_L.CLUB_FINDER_LINK_POST_IN_CHAT), WoWTools_DataMixin.Icon.left)
        end

        if not canGuildInvite then
            tooltip:AddLine(
                '|cff828282'
                ..WoWTools_L['Cannot invite members']..'|r'
            )
        end
    end)





    sub2=sub:CreateCheckbox(
        WoWTools_L['SHOW+GUILD_TAB_ROSTER'],
    function()
        return WoWTools_GuildMixin:Save().showListName
    end, function()
        WoWTools_GuildMixin:Save().showListName= not WoWTools_GuildMixin:Save().showListName and true or nil
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Guild.ShowList'])
    sub2= sub:CreateCheckbox(
        WoWTools_L.COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE,
    function()
        return WoWTools_GuildMixin:Save().showNotOnLine
    end, function()
        WoWTools_GuildMixin:Save().showNotOnLine= not WoWTools_GuildMixin:Save().showNotOnLine and true or nil
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Guild.ShowOffline'])



    sub:CreateSpacer()
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return WoWTools_GuildMixin:Save().subGuildName or 0
        end, setValue=function(value, frame)
            WoWTools_GuildMixin:Save().subGuildName= value~=0 and value or nil
            frame.Low:SetText(Get_Guild_Name())
        end,
        name=WoWTools_L['Truncate'] ,
        minValue=0,
        maxValue=93,
        step=1,
        tooltip=function(tooltip)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Guild.Truncate'])
            tooltip:AddLine(WoWTools_L.CLUB_FINDER_REPORT_REASON_GUILD_NAME)
            tooltip:AddLine('0 = '..(WoWTools_L.DISABLE))
        end
    })
    sub:CreateSpacer()
end


















local function WoW_List(_, root)
    local sub, sub2

    sub=root:CreateButton(
        WoWTools_DataMixin.Icon.net2..MicroButtonTooltipText(WoWTools_L.COMMUNITIES_FRAME_TITLE, "TOGGLEGUILDTAB"),
    function()
        ToggleGuildFrame()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_L.BINDING_NAME_TOGGLEGUILDTAB)
    end)


    local name, realm, rankIndex, rankName
    for guid, info in pairs(WoWToolsPlus_WoWDate) do
        if info.Guild and info.Guild.link and info.Guild.clubID and guid~=WoWTools_DataMixin.Player.GUID then

            C_ClubFinder.RequestPostingInformationFromClubId(info.Guild.clubID)

            name= info.Guild.data[1]
            rankName= info.Guild.data[2]
            rankIndex= info.Guild.data[3]
            realm= info.Guild.data[4]

            sub2= sub:CreateButton(
                WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=false})
                ..' '
                ..WoWTools_GuildMixin:Get_Rank_Texture(rankIndex, true)
                ..name
                ..(realm and realm~=WoWTools_DataMixin.Player.Realm
                    and (WoWTools_DataMixin.Player.Realms[realm] and '|cnGREEN_FONT_COLOR:-|r' or '|cnWARNING_FONT_COLOR:-|r')..realm
                    or ''
                ),
            function(data)
                WoWTools_ChatMixin:Chat(data.link, nil, ChatEdit_GetActiveWindow() and true or false)
                return MenuResponse.Open
            end, {
                link= info.Guild.link,
                name= name,
                rankName= rankName,
                rankIndex= rankIndex,
                realm= realm,
                text= info.Guild.text,
                playerGuid= guid,
                guid= info.Guild.guid,
            })

            sub2:SetTooltip(function(tooltip, desc)
                local data= desc.data.guid and C_ClubFinder.GetRecruitingClubInfoFromFinderGUID(desc.data.guid) or {}

                tooltip:AddDoubleLine(
                    '|A:'..(data.isCrossFaction and 'CrossedFlags' or WoWTools_DataMixin.Icon[WoWTools_DataMixin.Player.Faction])..':0:0|a'
                    ..'|T'..(data.tabardInfo and data.tabardInfo.emblemFileID or 0)..':0|t'
                    ..(desc.data.name or data.name),
                    WoWTools_UnitMixin:GetPlayerInfo(nil, data.lastPosterGUID, nil, {reName=true, reRealm=false})--data.lastPosterGUID
                )
                if desc.data.realm then
                    tooltip:AddLine(
                        (WoWTools_DataMixin.Player.Realms[desc.data.realm] and '|cnGREEN_FONT_COLOR:' or '|cffff00ff')
                        ..desc.data.realm
                    )
                end
                tooltip:AddLine(desc.data.text)
                tooltip:AddLine(' ')
                if desc.data.playerGuid~= data.lastPosterGUID then
                    tooltip:AddLine( WoWTools_UnitMixin:GetPlayerInfo(nil, desc.data.playerGuid, nil, {reName=true, reRealm=true}))
                end
                tooltip:AddLine(
                    WoWTools_GuildMixin:Get_Rank_Texture(desc.data.rankIndex, true)
                    ..desc.data.rankName
                )


                tooltip:AddDoubleLine(WoWTools_L.CLUB_FINDER_SORT_BY_MOST_MEMBERS, data.numActiveMembers)

                tooltip:AddDoubleLine(
                    '|A:'..(data.isCrossFaction and 'CrossedFlags' or WoWTools_DataMixin.Icon[WoWTools_DataMixin.Player.Faction])..':0:0|a'
                    ..(WoWTools_L.COMMUNITIES_EDIT_DIALOG_CROSS_FACTION),
                    WoWTools_TextMixin:GetYesNo(data.isCrossFaction)
                )


                tooltip:AddLine(' ')
                tooltip:AddDoubleLine('|cff00ccff'..(WoWTools_L.CLUB_FINDER_LINK_POST_IN_CHAT), WoWTools_DataMixin.Icon.left)
            end)
        end
    end

    WoWTools_MenuMixin:SetScrollMode(sub)
end


















local function Guild_Player_List(_, root)
    if not WoWTools_GuildMixin:Save().showListName then
        return
    end

    local total, online = GetNumGuildMembers()
    local showNotOnLine= WoWTools_GuildMixin:Save().showNotOnLine

    root:CreateDivider()
    if total<2 or (online<2 and not showNotOnLine) then
        root:CreateTitle(
            (WoWTools_L.GUILD_MEMBERS_ONLINE_COLON)..(online-1)
        )
        return
    end

    local sub
    C_GuildInfo.GuildRoster()

    local map=WoWTools_MapMixin:GetUnit('player')
    local maxLevel= GetMaxLevelForLatestExpansion()
    local name, rankName, rankIndex, level, zone, publicNote, officerNote, isOnline, status, guid, _

    for index=1, total, 1 do
        name, rankName, rankIndex, level, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
        if name and guid and (isOnline or showNotOnLine) and guid~=WoWTools_DataMixin.Player.GUID then
            publicNote= publicNote~='' and publicNote or nil
            officerNote= officerNote~='' and officerNote or nil
            sub=root:CreateButton(
                (
                    status==1 and format('|T%s:0|t', FRIENDS_TEXTURE_AFK)
                    or (status==2 and format('|T%s:0|t', FRIENDS_TEXTURE_DND))
                    or (not isOnline and format('|T%s:0|t', FRIENDS_TEXTURE_OFFLINE))
                    or (isOnline and showNotOnLine and format('|T%s:0|t', FRIENDS_TEXTURE_ONLINE))
                    or '  '
                )
                ..WoWTools_GuildMixin:Get_Rank_Texture(rankIndex)
                ..WoWTools_UnitMixin:GetPlayerInfo(nil, guid, name, {reName=true, reRealm=true})
                ..(level and level~=maxLevel and ' |cnGREEN_FONT_COLOR:'..level..'|r' or '')
                ..(isOnline and zone and (zone==map and '|A:poi-islands-table:0:0|a' or WoWTools_TextMixin:CN(zone)) or '')
                ..((publicNote or officerNote) and '|A:QuestLegendary:0:0|a' or ''),


            function(data)
                WoWTools_ChatMixin:Say(nil, data.name)
                return MenuResponse.Open
            end, {
                publicNote=publicNote,
                officerNote=officerNote,
                name=name,
                rankName=rankName,
                rankIndex=rankIndex,
                zone=zone,
                isOnline=isOnline,
            })
            sub:SetTooltip(function(tooltip, desc)
                local col= desc.data.isOnline and '' or '|cff828282'
                tooltip:AddDoubleLine(
                    col..(WoWTools_L.SLASH_TEXTTOSPEECH_WHISPER),
                    col..SLASH_WHISPER1..' '..desc.data.name
                )
                tooltip:AddLine(' ')
                tooltip:AddDoubleLine(
                    desc.data.zone,
                    WoWTools_GuildMixin:Get_Rank_Texture(desc.data.rankIndex)..(desc.data.rankName or '').. (desc.data.rankIndex and ' '..desc.data.rankIndex)
                )

                if desc.data.publicNote then
                    tooltip:AddLine(' ')
                    tooltip:AddLine(desc.data.publicNote, nil,nil,nil, true)
                end

                if desc.data.officerNote then
                    tooltip:AddLine(' ')
                    tooltip:AddLine(desc.data.officerNote, nil,nil,nil,true)
                end
            end)
        end
    end
    WoWTools_MenuMixin:SetScrollMode(root)
end











local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub

    if not IsInGuild() then
        WoW_List(self, root)
        return
    end

    if CanReplaceGuildMaster() then
        root:CreateButton(
            WoWTools_L.GUILD_IMPEACH_POPUP_CONFIRM,
        ToggleGuildFrame)
        root:CreateDivider()
    end

    Init_Guild_Menu(self, root)

    WoW_List(self, root)

    if CanReplaceGuildMaster() then
        root:CreateDivider()
        sub=root:CreateButton(
            WoWTools_L.GUILD_IMPEACH_POPUP_CONFIRM,
        ToggleGuildFrame)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_L.GUILD_IMPEACH_POPUP_TEXT, nil,nil,nil, true)
        end)
    end

    Guild_Player_List(self, root)
end




function WoWTools_GuildMixin:Init_Menu()
    WoWTools_ChatMixin:GetButtonForName('Guild'):SetupMenu(Init_Menu)
end