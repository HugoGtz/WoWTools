
WoWTools_AuctionHouseMixin= {}
--itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey [, restrictQualityToFilter])
function WoWTools_AuctionHouseMixin:GetItemLink(rowData)
    local itemKey= rowData and rowData.itemKey

    if not itemKey then
        return
    end

    local itemLink= rowData.itemLink
    local itemID= rowData.itemID or itemKey.itemID

    if not itemLink and rowData.auctionID then
        local priceInfo = C_AuctionHouse.GetAuctionInfoByID(rowData.auctionID)
        if priceInfo then
            itemLink= priceInfo.itemLink or priceInfo.battlePetLink
        end
    end

    if not itemLink then
        local data= C_TooltipInfo.GetItemKey(itemKey.itemID, itemKey.itemLevel, itemKey.itemSuffix, C_AuctionHouse.GetItemKeyRequiredLevel(itemKey))
        if data then
            itemLink= data.hyperlink
        end
    end


    local battlePetSpeciesID= rowData.battlePetSpeciesID or itemKey.battlePetSpeciesID
    if battlePetSpeciesID and battlePetSpeciesID<=0 then
        battlePetSpeciesID= nil
    end

    return itemLink, itemID, battlePetSpeciesID
end

function WoWTools_AuctionHouseMixin:GetDisplayMode()
    local displayMode= AuctionHouseFrame:GetDisplayMode()
    return
        displayMode==AuctionHouseFrameDisplayMode.CommoditiesSell,
        displayMode==AuctionHouseFrameDisplayMode.ItemSell
end

function WoWTools_AuctionHouseMixin:GetItemSellStatus(bag, slot, isCheckHideItem)
    local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot);
    if itemLocation and itemLocation:IsValid() and C_AuctionHouse.IsSellItemValid(itemLocation, false) then--ContainerFrame.lua
        local itemCommodityStatus= C_AuctionHouse.GetItemCommodityStatus(itemLocation) or 0
        if itemCommodityStatus>0 then
            local info = C_Container.GetContainerItemInfo(bag, slot) or {}
            if
                info.itemID
                and info.hyperlink
                and info.quality>= WoWTools_AuctionHouseMixin:Save().sellItemQualiy
                and (isCheckHideItem
                    and (
                        (info.itemID==82800 and not WoWTools_AuctionHouseMixin:Save().hideSellPet[info.hyperlink:match('Hbattlepet:(%d+)')])
                        or (info.itemID~=82800 and not WoWTools_AuctionHouseMixin:Save().hideSellItem[info.itemID])
                    )
                    or not isCheckHideItem
                )
            then
                return itemLocation, itemCommodityStatus, info
            end
        end
    end
end

function WoWTools_AuctionHouseMixin:SetPostNextSellItem(onlyFind)
    if onlyFind then
        for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do--Constants.InventoryConstants.NumBagSlots
            for slot=1, C_Container.GetContainerNumSlots(bag) do
                local itemLocation, itemCommodityStatus= self:GetItemSellStatus(bag, slot, true)
                if itemLocation
                    and (
                        (itemCommodityStatus==Enum.ItemCommodityStatus.Commodity)
                        or (itemCommodityStatus==Enum.ItemCommodityStatus.Item)
                    )
                then
                    return itemCommodityStatus
                end
            end
        end
        return false
    end


    local isCommoditiesSellFrame, isItemSellFrame= self:GetDisplayMode()

    if not C_AuctionHouse.IsThrottledMessageSystemReady()
        or (isCommoditiesSellFrame and AuctionHouseFrame.CommoditiesSellFrame:GetItem())
        or (isItemSellFrame and AuctionHouseFrame.ItemSellFrame:GetItem())
        or not AuctionHouseFrame:IsShown()
    then
        return
    end

    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do--Constants.InventoryConstants.NumBagSlots
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local itemLocation, itemCommodityStatus= self:GetItemSellStatus(bag, slot, true)
            if itemLocation
                and (
                    (itemCommodityStatus==Enum.ItemCommodityStatus.Commodity and isCommoditiesSellFrame)
                    or (itemCommodityStatus==Enum.ItemCommodityStatus.Item and isItemSellFrame)
                )
            then
                AuctionHouseFrame:SetPostItem(itemLocation)--ContainerFrame.lua
                return
            end
        end
    end
end

