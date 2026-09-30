

--任务，追踪柆




















--追踪栏
function WoWTools_MoveMixin.Events:Blizzard_ObjectiveTracker()
    EventRegistry:RegisterCallback("EditMode.Exit", function()
        ObjectiveTrackerFrame:SetMovable(true)
    end)

    self:Setup(ObjectiveTrackerFrame.Header, {
        notSave=true,
        notZoom=true,
        frame=ObjectiveTrackerFrame,
    })
end
