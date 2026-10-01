
local function AltSpell_Menu(_, root)
    root:CreateDivider()

    local sub,sub2, sub3, spellSub, num
    local spells= WoWTools_FoodMixin:Save().spells[WoWTools_DataMixin.Player.Class]
    --local item, alt, ctrl, shift= tab.item, tab.alt, tab.ctrl, tab.shift
    local keyTab={
        {type='Alt', spellID=spells.alt},
        {type='Ctrl', spellID=spells.ctrl},
        {type='Shift', spellID=spells.shift},
        --{type='Item', spellID=spells.item},
    }

    for _, tab in pairs(keyTab) do

        sub=root:CreateCheckbox(
            tab.type
            ..(WoWTools_SpellMixin:GetName(tab.spellID) or ''),

        function(data)
            return WoWTools_FoodMixin:Save().spells[WoWTools_DataMixin.Player.Class][data.type]==data.spellID and data.spellID~=nil

        end, function(data)
            WoWTools_FoodMixin:Save().spells[WoWTools_DataMixin.Player.Class][data.type]= not WoWTools_FoodMixin:Save().spells[WoWTools_DataMixin.Player.Class][data.type] and data.spellID or nil
            WoWTools_FoodMixin:Init_Button()

        end, {type=string.lower(tab.type), spellID=tab.spellID})

        sub:SetTooltip(function(tooltip, desc)
            WoWTools_SetTooltipMixin:Setup(tooltip, desc.data)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Food.ModSpell'])
        end)

        for i=1, 12 do
            spellSub= C_SpellBook.GetSpellBookSkillLineInfo(i)--shouIdHide name numSpellBookItems iconID isGuild itemIndexOffset
            if spellSub and spellSub.name and not spellSub.shouIdHide then
                sub2=sub:CreateButton(
                    '|T'..(spellSub.iconID or 0)..':0|t'..WoWTools_TextMixin:CN(spellSub.name),
                function()
                    return MenuResponse.Open
                end)

                local info= C_SpellBook.GetSpellBookSkillLineInfo(i)
                if info and info.name and info.itemIndexOffset and info.numSpellBookItems and info.numSpellBookItems>0 then

                    num=0
                    for index= info.itemIndexOffset+1, info.itemIndexOffset+ info.numSpellBookItems do
                        local spellData= C_SpellBook.GetSpellBookItemInfo(index, Enum.SpellBookSpellBank.Player) or {}--skillLineIndex itemType isOffSpec subName actionID name iconID isPassive spellID
                        if not spellData.isPassive and spellData.spellID and spellData.name then

                            sub3=sub2:CreateCheckbox(
                                WoWTools_SpellMixin:GetName(spellData.spellID),

                            function(data)
                                return WoWTools_FoodMixin:Save().spells[WoWTools_DataMixin.Player.Class][data.type]==data.spellID

                            end, function(data)
                                WoWTools_FoodMixin:Save().spells[WoWTools_DataMixin.Player.Class][data.type]= WoWTools_FoodMixin:Save().spells[WoWTools_DataMixin.Player.Class][data.type]~= data.spellID and data.spellID or nil
                                WoWTools_FoodMixin:Init_Button()

                            end, {type=string.lower(tab.type), spellID=spellData.spellID})

                            sub3:SetTooltip(function(tooltip, desc)
                                WoWTools_SetTooltipMixin:Setup(tooltip, desc.data)
                                WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Food.ModSpellPick'])
                            end)
                            num= num+1
                        end
                    end

                    WoWTools_MenuMixin:SetScrollMode(sub)
                end
            end
        end
        sub:CreateDivider()
        sub:CreateTitle(tab.type)
    end
end
















local function Check_All_SubClass(setClassID)
    WoWTools_FoodMixin:Save().class[setClassID]= WoWTools_FoodMixin:Save().class[setClassID] or {}
    for subClassID= 0, 20 do
        local subClass=C_Item.GetItemSubClassInfo(setClassID, subClassID)
        if subClass then
            WoWTools_FoodMixin:Save().class[setClassID][subClassID]=true
        else
            break
        end
    end
end













local function Check_All_Menu(_, root, setClassID)
    root:CreateDivider()
    local sub=root:CreateButton(WoWTools_L.CHECK_ALL, function(data)
        if IsControlKeyDown() or data.classID then
            do
                if data.classID then
                    Check_All_SubClass(data.classID)
                else
                    WoWTools_FoodMixin:Save().class={}
                    for classID=0, 20 do
                        if not WoWTools_FoodMixin:Save().DisableClassID[classID] then
                            local class= C_Item.GetItemClassInfo(classID)
                            if class then
                                WoWTools_FoodMixin:Save().class[classID]= {}
                                Check_All_SubClass(classID)
                            else
                                break
                            end
                        end
                    end
                end
            end
            WoWTools_FoodMixin:Check_Items()
        end
        return MenuResponse.Refresh
    end, {classID=setClassID})
    if not setClassID then
        sub:SetTooltip(function(tooltip) tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..WoWTools_DataMixin.Icon.left) end)
    end

    sub=root:CreateButton(WoWTools_L.UNCHECK_ALL, function(data)
        if IsControlKeyDown() or data.classID then
            if data.classID then
                WoWTools_FoodMixin:Save().class[data.classID]= nil
            else
                WoWTools_FoodMixin:Save().class={}
            end
            WoWTools_FoodMixin:Check_Items()
        end
        return MenuResponse.Refresh
    end, {classID=setClassID})
    if not setClassID then
        sub:SetTooltip(function(tooltip) tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..WoWTools_DataMixin.Icon.left) end)
    end
end



















local function Init_Menu(self, root)
    if not self:CanChangeAttribute() then
        root:CreateTitle(WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        return
    end

    local sub, sub2, sub3, class, subClass, find, name
    local items={
        --[classID]={num=0,[subClassID]=0}
    }
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do-- + NUM_REAGENTBAG_FRAMES
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info= C_Container.GetContainerItemInfo(bag, slot) or {}
            local classID, subClassID= WoWTools_FoodMixin:Get_Item_Valid(info.itemID)
            if classID and subClassID then
                local num= info.stackCount or 1
                items[classID]= items[classID] or {num=0}--class
                items[classID].num= items[classID].num+ num
                items[classID][subClassID]= (items[classID][subClassID] or 0)+ num--subClass
            end
        end
    end

    sub=root:CreateButton(
        (WoWTools_FoodMixin:Save().autoWho and '|cnGREEN_FONT_COLOR:' or '')
        ..'|A:common-icon-zoomin:0:0|a'
        ..(WoWTools_L['WHO~3'])
        ..WoWTools_DataMixin.Icon.mid,
    function()
        WoWTools_FoodMixin:Check_Items(true)
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Food.Search'])

    sub2=sub:CreateButton(WoWTools_L.HIDE, function() return MenuResponse.Open end)
    for classID=0, 20 do
        class= C_Item.GetItemClassInfo(classID)
        if class then
            sub3=sub2:CreateCheckbox(classID..' '..WoWTools_TextMixin:CN(class)..' '..(items[classID] and items[classID].num or ''), function(data)
                return WoWTools_FoodMixin:Save().DisableClassID[data.classID]
            end, function(data)
                WoWTools_FoodMixin:Save().DisableClassID[data.classID]= not WoWTools_FoodMixin:Save().DisableClassID[data.classID] and true or nil
                WoWTools_FoodMixin:Check_Items()
                return MenuResponse.Refresh
            end, {classID=classID})
            WoWTools_MenuMixin:SetDescription(sub3, WoWTools_L['Tip.Food.HideClass'])
        end
    end

    sub2=sub:CreateButton(WoWTools_L.DISABLE, function() return MenuResponse.Open end)
    find=0
    for itemID in pairs(WoWTools_FoodMixin:Save().noUseItems) do
        find=find+1
        sub3=sub2:CreateCheckbox(find..') '..WoWTools_ItemMixin:GetName(itemID), function(data)
            return WoWTools_FoodMixin:Save().noUseItems[data.itemID]
        end, function(data)
            WoWTools_FoodMixin:Save().noUseItems[data.itemID]= not WoWTools_FoodMixin:Save().noUseItems[data.itemID] and true or nil
            WoWTools_FoodMixin:Check_Items()
        end, {itemID=itemID})
        sub3:SetTooltip(function(tooltip, desc)
            WoWTools_SetTooltipMixin:Setup(tooltip, desc.data)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Food.DisabledItem'])
        end)
    end

    sub2:CreateDivider()
    sub2:CreateButton(
        WoWTools_L.CLEAR_ALL,
    function()
        StaticPopup_Show('WoWTools_OK',
        WoWTools_L.CLEAR_ALL,
        nil,
        {SetValue=function()
            WoWTools_FoodMixin:Save().noUseItems={}
            WoWTools_FoodMixin:Check_Items()
        end})
        return MenuResponse.Open
    end)
    WoWTools_MenuMixin:SetScrollMode(sub2)



    sub:CreateDivider()
    sub2=sub:CreateCheckbox(WoWTools_L['On login: search'], function()
        return WoWTools_FoodMixin:Save().autoLogin
    end, function()
        WoWTools_FoodMixin:Save().autoLogin= not WoWTools_FoodMixin:Save().autoLogin and true or nil
        if WoWTools_FoodMixin:Save().autoLogin then
            WoWTools_FoodMixin:Check_Items()
        end
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Food.AutoLogin'])

    sub2=sub:CreateCheckbox(WoWTools_L['SELF_CAST_AUTO+UPDATE'], function()
        return WoWTools_FoodMixin:Save().autoWho
    end, function()
        WoWTools_FoodMixin:Save().autoWho= not WoWTools_FoodMixin:Save().autoWho and true or nil
        if WoWTools_FoodMixin:Save().autoWho then
            WoWTools_FoodMixin:Check_Items()
        end
        self.CheckFrame:set_event()
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Food.AutoWho'])
        tooltip:AddLine(WoWTools_L.EVENTS_LABEL)
        tooltip:AddLine('BAG_UPDATE_DELAYED')
        tooltip:AddLine(' ')
        GameTooltip_AddErrorLine(tooltip, WoWTools_L['High CPU'])
    end)

    if not PlayerIsTimerunning() then
        sub2=sub:CreateCheckbox(
            WoWTools_L['Only current version items'],
        function()
            return WoWTools_FoodMixin:Save().onlyMaxExpansion
        end, function()
            WoWTools_FoodMixin:Save().onlyMaxExpansion= not WoWTools_FoodMixin:Save().onlyMaxExpansion and true or nil
            WoWTools_FoodMixin:Check_Items()
        end)
        WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Food.OnlyCurrentExp'])
    end

    sub2=sub:CreateCheckbox(WoWTools_L['Usable only'], function()
        return WoWTools_FoodMixin:Save().olnyUsaItem
    end, function()
        WoWTools_FoodMixin:Save().olnyUsaItem= not WoWTools_FoodMixin:Save().olnyUsaItem and true or false
        WoWTools_FoodMixin:Check_Items()
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Food.UsableOnly'])
        tooltip:AddLine('C_Item.GetItemSpell(itemID)')
    end)
    sub:CreateDivider()

    WoWTools_MenuMixin:BgAplha(sub,
    function()
        return WoWTools_FoodMixin:Save().bgAlpha or 0
    end, function(value)
        WoWTools_FoodMixin:Save().bgAlpha= value
        self:set_background()
    end)

    WoWTools_MenuMixin:Scale(self, sub, function()
        return WoWTools_FoodMixin:Save().scale or 1
    end, function(value)
        WoWTools_FoodMixin:Save().scale= value
        self:set_scale()
    end)



    WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        WoWTools_FoodMixin:Save().strata= data
        self:set_strata()
    end)


    sub2=sub:CreateButton(
        '|A:newplayertutorial-icon-key:0:0|a'
        ..(WoWTools_L.AUCTION_HOUSE_QUANTITY_LABEL),
    function()
        return MenuResponse.Open
    end, {rightText= WoWTools_FoodMixin:Save().numLine})
    WoWTools_MenuMixin:SetRightText(sub2)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Food.NumLine'])


    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return WoWTools_FoodMixin:Save().numLine
        end, setValue=function(value)
            WoWTools_FoodMixin:Save().numLine=value
            WoWTools_FoodMixin:Check_Items()
        end,
        --name=,
        minValue=1,
        maxValue=60,
        step=1,
        bit=nil,
    })
    sub2:CreateSpacer()


    sub2=sub:CreateButton(
        '|A:bag-reagent-border:0:0|a'
        ..(WoWTools_L.EMBLEM_BORDER),
    function()
        return MenuResponse.Open
    end, {rightText= WoWTools_FoodMixin:Save().borderAlpha or 0})
    WoWTools_MenuMixin:SetRightText(sub2)

    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return WoWTools_FoodMixin:Save().borderAlpha or 0
        end, setValue=function(value)
            WoWTools_FoodMixin:Save().borderAlpha=value
            WoWTools_FoodMixin:Check_Items()
        end,
        name=WoWTools_L.HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY,
        minValue=0,
        maxValue=1,
        step=0.1,
        bit='%0.1f',
    })


    sub:CreateDivider()
    WoWTools_MenuMixin:RestPoint(self, sub, WoWTools_FoodMixin:Save().point , function()
        if self:CanChangeAttribute() then
            WoWTools_FoodMixin:Save().point=nil
            self:set_point()
        end
    end)

    WoWTools_ToolsMixin:OpenMenu(sub, WoWTools_FoodMixin.addName)

    sub=root:CreateButton(WoWTools_L.CUSTOM, function() return MenuResponse.Open end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_L['Drag item to add'])
    end)

    find=0
    for itemID in pairs(WoWTools_FoodMixin:Save().addItems) do
        find=find+1
        sub2=sub:CreateCheckbox(find..') '..WoWTools_ItemMixin:GetName(itemID), function(data)
            return WoWTools_FoodMixin:Save().addItems[data.itemID]
        end, function(data)
            WoWTools_FoodMixin:Save().addItems[data.itemID]= not WoWTools_FoodMixin:Save().addItems[data.itemID] and true or nil
            WoWTools_FoodMixin:Check_Items()
        end, {itemID=itemID})
        sub2:SetTooltip(function(tooltip, desc)
            WoWTools_SetTooltipMixin:Setup(tooltip, desc.data)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Food.CustomItem'])
        end)
    end

    sub:CreateDivider()
    name= WoWTools_L.CLEAR_ALL
    sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            WoWTools_FoodMixin:Save().addItems={}
            WoWTools_FoodMixin:Check_Items()
        end})
        return MenuResponse.Open
    end, {name=name})

    WoWTools_MenuMixin:SetScrollMode(sub)

    sub2=sub:CreateCheckbox(WoWTools_L.BATTLEFIELD_MINIMAP_SHOW_ALWAYS, function()
        return WoWTools_FoodMixin:Save().addItemsShowAll
    end, function()
        WoWTools_FoodMixin:Save().addItemsShowAll= not WoWTools_FoodMixin:Save().addItemsShowAll and true or nil
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Food.CustomShowAll'])


    find=nil
--Enum.ItemClass
    for classID=0, 20 do
        if not WoWTools_FoodMixin:Save().DisableClassID[classID] then
            class= C_Item.GetItemClassInfo(classID)
            if class then
                if not find then
                    root:CreateDivider()
                    find=true
                end

                sub=root:CreateCheckbox(classID..' '..WoWTools_TextMixin:CN(class)..' '..(items[classID] and items[classID].num or ''), function(data)
                    return WoWTools_FoodMixin:Save().class[data.classID]
                end, function(data)
                    if WoWTools_FoodMixin:Save().class[data.classID] then
                        WoWTools_FoodMixin:Save().class[data.classID]= nil
                    else
                        WoWTools_FoodMixin:Save().class[data.classID]= WoWTools_FoodMixin:Save().class[data.classID] or {}
                        for i=0, 20 do
                            local name2= C_Item.GetItemSubClassInfo(data.classID, i)
                            if name2 and name2~='' then
                                WoWTools_FoodMixin:Save().class[data.classID][i]=true
                            end
                        end
                    end
                    WoWTools_FoodMixin:Check_Items()
                end, {classID=classID})
                sub:SetTooltip(function(tooltip, description)
                    WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Food.Class'])
                    tooltip:AddLine(
                        WoWTools_FoodMixin:Save().class[description.data.classID]
                        and (WoWTools_L.UNCHECK_ALL)
                        or (WoWTools_L.CHECK_ALL)
                    )
                end)



                for subClassID= 0, 20 do
                    subClass=C_Item.GetItemSubClassInfo(classID, subClassID)
                    if subClass and subClass~='' then
                        sub2=sub:CreateCheckbox(
                            subClassID..' '..WoWTools_TextMixin:CN(subClass)..' '
                            ..(items[classID] and items[classID][subClassID] or ''),
                        function(data)
                            return WoWTools_FoodMixin:Save().class[data.classID] and WoWTools_FoodMixin:Save().class[data.classID][data.subClassID]
                        end, function(data)
                            if WoWTools_FoodMixin:Save().class[data.classID] and WoWTools_FoodMixin:Save().class[data.classID][data.subClassID] then
                                WoWTools_FoodMixin:Save().class[data.classID][data.subClassID]=nil
                            else
                                WoWTools_FoodMixin:Save().class[data.classID]= WoWTools_FoodMixin:Save().class[data.classID] or {}
                                WoWTools_FoodMixin:Save().class[data.classID][data.subClassID]= true
                            end
                            WoWTools_FoodMixin:Check_Items()
                        end, {classID=classID, subClassID=subClassID})
                        WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Food.SubClass'])
                    else
                        break
                    end
                end

                Check_All_Menu(self, sub, classID)
            else
                break
            end
        end
    end

    Check_All_Menu(self, root, nil)

    AltSpell_Menu(self, root)
end














function WoWTools_FoodMixin:Init_Menu(btn)
    MenuUtil.CreateContextMenu(btn, Init_Menu)
end