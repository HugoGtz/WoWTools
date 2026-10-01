
--ObjectiveTrackerFrame



WoWTools_ObjectiveTabs={
    ['ScenarioObjectiveTracker']=false,

    ['QuestObjectiveTracker']=1,
    ['BonusObjectiveTracker']=1,
    ['CampaignQuestObjectiveTracker']=1,
    ['WorldQuestObjectiveTracker']=1,

    ['AchievementObjectiveTracker']=1,
    ['ProfessionsRecipeTracker']=1,
    ['MonthlyActivitiesObjectiveTracker']=1,
    ['UIWidgetObjectiveTracker']=1,
    ['AdventureObjectiveTracker']=1,

    ['InitiativeTasksObjectiveTracker']=1,
}

local function Is_Locked(frame)
    if frame then
        WoWTools_FrameMixin:IsLocked(frame)
    else
        return WoWTools_FrameMixin:IsLocked(ObjectiveTrackerFrame)
    end
end

local function Set_Collapse(collapse, isAllCollapse)
    if ObjectiveTrackerFrame:IsCollapsed() or Is_Locked() then
        return
    end

    for frame, isCheck in pairs(WoWTools_ObjectiveTabs) do
        frame= _G[frame]
        if frame:IsVisible()
            and not Is_Locked(frame)
            and (isCheck or isAllCollapse)
            and frame:IsCollapsed()~=collapse
        then
            frame:SetCollapsed(collapse)
        end
    end
end


local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2
    local col= Is_Locked() and '|cff828282' or ''

    sub=root:CreateButton(
        col
        ..(WoWTools_L['HUD_EDIT_MODE_COLLAPSE_OPTIONS~3']),
    function()
        Set_Collapse(true, true)
        return MenuResponse.Open
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Objective.CollapseAll'])

    sub2= sub:CreateCheckbox(
        '|cnWARNING_FONT_COLOR:'
        ..(WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT),
    function()
        return WoWTools_ObjectiveMixin:Save().autoHideInCombat
    end, function()
        WoWTools_ObjectiveMixin:Save().autoHideInCombat = not WoWTools_ObjectiveMixin:Save().autoHideInCombat and true or nil
        self:set_event()
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Objective.AutoCombat'])
        tooltip:AddLine('|cnWARNING_FONT_COLOR:BUG')
    end)


    sub=root:CreateButton(
        col
        ..(WoWTools_L['HUD_EDIT_MODE_EXPAND_OPTIONS~2']),
    function()
        Set_Collapse(false, true)
        return MenuResponse.Open
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Objective.ExpandAll'])

    sub=root:CreateCheckbox(
        WoWTools_L.SELF_CAST_AUTO,
    function()
        return WoWTools_ObjectiveMixin:Save().autoHide
    end, function()
        WoWTools_ObjectiveMixin:Save().autoHide = not WoWTools_ObjectiveMixin:Save().autoHide and true or nil
        self:set_event()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Objective.AutoCollapse'])

    root:CreateDivider()

    sub=root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'..(WoWTools_L['CLEAR_ALL~2']),
    function()
        StaticPopup_Show('WoWTools_OK',
        (WoWTools_L.OBJECTIVES_STOP_TRACKING)..'\n'
        ..'|A:bags-button-autosort-up:0:0|a'..(WoWTools_L['CLEAR_ALL~2']),
        nil,
        {SetValue=function()
            WoWTools_ObjectiveMixin:Clear_Achievement()
            WoWTools_ObjectiveMixin:Clear_CampaignQuest()
            WoWTools_ObjectiveMixin:Clear_MonthlyActivities()
            WoWTools_ObjectiveMixin:Clear_ProfessionsRecipe()
            WoWTools_ObjectiveMixin:Clear_Quest()
            WoWTools_ObjectiveMixin:Clear_WorldQuest()
            WoWTools_ObjectiveMixin:Clear_ContentTracking()
            WoWTools_ObjectiveMixin:Clear_NeighborhoodInitiative()
        end}
)
    end)
    sub:SetTooltip(function (tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Objective.ClearAll'])
        tooltip:AddLine(WoWTools_L.OBJECTIVES_STOP_TRACKING)
    end)

    root:CreateDivider()
    WoWTools_MenuMixin:Scale(ObjectiveTrackerFrame, root, function()
        return WoWTools_ObjectiveMixin:Save().scale
    end, function(value)
        if not Is_Locked() then
            WoWTools_ObjectiveMixin:Save().scale= value
            self:set_scale()
        end
    end)

    sub= root:CreateButton(
        '|A:MonkUI-LightOrb:0:0|a'..(WoWTools_L.HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY),
    function()
        return MenuResponse.Open
    end, {rightText=WoWTools_ObjectiveMixin:Save().alpha or 1})
    WoWTools_MenuMixin:SetRightText(sub)

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return WoWTools_ObjectiveMixin:Save().alpha or 1
        end,
        setValue=function(value)
            if not Is_Locked() then
                WoWTools_ObjectiveMixin:Save().alpha= value
                self:set_scale()
            end
        end,
        name= WoWTools_L.HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY ,
        minValue=0,
        maxValue=1,
        step=0.01,
        bit='%.2f',
    })
    sub:CreateSpacer()


    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_ObjectiveMixin.addName, name2=WoWTools_L['Settings...'], tooltip=function(tooltip)
        tooltip:AddLine(' ')
        tooltip:AddLine('|cnWARNING_FONT_COLOR:BUG')
        tooltip:AddLine(WoWTools_L['Note: errors may occur'])
        tooltip:AddLine(WoWTools_L['Fails when there is a clickable item button'])
    end})

    WoWTools_MenuMixin:Reload(sub)

end


local Init= WoWTools_Once(function()
    local MenuButton=CreateFrame('DropdownButton', 'WoWToolsObjectiveTrackerFrameMenuButton', ObjectiveTrackerFrame.Header, 'WoWToolsMenuTemplate') --WoWTools_ButtonMixin:Menu(ObjectiveTrackerFrame.Header, {size=20,name='WoWToolsObjectiveTrackerFrameMenuButton'})
    MenuButton:SetSize(20,20)

    function MenuButton:set_scale()
        if not Is_Locked() then
            ObjectiveTrackerFrame:SetScale(WoWTools_ObjectiveMixin:Save().scale or 1)
            ObjectiveTrackerFrame:SetAlpha(WoWTools_ObjectiveMixin:Save().alpha or 1)
        end
    end

    function MenuButton:auto_collapse()
        Set_Collapse(IsInInstance(), false)
    end

    function MenuButton:set_event()
        self:UnregisterAllEvents()

        if WoWTools_ObjectiveMixin:Save().autoHide then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent("CHALLENGE_MODE_START")
            self:RegisterEvent('ZONE_CHANGED_NEW_AREA')

            if WoWTools_ObjectiveMixin:Save().autoHideInCombat then
                self:RegisterEvent('PLAYER_REGEN_DISABLED')
                self:RegisterEvent('PLAYER_REGEN_ENABLED')
            end

            self:auto_collapse()
        end
    end

    function MenuButton:set_shown()
        self:SetShown(not ObjectiveTrackerFrame:IsCollapsed())
    end

    MenuButton:SetScript('OnMouseWheel', function(_, d)
        Set_Collapse(d==1, true)
    end)

    MenuButton:SetPoint('RIGHT', ObjectiveTrackerFrame.Header.MinimizeButton, 'LEFT')
    MenuButton:SetScript('OnLeave', GameTooltip_Hide)
    MenuButton:HookScript('OnEnter', function()
        GameTooltip:SetOwner(ObjectiveTrackerFrame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine('|A:Objective-Nub:0:0|a'..(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL)..WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')

        local col= Is_Locked() and '|cff828282' or ''
        GameTooltip:AddLine(
            col
            ..(WoWTools_L['HUD_EDIT_MODE_COLLAPSE_OPTIONS~2'])
            ..(WoWTools_L.HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_WRAP_UP)
            ..WoWTools_DataMixin.Icon.mid
        )
        GameTooltip:AddLine(
            col
            ..(WoWTools_L['HUD_EDIT_MODE_EXPAND_OPTIONS~3'])
            ..(WoWTools_L.HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_WRAP_DOWN)
            ..WoWTools_DataMixin.Icon.mid
        )
        GameTooltip:Show()
    end)
    MenuButton:SetupMenu(Init_Menu)

    MenuButton:SetScript('OnEvent', function(self, event)
        if Is_Locked() then
            return
        elseif event=='PLAYER_REGEN_DISABLED' then
            if not ObjectiveTrackerFrame:IsCollapsed() then
                ObjectiveTrackerFrame:SetCollapsed(true)
            end
        elseif event=='PLAYER_REGEN_ENABLED' then
            if ObjectiveTrackerFrame:IsCollapsed() then
                ObjectiveTrackerFrame:SetCollapsed(false)
            end
        else
            self:auto_collapse()
        end
    end)



    ObjectiveTrackerFrame.Header.MinimizeButton:HookScript('OnMouseUp', function()
        WoWTools_ObjectiveMixin:Save().initIsCollapsed= ObjectiveTrackerFrame:IsCollapsed()
    end)

    WoWTools_DataMixin:Hook(ObjectiveTrackerFrame.Header, 'SetCollapsed', function(_, collapsed)
        WoWTools_ObjectiveMixin:Save().initIsCollapsed= collapsed
        MenuButton:set_shown()
    end)


    WoWTools_DataMixin:Hook(ObjectiveTrackerManager, 'ReleaseFrame', function(_, line)
        if line.Icon2 then
            line.Icon2:SetTexture(0)
        end
    end)


    MenuButton:set_scale()
    MenuButton:set_event()
    MenuButton:set_shown()

    if WoWTools_ObjectiveMixin:Save().autoHide and WoWTools_ObjectiveMixin:Save().initIsCollapsed and not Is_Locked()  then
        ObjectiveTrackerFrame:SetCollapsed(true)--:ToggleCollapsed()
    end


    ObjectiveTrackerFrame.Header:EnableMouseWheel(true)
    ObjectiveTrackerFrame.Header:SetScript('OnMouseWheel', function(_, d)
        Set_Collapse(d==1, true)
    end)


end)


function WoWTools_ObjectiveMixin:Init_Menu()
    Init()
end


--Esquema del Centro de control (docs/SETTINGS.md): los mismos ajustes que el menú del rastreador
local function MenuButton()
    return _G['WoWToolsObjectiveTrackerFrameMenuButton']
end

local function Set_Event()
    local btn= MenuButton()
    if btn then
        btn:set_event()
    end
end

local function Set_Scale()
    local btn= MenuButton()
    if btn then
        btn:set_scale()
    end
end

local Options= {
    {type='section', text='Automations'},
    {type='check', key='autoHide', text='Auto collapse in instances', tooltip='Tip.Objective.AutoCollapse', automation=true,
        get= function(save) return save.autoHide end,
        set= function(save, value) save.autoHide= value and true or nil end,
        apply= Set_Event,
    },
    {type='check', key='autoHideInCombat', text='HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT',
        tooltip='Tip.Objective.AutoCombat', automation=true, indent=true,
        disabled= function(save) return not save.autoHide end,
        get= function(save) return save.autoHideInCombat end,
        set= function(save, value) save.autoHideInCombat= value and true or nil end,
        apply= Set_Event,
    },

    {type='section', text='Appearance'},
    {type='slider', key='scale', text='HOUSING_EXPERT_DECOR_SUBMODE_SCALE', tooltip='Tip.Menu.Scale', min=0.4, max=4, step=0.1, format='%.1f',
        noCombat=true,
        get= function(save) return save.scale or 1 end,
        set= function(save, value) save.scale= tonumber(format('%.1f', value)) or 1 end,
        apply= Set_Scale,
    },
    {type='slider', key='alpha', text='HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', min=0, max=1, step=0.01, format='%.2f',
        noCombat=true,
        get= function(save) return save.alpha or 1 end,
        set= function(save, value) save.alpha= tonumber(format('%.2f', value)) or 1 end,
        apply= Set_Scale,
    },

    {type='section', text='Advanced'},
    {type='button', key='clearAll', text='OBJECTIVES_STOP_TRACKING', buttonText='CLEAR_ALL', tooltip='Tip.Objective.ClearAll', confirm=true,
        disabled= function(_, M) return not M:IsEnabled() end,
        func= function()
            WoWTools_ObjectiveMixin:Clear_Achievement()
            WoWTools_ObjectiveMixin:Clear_CampaignQuest()
            WoWTools_ObjectiveMixin:Clear_MonthlyActivities()
            WoWTools_ObjectiveMixin:Clear_ProfessionsRecipe()
            WoWTools_ObjectiveMixin:Clear_Quest()
            WoWTools_ObjectiveMixin:Clear_WorldQuest()
            WoWTools_ObjectiveMixin:Clear_ContentTracking()
            WoWTools_ObjectiveMixin:Clear_NeighborhoodInitiative()
        end,
    },
}

function WoWTools_ObjectiveMixin:Get_Options()
    return Options
end
