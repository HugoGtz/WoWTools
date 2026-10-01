
local Init= WoWTools_Once(function()
    --if WoWTools_AttributesMixin:Save().disabledVehicleSpeed then
        --return
    --end

    for _, name in pairs({
        'MainMenuBarVehicleLeaveButton',
        'OverrideActionBarLeaveFrameLeaveButton',
        'MainActionBarVehicleLeaveButton',
    }) do
        local frame= _G[name]
        if frame and not frame.speedText then--evitar crear el texto y el hook dos veces
            frame.speedText= WoWTools_LabelMixin:Create(frame, {mouse=true})
            frame.speedText:SetPoint('TOP')
            frame.speedText:SetScript('OnLeave', GameTooltip_Hide)
            frame.speedText:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine(WoWTools_L.REFORGE_CURRENT, WoWTools_L.STAT_MOVEMENT_SPEED)
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_AttributesMixin.addName)
                GameTooltip:Show()
            end)
            frame.speedText:SetScript('OnMouseDown', function(self)
                local f= self:GetParent()
                if f.OnClicked then
                    f.OnClicked(f)
                end
            end)
            frame:HookScript('OnUpdate', function(self, elapsed)
                self.elapsed= (self.elapsed or 0.3) + elapsed
                if self.elapsed>0.3 then
                    self.elapsed= 0
                    local unit= PlayerFrame.displayedUnit or PlayerFrame.unit or 'player'
                    local speed= GetUnitSpeed(unit)
                    --self.speedText:SetText(math.modf(speed* 100 / BASE_MOVEMENT_SPEED))
                    self.speedText:SetText(AbbreviateNumbers(speed, WoWTools_AttributesMixin.SPEED_FORMAT_OPTIONS))
                end
            end)
            frame:HookScript('OnHide', function(self)
                self.elapsed= nil
            end)
        end
    end

end)








function WoWTools_AttributesMixin:Init_Vehicle_Speed()
    Init()
end