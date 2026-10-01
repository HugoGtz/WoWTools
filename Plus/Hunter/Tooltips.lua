
if WoWTools_DataMixin.Player.Class~='HUNTER' then
    return
end










local function SetTooltip(frame, pet)
    if WoWTools_HunterMixin:Save().HideTips then
        return
    end

    GameTooltip:SetOwner(frame, "ANCHOR_LEFT", -12, 0)
    GameTooltip:ClearLines()

    local i=1
    for indexType, name in pairs(pet) do

        local col= (select(2, math.modf(i/2))==0 and '|cffffffff') or '|cff00ccff'

        if type(name)=='table' then
            if indexType=='petAbilities' or indexType=='specAbilities' then
                GameTooltip:AddDoubleLine(
                    col
                    ..(indexType=='petAbilities'
                        and (WoWTools_L['BASE_SETTINGS_TAB+ABILITIES'])
                        or (WoWTools_L['SPECIALIZATION+ABILITIES'])
                    ),
                    WoWTools_HunterMixin:GetAbilitieIconForTab(name, false, 18)
                )
            end

        elseif indexType=='specialization' then
            local atlas = WoWTools_DataMixin.Icon[name]
            GameTooltip:AddDoubleLine(col..(WoWTools_L.SPECIALIZATION), (atlas and '|A:'..atlas..':18:18|a' or '')..col..WoWTools_TextMixin:CN(name))

        elseif indexType=='level' then
            GameTooltip:AddDoubleLine(col..(WoWTools_L.LEVEL), col..name)

        elseif indexType=='name' then
            GameTooltip:AddDoubleLine(col..(WoWTools_L['NAME~2']), col..WoWTools_TextMixin:CN(name))

        elseif indexType=='icon' then
            GameTooltip:AddDoubleLine(col..(WoWTools_L.EMBLEM_SYMBOL), col..format('|T%d:18|t%d', name, name))

        elseif indexType=='familyName' then
            GameTooltip:AddDoubleLine(col..(WoWTools_L.STABLE_SORT_TYPE_LABEL), col..WoWTools_TextMixin:CN(name))

        elseif indexType=='type' then
            GameTooltip:AddDoubleLine(col..(WoWTools_L.TYPE), col..WoWTools_TextMixin:CN(name))

        elseif indexType=='isFavorite' then
            GameTooltip:AddDoubleLine(col..(WoWTools_L.FAVORITES), col..WoWTools_TextMixin:GetYesNo(name, true))

        elseif indexType=='isExotic' then
            GameTooltip:AddDoubleLine(col..(WoWTools_L.STABLE_EXOTIC_TYPE_LABEL), col..WoWTools_TextMixin:GetYesNo(name, true))
        else

            name= (name==false or name==true) and col..WoWTools_TextMixin:GetYesNo(name, true)
                or name
            GameTooltip:AddDoubleLine(col..indexType, col..name)
        end
        i=i+1
    end
    GameTooltip:AddDoubleLine(
        WoWTools_L['PET_DIET_TEMPLATE~2'],
        table.concat(C_StableInfo.GetStablePetFoodTypes(pet.slotID), LIST_DELIMITER)
    )
    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(WoWTools_L.DRAG_MODEL, WoWTools_DataMixin.Icon.left)

    if GameTooltip.playerModel and pet.displayID and pet.displayID>0 then
        GameTooltip.playerModel:SetDisplayInfo(pet.displayID)
        GameTooltip.playerModel:SetShown(true)
    end
end



function WoWTools_HunterMixin:Set_Tooltips(frame, petInfo)
    SetTooltip(frame, petInfo)
end