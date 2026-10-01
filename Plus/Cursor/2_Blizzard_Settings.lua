
--Descripción (tooltip) para las casillas propias del panel
local function Set_Description(check, text)
    check:HookScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip_AddNormalLine(GameTooltip, text, true)
        GameTooltip:Show()
    end)
    check:HookScript('OnLeave', GameTooltip_Hide)
end

local function Set_Color()
    if WoWTools_CursorMixin:Save().notUseColor then
        WoWTools_CursorMixin.Color= CreateColor(1,1,1,1)
    elseif WoWTools_CursorMixin:Save().usrClassColor or not WoWTools_CursorMixin:Save().color then
        WoWTools_CursorMixin.Color= PlayerUtil.GetClassColor()
    else
        local col= WoWTools_CursorMixin:Save().color
        WoWTools_CursorMixin.Color= CreateColor(col.r or 1, col.g or 1, col.b or 1, col.a or 1)
    end
end















local function Init_GCD_Options(panel)
    if WoWTools_CursorMixin:Save().disabledGCD then
        return
    end

    panel.sliderSize = WoWTools_SliderMixin:CSlider(panel, {min=8, max=256, value=WoWTools_CursorMixin:Save().gcdSize, setp=1,
    text=WoWTools_L.HUD_EDIT_MODE_SETTING_BAGS_SIZE,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        WoWTools_CursorMixin:Save().gcdSize= value
        WoWTools_CursorMixin:GCD_Settings(true)
    end})
    panel.sliderSize:SetPoint("TOPLEFT", panel.gcdCheck, 'BOTTOMLEFT', 0, -20)

    local alphaSlider = WoWTools_SliderMixin:CSlider(panel, {min=0.1, max=1, value=WoWTools_CursorMixin:Save().alpha, setp=0.1, color=true,
    text=WoWTools_L.HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY,
    func=function(self, value)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        WoWTools_CursorMixin:Save().gcdAlpha= value
        WoWTools_CursorMixin:GCD_Settings(true)
    end})
    alphaSlider:SetPoint("TOPLEFT", panel.sliderSize, 'BOTTOMLEFT', 0, -20)

    local sliderX = WoWTools_SliderMixin:CSlider(panel, {min=-100, max=100, value=WoWTools_CursorMixin:Save().gcdX , setp=1,
    text='X',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        WoWTools_CursorMixin:Save().gcdX= value==0 and 0 or value
        WoWTools_CursorMixin:GCD_Settings(true)
    end})
    sliderX:SetPoint("TOPLEFT", alphaSlider, 'BOTTOMLEFT', 0, -20)

    local sliderY = WoWTools_SliderMixin:CSlider(panel, {min=-100, max=100, value=WoWTools_CursorMixin:Save().gcdY, setp=1, color=true,
    text='Y',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        WoWTools_CursorMixin:Save().gcdY= value==0 and 0 or value
        WoWTools_CursorMixin:GCD_Settings(true)
    end})
    sliderY:SetPoint("TOPLEFT", sliderX, 'BOTTOMLEFT', 0, -20)

    local checkReverse=CreateFrame('CheckButton', nil, panel, "InterfaceOptionsCheckButtonTemplate")
    checkReverse:SetChecked(WoWTools_CursorMixin:Save().gcdReverse)
    checkReverse.text:SetText(WoWTools_L.HUD_EDIT_MODE_SETTING_BAGS_DIRECTION)
    checkReverse:SetScript('OnMouseUp', function()
        WoWTools_CursorMixin:Save().gcdReverse = not WoWTools_CursorMixin:Save().gcdReverse and true or false
        WoWTools_CursorMixin:GCD_Settings(true)
    end)
    checkReverse:SetPoint("TOPLEFT", sliderY, 'BOTTOMLEFT', 0, -20)
    Set_Description(checkReverse, WoWTools_L['Tip.Cursor.GCDReverse'])

    local checkDrawBling=CreateFrame('CheckButton', nil, panel, "InterfaceOptionsCheckButtonTemplate")
    checkDrawBling:SetChecked(WoWTools_CursorMixin:Save().gcdReverse)
    checkDrawBling.text:SetText('|TInterface\\Cooldown\\star4:16|tDrawBling')
    checkDrawBling:SetScript('OnMouseUp', function()
        WoWTools_CursorMixin:Save().gcdDrawBling = not WoWTools_CursorMixin:Save().gcdDrawBling and true or false
        WoWTools_CursorMixin:GCD_Settings(true)
    end)
    checkDrawBling:SetPoint("LEFT", checkReverse.text, 'RIGHT', 2, 00)
    Set_Description(checkDrawBling, WoWTools_L['Tip.Cursor.GCDDrawBling'])

    local dropDown = CreateFrame("DropdownButton", nil, panel, "WowStyle1DropdownTemplate")
    local delColorButton= WoWTools_ButtonMixin:Cbtn(panel, {size=20})
    local addColorEdit= CreateFrame("EditBox", nil, panel, 'InputBoxTemplate')--EditBox
    local addColorButton= WoWTools_ButtonMixin:Cbtn(panel, {size=20})
    local numColorText= WoWTools_LabelMixin:Create(panel, {justifyH='RIGHT'})
    numColorText:SetPoint('RIGHT', dropDown, 'LEFT')
    numColorText:SetText(#WoWTools_CursorMixin:Save().GCDTexture)

    local function set_panel_Texture()
        local texture= WoWTools_CursorMixin:Save().GCDTexture[WoWTools_CursorMixin:Save().gcdTextureIndex]
        texture= texture or WoWTools_CursorMixin.DefaultGCDTexture
        panel.Texture:SetTexture(texture)
        addColorEdit:SetText(texture)
        numColorText:SetText(#WoWTools_CursorMixin:Save().GCDTexture)
    end


    dropDown:SetPoint("TOPLEFT", checkReverse, 'BOTTOMLEFT', 0,-15)
    dropDown:SetWidth(195)
    dropDown.Text:ClearAllPoints()
    dropDown.Text:SetPoint('CENTER')
    dropDown:SetDefaultText(WoWTools_CursorMixin:Save().Atlas[WoWTools_CursorMixin:Save().gcdTextureIndex] or select(3, WoWTools_TextureMixin:IsAtlas(WoWTools_CursorMixin.DefaultGCDTexture, 0)))
    dropDown:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end
        local sub
        --local num=0
        for index, texture in pairs(WoWTools_CursorMixin:Save().GCDTexture) do
            local isAtlas, _, icon= WoWTools_TextureMixin:IsAtlas(texture, 64)
            sub=root:CreateCheckbox(
                '',
            function(data)
                return WoWTools_CursorMixin:Save().gcdTextureIndex==data.index
            end, function(data)
                WoWTools_CursorMixin:Save().gcdTextureIndex=data.index
                WoWTools_CursorMixin:Save().randomTexture=nil
                panel.randomTextureCheck:SetChecked(false)
                self:SetDefaultText(data.icon)
                set_panel_Texture()
                WoWTools_CursorMixin:GCD_Settings(true)
            end, {index=index, icon=icon, texture=texture, isAtlas=isAtlas})
            sub:SetTooltip(function(tooltip, description)
                WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Cursor.GCDTexture'])
                tooltip:AddLine(select(3, WoWTools_TextureMixin:IsAtlas(description.data.texture, 64)))
                tooltip:AddLine(description.data.texture)
                tooltip:AddLine(WoWTools_L.COMBAT_ALLY_START_MISSION)
            end)
            sub:AddInitializer(function(btn, desc)
                local t= btn:AttachTexture()
                t:SetSize(32, 32)
                t:SetPoint('CENTER')
                if desc.data.isAtlas then
                    t:SetAtlas(desc.data.texture)
                else
                    t:SetTexture(desc.data.texture)
                end
            end)
        end
        WoWTools_MenuMixin:SetScrollMode(root)
    end)

    delColorButton:SetPoint('LEFT', dropDown, 'RIGHT',2,0)
    delColorButton:SetSize(20,20)
    delColorButton:SetNormalAtlas('xmarksthespot')
    delColorButton:SetScript('OnClick', function()
        local texture= WoWTools_CursorMixin:Save().GCDTexture[WoWTools_CursorMixin:Save().gcdTextureIndex]
        local icon = texture and '|T'..texture..':0|t'
        table.remove(WoWTools_CursorMixin:Save().GCDTexture, WoWTools_CursorMixin:Save().gcdTextureIndex)
        WoWTools_CursorMixin:Save().gcdTextureIndex=1
        set_panel_Texture()
        WoWTools_CursorMixin:GCD_Settings(true)
        addColorEdit:SetText(texture or WoWTools_CursorMixin.DefaultGCDTexture)
        WoWTools_Print(
            WoWTools_CursorMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_L.REMOVE,
            icon,
            texture
        )
    end)

    local function add_Color()
        local text= addColorEdit:GetText() or ''
        if text:gsub(' ','')~='' then
            table.insert(WoWTools_CursorMixin:Save().GCDTexture, text)
            addColorEdit:SetText('')
            numColorText:SetText(#WoWTools_CursorMixin:Save().GCDTexture)
        end
    end
    addColorEdit:SetPoint("TOPLEFT", dropDown, 'BOTTOMLEFT',2,-2)
	addColorEdit:SetSize(192,20)
	addColorEdit:SetAutoFocus(false)
    addColorEdit:ClearFocus()
    addColorEdit:SetScript('OnTextChanged', function(self, userInput)
        if userInput then
            local text= self:GetText()
            if text:gsub(' ','')~='' then
                if C_Texture.GetAtlasInfo(text) then
                    self:SetTextColor(0.6,0.6,0.6)
                else
                    self:SetTextColor(1,1,1)
                end
                panel.Texture:SetTexture(text)
            end
        end
    end)
    addColorEdit:SetScript('OnEnterPressed', add_Color)
    addColorEdit:SetScript('OnHide', addColorEdit.ClearFocus)

    addColorButton:SetPoint('LEFT', addColorEdit, 'RIGHT', 5,0)
    addColorButton:SetNormalAtlas('common-icon-checkmark')
    addColorButton:SetScript('OnClick', add_Color)
    addColorButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(format(WoWTools_L['LFG_LIST_CROSS_FACTION~2'] , 'Texture'))
        GameTooltip:Show()
    end)
    addColorButton:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)

    Init_GCD_Options=function()end
end



















local function Init_Options(panel)
    if WoWTools_CursorMixin:Save().disabledGCD then
        return
    end

    panel.Texture= panel:CreateTexture()
    panel.Texture:SetPoint('TOPRIGHT', panel, 'TOP', -20, 10)
    panel.Texture:SetSize(80,80)

    local useClassColorCheck= CreateFrame('CheckButton', nil, panel, "InterfaceOptionsCheckButtonTemplate")
    local colorText= WoWTools_LabelMixin:Create(panel, {color=WoWTools_CursorMixin.Color})
    local notUseColorCheck= CreateFrame('CheckButton', nil, panel, "InterfaceOptionsCheckButtonTemplate")

    useClassColorCheck:SetPoint("BOTTOMLEFT")
    useClassColorCheck.text:SetText(WoWTools_L.CLASS_COLORS)
    useClassColorCheck.text:SetTextColor(PlayerUtil.GetClassColor():GetRGB())
    useClassColorCheck:SetChecked(WoWTools_CursorMixin:Save().usrClassColor)
    useClassColorCheck:SetScript('OnMouseDown', function()
        WoWTools_CursorMixin:Save().usrClassColor= not WoWTools_CursorMixin:Save().usrClassColor and true or false
        WoWTools_CursorMixin:Save().notUseColor=nil
        notUseColorCheck:SetChecked(false)
        Set_Color()
        WoWTools_CursorMixin:GCD_Settings(true)
    end)
    Set_Description(useClassColorCheck, WoWTools_L['Tip.Cursor.ClassColor'])

    colorText:SetPoint('LEFT', useClassColorCheck.text, 'RIGHT', 4,0)
    colorText:SetText('|A:colorblind-colorwheel:0:0|a'..(WoWTools_L['CUSTOM~2']))
    colorText:EnableMouse(true)
    colorText.r, colorText.g, colorText.b, colorText.a= WoWTools_CursorMixin.Color:GetRGBA()
    colorText:SetScript('OnMouseDown', function(self)
        local usrClassColor= WoWTools_CursorMixin:Save().usrClassColor
        local notUseColor= WoWTools_CursorMixin:Save().notUseColor
        WoWTools_CursorMixin:Save().usrClassColor=nil
        WoWTools_CursorMixin:Save().notUseColor=nil
        useClassColorCheck:SetChecked(false)
        notUseColorCheck:SetChecked(false)

        local valueR, valueG, valueB, valueA= self.r, self.g, self.b, self.a
        local setA, setR, setG, setB
        local function func()
            WoWTools_CursorMixin:Save().color= {r=setR, g=setG, b=setB, a=setA}
            self:SetTextColor(setR, setG, setB, setA)
            Set_Color()
            WoWTools_CursorMixin:GCD_Settings(true)
        end
        WoWTools_ColorMixin:ShowColorFrame(self.r, self.g, self.b,self.a, function()
                setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
                func()
            end, function()
                setR, setG, setB, setA= valueR, valueG, valueB, valueA
                if usrClassColor then
                    WoWTools_CursorMixin:Save().usrClassColor=true
                    WoWTools_CursorMixin:GCD_Settings(true)
                    useClassColorCheck:SetChecked(true)
                elseif notUseColor then
                    WoWTools_CursorMixin:Save().notUseColor=true
                    WoWTools_CursorMixin:GCD_Settings(true)
                    notUseColorCheck:SetChecked(true)
                end
                func()
            end
        )
    end)
    colorText:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_L.SETTINGS, (WoWTools_L.COLOR)..WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)
    colorText:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)

    notUseColorCheck:SetPoint("LEFT", colorText, 'RIGHT')
    notUseColorCheck.text:SetText(WoWTools_L.NONE)
    notUseColorCheck:SetChecked(WoWTools_CursorMixin:Save().notUseColor)
    notUseColorCheck:SetScript('OnMouseDown', function()
        WoWTools_CursorMixin:Save().notUseColor= not WoWTools_CursorMixin:Save().notUseColor and true or nil
        Set_Color()
        useClassColorCheck:SetChecked(false)
        WoWTools_CursorMixin:GCD_Settings(true)
    end)
    Set_Description(notUseColorCheck, WoWTools_L['Tip.Cursor.NoColor'])

    panel.randomTextureCheck= CreateFrame('CheckButton', nil, panel, "InterfaceOptionsCheckButtonTemplate")
    panel.randomTextureCheck:SetPoint("LEFT", notUseColorCheck.text, 'RIGHT', 10,0)
    panel.randomTextureCheck.text:SetText('|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t'..(WoWTools_L['Random icon']))
    panel.randomTextureCheck:SetChecked(WoWTools_CursorMixin:Save().randomTexture)
    panel.randomTextureCheck:SetScript('OnMouseDown', function()
        WoWTools_CursorMixin:Save().randomTexture= not WoWTools_CursorMixin:Save().randomTexture and true or false
        WoWTools_CursorMixin:GCD_Settings(true)
    end)
    panel.randomTextureCheck:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    panel.randomTextureCheck:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        WoWTools_MenuMixin:AddDescription(GameTooltip, WoWTools_L['Tip.Cursor.RandomTexture'])
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_L.EVENTS_LABEL)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('GCD', WoWTools_TextMixin:GetEnabeleDisable(true))
        GameTooltip:Show()
    end)

    Init_Options=function()end
end



















local function Init(panel)
    

    --panel= CreateFrame('Frame')

    WoWTools_PanelMixin:AddSubCategory({
        name= WoWTools_CursorMixin.addName,
        frame= panel,
        disabled= WoWTools_CursorMixin:Save().disabledCursor and  WoWTools_CursorMixin:Save().disabledGCD,
    })

    WoWTools_PanelMixin:ReloadButton({
        panel=panel,
        addName=WoWTools_CursorMixin.addName,
        restTips=true,
        checked=nil,
        clearTips=nil,
        reload=false,
        disabledfunc=nil,
        clearfunc= function()
            WoWToolsPlusSave['Plus_Cursor']=nil
            WoWTools_DataMixin:Reload()
        end}
    )


    panel.gcdCheck=CreateFrame('CheckButton', nil, panel, "InterfaceOptionsCheckButtonTemplate")
    panel.gcdCheck:SetChecked(not WoWTools_CursorMixin:Save().disabledGCD)
    panel.gcdCheck:SetPoint("TOPLEFT", 0, -35)
    panel.gcdCheck.text:SetText((WoWTools_L.ENABLE).. ' GCD')
    panel.gcdCheck:SetScript('OnMouseDown', function()
        WoWTools_CursorMixin:Save().disabledGCD = not WoWTools_CursorMixin:Save().disabledGCD and true or nil
        WoWTools_CursorMixin:GCD_Settings(true)
        WoWTools_CursorMixin:Set_Options(panel)
    end)
    Set_Description(panel.gcdCheck, WoWTools_L['Tip.Cursor.EnableGCD'])



    if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
        Init_Options(panel)
        Init_GCD_Options(panel)
        Init=function()end
    else
        Init=function()
            Init_Options(panel)
            Init_GCD_Options(panel)
        end
    end
end











function WoWTools_CursorMixin:Set_Options(panel)
    Set_Color()
    Init(panel)
end