
local function Save()
    return WoWToolsPlusSave['ChatButton_Invite'] or {}
end



function WoWTools_InviteMixin:SetFocusButton(frame)
    if not frame or not Save().setFucus or frame.isSetFoucs then
        return

    elseif not frame:CanChangeAttribute() then
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
            self:SetFocusButton(frame)
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end)
        return
    end

    local key= strlower(Save().focusKey or 'Shift')
    if frame==FocusFrame then
        frame:SetAttribute(key..'-type1','macro')
        frame:SetAttribute(key..'-macrotext1','/clearfocus')
    else
        frame:SetAttribute(key..'-type1', 'focus')
        frame:SetAttribute(key..'-type2', 'macro')
        frame:SetAttribute(key..'-macrotext2', '/clearfocus')
    end

    frame.isSetFoucs= true


end





local function Init()
    if not Save().setFucus then
        return
    end

    local key= strlower(Save().focusKey or 'Shift')
    local clear= CreateFrame('Button', 'WoWToolsClearFocusButton', UIParent, 'SecureActionButtonTemplate')
    clear:SetAttribute('type','macro')
    clear:SetAttribute('macrotext','/clearfocus')
    clear:RegisterForClicks(WoWTools_DataMixin.RightButtonDown)
    WoWTools_KeyMixin:SetButtonKey(clear, true, strupper(key)..'-BUTTON2', nil)

    local over= CreateFrame('Button', 'WoWToolsOverFocusButton', UIParent, 'SecureActionButtonTemplate')
    over:SetAttribute("type", "focus")
    over:SetAttribute('unit', 'mouseover')

    over:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown)--, WoWTools_DataMixin.RightButtonDown)
    WoWTools_KeyMixin:SetButtonKey(over, true, strupper(key)..'-BUTTON1', nil)



    WoWTools_InviteMixin:SetFocusButton(PlayerFrame)
    WoWTools_InviteMixin:SetFocusButton(PetFrame)
    WoWTools_InviteMixin:SetFocusButton(TargetFrame)
    WoWTools_InviteMixin:SetFocusButton(TargetFrameToT)
    WoWTools_InviteMixin:SetFocusButton(FocusFrame)
    WoWTools_InviteMixin:SetFocusButton(FocusFrameToT)

    for i=1, MAX_PARTY_MEMBERS do
        WoWTools_InviteMixin:SetFocusButton(PartyFrame['MemberFrame'..i])
        WoWTools_InviteMixin:SetFocusButton(_G['CompactPartyFrameMember'..i])
    end

    for i=1, MAX_BOSS_FRAMES do--boss
        WoWTools_InviteMixin:SetFocusButton(_G['Boss'..i..'TargetFrame'])

    end

    WoWTools_DataMixin:Hook('CompactRaidGroup_InitializeForGroup', function(self)
        for i=1, MEMBERS_PER_RAID_GROUP do
            WoWTools_InviteMixin:SetFocusButton(_G[self:GetName().."Member"..i])
        end
    end)

    Init=function()end
end













function WoWTools_InviteMixin:Init_Focus()
    Init()
end

