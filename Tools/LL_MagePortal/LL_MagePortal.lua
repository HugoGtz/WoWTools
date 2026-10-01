
if WoWTools_DataMixin.Player.Class~='MAGE' and true then
    return
end

local Tab={}
if WoWTools_DataMixin.Player.Faction=='Horde' then
    Tab={
        {spell=1259190, spell2=1259194, luce=true},

        {spell=3567, spell2=11417, luce=true},
        {spell=3563, spell2=11418},
        {spell=3566, spell2=11420},
        {spell=32272, spell2=32267, old=true},--mismo nombre que 1259190 (Midnight)
        {spell=49358, spell2=49361},
        {spell=35715, spell2=35717},
        {spell=53140, spell2=53142},
        {spell=88344, spell2=88346},
        {spell=132627, spell2=132626},
        {spell=176242, spell2=176244},
        {spell=224869, spell2=224871},
        {spell=281404, spell2=281402},
        {spell=344587, spell2=344597},
        {spell=395277, spell2=395289},
        {spell=446540, spell2=446534},
        {spell=120145},
        {spell=193759},
    }
elseif WoWTools_DataMixin.Player.Faction=='Alliance' then
    Tab={
        {spell=1259190, spell2=1259194, luce=true},
        {spell=3561, spell2=10059, luce=true},
        {spell=3562, spell2=11416},
        {spell=3565, spell2=11419},
        {spell=32271, spell2=32266},
        {spell=49359, spell2=49360},
        {spell=33690, spell2=33691},
        {spell=53140, spell2=53142},
        {spell=88342, spell2=88345},
        {spell=132621, spell2=132620},
        {spell=176248, spell2=176246},
        {spell=224869, spell2=224871},
        {spell=281403, spell2=281400},
        {spell=344587, spell2=344597},
        {spell=395277, spell2=395289},
        {spell=446540, spell2=446534},
        {spell=120145},
        {spell=193759},
    }
else
    return
end

for _, tab in pairs(Tab) do
   WoWTools_DataMixin:Load(tab.spell, 'spell')
   WoWTools_DataMixin:Load(tab.spell2, 'spell')
end

local P_Save={
    isLeft=true,
    showText=true,
    --disabled
}

local Buttons
local addName
local Module= {}--lo completa WoWTools_Module:Register (al final del archivo)


local function Get_Spell_Label(spellID, text)
    if text then
        text= WoWTools_TextMixin:CN(text, {spellID=spellID, isName=true})
        text=text:gsub('(.+):','')
        text=text:gsub('(.+)-','');
        return text
    end
end


local function Set_Button_Label(btn)
    if not btn then
        return
    end

    if Module:Save().showText then
        if not btn.text then
            btn.text=WoWTools_LabelMixin:Create(btn, {color= not btn.luce})
        end
        btn.text:ClearAllPoints(0)
        if Module:Save().isLeft then
            btn.text:SetPoint('RIGHT', btn, 'LEFT')
        else
            btn.text:SetPoint('LEFT', btn, 'RIGHT')
        end
        btn.text:SetText(btn.name1 or '')
    elseif btn.text then
        btn.text:SetText('')
    end
end

local function Set_Button_All_Label()
    for _, name in pairs(Buttons) do
        Set_Button_Label(WoWTools_ToolsMixin:Get_ButtonForName(name))
    end
end


local function Init_Options(category, layout)
    WoWTools_PanelMixin:Header(layout, addName)
    local initializer=WoWTools_PanelMixin:OnlyCheck({
        category= category,
        name= '|cff3fc6ea'..(WoWTools_L.ENABLE)..'|r',
        tooltip= WoWTools_L['Tip.MagePortal.Enable']..'|n|n'..(addName or ''),
        GetValue= function() return not Module:Save().disabled end,
        SetValue= function()
            Module:Save().disabled= not Module:Save().disabled and true or nil
        end
    })

    WoWTools_PanelMixin:OnlyCheck({
        category= category,
        name= '|cff3fc6ea'..(WoWTools_L['Position: left'])..'|r',
        tooltip= WoWTools_L['Tip.MagePortal.Left']..'|n|n'..(addName or ''),
        GetValue= function() return Module:Save().isLeft end,
        SetValue= function()
            Module:Save().isLeft= not Module:Save().isLeft and true or false
            WoWTools_ToolsMixin:RestAllPoint()
            Set_Button_All_Label()
        end
    }, initializer)

    WoWTools_PanelMixin:OnlyCheck({
        category= category,
        name= '|cff3fc6ea'..(WoWTools_L.PROFESSIONS_FLYOUT_SHOW_NAME)..'|r',
        tooltip= WoWTools_L['Tip.MagePortal.ShowText']..'|n|n'..(addName or ''),
        GetValue= function() return Module:Save().showText end,
        SetValue= function()
            Module:Save().showText= not Module:Save().showText and true or false
            Set_Button_All_Label()
        end
    }, initializer)

end


local function Init_Button(tab)
   WoWTools_DataMixin:Load(tab.spell, 'spell')

    local name= C_Spell.GetSpellName(tab.spell)
    local icon= C_Spell.GetSpellTexture(tab.spell)
    local buttonName= 'MagePortal_Spell_'..tab.spell

    local btn=WoWTools_ToolsMixin:CreateButton({
        name=buttonName,
        tooltip='|T626001:0|t'..('|T'..(icon or 0)..':0|t')..(WoWTools_TextMixin:CN(name, {spellID=tab.spell, isName=true}) or tab.spell),
        isLeftOnlyLine=function()
            return Module:Save().isLeft
        end,
        disabledOptions=true,
    })

    if not btn then
        return
    end

    btn.spellID= tab.spell
    btn.spellID2= tab.spell2
    btn.luce= tab.luce
    btn.old= tab.old

    function btn:set_cool()
        if self:IsVisible() then
            WoWTools_CooldownMixin:SetFrame(self, {spellID=self.spellID2})
        else
            WoWTools_CooldownMixin:SetFrame(self)
        end
    end

    function btn:set_alpha()
        self:SetAlpha((self:IsMouseOver() or C_SpellBook.IsSpellInSpellBook(self.spellID)) and 1 or 0.3)
    end

    function btn:settings()
        local name1= C_Spell.GetSpellName(self.spellID)
        local icon1= C_Spell.GetSpellTexture(self.spellID)
        local done=false
        if name1 and icon1 then
            self:SetAttribute('type', 'spell')
            --mismo nombre en dos hechizos (Lunargenta): por ID para no lanzar el otro
            self:SetAttribute('spell', self.old and self.spellID or name1)
            if icon1 then
                self.texture:SetTexture(icon1)
            end
            if not self.name1 then
                self.name1= Get_Spell_Label(self.spellID, name1)
                if self.old and self.name1 then
                    self.name1= self.name1..' ('..WoWTools_L['Old']..')'
                end
            end
            done=true
        end

        if self.spellID2 then
            local name2= C_Spell.GetSpellName(self.spellID2)
            local icon2= C_Spell.GetSpellTexture(self.spellID2)
            if name2 and icon2 then
                self:SetAttribute('type2', 'spell')
                self:SetAttribute('spell2', self.old and self.spellID2 or name2)
                self.texture2:SetTexture(icon2)
                self.name2= self.name2 or name2
                done= done==true and true or done
            else
                done=false
            end
        end
        Set_Button_Label(self)
        return done
    end


    if tab.luce then
        btn.border:SetAtlas('bag-border')
    end
    btn.luce= tab.luce


    if btn.spellID2 then
        btn.texture2= btn:CreateTexture(nil,'OVERLAY')
        btn.texture2:SetPoint('TOPRIGHT',-6,-6)
        btn.texture2:SetSize(10, 10)
        btn.texture2:AddMaskTexture(btn.IconMask)
        btn:SetScript('OnShow', function(self)
            self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
            self:set_cool()
            self:set_alpha()
        end)
        btn:SetScript('OnHide', function(self)
            self:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
            self:set_cool()
        end)
        btn:set_cool()
        if btn:IsVisible() then
            btn:RegisterEvent('SPELL_UPDATE_COOLDOWN')
        end

    else
        btn:SetScript('OnShow', function(self)
            self:set_alpha()
        end)
    end

    btn:SetScript("OnEvent", function(self, event, arg1, arg2)
        if event=='SPELL_UPDATE_COOLDOWN' then
            WoWTools_CooldownMixin:SetFrame(self, {spellID=self.spellID2})

        elseif event=='SPELL_DATA_LOAD_RESULT' and arg1 and arg2 then
            if (arg1==self.spellID or arg1==self.spellID2) then
                if self:CanChangeAttribute() then
                    if self:settings() then
                        self:UnregisterEvent('SPELL_DATA_LOAD_RESULT')
                    end
                else
                    self:RegisterEvent('PLAYER_REGEN_ENABLED')
                end
            end

        elseif event=='PLAYER_REGEN_ENABLED' then
            if self:settings() then
                self:UnregisterEvent('PLAYER_REGEN_ENABLED')
            end
        end
    end)


    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:set_alpha()
    end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:SetSpellByID(self.spellID)
        if not C_SpellBook.IsSpellInSpellBook(self.spellID) then
            GameTooltip:AddLine(format('|cnWARNING_FONT_COLOR:%s|r', WoWTools_L.TRADE_SKILLS_UNLEARNED_TAB))
        end
        if self.spellID2 then
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(
                '|T'..(C_Spell.GetSpellTexture(self.spellID2) or 0)..':0|t'
                ..(WoWTools_TextMixin:CN(C_Spell.GetSpellLink(self.spellID2), {spellID=self.spellID2, isName=true}) or ('spellID'..self.spellID2))
                ..(WoWTools_CooldownMixin:GetText(self.spellID2, nil) or ''),
                format('%s%s',
                    C_SpellBook.IsSpellInSpellBook(self.spellID2) and '' or format('|cnWARNING_FONT_COLOR:%s|r',WoWTools_L.TRADE_SKILLS_UNLEARNED_TAB),
                    WoWTools_DataMixin.Icon.right)
                )
        end
        GameTooltip:Show()
        self:set_alpha()
        self:set_cool()
    end)

    if not btn:settings() then
        btn:RegisterEvent('SPELL_DATA_LOAD_RESULT')
    end
    C_Timer.After(2, function()
        btn:set_alpha()
    end)
    table.insert(Buttons, buttonName)
end


WoWTools_Module:Register({
    key= 'Tools_MagePortal', name= '%s Portal', icon= 626001, group= 'Tools',
    parent= 'WoWTools_ToolsButton', tooltip= 'Tip.MagePortal.Enable', defaults= P_Save, mixin= Module,
    --siempre: sus opciones en la página de Herramientas
    onLoad= function(M, save)
        M.addName= '|T626001:0|t|cff3fc6ea'..(format(WoWTools_L['%s Portal'], UnitClass('player'))..'|r')

        if save.disabled or not WoWTools_ToolsMixin:Get_MainButton() then
            Tab={}
        end

        WoWTools_ToolsMixin:Set_AddList(Init_Options)
    end,
    onEnable= function(M)
        if WoWTools_ToolsMixin:Get_MainButton() then
            addName= M.addName
            WoWTools_ToolsMixin:OnEnterWorld(function()
                Buttons={}
                for _, tab in pairs(Tab) do
                    Init_Button(tab)
                end
                Tab={}
            end)
        end
    end,
})
