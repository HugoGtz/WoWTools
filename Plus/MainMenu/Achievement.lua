





local Init= WoWTools_Once(function()
    local frame= CreateFrame('Frame')

    frame.Text= WoWTools_LabelMixin:Create(AchievementMicroButton,  {size=WoWTools_MainMenuMixin:Save().size, color=true})
    frame.Text:SetPoint('BOTTOM', AchievementMicroButton, 0,  3)
    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text)

    function frame:settings()
        local num
        num= GetTotalAchievementPoints() or 0
        num = num==0 and '' or WoWTools_DataMixin:MK(num, 1)
        self.Text:SetText(num)
    end
    frame:RegisterEvent('ACHIEVEMENT_EARNED')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    AchievementMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() or Kiosk.IsEnabled() then
            return
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            WoWTools_L.ACHIEVEMENT_POINTS,
            WoWTools_DataMixin:MK(GetTotalAchievementPoints(), 4),
            1,0.82,0, 1,1,1
        )
        if IsInGuild() then
            GameTooltip:AddDoubleLine(
                WoWTools_L.GUILD_ACHIEVEMENTS_TITLE,
                WoWTools_DataMixin:MK(GetTotalAchievementPoints(true), 4),
                1,0.82,0, 1,1,1
            )
        end
        GameTooltip:Show()
    end)

end)


function WoWTools_MainMenuMixin:Init_Achievement()
    Init()
end