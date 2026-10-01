

local function Edit_Item(self, info)

    StaticPopup_Show('WoWTools_EditText',
        WoWTools_OpenItemMixin.addName..'|n|n'
        ..WoWTools_ItemMixin:GetName(info.itemID)..'|n|n'
        ..format(WoWTools_L.ERR_ZONE_EXPLORED,
        WoWTools_OpenItemMixin:Save().no[info.itemID] and self.noText
        or (WoWTools_OpenItemMixin:Save().use[info.itemID] and self.useText)
        or (WoWTools_L['NEW~2'])
    ),
    nil,
    {
        itemID=info.itemID,
        itemLink=info.itemLink,

        text=WoWTools_OpenItemMixin:Save().use[info.itemID],
        OnShow=function(s, data)
            local edit= s.editBox or s:GetEditBox()
            local b3= s.button3 or s:GetButton3()
            edit:SetNumeric(true)
            local useStr=ITEM_SPELL_TRIGGER_ONUSE..'(.+)'
            local dateInfo= WoWTools_ItemMixin:GetTooltip({
                hyperLink=data.itemLink,
                itemID=data.itemID,
                text={useStr},
                onlyText=true,
            })
            local num= dateInfo.text[useStr] and dateInfo.text[useStr]:match('%d+')
            num= num and tonumber(num)

            edit:SetNumber(num or WoWTools_OpenItemMixin:Save().use[data.itemID] or 1)
            b3:SetText(self.noText)
        end,
        OnHide=function(s)
            local edit= s.editBox or s:GetEditBox()
            edit:SetNumeric(false)
            edit:ClearFocus()
        end,
        SetValue= function(s, data)
            local edit= s.editBox or s:GetEditBox()
            local num= edit:GetNumber()
            num = num<1 and 1 or num
            WoWTools_OpenItemMixin:Save().use[data.itemID]=num
            WoWTools_OpenItemMixin:Save().no[data.itemID]=nil
            WoWTools_OpenItemMixin:Get_Item()
            WoWTools_Print(WoWTools_DataMixin.Icon.icon2..WoWTools_OpenItemMixin.addName,
                WoWTools_ItemMixin:GetLink(data.itemID),
                num>1 and
                    (WoWTools_L['Combine items'])..': '..'|cnGREEN_FONT_COLOR:'..num..'|r'
                    or self.useText
            )
        end,
        OnAlt=function(_, data)
            WoWTools_OpenItemMixin:Save().no[data.itemID]=true
            WoWTools_OpenItemMixin:Save().use[data.itemID]=nil
            WoWTools_OpenItemMixin:Get_Item()
            WoWTools_Print(WoWTools_DataMixin.addName, WoWTools_OpenItemMixin.addName,
                WoWTools_ItemMixin:GetLink(info.itemID),
                self.noText
            )
        end,
        EditBoxOnTextChanged=function(s)
            local num= s:GetNumber()
            local p=s:GetParent()
            local b1= p:GetButton1()
            if num>1 then
                b1:SetText('|cnGREEN_FONT_COLOR:'..(WoWTools_L.AUCTION_STACK_SIZE)..' '..num..'|r')
            else
                b1:SetText('|cnGREEN_FONT_COLOR:'..self.useText..'|r');
            end
        end,
    }
    )

end















local function Remove_NoUse_Menu(self, root, itemID, type, numUse, index)
    WoWTools_DataMixin:Load(itemID, 'item')

    local sub=root:CreateButton(
        (numUse and '|cnGREEN_FONT_COLOR:'..numUse..'=|r ' or '')
        ..WoWTools_ItemMixin:GetName(itemID),
    function(data)
        Edit_Item(self, data)
        return MenuResponse.Open
    end, {itemID=itemID, type=type, rightText= index})

    WoWTools_MenuMixin:SetRightText(sub)
    WoWTools_SetTooltipMixin:Set_Menu(sub)

    if type=='use' then
        sub:CreateButton(
            WoWTools_DataMixin.Icon.left..(WoWTools_L.EDIT),
        function(data)
            Edit_Item(self, data)
            return MenuResponse.Open
        end, {itemID=itemID, type=type})
        sub:CreateDivider()
    end
    sub:CreateButton(
        '|A:common-icon-redx:0:0|a'..(WoWTools_L.REMOVE),
    function(data)
        WoWTools_OpenItemMixin:Save()[data.type][data.itemID]=nil

        WoWTools_Print(WoWTools_DataMixin.Icon.icon2..WoWTools_OpenItemMixin.addName,
            WoWTools_OpenItemMixin:Save()[data.type][data.itemID]
            and '|cnGREEN_FONT_COLOR:'..(WoWTools_L.REMOVE)..'|r'
            or ('|cnWARNING_FONT_COLOR:'..(WoWTools_L.SPELL_FAILED_ITEM_GONE)),

            WoWTools_ItemMixin:GetLink(data.itemID),
            data.type=='no' and self.noText or self.useText
        )

        WoWTools_OpenItemMixin:Get_Item()

        return MenuResponse.Open
    end, {itemID=itemID, type=type})
end




local function Remove_All_Menu(self, root, type, num)
    local name= (type=='use' and '|A:jailerstower-wayfinder-rewardcheckmark:0:0|a' or '|A:talents-button-reset:0:0|a')
                ..(WoWTools_L.CLEAR_ALL)..' #'..num

    root:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            local index=0
                local type2= data.type=='no' and self.noText or self.useText
                WoWTools_Print(WoWTools_DataMixin.Icon.icon2..WoWTools_OpenItemMixin.addName)
                for itemID in pairs(WoWTools_OpenItemMixin:Save()[data.type]) do
                    index= index+1
                    WoWTools_Print(
                        index..')',
                        WoWTools_L.REMOVE,
                        WoWTools_ItemMixin:GetLink(itemID),
                        '|A:common-icon-redx:0:0|a'..type2
                    )
                end
                WoWTools_Print(WoWTools_L.CLEAR_ALL, '|A:common-icon-redx:0:0|a|cnGREEN_FONT_COLOR:#',  index)
                WoWTools_OpenItemMixin:Save()[data.type]={}
                WoWTools_OpenItemMixin:Get_Item()
        end})
        return MenuResponse.Open

    end, {type=type, name=name})
    root:CreateDivider()
end
























local function Init_Menu(self, root)
    local sub, sub2

    if self:IsValid() then
        sub= root:CreateButton(
            select(2, self:GetItemName(true)),
            function() self:set_disabled_current_item() end,
            {itemLink=self:GetItemLink()}
        )
        sub:SetTooltip(function(tooltip)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.OpenItems.DisableCurrent'])
            tooltip:AddDoubleLine(self.noText)
            tooltip:AddDoubleLine(WoWTools_DataMixin.Icon.mid..(WoWTools_L.COMBAT_TEXT_SCROLL_UP))

        end)
    else
        sub=root:CreateButton(WoWTools_L.NONE)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_L['Use/Disable'])
            tooltip:AddLine(WoWTools_L['DRAG_MODEL+ITEMS~2'])
        end)
    end
    root:CreateDivider()

    local no= CountTable(WoWTools_OpenItemMixin:Save().no or {})
    local use= CountTable(WoWTools_OpenItemMixin:Save().use or {})

    sub= root:CreateButton(
        self.noText,
    function()
        return MenuResponse.Open
    end, {rightText= no})
    WoWTools_MenuMixin:SetRightText(sub)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.OpenItems.NoList'])

    if no>2 then
        Remove_All_Menu(self, sub, 'no', no)
    end
    local index=0
    for itemID in pairs(WoWTools_OpenItemMixin:Save().no) do
        index= index+1
        Remove_NoUse_Menu(self, sub, itemID, 'no', nil, index)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)


    sub=root:CreateButton(
        self.useText,
    function()
        return MenuResponse.Open
    end, {rightText= use})
    WoWTools_MenuMixin:SetRightText(sub)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.OpenItems.UseList'])

    if use>2 then
        Remove_All_Menu(self, sub, 'use', use)
    end
    index=0
    for itemID, numUse in pairs(WoWTools_OpenItemMixin:Save().use) do
        index= index+1
        Remove_NoUse_Menu(self, sub, itemID, 'use', numUse, index)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)


local OpenTips={
    open='Tip.OpenItems.Open',
    mount='Tip.OpenItems.Mount',
    mago='Tip.OpenItems.Transmog',
    ski='Tip.OpenItems.Recipe',
    alt='Tip.OpenItems.Other',
    reagent='Tip.OpenItems.Reagent',
}
local OptionsList={{
    name=WoWTools_L.ITEM_OPENABLE,
    type='open'
},{
    name=WoWTools_L.MOUNTS,
    type='mount'
},{
    name=WoWTools_L.TRANSMOGRIFY,
    type='mago'
}, {
    name=WoWTools_L.TRADESKILL_SERVICE_LEARN,
    type='ski'
}, {
    name=WoWTools_L.BINDING_HEADER_OTHER,
    type='alt'
}, {
    name=WoWTools_L.BAG_FILTER_REAGENTS,
    type='reagent',
    tooltip=WoWTools_L['WHO~2'],
},
}
    for _, info in pairs(OptionsList) do
        sub= root:CreateCheckbox(
            info.name,
        function(data)
            return WoWTools_OpenItemMixin:Save()[data.type]
        end, function(data)
            WoWTools_OpenItemMixin:Save()[data.type]= not WoWTools_OpenItemMixin:Save()[data.type] and true
            WoWTools_OpenItemMixin:Get_Item()
        end, {type=info.type, tooltip=info.tooltip})
        sub:SetTooltip(function(tooltip, description)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L[OpenTips[description.data.type]])
            if description.data.tooltip then
                tooltip:AddLine(description.data.tooltip)
            end
        end)
    end

    root:CreateDivider()


    sub= WoWTools_ToolsMixin:OpenMenu(root, WoWTools_OpenItemMixin.addName, self:get_key_text())

    WoWTools_KeyMixin:SetMenu(self, sub, {
        name= WoWTools_OpenItemMixin.addName,
        key=WoWTools_OpenItemMixin:Save().KEY,
        GetKey=function(key)
            WoWTools_OpenItemMixin:Save().KEY= key
            self:settings()
        end,
        OnAlt=function()
            WoWTools_OpenItemMixin:Save().KEY=nil
            self:settings()
        end,
    })

    sub:CreateDivider()
    sub2=sub:CreateTitle(WoWTools_L['DRAG_MODEL+ITEMS'])
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(self.useText, self.noText)
    end)

    WoWTools_ToolsMixin:SettingsMenu(root, WoWTools_OpenItemMixin)
end














function WoWTools_OpenItemMixin:Setup_Menu()
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('OpenItems')
    if btn then
        MenuUtil.CreateContextMenu(btn, Init_Menu)
    end
end

function WoWTools_OpenItemMixin:Edit_Item(...)
    Edit_Item(...)
end