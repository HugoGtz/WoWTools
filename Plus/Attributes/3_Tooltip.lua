local Show_Tooltip={}









--set_STATUS_Tooltip
Show_Tooltip.STATUS= function(frame)
    local currentSpec= GetSpecialization() or 0
    local PrimaryStat= select(6, C_SpecializationInfo.GetSpecializationInfo(currentSpec, nil, nil, nil, WoWTools_DataMixin.Player.Sex))

    local stat, effectiveStat, posBuff, negBuff = UnitStat('player', PrimaryStat)
    local effectiveStatDisplay = BreakUpLargeNumbers(effectiveStat or 0)
    local tooltipText = effectiveStatDisplay

    if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
        GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', tooltipText, frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
	else
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..BreakUpLargeNumbers(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff or 0)..FONT_COLOR_CODE_CLOSE
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..WARNING_FONT_COLOR_CODE.." "..BreakUpLargeNumbers(negBuff or 0)..FONT_COLOR_CODE_CLOSE
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE
		end

        GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', tooltipText, frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
	end

    local role = GetSpecializationRole(currentSpec)
    if PrimaryStat==LE_UNIT_STAT_STRENGTH then-- Strength
        local text= ''
        local attackPower = GetAttackPowerForStat(PrimaryStat, effectiveStat or 0)
        if (HasAPEffectsSpellPower()) then
            text= (WoWTools_L.STAT_TOOLTIP_BONUS_AP_SP)..' '..BreakUpLargeNumbers(attackPower)
        end
        if role == "TANK" then
            local increasedParryChance = GetParryChanceFromAttribute()
            if ( increasedParryChance > 0 ) then
                text = text~='' and text..'|n' or text
                text= text..format(WoWTools_L.CR_PARRY_BASE_STAT_TOOLTIP, increasedParryChance)
            end
        end
        GameTooltip:AddLine(text, frame.r, frame.g, frame.b,true)

    elseif PrimaryStat==LE_UNIT_STAT_AGILITY then-- Agility
        local text=''
        if HasAPEffectsSpellPower() then
            text= WoWTools_L.STAT_TOOLTIP_BONUS_AP_SP
        else
            text= WoWTools_L.STAT_TOOLTIP_BONUS_AP
        end

        if role == "TANK" then
            local increasedDodgeChance = GetDodgeChanceFromAttribute()
            if increasedDodgeChance > 0 then
                text= text .."|n"..format(WoWTools_L.CR_DODGE_BASE_STAT_TOOLTIP, increasedDodgeChance)
            end
        end
        GameTooltip:AddLine(text, nil, nil, nil,true)

    elseif PrimaryStat==LE_UNIT_STAT_INTELLECT then
        local text
        if HasAPEffectsSpellPower() then
            text= WoWTools_L.STAT_NO_BENEFIT_TOOLTIP
        elseif HasSPEffectsAttackPower() then
            text= WoWTools_L.STAT_TOOLTIP_BONUS_AP_SP
        else
            text= (WoWTools_L.DEFAULT_STAT4_TOOLTIP).. effectiveStat
        end
        GameTooltip:AddLine(text, nil, nil, nil,true)
    end
    --frame.value es el valor efectivo de referencia: comparar con el efectivo actual
    local current= effectiveStat or stat
    if frame.value and current and frame.value~=current then
        GameTooltip:AddLine(' ')
        local text
        if frame.value< current then
            text= WoWTools_AttributesMixin:Save().greenColor..'+ '..format('%s', WoWTools_DataMixin:MK(current- frame.value,3))
        else
            text= WoWTools_AttributesMixin:Save().redColor..'- '..format('%s', WoWTools_DataMixin:MK(frame.value- current, 3))
        end
        GameTooltip:AddDoubleLine(format('%i', frame.value), text)
    end
end






--set_CRITCHANCE_Tooltip
Show_Tooltip.CRITCHANCE= function(frame)
    local spellCrit = WoWTools_AttributesMixin:Get_MinCrit()
	local rangedCrit = GetRangedCritChance()
	local meleeCrit = GetCritChance()
    local critChance, rating
	if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
		critChance = spellCrit
		rating = CR_CRIT_SPELL
	elseif (rangedCrit >= meleeCrit) then
		critChance = rangedCrit
		rating = CR_CRIT_RANGED
	else
		critChance = meleeCrit
		rating = CR_CRIT_MELEE
	end
    GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', format('%.2f%%', critChance), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)

	local extraCritChance = GetCombatRatingBonus(rating)
	local extraCritRating = GetCombatRating(rating)
	if GetCritChanceProvidesParryEffect() then
        GameTooltip:AddLine(
            format(
                WoWTools_L.CR_CRIT_PARRY_RATING_TOOLTIP,
                BreakUpLargeNumbers(extraCritRating),
                extraCritChance,
                GetCombatRatingBonusForCombatRatingValue(CR_PARRY, extraCritRating)
            ), nil, nil, nil ,true
        )
	else
        GameTooltip:AddLine(
            format(
                WoWTools_L.CR_CRIT_TOOLTIP,
                BreakUpLargeNumbers(extraCritRating),
                extraCritChance
            ), nil, nil, nil,true
        )
	end
    
end












--set_HASTE_Tooltip
Show_Tooltip.HASTE= function(frame)
    local haste = GetHaste()
	local rating = CR_HASTE_MELEE

	local hasteFormatString
	if (haste < 0 and not GetPVPGearStatRules()) then
		hasteFormatString = WARNING_FONT_COLOR_CODE.."%s"..FONT_COLOR_CODE_CLOSE
	else
		hasteFormatString = "%s"
	end
	GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', format(hasteFormatString, format("%0.2f%%", haste)), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
	GameTooltip:AddLine(
        WoWTools_TextMixin:CN(_G["STAT_HASTE_"..WoWTools_DataMixin.Player.Class.."_TOOLTIP"])
        or (WoWTools_L.STAT_HASTE_TOOLTIP),
        nil, nil, nil, true
    )
    GameTooltip:AddLine(' ')
	GameTooltip:AddDoubleLine(
        format(
            WoWTools_L.STAT_HASTE_BASE_TOOLTIP,
            BreakUpLargeNumbers(GetCombatRating(rating)),
            GetCombatRatingBonus(rating))
        )
end





--set_VERSATILITY_Tooltip
Show_Tooltip.VERSATILITY= function(frame)
    local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)
	local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
	local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)
    GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', format('%.2f%%',  versatilityDamageBonus), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
    GameTooltip:AddLine(' ')
	GameTooltip:AddLine(
        format(
            CR_VERSATILITY_TOOLTIP,
            versatilityDamageBonus,
            versatilityDamageTakenReduction,
            BreakUpLargeNumbers(versatility),
            versatilityDamageBonus,
            versatilityDamageTakenReduction
        ),
        nil, nil, nil, true
    )
end







--set_LIFESTEAL_Tooltip
Show_Tooltip.LIFESTEAL= function(frame)
    local lifesteal = GetLifesteal()
	GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', format("%0.2f%%", lifesteal), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
    GameTooltip:AddLine(
        format(
            WoWTools_L.CR_LIFESTEAL_TOOLTIP,
            BreakUpLargeNumbers(GetCombatRating(CR_LIFESTEAL)),
            GetCombatRatingBonus(CR_LIFESTEAL)),
            nil, nil, nil, true
        )
end






--set_ARMOR_Tooltip
Show_Tooltip.ARMOR= function(frame)
    local _, effectiveArmor = UnitArmor('player')
    GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', BreakUpLargeNumbers(effectiveArmor), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)

    local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel('player'))
	local armorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor)

    GameTooltip:AddLine(
        format(
            WoWTools_L.STAT_ARMOR_TOOLTIP,
            armorReduction
        ), nil, nil, nil, true
    )

	if (armorReductionAgainstTarget) then
		GameTooltip:AddLine(
            format(
                WoWTools_L.STAT_ARMOR_TARGET_TOOLTIP, armorReductionAgainstTarget
            ),
            nil, nil, nil, true
        )
	end
end






--set_AVOIDANCE_Tooltip
Show_Tooltip.AVOIDANCE= function(frame)
    local Avoidance = GetAvoidance()
	GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ',  format("%0.2f%%", Avoidance), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
    GameTooltip:AddLine(
        format(
            WoWTools_L.CR_AVOIDANCE_TOOLTIP,
            BreakUpLargeNumbers(GetCombatRating(CR_AVOIDANCE)),
            GetCombatRatingBonus(CR_AVOIDANCE)
        ),
        nil, nil, nil, true
    )
end








--set_DODGE_Tooltip
Show_Tooltip.DODGE= function(frame)
    local chance = GetDodgeChance()
	GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ',  format("%0.2f%%", chance), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
    GameTooltip:AddLine(
        format(
            WoWTools_L.CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE)
        ),
        nil, nil, nil, true
    )
end










--set_PARRY_Tooltip
Show_Tooltip.PARRY= function(frame)
    local chance = GetParryChance()
	GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ',  format("%0.2f%%", chance), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
    GameTooltip:AddLine(
        format(
            WoWTools_L.CR_PARRY_TOOLTIP,
            GetCombatRating(CR_PARRY),
            GetCombatRatingBonus(CR_PARRY)
        ),
        nil, nil, nil, true
    )
end










--set_BLOCK_Tooltip
Show_Tooltip.BLOCK= function(frame)
    local chance = GetBlockChance()
    GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', format("%0.2f%%", chance), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)

	local shieldBlockArmor = GetShieldBlock()
	local blockArmorReduction = PaperDollFrame_GetArmorReduction(shieldBlockArmor, UnitEffectiveLevel('player'))
	local blockArmorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(shieldBlockArmor)

	GameTooltip:AddLine(format(WoWTools_L.CR_BLOCK_TOOLTIP, blockArmorReduction), frame.r, frame.g, frame.b,true)
	if (blockArmorReductionAgainstTarget) then
		GameTooltip:AddLine(
            format(
                WoWTools_L.STAT_BLOCK_TARGET_TOOLTIP,
                blockArmorReductionAgainstTarget
            ),
            nil, nil, nil,true
        )
	end
end











--set_STAGGER_Tooltip
Show_Tooltip.STAGGER= function(frame)
    local stagger, staggerAgainstTarget = C_PaperDollInfo.GetStaggerPercentage('player')
    if not stagger then
        return
    end
    GameTooltip:ClearLines()
    GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', format("%0.2f%%", stagger), frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
	GameTooltip:AddLine(format(WoWTools_L.STAT_STAGGER_TOOLTIP, stagger), frame.r, frame.g, frame.b,true)
	if (staggerAgainstTarget) then
		GameTooltip:AddLine(
            format(
                WoWTools_L.STAT_STAGGER_TARGET_TOOLTIP, staggerAgainstTarget
            ),
            nil, nil, nil, true
        )
	end
end








--set_SPEED_Tooltip
Show_Tooltip.SPEED= function(frame)
    local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed('player')
    GameTooltip:AddDoubleLine(frame.nameText or frame.name or ' ', 'player', frame.r, frame.g, frame.b, frame.r, frame.g, frame.b)
    GameTooltip:AddLine(
        format(
            WoWTools_L.CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED)),
            GetCombatRatingBonus(CR_SPEED)
        ),
        nil, nil, nil, true
    )
    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(
    (WoWTools_L.MOUNT_JOURNAL_FILTER_GROUND)..format(' %.0f%%', runSpeed*100/BASE_MOVEMENT_SPEED), format('%.2f', runSpeed))
    GameTooltip:AddDoubleLine((WoWTools_L.MOUNT_JOURNAL_FILTER_AQUATIC )..format(' %.0f%%', swimSpeed*100/BASE_MOVEMENT_SPEED), format('%.2f', swimSpeed))
    GameTooltip:AddDoubleLine((WoWTools_L.MOUNT_JOURNAL_FILTER_FLYING )..format(' %.0f%%', flightSpeed*100/BASE_MOVEMENT_SPEED), format('%.2f', flightSpeed))
    GameTooltip:AddDoubleLine((WoWTools_L.LANDING_DRAGONRIDING_PANEL_TITLE)..format(' %.0f%%', 100*100/BASE_MOVEMENT_SPEED), '100')
    if WoWTools_UnitMixin:UnitExists('vehicle') then
        currentSpeed = GetUnitSpeed('vehicle')
        GameTooltip:AddDoubleLine((WoWTools_L['Vehicle'])..format(' %.0f%%', currentSpeed*100/BASE_MOVEMENT_SPEED), format('%.2f', currentSpeed))
    end
end














function WoWTools_AttributesMixin:Set_Tooltips(frame, owner)
    if not InCombatLockdown() and Show_Tooltip[frame.name] then
        GameTooltip:SetOwner(owner or frame, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        Show_Tooltip[frame.name](frame)
        GameTooltip:Show()
    end
end