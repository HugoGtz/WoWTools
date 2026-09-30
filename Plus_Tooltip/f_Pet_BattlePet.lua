function WoWTools_TooltipMixin:Set_Battle_Pet(tooltip, speciesID, level, breedQuality, maxHealth, power, speed, customName)
    if self:IsInCombatDisabled(tooltip)
        or not canaccessvalue(speciesID)
        or not speciesID
    then
        return
    end

    speciesID= tonumber(speciesID)

    if not speciesID or speciesID < 1 then
        return
    end

    self:Set_Init_Item(tooltip)


    local speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, _, _, _, _, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)


    self:Set_Item_Model(tooltip, {creatureDisplayID=creatureDisplayID})

    if obtainable then
        local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
        if numCollected==0 then
            BattlePetTooltipTemplate_AddTextLine(tooltip,
                format(WoWTools_L.ITEM_PET_KNOWN, 0, limit),
                1,0,0
            )
        end
    end

    BattlePetTooltipTemplate_AddTextLine(tooltip,
        --'speciesID'
        (WoWTools_L.PET)
        ..WoWTools_DataMixin.Icon.icon2
        ..'|cffffffff'
        ..speciesID
        ..'   |T'..speciesIcon..':'..self.iconSize..'|t'
        ..'|cffffffff'
        ..speciesIcon
    )
    BattlePetTooltipTemplate_AddTextLine(tooltip,
        'companionID'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..companionID
        ..'  displayID'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..creatureDisplayID
    )

    BattlePetTooltipTemplate_AddTextLine(tooltip, ' ')

    local abilityIconA, abilityIconB= WoWTools_PetBattleMixin:GetAbilityIcon(speciesID, nil, nil, false, self.iconSize)
    if abilityIconA and abilityIconB then
        BattlePetTooltipTemplate_AddTextLine(tooltip, abilityIconA)
        BattlePetTooltipTemplate_AddTextLine(tooltip, abilityIconB)
    end

    BattlePetTooltipTemplate_AddTextLine(tooltip, ' ')

    local npcName= WoWTools_TextMixin:CN(nil, {npcID=companionID, isName=true})
    if npcName then
        BattlePetTooltipTemplate_AddTextLine(tooltip, npcName)
    end

--Description
    local sourceInfo= WoWTools_TextMixin:CN(nil, {speciesID=speciesID}) or {}
    tooltipDescription= sourceInfo[1] or tooltipDescription
    if tooltipDescription then
        BattlePetTooltipTemplate_AddTextLine(tooltip, tooltipDescription, nil, nil, nil, true)
    end

    tooltipSource= sourceInfo[2] or tooltipSource
    if tooltipSource then
        BattlePetTooltipTemplate_AddTextLine(tooltip, tooltipSource, nil, nil, nil, true)
    end

    if obtainable
        and not InCombatLockdown()
        and (not tooltip.JournalClick or not tooltip.JournalClick:IsShown())
    then
        if IsAltKeyDown() then
            WoWTools_LoadUIMixin:Journal(2, {petSpeciesID=speciesID})
        end
        BattlePetTooltipTemplate_AddTextLine(tooltip, ' ')
        BattlePetTooltipTemplate_AddTextLine(tooltip,
            '|TInterface\\Icons\\PetJournalPortrait:0|t'
            ..(WoWTools_L.SEARCH)..' |A:NPE_Icon:0:0|aAlt'
        )
    end

    local color= WoWTools_ItemMixin:GetColor(breedQuality)
    tooltip:Set_BG_Color(color, 0.15)


    local AllCollected, CollectedNum, CollectedText= WoWTools_PetBattleMixin:Collected(speciesID)
    local text2Right
     if petType and PET_TYPE_SUFFIX[petType] then
        local typeTexture= "Interface\\TargetingFrame\\PetBadge-"..PET_TYPE_SUFFIX[petType]
        local strongTexture, weakHintsTexture= WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)
        text2Right= '|T'..strongTexture..':'..self.iconSize..'|t'
            ..'|cnGREEN_FONT_COLOR:<|r|T'..typeTexture..':'..self.iconSize..':|t'
            ..'|cnWARNING_FONT_COLOR:>|r|T'..weakHintsTexture..':'..self.iconSize..'|t'
    end

    tooltip.textLeft:SetText(CollectedNum or '')
    tooltip.text2Left:SetText(CollectedText or '')
    tooltip.textRight:SetText(AllCollected or '')
    tooltip.text2Right:SetText(text2Right or '')


    self:Set_Web_Link(tooltip, {type='npc', id=companionID, name=speciesName, col=nil, isPetUI=true})

    --tooltip:Show()
    WoWTools_TooltipMixin:Show(tooltip)
end