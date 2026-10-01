
local P_UIPanelWindows= {}



local function Set_Frame_Size(self, w, h)
    if not self:IsResizable() then
        self:SetResizable(true)
    end
    self:SetSize(w, h)
end

local function Set_Frame_Scale(self, scale)
    if WoWTools_FrameMixin:IsLocked(self) then
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner, info)
            info.frame:SetScale(info.scale)
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end, nil, {frame=self, scale= scale})
    else
        self:SetScale(scale)
    end
end


local function Save_Frame_Size(self)
    if not self.name then
        return
    end

    if self.sizeStopFunc then
        self.sizeStopFunc(_G[self.name], self)
    else
        local w, h= self:GetParent():GetSize()
        w= math.modf(w)
        h= math.modf(h)
        WoWTools_MoveMixin:Save().size[self.name]= {w, h}
    end
end



local function Set_ScalePercent(self, isSu)
    local target= self:GetParent()
    local w,h= target:GetSize()
    if isSu then
        w= w+ w* 0.1
        h= h+ h* 0.1
    else
        w= w- w* 0.1
        h= h- h* 0.1
    end
    local maxW= self.maxWidth or math.modf(UIParent:GetWidth())
    local maxH= self.maxHeight or math.modf(UIParent:GetHeight())

    if
        w<self.minWidth
        or h<self.minHeight
        or w>maxW
        or h>maxH
    then
        return
    end

    Set_Frame_Size(target, w, h)
    Save_Frame_Size(self)
end


local function FrameOnShow_SetPoint(self, isSet)
    local name= self.name
    local target= self:GetParent()

    local attributes= P_UIPanelWindows[name] or UIPanelWindows[name]
    if not target:CanChangeAttribute() or not attributes then
        return
    end

    if isSet then
        SetUIPanelAttribute(target, name, true)
        target:SetAttribute("UIPanelLayout-defined", true)

        for name2, att in pairs(attributes) do
            target:SetAttribute("UIPanelLayout-"..name2, att)
        end
        UpdateUIPanelPositions(target)

    else

        target:SetAttribute("UIPanelLayout-defined", nil)
        for name2 in pairs(attributes) do
            target:SetAttribute("UIPanelLayout-"..name2, nil)
        end
    end
end




local function Init_Point_Menu(self, root)
    if not UIPanelWindows then
        return
    end
    local sub
    local name= self.name
    local target= self:GetParent()

    sub=root:CreateCheckbox(
        WoWTools_L.LOCK_FOCUS_FRAME,
    function()
        return WoWTools_MoveMixin:Save().UIPanelWindows[name]
    end, function()
        WoWTools_MoveMixin:Save().UIPanelWindows[name]= not WoWTools_MoveMixin:Save().UIPanelWindows[name] and true or nil

        if WoWTools_MoveMixin:Save().UIPanelWindows[name] then
            if UIPanelWindows[name] then
                P_UIPanelWindows[name]= UIPanelWindows[name]
                UIPanelWindows[name]= nil
                FrameOnShow_SetPoint(self, false)
            end
        elseif P_UIPanelWindows[name] then
            UIPanelWindows[name]= P_UIPanelWindows[name]
            P_UIPanelWindows[name]= nil
            FrameOnShow_SetPoint(self, true)
        end
    end)

    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Move.LockPoint'])
        tooltip:AddLine(name)
        tooltip:AddLine(WoWTools_L['Custom position when shown'])
        tooltip:AddLine('|A:NPE_Icon:0:0|aEsc '..(WoWTools_L['DISABLE~2']))
        --toca el gestor de paneles de Blizzard (taint)
        GameTooltip_AddErrorLine(tooltip, WoWTools_L['May cause Interface action blocked errors when opening panels in combat'])
        local tab= P_UIPanelWindows[name] or UIPanelWindows[name]
        if tab then
            tooltip:AddLine(' ')
            local t
            for name, value in pairs(tab) do
                t=type(value)
                tooltip:AddDoubleLine(name,
                    (t=='string' or t=='number') and value
                    or (value==true and 'true') or (value==false and 'false')
                    or t
                )
            end
        end
    end)
    sub:SetEnabled(
        (P_UIPanelWindows[name] or UIPanelWindows[name])
        and WoWTools_MoveMixin:Save().point[name]
        and target:CanChangeAttribute()
    )

    WoWTools_MenuMixin:Reload(sub)
    sub:CreateDivider()
    sub:CreateTitle(WoWTools_L.REQUIRES_RELOAD)

    root:CreateDivider()
    local index=0
    for frameName in pairs(WoWTools_MoveMixin:Save().UIPanelWindows) do
        index= index+1
        sub=root:CreateCheckbox(
            (index<10 and ' ' or '')..index..') '..frameName,
        function(data)
            return WoWTools_MoveMixin:Save().UIPanelWindows[data.name]
        end, function(data)
            WoWTools_MoveMixin:Save().UIPanelWindows[data.name]= not WoWTools_MoveMixin:Save().UIPanelWindows[data.name] and true or nil
            FrameOnShow_SetPoint(self, WoWTools_MoveMixin:Save().UIPanelWindows[data.name])
        end, {name=frameName})
        sub:SetTooltip(function(tooltip, desc)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Move.LockPointList'])
            tooltip:AddLine(desc.data.name)
            tooltip:AddLine(WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2 )
            tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
        end)
    end

    if index>0 then
        root:CreateDivider()
        root:CreateButton(
            '|A:bags-button-autosort-up:0:0|a'..(WoWTools_L.CLEAR_ALL),
        function()
            StaticPopup_Show('WoWTools_OK',
                WoWTools_L.CLEAR_ALL,
            nil,
            {SetValue=function()
                WoWTools_MoveMixin:Save().UIPanelWindows={}
            end})
            return MenuResponse.Open
        end)
    end

--SetScrollMod
    WoWTools_MenuMixin:SetScrollMode(root)
end


local function Init_Menu(self, root)
    local target= self:GetParent()
    local name= self.name
    root:SetTag('WOWTOOLS_RESIZEBUTTON_MENU')

    local sub, sub2
    if WoWTools_FrameMixin:IsLocked(target) then
        root:CreateTitle(WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        return
    end

    WoWTools_MenuMixin:Scale(self, root, function()
        return target:GetScale()
    end, function(value)
        if not WoWTools_FrameMixin:IsLocked(target) then
            WoWTools_MoveMixin:Save().scale[name]=value
            Set_Frame_Scale(target, value)
        end
    end, function()
        if not WoWTools_FrameMixin:IsLocked(target) then
            WoWTools_MoveMixin:Save().scale[name]=nil
            if self.scaleRestFunc then
                self.scaleRestFunc(target, self)
            end
            if target:GetScale()~=1 then
                target:SetScale(1)
            end
        end
    end)

    if self.setSize then
        sub=root:CreateCheckbox(
            WoWTools_L['HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE~2'],
        function()
            return not WoWTools_MoveMixin:Save().disabledSize[name]
        end, function()
            WoWTools_MoveMixin:Save().disabledSize[name]= not WoWTools_MoveMixin:Save().disabledSize[name] and true or nil
        end, {rightText=format('%i|cff626262x|r%i', target:GetWidth(),target:GetHeight())})
        WoWTools_MenuMixin:SetRightText(sub)

        sub:SetTooltip(function(tooltip)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Move.Size'])
            if self.sizeTooltip then
                if type(self.sizeTooltip)=='function' then
                    self.sizeTooltip(tooltip, target, self)
                else
                    tooltip:AddLine(self.sizeTooltip)
                end
            end
        end)

--x
        sub:CreateSpacer()
        sub2=WoWTools_MenuMixin:CreateSlider(sub, {
            getValue=function()
                return math.modf(target:GetWidth())
            end, setValue=function(value)
                if not WoWTools_FrameMixin:IsLocked(target) and not WoWTools_MoveMixin:Save().disabledSize[name] then
                    target:SetWidth(value)
                    if self.sizeUpdateFunc then
                        self.sizeUpdateFunc(target, self)
                    end
                    if self.sizeStopFunc then
                        self.sizeStopFunc(target, self)
                    else
                        Save_Frame_Size(self)
                    end
                end
            end,
            name='x',
            minValue=self.minWidth,
            maxValue=self.maxWidth or math.modf(UIParent:GetWidth()),
            step=5,
        })
        sub2:SetEnabled(not WoWTools_MoveMixin:Save().disabledSize[name])
        sub:CreateSpacer()
        sub:CreateSpacer()
        sub2=WoWTools_MenuMixin:CreateSlider(sub, {
            getValue=function()
                return math.modf(target:GetHeight())
            end, setValue=function()
                if not WoWTools_FrameMixin:IsLocked(target) and not WoWTools_MoveMixin:Save().disabledSize[name] then
                    if self.sizeUpdateFunc then
                        self.sizeUpdateFunc(target, self)
                    end
                    if self.sizeStopFunc then
                        self.sizeStopFunc(target, self)
                    else
                        Save_Frame_Size(self)
                    end
                end
            end,
            name='y',
            minValue= self.minHeight,
            maxValue= self.maxHeight or math.modf(UIParent:GetHeight()),
            step=5,
        })
        sub2:SetEnabled(not WoWTools_MoveMixin:Save().disabledSize[name])
        sub:CreateSpacer()
        sub2=sub:CreateButton(
            '+0.1%',
        function()
            if not WoWTools_FrameMixin:IsLocked(target) and not WoWTools_MoveMixin:Save().disabledSize[name] then
                Set_ScalePercent(self, true)
            end
            return MenuResponse.Refresh
        end)
        WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Move.SizeUp'])
        sub2=sub:CreateButton(
            '-0.1%',
        function()
            if not WoWTools_FrameMixin:IsLocked(target) and not WoWTools_MoveMixin:Save().disabledSize[name] then
                Set_ScalePercent(self, false)
            end
            return MenuResponse.Refresh
        end)
        WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Move.SizeDown'])
        sub2=sub:CreateRadio(
            WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2,
        function()
            return WoWTools_MoveMixin:Save().size[name]
        end, function()
            WoWTools_MoveMixin:Save().size[name]=nil
            if not WoWTools_FrameMixin:IsLocked(target) then
                if self.sizeRestFunc then
                    self.sizeRestFunc(target, self)
                end
                if not self.notUpdatePositon then
                    WoWTools_DataMixin:Call('UpdateUIPanelPositions', target)
                end
            end
            return MenuResponse.Refresh
        end)
        WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Move.SizeClear'])
    end

    if self.set_move_event then
        sub=root:CreateCheckbox(
            (WoWTools_L.CHANNELPULLOUT_OPACITY_LABEL),
        function()
            return not WoWTools_MoveMixin:Save().disabledAlpha[name]
        end, function()
            WoWTools_MoveMixin:Save().disabledAlpha[name]= not WoWTools_MoveMixin:Save().disabledAlpha[name] and true or nil
            self:set_move_event()
        end, {rightText= WoWTools_MoveMixin:Save().alpha or 1})
        sub:SetTooltip(function(tooltip)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Move.Alpha'])
            tooltip:AddLine(WoWTools_L['CAMERA_SMARTER~2'])
        end)
        WoWTools_MenuMixin:SetRightText(sub)

        WoWTools_MenuMixin:OpenOptions(sub, {
            name=WoWTools_MoveMixin.addName,
            name2=WoWTools_L['Settings...'],
        })
    end


    root:CreateDivider()
    sub=root:CreateRadio(
        (WoWTools_MoveMixin:Save().point[name] and '' or '|cff626262')
        ..(WoWTools_L['Clear position']),
    function()
        return WoWTools_MoveMixin:Save().point[name]
    end, function()
        local data= target.moveFrameData
        if data
            and not data.notSave
            and not WoWTools_FrameMixin:IsLocked(target)
        then
            if P_UIPanelWindows[name] then
                UIPanelWindows[name]= P_UIPanelWindows[name]
                P_UIPanelWindows[name]= nil
            end

            WoWTools_MoveMixin:Save().point[name]=nil

            if self.restPointFunc then
                self.restPointFunc(self)
            elseif not self.notUpdatePositon then
                WoWTools_DataMixin:Call('UpdateUIPanelPositions', target)
            end
        end
        return MenuResponse.Refresh
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Move.ClearPoint'])




    Init_Point_Menu(self, sub)

    --Init_Esc_Menu(self, root)


    sub=root:CreateDivider()

    sub=WoWTools_MenuMixin:OpenOptions(root, {
        name= WoWTools_MoveMixin.addName,
        name2= WoWTools_L['Settings...'],
    })


--/reload
    WoWTools_MenuMixin:Reload(sub)

    if self.addMenu then
        self.addMenu(target, root)
    end
end


local function Set_Move_Alpha(frame)
    local name= frame and frame:GetName()
    if not name or WoWTools_MoveMixin:Save().notMoveAlpha then
        return
    end


    if not frame.ResizeButton then
        frame.ResizeButton= CreateFrame("Frame", nil, frame)
    end
    frame.ResizeButton.name= name

    frame.ResizeButton:SetScript('OnEvent', function(self, event)
        local target= self:GetParent()
        if event=='PLAYER_STARTED_MOVING' then
            target:SetAlpha(WoWTools_MoveMixin:Save().alpha)

        elseif event=='PLAYER_STOPPED_MOVING' then
            target:SetAlpha(1)

        end
    end)



    function frame.ResizeButton:set_move_event()
        if WoWTools_MoveMixin:Save().disabledAlpha[self.name] or WoWTools_MoveMixin:Save().alpha==1 then
            self:UnregisterAllEvents()
            self:SetScript('OnShow', nil)
            self:SetScript('OnHide', nil)
            self:GetParent():SetAlpha(1)
        else
            if self:IsVisible() then
                self:RegisterEvent('PLAYER_STARTED_MOVING')
                self:RegisterEvent('PLAYER_STOPPED_MOVING')
            end
            self:SetScript('OnShow', function(f)
                f:RegisterEvent('PLAYER_STARTED_MOVING')
                f:RegisterEvent('PLAYER_STOPPED_MOVING')
            end)
            self:SetScript('OnHide', function(f)
                f:UnregisterAllEvents()
                f:GetParent():SetAlpha(1)
            end)
        end
    end

    frame.ResizeButton:set_move_event()

    frame:HookScript('OnEnter', function(self)
        self:SetAlpha(1)
    end)
end


local function GetScaleDistance(SOS) -- distance from cursor to TopLeft :)
	local left, top = SOS.left, SOS.top
	local scale = SOS.EFscale
	local x, y = GetCursorPosition()
	x = x/scale - left
	y = top - y/scale
	return sqrt(x*x+y*y)
end


local function Set_Tooltip(self)
    local target= self:GetParent()
    local name= self.name or target:GetName()

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    if not name then
        return
    end

    if WoWTools_FrameMixin:IsLocked(target) then
        GameTooltip:AddDoubleLine('|cnWARNING_FONT_COLOR:'..(WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT), WoWTools_TextMixin:GetEnabeleDisable(false))
        GameTooltip:Show()
        return
    elseif target:IsProtected() then
        GameTooltip:AddDoubleLine(
            WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT,
            '|cnWARNING_FONT_COLOR:'..(WoWTools_L['DISABLE+NPE_CONTROLS'])
        )
        GameTooltip:AddLine(' ')
    end

    GameTooltip:AddDoubleLine('|cffff00ff'..name, format('%s %.2f', WoWTools_L['Effective'], target:GetEffectiveScale()))
    local parent= target:GetParent()
    if parent then
        GameTooltip:AddDoubleLine(parent:GetName() or 'Parent', format('%.2f', parent:GetScale()))
    end

    local scale
    scale= tonumber(format('%.2f', target:GetScale() or 1))
    scale= ((scale<=0.4 or scale>=2.5) and ' |cnWARNING_FONT_COLOR:' or ' |cnGREEN_FONT_COLOR:')..scale..' '
    GameTooltip:AddDoubleLine((WoWTools_L.HOUSING_EXPERT_DECOR_SUBMODE_SCALE), scale..WoWTools_DataMixin.Icon.left)

    if self.setSize then
        GameTooltip:AddLine(' ')
        local col
        if self.sizeRestTooltipColorFunc then
            col=self.sizeRestTooltipColorFunc(self)
        end
        col=col or (WoWTools_MoveMixin:Save().size[name] and '' or '|cff626262')

        local w, h
        w= math.modf(target:GetWidth())
        w= format('%s%d|r', ((self.minWidth and self.minWidth>=w) or (self.maxWidth and self.maxWidth<=w)) and '|cnWARNING_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:', w)

        h= math.modf(target:GetHeight())
        h= format('%s%d|r', ((self.minHeight and self.minHeight>=h) or (self.maxHeight and self.maxHeight<=h)) and '|cnWARNING_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:', h)

        GameTooltip:AddDoubleLine(
            col..(WoWTools_L['HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE~2'])..format(' %s |cffffffffx|r %s', w, h),
                WoWTools_TextMixin:GetEnabeleDisable(not WoWTools_MoveMixin:Save().disabledSize[name])..WoWTools_DataMixin.Icon.right
        )

        if self.sizeTooltip then
            if type(self.sizeTooltip)=='function' then
                self.sizeTooltip(GameTooltip, target, self)
            else
                GameTooltip:AddLine(self.sizeTooltip)
            end
        end
    else
        GameTooltip_AddErrorLine(GameTooltip,
            (WoWTools_L.HUD_EDIT_MODE_SETTING_UNIT_FRAME_FRAME_SIZE)
            ..': '
            ..(WoWTools_L.LOCK)
        )
    end

    GameTooltip:AddLine(' ')
    if self.set_move_event then
        GameTooltip:AddDoubleLine(
            (WoWTools_L['Alpha when moving ']),
            WoWTools_MoveMixin:Save().disabledAlpha[name] and WoWTools_TextMixin:GetEnabeleDisable(false) or ('|cnGREEN_FONT_COLOR:'..Save().alpha)
        )
    end

    GameTooltip:AddDoubleLine(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.mid)
    GameTooltip:Show()
end


local function Set_Enter(btn, target)

    if btn.alpha then

        --if btn.alpha==0 then
        target:HookScript('OnEnter', function(self)
            self.ResizeButton:SetAlpha(1)
        end)
        target:HookScript('OnLeave', function(self)
            self.ResizeButton:SetAlpha(self.ResizeButton.alpha)
        end)
        --end
    end

    btn:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        ResetCursor()
        self:SetAlpha(self.alpha or 0.5)
    end)
    btn:SetScript('OnEnter', function(self)
        Set_Tooltip(self)
        SetCursor('Interface\\CURSOR\\Crosshair\\UI-Cursor-SizeRight')
        self:SetAlpha(1)
    end)

    btn:SetAlpha(btn.alpha or 0.5)
end


local function Set_OnMouseUp(self)
    local d= self.isActiveButton
    local target= self:GetParent()

    self:SetScript("OnUpdate", nil)

    if d=='RightButton' and self.setSize then
        local continueResizeStop = true
        if target.onResizeStopCallback then
            continueResizeStop = target.onResizeStopCallback(self)
        end
        if continueResizeStop then
            target:StopMovingOrSizing()
        end
        Save_Frame_Size(self)

    elseif d=='LeftButton' then
        if self.scaleStopFunc then
            self.scaleStopFunc(target, self)
        elseif self.name then
            WoWTools_MoveMixin:Save().scale[self.name]= target:GetScale()
        end
    end
    self.SOS= nil

    self.isActiveButton= nil
end


local function Set_OnMouseDown(self, d)
    local target= self:GetParent()

    if self.isActiveButton
        or WoWTools_FrameMixin:IsLocked(target)
        or IsModifierKeyDown()
    then
        return
    end

    self.isActiveButton = d


    if d=='LeftButton' then
        self.SOS= self.SOS or {}
        self.SOS.left, self.SOS.top = target:GetLeft(), target:GetTop()
        self.SOS.scale = target:GetScale()
        self.SOS.x, self.SOS.y = self.SOS.left, self.SOS.top-(UIParent:GetHeight()/self.SOS.scale)
        self.SOS.EFscale = target:GetEffectiveScale()
        self.SOS.dist = GetScaleDistance(self.SOS)
        self:SetScript("OnUpdate", function()
            if WoWTools_FrameMixin:IsLocked(self) then
                self:SetScript("OnUpdate", nil)
                self.isActiveButton=nil
                return
            end

            local SOS= self.SOS
            local distance= GetScaleDistance(SOS)
            local scale2 = distance/SOS.dist*SOS.scale
            if scale2 < 0.4 then
                scale2 = 0.4
            elseif scale2 > 2.5 then
                scale2 = 2.5
            end

            scale2= tonumber(format('%.2f', scale2))
            target:SetScale(scale2)

            local s = SOS.scale/target:GetScale()
            local x = SOS.x*s
            local y = SOS.y*s

            target:ClearAllPoints()
            target:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)

            Set_Tooltip(self)

            if self.scaleUpdateFunc then
                self.scaleUpdateFunc(target, self)
            end
        end)

    elseif d=='RightButton' and self.setSize and not WoWTools_MoveMixin:Save().disabledSize[self.name] then

        local continueResizeStart = true
        if target.onResizeStartCallback then
            continueResizeStart = target.onResizeStartCallback(self)
        end
        if continueResizeStart then
            target:SetResizable(true)
            target:StartSizing(self.startSizing or "BOTTOMRIGHT", true)
        end
        self:SetScript('OnUpdate', function()
            if WoWTools_FrameMixin:IsLocked(target) then
                self:SetScript("OnUpdate", nil)
                self.isActiveButton=nil
                target:StopMovingOrSizing()

            elseif self.sizeUpdateFunc then
                self.sizeUpdateFunc(target, self)
            end
            Set_Tooltip(self)
        end)
    end



    Set_Tooltip(self)
end


local function Set_Init_Frame(btn, target, size, initFunc)
    if WoWTools_FrameMixin:IsLocked(target) then--not InCombatLockdown() or not sel:IsProtected() 
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner, tab)--btn2, target2, size2, initFunc2)
            if tab.size then
                Set_Frame_Size(tab.target, tab.size[1], tab.size[2])
            end
            if initFunc then
                initFunc(btn)
            end
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end, nil, {
            btn=btn,
            target=target,
            size=size,
            initFunc=initFunc
        })
    else
        if size then
            Set_Frame_Size(target, size[1], size[2])
        end
        if initFunc then
            initFunc(btn)
        end
    end
end


function WoWTools_MoveMixin:Scale_Size_Button(frame, tab)
    local name= frame and frame:GetName()
    tab= tab or {}

    if not name
        or tab.notZoom
        or frame.ResizeButton
        or (tab.frame and not tab.needSize)
        or _G['WoWToolsResizeButton'..name]

    then
        return
    end



    frame.ResizeButton= CreateFrame('Button', 'WoWToolsResizeButton'..name, frame, 'PanelResizeButtonTemplate')--UI-HUD-UnitFrame-Player-PortraitOn-CornerEmbellishment SharedUIPanelTemplates.lua


    local btn= frame.ResizeButton

    btn:SetFrameStrata('DIALOG')
    btn:SetFrameLevel(999)
    btn:SetSize(18, 18)

    local setResizeButtonPoint= tab.setResizeButtonPoint
    local minW= tab.minW or 115
    local minH= tab.minH or 115
    local maxW= tab.maxW
    local maxH= tab.maxH
    local rotationDegrees= tab.rotationDegrees
    local initFunc= tab.initFunc


    local onShowFunc= tab.onShowFunc


    btn.sizeRestFunc= tab.sizeRestFunc
    btn.sizeUpdateFunc= tab.sizeUpdateFunc

    btn.sizeStopFunc= tab.sizeStopFunc
    btn.scaleStopFunc= tab.scaleStopFunc

    btn.name= name
    btn.scaleUpdateFunc= tab.scaleUpdateFunc
    btn.scaleRestFunc= tab.scaleRestFunc
    btn.restPointFunc= tab.restPointFunc
    btn.alpha= tab.alpha
    btn.notUpdatePositon= tab.notUpdatePositon
    btn.notMoveAlpha= tab.notMoveAlpha
    btn.setSize= tab.sizeRestFunc and true or nil

    btn.sizeRestTooltipColorFunc= tab.sizeRestTooltipColorFunc
    btn.sizeTooltip= tab.sizeTooltip
    btn.addMenu= tab.addMenu

    if setResizeButtonPoint then
        btn:SetPoint(setResizeButtonPoint[1] or 'BOTTOMRIGHT', setResizeButtonPoint[2] or frame, setResizeButtonPoint[3] or 'BOTTOMRIGHT', setResizeButtonPoint[4] or 0, setResizeButtonPoint[5] or 0)
    else
        btn:SetPoint('BOTTOMRIGHT', frame, 3, -3)
    end

    if btn.setSize then
        frame:SetResizable(true)
        btn:Init(frame, minW, minH, maxW , maxH, rotationDegrees)

        local size= WoWTools_MoveMixin:Save().size[name]
        if size or initFunc then
            Set_Init_Frame(btn, frame, size, initFunc)
        end
    end

    WoWTools_TextureMixin:SetButton(btn, {alpha=1})

    --btn:SetClampedToScreen(true)


    local scale= WoWTools_MoveMixin:Save().scale[name]
    if scale and scale~=1 then
        Set_Frame_Scale(frame, scale)
    end

    btn:SetScript("OnMouseUp", function(s, d)
        Set_OnMouseUp(s, d)
    end)
    btn:SetScript("OnMouseDown", function(s, d)
        Set_OnMouseDown(s, d)
    end)
    btn:SetScript('OnMouseWheel', function(s)
        MenuUtil.CreateContextMenu(s, Init_Menu)
        Set_Tooltip(s)
    end)



    frame:HookScript('OnHide', function(s)
        local b= s.ResizeButton
        local d= b and b.isActiveButton
        if d then
            b:SetScript("OnUpdate", nil)
            b.isActiveButton= nil
        end
    end)

    if onShowFunc then
        if onShowFunc==true then
            frame:HookScript('OnShow', function(s)
                self:Set_SizeScale(s)
            end)
        else
            frame:HookScript('OnShow', onShowFunc)
        end
    end

    if not btn.notMoveAlpha then
        Set_Move_Alpha(frame)
    end

    if WoWTools_MoveMixin:Save().UIPanelWindows[name] and UIPanelWindows[name] then
        P_UIPanelWindows[name]= UIPanelWindows[name]
        UIPanelWindows[name]= nil
        FrameOnShow_SetPoint(btn, false)
    end


    Set_Enter(btn, frame)
end


function WoWTools_MoveMixin:MoveAlpha(frame)
    Set_Move_Alpha(frame)
end

function WoWTools_MoveMixin:Set_SizeScale(frame)
    local name= frame and frame:GetName()
    if not name or not frame.ResizeButton then
        return
    end

    if WoWTools_FrameMixin:IsLocked(frame) then
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
            self:Set_SizeScale(frame)
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end)
        return
    end

    local scale= WoWTools_MoveMixin:Save().scale[name]
    if scale then
        Set_Frame_Scale(frame, scale)
    end

    if frame.ResizeButton.setSize then
        local size= WoWTools_MoveMixin:Save().size[name]
        if size then
            Set_Frame_Size(frame, size[1], size[2])
        end
    end
end


function WoWTools_MoveMixin:Set_Frame_Scale(frame)
    local name= frame:GetName()
    local value= name and WoWTools_MoveMixin:Save().scale[name]
    if value then
        Set_Frame_Scale(frame, value)
    end
end

function WoWTools_MoveMixin:Set_OnMouseUp(...)
    Set_OnMouseUp(...)
end

function WoWTools_MoveMixin:Set_OnMouseDown(...)
    Set_OnMouseDown(...)
end