--法术按键, 颜色 ActionButton.lua

--restaura el color como ActionButton:UpdateUsable(), sin llamar al método del botón seguro (taint)
local function Set_UsableColor(frame)
    if not frame.action or not frame.icon then
        return
    end
    local isUsable, notEnoughMana= C_ActionBar.IsUsableAction(frame.action)
    if not canaccessvalue(isUsable) or not canaccessvalue(notEnoughMana) then
        return
    end
    if isUsable then
        frame.icon:SetVertexColor(1, 1, 1)
    elseif notEnoughMana then
        frame.icon:SetVertexColor(0.5, 0.5, 1)
    else
        frame.icon:SetVertexColor(0.4, 0.4, 0.4)
    end
end

local function Init()
    if not WoWToolsPlusSave['Plus_Spell'].actionButtonRangeColor then
        return
    end

    WoWTools_DataMixin:Hook('ActionButton_UpdateRangeIndicator', function(frame, checksRange, inRange)

        if not canaccessvalue(checksRange)
            or not canaccessvalue(inRange)
            or not canaccessvalue(frame.UpdateUsable)
        then
            return
        end

        if not frame.setHooksecurefunc and frame.UpdateUsable then
            WoWTools_DataMixin:Hook(frame, 'UpdateUsable', function(self)
                local isUsable= C_ActionBar.IsUsableAction(self.action)
                if not canaccessvalue(isUsable) or not isUsable then
                    return
                end
                local hasRange= C_ActionBar.HasRangeRequirements(self.action)
                if not canaccessvalue(hasRange) or not hasRange then
                    return
                end
                local inRange2= C_ActionBar.IsActionInRange(self.action)
                if canaccessvalue(inRange2) and inRange2==false then
                    self.icon:SetVertexColor(1,0,0)
                end
            end)
            frame.setHooksecurefunc= true
        end

    local hotKey= frame.HotKey:GetText()
       if not canaccessvalue(hotKey) then
            return
       end

        if ( frame.HotKey:GetText() == RANGE_INDICATOR ) then
            if ( checksRange ) then
                if ( inRange ) then
                    Set_UsableColor(frame)
                else
                    frame.icon:SetVertexColor(1,0,0)
                end
            end
        else
            if ( checksRange and not inRange ) then
                frame.icon:SetVertexColor(1,0,0)
            else
                Set_UsableColor(frame)
            end
        end
    end)


    Init=function()end
end





function WoWTools_SpellMixin:Init_ActionButton_UpdateRange()--法术按键, 颜色
    Init()
end