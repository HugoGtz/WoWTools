


function WoWTools_TooltipMixin:Set_Achievement(tooltip, achievementID)
    if self:IsInCombatDisabled(tooltip)
        or not canaccessvalue(achievementID)
        or not achievementID
    then
        return
    end

    local _, name, points, completed, _, _, _, _, flags, icon, rewardText, isGuild = GetAchievementInfo(achievementID)
    if rewardText and rewardText~='' then
        tooltip:AddLine(' ')
        local itemID= C_AchievementInfo.GetRewardItemID(achievementID)
        local itemIcon
        if itemID then
            WoWTools_DataMixin:Load(itemID, 'item')
            itemIcon= select(5, C_Item.GetItemInfoInstant(itemID))
        end
        tooltip:AddLine(
            (itemIcon and '|T'..itemIcon..':0|t' or '')
            ..WoWTools_TextMixin:CN(rewardText),
            0, 0.8, 1, true
        )
    end

    tooltip:AddLine(' ')
--id icon    
    tooltip:AddDoubleLine(
        icon and '|T'..icon..':'..self.iconSize..'|t|cffffffff'..icon or ' ',

        (WoWTools_L.ACHIEVEMENTS)
        ..WoWTools_DataMixin.Icon.icon2
        ..(flags==0x20000 and '|cff00ccff'..WoWTools_DataMixin.Icon.wow2 or '|cffffffff')
        ..achievementID
    )
    local textLeft= (points or 0)..(WoWTools_L.RESAMPLE_QUALITY_POINT)
    local text2Left= completed
                    and '|cnGREEN_FONT_COLOR:'..(WoWTools_L.CRITERIA_COMPLETED)
                    or '|cnWARNING_FONT_COLOR:'..(WoWTools_L.ACHIEVEMENTFRAME_FILTER_INCOMPLETE)
    local textRight= (isGuild or flags==0x4000) and (WoWTools_L.GUILD_ACHIEVEMENTS_TITLE) or nil
    local text2Right= flags==0x20000 and (WoWTools_DataMixin.Icon.net2..'|cff00ccff'..(WoWTools_L.ITEM_UPGRADE_DISCOUNT_TOOLTIP_ACCOUNT_WIDE)) or nil

    if tooltip.IsEmbedded then
        tooltip:AddLine(textLeft)
        tooltip:AddLine(text2Left)
        tooltip:AddLine(textRight)
        tooltip:AddLine(text2Right)
    else
        tooltip.textLeft:SetText(textLeft or '')
        tooltip.text2Left:SetText(text2Left or '')
        tooltip.textRight:SetText(textRight or '')
        tooltip.text2Right:SetText(text2Right or '')
    end

    tooltip.Portrait:settings(icon)

    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='achievement', id=achievementID, name=name, col=nil, isPetUI=false})

    WoWTools_TooltipMixin:Show(tooltip)
end

