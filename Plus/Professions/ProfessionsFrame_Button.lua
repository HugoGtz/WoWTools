
local function Save()
    return WoWToolsPlusSave['Plus_Professions']
end
local Frame










local function Init_Frame()
    Frame= CreateFrame('Frame', nil, ProfessionsFrame)
    Frame:SetPoint('BOTTOMLEFT', ProfessionsFrame, 'BOTTOMRIGHT',0, 35)
    Frame:SetSize(1,1)


    function Frame:set_scale()
        self:SetScale(Save().scaleButton or 1)
    end
    Frame:set_scale()


    if Save().showFuocoButton then
        function Frame:set_event()
            self:UnregisterAllEvents()
            if ProfessionsFrame:IsVisible() then
                self:RegisterEvent('PLAYER_REGEN_DISABLED')
            else
                self:UnregisterEvent('PLAYER_REGEN_DISABLED')
            end
        end
        Frame:SetScript('OnEvent', function()
            if ProfessionsFrame:IsVisible() then
                --GenerateClosure(ProfessionsFrame.CheckConfirmClose, ProfessionsFrame)
                WoWTools_DataMixin:Call('HideUIPanel', ProfessionsFrame)
            end
        end)

        ProfessionsFrame:HookScript('OnShow', function()
            Frame:set_event()
        end)
        ProfessionsFrame:HookScript('OnHide', function()
            Frame:set_event()
        end)

        Frame:set_event()
    end
end







local function Init_Fuoco_Button(button)
    local btn= WoWTools_ButtonMixin:Cbtn(button, {
        isSecure=true,
        texture=135805,
        size=32
    })
    btn:SetPoint('LEFT', button, 'RIGHT',2,0)

    btn:RegisterEvent('SPELL_UPDATE_COOLDOWN')
    WoWTools_CooldownMixin:SetFrame(btn, {spellID=818})

    btn:SetScript('OnEvent', function (self)
        WoWTools_CooldownMixin:SetFrame(self, {spellID=818})
    end)

    btn:SetScript('OnShow', function (self)
        self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
        WoWTools_CooldownMixin:SetFrame(self, {spellID=818})
    end)

    btn:SetScript('OnHide', function (self)
        WoWTools_CooldownMixin:SetFrame(self)
        self:UnregisterAllEvents()
        self:SetScript('OnUpdate', nil)
    end)


    function btn:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:SetSpellByID(818)
        GameTooltip:AddLine(' ')
        local text= self:GetAttribute('macrotext*')
        if text then
            GameTooltip:AddLine(text)
        else
            text= self:GetAttribute('item2')
            if text then
                GameTooltip:AddLine(text..WoWTools_DataMixin.Icon.right)
            end
        end
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_ProfessionMixin.addName)
        GameTooltip:Show()
    end

    btn:SetScript('OnLeave', function(self)
        self:SetScript('OnUpdate', nil)
        GameTooltip:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self:SetScript('OnUpdate', function(f, elapsed)
            f.elapsed= (f.elapsed or 0) + elapsed
            if f.elapsed >= 1 then
                f.elapsed= 0
                self:set_tooltip()
            end
        end)
    end)

    local name= C_Spell.GetSpellName(818)
    local toyName=C_Item.GetItemNameByID(134020)

    if name and toyName then
        btn:SetAttribute('type*', 'macro')
        btn:SetAttribute('macrotext*',  '/usetoy '..toyName..'\n/cast [@cursor]'..name)
    else

        btn:SetAttribute('type1', 'spell')
        btn:SetAttribute('spell1', 818)
        btn:SetAttribute('unit', 'player')

        btn:SetAttribute('type2', 'item')
        btn:SetAttribute('item2', toyName or 134020)
    end
end





local function Init_Buttons()
    local last
    --GetProfessions() puede devolver nil en medio: lista sin huecos y arqueología al final
    local prof1, prof2, archaeology, fishing, cooking= GetProfessions()
    local tab={}
    for _, index in ipairs({prof1 or false, prof2 or false, fishing or false, cooking or false, archaeology or false}) do
        if index then
            table.insert(tab, index)
        end
    end

    for k , index in ipairs(tab) do
        local name, icon, _, _, _, _, skillLine = GetProfessionInfo(index)
        if icon and skillLine then
            local button= WoWTools_ButtonMixin:Cbtn(Frame, {size=32})
            button:SetNormalTexture(icon)

            if not last then
                button:SetPoint('BOTTOMLEFT', Frame)
            elseif k==3 then
                button:SetPoint('BOTTOMLEFT', last, 'TOPLEFT',0, 17)
            elseif skillLine==794 then
                button:SetPoint('BOTTOMLEFT', last, 'TOPLEFT',0, 37)
            else
                button:SetPoint('BOTTOMLEFT', last, 'TOPLEFT',0,2)
            end
            button:SetScript('OnMouseDown', function(self)
                C_TradeSkillUI.OpenTradeSkill(self.skillLine)
            end)
            button:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine(self.name, 'skillLine '..self.skillLine)
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_ProfessionMixin.addName)
                GameTooltip:Show();
            end)
            button:SetScript('OnLeave',function(self)
                GameTooltip:Hide()
                self:SetButtonState('NORMAL')
            end)
            button.name= name
            button.skillLine= skillLine

            if skillLine==185 and Save().showFuocoButton then
                Init_Fuoco_Button(button)
            end
            last= button
        end
    end
end














local function Init()
    if Frame then
        Frame:SetShown(Save().setButton)
    else
        if Save().setButton then
            do
                Init_Frame()
            end
            Init_Buttons()
        end
    end
end
















local function Init_Menu(self, root)
    if Save().showFuocoButton
        and WoWTools_MenuMixin:CheckInCombat(root)
        or not self:IsMouseOver()
    then
        return
    end

    local sub, sub2

    sub=root:CreateCheckbox(
        WoWTools_L['SHOW_QUICK_BUTTON~3'],
    function()
        return Save().setButton
    end, function()
        Save().setButton= not Save().setButton and true or false
        if Save().showFuocoButton  then
            WoWTools_Print(WoWTools_DataMixin.addName,  WoWTools_ProfessionMixin.addName, WoWTools_L.REQUIRES_RELOAD)
        end
        Init()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Professions.QuickButtons'])


    sub2=sub:CreateCheckbox(
        WoWTools_SpellMixin:GetName(818),
    function()
        return Save().showFuocoButton
    end, function()
        Save().showFuocoButton= not Save().showFuocoButton and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Professions.CookingFire'])
        tooltip:AddLine('|cnWARNING_FONT_COLOR:BUG')
        tooltip:AddLine((WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT )..': '..WoWTools_TextMixin:GetShowHide(false))
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
    end)

    sub:CreateDivider()
    sub2=sub:CreateTitle('BUG')

    WoWTools_MenuMixin:Reload(sub)



    WoWTools_MenuMixin:Scale(self, root, function()
        return Save().scaleButton or 1
    end, function(value)
        Save().scaleButton= value
        if Frame then
            Frame:set_scale()
        end
    end)

    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_ProfessionMixin.addName})
end










function WoWTools_ProfessionMixin:Init_ProfessionsFrame_Button()
    local btn=WoWTools_ButtonMixin:Menu(ProfessionsFrame.CloseButton, {name='WoWToolsProfessionsEnableButton'})
    btn:SetPoint('RIGHT', ProfessionsFrame.MaximizeMinimize.MinimizeButton, 'LEFT', -2, 0)
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(f)
        GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine((WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL)..WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)

    btn:SetupMenu(Init_Menu)
    Init()
end