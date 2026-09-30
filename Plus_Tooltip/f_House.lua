function WoWTools_TooltipMixin:Set_HouseItem(tooltip, entryInfo)
    if not entryInfo then
        return
    end

    local portrait

    if entryInfo.iconTexture then
        local size= math.min(entryInfo.size, 90)*5
        tooltip:AddDoubleLine(nil,
            '|T'..entryInfo.iconTexture..':'..size..':'..size..'|t'
        )

    end

    if entryInfo.quality then
        tooltip:AddDoubleLine(
            format(
                NORMAL_FONT_COLOR:WrapTextInColorCode(WoWTools_L.PROFESSIONS_CRAFTING_QUALITY),
                '|cffffffff'..WoWTools_ItemMixin.QualityText[entryInfo.quality or 1]..'|r'
            ),
            entryInfo.iconTexture and '|T'..entryInfo.iconTexture..':23|t|cffffffff'..entryInfo.iconTexture
        )
    end

--室内, 室外

    tooltip:AddDoubleLine(
        (entryInfo.isAllowedIndoors and GREEN_FONT_COLOR:GenerateHexColorMarkup() or NORMAL_FONT_COLOR:GenerateHexColorMarkup())
        ..('|A:house-room-limit-icon:0:0|a'..(WoWTools_L.HOUSING_CATALOG_FILTERS_INDOORS))
        ..': '..WoWTools_TextMixin:GetYesNo(entryInfo.isAllowedIndoors),

        (entryInfo.isAllowedOutdoors and GREEN_FONT_COLOR:GenerateHexColorMarkup() or NORMAL_FONT_COLOR:GenerateHexColorMarkup())
        ..WoWTools_TextMixin:GetYesNo(entryInfo.isAllowedOutdoors)..' :'
        ..(WoWTools_L.HOUSING_CATALOG_FILTERS_OUTDOORS)..'|A:house-outdoor-budget-icon:0:0|a'
    )

--匠心房间
    if entryInfo.isPrefab then
        tooltip:AddLine(
            (entryInfo.isPrefab and GREEN_FONT_COLOR:GenerateHexColorMarkup() or NORMAL_FONT_COLOR:GenerateHexColorMarkup())
            ..(WoWTools_L.HOUSING_LAYOUT_PREFAB_ROOM_TOOLTIP)
            ..': '..WoWTools_TextMixin:GetYesNo(entryInfo.isPrefab)

        )
    end


    tooltip:AddLine(
        (entryInfo.isUniqueTrophy and GREEN_FONT_COLOR:GenerateHexColorMarkup() or NORMAL_FONT_COLOR:GenerateHexColorMarkup())
        ..(WoWTools_L.HOUSING_DECOR_UNIQUE_TROPHY_TOOLTIP)
        ..': '..WoWTools_TextMixin:GetYesNo(entryInfo.isUniqueTrophy)
    )



--来源
    local sourceText
    if entryInfo.sourceText and entryInfo.sourceText~='' then
        sourceText=  WoWTools_TextMixin:CN(entryInfo.sourceText)
    else
        sourceText= WoWTools_HouseMixin:GetObjectiveText(entryInfo)
    end
    if sourceText then
        tooltip:AddLine(' ')
        tooltip:AddLine(sourceText, 1, 0.82, 0, true)
    end

--关键词
    local tag= WoWTools_HouseMixin:GetTagsText(entryInfo)
    if tag then
        tooltip:AddLine(' ')
        tooltip:AddLine(tag, 1, 0.82, 0, true)
    end

    if entryInfo.canCustomize then
        portrait='housing-dyable-palette-icon'
    end

    --textLeft= WoWTools_ItemMixin:GetDecorItemCount(nil, entryInfo, true)

    return portrait
end



