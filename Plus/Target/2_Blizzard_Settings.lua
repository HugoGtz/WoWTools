
local Frame

local function Save()
    return WoWToolsPlusSave['Plus_Target']
end
local function TargetTextureSave()
    return WoWToolsPlusPlayerDate['TargetTexture'] or {}
end

local function set_Target_Color(self, isInCombat)--设置，颜色
    if self then
        if isInCombat then
            self:SetVertexColor(Save().targetInCombatColor.r, Save().targetInCombatColor.g, Save().targetInCombatColor.b, Save().targetInCombatColor.a)
        else
            self:SetVertexColor(Save().targetColor.r, Save().targetColor.g, Save().targetColor.b, Save().targetColor.a)
        end
    end
end

local TextureTab={
    ['auctionhouse-icon-favorite']='a',
    ['common-icon-rotateright']='a',
    ['Adventures-Target-Indicator']='a',
    ['Adventures-Target-Indicator-desat']='a',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Hunters_Mark.tga']='t',
    ['NPE_ArrowDown']='a',
    ['UI-HUD-MicroMenu-StreamDLYellow-Up']='a',
    ['Interface\\AddOns\\WeakAuras\\Media\\Textures\\targeting-mark.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Reticule.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\RedArrow.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\NeonReticule.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\NeonRedArrow.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\RedChevronArrow.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\PaleRedChevronArrow.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\arrow_tip_green.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\arrow_tip_red.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\skull.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\circles_target.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\red_star.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\greenarrowtarget.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\BlueArrow.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\bluearrow1.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\gearsofwar.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\malthael.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\NewRedArrow.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\NewSkull.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\PurpleArrow.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Shield.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\NeonGreenArrow.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Q_FelFlamingSkull.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Q_RedFlamingSkull.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Q_ShadowFlamingSkull.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Q_GreenGPS.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Q_RedGPS.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Q_WhiteGPS.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Q_GreenTarget.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Q_RedTarget.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Q_WhiteTarget.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Arrows_Towards.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Arrows_Away.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Arrows_SelfTowards.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Arrows_SelfAway.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Arrows_FriendTowards.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Arrows_FriendAway.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Arrows_FocusTowards.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\Arrows_FocusAway.tga']='t',
    ['Interface\\AddOns\\WoWToolsPlus\\Source\\Mouse\\green_arrow_down_11384.tga']='t',
}




--Descripción (tooltip) para las casillas propias del panel
local function Set_Description(check, text)
    check:HookScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip_AddNormalLine(GameTooltip, text, true)
        GameTooltip:Show()
    end)
    check:HookScript('OnLeave', GameTooltip_Hide)
end

local function get_texture_tab()
    for name in pairs(TargetTextureSave() or {}) do
        if TextureTab[name] then
            WoWToolsPlusPlayerDate['TargetTexture'][name]=nil
        else
            TextureTab[name]= 'use'
        end
    end
    return TextureTab
end


local function Init_Options()
    local sel=CreateFrame('CheckButton', nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    sel:SetPoint('TOPLEFT', 0, -40)
    sel:SetChecked(Save().target)
    sel:SetScript('OnClick', function()
        Save().target= not Save().target and true or false
        WoWTools_TargetMixin:Set_All_Init()
    end)
    sel.Text:SetText('1) |A:common-icon-rotateright:0:0|a'..(WoWTools_L.TARGET))
    Set_Description(sel, WoWTools_L['Tip.Target.Target'])
    sel.Text:SetTextColor( Save().targetColor.r, Save().targetColor.g, Save().targetColor.b, Save().targetColor.a)
    sel.Text:EnableMouse(true)
    sel.Text:SetScript('OnMouseDown', function(self2, d)
        if d=='LeftButton' then
            local setR, setG, setB, setA
            local R,G,B,A= Save().targetColor.r, Save().targetColor.g, Save().targetColor.b, Save().targetColor.a
            local function func()
                Save().targetColor={r=setR, g=setG, b=setB, a=setA}
                self2:SetTextColor(setR, setG, setB, setA)
                set_Target_Color(Frame.tipTargetTexture, false)
                WoWTools_TargetMixin:Set_All_Init()
            end
            WoWTools_ColorMixin:ShowColorFrame(Save().targetColor.r, Save().targetColor.g, Save().targetColor.b, Save().targetColor.a, function()
                    setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
                    func()
                end, function()
                    setR, setG, setB, setA= R,G,B,A
                    func()
                end
            )
        elseif d=='RightButton' then
            Save().targetColor={r=1, g=1, b=1, a=1}
            self2:SetTextColor(1, 1, 1, 1)
            set_Target_Color(Frame.tipTargetTexture, false)
            WoWTools_TargetMixin:Set_All_Init()
        end
    end)
    sel.Text:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
    sel.Text:SetScript('OnEnter', function(self2)
        GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
        WoWTools_MenuMixin:AddDescription(GameTooltip, WoWTools_L['Tip.Target.Target'])
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_L.BINDING_NAME_NAMEPLATES, WoWTools_TextMixin:GetEnabeleDisable(C_CVar.GetCVarBool("nameplateShowEnemies")))
        GameTooltip:AddLine(' ')
        local r,g,b,a= Save().targetColor.r, Save().targetColor.g, Save().targetColor.b, Save().targetColor.a
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.left..(WoWTools_L['SETTINGS+COLOR']), (WoWTools_L.DEFAULT)..WoWTools_DataMixin.Icon.right, r,g,b, 1,1,1)
        GameTooltip:AddDoubleLine('r='..r..' g='..g..' b='..b, 'a='..a, r,g,b, r,g,b)
        GameTooltip:AddLine(' ')
        GameTooltip:Show()
        self2:SetAlpha(0.3)
    end)

    Frame.tipTargetTexture= Frame:CreateTexture()--目标，图片，提示
    Frame.tipTargetTexture:SetPoint("TOP")
    --set_Target_Texture(Frame.tipTargetTexture)--设置，图片
    Frame.tipTargetTexture:SetSize(Save().w, Save().h)--设置，大小
    set_Target_Color(Frame.tipTargetTexture, false)--设置，颜色

    local combatCheck=CreateFrame('CheckButton', nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    combatCheck:SetPoint('LEFT', sel.Text, 'RIGHT', 15,0)
    combatCheck:SetChecked(Save().targetInCombat)
    combatCheck:SetScript('OnClick', function()
        Save().targetInCombat= not Save().targetInCombat and true or false
        WoWTools_TargetMixin:Set_All_Init()
    end)
    combatCheck.Text:EnableMouse(true)
    combatCheck.Text:SetText(WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
    Set_Description(combatCheck, WoWTools_L['Tip.Target.InCombat'])
    combatCheck.Text:SetTextColor(Save().targetInCombatColor.r, Save().targetInCombatColor.g, Save().targetInCombatColor.b, Save().targetInCombatColor.a)
    combatCheck.Text:SetScript('OnMouseDown', function(self2, d)
        if d=='LeftButton' then
            local setR, setG, setB, setA
            local R,G,B,A= Save().targetInCombatColor.r, Save().targetInCombatColor.g, Save().targetInCombatColor.b, Save().targetInCombatColor.a
            local function func()
                Save().targetInCombatColor={r=setR, g=setG, b=setB, a=setA}
                self2:SetTextColor(setR, setG, setB, setA)
                set_Target_Color(Frame.tipTargetTexture, true)
                WoWTools_TargetMixin:Set_All_Init()
            end
            WoWTools_ColorMixin:ShowColorFrame(Save().targetInCombatColor.r, Save().targetInCombatColor.g, Save().targetInCombatColor.b, Save().targetInCombatColor.a, function()
                    setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
                    func()
                end, function()
                    setR, setG, setB, setA= R,G,B,A
                    func()
                end
            )
        elseif d=='RightButton' then
            Save().targetInCombatColor={r=1, g=0, b=0, a=1}
            self2:SetTextColor(1, 0, 0, 1)
            set_Target_Color(Frame.tipTargetTexture, false)
            WoWTools_TargetMixin:Set_All_Init()
        end
    end)
    combatCheck.Text:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
    combatCheck.Text:SetScript('OnEnter', function(self2)
        local r,g,b,a= Save().targetInCombatColor.r, Save().targetInCombatColor.g, Save().targetInCombatColor.b, Save().targetInCombatColor.a
        GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
        WoWTools_MenuMixin:AddDescription(GameTooltip, WoWTools_L['Tip.Target.InCombat'])
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.left..(WoWTools_L['SETTINGS+COLOR']), (WoWTools_L.DEFAULT)..WoWTools_DataMixin.Icon.right, r,g,b, 1,1,1)
        GameTooltip:AddDoubleLine('r='..r..' g='..g..' b='..b, 'a='..a, r,g,b, r,g,b)
        GameTooltip:Show()
        self2:SetAlpha(0.3)
    end)


    local menuPoint= CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    menuPoint:SetPoint("LEFT", combatCheck.Text, 'RIGHT', 15, 0)
    menuPoint:SetWidth(195)
    menuPoint.Text:ClearAllPoints()
    menuPoint.Text:SetPoint('CENTER')
    menuPoint:SetDefaultText(Save().TargetFramePoint)
    menuPoint:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end

        for _, tab in pairs({
            {name='TOP', tip=WoWTools_L['Tip.Target.PointTop']},
            {name='HEALTHBAR', tip=WoWTools_L['Tip.Target.PointHealthBar']},
            {name='LEFT', tip=WoWTools_L['Tip.Target.PointLeft']},
        }) do
            local name= tab.name
            local sub=root:CreateCheckbox(
                name,
            function(data)
                return Save().TargetFramePoint==data.name
            end, function(data)
                Save().TargetFramePoint= data.name
                self:SetDefaultText(data.name)
                WoWTools_TargetMixin:Set_All_Init()
            end, {name=name})
            WoWTools_MenuMixin:SetDescription(sub, tab.tip)
        end
    end)


    local sliderX = WoWTools_SliderMixin:CSlider(Frame, {min=-250, max=250, value=Save().x, setp=1, w= 100,
    text= 'X',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().x= value
        WoWTools_TargetMixin:Set_All_Init()
    end})
    sliderX:SetPoint("TOPLEFT", sel, 'BOTTOMRIGHT',0, -12)
    local sliderY = WoWTools_SliderMixin:CSlider(Frame, {min=-250, max=250, value=Save().y, setp=1, w= 100, color=true,
    text= 'Y',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().y= value
        WoWTools_TargetMixin:Set_All_Init()
    end})
    sliderY:SetPoint("LEFT", sliderX, 'RIGHT',15,0)
    local sliderW = WoWTools_SliderMixin:CSlider(Frame, {min=10, max=100, value=Save().w, setp=1, w= 100,
    text= 'W',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().w= value
        Frame.tipTargetTexture:SetSize(Save().w, Save().h)--设置，大小
        WoWTools_TargetMixin:Set_All_Init()
    end})
    sliderW:SetPoint("LEFT", sliderY, 'RIGHT',15,0)
    local sliderH = WoWTools_SliderMixin:CSlider(Frame, {min=10, max=100, value=Save().h, setp=1, w= 100, color=true,
    text= 'H',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().h= value
        Frame.tipTargetTexture:SetSize(Save().w, Save().h)--设置，大小
        WoWTools_TargetMixin:Set_All_Init()
    end})
    sliderH:SetPoint("LEFT", sliderW, 'RIGHT',15,0)



    local sliderScale = WoWTools_SliderMixin:CSlider(Frame, {min=0.2, max=4, value=Save().scale or 1, setp=0.1, w= 100,
    text= WoWTools_L.HOUSING_EXPERT_DECOR_SUBMODE_SCALE,
    func=function(self2, value)
        value= tonumber(format('%.1f', value))
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().scale= value
        WoWTools_TargetMixin:Set_All_Init()
    end,
    --tooltip= '1 = '..(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE)
    })
    sliderScale:SetPoint("TOPLEFT", sliderX, 'BOTTOMLEFT', 0,-16)

    local sliderElapsed = WoWTools_SliderMixin:CSlider(Frame, {min=0.3, max=1.5, value=Save().elapsed or 0.5, setp=0.1, w= 100, color=true,
    text= WoWTools_L.SPEED,
    func=function(self2, value)
        value= tonumber(format('%.1f', value))
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save().elapsed= value
        WoWTools_TargetMixin:Set_All_Init()
    end})
    sliderElapsed:SetPoint("LEFT", sliderScale, 'RIGHT',15, 0)


    local menu= CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    menu:SetPoint("TOPLEFT", sel, 'BOTTOMRIGHT', -16,-82)
    menu:SetWidth(445)
    menu:SetDefaultText(Save().targetTextureName)
    menu.Text:ClearAllPoints()
    menu.Text:SetPoint('CENTER')
    menu:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end

        local num=0
        local sub
        for name, use in pairs(get_texture_tab()) do
            local isAtlas, _, icon= WoWTools_TextureMixin:IsAtlas(name, 128)
            if icon then
                sub=root:CreateRadio(
                    (use=='use' and '|cnGREEN_FONT_COLOR:' or '')
                    ..(name:match('.+\\(.+)') or name):gsub('%..+', ''),
                function(data)
                    return Save().targetTextureName== data.name
                end, function(data)
                    Save().targetTextureName= data.name
                    self:SetDefaultText(data.icon)
                    self.edit:SetText(data.name)
                    WoWTools_TargetMixin:Set_All_Init()
                end, {name=name, icon=icon, isAtlas=isAtlas})

                sub:AddInitializer(function(btn, desc)
                    local t = btn:AttachTexture()
                    t:SetSize(32, 32)
                    t:SetPoint("RIGHT")
                    if desc.data.isAtlas then
                        t:SetAtlas(desc.data.name)
                    else
                        t:SetTexture(desc.data.name or 0)
                    end
                end)

                sub:SetTooltip(function(tooltip, desc)
                    WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Target.Texture'])
                    tooltip:AddLine(desc.data.icon)
                    tooltip:AddLine(desc.data.name)
                end)
                num= num+1
            end
        end
--SetScrollMod
        WoWTools_MenuMixin:SetScrollMode(root)
    end)

    menu.edit= CreateFrame("EditBox", nil, menu, 'InputBoxTemplate')--EditBox
    WoWTools_TextureMixin:SetEditBox(menu.edit)
    menu.edit:SetPoint("TOPLEFT", menu, 'BOTTOMLEFT',22,-2)
	menu.edit:SetSize(420,22)
	menu.edit:SetAutoFocus(false)
    menu.edit:ClearFocus()
    menu.edit.Label= WoWTools_LabelMixin:Create(menu.edit)
    menu.edit.Label:SetPoint('RIGHT', menu.edit, 'LEFT', -4, 0)
    menu.edit:SetScript('OnShow', function(self)
        self:SetText(Save().targetTextureName)
    end)
    menu.edit:SetScript('OnTextChanged', function(self)
        local name, isAtlas
        name= self:GetText() or ''
        name= name:gsub(' ', '')
        name= name=='' and false or name
        if name then
            isAtlas, name= WoWTools_TextureMixin:IsAtlas(name)
            if name then
                if isAtlas then
                    Frame.tipTargetTexture:SetAtlas(name)
                else
                    Frame.tipTargetTexture:SetTexture(name)
                end
                self.Label:SetText(isAtlas and 'Atls' or 'Texture')
            else
                Frame.tipTargetTexture:SetTexture(0)
            end
        end
        self.del:SetShown(name and TargetTextureSave()[name])
        self.add:SetShown(name and not TargetTextureSave()[name])
    end)

    --删除，图片
    menu.edit.del= WoWTools_ButtonMixin:Cbtn(menu.edit, {atlas='xmarksthespot', size=23})
    menu.edit.del:SetPoint('LEFT', menu, 'RIGHT',2,0)
    menu.edit.del:SetScript('OnClick', function(self)
        local parent= self:GetParent()
        local isAtals, name= WoWTools_TextureMixin:IsAtlas(parent:GetText())
        if name and TargetTextureSave()[name] then
            WoWToolsPlusPlayerDate['TargetTexture'][name]= nil
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_TargetMixin.addName,
                '|cnWARNING_FONT_COLOR:'..(WoWTools_L.DELETE)..'|r',
                (isAtals and '|A:'..name..':0:0|a' or ('|T'..name..':0|t'))..name
            )
            parent:SetText("")
            parent:SetText(name)
        end
    end)

    --添加按钮
    menu.edit.add= WoWTools_ButtonMixin:Cbtn(menu.edit, {atlas='common-icon-checkmark', size=23})--添加, 按钮
    menu.edit.add:SetPoint('LEFT', menu.edit, 'RIGHT', 5,0)
    menu.edit.add:SetScript('OnClick', function(self)
        local parent= self:GetParent()
        local isAtlas, icon= WoWTools_TextureMixin:IsAtlas(parent:GetText())
        if icon and not TargetTextureSave()[icon] then
            WoWToolsPlusPlayerDate['TargetTexture'][icon]= isAtlas and 'a' or 't'
            parent:SetText('')
            print(WoWTools_DataMixin.addName,
                WoWTools_TargetMixin.addName,
                '|cnGREEN_FONT_COLOR:'..(WoWTools_L.ADD)..'|r',
                (isAtlas and '|A:'..icon..':0:0|a' or ('|T'..icon..':0|t'))..icon
            )
        end
    end)
    menu.edit.add:SetScript('OnLeave', GameTooltip_Hide)
    menu.edit.add:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        local atlas, icon= WoWTools_TextureMixin:IsAtlas(menu.edit:GetText())
        if icon then
            GameTooltip:AddDoubleLine(atlas and '|A:'..icon..':0:0|a' or ('|T'..icon..':0|t'), WoWTools_L.ADD)
            GameTooltip:AddDoubleLine(atlas and 'Atlas' or 'Texture', icon)
        else
            GameTooltip:AddLine(WoWTools_L.NONE)
        end
        GameTooltip:Show()
    end)


    local questCheck= CreateFrame('CheckButton', nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    questCheck.Text:SetText('4) '..(WoWTools_L['Quest progress']))
    --questCheck:SetPoint('TOPLEFT', sel2, 'BOTTOMLEFT',0,-64)
    questCheck:SetPoint('TOPLEFT', menu.edit, 'BOTTOMLEFT', -32, -32)
    questCheck:SetChecked(Save().quest)
    Set_Description(questCheck, WoWTools_L['Tip.Target.Quest'])
    questCheck:SetScript('OnClick', function()
        Save().quest= not Save().quest and true or false
        WoWTools_TargetMixin:Set_All_Init()
    end)

    local questAllFactionCheck= CreateFrame('CheckButton', nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    questAllFactionCheck.Text:SetFormattedText(
        '%s|A:%s:0:0|a|A:%s:0:0|a',
        WoWTools_L['All factions'],
        WoWTools_DataMixin.Icon.Horde, WoWTools_DataMixin.Icon.Alliance)

    questAllFactionCheck:SetPoint('LEFT', questCheck.Text, 'RIGHT',2,0)
    questAllFactionCheck:SetChecked(Save().questShowAllFaction)
    Set_Description(questAllFactionCheck, WoWTools_L['Tip.Target.QuestAllFaction'])
    questAllFactionCheck:SetScript('OnClick', function()
        Save().questShowAllFaction= not Save().questShowAllFaction and true or nil
        WoWTools_TargetMixin:Set_All_Init()
    end)

    local classCheck= CreateFrame('CheckButton', nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    classCheck.Text:SetText(WoWTools_L.CLASS)
    classCheck:SetPoint('LEFT', questAllFactionCheck.Text, 'RIGHT',2,0)
    classCheck:SetChecked(Save().questShowPlayerClass)
    Set_Description(classCheck, WoWTools_L['Tip.Target.QuestClass'])
    classCheck:SetScript('OnClick', function()
        Save().questShowPlayerClass= not Save().questShowPlayerClass and true or false
        WoWTools_TargetMixin:Set_All_Init()
    end)


    Init_Options=function()end
end


--添加控制面板
local function Init()
    Frame= CreateFrame('Frame', nil, SettingsPanel)

    WoWTools_PanelMixin:AddSubCategory({
        name= WoWTools_TargetMixin.addName,
        frame= Frame,
        disabled= Save().disabled
    })

    WoWTools_PanelMixin:ReloadButton({panel=Frame, addName= WoWTools_TargetMixin.addName, restTips=nil, checked=not Save().disabled, clearTips=nil, reload=false,--重新加载UI, 重置, 按钮
        disabledfunc=function()
            Save().disabled= not Save().disabled and true or nil

            Init_Options()
            WoWTools_TargetMixin:Set_All_Init()

            print(WoWTools_DataMixin.Icon.icon2..WoWTools_TargetMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), Save().disabled and (WoWTools_L.REQUIRES_RELOAD) or '')

        end,
        clearfunc= function() WoWToolsPlusSave['Plus_Target']=nil WoWTools_DataMixin:Reload() end}
    )

    if not Save().disabled then
        if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
            Init_Options()
        else
            EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
                if arg1=='Blizzard_Settings' then
                    Init_Options()
                    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
                end
            end)
        end
    end

    Init=function()end
end


function WoWTools_TargetMixin:Init_Options()
    Init()
end