local function Save()
    return WoWToolsPlusSave['Minimap_Plus']
end





function WoWTools_MinimapMixin:ExpansionLanding_Menu(_, root)
    local tipSub= root:CreateCheckbox(
        (ExpansionLandingPageMinimapButton and '' or '|cff626262')
        ..'|A:dragonflight-landingbutton-up:0:0|a'..WoWTools_L['Hide garrison icon'],
    function()
        return Save().hideExpansionLandingPageMinimapButton
    end, function()
        Save().hideExpansionLandingPageMinimapButton= not Save().hideExpansionLandingPageMinimapButton and true or false
        Save().moveExpansionLandingPageMinimapButton=nil
        print(
            WoWTools_MinimapMixin.addName..WoWTools_DataMixin.Icon.icon2,
            '|cnGREEN_FONT_COLOR:',
            WoWTools_L.REQUIRES_RELOAD
        )
    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.MiniMap.HideLanding'])

    local tipSub= root:CreateCheckbox(
        '|A:dragonflight-landingbutton-up:0:0|a'..WoWTools_L['Move garrison icon'],
    function()
        return Save().moveExpansionLandingPageMinimapButton
    end, function()
        Save().moveExpansionLandingPageMinimapButton= not Save().moveExpansionLandingPageMinimapButton and true or false
        Save().hideExpansionLandingPageMinimapButton=nil
        print(
            WoWTools_MinimapMixin.addName..WoWTools_DataMixin.Icon.icon2,
            '|cnGREEN_FONT_COLOR:',
            WoWTools_L.REQUIRES_RELOAD
        )
    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.MiniMap.MoveLanding'])
end




function WoWTools_MinimapMixin:Init_ExpansionLanding()
    --要塞，图标
    if not ExpansionLandingPageMinimapButton then
        return
    end
    if Save().hideExpansionLandingPageMinimapButton then
        ExpansionLandingPageMinimapButton:SetShown(false)
        ExpansionLandingPageMinimapButton:HookScript('OnShow', function(frame)
            frame:SetShown(false)
        end)
    elseif Save().moveExpansionLandingPageMinimapButton then
        ExpansionLandingPageMinimapButton:SetFrameStrata('TOOLTIP')
        C_Timer.After(2, function()
            WoWTools_MoveMixin:Setup(ExpansionLandingPageMinimapButton, {
                --needMove=true,
                hideButton=true, click='RightButton',
            setResizeButtonPoint={
                nil, nil, nil, -2, 2
            }})
            C_Timer.After(8, function()--盟约图标停止闪烁
                ExpansionLandingPageMinimapButton.MinimapLoopPulseAnim:Stop()
            end)
        end)
    end
end