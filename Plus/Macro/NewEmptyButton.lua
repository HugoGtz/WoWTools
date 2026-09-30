
local function Save()
    return WoWToolsPlusSave['Plus_Macro2']
end


--#############
local MacroButtonList={
    {macro='/reload', name='reload'},--134400
    {macro='/fstack', name='fstack'},
    {macro='/etrace', name='etrace'},
    {macro='#showtooltip\n/cast [mod:alt]\n/cast [mod:ctrl]\n/cast [mod:shift][noflyable]\n/cast [advflyable]\n/cast [swimming]\n/cast [flyable]', name='Mount'},
    {macro='/click ExtraActionButton1', name='Extra'},
    --{macro=, name=, icon=, },
}


local function Save_Macro_Menu(frame, root)
    if WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

    local selectIndex= frame.selectionIndex or MacroFrame:GetSelectedIndex()

    local index= selectIndex and MacroFrame:GetMacroDataIndex(selectIndex)

    local sub, sub2, sub3, name, icon, body, num, header, spellID, itemName, itemLink
    if index then
        name, icon, body = GetMacroInfo(index)
        itemName, itemLink= GetMacroItem(index)
        spellID= GetMacroSpell(index)
        local spellName= spellID and C_Spell.GetSpellName(spellID)

        WoWTools_DataMixin:Load(itemLink, 'item')
        WoWTools_DataMixin:Load(spellID, 'spell')

        header= '|T'..(icon or 134400)..':0|t'.. (name and name:gsub(' ', '') or '')..(spellName or spellID or '')..(itemName or itemLink or '')
        sub=root:CreateCheckbox(
            '|A:PetJournal-FavoritesIcon:0:0|a'
            ..((not body or body=='') and '|cff626262' or '')
            ..(WoWTools_L.FAVORITES)
            ..' '..header,
        function(data)
            return data.header and Save().macro[data.header]
        end, function(data)
            if data.body and data.body~='' then
                Save().macro[data.header]=  not Save().macro[data.header] and {
                        name=data.name,
                        icon=data.icon,
                        body=data.body,
                    }
                    or nil
            end
        end, {name=name, icon=icon, body=body, header=header, itemLink=itemLink, spellID=spellID})

        WoWTools_MacroMixin:SetMenuTooltip(sub, WoWTools_L['Tip.Macro.Favorite'])
    else
        root:CreateTitle(
            '|A:PetJournal-FavoritesIcon:0:0|a'
            ..DISABLED_FONT_COLOR:WrapTextInColorCode(
                WoWTools_L.FAVORITES
            ))
    end


    num=0
    for head2, tab in pairs(Save().macro) do
        sub2=sub:CreateButton(
            head2,
        function(data)
            WoWTools_MacroMixin:CreateMacroNew(data.tab.name, data.tab.icon, data.tab.body)
            return MenuResponse.Open
        end, {saveName=head2, tab=tab})
        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddLine(description.data.saveName)
            if description.data.tab.body then
                tooltip:AddLine(description.data.tab.body)
                tooltip:AddLine(' ')
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..'|A:communities-chat-icon-plus:0:0|a'..(WoWTools_L.NEW)..WoWTools_DataMixin.Icon.left)
            else
                tooltip:AddLine((WoWTools_L.NONE))
            end
        end)
        sub3=sub2:CreateCheckbox(
            '|A:XMarksTheSpot:0:0|a'
            ..(WoWTools_L.REMOVE),
        function(data)
            return Save().macro[data.head2]
        end, function(data)
            Save().macro[data.head2]= not Save().macro[data.head2] and {name=data.name, icon=data.icon, body=data.body} or nil

            if Save().macro[data.head2] then
                WoWTools_Print(
                    WoWTools_MacroMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    GREEN_FONT_COLOR:WrapTextInColorCode(WoWTools_L.FAVORITES)
                )
            else
                WoWTools_Print(
                    WoWTools_MacroMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    '|cnWARNING_FONT_COLOR:',
                    WoWTools_L.REMOVE
                )
                WoWTools_Print(
                    data.body
                )
            end
        end, {head2=head2, name=tab.name, icon=tab.icon, body=tab.body})
        WoWTools_MacroMixin:SetMenuTooltip(sub3, WoWTools_L['Tip.Macro.FavoriteRemove'])
        num=num+1
    end

    if num>1 then
        sub:CreateDivider()
        WoWTools_MenuMixin:ClearAll(sub, function()
            Save().macro={}
        end)

        WoWTools_MenuMixin:SetScrollMode(sub)
    end
end


local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local notMax= MacroNewButton:IsEnabled()
    if WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

    local sub

    for _, tab in pairs(MacroButtonList) do
        sub=root:CreateButton(
            '|T'..(tab.icon or 0)..':0|t'..tab.name,
        function(data)
            WoWTools_MacroMixin:CreateMacroNew(data.name, data.icon, data.macro)
            return MenuResponse.Open
        end, {name=tab.name, icon=tab.icon, macro=tab.macro})
        sub:SetTooltip(function(tooltip, description)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Macro.Preset'])
            tooltip:AddLine(WoWTools_MacroMixin:GetName(description.data.name, description.data.icon))
            tooltip:AddLine(' ')
            tooltip:AddLine(description.data.macro, nil, nil, nil, true)
        end)
        sub:SetEnabled(notMax)
    end

    root:CreateDivider()
    Save_Macro_Menu(self, root)
end


--#############
local function Init()
    if Save().hideBottomList then
        return
    end

    local btn= CreateFrame('Button', 'WoWToolsMacroNewEmptyButton', MacroFrame, 'WoWToolsButtonTemplate')
    btn:SetNormalAtlas('communities-chat-icon-plus')
    btn:SetPoint('BOTTOMLEFT', _G['MacroFrameTab3'] or MacroFrameTab2, 'BOTTOMRIGHT', 2 ,0)
    function btn:tooltip(tooltip)
        tooltip:AddLine(
            (WoWTools_MacroMixin:IsCanCreateNewMacro() and '' or '|cff626262')
            ..'|A:communities-chat-icon-plus:0:0|a'
            ..(WoWTools_L.NEW)
        )
    end
    btn:SetScript('OnClick', function()
        WoWTools_MacroMixin:CreateMacroNew()
    end)

    local menu= CreateFrame('DropdownButton', 'WoWToolsMacroEmptyMenuButton', btn, 'WoWToolsMenuTemplate')
    menu:SetPoint('LEFT', btn, 'RIGHT')
    menu:SetNormalAtlas('PetJournal-FavoritesIcon')
    menu:GetNormalTexture():SetVertexColor(1,1,1,1)
    menu:SetupMenu(Init_Menu)
    menu.tooltip= '|A:PetJournal-FavoritesIcon:0:0|a'
            ..(WoWTools_L.FAVORITES)

    WoWTools_DataMixin:Hook(MacroFrame, 'UpdateButtons', function()
        local enabled= WoWTools_MacroMixin:IsCanCreateNewMacro()
        _G['WoWToolsMacroNewEmptyButton']:SetEnabled(enabled)
        _G['WoWToolsMacroEmptyMenuButton']:SetEnabled(enabled)
    end)

    Init=function()
        local show= not Save().hideBottomList
         _G['WoWToolsMacroNewEmptyButton']:SetShown(show)
        _G['WoWToolsMacroEmptyMenuButton']:SetShown(show)
    end
end


function WoWTools_MacroMixin:Init_AddNew_Button()
    Init()
end


function WoWTools_MacroMixin:Save_Macro_Menu(frame, root)
    Save_Macro_Menu(frame, root)
end