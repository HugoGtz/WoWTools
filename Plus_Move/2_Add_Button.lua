local function Set_Tooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MoveMixin.addName)
    GameTooltip:AddLine(format('|cffff00ff%s|r', self.name))
    GameTooltip:AddLine(' ')


    GameTooltip:AddDoubleLine(
        WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL,
        WoWTools_DataMixin.Icon.right
    )
    GameTooltip:AddDoubleLine(
        WoWTools_L.NPE_MOVE,
        'Alt+'..WoWTools_DataMixin.Icon.right
    )
    if self.setZoom then
        GameTooltip:AddDoubleLine(
            (WoWTools_L.HOUSING_EXPERT_DECOR_SUBMODE_SCALE)..' |cnGREEN_FONT_COLOR:'..(WoWTools_MoveMixin:Save().scale[self.name] or 1),
            'Alt+'..WoWTools_DataMixin.Icon.mid
        )
    end
    GameTooltip:Show()
end


local function Init_Menu(self, root)
    if self.setZoom then
        WoWTools_MenuMixin:Scale(self, root, function()
            return WoWTools_MoveMixin:Save().scale[self.name] or 1
        end, function(value)
            local frame= self:GetParent()
            if frame:CanChangeAttribute() then
                WoWTools_MoveMixin:Save().scale[self.name]= value
                frame:SetScale(value)
            end
        end)
    end

    root:CreateButton(
        '|A:characterundelete-RestoreButton:0:0|a'
        ..(WoWTools_MoveMixin:Save().point[self.name] and '' or '|cff828282')
        ..(WoWTools_L.RESET_POSITION),
    function()
        WoWTools_MoveMixin:Save().point[self.name]= nil
        local p=self.pointSave
        if p and p[1] then
            local frame= self:GetParent()
            frame:ClearAllPoints()
            frame:SetPoint(p[1], p[2] or UIParent, p[3], p[4], p[5])
        end
        return MenuResponse.Open
    end)

    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {
        name=WoWTools_MoveMixin.addName,
        category=WoWTools_MoveMixin.Category
    })
end


local function SetupButton(frame, tab)
    tab= tab or {}
    local name
    --if frame and not WoWTools_MoveMixin:Save().disabledMove and not frame.WoWToolsMoveButton then
    if frame and not frame.WoWToolsMoveButton then
        name= tab.name or frame:GetName()
    end
    if not name then
        return
    end

    tab= tab or {}
    local setZoom= not tab.notZoom-- and not WoWTools_MoveMixin:Save().disabledZoom
    --local click= tab.click
    local setPoint= tab.setPoint
    local size= tab.size or 23
    local alpha= tab.alpha or 0.3

    local btn= WoWTools_ButtonMixin:Cbtn(frame, {
        texture='Interface\\Cursor\\UI-Cursor-Move',
        size=size,
        name='WoWToolsMoveButton_'..name
    })

    btn.name= name
    btn.setZoom= setZoom
    --btn.click= click
    btn.alpha= alpha
    btn.pointSave= {frame:GetPoint(1)}

    function btn:set_alpha()
        if self.alpha~=1 then
            self:SetAlpha(self:IsMouseOver() and 1 or self.alpha)
        end
    end
    btn:set_alpha()

    if setPoint then
        setPoint(btn)
    else
        btn:SetPoint('BOTTOM', frame, 'TOP')
    end
    btn:SetFrameLevel(frame:GetFrameLevel()+7)-- 9999)

    btn:SetScript("OnLeave", function(self)
        ResetCursor()
        GameTooltip:Hide()
        self:set_alpha()
    end)
    btn:SetScript("OnEnter",function(self)
        Set_Tooltip(self)
        self:set_alpha()
    end)

    btn:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            MenuUtil.CreateContextMenu(self, function(...)
                Init_Menu(...)
            end)
        end
    end)

    if setZoom then
        local scale= WoWTools_MoveMixin:Save().scale[name]
        if scale and scale~=1 then
            if WoWTools_FrameMixin:IsLocked(frame) then--tras /reload en combate: esperar
                EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
                    frame:SetScale(scale)
                    EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
                end)
            else
                frame:SetScale(scale)
            end
        end

        btn:SetScript('OnMouseWheel', function(self, delta)
            WoWTools_MoveMixin:Save().scale[self.name]= WoWTools_FrameMixin:ScaleFrame(
                self:GetParent(),
                delta,
                WoWTools_MoveMixin:Save().scale[self.name]
            )
            Set_Tooltip(self)
        end)
    end

    tab.frame= frame
    

    --tab.name= name
    tab.click= 'RightButton'
    tab.isAltKeyDown= true

    WoWTools_MoveMixin:Setup(btn, tab)

    frame.WoWToolsMoveButton= btn
    return btn
end


local function Init_UIWidgetPowerBarContainerFrame()
    local frame= UIWidgetPowerBarContainerFrame
    if not frame then
        return
    end

    SetupButton(frame)


    if frame.WoWToolsMoveButton then
        local find=false
        for _, f in pairs(frame.widgetFrames or {}) do
            if f then
                find=true
                break
            end
        end
        if not find then
            if frame.WoWToolsMoveButton then
                frame.WoWToolsMoveButton:Hide()
            end
        end
    end

    WoWTools_DataMixin:Hook(frame, 'CreateWidget', function(self)
        if self.WoWToolsMoveButton then
            self.WoWToolsMoveButton:SetShown(true)
        end
    end)
    WoWTools_DataMixin:Hook(frame, 'RemoveWidget', function(self)
        if self.WoWToolsMoveButton then
            self.WoWToolsMoveButton:SetShown(false)
        end
    end)
    WoWTools_DataMixin:Hook(frame, 'RemoveAllWidgets', function(self)
        if self.WoWToolsMoveButton then
            self.WoWToolsMoveButton:SetShown(false)
        end
    end)

end


local function Init()
    SetupButton(ZoneAbilityFrame)

    Init_UIWidgetPowerBarContainerFrame()

    SetupButton(PetBattleFrame.BottomFrame, {
        name='PetBattleFrame_BottomFrame',
        size= {20, 26},
        setPoint=function(button)
            button:SetPoint('BOTTOMRIGHT', PetBattleFrame.BottomFrame.MicroButtonFrame, -4, 0)
        end,
    })

    C_Timer.After(4, function()
        SetupButton(QueueStatusButton, {save=true, notZoom=true, show=true})

        WoWTools_DataMixin:Hook(EditModeManagerFrame, 'ExitEditMode', function()
            WoWTools_MoveMixin:SetPoint(QueueStatusButton)
        end)
    end)

    Init=function()end
end


function WoWTools_MoveMixin:Init_AddButton()
    Init()
end

