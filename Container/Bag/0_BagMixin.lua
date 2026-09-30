WoWTools_BagMixin={}


function WoWTools_BagMixin:Ceca(itemID, tab)
    tab= tab or {}
    local isKeystone= tab.isKeystone
    local check= tab.check
    local findAll= tab.findAll
    for bagID= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + (findAll and NUM_REAGENTBAG_FRAMES or 0) do--Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES ,Constants.InventoryConstants.NumBagSlots
        for slotID=1, C_Container.GetContainerNumSlots(bagID) do
            local info = C_Container.GetContainerItemInfo(bagID, slotID)
            if info
                and info.itemID
                and info.hyperlink
                and (
                    isKeystone and C_Item.IsItemKeystoneByID(info.itemID)
                    or itemID==info.itemID
                    or (check and check(info, bagID, slotID))
                )
            then
                return info, bagID, slotID
            end
        end
    end
end


function WoWTools_BagMixin:Find(find, tab)

    if not IsBagOpen(Enum.BagIndex.Backpack) and not IsBagOpen(NUM_TOTAL_EQUIPPED_BAG_SLOTS) then
        return
    end

    if find~=true or not tab then
        C_Container.SetItemSearch('')
        return
    end

    local itemName, itemLink
    if tab.itemName then
        itemName= tab.itemName

    elseif tab.itemLink then--itemLink
        itemLink= tab.itemLink

    elseif tab.itemID then--itemID
        itemName= C_Item.GetItemNameByID(tab.itemLink or tab.itemID)

    elseif tab.itemLocation and tab.itemLocation:IsValid() then--itemLocation
        itemName= C_Item.GetItemName(tab.itemLocation)

    elseif tab.merchantIndex then
        local info = C_MerchantFrame.GetItemInfo(tab.merchantIndex)
        if info then
            itemName= info.name
        end

    elseif tab.BuybackIndex then
        itemName= GetBuybackItemInfo(tab.BuybackIndex)

    elseif tab.itemKey then--itemKey
        local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(tab.itemKey) or {}
        itemName= itemKeyInfo.itemName

    elseif tab.bag then
        itemLink= C_Container.GetContainerItemLink(tab.bag.bag, tab.bag.slot)

    elseif tab.guidBank then
        itemLink= GetGuildBankItemLink(tab.guidBank.tab, tab.guidBank.slot)
    elseif tab.lootIndex then
        local _, lootName, _, currencyID= GetLootSlotInfo(tab.lootIndex)
        itemName= not currencyID and lootName
    end

    if itemLink then
        itemName= C_Item.GetItemNameByID(itemLink) or itemLink:match('|H.-%[(.-)]|h')
    end
    if itemName then
        C_Container.SetItemSearch(itemName)
    end
end


function WoWTools_BagMixin:GetFree(isRegentBag)

    local free, all, regentsFree= 0, 0, 0--CalculateTotalNumberOfFreeBagSlots() MainMenuBarBagButtons.lua

    local num= NUM_BAG_FRAMES+ (isRegentBag and NUM_REAGENTBAG_FRAMES or 0)

    for i = BACKPACK_CONTAINER, num do
        local freeBag= C_Container.GetContainerNumFreeSlots(i) or 0
        free= free+ freeBag
        all= all+ (C_Container.GetContainerNumSlots(i) or 0)
        if isRegentBag and i==num then
            regentsFree= freeBag
        end
    end
    return free, all, regentsFree
end


function WoWTools_BagMixin:GetItems(checkAllBag, onlyItem, onlyRegents, checkBagFunc)
    local Tabs={}

    local context= ItemButtonUtil.GetItemContext()
    local num= NUM_BAG_FRAMES+ ((checkAllBag or onlyRegents) and NUM_REAGENTBAG_FRAMES or 0)
    local isCraftingReagent

    for bag= BACKPACK_CONTAINER, num do--0-5

        for slot=1, C_Container.GetContainerNumSlots(bag) do

            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID
                and (not context or ItemButtonUtil.ItemContextMatchResult.Match == ItemButtonUtil.GetItemContextMatchResultForItem(ItemLocation:CreateFromBagAndSlot(bag, slot)))
                and (not checkBagFunc or checkBagFunc(bag, slot, info))
            then

               WoWTools_DataMixin:Load(info.itemID, 'item')
                if onlyItem or onlyRegents then

                    isCraftingReagent= select(17, C_Item.GetItemInfo(info.itemID))

                    if onlyRegents and isCraftingReagent or (onlyItem and isCraftingReagent==false) then
                        table.insert(Tabs, 1, {
                            info=info,
                            bag=bag,
                            slot=slot,
                            isRegent=isCraftingReagent,
                        })
                    end
                else
                    table.insert(Tabs, 1, {
                        info=info,
                        bag=bag,
                        slot=slot,
                    })
                end
            end
        end
    end
    return Tabs
end


function WoWTools_BagMixin:OpenBag(bagID, isBank)
    if bagID then
        if not IsBagOpen(bagID) then
            ToggleBag(bagID)
        end
    else
        --Desde 11.2 el banco va por pestañas y ya no hay bolsas de banco (los IDs 6-12 son pestañas):
        --isBank abre las bolsas del jugador
        do
            for i=BACKPACK_CONTAINER, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
                if not IsBagOpen(i) then
                    ToggleBag(i)
                end
            end
        end
    end
end

function WoWTools_BagMixin:CloseBag(bagID, isBank)
    if bagID then
        if IsBagOpen(bagID) then
            CloseBag(bagID)
        end
    else
        do--ver OpenBag: ya no hay bolsas de banco
            for i=BACKPACK_CONTAINER, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
                if IsBagOpen(i) then
                    CloseBag(i)
                end
            end
        end
    end
end




