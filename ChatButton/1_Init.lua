local P_Save={
    --disabled=true,    
    disabledADD={
        ['ChatButton_Emoji']= not WoWTools_DataMixin.Player.IsCN and true,
    },
    scale= 1,
    strata='MEDIUM',

    borderAlpha=0,
    bgAlpha=0,

    pointX=0,
    anchorMenuIndex=1,
    setChatFrameLeft=nil,

    disabledTooltiip=nil,

}



local function Set_All_Buttons(self)
    local Buttons= WoWTools_ChatMixin:GetButtons()
    local Name= WoWTools_ChatMixin:GetNameText()
    for _, name in pairs(Buttons) do
        _G[Name..name]:SetAllSettings()
    end
    self:set_backgroud()
    self:set_menu_anchor()
end


local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2
    WoWTools_MenuMixin:Scale(self, root, function()
        return WoWTools_ChatMixin:Save().scale
    end, function(value)
        WoWTools_ChatMixin:Save().scale= value
        self:settings()
    end)

    sub=WoWTools_MenuMixin:BgAplha(root, function()
        return WoWTools_ChatMixin:Save().bgAlpha or 0
    end, function(value)
        WoWTools_ChatMixin:Save().bgAlpha=value
        self:set_backgroud()
    end, function()
        WoWTools_ChatMixin:Save().bgAlpha= nil
        WoWTools_ChatMixin:Save().bgUseClassColor= nil
        self:set_backgroud()
    end)

    sub:CreateSpacer()
    sub2=sub:CreateCheckbox(
        WoWTools_L.CLASS_COLORS,
    function()
        return WoWTools_ChatMixin:Save().bgUseClassColor
    end, function()
        WoWTools_ChatMixin:Save().bgUseClassColor= not WoWTools_ChatMixin:Save().bgUseClassColor and true or nil
        self:set_backgroud()
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Chat.BgClassColor'])


--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, root, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        WoWTools_ChatMixin:Save().strata= data
        self:settings()
        return MenuResponse.Refresh
    end)

    sub=root:CreateButton(
        '|A:bag-reagent-border:0:0|a'..(WoWTools_L.EMBLEM_BORDER),
    function()
        return MenuResponse.Open
    end, {rightText= WoWTools_ChatMixin:Save().borderAlpha or 0.3})
    WoWTools_MenuMixin:SetRightText(sub)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Chat.Border'])

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return WoWTools_ChatMixin:Save().borderAlpha or 0.3
        end, setValue=function(value)
            WoWTools_ChatMixin:Save().borderAlpha=value
            Set_All_Buttons(self)
        end,
        name=WoWTools_L.HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY,
        minValue=0,
        maxValue=1,
        step=0.1,
        bit='%0.1f',
    })

    sub:CreateSpacer()
    sub:CreateSpacer()

    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return WoWTools_ChatMixin:Save().pointX or 0
        end, setValue=function(value)
            WoWTools_ChatMixin:Save().pointX=value
            Set_All_Buttons(self)
        end,
        name='X',
        minValue=-15,
        maxValue=15,
        step=1,
    })

    sub:CreateDivider()
    sub:CreateButton(
        WoWTools_L.RESET,
    function()
        WoWTools_ChatMixin:Save().pointX=0
        WoWTools_ChatMixin:Save().borderAlpha=0.3
        Set_All_Buttons(self)
        return MenuResponse.Open
    end)


    sub=root:CreateCheckbox(
        '|A:bags-greenarrow:0:0|a'
        ..(WoWTools_L.HUD_EDIT_MODE_SETTING_BAGS_DIRECTION),
    function()
        return WoWTools_ChatMixin:Save().isVertical
    end, function()
        WoWTools_ChatMixin:Save().isVertical= not WoWTools_ChatMixin:Save().isVertical and true or nil
        self:settings()
        Set_All_Buttons(self)
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Chat.Vertical'])



    local textTab={
      '|cnGREEN_FONT_COLOR:'..(WoWTools_L.HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN),
      WoWTools_L.HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP,
      WoWTools_L.HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT,
      WoWTools_L.HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT,
    }
    for index, tab in pairs(WoWTools_ChatMixin.AnchorMenuTab) do
        sub2=sub:CreateCheckbox(
            textTab[index],
        function(data)
            return (WoWTools_ChatMixin:Save().anchorMenuIndex or 1)==data.index

        end, function(data)
            WoWTools_ChatMixin:Save().anchorMenuIndex= data.index
            Set_All_Buttons(self)

        end, {index=index, p=tab[1], p2=tab[2]})

        sub2:SetTooltip(function(tooltip, desc)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Chat.MenuAnchor'])
            tooltip:AddLine(WoWTools_L['HUD_EDIT_MODE_MICRO_MENU_LABEL+CHOOSE_LOCATION'])
            tooltip:AddDoubleLine(desc.data.p, desc.data.p2)
        end)
    end


    sub=root:CreateCheckbox(
        WoWTools_L.HUD_EDIT_MODE_HUD_TOOLTIP_LABEL,
    function()
        return not WoWTools_ChatMixin:Save().disabledTooltiip
    end, function()
        WoWTools_ChatMixin:Save().disabledTooltiip= not WoWTools_ChatMixin:Save().disabledTooltiip and true or nil
    end)
    sub:SetTooltip(function (tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Chat.Tooltip'])
        tooltip:AddLine('GameTooltip')
    end)

--UIParent
    sub= root:CreateCheckbox(
        'UIParent',
    function()
        return not WoWTools_ChatMixin:Save().setParent
    end, function()
        WoWTools_ChatMixin:Save().setParent= not WoWTools_ChatMixin:Save().setParent and true or nil
        self:settings()
        MenuUtil.ShowTooltip(self, function(tooltip)
            tooltip:AddLine('SetParent '..'|cnGREEN_FONT_COLOR:'..self:GetParent():GetName())
        end)
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Chat.UIParent'])
        tooltip:AddLine('SetParent '..'|cnGREEN_FONT_COLOR:'..self:GetParent():GetName())
    end)
--WoWTools_Join(HUD_EDIT_MODE_CHAT_FRAME_LABEL, HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_DOWN),

    sub=root:CreateCheckbox(
        WoWTools_L.HUD_EDIT_MODE_CHAT_FRAME_LABEL,
    function()
        return WoWTools_ChatMixin:Save().setChatFrameLeft
    end, function()
        WoWTools_ChatMixin:Save().setChatFrameLeft= not WoWTools_ChatMixin:Save().setChatFrameLeft and true or nil
        if WoWTools_ChatMixin:Save().setChatFrameLeft then
            WoWTools_ChatMixin:Save().Point= nil
        end
        self:settings()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Chat.ChatFrameLeft'])


    sub=root:CreateCheckbox(
        '|A:newplayertutorial-drag-cursor:0:0|a'
        ..(WoWTools_L['ENTER_LFG+EMBLEM_SYMBOL']),
    function()
        return WoWTools_ChatMixin:Save().isEnterShowMenu
    end, function()
        WoWTools_ChatMixin:Save().isEnterShowMenu = not WoWTools_ChatMixin:Save().isEnterShowMenu and true or nil
    end)
    sub:SetTooltip(function (tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Chat.EnterShowMenu'])
        tooltip:AddLine(WoWTools_L['SHOW+HUD_EDIT_MODE_MICRO_MENU_LABEL'])
    end)



    root:CreateDivider()
    sub= WoWTools_ChatMixin:Open_SettingsPanel(root, nil)

    WoWTools_MenuMixin:RestPoint(self, sub, WoWTools_ChatMixin:Save().Point, function()
        WoWTools_ChatMixin:Save().Point=nil
        self:settings()
        return MenuResponse.Open
    end)
end


local Init= WoWTools_Once(function()
    local btn= CreateFrame('DropdownButton', 'WoWToolsChatButtonMainButton', UIParent)

    WoWTools_ChatMixin:Set_Button_Script(btn)
    btn:SetHighlightAtlas('WoWShare-Highlight')
    btn:SetPushedAtlas('WoWShare-Selection')

    btn.Background= btn:CreateTexture(nil, 'BACKGROUND')

    function btn:set_backgroud()
        local Name= WoWTools_ChatMixin:GetNameText()
        local Buttons= WoWTools_ChatMixin:GetButtons()
        local btn1= Buttons[1] and _G[Name..Buttons[1]]
        if not btn1 then
            self.Background:SetColorTexture(0,0,0,0)
            return
        end

        local btn2= _G[Name..Buttons[#Buttons]]

        self.Background:ClearAllPoints()

        self.Background:SetPoint('BOTTOMLEFT', btn1, -2, -2)

        local w= 30+ 4
        if WoWTools_ChatMixin:Save().isVertical then
            self.Background:SetPoint('TOPLEFT', btn2, -2, 2)
            self.Background:SetWidth(w)
        else
            self.Background:SetPoint('BOTTOMRIGHT', btn2, 2, -2)
            self.Background:SetHeight(w+1)
        end

        local r,g,b,a= 0, 0, 0, WoWTools_ChatMixin:Save().bgAlpha or 0
        if WoWTools_ChatMixin:Save().bgUseClassColor then
            r,g,b= PlayerUtil.GetClassColor():GetRGB()
        end
        self.Background:SetColorTexture(r,g,b,a)
    end

    function btn:set_menu_anchor()
        local point= WoWTools_ChatMixin.AnchorMenuTab[WoWTools_ChatMixin:Save().anchorMenuIndex or 1]
        self:SetMenuAnchor(AnchorUtil.CreateAnchor(point[1], self, point[2]))
    end


    SELECTED_DOCK_FRAME.editBox:SetAltArrowKeyMode(false)
    WoWTools_TextureMixin:SetEditBox(SELECTED_DOCK_FRAME.editBox, {alpha=1})

    function btn:settings()
        if WoWTools_ChatMixin:Save().isVertical then
            self:SetSize(30,10)
        else
            self:SetSize(10,30)
        end
        self:set_menu_anchor()
        self:SetFrameStrata(WoWTools_ChatMixin:Save().strata or 'MEDIUM')
        self:SetScale(WoWTools_ChatMixin:Save().scale or 1)

        self:ClearAllPoints()

        local toChatFrame= WoWTools_ChatMixin:Save().setChatFrameLeft and true or false
        if toChatFrame then
            self:SetPoint('TOP', ChatFrameMenuButton, 'BOTTOM')
        elseif WoWTools_ChatMixin:Save().Point then
            self:SetPoint(WoWTools_ChatMixin:Save().Point[1], UIParent, WoWTools_ChatMixin:Save().Point[3], WoWTools_ChatMixin:Save().Point[4], WoWTools_ChatMixin:Save().Point[5])
        else
            self:SetPoint('BOTTOMLEFT', SELECTED_CHAT_FRAME, 'TOPLEFT', -5, 30)
        end

        self:SetParent(WoWTools_ChatMixin:Save().setParent and GeneralDockManager or UIParent)

        self:SetMovable(not toChatFrame)
        self:SetClampedToScreen(true)--movida libremente también: si no, se podía perder fuera de la pantalla
        if toChatFrame then
            self:RegisterForDrag()
        else
            self:RegisterForDrag("RightButton")
        end
    end

    function btn:set_tooltip()
        if not self:IsMovable() then
            return
        end
        GameTooltip:SetText(
            (WoWTools_L.NPE_MOVE)
            ..' Alt+'
            ..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:Show()
    end


    btn:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)

    btn:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            WoWTools_ChatMixin:Save().Point={self:GetPoint(1)}
            WoWTools_ChatMixin:Save().Point[2]=nil
        end
    end)

    btn:SetScript("OnMouseUp", function()
        ResetCursor()
    end)
    btn:SetScript("OnMouseDown", function(self, d)
        if IsAltKeyDown() and d=='RightButton' and self:IsMovable() then
            SetCursor('UI_MOVE_CURSOR')
            self:CloseMenu()
        end
    end)

    btn:settings()
    btn:SetupMenu(Init_Menu)
end)


--Refresco en vivo de la barra (lo usan el menú y el Centro de control). all: también los botones
function WoWTools_ChatMixin:Refresh(all)
    local btn= _G['WoWToolsChatButtonMainButton']
    if not btn then
        return
    end
    btn:settings()
    if all then
        Set_All_Buttons(btn)
    end
end


local StrataList= {'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}

local function Strata_Values()
    local list= {}
    for _, strata in ipairs(StrataList) do
        table.insert(list, {value=strata, text=strata})
    end
    return list
end

local function Anchor_Values()
    return {
        {value=1, text='HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN'},
        {value=2, text='HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP'},
        {value=3, text='HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT'},
        {value=4, text='HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT'},
    }
end

local function Refresh()
    WoWTools_ChatMixin:Refresh()
end

local function Refresh_All()
    WoWTools_ChatMixin:Refresh(true)
end

--Esquema del Centro de control (docs/SETTINGS.md): mismos campos que el menú del botón
local Options= {
    {type='section', text='GENERAL'},
    {type='check', key='enterShowMenu', text='Open menus on mouseover', tooltip='Tip.Chat.EnterShowMenu',
        get= function(save) return save.isEnterShowMenu end,
        set= function(save, value) save.isEnterShowMenu= value and true or nil end,
    },
    {type='check', key='tooltip', text='Show tooltips', tooltip='Tip.Chat.Tooltip',
        get= function(save) return not save.disabledTooltiip end,
        set= function(save, value) save.disabledTooltiip= not value and true or nil end,
    },
    {type='children'},

    {type='section', text='Appearance'},
    {type='slider', key='scale', text='SCALE', tooltip='Tip.Menu.Scale', min=0.4, max=4, step=0.1, format='%.1f',
        get= function(save) return save.scale or 1 end,
        set= function(save, value) save.scale= value end,
        apply= Refresh,
    },
    {type='check', key='vertical', text='Vertical layout', tooltip='Tip.Chat.Vertical',
        get= function(save) return save.isVertical end,
        set= function(save, value) save.isVertical= value and true or nil end,
        apply= Refresh_All,
    },
    {type='dropdown', key='anchorMenu', text='Menu direction', tooltip='Tip.Chat.MenuAnchor',
        values= Anchor_Values,
        get= function(save) return save.anchorMenuIndex or 1 end,
        set= function(save, value) save.anchorMenuIndex= value end,
        apply= Refresh_All,
    },
    {type='slider', key='pointX', text='Button spacing', tooltip='Tip.Chat.Border', min=-15, max=15, step=1,
        get= function(save) return save.pointX or 0 end,
        set= function(save, value) save.pointX= value end,
        apply= Refresh_All,
    },
    {type='slider', key='borderAlpha', text='Border opacity', tooltip='Tip.Chat.Border', min=0, max=1, step=0.1, format='%.1f',
        get= function(save) return save.borderAlpha or 0.3 end,
        set= function(save, value) save.borderAlpha= value end,
        apply= Refresh_All,
    },
    {type='slider', key='bgAlpha', text='BACKGROUND+HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', tooltip='Tip.Menu.BgAlpha',
        min=0, max=1, step=0.1, format='%.1f',
        get= function(save) return save.bgAlpha or 0 end,
        set= function(save, value) save.bgAlpha= value end,
        apply= Refresh_All,
    },
    {type='check', key='bgClassColor', text='CLASS_COLORS', tooltip='Tip.Chat.BgClassColor', indent=true,
        get= function(save) return save.bgUseClassColor end,
        set= function(save, value) save.bgUseClassColor= value and true or nil end,
        apply= Refresh_All,
    },
    {type='dropdown', key='strata', text='Strata', tooltip='Tip.Menu.Strata',
        values= Strata_Values,
        get= function(save) return save.strata or 'MEDIUM' end,
        set= function(save, value) save.strata= value end,
        apply= Refresh,
    },

    {type='check', key='chatFrameLeft', text='Attach under the chat menu button', tooltip='Tip.Chat.ChatFrameLeft',
        get= function(save) return save.setChatFrameLeft end,
        set= function(save, value)
            save.setChatFrameLeft= value and true or nil
            if save.setChatFrameLeft then
                save.Point= nil
            end
        end,
        apply= Refresh,
    },
    {type='check', key='uiParent', text='Attach to UIParent', tooltip='Tip.Chat.UIParent',
        get= function(save) return not save.setParent end,
        set= function(save, value) save.setParent= not value and true or nil end,
        apply= Refresh,
    },
    {type='button', key='resetPoint', text='RESET_POSITION', buttonText='RESET',
        disabled= function(save) return save.setChatFrameLeft or not save.Point end,
        func= function(M, save)
            save.Point= nil
            M:Refresh()
            M:Print(WoWTools_L.RESET_POSITION)
        end,
    },

    {type='section', text='Advanced'},
    {type='button', key='reset', text='Reset all settings', buttonText='RESET', tooltip='Tip.Menu.RestData',
        func= function(M)
            StaticPopup_Show('WoWTools_RestData', M.addName, nil, function()
                WoWToolsPlusSave['ChatButton']= nil
            end)
        end,
    },
}


--Los botones (submódulos) se registran después, con parent='ChatButton'
WoWTools_Module:Register({
    key= 'ChatButton', name= 'Module.Chat tools', icon= 'voicechat-icon-textchat-silenced', group= 'Chat',
    defaults= P_Save, tooltip= 'Tip.Chat.Enable', mixin= WoWTools_ChatMixin,
    options= Options,
    onLoad= function(_, save)
        save.disabledADD= save.disabledADD or {}
    end,
    onEnable= Init,
    childToggle= WoWTools_Module:DisabledADDToggle({
        ChatButtonGroup='Group', ChatButtonGuild='Guild', ChatButton_LFD='LFD', ChatButton_HyperLink='HyperLink',
        ChatButton_Say='Say', ChatButton_Invite='Invite', ChatButton_Roll='Roll',--Plus_EmoteButton usa su propio interruptor
    }),
})
