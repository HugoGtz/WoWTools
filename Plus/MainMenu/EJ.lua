 --冒险指南


local function Get_Perks_Info()
    local activitiesInfo = C_PerksActivities.GetPerksActivitiesInfo()--贸易站, 点数Blizzard_MonthlyActivities.lua
    if not activitiesInfo then
        return
    end
    local thresholdMax = 0
    for _, thresholdInfo in pairs(activitiesInfo.thresholds) do
        if thresholdInfo.requiredContributionAmount > thresholdMax then
            thresholdMax = thresholdInfo.requiredContributionAmount
        end
    end
    thresholdMax= thresholdMax == 0 and 1000 or thresholdMax
    local earnedThresholdAmount = 0
    for _, activity in pairs(activitiesInfo.activities) do
        if activity.completed then
            earnedThresholdAmount = earnedThresholdAmount + activity.thresholdContributionAmount
        end
    end
    earnedThresholdAmount = math.min(earnedThresholdAmount, thresholdMax)
    return earnedThresholdAmount, thresholdMax, C_CurrencyInfo.GetCurrencyInfo(2032), activitiesInfo
end


local function Init()
    local frame= CreateFrame('Frame')

    frame.Text= WoWTools_LabelMixin:Create(EJMicroButton,  {size=WoWToolsPlusSave['Plus_MainMenu'].size, color=true})
    --frame.Text:SetPoint('TOP', EJMicroButton, 0,  -3)
    frame.Text:SetPoint('BOTTOM', EJMicroButton, 0,  3)

    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text)

    function frame:settings()
        local text
        local cur, max, info= Get_Perks_Info()
        if cur then
            info =info or {}
            if cur== max then
                text= (info.quantity and WoWTools_DataMixin:MK(info.quantity, 1) or format('|A:%s:0:0|a', 'common-icon-checkmark'))
            else
                text= format('%i%%', cur/max*100)
            end
        end
        self.Text:SetText(text or '')
    end
    frame:RegisterEvent('CVAR_UPDATE')
    frame:RegisterEvent('PERKS_ACTIVITY_COMPLETED')
    frame:RegisterEvent('PERKS_ACTIVITIES_UPDATED')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    EJMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() or Kiosk.IsEnabled() then
            return
        end

        GameTooltip:AddLine(' ')

        local cur, max, info= Get_Perks_Info()
        if cur then
            info= info or {}

            if info.quantity then
                GameTooltip:AddDoubleLine(
                    (info.iconFileID  and '|T'..info.iconFileID..':0|t' or '|A:activities-complete-diamond:0:0|a')
                    ..info.quantity,
                    WoWTools_TextMixin:CN(info.name)
                )
            end
            GameTooltip:AddDoubleLine((cur==max and '|cnGREEN_FONT_COLOR:' or '|cffff00ff')..cur..'|r/'..max..format(' %i%%', cur/max*100), WoWTools_L.MONTHLY_ACTIVITIES_PROGRESSED)

        end

        local factionInfo= WoWTools_FactionMixin:GetCompanionInfo(nil, GameTooltip)
        if cur or factionInfo then
            GameTooltip:AddLine(' ')
        end

        local isCombat= InCombatLockdown() or DISALLOW_FRAME_TOGGLING

        GameTooltip:AddLine(
            (isCombat and '|cff626262' or '|cffffffff')
            ..(WoWTools_L.JOURNEYS_LABEL)..'|r'
            ..WoWTools_DataMixin.Icon.right
        )

        GameTooltip:AddLine(
            (not isCombat and factionInfo and factionInfo.configID and '|cffffffff' or '|cff626262' )
            ..(WoWTools_L.COVENANT_MISSIONS_FOLLOWERS)..'|r'
            ..WoWTools_DataMixin.Icon.mid
        )
        GameTooltip:Show()
    end)



    EJMicroButton:HookScript('OnClick', function(_, d)
        if d~='RightButton'
            or KeybindFrames_InQuickKeybindMode()
        then
            return
        end
        WoWTools_LoadUIMixin:OpenFaction()
    end)

    EJMicroButton:EnableMouseWheel(true)
    EJMicroButton:HookScript('OnMouseWheel', function(_, d)
        if KeybindFrames_InQuickKeybindMode() or Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING then
            return
        end

        if d==1 then
            WoWTools_LoadUIMixin:OpenCompanion()
        elseif d==-1 then
            if DelvesCompanionConfigurationFrame and DelvesCompanionConfigurationFrame:IsShown() then
                HideUIPanel(DelvesCompanionConfigurationFrame)
            end
        end
    end)

    Init=function()end
end


function WoWTools_MainMenuMixin:Init_EJ()--冒险指南
    Init()
end