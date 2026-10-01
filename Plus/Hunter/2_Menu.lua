
if WoWTools_DataMixin.Player.Class~='HUNTER' then
    return
end


local function Init_Menu(_, root)
    local sub
        sub=root:CreateCheckbox(
            '|A:dressingroom-button-appearancelist-up:0:0|a'..(WoWTools_L.BATTLE_PETS_TOTAL_PETS),
        function()
            return WoWTools_HunterMixin:Save().show_All_List
        end, function()
            WoWTools_HunterMixin:Save().show_All_List= not WoWTools_HunterMixin:Save().show_All_List and true or nil
            WoWTools_HunterMixin:Set_StableFrame_List()
            return MenuResponse.Close
        end)
        WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Hunter.AllList'])

        root:CreateDivider()

        if WoWTools_HunterMixin:Save().show_All_List then
            sub=root:CreateCheckbox(
                WoWTools_L.PERKS_PROGRAM_ASCENDING,
            function()
                return not WoWTools_HunterMixin:Save().sortDown
            end, function()
                WoWTools_HunterMixin:Save().sortDown= not WoWTools_HunterMixin:Save().sortDown and true or nil
            end)
            sub:SetTooltip(function(tooltip)
                WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Hunter.SortAscending'])
                tooltip:AddLine(WoWTools_L.STABLE_FILTER_BUTTON_LABEL)
            end)

            for _, tab in pairs( {
                {name='petNumber', type= 'petNumber'},
                {name='creatureID', type='creatureID'},
                {name='uiModelSceneID', type='uiModelSceneID'},
                {name='displayID', type='displayID'},
                {name=WoWTools_L.TYPE, type='type'},
                {name=WoWTools_L.NAME, type='name'},
                {name=WoWTools_L.SPECIALIZATION, type='specialization'},
                {name=WoWTools_L.EMBLEM_SYMBOL, type='icon'},
                {name=WoWTools_L.STABLE_SORT_TYPE_LABEL, type="familyName"}
            }) do
                sub=root:CreateButton(tab.name, function(data)
                    WoWTools_HunterMixin:sort_pets_list(data.type)
                    return MenuResponse.Open
                end, {type=tab.type})
                sub:SetTooltip(function(tooltip)
                    WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Hunter.SortBy'])
                    tooltip:AddLine(WoWTools_L.STABLE_FILTER_BUTTON_LABEL)
                end)
            end

            root:CreateDivider()
            root:CreateSpacer()
            WoWTools_MenuMixin:CreateSlider(root, {
                getValue=function()
                    return WoWTools_HunterMixin:Save().all_List_Size or 28
                end, setValue=function(value)
                    WoWTools_HunterMixin:Save().all_List_Size=value
                    local AllListFrame= _G['WoWTools_StableFrameAllList']
                    if AllListFrame then
                        AllListFrame:Settings()
                    end

                end,
                name=WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
                minValue=8,
                maxValue=72,
                step=1,
                bit=nil,
            })
            root:CreateSpacer()
        end

        

        sub=root:CreateCheckbox(
            WoWTools_L.HUD_EDIT_MODE_HUD_TOOLTIP_LABEL,
        function()
            return not WoWTools_HunterMixin:Save().HideTips
        end, function()
            WoWTools_HunterMixin:Save().HideTips= not WoWTools_HunterMixin:Save().HideTips and true or nil
        end)
        WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Hunter.Tooltips'])


        root:CreateDivider()
        WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_HunterMixin.addName})
    end






local function Init()
    local btn= WoWTools_ButtonMixin:Menu(StableFrameCloseButton, {name='WoWToolsHunterPlusMenuButton'})
    WoWTools_TextureMixin:SetButton(btn)
    btn:SetPoint('RIGHT', StableFrameCloseButton, 'LEFT', -2, 0)


    function btn:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_HunterMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(
            (_G['WoWTools_StableFrameAllList'] and '' or '|cff828282')
            ..(WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE),
            (WoWTools_HunterMixin:Save().all_List_Size or 22)..WoWTools_DataMixin.Icon.mid
        )
        GameTooltip:Show()
    end

    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)
    btn:SetScript('OnEnter', btn.set_tooltips)

    btn:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, function(...)
            Init_Menu(...)
        end)
    end)

    btn:EnableMouseWheel(true)
    btn:SetScript('OnMouseWheel', function(self, d)
        local AllListFrame= _G['WoWTools_StableFrameAllList']
        if not AllListFrame then
            return
        end

        local value= WoWTools_HunterMixin:Save().all_List_Size or 22
        if d==1 then
           value= value+ 1
        elseif d==-1 then
            value= value-1
        end

        value= min(value, 72)
        value= max(value, 8)

        WoWTools_HunterMixin:Save().all_List_Size=value

        AllListFrame:Settings()

        self:set_tooltips()
    end)
end








function WoWTools_HunterMixin:Init_Menu()
    Init()
end