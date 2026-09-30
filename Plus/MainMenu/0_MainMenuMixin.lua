WoWTools_MainMenuMixin={
    Labels={}
}

function WoWTools_MainMenuMixin:SetNotificationOverlay(button)
    if button.NotificationOverlay then
        button.NotificationOverlay:SetAlpha(0.4)
    end
end
