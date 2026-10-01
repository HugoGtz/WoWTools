
local FramerateButton











local function Init()
    if not WoWTools_MainMenuMixin:Save().frameratePlus then
        return
    end

    FramerateButton= WoWTools_ButtonMixin:Cbtn(FramerateFrame, {size=14, name='WoWToolsPlusFramerateButton'})
    FramerateButton:SetPoint('RIGHT',FramerateFrame.FramerateText)

    FramerateButton:SetMovable(true)
    FramerateButton:RegisterForDrag("RightButton")
    FramerateButton:SetClampedToScreen(true)
    FramerateButton:SetScript("OnDragStart", function(_, d)
        if d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
            local frame= FramerateFrame
            if not frame:IsMovable()  then
                frame:SetMovable(true)
            end
            frame:StartMoving()
        end
    end)
    FramerateButton:SetScript("OnDragStop", function()
        local self= FramerateFrame
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            WoWTools_MainMenuMixin:Save().frameratePoint={self:GetPoint(1)}
            WoWTools_MainMenuMixin:Save().frameratePoint[2]=nil
        end
    end)
    FramerateButton:SetScript("OnMouseUp", ResetCursor)
    FramerateButton:SetScript('OnMouseDown', function(_, d)
        if d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)


    function FramerateButton:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(MicroButtonTooltipText(FRAMERATE_LABEL, "TOGGLEFPS"))
        GameTooltip:AddDoubleLine(WoWTools_L.NPE_MOVE, WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_L.FONT_SIZE, (WoWTools_MainMenuMixin:Save().framerateSize or 12)..WoWTools_DataMixin.Icon.mid)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MainMenuMixin.addName)
        GameTooltip:Show()
    end
    FramerateButton:SetScript('OnLeave', GameTooltip_Hide)
    FramerateButton:SetScript('OnEnter', FramerateButton.set_tooltips)

    FramerateButton:SetScript('OnMouseWheel',function(self, d)
        if IsModifierKeyDown() then
            return
        end
        local size=WoWTools_MainMenuMixin:Save().framerateSize or 12
        if d==1 then
            size=size+1
            size = size>72 and 72 or size
        elseif d==-1 then
            size=size-1
            size= size<6 and 6 or size
        end
        WoWTools_MainMenuMixin:Save().framerateSize=size
        self:set_size()
        self:set_tooltips()
    end)

    function FramerateButton:set_size()
        WoWTools_LabelMixin:Create(nil, {size=WoWTools_MainMenuMixin:Save().framerateSize or 12, changeFont=FramerateFrame.FramerateText, color=true})--WoWTools_MainMenuMixin:Save().size, nil , Labels.fpsms, true)    
    end
    FramerateButton:set_size()

    FramerateFrame.Label:SetText('')
    FramerateFrame.Label:SetShown(false)
    FramerateFrame:SetMovable(true)
    FramerateFrame:SetClampedToScreen(true)
    FramerateFrame:HookScript('OnShow', function(self)
        if WoWTools_MainMenuMixin:Save().frameratePoint and FramerateFrame then
            self:ClearAllPoints()
            self:SetPoint(WoWTools_MainMenuMixin:Save().frameratePoint[1], UIParent, WoWTools_MainMenuMixin:Save().frameratePoint[3], WoWTools_MainMenuMixin:Save().frameratePoint[4], WoWTools_MainMenuMixin:Save().frameratePoint[5])
        end
    end)
    FramerateFrame:SetFrameStrata('HIGH')

    if WoWTools_MainMenuMixin:Save().framerateLogIn and not FramerateFrame:IsShown() then
        FramerateFrame:Toggle()
    end

    Init=function()end
end





function WoWTools_MainMenuMixin:Init_Framerate_Plus()
    Init()
end