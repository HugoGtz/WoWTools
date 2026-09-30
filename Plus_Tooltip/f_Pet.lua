


function WoWTools_TooltipMixin:Set_Pet(tooltip, speciesID)
    if self:IsInCombatDisabled(tooltip)
        or not canaccessvalue(speciesID)
        or not speciesID
    then
        return
    end

    speciesID = tonumber(speciesID)

    if not speciesID or speciesID< 1 then
        return
    end

    local speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    local AllCollected, CollectedNum, CollectedText, text2Right, typeTexture

    tooltip:AddLine(' ')

--speciesID, icon
    tooltip:AddDoubleLine(
        speciesIcon and '|T'..speciesIcon..':'..self.iconSize..'|t|cffffffff'..speciesIcon,

        (WoWTools_L.PET)
        ..'|cffffffff'..WoWTools_DataMixin.Icon.icon2
        ..speciesID
    )

--displayID companionID
    tooltip:AddDoubleLine(
        creatureDisplayID and 'displayID|cffffffff'..WoWTools_DataMixin.Icon.icon2..creatureDisplayID,

        companionID and 'companionID|cffffffff'..WoWTools_DataMixin.Icon.icon2..companionID
    )

    if canBattle then
        local abilityIconA, abilityIconB = WoWTools_PetBattleMixin:GetAbilityIcon(speciesID, nil, nil, false, self.iconSize)
        if abilityIconA or abilityIconB then
            tooltip:AddLine(' ')
            tooltip:AddLine(abilityIconA)
            tooltip:AddLine(abilityIconB)
        end
    else
        GameTooltip_AddErrorLine(tooltip, WoWTools_L.BATTLE_PET_CANNOT_BATTLE)
    end

    if not isTradeable then
        GameTooltip_AddErrorLine(tooltip, WoWTools_L.BATTLE_PET_NOT_TRADABLE)
    end

    tooltip:AddLine(' ')
    local sourceInfo= WoWTools_TextMixin:CN(nil, {speciesID=speciesID}) or {}
    local cnName= WoWTools_TextMixin:CN(nil, {npcID=companionID, isName=true})

    if cnName then
        tooltip:AddLine(cnName)
    end

    if tooltipDescription or sourceInfo[1] then
        tooltip:AddLine(sourceInfo[1] or tooltipDescription, nil,nil,nil, true)
    end
    if tooltipSource or sourceInfo[2] then
        tooltip:AddLine(sourceInfo[2] or tooltipSource,nil,nil,nil, true)
    end


    --local cardModelSceneID, loadoutModelSceneID = C_PetJournal.GetPetModelSceneInfoBySpeciesID(speciesID);

	--loadoutPlate.modelScene:TransitionToModelSceneID(loadoutModelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD)
    self:Set_Item_Model(tooltip, {
       -- modelSceneID= loadoutModelSceneID,
        creatureDisplayID=creatureDisplayID
    })

    if obtainable
        and not InCombatLockdown()
        and (not tooltip.JournalClick or not tooltip.JournalClick:IsShown())
    then
        if IsAltKeyDown() then
            WoWTools_LoadUIMixin:Journal(2, {petSpeciesID=speciesID})
            --PetJournalSearchBox:SetText(speciesName)
        end
        tooltip:AddLine(' ')
        tooltip:AddLine('|A:NPE_Icon:0:0|aAlt |TInterface\\Icons\\PetJournalPortrait:0|t'..(WoWTools_L.SEARCH))
    end

    if petType and PET_TYPE_SUFFIX[petType] then
        typeTexture= "Interface\\TargetingFrame\\PetBadge-"..PET_TYPE_SUFFIX[petType]

        local strongTexture, weakHintsTexture= WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)
        text2Right= '|T'..strongTexture..':0|t'
            ..'|cnGREEN_FONT_COLOR:<|r|T'..typeTexture..':0:|t'
            ..'|cnWARNING_FONT_COLOR:>|r|T'..weakHintsTexture..':'..self.iconSize..'|t'
    end

    tooltip.Portrait:SetTexture(typeTexture or 0)
    --tooltip.Portrait:SetShown(typeTexture)

    if obtainable then
        AllCollected, CollectedNum, CollectedText= WoWTools_PetBattleMixin:Collected(speciesID)
    end

    tooltip:Set_TopLabel(CollectedNum, CollectedText, AllCollected, text2Right)


    self:Set_Web_Link(tooltip, {type='npc', id=companionID, name=speciesName, col= nil, isPetUI=false})

    WoWTools_PetBattleMixin:Show_TypeButton_Type(petType)

    WoWTools_TooltipMixin:Show(tooltip)
end
