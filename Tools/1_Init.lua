local function Init_Menu(self, root)

    if not self:CanChangeAttribute() then
        root:CreateTitle(WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        return
    end

    local sub, sub2
    sub=root:CreateCheckbox(
        WoWTools_L.SHOW,
    function()
        return self.Frame:IsShown()
    end, function()
        self:set_shown()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Tools.Show'])
        tooltip:AddLine((InCombatLockdown() and '|cnWARNING_FONT_COLOR:' or '')..(WoWTools_L['HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT~2']))
    end)

    sub:CreateTitle(WoWTools_L.SHOW)
    sub2=sub:CreateCheckbox('|A:newplayertutorial-drag-cursor:0:0|a'..(WoWTools_L['ENTER_LFG+EMBLEM_SYMBOL']), function()
        return WoWTools_ToolsMixin:Save().isEnterShow
    end, function()
        WoWTools_ToolsMixin:Save().isEnterShow = not WoWTools_ToolsMixin:Save().isEnterShow and true or false
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Tools.EnterShow'])

    sub:CreateTitle(WoWTools_L.HIDE)
    sub2=sub:CreateCheckbox('|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'..(WoWTools_L.ENTERING_COMBAT), function()
        return WoWTools_ToolsMixin:Save().isCombatHide
    end, function()
        WoWTools_ToolsMixin:Save().isCombatHide = not WoWTools_ToolsMixin:Save().isCombatHide and true or false
        self:set_event()
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Tools.CombatHide'])

    sub2=sub:CreateCheckbox('|A:transmog-gearSlot-unassigned-feet:0:0|a'..(WoWTools_L.NPE_MOVE), function()
        return WoWTools_ToolsMixin:Save().isMovingHide
    end, function()
        WoWTools_ToolsMixin:Save().isMovingHide = not WoWTools_ToolsMixin:Save().isMovingHide and true or false
        self:set_event()
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Tools.MovingHide'])

    sub2=sub:CreateCheckbox(
        '|A:UI-HUD-MicroMenu-GameMenu-Mouseover:0:0|a'
        ..(WoWTools_L['SHOW+MAINMENU_BUTTON']),
    function()
        return WoWTools_ToolsMixin:Save().isMainMenuHide
    end, function()
        WoWTools_ToolsMixin:Save().isMainMenuHide= not WoWTools_ToolsMixin:Save().isMainMenuHide and true or false
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Tools.MainMenuHide'])


    root:CreateDivider()
    sub=WoWTools_ToolsMixin:OpenMenu(root)

    sub2=sub:CreateCheckbox('30x30', function()
        return WoWTools_ToolsMixin:Save().height==30
    end, function()
        WoWTools_ToolsMixin:Save().height= WoWTools_ToolsMixin:Save().height==10 and 30 or 10
        self:set_size()
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Tools.Size30'])
        tooltip:AddLine(WoWTools_L.HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE)
    end)

    sub2=sub:CreateCheckbox(
        WoWTools_L.EMBLEM_SYMBOL,
    function()
        return WoWTools_ToolsMixin:Save().showIcon
    end, function()
        WoWTools_ToolsMixin:Save().showIcon= not WoWTools_ToolsMixin:Save().showIcon and true or false
        self:set_icon()
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Tools.ShowIcon'])
        tooltip:AddLine(WoWTools_TextMixin:GetShowHide(nil, true))
    end)

    WoWTools_MenuMixin:BgAplha(sub,
    function()
        return WoWTools_ToolsMixin:Save().bgAlpha
    end, function(value)
        WoWTools_ToolsMixin:Save().bgAlpha= value
        WoWTools_ToolsMixin:ShowBackground()
    end)

   WoWTools_MenuMixin:Scale(self, sub, function()
        return WoWTools_ToolsMixin:Save().scale
    end, function(data)
        if self:CanChangeAttribute() then
            WoWTools_ToolsMixin:Save().scale=data
            self:set_scale()
        else
            WoWTools_Print(WoWTools_ToolsMixin.addName..WoWTools_DataMixin.Icon.icon2, WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        end
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        WoWTools_ToolsMixin:Save().strata= data
        self:set_strata()
    end)



    sub2=sub:CreateButton(
        '|A:bag-reagent-border:0:0|a'..(WoWTools_L.EMBLEM_BORDER),
    function()
        return MenuResponse.Open
    end, {rightText= WoWTools_ToolsMixin:Save().borderAlpha or 0})
    WoWTools_MenuMixin:SetRightText(sub2)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Tools.BorderAlpha'])

    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return WoWTools_ToolsMixin:Save().borderAlpha or 0
        end, setValue=function(value)
            WoWTools_ToolsMixin:Save().borderAlpha=value
            local list, Name= WoWTools_ToolsMixin:Get_All_Buttons()
            for _, name in pairs(list) do
                _G[Name..name]:set_border_alpha()
            end
        end,
        name=WoWTools_L.HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY,
        minValue=0,
        maxValue=1,
        step=0.1,
        bit='%0.1f',
    })





    sub:CreateDivider()
    WoWTools_MenuMixin:RestPoint(self, sub, WoWTools_ToolsMixin:Save().point, function()
        WoWTools_ToolsMixin:Save().point=nil
        self:set_point()
    end)

    sub:CreateDivider()
    WoWTools_MenuMixin:Reload(sub, false)
end
















local Init= WoWTools_Once(function()
    local btn= WoWTools_ToolsMixin:Get_MainButton()

    btn.texture=btn:CreateTexture(nil, 'BORDER')
    btn.texture:SetPoint('CENTER')
    btn.texture:SetSize(10,10)
    btn.texture:SetShown(WoWTools_ToolsMixin:Save().showIcon)
    btn.texture:SetTexture('Interface\\AddOns\\WoWToolsPlus\\Source\\Texture\\WoWtools')

    function btn:set_size()
        self:SetSize(30, WoWTools_ToolsMixin:Save().height or 10)
    end



    function btn:set_icon()
        self.texture:SetShown(WoWTools_ToolsMixin:Save().showIcon)
    end


    function btn:set_point()
        if self:IsProtected() and InCombatLockdown() then
           WoWTools_Print(WoWTools_ToolsMixin.addName..WoWTools_DataMixin.Icon.icon2, '|cnWARNING_FONT_COLOR:'..(WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
        else
            self:ClearAllPoints()
            local p=WoWTools_ToolsMixin:Save().point
            if p and p[1] then
                self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
            else
                self:SetPoint('CENTER', 300, 100)
            end
        end
    end

    function btn:set_scale()
        if self:CanChangeAttribute() then
            self:SetScale(WoWTools_ToolsMixin:Save().scale or 1)
        end
    end

    function btn:set_strata()
        self:SetFrameStrata(WoWTools_ToolsMixin:Save().strata or 'MEDIUM')
    end

    function btn:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine((self:CanChangeAttribute() and '' or '|cff626262')..WoWTools_TextMixin:GetShowHide(nil, true), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_L.NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_L.SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
    end

    btn:RegisterForDrag("RightButton")
    btn:SetMovable(true)
    btn:SetClampedToScreen(true)

    btn:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)

    btn:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            WoWTools_ToolsMixin:Save().point={self:GetPoint(1)}
            WoWTools_ToolsMixin:Save().point[2]=nil
        end
    end)

    btn:SetScript("OnLeave",function()
        GameTooltip:Hide()
        ResetCursor()
    end)

    btn:SetScript('OnEnter', function(self)
        WoWTools_ToolsMixin:EnterShowFrame(self)
        self:set_tooltip()
    end)

    btn:SetScript("OnMouseUp", ResetCursor)
    btn:SetScript("OnMouseDown", function(_, d)
        if IsAltKeyDown() and d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

    btn:SetScript('OnMouseWheel', function(self, d)
        if self.Frame:CanChangeAttribute() then
            self.Frame:SetShown(d==1)
        end
    end)

    btn:SetScript("OnClick", function(self, d)
        if IsModifierKeyDown() then
            return
        end
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)

        elseif d=='LeftButton' then
            self:set_shown()
        end
    end)

    btn:set_scale()
    btn:set_point()
    btn:set_strata()
    btn:set_size()

    function btn:set_shown()
        if self.Frame:CanChangeAttribute() then
            self.Frame:SetShown(not self.Frame:IsShown())
        end
    end

    function btn:set_event()
        self.Frame:UnregisterAllEvents()
        if WoWTools_ToolsMixin:Save().isCombatHide then
            self.Frame:RegisterEvent('PLAYER_REGEN_DISABLED')
        end
        if WoWTools_ToolsMixin:Save().isMovingHide then
            self.Frame:RegisterEvent('PLAYER_STARTED_MOVING')
        end
    end

    btn.Frame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_REGEN_DISABLED' then
            if self:IsShown() then
                self:SetShown(false)
            end
        elseif event=='PLAYER_STARTED_MOVING' then
            if self:CanChangeAttribute() and self:IsShown() then
                self:SetShown(false)
            end
        end
    end)
    btn:set_event()

    GameMenuFrame:HookScript('OnShow', function()
        local b= WoWTools_ToolsMixin:Get_MainButton()
        if b.Frame:IsShown() and WoWTools_ToolsMixin:Save().isMainMenuHide then
            b:set_shown()
        end
    end)

end)















--Botón principal ya preparado (Init): sus funciones set_* existen
local function MainButton()
    local btn= WoWTools_ToolsMixin:Get_MainButton()
    if btn and btn.set_scale then
        return btn
    end
end

--Submódulos que se activan desde la lista de submódulos (save.disabledADD[nombre])
local ChildButtons= {
    Tools_Mounts='Mount', Tools_Hearthstone='Hearthstone', Tools_OpenItems='OpenItems',
    Tools_Foods='Food', Tools_UseToy='UseToy',
}
local SkipButtons= {}
for _, name in pairs(ChildButtons) do
    SkipButtons[name]= true
end

local function Get_Options()
    local list= {
        {type='section', text='GENERAL'},
        {type='check', key='enterShow', text='Open the bar on hover', tooltip='Tip.Tools.EnterShow',
            get= function(save) return save.isEnterShow end,
            set= function(save, value) save.isEnterShow= value and true or false end,
        },
        {type='check', key='combatHide', text='Hide the bar in combat', tooltip='Tip.Tools.CombatHide',
            get= function(save) return save.isCombatHide end,
            set= function(save, value) save.isCombatHide= value and true or false end,
            apply= function() local btn= MainButton() if btn then btn:set_event() end end,
        },
        {type='check', key='movingHide', text='Hide the bar when moving', tooltip='Tip.Tools.MovingHide',
            get= function(save) return save.isMovingHide end,
            set= function(save, value) save.isMovingHide= value and true or false end,
            apply= function() local btn= MainButton() if btn then btn:set_event() end end,
        },
        {type='check', key='mainMenuHide', text='Hide the bar with the game menu', tooltip='Tip.Tools.MainMenuHide',
            get= function(save) return save.isMainMenuHide end,
            set= function(save, value) save.isMainMenuHide= value and true or false end,
        },

        {type='section', text='Appearance'},
        {type='slider', key='scale', text='HOUSING_EXPERT_DECOR_SUBMODE_SCALE', tooltip='Tip.Menu.Scale',
            min=0.4, max=4, step=0.05, format='%.2f', noCombat=true,
            get= function(save) return save.scale or 1 end,
            set= function(save, value) save.scale= value end,
            apply= function() local btn= MainButton() if btn then btn:set_scale() end end,
        },
        {type='slider', key='bgAlpha', text='BACKGROUND+HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', tooltip='Tip.Menu.BgAlpha',
            min=0, max=1, step=0.1, format='%.1f',
            get= function(save) return save.bgAlpha or 0 end,
            set= function(save, value) save.bgAlpha= value end,
            apply= function() if MainButton() then WoWTools_ToolsMixin:ShowBackground() end end,
        },
        {type='slider', key='borderAlpha', text='Border opacity', tooltip='Tip.Tools.BorderAlpha',
            min=0, max=1, step=0.1, format='%.1f',
            get= function(save) return save.borderAlpha or 0 end,
            set= function(save, value) save.borderAlpha= value end,
            apply= function()
                local all, Name= WoWTools_ToolsMixin:Get_All_Buttons()
                for _, name in pairs(all) do
                    local btn= _G[Name..name]
                    if btn and btn.set_border_alpha then
                        btn:set_border_alpha()
                    end
                end
            end,
        },
        {type='dropdown', key='strata', text='Strata', tooltip='Tip.Menu.Strata', noCombat=true,
            values= function() return WoWTools_ToolsMixin:StrataValues() end,
            get= function(save) return save.strata or 'MEDIUM' end,
            set= function(save, value) save.strata= value end,
            apply= function() local btn= MainButton() if btn then btn:set_strata() end end,
        },
        {type='check', key='size30', text='Large main button (30x30)', tooltip='Tip.Tools.Size30', noCombat=true,
            get= function(save) return save.height==30 end,
            set= function(save, value) save.height= value and 30 or 10 end,
            apply= function() local btn= MainButton() if btn then btn:set_size() end end,
        },
        {type='check', key='showIcon', text='Show icon on the main button', tooltip='Tip.Tools.ShowIcon',
            get= function(save) return save.showIcon end,
            set= function(save, value) save.showIcon= value and true or false end,
            apply= function() local btn= MainButton() if btn then btn:set_icon() end end,
        },
        {type='button', key='resetPoint', text='RESET_POSITION', buttonText='RESET', noCombat=true,
            tooltip='Tip.Tools.ResetPoint',
            func= function(M, save)
                save.point= nil
                local btn= MainButton()
                if btn then
                    btn:set_point()
                end
            end,
        },

        {type='section', key='buttons', text='Toolbar buttons'},
        {type='note', key='buttonsNote', text='Tip.Tools.ButtonsNote'},
    }

    for _, opt in ipairs(WoWTools_ToolsMixin:ButtonOptions(SkipButtons)) do
        table.insert(list, opt)
    end

    table.insert(list, {type='children'})

    table.insert(list, {type='section', text='Advanced'})
    table.insert(list, {type='button', key='resetAll', text='Reset toolbar settings', buttonText='RESET',
        tooltip='Tip.Tools.ResetAll',
        func= function(M)
            StaticPopup_Show('WoWTools_RestData', M.addName, nil, function()
                WoWToolsPlusSave['WoWTools_ToolsButton']=nil
            end)
        end,
    })
    return list
end




WoWTools_Module:Register({
    key= 'WoWTools_ToolsButton', name= 'Module.Tools', icon= 'Professions-Crafting-Orders-Icon', group= 'Tools',
    tooltip= 'Tip.Tools.Enable', mixin= WoWTools_ToolsMixin,
    options= Get_Options,
    --Herramientas, Monturas... se activan con save.disabledADD; Juguetes de mapa, Profesiones, Usar objetos y
    --Portales de mago tienen su propio interruptor (save.disabled de cada submódulo)
    childToggle= WoWTools_Module:DisabledADDToggle(ChildButtons),
    defaults= {
        --disabled=true,

        disabledADD={},
        BottomPoint={
            Mount=true,
            Hearthstone=true,
            OpenItems=true,
            MapToy=true,
        },
        scale=1,
        strata='MEDIUM',

        height=10,
        lineNum=10,

        isEnterShow=true,
        isCombatHide=true,
        isMovingHide=true,
        isMainMenuHide=true,
        showIcon=true,
        --loadCollectionUI=nil,
        --show=false,
        --point

        bgAlpha= 0.5,
        borderAlpha=0,
    },

    --siempre (también desactivado)
    onLoad= function(M, save)
        save.borderAlpha= save.borderAlpha or 0.3

        if type(save.bgAlpha)~='number' then
            save.bgAlpha= 0
        end

        save.BottomPoint= save.BottomPoint or {
            Mount=true,
            Hearthstone=true,
            OpenItems=true,
            MapToy=true,
        }

        M:Init()--crea el botón principal (si no está desactivado)
    end,

    onEnable= function(M)
        if M:Get_MainButton() then
            Init()
        end
    end,

    events= {PLAYER_LOGOUT= function(M, save)
        if not WoWTools_DataMixin.ClearAllSave then
            local btn= M:Get_MainButton()
            if btn then
                save.show= btn.Frame:IsShown()
            end
        end
    end},
})
