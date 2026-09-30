WoWTools_MacroMixin={}

function WoWTools_MacroMixin:GetName(name, icon)
    if name then
        return
            '|T'..(icon or 134400)..':0|t'
            ..(name:gsub('  ', '')==' '
            and (WoWTools_L['(Space)'])
            or name)
    end
end

function WoWTools_MacroMixin:GetSelectIndex()
    if InCombatLockdown() then
        return
    end
    local index= MacroFrame:GetSelectedIndex()
    if index then
        return MacroFrame:GetMacroDataIndex(index)
    end
end

function WoWTools_MacroMixin:IsCanCreateNewMacro()
    return MacroNewButton:IsEnabled() and not InCombatLockdown()
end

function WoWTools_MacroMixin:SetMacroTexture(iconTexture)
    if InCombatLockdown() or not iconTexture or iconTexture==0 then
        return
    end
    local MacroFrame =MacroFrame
    local actualIndex = WoWTools_MacroMixin:GetSelectIndex()
    if actualIndex then
        local name= GetMacroInfo(actualIndex)
        local index = EditMacro(actualIndex, name, iconTexture) - (MacroFrame.macroBase or 0);
        MacroFrame:SelectMacro(index or 1);
        WoWTools_DataMixin:Call(MacroFrame.Update, MacroFrame, true)
    end
end

function WoWTools_MacroMixin:CreateMacroNew(name, icon, body)
    if not self:IsCanCreateNewMacro() or InCombatLockdown() then
        return
    end
    if type(icon)=='string' then
        icon= GetFileIDFromPath(icon) or icon
    end
    local index = CreateMacro(name or ' ', icon or 134400, body or '', MacroFrame.macroBase>0)
    index= index- MacroFrame.macroBase

    MacroFrame:SelectMacro(index)

    WoWTools_DataMixin:Call(MacroFrame.Update, MacroFrame, true)
end

function WoWTools_MacroMixin:SetTooltips(frame, index)
    index= index or (frame.selectionIndex and frame.selectionIndex+ MacroFrame.macroBase)

    if index then
        local name, icon, body = GetMacroInfo(index)
        if name and body then
            GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
            local itemLink= select(2, GetMacroItem(index))
            local spellID= GetMacroSpell(index)

            GameTooltip:ClearLines()
            if itemLink then
                GameTooltip:AddLine(WoWTools_ItemMixin:GetName(nil, itemLink))
                GameTooltip:AddLine(' ')
            elseif spellID then
                GameTooltip:AddLine(WoWTools_SpellMixin:GetName(spellID))
                GameTooltip:AddLine(' ')
            end
            GameTooltip:AddDoubleLine(WoWTools_MacroMixin:GetName(name, icon), (WoWTools_L.TRADESKILL_FILTER_SLOTS)..' '..index)
            GameTooltip:AddLine(body, nil,nil,nil, true)
            GameTooltip:AddLine(' ')
            if frame~=MacroFrameSelectedMacroButton then
                local col= InCombatLockdown() and '|cff828282' or '|cffffffff'
                GameTooltip:AddDoubleLine(
                    col..(WoWTools_L.DELETE),
                    col..'Alt+'..(WoWTools_L.BUFFER_DOUBLE)..WoWTools_DataMixin.Icon.left
                )
            end

            GameTooltip:Show()

            return icon
        end
    end
end

function WoWTools_MacroMixin:SetMenuTooltip(root, descText)
    root:SetTooltip(function(tooltip, description)
        WoWTools_MenuMixin:AddDescription(tooltip, descText)
        local name= description.data.name
        local icon= description.data.icon
        local body= description.data.body
        local spellID= description.data.spellID
        local itemLink= description.data.itemLink
        local index= description.data.index
        if index then
            spellID= GetMacroSpell(index)
            itemLink= select(2, GetMacroItem(index))
            name, icon, body= GetMacroInfo(index)
        end
        if itemLink then
            tooltip:AddLine(WoWTools_ItemMixin:GetName(nil, itemLink))
            tooltip:AddLine(' ')
        elseif spellID then
            tooltip:AddLine(WoWTools_SpellMixin:GetName(spellID))
            tooltip:AddLine(' ')
        end
        tooltip:AddLine(WoWTools_MacroMixin:GetName(name, icon))
        tooltip:AddLine(body, nil, nil, nil, true)
    end)
end




