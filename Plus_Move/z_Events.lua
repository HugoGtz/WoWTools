function WoWTools_MoveMixin.Events:Blizzard_TrainerUI()
    ClassTrainerFrame.ScrollBox:ClearAllPoints()
    ClassTrainerFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -26, 34)
    ClassTrainerFrameSkillStepButton:SetPoint('RIGHT', -12, 0)
    ClassTrainerFrameBottomInset:SetPoint('BOTTOMRIGHT', -4, 28)
    WoWTools_DataMixin:Hook('ClassTrainerFrame_Update', function()--Blizzard_TrainerUI.lua
        ClassTrainerFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -26, 34)
    end)
    self:Setup(ClassTrainerFrame, {
        minW=200, minH=197,
    sizeRestFunc=function(f)
        f:SetSize(338, 424)
    end})
end

function WoWTools_MoveMixin.Events:Blizzard_TimeManager()
    self:Setup(TimeManagerFrame, {save=true})
end

function WoWTools_MoveMixin.Events:Blizzard_BlackMarketUI()
    self:Setup(BlackMarketFrame)
end

function WoWTools_MoveMixin.Events:Blizzard_Calendar()
    self:Setup(CalendarFrame)
    self:Setup(CalendarEventPickerFrame, {frame=CalendarFrame})
    self:Setup(CalendarTexturePickerFrame, {frame=CalendarFrame})
    self:Setup(CalendarMassInviteFrame, {frame=CalendarFrame})
    self:Setup(CalendarCreateEventFrame, {frame=CalendarFrame})
    self:Setup(CalendarViewEventFrame, {frame=CalendarFrame})
    self:Setup(CalendarViewHolidayFrame, {frame=CalendarFrame})
    self:Setup(CalendarViewRaidFrame, {frame=CalendarFrame})
end

function WoWTools_MoveMixin.Events:Blizzard_GarrisonUI()
    self:Setup(GarrisonShipyardFrame)
    self:Setup(GarrisonMissionFrame)
    self:Setup(GarrisonCapacitiveDisplayFrame)
    self:Setup(CovenantMissionFrame)

    self:Setup(GarrisonLandingPage,{
    })
    self:Setup(OrderHallMissionFrame)
    self:Setup(AdventureMapQuestChoiceDialog, {frame=OrderHallMissionFrame})
end

function WoWTools_MoveMixin.Events:Blizzard_PlayerChoice()
    self:Setup(PlayerChoiceFrame)

    WoWTools_DataMixin:Hook(PlayerChoiceFrame, 'SetupOptions', function(frame)
        for optionFrame in frame.optionPools:EnumerateActiveByTemplate(frame.optionFrameTemplate) do
            if not optionFrame.moveFrameData then
                self:Setup(optionFrame, {frame=frame})
            end
        end
    end)
end



function WoWTools_MoveMixin.Events:Blizzard_FlightMap()
    self:Setup(FlightMapFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_OrderHallUI()
    self:Setup(OrderHallTalentFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_GenericTraitUI()
    self:Setup(GenericTraitFrame)
    self:Setup(GenericTraitFrame.ButtonsParent, {frame=GenericTraitFrame})
end

function WoWTools_MoveMixin.Events:Blizzard_WeeklyRewards()
    self:Setup(WeeklyRewardsFrame, {onShowFunc=true})
    self:Setup(WeeklyRewardsFrame.Blackout, {frame=WeeklyRewardsFrame})
end


function WoWTools_MoveMixin.Events:Blizzard_ItemUpgradeUI()
    self:Setup(ItemUpgradeFrame)
end

function WoWTools_MoveMixin.Events:Blizzard_InspectUI()
    if InspectFrame then
        self:Setup(InspectFrame)
    end
end

function WoWTools_MoveMixin.Events:Blizzard_ItemInteractionUI()
    C_Timer.After(2, function()
        self:Setup(ItemInteractionFrame)
    end)
end




function WoWTools_MoveMixin.Events:Blizzard_ChromieTimeUI()
    self:Setup(ChromieTimeFrame)
end

function WoWTools_MoveMixin.Events:Blizzard_BFAMissionUI()
    self:Setup(BFAMissionFrame)
end




function WoWTools_MoveMixin.Events:Blizzard_DeathRecap()
    self:Setup(DeathRecapFrame, {
        minW=254,minH=143,
    sizeRestFunc=function(f)
        f:SetSize(410, 326)
    end})
end

function WoWTools_MoveMixin.Events:Blizzard_ClickBindingUI()
    ClickBindingFrame.TutorialButton:SetFrameLevel(ClickBindingFrame.TitleContainer:GetFrameLevel()+1)

    self:Setup(ClickBindingFrame)
    self:Setup(ClickBindingFrame.ScrollBox, {frame=ClickBindingFrame})
end


function WoWTools_MoveMixin.Events:Blizzard_ArchaeologyUI()
    self:Setup(ArchaeologyFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_CovenantRenown()
    self:Setup(CovenantRenownFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_ScrappingMachineUI()
    self:Setup(ScrappingMachineFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_ArtifactUI()
    self:Setup(ArtifactFrame)
end

function WoWTools_MoveMixin.Events:Blizzard_RemixArtifactUI()
    self:Setup(RemixArtifactFrame)
    self:Setup(RemixArtifactFrame.ButtonsParent.Overlay, {frame=RemixArtifactFrame})
end

function WoWTools_MoveMixin.Events:Blizzard_DelvesCompanionConfiguration()
    self:Setup(DelvesCompanionConfigurationFrame)
    self:Setup(DelvesCompanionAbilityListFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_HelpFrame()
    self:Setup(HelpFrame)
    --self:Setup(HelpFrame.TitleContainer, {frame=HelpFrame})
end



function WoWTools_MoveMixin.Events:Blizzard_GuildRename()--11.1.5
    self:Setup(GuildRenameFrame)
end


--FSTACK
function WoWTools_MoveMixin.Events:Blizzard_DebugTools()



    local function Set_Line(frame, line)
        local width= frame:GetWidth()
        local keyWidth= width/4
        if line.Key then
            line.Key:SetWidth(keyWidth)
            line.Key.Text:SetPoint('RIGHT')
        end
        if line.ValueButton then
            line.ValueButton:SetPoint('RIGHT', frame, -23, 0)
            line.ValueButton.Text:SetPoint('RIGHT')
        end
        if line.Value then
            line.Value:SetPoint('RIGHT', frame, -23, 0)
        end
    end

     local function set_frame(frame)
        frame.LinesScrollFrame:ClearAllPoints()
        frame.LinesScrollFrame:SetPoint('TOPLEFT', 6, -62)
        frame.LinesScrollFrame:SetPoint('BOTTOMRIGHT', -36, 22)
        --frame.FilterBox:SetPoint('RIGHT', -26,0)
        frame.TitleButton.Text:SetPoint('RIGHT')

       WoWTools_DataMixin:Hook(frame, 'UpdateLines', function(f)
            if f.dataProviders then
                for _, line in ipairs(f.lines) do
                    Set_Line(f, line)
                end
            end
        end)
    end
    set_frame(TableAttributeDisplay)


    WoWTools_DataMixin:Hook(TableInspectorMixin, 'OnLoad', function(frame)
        set_frame(frame)

        frame:SetResizable(true)
        frame.ResizeButton= CreateFrame('Button', nil, frame, 'PanelResizeButtonTemplate')
        frame.ResizeButton:SetSize(18, 18)
        frame.ResizeButton:SetPoint('BOTTOMRIGHT', frame, 3, -3)
        frame.ResizeButton:Init(frame, 200, 150)
        frame.ResizeButton.setSize=true
        WoWTools_TextureMixin:SetButton(frame.ResizeButton, {alpha=0.5})
        frame.ResizeButton:SetScript("OnMouseUp", function(...)
            WoWTools_MoveMixin:Set_OnMouseUp(...)
        end)
        frame.ResizeButton:SetScript("OnMouseDown", function(...)
            WoWTools_MoveMixin:Set_OnMouseDown(...)
        end)
    end)


    WoWTools_DataMixin:Hook(TableAttributeLineReferenceMixin, 'Initialize', function(line)
        local frame= line:GetParent():GetParent():GetParent()
        local btn= frame.ResizeButton
        if btn and btn.setSize then
            Set_Line(frame, line)
        end
    end)

    self:Setup(TableAttributeDisplay, {
        minW=330,
        minH=150,
        sizeUpdateFunc=function(frame)
            frame:UpdateLines()--RefreshAllData()
        end,
        sizeRestFunc=function(f)
            f:SetSize(500, 400)
        end,
    })
end


--Shared
--Blizzard_AuctionHouseTableBuilder.lua
function WoWTools_MoveMixin.Events:Blizzard_AuctionHouseUI()
    AuctionHouseMultisellProgressFrame:HookScript('OnShow', function(frame)
        frame:ClearAllPoints()
        frame:SetPoint('TOPRIGHT', AuctionHouseFrame, 'BOTTOMRIGHT', 0, -2)
    end)

    AuctionHouseFrame.CategoriesList:SetPoint('BOTTOM', AuctionHouseFrame.MoneyFrameBorder.MoneyFrame, 'TOP',0,2)
    AuctionHouseFrame.BrowseResultsFrame.ItemList.HeaderContainer:SetPoint('RIGHT')
    AuctionHouseFrame.BrowseResultsFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')

    AuctionHouseFrameAuctionsFrame.SummaryList.Background:SetPoint('BOTTOM')
    AuctionHouseFrameAuctionsFrame.AllAuctionsList.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrameAuctionsFrame.BidsList.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrame.WoWTokenResults.BuyoutLabel:ClearAllPoints()
    AuctionHouseFrame.WoWTokenResults.BuyoutLabel:SetPoint('BOTTOM', AuctionHouseFrame.WoWTokenResults.Buyout, 'TOP', 0, 32)
    AuctionHouseFrame.WoWTokenResults.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.Background:SetPoint('BOTTOM')
    AuctionHouseFrame.CommoditiesBuyFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')

    AuctionHouseFrame.ItemBuyFrame.ItemList.HeaderContainer:SetPoint('RIGHT')
    AuctionHouseFrame.ItemBuyFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')

    AuctionHouseFrame.ItemBuyFrame.ItemDisplay:SetPoint('RIGHT',-3, 0)
    AuctionHouseFrame.ItemBuyFrame.ItemDisplay.Background:SetPoint('RIGHT')

    WoWTools_DataMixin:Hook(AuctionHouseFrame, 'SetDisplayMode', function(frame, mode)
        local size= self:Save().size[frame:GetName()]
        local btn= frame.ResizeButton
        if not size or not btn then
            return
        end

        if mode==AuctionHouseFrameDisplayMode.ItemSell or mode==AuctionHouseFrameDisplayMode.CommoditiesSell then
            frame:SetSize(800, 538)
            btn.minWidth = 800
            btn.minHeight = 538
            btn.maxWidth = 800
            btn.maxHeight = 538
        else
            frame:SetSize(size[1], size[2])
            btn.minWidth = 600
            btn.minHeight = 320
            btn.maxWidth = nil
            btn.maxHeight = nil
        end
    end)

    --AuctionHouseItemListMixin:UpdateTableBuilderLayout() TableBuilderMixin:ArrangeHeaders()
    local function Rest()
        for _, frame in pairs({
            AuctionHouseFrame.BrowseResultsFrame.ItemList,

            AuctionHouseFrameAuctionsFrame.AllAuctionsList,
            AuctionHouseFrameAuctionsFrame.ItemList,
            AuctionHouseFrameAuctionsFrame.CommoditiesList,
            AuctionHouseFrameAuctionsFrame.BidsList,

            AuctionHouseFrame.ItemSellList,
            AuctionHouseFrame.ItemBuyFrame.ItemList,

        }) do

            if frame.UpdateTableBuilderLayout and not frame.tableBuilderLayoutDirty then
                frame.tableBuilderLayoutDirty=true
                if frame.tableBuilder then
                    frame:UpdateTableBuilderLayout()
                end
            end
        end
    end

    self:Setup(AuctionHouseFrame, {
        sizeUpdateFunc=Rest,
        sizeRestFunc=function(f)
            f:SetSize(800, 538)
            Rest()
        end
    })


    self:Setup(AuctionHouseFrame.ItemSellFrame, {frame=AuctionHouseFrame})
    self:Setup(AuctionHouseFrame.ItemSellFrame.Overlay, {frame=AuctionHouseFrame})
    self:Setup(AuctionHouseFrame.ItemSellFrame.ItemDisplay, {frame=AuctionHouseFrame})

    self:Setup(AuctionHouseFrame.CommoditiesSellFrame, {frame=AuctionHouseFrame})
    self:Setup(AuctionHouseFrame.CommoditiesSellFrame.Overlay, {frame=AuctionHouseFrame})
    self:Setup(AuctionHouseFrame.CommoditiesSellFrame.ItemDisplay, {frame=AuctionHouseFrame})

    self:Setup(AuctionHouseFrame.ItemBuyFrame.ItemDisplay, {frame=AuctionHouseFrame, save=true})
    self:Setup(AuctionHouseFrameAuctionsFrame.ItemDisplay, {frame=AuctionHouseFrame, save=true})
end


function WoWTools_MoveMixin.Events:Blizzard_AchievementUI()
    AchievementFrameCategories:ClearAllPoints()
    AchievementFrameCategories:SetPoint('TOPLEFT', 21, -19)
    AchievementFrameCategories:SetPoint('BOTTOMLEFT', 175, 19)

    AchievementFrameMetalBorderRight:SetPoint('TOP', AchievementFrameMetalBorderTopRight, 'BOTTOM')
    AchievementFrameMetalBorderLeft:SetPoint('TOP', AchievementFrameMetalBorderTopLeft, 'BOTTOM')
    AchievementFrameMetalBorderRight:SetPoint('BOTTOM', AchievementFrameMetalBorderBottomRight, 'TOP')
    AchievementFrameMetalBorderLeft:SetPoint('BOTTOM', AchievementFrameMetalBorderBottomLeft, 'TOP')

    --WoWTools_DataMixin:Hook(AchievementTemplateMixin, 'OnLoad', function(f)
    WoWTools_DataMixin:Hook(AchievementTemplateMixin, 'OnLoad', function(f)
        f.Label:SetPoint('RIGHT', f.Shield.Icon, 'LEFT')
        f.Label:SetPoint('LEFT', f.PlusMinus, 'RIGHT')

        f.Description:SetPoint('RIGHT', f.Shield.Icon, 'LEFT')
        f.Description:SetPoint('LEFT', f.Icon, 'RIGHT')

        f.Reward:SetPoint('RIGHT', f.Shield.Icon, 'LEFT')
        f.Reward:SetPoint('LEFT', f.Icon, 'RIGHT')
    end)
    --WoWTools_DataMixin:Hook('AchievementObjectives_DisplayProgressiveAchievement', function(objectivesFrame, id)



    local left= -38
    AchievementFrameAchievements:SetPoint('RIGHT', left, 0)
    AchievementFrameStats:SetPoint('RIGHT', left, 0)
    AchievementFrameSummary:SetPoint('RIGHT', left, 0)

    AchievementFrameStatsBG:SetPoint('RIGHT')

    AchievementFrameComparison:SetPoint('RIGHT')

    AchievementFrameComparison.AchievementContainer:SetPoint('RIGHT', left, 0)

    AchievementFrameComparison.Summary:SetPoint('RIGHT', left, 0)
    AchievementFrameComparison.Summary.Player:SetPoint('RIGHT', -120, 0)
    AchievementFrameComparison.AchievementContainer.ScrollBar:SetPoint('TOPLEFT', AchievementFrameComparison.Summary, 'TOPRIGHT', 5, -5)
    WoWTools_DataMixin:Hook(AchievementComparisonTemplateMixin, 'OnLoad', function(f)
        f.Player:SetPoint('RIGHT', -120, 0)
    end)
    AchievementFrameComparison.StatContainer:SetPoint('RIGHT', left, 0)


    AchievementFrame.Header:ClearAllPoints()
    AchievementFrame.Header:SetPoint('BOTTOM', AchievementFrame, 'TOP', 0, -38)

    AchievementFrameFilterDropdown:ClearAllPoints()
    AchievementFrameFilterDropdown:SetPoint('CENTER', AchievementFrame.Header.LeftDDLInset, -2, 3)


    self:Setup(AchievementFrame, {
        minW=768,
        minH=500,
        sizeRestFunc= function(f)
            f:SetSize(768, 500)
        end,
    })
    self:Setup(AchievementFrame.Header, {frame=AchievementFrame})

    self:Setup(AchievementFrameComparisonHeader, {frame=AchievementFrame})
    self:Setup(AchievementFrameComparison, {frame=AchievementFrame})
    self:Setup(AchievementFrameComparison.AchievementContainer, {frame=AchievementFrame})

    WoWTools_DataMixin:Hook(AchievementFrame, 'SetWidth', function(f)
        if f.ResizeButton and not f.ResizeButton.isActiveButton then
            self:Set_SizeScale(f)
        end
    end)

    AchievementFrame.SearchResults:SetPoint('TOP', 0, -14)
    self:Setup(AchievementFrame.SearchResults, {frame=AchievementFrame})
end


function WoWTools_MoveMixin.Events:Blizzard_Channels()
    self:Setup(CreateChannelPopup)

    WoWTools_DataMixin:Hook(ChannelRosterButtonMixin, 'OnLoad', function(btn)
        btn.Name:SetPoint('RIGHT')
    end)
    self:Setup(ChannelFrame, {
        minW=402, minH=200,-- maxW=402,
    sizeRestFunc=function(f)
        f:SetSize(402, 423)
    end})
end

function WoWTools_MoveMixin.Events:Blizzard_Settings_Shared()
    for _, region in pairs({SettingsPanel:GetRegions()}) do
        if region:IsObjectType('Texture') then
            region:SetPoint('BOTTOMRIGHT', -12, 38)
        end
    end
    self:Setup(SettingsPanel, {
        minW=800,
        minH=200,
    sizeRestFunc=function(f)
        f:SetSize(920, 724)
    end})
end


function WoWTools_MoveMixin.Events:Blizzard_ChatFrame()
    CombatConfigFormattingExampleString1:SetPoint('RIGHT')
    CombatConfigFormattingExampleString2:SetPoint('RIGHT')

    self:Setup(ChatConfigFrame)
    self:Setup(ChatConfigFrame.Header, {frame=ChatConfigFrame})
    self:Setup(ChatConfigFrame.Border, {frame=ChatConfigFrame})
end


function WoWTools_MoveMixin.Events:Blizzard_GameMenu()
    self:Setup(GameMenuFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_ActionBar()
    self:Setup(ExtraActionButton1, {click='RightButton', notSave=true, notMoveAlpha=true})
end

function WoWTools_MoveMixin.Events:Blizzard_UnitFrame()
    --self:Setup(PartyFrame.Background, {frame=PartyFrame, notZoom=true, notSave=true})

    self:Setup(OpacityFrame)
    self:Setup(ArcheologyDigsiteProgressBar, {notZoom=true})
    self:Setup(VehicleSeatIndicator, {notZoom=true, notSave=true})
    --self:Setup(ExpansionLandingPage)
    self:Setup(PlayerPowerBarAlt, {notMoveAlpha=true})

    if BattleTagInviteFrame then--ya no existe en 12.0
        self:Setup(BattleTagInviteFrame)
    end

    for _, barContainer in ipairs(StatusTrackingBarManager.barContainers or {}) do
        self:Setup(barContainer, {alpha=0})
    end

    self:Setup(OverrideActionBar, {notMoveAlpha=true})
    self:Setup(OverrideActionBarExpBar, {frame=OverrideActionBar})

    self:Setup(ReportFrame)
end


function WoWTools_MoveMixin.Events:Blizzard_EventTrace()
    EventTrace.Log.Bar.SearchBox:SetPoint('LEFT', EventTrace.Log.Bar.Label, 'RIGHT')
    EventTrace.Log.Bar.SearchBox:SetScript('OnEditFocusGained', function(frame)
        frame:HighlightText()
    end)
    self:Setup(EventTrace)
end


function WoWTools_MoveMixin.Events:Blizzard_AccountStore()
    self:Setup(AccountStoreFrame, {
        minH=537,
        minW=800,
    sizeRestFunc=function(f)
        f:SetSize(800, 537)
    end})
end


function WoWTools_MoveMixin.Events:Blizzard_ProfessionsBook()
    self:Setup(ProfessionsBookFrame)
end


--LFDRoleCheckPopup
function WoWTools_MoveMixin.Events:Blizzard_StaticPopup()
    --movibles pero sin guardar posición: si no, popups distintos caían en el mismo sitio y se solapaban
    WoWTools_DataMixin:Hook('StaticPopup_SetUpPosition', function(dialog)
        if not dialog.moveFrameData then
            self:Setup(dialog, {notSave=true})
        end
    end)

end




function WoWTools_MoveMixin.Events:Blizzard_DurabilityFrame()
    self:Setup(DurabilityFrame, {notSave=true, notZoom=true})
end


function WoWTools_MoveMixin.Events:Blizzard_CooldownViewer()
    local function on_settings(frame)
        local w=frame.CooldownScroll:GetWidth()
        local value= math.max(3, math.modf(w/46))

        local pool= frame.categoryPool:GetPool('CooldownViewerSettingsCategoryTemplate')
        if pool then
            for f in pool:EnumerateActive() do
                if f.Container.stride~=value then
                    f.Container.stride = value
                    f:Layout()
                end
                f:SetPoint('RIGHT', frame.CooldownScroll)
            end
        end

        pool= frame.categoryPool:GetPool('CooldownViewerSettingsBarCategoryTemplate')
        if pool then
            for f in pool:EnumerateActive() do
                f:SetPoint('RIGHT', frame.CooldownScroll)
                f.Container:SetPoint('RIGHT', -17, 0)
            end
        end
    end

    CooldownViewerSettings:HookScript('OnSizeChanged', function(frame)
        on_settings(frame)
    end)

    WoWTools_DataMixin:Hook(CooldownViewerSettings, 'RefreshLayout', function(frame)
       on_settings(frame)
    end)

    WoWTools_DataMixin:Hook(CooldownViewerSettingsBarItemMixin, 'RefreshData', function(frame)
        frame.Bar:SetPoint('RIGHT', CooldownViewerSettings.CooldownScroll, -17, 0)
    end)

    CooldownViewerSettings.SearchBox:SetPoint('RIGHT', -45, 0)

    self:Setup(CooldownViewerSettings, {
        minW=196, minH=183,
    sizeRestFunc=function(f)
        f:SetSize(399, 609)
    end
    })
end


function WoWTools_MoveMixin.Events:Blizzard_AlliedRacesUI()
    self:Setup(AlliedRacesFrame)
end



function WoWTools_MoveMixin.Events:Blizzard_CompactRaidFrames()

    WoWTools_DataMixin:Hook('CompactRaidFrameManager_Expand', function()
        if CompactRaidFrameManager:CanChangeAttribute() then
            CompactRaidFrameManager:ClearAllPoints()
            local p= self:Save().point['CompactRaidFrameManager']
            if p and p[1] then
                CompactRaidFrameManager:SetPoint(p[1], UIParent, p[3], p[4], p[5])
            else
                CompactRaidFrameManager:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -140)
            end
            CompactRaidFrameManager:SetMovable(true)
            CompactRaidFrameManager:SetFrameStrata('MEDIUM')
            local s= self:Save().scale['CompactRaidFrameManager']
            if s and s~=1 then
                CompactRaidFrameManager:SetScale(s)
            end
        end
        CompactRaidFrameManager.ResizeButton:SetShown(true)
        self:Save().CompactRaidFrameManagerIsExpand= true
    end)
    WoWTools_DataMixin:Hook('CompactRaidFrameManager_Collapse', function()
        if CompactRaidFrameManager:CanChangeAttribute() then
            CompactRaidFrameManager:ClearAllPoints()
            CompactRaidFrameManager:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -200, -140)
            CompactRaidFrameManager:SetMovable(false)
            CompactRaidFrameManager:SetFrameStrata('BACKGROUND')
            if CompactRaidFrameManager:GetScale()~=1 then
                CompactRaidFrameManager:SetScale(1)
            end
        end
        CompactRaidFrameManager.ResizeButton:SetShown(false)
        self:Save().CompactRaidFrameManagerIsExpand= nil
    end)

    self:Setup(CompactRaidFrameManager, {
    restPointFunc=function()
        WoWTools_DataMixin:Call('CompactRaidFrameManager_Expand')
    end})


    if self:Save().CompactRaidFrameManagerIsExpand then
        WoWTools_DataMixin:Call('CompactRaidFrameManager_Expand')
    else
        WoWTools_DataMixin:Call('CompactRaidFrameManager_Collapse')
    end
end



function WoWTools_MoveMixin.Events:Blizzard_SharedWidgetFrames()
    self:Setup(UIWidgetCenterDisplayFrame)
end
