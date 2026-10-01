local function Save()
    return WoWToolsPlusPlayerDate['Tools_UseItems']
end












local function Create_Button(btn)
    btn.useSpell= WoWTools_ButtonMixin:Cbtn(btn, {
        size=16,
        atlas='soulbinds_tree_conduit_icon_utility'
    })
    btn.useSpell:SetPoint('TOP', btn, 'BOTTOM', 8,0)

    function btn.useSpell:set_alpha()
        if self.spellID then
            self:SetAlpha(WoWTools_UseItemsMixin:Find_Type('spell', self.spellID) and 1 or 0.2)
        end
    end
    function btn.useSpell:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_ToolsMixin.addName, WoWTools_UseItemsMixin.addName)
        GameTooltip_AddErrorLine(GameTooltip, WoWTools_L.REQUIRES_RELOAD)
        GameTooltip:AddLine(' ')
        if self.spellID then
            GameTooltip:AddDoubleLine(
                '|T'..(C_Spell.GetSpellTexture(self.spellID) or 0)..':0|t'
                ..(C_Spell.GetSpellLink(self.spellID) or self.spellID)
                ..' '..WoWTools_TextMixin:GetEnabeleDisable(WoWTools_UseItemsMixin:Find_Type('spell', self.spellID)),

                WoWTools_DataMixin.Icon.left
            )
        end
        GameTooltip:AddDoubleLine(WoWTools_L.SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
    end

    btn.useSpell:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:set_alpha()
    end)

    btn.useSpell:SetScript('OnEnter', function(self)
        self:SetAlpha(1)
        self:set_tooltips()
    end)

    btn.useSpell:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            if self.spellID then
                local findIndex= WoWTools_UseItemsMixin:Find_Type('spell', self.spellID)
                if findIndex then
                    table.remove(Save().spell, findIndex)
                else
                    table.insert(Save().spell, self.spellID)
                end
                self:set_tooltips()
                self:set_alpha()
            end
        else
            MenuUtil.CreateContextMenu(self, WoWTools_UseItemsMixin.Init_Menu)
        end
    end)
end






local Init= WoWTools_Once(function()
    WoWTools_DataMixin:Hook(SpellBookItemMixin, 'UpdateVisuals', function(frame)
         if not frame.Button.useSpell then
            Create_Button(frame.Button)
        end
        local spellID= frame.spellBookItemInfo.spellID
        frame.Button.useSpell.spellID= frame.spellBookItemInfo.spellID
        frame.Button.useSpell:set_alpha()
        frame.Button.useSpell:SetShown(spellID and not C_Spell.IsSpellPassive(spellID))
    end)
end)





function WoWTools_UseItemsMixin:Init_PlayerSpells()
    EventUtil.ContinueOnAddOnLoaded('Blizzard_PlayerSpells', function()
        Init()
    end)
end