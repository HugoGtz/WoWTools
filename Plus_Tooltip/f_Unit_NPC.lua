local function Set_BrannBronzebeard(tooltip, unit, size)
    if not UnitInPartyIsAI(unit)
        or not WoWTools_MapMixin:IsInDelve()
    then
        return
    end

    local role= UnitGroupRolesAssigned(unit)
    local left= role~='NONE' and WoWTools_DataMixin.Icon[role] or nil
    local right

    local companionFactionID = C_DelvesUI.GetFactionForCompanion()
    if not companionFactionID then
        return
    end

    local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(companionFactionID)
    if rankInfo and rankInfo.currentLevel and rankInfo.maxLevel then
        if rankInfo.currentLevel == rankInfo.maxLevel then
            left= (left or '')..format(WoWTools_L.UNIT_LEVEL_TEMPLATE, rankInfo.currentLevel)
        else
            left= (left or '')..'|cnGREEN_FONT_COLOR:'..format(WoWTools_L.TOOLTIP_TALENT_RANK, rankInfo.currentLevel, rankInfo.maxLevel)..'|r'

            local repInfo = C_GossipInfo.GetFriendshipReputation(companionFactionID)
            if repInfo and repInfo.nextThreshold and repInfo.standing and repInfo.nextThreshold>0 then
                left= (left or '')..format('|A:GarrMission_CurrencyIcon-Xp:0:0|a|cnGREEN_FONT_COLOR:%i%%|r', repInfo.standing/repInfo.nextThreshold*100)
                if repInfo.texture and repInfo.texture>0 then
                    right= '|T'..repInfo.texture..':'..size..'|t'..repInfo.texture
                end
            end
        end
    end


    tooltip:AddLine(
        (WoWTools_L.REPUTATION)
        ..WoWTools_DataMixin.Icon.icon2..companionFactionID..(right or '')
    )

    return left
end


function WoWTools_TooltipMixin:Set_Unit_NPC(tooltip, name, unit, guid)
    if self:IsInCombatDisabled(tooltip)
        --or not WoWTools_UnitMixin:UnitExists(unit)
        or not canaccessvalue(unit)
        or not canaccessvalue(name)
        or not canaccessvalue(guid)
    then
        return
    end

    local textLeft, text2Left, textRight, text2Right=' ', '', '', ''
    local tooltipName=tooltip:GetName() or 'GameTooltip'

    if UnitIsQuestBoss(unit) then
        tooltip.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest')
        --tooltip.Portrait:SetShown(true)

    elseif UnitIsBossMob(unit) then
        text2Left= WoWTools_L.BOSS
        tooltip.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
        --tooltip.Portrait:SetShown(true)
    else
        local classification = UnitClassification(unit)--TargetFrame.lua
        if classification == "rareelite" then
            text2Left= WoWTools_L.GARRISON_MISSION_RARE
            tooltip.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
            --tooltip.Portrait:SetShown(true)

        elseif classification == "rare" then
            text2Left= WoWTools_L.GARRISON_MISSION_RARE
            tooltip.Portrait:SetAtlas('UnitFrame-Target-PortraitOn-Boss-Rare-Star')
            --tooltip.Portrait:SetShown(true)
        else
            SetPortraitTexture(tooltip.Portrait, unit, true)
            --tooltip.Portrait:SetShown(true)
        end
    end

    local creatureName=UnitCreatureType(unit)
    if creatureName and not creatureName:find(COMBAT_ALLY_START_MISSION) then
        _G[tooltipName.."TextRight1"]:SetText(WoWTools_TextMixin:CN(creatureName))
        _G[tooltipName.."TextRight1"]:SetShown(true)
    end

    local uiWidgetSet= UnitWidgetSet(unit)
    if uiWidgetSet and uiWidgetSet>0 then
        tooltip:AddLine(WoWTools_DataMixin.Icon.icon2..'uiWidgetSetID '..uiWidgetSet)
    end

    local zone, npc
    if guid then
        npc, zone= WoWTools_UnitMixin:GetNpcID(unit, guid)
        textLeft= Set_BrannBronzebeard(tooltip, unit, self.iconSize) or textLeft
        if zone then
            tooltip:AddLine(WoWTools_DataMixin.Language.layer..zone)
            WoWTools_DataMixin.Player.Layer=zone
        end
        if npc then
            tooltip:AddLine(
                (WoWTools_L.GROUPMANAGER_UNIT_MARKER)
                ..WoWTools_DataMixin.Icon.icon2
                ..npc
            )
            self:Set_Web_Link(tooltip, {type='npc', id=npc, name=name, isPetUI=false})
        end
    end


    tooltip:Set_TopLabel(textLeft, text2Left, textRight, text2Right)

    if not WoWToolsPlusSave['Plus_Tootips'].disabledNPCcolor then
        local color= WoWTools_UnitMixin:GetColor(unit, guid)
        local r,g,b= color:GetRGB()

        local lineLeft, lineRight

        for i=1, tooltip:NumLines() do
            lineLeft= _G[tooltipName.."TextLeft"..i]
            if lineLeft then
                lineLeft:SetTextColor(r, g, b)
            end
            lineRight= _G[tooltipName.."TextRight"..i]
            if lineRight and lineRight:IsShown() then
                lineRight:SetTextColor(r, g, b)
            end
        end
        tooltip.textLeft:SetTextColor(r, g, b)
        tooltip.text2Left:SetTextColor(r, g, b)
        tooltip.textRight:SetTextColor(r, g, b)
        tooltip.text2Right:SetTextColor(r, g, b)

        if tooltip.StatusBar then
            tooltip.StatusBar:SetStatusBarColor(r,g,b)
        end
    end

    self:Set_Item_Model(tooltip, {unit=unit, guid=guid})

    WoWTools_TooltipMixin:Show(tooltip)
end


