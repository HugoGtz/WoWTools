
if WoWTools_DataMixin.Player.Class~='HUNTER' then
    return
end



--local MAX_SUMMONABLE_HUNTER_PETS = Constants.PetConsts_PostCata.MAX_SUMMONABLE_HUNTER_PETS or 5

local EXTRA_PET_STABLE_SLOT_LUA_INDEX = (Constants.PetConsts_PostCata.EXTRA_PET_STABLE_SLOT or 5) + 1;

--local NUM_PET_SLOTS_HUNTER = Constants.PetConsts_PostCata.NUM_PET_SLOTS_HUNTER or 205

local CALL_PET_SPELL_IDS = {
    0883,
	83242,
	83243,
	83244,
	83245,
}

WoWTools_DataMixin:Load(267116, 'spell')

local backgroundForPetSpec = {
    [STABLE_PET_SPEC_CUNNING] = "hunter-stable-bg-art_cunning",
    [STABLE_PET_SPEC_FEROCITY] = "hunter-stable-bg-art_ferocity",
    [STABLE_PET_SPEC_TENACITY] = "hunter-stable-bg-art_tenacity",
}


local function GetAbilitiesIcons(pet, line)
    if not pet then
        return ''
    end

    local text= WoWTools_HunterMixin:GetAbilitieIconForTab(pet.specAbilities, line, 16)
    if text~='' then
        text= text..(not line and '  ' or '   |n')
    end
    return text..WoWTools_HunterMixin:GetAbilitieIconForTab(pet.petAbilities or pet.abilities, line, 16)
end





local function created_model(btn, setBg)
    btn.model= CreateFrame("PlayerModel", nil, btn)
    local w= btn:GetWidth()

    if btn:GetID()==EXTRA_PET_STABLE_SLOT_LUA_INDEX then
        btn.model:SetFacing(-0.3)
        w=w+80
        btn.model:SetPoint('RIGHT', btn, 'LEFT')
    else
        btn.model:SetFacing(0.3)
        w= w+40
        btn.model:SetPoint('TOP', btn, 'BOTTOM', 0, -14)
    end
    btn.model:SetSize(w, w)

    if setBg then
        btn.model.bg= btn:CreateTexture(nil, 'BACKGROUND')
        btn.model.bg:SetAllPoints(btn.model)

        btn.model.shadow= btn.model:CreateTexture(nil, 'ARTWORK')
        btn.model.shadow:SetAtlas('perks-char-shadow')
        btn.model.shadow:SetPoint('BOTTOMLEFT',btn.model, 0,-3)
        btn.model.shadow:SetSize(w-18, 18)
        btn.model.shadow:SetAlpha(0.4)

        local slotID= btn:GetID()
        btn.callSpellButton= WoWTools_ButtonMixin:Cbtn(btn, {size=18})
        btn.callSpellButton.Texture=btn.callSpellButton:CreateTexture(nil, 'OVERLAY')
        btn.callSpellButton.Texture:SetAllPoints()
        --SetPortraitToTexture(btn.callSpellButton.Texture, 132161)
        btn.callSpellButton.Texture:SetTexture(132161)
        btn.callSpellButton:SetPoint('BOTTOMLEFT', -8, -15)
        btn.callSpellButton.spellID= CALL_PET_SPELL_IDS[slotID]
        btn.callSpellButton:SetScript('OnLeave', GameTooltip_Hide)
        btn.callSpellButton:SetScript('OnEnter', function(self)
            if self.spellID then
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:SetSpellByID(self.spellID, true, true);
                GameTooltip:Show();
            end
        end)

        btn.Portrait2= btn:CreateTexture(nil, 'OVERLAY')
        btn.Portrait2:SetSize(18, 18)
        btn.Portrait2:SetPoint('LEFT', btn.callSpellButton, 'RIGHT')

        btn.abilitiesText= WoWTools_LabelMixin:Create(btn, {SetJustifyH='RIGHT'})
        btn.abilitiesText:SetPoint('BOTTOMRIGHT', btn.callSpellButton, 'BOTTOMLEFT',10,0)

        btn.specTexture= btn:CreateTexture(nil, 'OVERLAY')
        btn.specTexture:SetSize(18, 18)
        btn.specTexture:SetPoint('BOTTOMLEFT', btn.Portrait2, 'BOTTOMRIGHT')

        btn.indexText=WoWTools_LabelMixin:Create(btn, {alpha=0.5})
        btn.indexText:SetPoint('BOTTOMLEFT', btn.specTexture, 'BOTTOMRIGHT')
        btn.indexText:SetText(slotID)

    else
        btn.specTexture= btn:CreateTexture(nil, 'OVERLAY')
        btn.specTexture:SetSize(18, 18)
        btn.specTexture:SetPoint('BOTTOMRIGHT', 2, -2)
    end

    btn.specText= WoWTools_LabelMixin:Create(btn, {color=true})
    btn.specText:SetPoint('TOP', 0, 12)

    function btn:set_pet()
        local pet= self:IsVisible() and self.petData or {}
        local displayID= pet.displayID or 0
        if displayID==0 then
            self.model:ClearModel()
        elseif displayID~=self.displayID then
            self.model:SetDisplayInfo(displayID)
        end
        self.displayID= displayID
        if self.model.bg then
            local atlas
            if displayID>0 then

                atlas = backgroundForPetSpec[pet.specialization]
            end
            if atlas then
                self.model.bg:SetAtlas(atlas)-- or 'footer-bg')
            else
                self.model.bg:SetTexture(0)
            end
            self.model.shadow:SetShown(displayID>0)
            self.abilitiesText:SetText(GetAbilitiesIcons(pet, true))
            self.Portrait2:SetTexture(pet.icon or 0)
        else
            self.Icon:SetTexCoord(0, 1, 0, 1)
        end

        local atlas= WoWTools_DataMixin.Icon[pet.specialization]
        if atlas then
            self.specTexture:SetAtlas(atlas)
        else
            self.specTexture:SetTexture(0)
        end
        self.specText:SetText(WoWTools_TextMixin:CN(pet.specialization) or '')
    end

    WoWTools_DataMixin:Hook(btn, 'SetPet', btn.set_pet)--StableActivePetButtonTemplateMixin

    btn:HookScript('OnHide', btn.set_pet)
    btn:HookScript('OnEnter', function(self)
        if WoWTools_HunterMixin:Save().HideTips then
            return
        end
        if self.petData and not self.locked and self:IsEnabled() then
            WoWTools_HunterMixin:Set_Tooltips(self, self.petData)
            GameTooltip:AddDoubleLine(WoWTools_L.STABLE_PET_BUTTON_LABEL, WoWTools_DataMixin.Icon.right)
            if self:GetID()==EXTRA_PET_STABLE_SLOT_LUA_INDEX then
                GameTooltip:AddDoubleLine(
                    format('|cffaad372%s|r', WoWTools_L.TALENT),
                    format('|T461112:0|t|cffaad372%s|r', C_Spell.GetSpellLink(267116) or C_Spell.GetSpellName(267116) or 'Animal Companion')
                )
            end
            GameTooltip:Show()
        end
    end)

    btn:set_pet()
end












local function Set_SetPet(btn)
    if btn.set_list_button_settings then
        btn:set_list_button_settings()
        return
    end

    btn.Portrait2= btn:CreateTexture(nil, 'OVERLAY')
    btn.Portrait2:SetSize(20, 20)
    btn.Portrait2:SetPoint('RIGHT', btn.Portrait,'LEFT')
    btn.Portrait2:SetAlpha(0.5)
    btn.abilitiesText= WoWTools_LabelMixin:Create(btn)
    btn.abilitiesText:SetPoint('BOTTOMRIGHT', btn.Background, -9, 8)
    btn.indexText= WoWTools_LabelMixin:Create(btn)--, {color={r=1,g=0,b=1}})--SlotID
    btn.indexText:SetPoint('TOPRIGHT', -9,-6)
    btn.indexText:SetAlpha(0.5)

    function btn:set_list_button_settings()
        self.abilitiesText:SetText(GetAbilitiesIcons(self.petData, false))
        local data= self.petData or {}
        self.Portrait2:SetTexture(data.icon or nil)
        self.indexText:SetText(data.slotID or '')
    end
    btn:HookScript('OnEnter', function(self)
        if self.petData then
            WoWTools_HunterMixin:Set_Tooltips(self, self.petData)
            GameTooltip:Show()
        end
    end)
end





local function Init()
    --WoWTools_DataMixin:Hook(StableStabledPetButtonTemplateMixin, 'SetPet', Set_SetPet)

    WoWTools_DataMixin:Hook(StableFrame.StabledPetList.ScrollBox, 'Update', function(self)
        if not self:HasView() then
            return
        end
        for _, btn in pairs(self:GetFrames() or {}) do
            Set_SetPet(btn)
        end
    end)


    for _, btn in ipairs(StableFrame.ActivePetList.PetButtons) do
        created_model(btn, true)
    end
    created_model(StableFrame.ActivePetList.BeastMasterSecondaryPetButton, false)

    WoWTools_DataMixin:Hook(StableFrame.PetModelScene, 'SetPet', function(self)
        local frame= self:GetParent()
        local selecIndex= frame.selectedPet and frame.selectedPet.slotID
        for _, btn2 in ipairs(frame.ActivePetList.PetButtons) do
            btn2.model:SetShown(btn2.petData and not btn2.locked and selecIndex~=btn2:GetID())
        end
        local btn2= frame.ActivePetList.BeastMasterSecondaryPetButton
        btn2.model:SetShown(btn2.petData and btn2:IsEnabled() and selecIndex~=btn2:GetID())
    end)


    local btnSecond= StableFrame.ActivePetList.BeastMasterSecondaryPetButton
    btnSecond.SpellFrame= CreateFrame('Frame', nil, btnSecond, 'StablePetAbilityTemplate')--StablePetAbilityMixin
    btnSecond.SpellFrame:SetPoint('TOPRIGHT', btnSecond, 'BOTTOMRIGHT', 10,-6)
    btnSecond.SpellFrame:Initialize(267116)
    btnSecond.SpellFrame.Icon:ClearAllPoints()
    btnSecond.SpellFrame.Icon:SetPoint('RIGHT')
    btnSecond.SpellFrame.Name:ClearAllPoints()
    btnSecond.SpellFrame.Name:SetPoint('RIGHT', btnSecond.SpellFrame.Icon, 'LEFT')
    WoWTools_DataMixin:Hook(btnSecond, 'Refresh', function(self)
        if _G['WoWTools_StableFrameAllList'] then
            _G['WoWTools_StableFrameAllList'].btn6:settings()
        end
        if self:IsEnabled() then
            self.SpellFrame.Name:SetTextColor(1,1,1)
        else
            self.SpellFrame.Name:SetTextColor(0.5,0.5,0.5)
        end
    end)


    StableFrame.PetModelScene.PetInfo.Food=WoWTools_LabelMixin:Create(StableFrame.PetModelScene.PetInfo, {copyFont=true and StableFrame.PetModelScene.PetInfo.Specialization, color={r=1,g=1,b=1}, size=16})--copyFont=StableFrame.PetModelScene.PetInfo.Specialization, 
    StableFrame.PetModelScene.PetInfo.Food:SetPoint('TOPRIGHT', StableFrame.PetModelScene.PetInfo.Exotic, 'BOTTOMRIGHT')

    StableFrame.PetModelScene.PetInfo.ExoticTexture= StableFrame.PetModelScene.PetInfo:CreateTexture()
    StableFrame.PetModelScene.PetInfo.ExoticTexture:SetSize(18,18)
    StableFrame.PetModelScene.PetInfo.ExoticTexture:SetPoint('RIGHT', StableFrame.PetModelScene.PetInfo.Exotic, 'LEFT')
    StableFrame.PetModelScene.PetInfo.ExoticTexture:SetTexture(461112)
    StableFrame.PetModelScene.PetInfo.ExoticTexture:Hide()

    WoWTools_DataMixin:Hook(StableFrame.PetModelScene.PetInfo, 'SetPet', function(self, petData)
        petData= petData or {}
        self.ExoticTexture:SetShown(petData.isExotic)
        local text
        if petData.slotID then
            local dietString = table.concat(C_StableInfo.GetStablePetFoodTypes(petData.slotID), LIST_DELIMITER)
            text= format(WoWTools_L.PET_DIET_TEMPLATE, dietString)
        end
        self.Food:SetText(text or '')
    end)


    Init=function()end
end









function WoWTools_HunterMixin:Init_StableFrame_Plus()
    Init()
end

