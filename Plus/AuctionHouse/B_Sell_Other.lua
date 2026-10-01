
local function Init_NextItem()

    AuctionHouseFrame.CommoditiesSellFrame.PostButton:SetHeight(32)--<Size x="194" y="22"/>
    AuctionHouseFrame.ItemSellFrame.PostButton:SetHeight(32)

    WoWTools_DataMixin:Hook(AuctionHouseFrame.CommoditiesSellFrame, 'PostItem', function(self)
        self.isNextItem=true
    end)
    WoWTools_DataMixin:Hook(AuctionHouseFrame.CommoditiesSellFrame, 'UpdatePostButtonState', function(self)
        self.PostButton:ClearAllPoints()
        self.PostButton:SetPoint('BOTTOM', 45, 75)
        if self:GetItem()
            or not C_AuctionHouse.IsThrottledMessageSystemReady()
            or not self.isNextItem
            or AuctionHouseMultisellProgressFrame:IsShown()
        then
            return
        end
        C_Timer.After(0.3, function() WoWTools_AuctionHouseMixin:SetPostNextSellItem() end)
        self.isNextItem=nil
    end)
    WoWTools_DataMixin:Hook(AuctionHouseFrame.ItemSellFrame, 'PostItem', function(self)
        self.isNextItem=true
    end)
    WoWTools_DataMixin:Hook(AuctionHouseFrame.ItemSellFrame, 'UpdatePostButtonState', function(self)
        self.PostButton:ClearAllPoints()
        self.PostButton:SetPoint('BOTTOM', 45, 75)
        if self:GetItem()
            or not C_AuctionHouse.IsThrottledMessageSystemReady()
            or not self.isNextItem
            or AuctionHouseMultisellProgressFrame:IsShown()
        then
            return
        end
        C_Timer.After(0.3, function() WoWTools_AuctionHouseMixin:SetPostNextSellItem() end)
        self.isNextItem=nil
    end)

    --Create_AutPost(AuctionHouseFrame.CommoditiesSellFrame.PostButton)
    --Create_AutPost(AuctionHouseFrame.ItemSellFrame.PostButton)

    Init_NextItem=function()end
end


local function Init_ShowCommoditiesButton()
    local levelFrame= AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton:GetFrameLevel()

    local showCommoditiesButton=WoWTools_ButtonMixin:Cbtn(AuctionHouseFrame.ItemSellFrame, {
        isUI=true,
        size={100,22},
        text=WoWTools_L.ITEMS
    })
    showCommoditiesButton:SetPoint('BOTTOMRIGHT', -15,15)
    showCommoditiesButton:SetFrameLevel(levelFrame)
    showCommoditiesButton:SetScript('OnLeave', GameTooltip_Hide)
    showCommoditiesButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT");
        GameTooltip:ClearLines();
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_AuctionHouseMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_L['SHOW+MODE'], '|cnGREEN_FONT_COLOR:'..(WoWTools_L.CONVERT)..'|r '..(WoWTools_L.PROFESSIONS_COLUMN_HEADER_REAGENTS))
        GameTooltip:Show();
    end)
    showCommoditiesButton:SetScript('OnClick', function()
        AuctionHouseFrame:ClearPostItem()
        if AuctionHouseMultisellProgressFrame:IsShown() then
            C_AuctionHouse.CancelSell()
        end
        AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.CommoditiesSell)
        C_Timer.After(0.5, function() WoWTools_AuctionHouseMixin:SetPostNextSellItem() end)
    end)


    local showSellButton=WoWTools_ButtonMixin:Cbtn(AuctionHouseFrame.CommoditiesSellFrame, {
        isUI=true,
        size={100,22},
        text=WoWTools_L.PROFESSIONS_COLUMN_HEADER_REAGENTS
    })
    showSellButton:SetPoint('BOTTOMRIGHT',  -15,15)
    showSellButton:SetFrameLevel(levelFrame)
    showSellButton:SetScript('OnLeave', GameTooltip_Hide)
    showSellButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT");
        GameTooltip:ClearLines();
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_AuctionHouseMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_L.SHOW, '|cnGREEN_FONT_COLOR:'..(WoWTools_L.CONVERT)..'|r '..(WoWTools_L.ITEMS))
        GameTooltip:Show();
    end)
    showSellButton:SetScript('OnClick', function()
        AuctionHouseFrame:ClearPostItem()
        AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.ItemSell)
        C_Timer.After(0.5, function() WoWTools_AuctionHouseMixin:SetPostNextSellItem() end)
    end)

    local cancelButton2= WoWTools_ButtonMixin:Cbtn(AuctionHouseFrame.ItemSellFrame.PostButton, {size=32, texture='Interface\\Buttons\\CancelButton-Up'})
    cancelButton2:SetHighlightTexture('Interface\\Buttons\\CancelButton-Highlight')
    cancelButton2:SetPushedTexture('Interface\\Buttons\\CancelButton-Down')
    cancelButton2:SetFrameLevel(1501)
    cancelButton2:SetPoint('RIGHT', AuctionHouseFrame.ItemSellFrame.PostButton, 'LEFT', 0,-2)
    cancelButton2:SetScript('OnLeave', GameTooltip_Hide)
    cancelButton2:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT");
        GameTooltip:ClearLines();
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_AuctionHouseMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(' ', WoWTools_L.AUCTION_HOUSE_CANCEL_AUCTION_BUTTON)
        GameTooltip:Show();
    end)
    cancelButton2:SetScript('OnClick', C_AuctionHouse.CancelSell)


--Blizzard_AuctionHouseSearchBar.lua
    WoWTools_DataMixin:Hook(AuctionHouseFrame.CommoditiesSellList.ScrollBox, 'Update', function(frame)
        if not frame:HasView() then
            return
        end
        for _, btn in pairs(frame:GetFrames() or {}) do
            if not btn.setOnDoubleClick then
                btn:SetScript('OnDoubleClick', function()
                    local itemLink= AuctionHouseFrame.CommoditiesSellFrame.ItemDisplay:GetItemLink()
                    local itemName= itemLink and C_Item.GetItemInfo(itemLink)
                    if itemName then
                        AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.Buy)
                        AuctionHouseFrame.SearchBar.SearchBox:SetText(itemName)
                        AuctionHouseFrame.SearchBar:StartSearch()
                    end
                end)
                btn.setOnDoubleClick=true
            end
        end
    end)
    WoWTools_DataMixin:Hook(AuctionHouseFrame.ItemSellList.ScrollBox, 'Update', function(frame)
        if not frame:HasView() then
            return
        end
        for _, btn in pairs(frame:GetFrames() or {}) do
            if not btn.setOnDoubleClick then
                btn:SetScript('OnDoubleClick', function()
                    local itemLink= AuctionHouseFrame.ItemSellFrame.ItemDisplay:GetItemLink()
                    local itemName= itemLink and C_Item.GetItemInfo(itemLink)
                    if itemName then
                        AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.Buy)
                        AuctionHouseFrame.SearchBar.SearchBox:SetText(itemName)
                        AuctionHouseFrame.SearchBar:StartSearch()
                    end
                end)
                btn.setOnDoubleClick=true
            end
        end
    end)

end


local function OnShowToSellFrame()
    if not WoWTools_AuctionHouseMixin:Save().intShowSellItem or not AuctionHouseFrame:IsShown() then
        return
    end

    local itemCommodityStatus

    --AuctionHouseFrame:SetDisplayMode(AuctionHouseFrameDisplayMode.ItemSell)

    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do--Constants.InventoryConstants.NumBagSlots
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            itemCommodityStatus= select(2, WoWTools_AuctionHouseMixin:GetItemSellStatus(bag, slot, true))

            if itemCommodityStatus then
                AuctionHouseFrame:SetDisplayMode(
                    itemCommodityStatus==Enum.ItemCommodityStatus.Commodity and AuctionHouseFrameDisplayMode.CommoditiesSell
                    or AuctionHouseFrameDisplayMode.ItemSell
                )

                --C_Timer.After(0.3, function()
                    WoWTools_AuctionHouseMixin:SetPostNextSellItem()
                --end)

                return
            end
        end
    end
end


local function GetDefaultPrice(itemLocation)
    local price= 2000000--200g

    local itemLink, itemID
    if itemLocation and itemLocation:IsValid() then
        itemLink = C_Item.GetItemLink(itemLocation)
        itemID= C_Item.GetItemID(itemLocation)
    end

    if not itemID or not itemLink then
        return price
    end


    local classID= select(6, C_Item.GetItemInfoInstant(itemID))

    if WoWTools_AuctionHouseMixin:Save().SellItemDefaultPrice[itemID] then
        price= WoWTools_AuctionHouseMixin:Save().SellItemDefaultPrice[itemID]

    elseif C_MountJournal.GetMountFromItem(itemID) or C_ToyBox.GetToyInfo(itemID) then
        price= 999999900

    elseif C_PetJournal.GetPetInfoByItemID(itemID)
        or itemLink:find('Hbattlepet:(%d+)')
        or C_Item.IsCosmeticItem(itemID)
        or C_Item.IsDecorItem(itemID)
        or C_Item.IsDressableItemByID(itemID)
        or classID==12
    then
        price= 99999900

    else--if LinkUtil.IsLinkType(itemLink, "item") then
        local vendorPrice = select(11, C_Item.GetItemInfo(itemLink))
        if vendorPrice then
            local defaultPrice = vendorPrice * 500
            local price2 = defaultPrice + (COPPER_PER_SILVER - (defaultPrice % COPPER_PER_SILVER))-- AH prices must be in silver increments.

            price= math.max(price2, price)--200g
        end
    end


    return price
end


local function Update_Total_Price(frame)
    local itemLocation= frame:GetItem()
    local text=''
    local text2=''
    if itemLocation and itemLocation:IsValid() then
        local itemLink = C_Item.GetItemLink(itemLocation);
        local vendorPrice =itemLink and select(11, C_Item.GetItemInfo(itemLink)) or 10000;
        local unitPrice= frame.GetUnitPrice and frame:GetUnitPrice() or frame.PriceInput:GetAmount();-- frame:GetUnitPrice()
        unitPrice= unitPrice or 0--precio vacío o 0: no avisar mientras se escribe
        local col=''
        if vendorPrice and unitPrice and vendorPrice>0 and unitPrice>0 then
            if unitPrice> vendorPrice then
                local x= unitPrice/vendorPrice
                if x<5 then
                    col= '|cff626262'
                elseif x<10 then
                    col= '|cffffffff'
                elseif x<50 then
                    col='|cnGREEN_FONT_COLOR:'
                else
                    col='|cffff00ff'
                end
                x= x<0 and 0 or x
                if x<10 then
                    text= col..format('x%.2f', x)
                else
                    text= col..format('x%i', x)
                end
            else
                col='|cnWARNING_FONT_COLOR:'
                text= col..(WoWTools_L['VOICEMACRO_1_Sc_0~2'])
                --Solo avisar: antes se sacaba el objeto del marco de venta y se ocultaba para siempre
            end
        end
        if vendorPrice then
            text2= col..GetMoneyString(vendorPrice)--C_CurrencyInfo.GetCoinTextureString(vendorPrice)
        end
    end
    frame.vendorPriceLabel:SetText(text2)
    frame.percentLabel:SetText(text)
end

local function Save_SellItem_Price(frame)
    local itemLocation= frame:GetItem()
    if itemLocation and itemLocation:IsValid() then
        local itemID= C_Item.GetItemID(itemLocation)
        if itemID  then
            local unitPrice= frame.PriceInput:GetAmount()
            if unitPrice and unitPrice>100000 then
                WoWTools_AuctionHouseMixin:Save().SellItemDefaultPrice[itemID]= unitPrice
            else
                WoWTools_AuctionHouseMixin:Save().SellItemDefaultPrice[itemID]=nil
            end
        end
    end
end


local function Init_PercentLabel()
    AuctionHouseFrame.CommoditiesSellFrame.percentLabel= WoWTools_LabelMixin:Create(AuctionHouseFrame.CommoditiesSellFrame, {size=22, justifyH='RIGHT'})
    AuctionHouseFrame.CommoditiesSellFrame.percentLabel:SetPoint('BOTTOMRIGHT', AuctionHouseFrame.CommoditiesSellList, 'TOP', -50,0)

    AuctionHouseFrame.CommoditiesSellFrame.vendorPriceLabel= WoWTools_LabelMixin:Create(AuctionHouseFrame.CommoditiesSellFrame, {size=12})
    AuctionHouseFrame.CommoditiesSellFrame.vendorPriceLabel:SetPoint('TOPRIGHT', AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.GoldBox, 'BOTTOMRIGHT',0,4)

    AuctionHouseFrame.ItemSellFrame.percentLabel= WoWTools_LabelMixin:Create(AuctionHouseFrame.ItemSellFrame, {size=22, justifyH='RIGHT'})
    AuctionHouseFrame.ItemSellFrame.percentLabel:SetPoint('BOTTOMRIGHT', AuctionHouseFrame.ItemSellList, 'TOP', -50,0)

    AuctionHouseFrame.ItemSellFrame.vendorPriceLabel= WoWTools_LabelMixin:Create(AuctionHouseFrame.ItemSellFrame, {size=12})
    AuctionHouseFrame.ItemSellFrame.vendorPriceLabel:SetPoint('TOPRIGHT', AuctionHouseFrame.ItemSellFrame.PriceInput.MoneyInputFrame.GoldBox, 'BOTTOMRIGHT',0,4)

    WoWTools_DataMixin:Hook(AuctionHouseFrame.CommoditiesSellFrame, 'UpdateTotalPrice', function(self)
        Update_Total_Price(self)
    end)
    WoWTools_DataMixin:Hook(AuctionHouseFrame.ItemSellFrame, 'UpdateTotalPrice', function(self)
        Update_Total_Price(self)
    end)


    AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.GoldBox:HookScript('OnTextChanged', function(_, userInput)
        if userInput then
            Save_SellItem_Price(AuctionHouseFrame.CommoditiesSellFrame)
        end
    end)
    AuctionHouseFrame.ItemSellFrame.PriceInput.MoneyInputFrame.GoldBox:HookScript('OnTextChanged', function(_, userInput)
        if userInput then
            Save_SellItem_Price(AuctionHouseFrame.ItemSellFrame)
        end
    end)

    AuctionHouseFrame.CommoditiesSellFrame.PriceInput.MoneyInputFrame.SilverBox:HookScript('OnTextChanged', function(_, userInput)
        if userInput then
            Save_SellItem_Price(AuctionHouseFrame.CommoditiesSellFrame)
        end
    end)
    AuctionHouseFrame.ItemSellFrame.PriceInput.MoneyInputFrame.SilverBox:HookScript('OnTextChanged', function(_, userInput)
        if userInput then
            Save_SellItem_Price(AuctionHouseFrame.ItemSellFrame)
        end
    end)

end


local function Init_MaxSellItemCheck()
    local MaxSellItemCheck, MaxSellItemCheck2
    MaxSellItemCheck= CreateFrame('CheckButton', nil, AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton, 'InterfaceOptionsCheckButtonTemplate')
    MaxSellItemCheck:SetPoint('LEFT', AuctionHouseFrame.CommoditiesSellFrame.QuantityInput.MaxButton, 'RIGHT')
    MaxSellItemCheck:SetSize(24,24)
    MaxSellItemCheck:SetChecked(WoWTools_AuctionHouseMixin:Save().isMaxSellItem)

    MaxSellItemCheck:SetScript('OnLeave', GameTooltip_Hide)
    MaxSellItemCheck:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_AuctionHouseMixin.addName)
        GameTooltip:AddDoubleLine(' ', WoWTools_L.AUCTION_HOUSE_MAX_QUANTITY_BUTTON)
        GameTooltip:Show()
    end)
    MaxSellItemCheck:SetScript('OnClick', function()
        WoWTools_AuctionHouseMixin:Save().isMaxSellItem= not WoWTools_AuctionHouseMixin:Save().isMaxSellItem and true or false
        MaxSellItemCheck2:SetChecked(WoWTools_AuctionHouseMixin:Save().isMaxSellItem)
    end)

    MaxSellItemCheck2= CreateFrame('CheckButton', nil, AuctionHouseFrame.ItemSellFrame.QuantityInput.MaxButton, 'InterfaceOptionsCheckButtonTemplate')
    MaxSellItemCheck2:SetPoint('LEFT', AuctionHouseFrame.ItemSellFrame.QuantityInput.MaxButton, 'RIGHT')
    MaxSellItemCheck2:SetSize(24,24)
    MaxSellItemCheck2:SetChecked(WoWTools_AuctionHouseMixin:Save().isMaxSellItem)

    MaxSellItemCheck2:SetScript('OnLeave', GameTooltip_Hide)
    MaxSellItemCheck2:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_AuctionHouseMixin.addName)
        GameTooltip:AddDoubleLine(' ', WoWTools_L.AUCTION_HOUSE_MAX_QUANTITY_BUTTON)
        GameTooltip:Show()
    end)
    MaxSellItemCheck2:SetScript('OnClick', function()
        WoWTools_AuctionHouseMixin:Save().isMaxSellItem= not WoWTools_AuctionHouseMixin:Save().isMaxSellItem and true or false
        MaxSellItemCheck:SetChecked(WoWTools_AuctionHouseMixin:Save().isMaxSellItem)
    end)
end


local function Init()
    if WoWTools_AuctionHouseMixin:Save().disabledSellPlus then
        return
    end

    Init_ShowCommoditiesButton()
    Init_NextItem()
    Init_PercentLabel()
    Init_MaxSellItemCheck()

    function AuctionHouseFrame.CommoditiesSellFrame:GetDefaultPrice()
        return GetDefaultPrice(self:GetItem())
    end
    function AuctionHouseFrame.ItemSellFrame:GetDefaultPrice()
        return GetDefaultPrice(self:GetItem())
    end



--Blizzard_AuctionHouseFrame.xml
    AuctionHouseFrame.CommoditiesSellList:ClearAllPoints()
    AuctionHouseFrame.CommoditiesSellList:SetSize(427, 442)
    AuctionHouseFrame.CommoditiesSellList:SetPoint('BOTTOMLEFT', AuctionHouseFrame.MoneyFrameBorder, 'TOPLEFT')
    AuctionHouseFrame.CommoditiesSellFrame:ClearAllPoints()
    AuctionHouseFrame.CommoditiesSellFrame:SetSize(363, 442)
    AuctionHouseFrame.CommoditiesSellFrame:SetPoint('TOPLEFT', AuctionHouseFrame.CommoditiesSellList, 'TOPRIGHT')
    AuctionHouseFrame.CommoditiesSellList.RefreshFrame.RefreshButton:ClearAllPoints()
    AuctionHouseFrame.CommoditiesSellList.RefreshFrame.RefreshButton:SetParent(AuctionHouseFrame.CommoditiesSellFrame.PostButton)
    AuctionHouseFrame.CommoditiesSellList.RefreshFrame.RefreshButton:SetPoint('LEFT', AuctionHouseFrame.CommoditiesSellFrame.PostButton, 'RIGHT')

    AuctionHouseFrame.ItemSellList:ClearAllPoints()
    AuctionHouseFrame.ItemSellList:SetSize(427, 442)
    AuctionHouseFrame.ItemSellList:SetPoint('BOTTOMLEFT', AuctionHouseFrame.MoneyFrameBorder, 'TOPLEFT')
    AuctionHouseFrame.ItemSellFrame:ClearAllPoints()
    AuctionHouseFrame.ItemSellFrame:SetSize(363, 442)
    AuctionHouseFrame.ItemSellFrame:SetPoint('TOPLEFT', AuctionHouseFrame.ItemSellList, 'TOPRIGHT')
    AuctionHouseFrame.ItemSellList.RefreshFrame.RefreshButton:ClearAllPoints()
    AuctionHouseFrame.ItemSellList.RefreshFrame.RefreshButton:SetParent(AuctionHouseFrame.ItemSellFrame.PostButton)
    AuctionHouseFrame.ItemSellList.RefreshFrame.RefreshButton:SetPoint('LEFT', AuctionHouseFrame.ItemSellFrame.PostButton, 'RIGHT')

    AuctionHouseFrame.CommoditiesSellList.RefreshFrame.TotalQuantity:ClearAllPoints()
    AuctionHouseFrame.CommoditiesSellList.RefreshFrame.TotalQuantity:SetPoint('BOTTOMRIGHT', AuctionHouseFrame.CommoditiesSellList, 'TOPRIGHT', -25, 0)

    AuctionHouseFrame.ItemSellList.RefreshFrame.TotalQuantity:ClearAllPoints()
    AuctionHouseFrame.ItemSellList.RefreshFrame.TotalQuantity:SetPoint('BOTTOMRIGHT', AuctionHouseFrame.ItemSellList, 'TOPRIGHT', -25, 0)

    C_Timer.After(1, function()
        AuctionHouseFrame:HookScript('OnShow', OnShowToSellFrame)
        OnShowToSellFrame()
    end)

   Init=function()end
end


function WoWTools_AuctionHouseMixin:Sell_Other()
    Init()
end