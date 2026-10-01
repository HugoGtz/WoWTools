
WoWTools_FactionMixin={}


local FactionAtlas={
    delve= 'delves-bountiful',
    prey= 'completiondialog-midnightcampaign-prey-icon',
}


function WoWTools_FactionMixin:GetInfo(factionID, toLeft)
    if not factionID or factionID<1 then
        return {}
    end

    local isMajor = C_Reputation.IsMajorFaction(factionID)
    local data= C_Reputation.GetFactionDataByID(factionID)

    if data then
        if data.isHeader and not data.isHeaderWithRep or not data.factionID then
            return {}
        end

    elseif not isMajor then
        return {}
    end

    local name, factionStandingtext, value, texture, atlas, barColor, isCapped, isUnlocked, expansionID, xp
    local toRight= not toLeft

    local friendshipID
    local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
    if repInfo and repInfo.friendshipFactionID and repInfo.friendshipFactionID> 0 then

        name= repInfo.name
        texture=repInfo.texture
        friendshipID= repInfo.friendshipFactionID
        isCapped= not repInfo.nextThreshold
        isUnlocked= true

        local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
        if rankInfo then
            factionStandingtext= rankInfo.currentLevel..'/'..rankInfo.maxLevel
        end

        if not isCapped then
            local currentExperience = repInfo.standing - repInfo.reactionThreshold
            local nextLevelAt = repInfo.nextThreshold - repInfo.reactionThreshold
            xp= nextLevelAt- currentExperience
            value= format('|A:GarrMission_CurrencyIcon-Xp:0:0|a%i%%', currentExperience/nextLevelAt*100)
        end

    elseif isMajor then
        local major = C_MajorFactions.GetMajorFactionData(factionID)
        if major then
            name= major.name
            factionStandingtext= (major.renownLevel or 0)..'/'..#C_MajorFactions.GetRenownLevels(factionID)
            isCapped=C_MajorFactions.HasMaximumRenown(factionID)
            isUnlocked= major.isUnlocked
            expansionID= major.expansionID

            if isUnlocked then
                if not isCapped then
                    xp= major.renownLevelThreshold- major.renownReputationEarned
                    value= format('|A:GarrMission_CurrencyIcon-Xp:0:0|a%i%%', major.renownReputationEarned/major.renownLevelThreshold*100)
                end
            else
                factionStandingtext= '|A:AdventureMapIcon-Lock:0:0|a'
            end

            if major.textureKit then

                if major.textureKit=='delve' then
                    atlas= 'delves-bountiful'
                else

                    atlas= FactionAtlas[major.textureKit] or format('majorFactions_icons_%s512', major.textureKit)
                end
            end

        else
            return {}
        end


    elseif data and data.reaction then
        name= data.name
        factionStandingtext= data.reaction..'/'..MAX_REPUTATION_REACTION
        isCapped= data.reaction == MAX_REPUTATION_REACTION--8
        isUnlocked= true

        if
            not isCapped
            and data.reaction
            and data.currentReactionThreshold
            and data.currentStanding
            and data.nextReactionThreshold
        then

            if data.nextReactionThreshold==0 then
                xp= data.currentReactionThreshold-data.currentStanding
                value= format('|A:GarrMission_CurrencyIcon-Xp:0:0|a%i%%', (data.currentReactionThreshold-data.currentStanding)/data.currentReactionThreshold*100)

            else
                xp= data.nextReactionThreshold- data.currentStanding
                value= format('|A:GarrMission_CurrencyIcon-Xp:0:0|a%i%%', data.currentStanding/data.nextReactionThreshold*100)
            end
        end
    else
        return {}
    end




    local isParagon = C_Reputation.IsFactionParagon(factionID)
    local hasRewardPending
    if isParagon and isUnlocked and isCapped then
        local currentValue, threshold, questID, hasReward, tooLowLevelForParagon, paragonStorageLevel = C_Reputation.GetFactionParagonInfo(factionID)

        if hasReward then
            local itemID=questID and select(6, GetQuestLogRewardInfo(1, questID))
            if itemID then
                local icon= select(5, C_Item.GetItemInfoInstant(itemID))
                if icon then
                    hasRewardPending= '|T'..icon..':0|t'
                end
            end
            hasRewardPending= hasRewardPending or format('|A:GarrMission-%sChest:0:0|a', WoWTools_DataMixin.Player.Faction)
        end
    
        if C_MajorFactions.IsWeeklyRenownCapped(factionID) then
            barColor= WARNING_FONT_COLOR
            value= WoWTools_L['Capped this week']
            value= barColor:WrapTextInColorCode(value)

        elseif currentValue and threshold then

            local completed= paragonStorageLevel or math.modf(currentValue/threshold)
            currentValue= completed>0 and currentValue - threshold * completed or currentValue

            if toRight then
                value= format('%i%%', currentValue/threshold*100)..' ('..completed..')'
            else
                value= '('..completed..') '..format('%i%%', currentValue/threshold*100)
            end

            if tooLowLevelForParagon then
                barColor= DISABLED_FONT_COLOR
            elseif hasReward then
                barColor= GREEN_FONT_COLOR
            end
        end

    end

    if not barColor then
        if not isUnlocked then
            barColor= DISABLED_FONT_COLOR
        elseif isCapped then
            if hasRewardPending then
                barColor= GREEN_FONT_COLOR
            elseif C_Reputation.IsAccountWideReputation(factionID) then
                barColor= ACCOUNT_WIDE_FONT_COLOR
            else
                barColor= ACHIEVEMENT_COMPLETE_COLOR
            end
        else
            barColor= NORMAL_FONT_COLOR
        end
    end


    if xp then
        if xp<=0 then
            xp= nil
        else
            xp= '|cnWARNING_FONT_COLOR:'..WoWTools_DataMixin:MK(xp, 3)..'|r'
        end
    end


    return {
        name= name,
        color= barColor,

        texture= texture,
        atlas= atlas,

        factionID= factionID,
        friendshipID= friendshipID,
        isMajor=isMajor,
        isParagon= isParagon,

        factionStandingtext= factionStandingtext,
        valueText= value,
        xp= xp,

        hasRewardPending=hasRewardPending,
        isCapped= isCapped,
        isUnlocked= isUnlocked,
        expansionID= expansionID
    }
end


function WoWTools_FactionMixin:GetName(factionID)
    local data= self:GetInfo(factionID)
    if not data.factionID then
        return factionID
    end

    local isAccount= C_Reputation.IsAccountWideReputation(factionID)

    return
        (data.atlas and ('|A:'..data.atlas..':0:0|a') or (data.texture and '|T'..data.texture..':0|t') or '')

        ..(isAccount and '|cff00ccff' or (data.isCapped and '|cffff7f00') or '|cff00ff00')
        ..WoWTools_TextMixin:CN(data.name)
        ..'|r '

        ..(data.isUnlocked and
            '|cffffffff'
            ..(
                data.isCapped and ''
                or (data.factionStandingtext and data.factionStandingtext..' ')
                or ''
            )
            ..((data.isCapped or data.isParagon) and data.valueText or '')
            ..'|r'

            or '|A:Professions_Specialization_Lock_Glow:0:0|a'
        )

        ..(isAccount and '|A:questlog-questtypeicon-account:0:0|a' or '')

        ..(data.hasRewardPending
            and (WoWTools_DataMixin.Player.Faction=='Alliance' and '|A:GarrMission-AllianceChest:0:0|a' or '|A:GarrMission-HordeChest:0:0|a')
            or ''
        )
end




function WoWTools_FactionMixin:Find(factionID)
    if ReputationFrame:IsVisible() then
        if factionID then
            for index=1, C_Reputation.GetNumFactions() do
                local data= C_Reputation.GetFactionDataByIndex(index)
                if data and data.name and data.factionID then

                    if data.factionID==factionID then

                        ReputationFrame.ScrollBox:ScrollToElementDataIndex(index)

                        for _, frame in pairs(ReputationFrame.ScrollBox:GetFrames() or {}) do
                            if frame.Content and frame.elementData then
                                if frame.elementData.factionID==factionID  then
                                    frame.Content.BackgroundHighlight:SetAlpha(0.2)
                                else
                                    frame.Content.BackgroundHighlight:SetAlpha(0)
                                end
                            end
                        end

                        break
                    end
                end
            end
        else
            for _, frame in pairs(ReputationFrame.ScrollBox:GetFrames() or {}) do
                if frame.Content then
                frame.Content.BackgroundHighlight:SetAlpha(0)
                end
            end
        end
    end
end




function WoWTools_FactionMixin:UpdatList()
    if ReputationFrame and ReputationFrame:IsVisible() then
        WoWTools_DataMixin:Call(ReputationFrame.Update, ReputationFrame)
    end
end


--C_DelvesUI.GetDelvesFactionForSeason()
function WoWTools_FactionMixin:GetCompanionInfo(companionID, tooltip)

    local playerCompanionID

    local seasonFactionID= C_DelvesUI.GetDelvesFactionForSeason()
    if seasonFactionID then
        local major= C_MajorFactions.GetMajorFactionData(seasonFactionID)
        if major and major.playerCompanionID then
            companionID= companionID or major.playerCompanionID
            playerCompanionID= major.playerCompanionID
        end
    end


    local factionID = C_DelvesUI.GetFactionForCompanion(companionID)
    local info= factionID and C_Reputation.GetFactionDataByID(factionID)

    if not info or not info.name then
        return
    end


    local companionRankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)


    local compaionName= (playerCompanionID==companionID and '|A:CampCollection-icon-star:0:0|a' or '')
            ..WoWTools_TextMixin:CN(info.name)

    local level
    if companionRankInfo then
        level = companionRankInfo.currentLevel or 0
        local companionRepInfo = C_GossipInfo.GetFriendshipReputation(factionID)
        if companionRepInfo then
            if companionRepInfo.nextThreshold then
                local currentExperience = companionRepInfo.standing - companionRepInfo.reactionThreshold
                local nextLevelAt = companionRepInfo.nextThreshold - companionRepInfo.reactionThreshold
                level= format('%d|A:GarrMission_CurrencyIcon-Xp:0:0|a%i%%', level, currentExperience/nextLevelAt*100)
            else
                level= ACCOUNT_WIDE_FONT_COLOR:GenerateHexColorMarkup()..level..'|r'
            end
        end
    end

    local traitTreeID = C_DelvesUI.GetTraitTreeForCompanion(companionID)
    local configID= traitTreeID and C_Traits.GetConfigIDByTreeID(traitTreeID)


    if tooltip then
        local hex= configID and '' or DISABLED_FONT_COLOR:GenerateHexColorMarkup()
        tooltip:AddDoubleLine(level and hex..level or ' ', hex..compaionName)
    end

    info.companionID= companionID
    info.playerCompanionID= playerCompanionID

    info.compaionName= compaionName
    info.compaionLevel= level
    info.traitTreeID= traitTreeID
    info.configID= configID

    return info
end


