WoWTools_MinimapMixin={}



local P_Save={
    scale=0.85,
    ZoomOutInfo=true,

    vigentteButtonShowText=true,
    vigentteButtonTextScale=1,
    hideVigentteCurrentOnMinimap=nil,
    hideVigentteCurrentOnWorldMap=nil,
    questIDs={},
    areaPoiIDs={[7943]= 2248},
    uiMapIDs= {},
    currentMapAreaPoiIDs=true,

    miniMapPoint={},



    useServerTimer=true,


    hideExpansionLandingPageMinimapButton= true,


    Icons={
        disabled= true,
        noAdd={
            --['BugSack']=true,
        },
        hideAdd={
            ['WoWToolsPlus']=true,
        },
        userAdd={},
        numLine=1,
        hideInMove= true,
        hideInCombat=true,
        isEnterShow=true,
        alphaBG=0,--bg
        bgAlpha=0.75,
        borderAlpha=0,
        bgAlpha2=0.75,
        borderAlpha2=0.5,
    },
}



local function Save()
    return  WoWToolsPlusSave['Minimap_Plus']
end













local function Init()
    for questID in pairs(Save().questIDs or {}) do
       WoWTools_DataMixin:Load(questID, 'quest')
    end
    do
        WoWTools_MinimapMixin:Init_Icon()
    end

    WoWTools_MinimapMixin:Init_InstanceDifficulty()
    WoWTools_MinimapMixin:Init_TrackButton()
    WoWTools_MinimapMixin:Init_ExpansionLanding()
    WoWTools_MinimapMixin:Init_Minimap_Zoom()

    Menu.ModifyMenu("MENU_MINIMAP_TRACKING", function(self, root)
        if not self:IsMouseOver() then
            return
        end
        root:CreateDivider()

        local sub=root:CreateCheckbox(
            (InCombatLockdown() and '|cff606060' or '')
            ..(WoWTools_L.TOWNSFOLK_TRACKING_TEXT)
            ..WoWTools_DataMixin.Icon.icon2,
        function()
            return C_CVar.GetCVarBool("minimapTrackingShowAll") and true or false
        end, function()
            if not InCombatLockdown() then
                if C_CVar.SetCVar('minimapTrackingShowAll', not C_CVar.GetCVarBool("minimapTrackingShowAll") and '1' or '0' ) then
                    return MenuResponse.CloseAll
                end
            end
        end)
        sub:SetTooltip(function(tooltip)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.MiniMap.Townsfolk'])
            tooltip:AddLine(WoWTools_MinimapMixin.addName..WoWTools_DataMixin.Icon.icon2)
            tooltip:AddLine([[SetCVar("minimapTrackingShowAll", "1")]])
        end)
        sub:AddInitializer(function(button)
            local rightTexture = button:AttachTexture()
            rightTexture:SetSize(20, 20)
            rightTexture:SetPoint("RIGHT")
            rightTexture:SetAtlas('poi-town')
            local fontString = button.fontString
            fontString:SetPoint("RIGHT", rightTexture, "LEFT")
        end)
    end)

    Init=function()end
end









local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Minimap_Plus']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Minimap_Plus'], P_Save)

            if not Save().Icons then
                Save().Icons= P_Save.Icons
                if Save().ZoomOut==true then
                    Save().ZoomOut='min'
                end
            end

            P_Save= nil

            WoWTools_MinimapMixin.addName= '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(WoWTools_L['Module.Minimap'])
            WoWTools_MinimapMixin.addName2= '|A:VignetteKillElite:0:0|a'..(WoWTools_L.TRACKING)

           WoWTools_PanelMixin:Check_Button({
                checkName= WoWTools_MinimapMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    if Save().disabled then
                        WoWTools_Print(
                            WoWTools_MinimapMixin.addName..WoWTools_DataMixin.Icon.icon2,
                            WoWTools_L.REQUIRES_RELOAD
                        )
                    else
                        Init()
                        WoWTools_MinimapMixin:Init_TimeManager()
                        WoWTools_MinimapMixin:Init_Collection_Icon()
                    end

                end,
                buttonText= WoWTools_L.RESET_POSITION,
                buttonFunc= function()
                    if StopwatchFrame.rest_point then
                        StopwatchFrame:rest_point()
                    end

                    WoWTools_MinimapMixin:Rest_TimeManager_Point()
                    WoWTools_MinimapMixin:Rest_TrackButton_Point()

                    Save().Icons.point=nil
                    WoWTools_MinimapMixin:Init_Collection_Icon()

                    WoWTools_Print(
                        WoWTools_MinimapMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_L.RESET_POSITION
                    )
                end,
                tooltip= WoWTools_L['Tip.MiniMap.Module'],
            })

            if Save().disabled then
                self:SetScript('OnEvent', nil)
                self:UnregisterAllEvents()
            else
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                Init()

                if C_AddOns.IsAddOnLoaded('Blizzard_TimeManager') then
                    WoWTools_MinimapMixin:Init_TimeManager()
                    self:UnregisterEvent(event)
                end
            end

        elseif arg1=='Blizzard_TimeManager' and WoWToolsPlusSave then
            WoWTools_MinimapMixin:Init_TimeManager()
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_MinimapMixin:Init_Collection_Icon()
        self:UnregisterEvent(event)
    end
end)