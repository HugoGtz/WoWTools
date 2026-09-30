


function WoWTools_TooltipMixin:Set_Mount(tooltip, mountID, type)
    if self:IsInCombatDisabled(tooltip)
        or not canaccessvalue(mountID)
        or not mountID
    then
        return

    elseif mountID==268435455 then
        self:Set_Spell(tooltip, 150544)
        return
    end

    tooltip:AddLine(' ')
    --local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID, isForDragonriding = C_MountJournal.GetDisplayedMountInfo(elementData.index)
    local creatureName, spellID, _,isActive, isUsable, _, _, isFactionSpecific, faction, _, isCollected, _, isForDragonriding =C_MountJournal.GetMountInfoByID(mountID)

    WoWTools_DataMixin:Load(spellID, 'spell')
    local icon= C_Spell.GetSpellTexture(spellID)

    tooltip:AddDoubleLine(
        spellID and '|T'..(icon or 0)..':0|t'
        ..'spellID'
        ..WoWTools_DataMixin.Icon.icon2
        ..'|cffffffff'..spellID,

        (WoWTools_L.PERKS_VENDOR_CATEGORY_MOUNT)
        ..WoWTools_DataMixin.Icon.icon2
        ..'|cffffffff'
        ..mountID
    )

    local textRight
    if isFactionSpecific then
        if faction==0 then
            textRight= format(
                WoWTools_L.LFG_LIST_CROSS_FACTION,
                format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.Horde, WoWTools_L.THE_HORDE)
            )
        elseif faction==1 then
            textRight= format(
                WoWTools_L.LFG_LIST_CROSS_FACTION,
                format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.NONE, WoWTools_L.THE_ALLIANCE)
            )
        end
    elseif isForDragonriding then
        textRight= format(WoWTools_L.LFG_LIST_CROSS_FACTION, WoWTools_L.MOUNT_JOURNAL_FILTER_DRAGONRIDING)
    end


    local creatureDisplayInfoID, _, source, isSelfMount, _, _, animID, spellVisualKitID = C_MountJournal.GetMountInfoExtraByID(mountID)
    if creatureDisplayInfoID then
        tooltip:AddDoubleLine(
            'displayID'
            ..WoWTools_DataMixin.Icon.icon2
            ..'|cffffffff'
            ..creatureDisplayInfoID,

            isSelfMount and '|cnGREEN_FONT_COLOR:'..(WoWTools_L.TUTORIAL_TITLE61_DRUID)
        )
    end

    if source then
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_TextMixin:CN(source), nil,nil,nil,true)
    end

    self:Set_Item_Model(tooltip, {
        creatureDisplayID=creatureDisplayInfoID,
        animID=animID,
        spellVisualKitID=spellVisualKitID,
    })

    local can= isCollected and isUsable and not isActive and not UnitCastingInfo('player')
    if can and IsAltKeyDown() then
        C_MountJournal.SummonByID(mountID)
    end

    local col= can and '|cnGREEN_FONT_COLOR:' or '|cff626262'

    tooltip:AddDoubleLine(
        col..(WoWTools_L['MOUNT~2']),
        col..'Alt+|A:NPE_Icon:0:0|a'
    )

    if type and MountJournal and MountJournal:IsVisible() and creatureName then
        MountJournalSearchBox:SetText(creatureName)
    end

    local textLeft= isCollected
                    and '|cnGREEN_FONT_COLOR:'..(WoWTools_L.COLLECTED)..'|r'
                    or ('|cnWARNING_FONT_COLOR:'..(WoWTools_L.NOT_COLLECTED)..'|r')

    tooltip:Set_TopLabel(textLeft, nil, textRight, nil)

    tooltip.Portrait:settings(icon)

    self:Set_Web_Link(tooltip, {type='spell', id=spellID, name=creatureName, col=nil, isPetUI=false})

    WoWTools_TooltipMixin:Show(tooltip)
end

