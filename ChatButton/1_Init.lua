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


local Init_Panel_Once= WoWTools_Once(function()
    WoWTools_PanelMixin:Header(WoWTools_ChatMixin.Layout, WoWTools_L.OPTIONS)

    for _, data in pairs (WoWTools_ChatMixin:GetAllAddList()) do
        WoWTools_PanelMixin:OnlyCheck({
            category= WoWTools_ChatMixin.Category,
            name= data.tooltip,
            tooltip= WoWTools_L['Tip.Chat.AddButton']..'|n|n'..data.name,
            Value= not WoWTools_ChatMixin:Save().disabledADD[data.name],
            GetValue= function() return not WoWTools_ChatMixin:Save().disabledADD[data.name] end,
            SetValue= function()
                WoWTools_ChatMixin:Save().disabledADD[data.name]= not WoWTools_ChatMixin:Save().disabledADD[data.name] and true or nil
            end
        })
    end
end)

--Solo se crea con el módulo activado (puede activarse más tarde desde la casilla)
local function Init_Panel()
    if WoWTools_ChatMixin:Save().disabled then
        return
    end
    Init_Panel_Once()
end


--Página de opciones propia (subcategoría): se crea siempre, aunque esté desactivado
local function Init_Options()
    WoWTools_ChatMixin:Save().disabledADD= WoWTools_ChatMixin:Save().disabledADD or {}

    WoWTools_ChatMixin.Category, WoWTools_ChatMixin.Layout= WoWTools_PanelMixin:AddSubCategory({
        name=WoWTools_ChatMixin.addName,
        disabled=WoWTools_ChatMixin:Save().disabled
    })

    WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_L.ENABLE,
        GetValue= function() return not WoWTools_ChatMixin:Save().disabled end,
        SetValue= function()
            WoWTools_ChatMixin:Save().disabled= not WoWTools_ChatMixin:Save().disabled and true or nil
            Init_Panel()
        end,
        buttonText= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_L.RESET),
        buttonFunc= function()
            StaticPopup_Show('WoWTools_RestData',
                WoWTools_ChatMixin.addName,
                nil,
            function()
                WoWToolsPlusSave['ChatButton']= nil
            end)
        end,
        tooltip= WoWTools_L['Tip.Chat.Enable']..'|n|n'..'|cnWARNING_FONT_COLOR:'..(WoWTools_L.REQUIRES_RELOAD),
        layout= WoWTools_ChatMixin.Layout,
        category= WoWTools_ChatMixin.Category,
    })

    WoWTools_PanelMixin:OnlyButton({
        buttonText= WoWTools_L.RESET_POSITION,
        category= WoWTools_ChatMixin.Category,
        layout= WoWTools_ChatMixin.Layout,
        SetValue= function()
            WoWTools_ChatMixin:Save().Point=nil
            if _G['WoWToolsChatButtonMainButton'] then
                _G['WoWToolsChatButtonMainButton']:settings()
            end
            WoWTools_Print(
                WoWTools_ChatMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_L.RESET_POSITION
            )
        end
    })

    WoWTools_PanelMixin:Header(WoWTools_ChatMixin.Layout, WoWTools_L.OTHER)

    EventUtil.ContinueOnAddOnLoaded('Blizzard_Settings', Init_Panel)
end


--Los botones (submódulos) se registran después, con parent='ChatButton'
WoWTools_Module:Register({
    key= 'ChatButton', name= 'Module.Chat tools', icon= 'voicechat-icon-textchat-silenced', group= 'Chat',
    defaults= P_Save, tooltip= 'Tip.Chat.Enable', mixin= WoWTools_ChatMixin,
    panel= false,--tiene su propia página de opciones (Init_Options)
    onLoad= Init_Options,
    onEnable= Init,
})
