local function status_set_rating(frame, rating)
    local num= rating and GetCombatRating(rating)
    if not canaccessvalue(num) or not num then
        frame.numLabel:SetText('')
    else
        local extraChance = GetCombatRatingBonus(rating) or 0
        local extra=''
        if extraChance>0 then
            extra= format('|cnGREEN_FONT_COLOR:+%i%%|r', extraChance)
        elseif extraChance<0 then
            extra= format('|cnWARNING_FONT_COLOR:%i%%|r', extraChance)
        end
        frame.numLabel:SetFormattedText('%s%s', BreakUpLargeNumbers(num), extra)
    end
end

local function create_status_label(frame, rating)
    local bit= WoWTools_PaperDollMixin:Save().itemLevelBit or -1

    if bit>=0 and frame:IsShown() then
        if not frame.numLabel then
            frame.numLabel=WoWTools_LabelMixin:Create(frame, {color={r=1,g=1,b=1}})
            frame.numLabel:SetPoint('LEFT', frame.Label, 'RIGHT',2,0)
        end
        if rating then
            status_set_rating(frame, rating)
        end
        return true

    elseif frame.numLabel then
        frame.numLabel:SetText("")
    end
end


-- General
local function Init_General()
    WoWTools_DataMixin:Hook('PaperDollFrame_SetHealth', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetPower', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetAlternateMana', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
end


--Base stats
local function Init_Base_Stats(frame, unit, statIndex)
    if create_status_label(frame) then
        local tooltipText
        local _, _, posBuff, negBuff = UnitStat(unit, statIndex)
        if canaccessvalue(posBuff) and (posBuff ~= 0 or negBuff ~= 0) then
            if ( posBuff > 0 ) then
                tooltipText = GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff)..FONT_COLOR_CODE_CLOSE
            end
            if ( negBuff < 0 ) then
                tooltipText = (tooltipText or '')..WARNING_FONT_COLOR_CODE.." -"..BreakUpLargeNumbers(negBuff)..FONT_COLOR_CODE_CLOSE
            end
        end
        frame.numLabel:SetText(tooltipText or '')
    end
end


--Enhancement
local function Init_Enhancements()
    WoWTools_DataMixin:Hook('PaperDollFrame_SetCritChance', function(frame)
        if create_status_label(frame) then
            local rating, spellCrit, rangedCrit, meleeCrit
            local holySchool = 2
            local minCrit = GetSpellCritChance(holySchool)
            if canaccessvalue(minCrit) then
                for i=(holySchool+1), MAX_SPELL_SCHOOLS do
                    spellCrit = GetSpellCritChance(i)
                    minCrit = min(minCrit, spellCrit)
                end
                spellCrit = minCrit
                rangedCrit = GetRangedCritChance()
                meleeCrit = GetCritChance()
                if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
                    rating = CR_CRIT_SPELL
                elseif (rangedCrit >= meleeCrit) then
                    rating = CR_CRIT_RANGED
                else
                    rating = CR_CRIT_MELEE
                end
            end
            status_set_rating(frame, rating)
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetHaste', function(frame)
        create_status_label(frame, CR_HASTE_MELEE)
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetMastery', function(frame)
        create_status_label(frame, CR_MASTERY)
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetVersatility', function(frame)
        if create_status_label(frame) then
            local text
            local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)
            if canaccessvalue(versatility) and versatility and versatility>1 then
                text= BreakUpLargeNumbers(versatility)
                local versatilityDamageTakenReduction= GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)
                if versatilityDamageTakenReduction>1 then
                    text= format('%s/|cffc69b6d%i%%|r', text, versatilityDamageTakenReduction)
                end
            end
            frame.numLabel:SetText(text or '')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetLifesteal', function(frame)
        create_status_label(frame, CR_LIFESTEAL)
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetAvoidance', function(frame)
        create_status_label(frame, CR_AVOIDANCE)
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetSpeed', function(frame)
        create_status_label(frame, CR_SPEED)
    end)
end


local function Init_Attack()
    WoWTools_DataMixin:Hook('PaperDollFrame_SetDamage', function(frame)
        if create_status_label(frame) then
            frame.numLabel:SetText(canaccessvalue(frame.damage) and frame.damage and frame.damage:match('(|c.-|r)') or '')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetAttackPower', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)

    WoWTools_DataMixin:Hook('PaperDollFrame_SetEnergyRegen', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetRuneRegen', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetFocusRegen', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
end


-- Spell
local function Init_Spell()
    WoWTools_DataMixin:Hook('PaperDollFrame_SetSpellPower', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetManaRegen', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
end


local function Init_Defense()
    WoWTools_DataMixin:Hook('PaperDollFrame_SetArmor', function(frame, unit)
        if create_status_label(frame) then
            local effectiveArmor = select(2, UnitArmor(unit))
            local text
            if canaccessvalue(effectiveArmor) and effectiveArmor then
                local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel(unit)) or 0
                if armorReduction>1 then
                    text = format('%i%%', armorReduction)
                    local armorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor)
                    if armorReductionAgainstTarget and armorReduction~=armorReductionAgainstTarget and armorReductionAgainstTarget>1 then
                        text = format('%s/%i%%', text, armorReductionAgainstTarget)
                    end
                end
            end
            frame.numLabel:SetText(text or '')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetDodge', function(frame)
        create_status_label(frame, CR_DODGE)
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetParry', function(frame)
        create_status_label(frame, CR_PARRY)
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetBlock', function(frame, unit)
        if create_status_label(frame) then--, CR_BLOCK)
            local text
            local shieldBlockArmor = GetShieldBlock()
            if canaccessvalue(shieldBlockArmor) and shieldBlockArmor then
                local blockArmorReduction = PaperDollFrame_GetArmorReduction(shieldBlockArmor, UnitEffectiveLevel(unit)) or 0
                if blockArmorReduction>1 then
                    local blockArmorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(shieldBlockArmor)
                    text= format('%i%%', blockArmorReduction)
                    if blockArmorReductionAgainstTarget and blockArmorReduction~= blockArmorReductionAgainstTarget and blockArmorReductionAgainstTarget>1 then
                        text=format('%s/%i%%', text, blockArmorReductionAgainstTarget)
                    end
                end
            end
            frame.numLabel:SetText(text or '')
        end
    end)
    WoWTools_DataMixin:Hook('PaperDollFrame_SetResilience', function(frame)
        create_status_label(frame, COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
    end)

    WoWTools_DataMixin:Hook('PaperDollFrame_SetLabelAndText', function(statFrame, _, text, isPercentage, numericValue)
        local bit= WoWTools_PaperDollMixin:Save().itemLevelBit or -1
        if canaccessvalue(text) and canaccessvalue(numericValue) and bit>=0 and (isPercentage or (type(text)=='string' and text:find('%%'))) then
            statFrame.Value:SetFormattedText('%.0'..bit..'f%%', numericValue)
        end
    end)
end


local function Init()
    if WoWTools_PaperDollMixin:Save().notStatusPlusFunc then
        return
    end

    WoWTools_DataMixin:Hook('PaperDollFrame_SetItemLevel', function(statFrame)
        local bit= WoWTools_PaperDollMixin:Save().itemLevelBit or -1
        if statFrame:IsShown() and bit>=0 then
            local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvP = GetAverageItemLevel()
            if canaccessvalue(avgItemLevelPvP) then
	            local minItemLevel = C_PaperDollInfo.GetMinItemLevel()    
                local displayItemLevel = math.max(minItemLevel or 0, avgItemLevelEquipped)
                local pvp=''
                if ( avgItemLevel ~= avgItemLevelPvP ) then
                    pvp= format('/|cffff7f00%i|r', avgItemLevelPvP)
                end
                if statFrame.numericValue ~= displayItemLevel then
                    statFrame.Value:SetFormattedText('%.0'..bit..'f%s', displayItemLevel, pvp)
                end
            end
        end
    end)
    CharacterStatsPane.ItemLevelFrame.Value:EnableMouse(true)
    function CharacterStatsPane.ItemLevelFrame.Value:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        local bit= WoWTools_PaperDollMixin:Save().itemLevelBit or -1
        GameTooltip_SetTitle(GameTooltip,
            WoWTools_PaperDollMixin.addName..WoWTools_DataMixin.Icon.icon2
        )
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            (WoWTools_L['Decimals ~2'])
            ..(
                bit==-1 and '|cnWARNING_FONT_COLOR:'..(WoWTools_L.DISABLE)..'|r'
                or ('|cnGREEN_FONT_COLOR:'..bit)
            ),

            '-1'..WoWTools_DataMixin.Icon.left
            ..WoWTools_DataMixin.Icon.right..'+1'
        )
        GameTooltip:Show()
    end
    CharacterStatsPane.ItemLevelFrame.Value:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip_Hide()
    end)
    CharacterStatsPane.ItemLevelFrame.Value:SetScript('OnEnter', function(self)
        self:set_tooltips()
        self:SetAlpha(0.7)
    end)
    CharacterStatsPane.ItemLevelFrame.Value:SetScript('OnMouseUp', function(self)
        self:SetAlpha(0.7)
    end)
    CharacterStatsPane.ItemLevelFrame.Value:SetScript('OnMouseDown', function(self, d)
        local n= (WoWTools_PaperDollMixin:Save().itemLevelBit or -1)+ (d=='LeftButton' and -1 or 1)
        n= math.max(-1, n)
        n= math.min(4, n)
        WoWTools_PaperDollMixin:Save().itemLevelBit=n
        WoWTools_PaperDollMixin:UpdateStats()
        self:set_tooltips()
        self:SetAlpha(0.3)
    end)

    


    Init_General()


--Base stats
    WoWTools_DataMixin:Hook('PaperDollFrame_SetStat', Init_Base_Stats)

--Enhancements
    Init_Enhancements()


-- Attack
    Init_Attack()


-- Spell
    Init_Spell()

-- Defense
    Init_Defense()

    Init=function()end
end


function WoWTools_PaperDollMixin:Init_Status_Bit()
    Init()
end