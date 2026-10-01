local Frame

local function Set_Text(self)
    WoWTools_ChallengeMixin:ActivitiesFrame(self, {isPvP=not WoWTools_ChallengeMixin:Save().activitiesHidePvP})
end









local function Init()
    if WoWTools_ChallengeMixin:Save().hideActivities then
        return
    end

    Frame= CreateFrame('Frame', nil, ChallengesFrame)
    Frame:SetFrameStrata('HIGH')
    Frame:SetFrameLevel(3)
    Frame:SetSize(1,1)
    Frame:Hide()

    function Frame:Settings()
        local show= not WoWTools_ChallengeMixin:Save().hideActivities
        self:SetPoint('TOPLEFT', ChallengesFrame, 'TOPLEFT', WoWTools_ChallengeMixin:Save().activitiesX or 10, WoWTools_ChallengeMixin:Save().activitiesY or -53)
        self:SetShown(show)
        self:SetScale(WoWTools_ChallengeMixin:Save().activitiesScale or 1)
     end

    Frame:Settings()

    Frame:SetScript('OnShow', function(self)
        Set_Text(self)
        self:RegisterEvent('MYTHIC_PLUS_CURRENT_AFFIX_UPDATE')
        self:RegisterEvent('MYTHIC_PLUS_NEW_WEEKLY_RECORD')
    end)
    Frame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        WoWTools_ChallengeMixin:ActivitiesFrame(Frame, {isClear=true})
    end)
    Frame:SetScript('OnEvent', function(self)
        Set_Text(self)
    end)

    Init= function()
        Frame:SetShown(false)
        Frame:Settings()
    end
end

function WoWTools_ChallengeMixin:ChallengesUI_Activities()
    Init()
end
