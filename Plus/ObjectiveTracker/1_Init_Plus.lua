



local P_Save={
    disabled= true,
    scale= 1,
    alpha=1,
    autoHide= nil
}


local Init= WoWTools_Once(function()
    ScenarioObjectiveTracker.Header.numStagesLabel= WoWTools_LabelMixin:Create(ScenarioObjectiveTracker.Header, {copyFont=ScenarioObjectiveTracker.StageBlock.Name, justifyH='RIGHT'})
    ScenarioObjectiveTracker.Header.numStagesLabel:SetPoint('LEFT', ScenarioObjectiveTracker.Header.Text, 'RIGHT')

    WoWTools_DataMixin:Hook(ScenarioObjectiveTracker, 'LayoutContents', function(self)
        local text
        local currentStage, numStages = select(2, C_Scenario.GetInfo())
        if numStages and numStages>1 and currentStage then
            text= (numStages==currentStage and '|cnGREEN_FONT_COLOR:' or '')..currentStage..'/'..numStages
        end
        self.Header.numStagesLabel:SetText(text or '')
    end)
    --local scenarioName, currentStage, numStages, flags, hasBonusStep, isBonusStepComplete, _, xp, money, scenarioType, areaName, _, scenarioID = C_Scenario.GetInfo();
    ScenarioObjectiveTracker.StageBlock:HookScript('OnEnter', function(self)
        local scenarioID = select(13, C_Scenario.GetInfo())
        if not scenarioID then
            return
        end
        if not GameTooltip:IsShown() then
            GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
            GameTooltip:ClearLines()
        else
            GameTooltip:AddLine(' ')
        end

        GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.icon2..'scenarioID', '|cffffffff'..scenarioID)
        GameTooltip:Show()
    end)


--QuestObjectiveItemButtonTemplate
    WoWTools_DataMixin:Hook(QuestObjectiveItemButtonMixin, 'SetUp', function(self)
        if not WoWTools_FrameMixin:IsLocked(self) and not self.isSetTexture then
            self:SetSize(42,42)
            self.NormalTexture:SetPoint('TOPLEFT', -10, 10)
            self.NormalTexture:SetPoint('BOTTOMRIGHT', 10, -10)
            self:GetPushedTexture():SetPoint('TOPLEFT', -14, 14)
            self:GetPushedTexture():SetPoint('BOTTOMRIGHT', 14, -14)
            self.isSetTexture= true
        end
    end)


    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
        AchievementObjectiveTracker,
        WoWTools_L.TRACKER_HEADER_ACHIEVEMENTS,
    function()
        WoWTools_ObjectiveMixin:Clear_Achievement(true)
    end)
    WoWTools_DataMixin:Hook(AchievementObjectiveTracker, 'AddAchievement', function(self, achievementID)
        local block = WoWTools_ObjectiveMixin:Get_Block(self, achievementID)
        if not block then
            return
        end

        local icon= select(10, GetAchievementInfo(achievementID))
        WoWTools_ObjectiveMixin:Set_Block_Icon(block, icon, 'isAchievement')


        for index, line in pairs(block.usedLines or {}) do
            local subIcon
            if type(index)=='number' then
                --local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(achievementID, index);
                local assetID= select(8, GetAchievementCriteriaInfo(achievementID, index))
                subIcon = assetID and select(10, GetAchievementInfo(assetID))
            end
            WoWTools_ObjectiveMixin:Set_Line_Icon(line, subIcon)
        end
    end)


    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
        ProfessionsRecipeTracker,
        WoWTools_L.PROFESSIONS_TRACKER_HEADER_PROFESSION,
    function()
        WoWTools_ObjectiveMixin:Clear_ProfessionsRecipe(true)
    end)
    WoWTools_DataMixin:Hook(ProfessionsRecipeTracker, 'AddRecipe', function(self, recipeID, isRecraft)
        local blockID = NegateIf(recipeID, isRecraft);
	    local block = WoWTools_ObjectiveMixin:Get_Block(self, blockID)

        if not block then
            return
        end

        local data=  C_TradeSkillUI.GetRecipeInfo(recipeID)
        if data then
            WoWTools_ObjectiveMixin:Set_Block_Icon(block, data.icon, 'isRecipe')
        end

        local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft)
        if not recipeSchematic or not recipeSchematic.reagentSlotSchematics then
            return
        end

        for index, line in pairs(block.usedLines or {}) do
            local subIcon
            if type(index)=='number' then
                local reagentSlotSchematic= recipeSchematic.reagentSlotSchematics[index]
                if reagentSlotSchematic then
                    local reagent = reagentSlotSchematic.reagents[1] or {}
                    if reagent.itemID then
                        local item = Item:CreateFromItemID(reagent.itemID);
                        subIcon = item:GetItemIcon()
                    elseif reagent.currencyID then
                        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reagent.currencyID);
                        if currencyInfo then
                            subIcon = currencyInfo.iconFileID;
                        end
                    end
                end
            end

            WoWTools_ObjectiveMixin:Set_Line_Icon(line, subIcon)
        end
    end)


    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
    QuestObjectiveTracker,
        WoWTools_L.TRACKER_HEADER_QUESTS,
    function()
        WoWTools_ObjectiveMixin:Clear_Quest(true)
    end)

    WoWTools_DataMixin:Hook(QuestObjectiveTracker, 'AddBlock', function(_, block)
        local questID= block.HeaderText and block.id and tonumber(block.id)
        if questID then
            local color = select(2, WoWTools_QuestMixin:GetAtlasColor(questID))
            if color then
                block.HeaderText:SetTextColor(color:GetRGB())
            end
        end
    end)


    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
        CampaignQuestObjectiveTracker,
        WoWTools_L.TRACKER_HEADER_CAMPAIGN_QUESTS,
    function()
        WoWTools_ObjectiveMixin:Clear_CampaignQuest(true)
    end)


    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
        WorldQuestObjectiveTracker,
        WoWTools_L.TRACKER_HEADER_WORLD_QUESTS,
    function()
       WoWTools_ObjectiveMixin:Clear_WorldQuest(true)
    end)


    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
        MonthlyActivitiesObjectiveTracker,
        WoWTools_L.TRACKER_HEADER_MONTHLY_ACTIVITIES,
    function()
        WoWTools_ObjectiveMixin:Clear_MonthlyActivities(true)
    end)

    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
        AdventureObjectiveTracker,
        WoWTools_L.FAVORITES,
    function()
        WoWTools_ObjectiveMixin:Clear_ContentTracking(true)
    end)


    WoWTools_ObjectiveMixin:Add_ClearAll_Button(
        InitiativeTasksObjectiveTracker,
        WoWTools_L.HOUSING_DASHBOARD_INITIATIVES,
    function()
        WoWTools_ObjectiveMixin:Clear_NeighborhoodInitiative(true)
    end)


    WoWTools_ObjectiveMixin:Init_Menu()
end)


--Módulo registrado con la API común (docs/REFACTOR.md, R2).
--La casilla es propia (panel=false, en onLoad): activar arranca ya sin recargar, el nombre va en color y el tooltip avisa de 'Bug'.
WoWTools_Module:Register({
    key= 'ObjectiveTracker',
    name= 'Module.Objective tracker',
    icon= 'Objective-Nub',
    group= 'Interface',
    defaults= P_Save,
    mixin= WoWTools_ObjectiveMixin,
    panel= false,
    tooltip= 'Tip.Objective.Module',
    options= function()
        return WoWTools_ObjectiveMixin:Get_Options()
    end,
    onLoad= function()
        WoWTools_ObjectiveMixin.addName= '|A:Objective-Nub:0:0|a|cnWARNING_FONT_COLOR:'..(WoWTools_L['Module.Objective tracker'])..'|r'

        WoWTools_PanelMixin:OnlyCheck({
            name=WoWTools_ObjectiveMixin.addName,
            tooltip=WoWTools_L['Tip.Objective.Module']..'|n|n'..'|cnWARNING_FONT_COLOR:Bug',
            GetValue= function() return not WoWTools_ObjectiveMixin:Save().disabled end,
            SetValue= function()
                WoWTools_ObjectiveMixin:Save().disabled= not WoWTools_ObjectiveMixin:Save().disabled and true or nil

                if not WoWTools_ObjectiveMixin:Save().disabled then
                    Init()
                else
                    WoWTools_Print(
                        WoWTools_DataMixin.Icon.icon2..WoWTools_ObjectiveMixin.addName,
                        WoWTools_TextMixin:GetEnabeleDisable(not WoWTools_ObjectiveMixin:Save().disabled),
                        WoWTools_L.REQUIRES_RELOAD
                    )
                end
            end
        })
    end,
    onEnable= function()
        Init()
    end,
})
