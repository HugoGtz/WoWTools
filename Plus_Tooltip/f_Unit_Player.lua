

function WoWTools_TooltipMixin:Set_Unit_Player(tooltip, name, unit, guid)
    if self:IsInCombatDisabled(tooltip)
        --or not WoWTools_UnitMixin:UnitExists(unit)
        or not canaccessvalue(name)
        or not canaccessvalue(unit)
        or not canaccessvalue(guid)
    then
        return
    end

    local realm= select(2, UnitName(unit)) or WoWTools_DataMixin.Player.Realm
    local isPlayer = UnitIsPlayer(unit)
    local isSelf= WoWTools_UnitMixin:UnitIsUnit('player', unit)
    local isGroupPlayer= (not isSelf and WoWTools_DataMixin.GroupGuid[guid]) and true or nil

    local color= WoWTools_UnitMixin:GetColor(unit, guid)

    local isInCombat= InCombatLockdown()
    local englishFaction = isPlayer and UnitFactionGroup(unit)
    local textLeft, text2Left, textRight, text2Right='', '', '', ''
    local tooltipName=tooltip:GetName() or 'GameTooltip'

    local size= ':'..self.iconSize..':0'..self.iconSize

    guid= guid or UnitGUID(unit)

    tooltip.Portrait:SetAtlas(WoWTools_DataMixin.Icon[englishFaction] or 'Neutral')
    --tooltip.Portrait:SetShown(true)

    local data= WoWTools_DataMixin.PlayerInfo[guid]
    if data then

        textLeft= data.itemLevel

        if data.specID then
            local icon, role= select(4, GetSpecializationInfoByID(data.specID))
            if icon then
                text2Left= '|T'..icon..':0|t'..(WoWTools_DataMixin.Icon[role] or '')
            end
        end
    else
        WoWTools_UnitMixin:GetNotifyInspect(nil, unit)
    end

    tooltip:Set_BG_Color(color, 0.2)


    local isWarModeDesired= C_PvP.IsWarModeDesired()
    local statusIcon, statusText= WoWTools_UnitMixin:GetOnlineInfo(unit)
    if statusIcon and statusText then
        textLeft= textLeft..statusIcon..statusText

    elseif isGroupPlayer then
        local reason=UnitPhaseReason(unit)
        if reason then
            if reason==0 then
                textLeft= (WoWTools_L['Different phase'])..textLeft
            elseif reason==1 then
                textLeft= format(WoWTools_L['Not in the same layer %s'], WoWTools_DataMixin.Player.layer or '')..textLeft
            elseif reason==2 then
                textLeft= (isWarModeDesired and (WoWTools_L.ERR_PVP_WARMODE_TOGGLE_OFF) or (WoWTools_L.ERR_PVP_WARMODE_TOGGLE_ON))..textLeft
            elseif reason==3 then
                textLeft= (WoWTools_L.PLAYER_DIFFICULTY_TIMEWALKER)..textLeft
            end
        end
    end
    if select(2, IsInInstance())=='none' and UnitHasLFGRandomCooldown(unit) then
        text2Left= text2Left..'|T236347:0|t'
    end

    if isSelf then
        C_WowTokenPublic.UpdateMarketPrice()
        local price= C_WowTokenPublic.GetCurrentMarketPrice()
        if price and price>0 then
            local all, numPlayer= WoWTools_ItemMixin:GetWoWCount(122284, nil, true)
            text2Right= all
                ..(numPlayer>1 and '('..numPlayer..')' or '')
                ..'|A:token-choice-wow:0:0|a '
                ..WoWTools_DataMixin:MK(price/10000,1)
                ..'|A:Front-Gold-Icon:0:0|a'
        end

        local titleID= GetCurrentTitle()
        if titleID and titleID>0 then
            local titleName= GetTitleName(titleID)
            textRight= WoWTools_TextMixin:CN(titleName)--, {titleID= titleID})
            if textRight then
                textRight= format(textRight, '')
            end
        end
    else

        local lineLeft1=_G[tooltipName..'TextLeft1']
        if lineLeft1 then
            local t= lineLeft1:GetText()
            if canaccessvalue(t) and t then
                if t:find('|A:') then
                    textRight= tooltip.textRight:GetText() or ''
                else
                    textRight= t:gsub(name, '')
                    textRight= textRight:gsub('-'..realm, '')
                end
            end
        end
    end

    tooltip.textLeft:SetText(textLeft)
    tooltip.text2Left:SetText(text2Left)
    tooltip.textRight:SetText(textRight)
    tooltip.text2Right:SetText(text2Right)

    tooltip.textLeft:SetTextColor(color:GetRGB())
    tooltip.text2Left:SetTextColor(color:GetRGB())
    tooltip.textRight:SetTextColor(color:GetRGB())
    tooltip.text2Right:SetTextColor(color:GetRGB())



    local lineLeft1=_G[tooltipName..'TextLeft1']
    if lineLeft1 then
        lineLeft1:SetText(
            '|A:common-icon-rotateright:0:0|a'
            ..(isSelf and '|A:auctionhouse-icon-favorite:0:0|a' or WoWTools_UnitMixin:GetIsFriendIcon(nil, guid, nil) or '')
            ..name
            ..'|A:common-icon-rotateleft:0:0|a'
        )
        local lineRight1= _G[tooltipName..'TextRight1']
        if lineRight1 then
            local region= WoWTools_RealmMixin:Get_Region(realm)
            lineRight1:SetText(realm
                ..(isSelf
                and '|A:auctionhouse-icon-favorite:0:0|a'
                or (realm==WoWTools_DataMixin.Player.Realm and '|A:common-icon-checkmark:0:0|a')
                or (WoWTools_DataMixin.Player.Realms[realm] and '|A:Adventures-Checkmark:0:0|a')
                or ''
            )
            ..(region and region.col or ''))
            lineRight1:SetShown(true)
        end
    end

    local isInGuild= IsPlayerInGuildFromGUID(guid)
    local lineLeft2= isInGuild and _G[tooltipName..'TextLeft2']
    if lineLeft2 then
        local guildName, guildRankName, guildRankIndex = GetGuildInfo(unit)

        --local lineRight2= _G[tooltipName..'TextRight2']
        if guildName then
            
            guildName= WoWTools_TextMixin:sub(guildName, 12, 24)
            local rank=''
            if guildRankIndex then
                guildRankName= WoWTools_TextMixin:sub(guildRankName, 4, 8)
                rank= guildRankIndex==0 and '|TInterface\\GroupFrame\\UI-Group-LeaderIcon:0|t'
                    or (guildRankIndex==1 and '|TInterface\\GroupFrame\\UI-Group-AssistantIcon:0|t')
                    or ('|A:MonkUI-LightOrb-small:0:0|a'..(guildRankName or guildRankIndex))
            end

            lineLeft2:SetText(
                '|A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a'
                ..guildName
                ..rank
            )

        else
            local text=lineLeft2:GetText()
            if canaccessvalue(text) and text and text~='' and not text:find('|A:') then--valor secreto (12.0)
                lineLeft2:SetText(
                    '|A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a'
                    ..(text:match('(.-)%-') or text)
                )
            end
        end
    end

    local lineLeft3= isInGuild and _G[tooltipName..'TextLeft3'] or _G[tooltipName..'TextLeft2']
    if lineLeft3 then
        local classFilename= select(2, UnitClass(unit))
        local sex = UnitSex(unit)
        local raceName, raceFile= UnitRace(unit)
        local level= UnitLevel(unit)
        local text= sex==2
                    and '|A:charactercreate-gendericon-male-selected'..size..'|a'
                    or ('|A:charactercreate-gendericon-female-selected'..size..'|a')

        if GetMaxLevelForLatestExpansion()==level then
            text= text.. level
        else
            text= text..'|cnGREEN_FONT_COLOR:'..level..'|r'
        end

        local effectiveLevel= UnitEffectiveLevel(unit)
        if effectiveLevel and effectiveLevel>0 and effectiveLevel~=level then
            text= text..'(|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r) '
        end

        local info= C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
        if info and info.currentSeasonScore and info.currentSeasonScore>0 then
            text= text..' '..(WoWTools_UnitMixin:GetRaceIcon(unit, guid, raceFile, {sex=sex, size=self.iconSize}) or '')
                    ..' '..WoWTools_UnitMixin:GetClassIcon(nil, nil, classFilename, {size=self.iconSize})
                    ..' '..(UnitIsPVP(unit) and  '|cnGREEN_FONT_COLOR:'..(WoWTools_L.PVP)..'|r' or (WoWTools_L.TRANSMOG_SET_PVE))
                    ..' |A:recipetoast-icon-star:0:0|a'..info.currentSeasonScore..'|r'

            if info.runs and info.runs then
                local bestRunLevel=0
                for _, run in pairs(info.runs) do
                    if run.bestRunLevel and run.bestRunLevel>bestRunLevel then
                        bestRunLevel=run.bestRunLevel
                    end
                end
                if bestRunLevel>0 then
                    text= text..' (|cnGREEN_FONT_COLOR:'..bestRunLevel..'|r)'
                end
            end
        else
            text= text..' '..(WoWTools_UnitMixin:GetRaceIcon(unit, guid, raceFile, {sex=sex, size=self.iconSize})  or '')
                    ..(WoWTools_TextMixin:CN(raceName) or WoWTools_TextMixin:CN(raceFile) or '')
                    ..' '..(WoWTools_UnitMixin:GetClassIcon(unit, guid, classFilename, {size=self.iconSize}) or '')
                    ..' '..(UnitIsPVP(unit) and '(|cnGREEN_FONT_COLOR:'..(WoWTools_L.TRANSMOG_SET_PVP)..'|r)' or ('('..(WoWTools_L.TRANSMOG_SET_PVE)..')'))
        end
        lineLeft3:SetText(text)

    end

    local hideLine
    local num= isInGuild and 4 or 3
    for i=1, tooltip:NumLines() or 0, 1 do
        local lineLeft=_G[tooltipName..'TextLeft'..i]
        if lineLeft then
            local show=true
            if i==num then
                if isSelf then
                    lineLeft:SetText(
                        WoWTools_DataMixin.Player.Layer
                        and WoWTools_DataMixin.Language.layer..WoWTools_DataMixin.Player.Layer
                        or ' '
                    )
                    local lineRight= _G[tooltipName..'TextRight'..i]
                    if lineRight then
                        if isWarModeDesired then
                            lineRight:SetText('|cnGREEN_FONT_COLOR:'..(WoWTools_L.PVP_LABEL_WAR_MODE))
                        else
                            lineRight:SetText(WoWTools_L.ERR_PVP_WARMODE_TOGGLE_OFF)
                        end
                        lineLeft:SetShown(true)
                    end
                elseif isGroupPlayer then
                    local mapID= C_Map.GetBestMapForUnit(unit)
                    if mapID then
                        local mapInfo= C_Map.GetMapInfo(mapID)
                        if mapInfo and mapInfo.name then
                            lineLeft:SetText('|A:poi-islands-table:0:0|a'..mapInfo.name)
                            lineLeft:SetShown(true)
                        end
                    end
                else
                    if not hideLine  then
                        hideLine=lineLeft
                    else
                        show=false
                    end
                end
            elseif i>num then

                if not hideLine then
                    hideLine=lineLeft
                else

                    show=false
                end
            end

            if show then
                lineLeft:SetTextColor(color:GetRGB())
                local lineRight= _G[tooltipName..'TextRight'..i]
                if lineRight and lineRight:IsShown()then
                    lineRight:SetTextColor(color:GetRGB())
                end
            else
                lineLeft:SetText('')
                lineLeft:SetShown(false)
                local lineRight= _G[tooltipName..'TextRight'..i]
                if lineRight then
                    lineRight:SetText('')
                    lineRight:SetShown(false)
                end
            end
        end
    end
    if isInCombat then
        if hideLine then
            hideLine:SetText('')
            hideLine:SetShown(false)
        end
    else
        self:Set_Web_Link(hideLine, {unitName=name, realm=realm, col=color:GenerateHexColorMarkup()})
    end

    if tooltip.StatusBar then
        tooltip.StatusBar:SetStatusBarColor(color:GetRGB())
    end

    self:Set_Item_Model(tooltip, {unit=unit, guid=guid})


    WoWTools_TooltipMixin:Show(tooltip)
    --if hideLine then
        --tooltip:Show()
    --end
end