

local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2, name
    sub=root:CreateCheckbox(
        WoWTools_L.SHOW,
    function()
        return not WoWTools_AuctionHouseMixin:Save().hideSellItemList
    end, function()
        WoWTools_AuctionHouseMixin:Save().hideSellItemList= not WoWTools_AuctionHouseMixin:Save().hideSellItemList and true or nil
        self:Settings()
        self:Init_Sell_Item_Button()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.AuctionHouse.SellList'])

    root:CreateDivider()

    sub=root:CreateButton(
        WoWTools_L['HIDE+ITEMS'],
    function()
        return MenuResponse.Open
    end)

    sub2=sub:CreateCheckbox(
        WoWTools_L.HIDE,
    function()
        return WoWTools_AuctionHouseMixin:Save().hideSellItemListButton
    end, function()
        WoWTools_AuctionHouseMixin:Save().hideSellItemListButton= not WoWTools_AuctionHouseMixin:Save().hideSellItemListButton and true or nil
        self:Init_Sell_Item_Button()
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.AuctionHouse.HideMarked'])

    name= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_L.CLEAR_ALL)
    sub2=sub:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            WoWTools_AuctionHouseMixin:Save().hideSellItem={}
            WoWTools_AuctionHouseMixin:Save().hideSellPet={}
            self:Init_Sell_Item_Button()
            WoWTools_Print(
                WoWTools_AuctionHouseMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_L['Clear hidden items']
            )
        end})
        return MenuResponse.Open
    end, {name=name})
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.AuctionHouse.ClearHidden'])

    sub:CreateDivider()
    local find=false
    for itemID in pairs(WoWTools_AuctionHouseMixin:Save().hideSellItem) do
        sub2= sub:CreateCheckbox(
            WoWTools_ItemMixin:GetName(itemID, nil),
        function(data)
            return WoWTools_AuctionHouseMixin:Save().hideSellItem[data.itemID]
        end, function(data)
            WoWTools_AuctionHouseMixin:Save().hideSellItem[data.itemID]= not WoWTools_AuctionHouseMixin:Save().hideSellItem[data.itemID] and true or nil
            self:Init_Sell_Item_Button()
        end, {itemID= itemID})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
        find=true
    end


    if find then
        sub:CreateDivider()
    end
    for speciesID, itemLink in pairs(WoWTools_AuctionHouseMixin:Save().hideSellPet) do
        local speciesName, speciesIcon, _, companionID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
        if speciesName then
            sub2= sub:CreateCheckbox(
                '|T'..(speciesIcon or 0)..':0|t'
                ..WoWTools_TextMixin:CN(speciesName, {npcID=companionID, isName=true}),
            function(data)
                return WoWTools_AuctionHouseMixin:Save().hideSellPet[data.speciesID]
            end, function(data)
                WoWTools_AuctionHouseMixin:Save().hideSellPet[data.speciesID]= not WoWTools_AuctionHouseMixin:Save().hideSellPet[data.speciesID] and data.itemLink or nil
                self:Init_Sell_Item_Button()
            end, {speciesID= speciesID, itemLink= itemLink})

            WoWTools_SetTooltipMixin:Set_Menu(sub2)
            find=true
        end
    end


    if not find then
       sub:CreateTitle(WoWTools_L.NONE)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)

    sub= root:CreateButton(
        WoWTools_ItemMixin:GetColor(WoWTools_AuctionHouseMixin:Save().sellItemQualiy, {text=WoWTools_Join(WoWTools_L.PROFESSIONS_COLUMN_HEADER_QUALITY,
            WoWTools_ItemMixin.QualityText[WoWTools_AuctionHouseMixin:Save().sellItemQualiy] or WoWTools_AuctionHouseMixin:Save().sellItemQualiy
        )}),
    function()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.AuctionHouse.SellQuality'])
        tooltip:AddLine(WoWTools_L.MINIMUM)
        tooltip:AddLine(WoWTools_L.COLORBLIND_ITEM_QUALITY)
    end)
    for quality= Enum.ItemQuality.Poor ,  Enum.ItemQuality.WoWToken do
        sub2=sub:CreateCheckbox(
            WoWTools_ItemMixin.QualityText[quality] or quality,
        function(data)
            return WoWTools_AuctionHouseMixin:Save().sellItemQualiy== data.quality
        end, function(data)
            WoWTools_AuctionHouseMixin:Save().sellItemQualiy= data.quality
            self:Init_Sell_Item_Button()
        end, {quality=quality})
        sub2:SetTooltip(function(tooltip, desc)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.AuctionHouse.SellQuality'])
            tooltip:AddLine(desc.data.quality)
        end)
    end

    sub=root:CreateCheckbox(
        WoWTools_L['NPE_TURN+AUCTION_HOUSE_SELL_TAB'],
    function()
        return WoWTools_AuctionHouseMixin:Save().intShowSellItem
    end, function()
        WoWTools_AuctionHouseMixin:Save().intShowSellItem= not WoWTools_AuctionHouseMixin:Save().intShowSellItem and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.AuctionHouse.GoToSell'])
        tooltip:AddLine(WoWTools_L['SHOW+BUTTON_LAG_AUCTIONHOUSE'])
    end)

    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_AuctionHouseMixin.addName})

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return WoWTools_AuctionHouseMixin:Save().numButton
        end, setValue=function(value)
            WoWTools_AuctionHouseMixin:Save().numButton=value
            self:Init_Sell_Item_Button()
        end,
        name=WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS,
        minValue=1,
        maxValue=40,
        step=1,
    })
    sub:CreateSpacer()

    WoWTools_MenuMixin:Scale(self, sub, function()
        return WoWTools_AuctionHouseMixin:Save().scaleSellButton or 1
    end, function(value)
        WoWTools_AuctionHouseMixin:Save().scaleSellButton= value
        self:Settings()
    end)

end





function WoWTools_AuctionHouseMixin:Sell_Setup_Menu(button)
    button:SetupMenu(Init_Menu)
end