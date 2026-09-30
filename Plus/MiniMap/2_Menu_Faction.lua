


local function Set_Faction_Menu(root, factionID)
    local info= WoWTools_FactionMixin:GetInfo(factionID)
    if not info.name then
        return
    end

    local icon=''
    if info.atlas then
        icon= '|A:'..info.atlas..':18:18|a'
    elseif info.texture then
        icon= '|T'..info.texture..':18|t'
    end

    local name= WoWTools_TextMixin:CN(info.name)
    if not info.isUnlocked then
        name= DISABLED_FONT_COLOR:WrapTextInColorCode(name)
    else
        name= NORMAL_FONT_COLOR:WrapTextInColorCode(name)
    end

    local sub=root:CreateRadio(
        icon..name
        ..(info.color and '|c'..info.color:GenerateHexColor() or '|cffffffff')
        ..(info.factionStandingtext and not info.isCapped and ' '..info.factionStandingtext..' ' or ' ')
        ..'|r'
        ..(info.valueText or '')
        ..(info.hasRewardPending and '|A:BonusLoot-Chest:0:0|a' or ''),

    function(data)
        if EncounterJournalJourneysFrame then
            return EncounterJournalJourneysFrame and EncounterJournalJourneysFrame.JourneyProgress.majorFactionData.factionID==data.factionID

        elseif MajorFactionRenownFrame then
            return MajorFactionRenownFrame and MajorFactionRenownFrame.majorFactionID==data.factionID
        end
    end, function(data)
        WoWTools_LoadUIMixin:OpenFaction(data.factionID)
        return MenuResponse.Refresh
    end, {factionID=factionID})

    WoWTools_SetTooltipMixin:FactionMenu(sub)

    return sub
end


function WoWTools_MinimapMixin:Faction_Menu(_, root)
    local sub

    sub=root:CreateButton(
        '|A:VignetteEvent-SuperTracked:0:0|a'
        ..(WoWTools_L.LANDING_PAGE_RENOWN_LABEL),
    --function()
        --return MajorFactionRenownFrame and MajorFactionRenownFrame:IsShown()
    function()
        WoWTools_LoadUIMixin:OpenFaction(2593)
        return MenuResponse.Refresh
    end)



    local tab= C_MajorFactions.GetMajorFactionIDs()

    table.sort(tab, function(a, b)
        local a2= C_MajorFactions.GetMajorFactionData(a) or {expansionID=0}
        local b2= C_MajorFactions.GetMajorFactionData(b) or {expansionID=0}
        if a2.expansionID==b2.expansionID then
            return a>b
        else
            return a2.expansionID>b2.expansionID
        end
    end)

    local expansionID= WoWTools_DataMixin.ExpansionLevel

    for index, factionID in pairs(tab) do
        local major= C_MajorFactions.GetMajorFactionData(factionID)
        if major and major.expansionID<expansionID then
            expansionID= major.expansionID
            table.insert(tab, index, '-')
        end
    end


    for _, factionID in pairs(tab) do
        if factionID=='-' then
            sub:CreateDivider()
        elseif not C_MajorFactions.IsMajorFactionHiddenFromExpansionPage(factionID) then
            Set_Faction_Menu(sub, factionID)
        end
    end


    WoWTools_MenuMixin:SetScrollMode(sub)
end


