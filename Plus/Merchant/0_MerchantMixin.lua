WoWTools_MerchantMixin={}

local function Save()
    return WoWToolsPlusSave['Plus_SellBuy']
end

function WoWTools_MerchantMixin:Update_MerchantFrame()
    if not MerchantFrame:IsShown() then
        return
    end
    if MerchantFrame.selectedTab == 2 then
        WoWTools_DataMixin:Call('MerchantFrame_UpdateBuybackInfo')
    else
        WoWTools_DataMixin:Call('MerchantFrame_UpdateMerchantInfo')
    end
end

function WoWTools_MerchantMixin:CheckSellItem(itemID, itemLink, quality, isBound)
    if not itemID or Save().disabled or WoWToolsPlusPlayerDate['SellBuyItems'].noSell[itemID] then
        return
    end

    if WoWToolsPlusPlayerDate['SellBuyItems'].sell[itemID] and not Save().notSellCustom then
        return WoWTools_L.CUSTOM
    end

    --Vender botín de jefe es opcional (sellBoss, desactivado por defecto) y nunca vende apariencias sin coleccionar
    if not PlayerIsTimerunning() and Save().sellBoss and itemLink then
        local level= Save().bossItems[itemID]
        if level and select(2, WoWTools_CollectionMixin:Item(itemID, nil, nil))~=false then
            local itemLevel= WoWTools_ItemMixin:GetItemLevel(itemLink) or select(4, C_Item.GetItemInfo(itemLink))
            if level== itemLevel  then
                return WoWTools_L.BOSS
            end
        end
    end

    if quality==0 then
        if WoWTools_CollectionMixin:GetPet9Item(itemID, true) then--宠物兑换, wow9.0
            return WoWTools_L.PET

        elseif not Save().notSellJunk then--垃圾
            if isBound==true then
                return WoWTools_L.BAG_FILTER_JUNK
            else
                local classID, subclassID = select(6, C_Item.GetItemInfoInstant(itemID))
                if (classID==2 or classID==4) and subclassID~=0 then
                    local isCollected = select(2, WoWTools_CollectionMixin:Item(itemID, nil, nil))--物品是否收集
                    if isCollected==false then
                        return
                    end
                end
                return WoWTools_L.BAG_FILTER_JUNK
            end
        end
    end
end
