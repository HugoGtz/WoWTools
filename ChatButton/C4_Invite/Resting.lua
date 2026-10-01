
local function Init()
    local frame= CreateFrame('Frame')
    WoWTools_InviteMixin.RestingFrame= frame

    frame.enterText= '|A:communities-icon-addgroupplus:0:0|a'..(
                    WoWTools_L['Enter |cnGREEN_FONT_COLOR:Rest|r Zone']
                )

    frame.leaveText= '|A:communities-icon-addgroupplus:0:0|a'..(
                    WoWTools_L['Leave |cnWARNING_FONT_COLOR:Rest|r Zone']
                )

    function frame:set_event()
        self:UnregisterAllEvents()
        if WoWTools_InviteMixin:Save().restingTips then
            self:RegisterEvent('PLAYER_UPDATE_RESTING')
        end
    end

    function frame:settings()
        WoWTools_Print(
            IsResting() and self.enterText or self.leaveText
        )
    end

    frame:SetScript("OnEvent", frame.settings)
    frame:set_event()
end








function WoWTools_InviteMixin:Init_Resting()
    Init()
end

function WoWTools_InviteMixin:Resting_Settings()
    self.RestingFrame:set_event()
    self.RestingFrame:settings()
end