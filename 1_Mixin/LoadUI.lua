WoWTools_LoadUIMixin= {}



function WoWTools_LoadUIMixin:IsDisabledOpenFrame()
    return Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING
end




function WoWTools_LoadUIMixin:Journal(index, tab)
    if
        self:IsDisabledOpenFrame()
        or InCombatLockdown()
    then
        return
    end

    if not CollectionsJournal then
        CollectionsJournal_LoadUI()
    end

    if not CollectionsJournal:IsShown() then
        ShowUIPanel(CollectionsJournal)
        --CollectionsJournal:Show()
    end

    index= index or 1

    CollectionsJournal_SetTab(CollectionsJournal, index)

    if not tab then
        return
    end

    if tab.toyItemID then
        if index==3 then
            local name2= select(2, C_ToyBox.GetToyInfo(tab.toyItemID))
            if name2 then
                C_ToyBoxInfo.SetDefaultFilters()
                if ToyBox.searchBox then
                    ToyBox.searchBox:SetText(name2)
                end
            end
        end
    elseif (tab.petOwner and tab.petIndex) or tab.petSpeciesID then
        local speciesID = tab.petSpeciesID or C_PetBattles.GetPetSpeciesID(tab.petOwner, tab.petIndex)
        if speciesID then
            PetJournalSearchBox:SetText('')
            C_PetJournal.SetDefaultFilters()
            PetJournal_SelectSpecies(PetJournal, speciesID)
        end
    end
end




--C_CurrencyInfo.GetCurrencyListSize() <= 0
function WoWTools_LoadUIMixin:OpenPaperDoll(frameIndex, tabIndex)
    if self:IsDisabledOpenFrame()
        or C_GameRules.IsGameRuleActive(Enum.GameRule.CharacterPanelDisabled)
    then
        return
    end

    if not CharacterFrame:IsShown() then
        ToggleCharacter("PaperDollFrame")
    end

    if frameIndex==1 then
        if tabIndex then
            PaperDollFrame_SetSidebar(PaperDollFrame, tabIndex)
        end

    elseif frameIndex==2 then
        if not ReputationFrame:IsShown() then
            ToggleCharacter("ReputationFrame")
        end

    elseif frameIndex==3 then
        CharacterFrame:ToggleTokenFrame()
    end
end


function WoWTools_LoadUIMixin:ToggleLandingPage()

    local mode= C_Garrison.GetLandingPageGarrisonType()
    if --ExpansionLandingPageMinimapButton:IsInGarrisonMode()
        GameRulesUtil.ShouldShowExpansionLandingPageButton()
        and mode
        and C_Garrison.IsLandingPageMinimapButtonVisible(mode)
        and not self:IsDisabledOpenFrame()
    then
        GarrisonLandingPage_Toggle()
    end
end


function WoWTools_LoadUIMixin:Professions(recipeID)
    if self:IsDisabledOpenFrame() then
        return
    end

    do
        if not ProfessionsFrame then
            ProfessionsFrame_LoadUI()
        end
    end
    if recipeID then
        if C_TradeSkillUI.IsRecipeProfessionLearned(recipeID) then
            local parentTradeSkillID= select(3, C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID))
            if parentTradeSkillID then
                OpenProfessionUIToSkillLine(parentTradeSkillID)
            end
            C_TradeSkillUI.OpenRecipe(recipeID)
        --else
            --Professions.InspectRecipe(recipeID)
        end
    end
end


function WoWTools_LoadUIMixin:WeeklyRewards()
    if
        InCombatLockdown()
        or self:IsDisabledOpenFrame()
    then
        return
    end

    if not WeeklyRewardsFrame then
        WeeklyRewards_LoadUI()
    end

    if WeeklyRewardsFrame and WeeklyRewardsFrame:IsVisible()then
        WeeklyRewardsFrame:Hide()
    else
        WeeklyRewards_ShowUI()--WeeklyReward.lua
    end
end


function WoWTools_LoadUIMixin:OpenFaction(factionID)
    if
        self:IsDisabledOpenFrame()
    then
        return
    end

    local isMajor= factionID and C_Reputation.IsMajorFaction(factionID)

    if isMajor or not factionID then
        if not EncounterJournal then
            EncounterJournal_LoadUI()
        end

        if WoWTools_FrameMixin:IsLocked(EncounterJournal) then
            return
        end

        if ReputationFrame:IsVisible() then
            HideUIPanel(CharacterFrame)
        end

        if not EncounterJournal:IsShown() then
            ShowUIPanel(EncounterJournal)
        end

        EJ_ContentTab_Select(EncounterJournal.JourneysTab:GetID())

        if factionID and EncounterJournalJourneysFrame then
            EncounterJournalJourneysFrame:ResetView(C_MajorFactions.GetMajorFactionData(factionID), factionID)
            EncounterJournal_OpenToJourney(factionID)
        end

    elseif factionID then
        self:OpenPaperDoll(2)
        if not ReputationFrame or not ReputationFrame:IsShown() then
            return
        end

        if EncounterJournal and EncounterJournal:IsShown() then
            HideUIPanel(EncounterJournal)
        end

        if C_Reputation.GetReputationSortType()~=Enum.ReputationSortType.None then
            C_Reputation.SetReputationSortType(Enum.ReputationSortType.None)
        end
        WoWTools_FactionMixin:Find(factionID)
    end

end


local mainTextureKitRegions = {
	["Background"] = "CovenantSanctum-Renown-Background-%s",
	["TitleDivider"] = "CovenantSanctum-Renown-Title-Divider-%s",
	["Divider"] = "CovenantSanctum-Renown-Divider-%s",
	["Anima"] = "CovenantSanctum-Renown-Anima-%s",
	["FinalToastSlabTexture"] = "CovenantSanctum-Renown-FinalToast-%s",
	["SelectedLevelGlow"] = "CovenantSanctum-Renown-Next-Glow-%s",
}
local function SetupTextureKit(frame, regions, covenantData)
	SetupTextureKitOnRegions(covenantData.textureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize)
end


function WoWTools_LoadUIMixin:CovenantRenown(frame, covenantID)
    if
        self:IsDisabledOpenFrame()
    then
        return
    end


    if not CovenantRenownFrame or not CovenantRenownFrame:IsShown() then
        ToggleCovenantRenown()
    end


    covenantID= covenantID or (frame and frame.covenantID)
    if not covenantID then
        return
    end

    --CovenantRenownMixin:SetUpCovenantData()
    local covenantData = C_Covenants.GetCovenantData(covenantID)
    if not covenantData then
        return
    end

    local textureKit = covenantData.textureKit

    NineSliceUtil.ApplyUniqueCornersLayout(CovenantRenownFrame.NineSlice, textureKit)
    NineSliceUtil.DisableSharpening(CovenantRenownFrame.NineSlice)

    local atlas = "CovenantSanctum-RenownLevel-Border-%s"
    CovenantRenownFrame.HeaderFrame.Background:SetAtlas(atlas:format(textureKit), TextureKitConstants.UseAtlasSize)
    UIPanelCloseButton_SetBorderAtlas(CovenantRenownFrame.CloseButton, "UI-Frame-%s-ExitButtonBorder", -1, 1, textureKit)
    SetupTextureKit(CovenantRenownFrame, mainTextureKitRegions, covenantData)

    local renownLevelsInfo = C_CovenantSanctumUI.GetRenownLevels(covenantID) or {}
    local unlocked=0
    for i, levelInfo in ipairs(renownLevelsInfo) do
        levelInfo.textureKit = textureKit
        if not levelInfo.locked then
            unlocked=i
        end
        levelInfo.rewardInfo = C_CovenantSanctumUI.GetRenownRewardsForLevel(covenantID, i)
    end
    CovenantRenownFrame.TrackFrame:Init(renownLevelsInfo)
    CovenantRenownFrame.maxLevel = renownLevelsInfo[#renownLevelsInfo] and renownLevelsInfo[#renownLevelsInfo].level or 0


    CovenantRenownFrame.actualLevel = C_CovenantSanctumUI.GetRenownLevel()
    CovenantRenownFrame.displayLevel = unlocked

    CovenantRenownFrame:Refresh(true)

    C_CovenantSanctumUI.RequestCatchUpState()
end


function WoWTools_LoadUIMixin:SpellBook(index, spellID)
    if InCombatLockdown()
        or self:IsDisabledOpenFrame()
    then
        return
    end

    if index==1 then
        PlayerSpellsUtil.OpenToClassSpecializationsTab()
    elseif index==2 then
        PlayerSpellsUtil.OpenToClassTalentsTab()
    else
        if spellID then
            local knownSpellsOnly, toggleFlyout, flyoutReason = true, true, nil;
            PlayerSpellsUtil.OpenToSpellBookTabAtSpell(spellID, knownSpellsOnly, toggleFlyout, flyoutReason)
        else
            PlayerSpellsUtil.OpenToSpellBookTab()
        end
    end
end


-- AchievementObjectiveTrackerMixin:OnBlockHeaderClick
--AchievementFrameAchievements.selection ~= achievementID
--CanShowAchievementUI()
function WoWTools_LoadUIMixin:Achievement(achievementID)
    if not achievementID
        or not C_AchievementInfo.IsValidAchievement(achievementID)
        or self:IsDisabledOpenFrame()
    then
        return
    end

    if not AchievementFrame then
        WoWTools_DataMixin:Call('AchievementFrame_LoadUI')
    end

    if not AchievementFrame:IsShown() then
        WoWTools_DataMixin:Call('AchievementFrame_ToggleAchievementFrame')
    end
    if achievementID then
        WoWTools_DataMixin:Call('AchievementFrame_SelectAchievement', achievementID, true)
    end
end


--AchievementFrame_SelectAchievement(6779)
function WoWTools_LoadUIMixin:JournalInstance(journalType, journalInstanceID, difficultyID)
    if not AdventureGuideUtil.IsAvailable()
        or not journalInstanceID
        or (InCombatLockdown() and (not EncounterJournal or not EncounterJournal:IsShown()))
        or self:IsDisabledOpenFrame()
    then
        return
    end
    AdventureGuideUtil.OpenJournalLink(journalType or 0, journalInstanceID, difficultyID or 23)
end


function WoWTools_LoadUIMixin:OpenCompanion(companionID)
    if InCombatLockdown() or self:IsDisabledOpenFrame() or not DelvesCompanionConfigurationFrame then
        return

    elseif DelvesCompanionConfigurationFrame:IsShown() then
        DelvesCompanionConfigurationFrame:Hide()
        return
    end

    if not companionID then
        local factionID= C_DelvesUI.GetDelvesFactionForSeason()-- or 2272
        if factionID then
            local major= C_MajorFactions.GetMajorFactionData(factionID)
            if major then
                companionID= major.playerCompanionID
            end
        end
    end

    local traitTreeID = C_DelvesUI.GetTraitTreeForCompanion(companionID)
    local configID= traitTreeID and C_Traits.GetConfigIDByTreeID(traitTreeID)

    if not configID then
        return
    end

    DelvesCompanionConfigurationFrame.playerCompanionID = companionID
    ShowUIPanel(DelvesCompanionConfigurationFrame)
end

function WoWTools_LoadUIMixin:Housing()
    if not HousingDashboardFrame then
        do
            HousingFramesUtil.ToggleHousingDashboard()
        end
        if HousingDashboardFrame and HousingDashboardFrame:IsShown() then
            HousingFramesUtil.ToggleHousingDashboard()
        end
    end
end