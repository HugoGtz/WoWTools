


local function Create_ItemTypeLabel(btn)
    if btn then
        btn.itemTypeLabel= btn.ContentsContainer:CreateFontString(nil, 'BORDER', 'WoWToolsFont')
        btn.itemTypeLabel:SetPoint('RIGHT', btn.ContentsContainer.Icon, 'LEFT')
        btn.itemTypeLabel:SetJustifyH('RIGHT')
    end
end


local function Set_ItemType(btn, itemInfo)
    itemInfo = itemInfo or {}

    local text
    local hex=''

    if itemInfo.speciesID and itemInfo.speciesID>0 then
        text= WoWTools_L.PET
        hex= '|cffedd100'

    elseif itemInfo.mountID and itemInfo.mountID>0 then
        text= WoWTools_L.MOUNT
        hex= '|cff00ccff'

    elseif itemInfo.transmogSetID and itemInfo.transmogSetID>0 then
        text= WoWTools_L.PERKS_PROGRAM_CART_COLLECTION_HEADER
        hex= '|cff00ff12'

    elseif itemInfo.itemID and itemInfo.itemID>0 then
        local itemID= itemInfo.itemID

        if C_ToyBox.GetToyInfo(itemID) then
            text= WoWTools_L.TOY
            hex= '|cffffffff'

        elseif C_Item.IsCosmeticItem(itemID) then
            local _, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID= C_Item.GetItemInfoInstant(itemID)
            if classID==Enum.ItemClass.Weapon then
                if itemSubType then
                    text= WoWTools_TextMixin:CN(itemSubType)
                elseif itemType then
                    text= WoWTools_TextMixin:CN(itemType)
                end
                if not C_Item.IsEquippableItem(itemID) then
                    hex= '|cff808080'
                end
            end
            text= text or _G[itemEquipLoc] or (WoWTools_L.ITEM_COSMETIC)

            if not hex and select(3, WoWTools_CollectionMixin:Item(itemID))==false then
                hex= '|cff808080'
            else
                hex= hex or '|cffffd200'
            end
            text= text:gsub(ICON_FILTER_ITEM..'$', '')
            text= text:gsub(WEAPON..'$', '')
            text= text:gsub(' $', '')
        end
    end

    btn.itemTypeLabel:SetText(text and hex..text or "")

    local color = WoWTools_ItemMixin:GetColor(itemInfo.quality, {itemID=itemInfo.itemID})
    btn.ContentsContainer.Label:SetTextColor(color:GetRGB())
end



function WoWTools_ItemMixin.Events:Blizzard_PerksProgram()
    WoWTools_DataMixin:Hook( PerksProgramProductButtonMixin, 'OnLoad', function(btn)
        if btn:HasSecretValues() then
            return
        end

        Create_ItemTypeLabel(btn)

        btn:SetScript('OnDoubleClick', function(b)
            b.ContentsContainer.CartToggleButton:Click()
        end)
    end)

    WoWTools_DataMixin:Hook( PerksProgramProductButtonMixin, 'SetItemInfo', function(btn, itemInfo)
        if not btn.itemTypeLabel then
            return
        end

        Set_ItemType(btn, itemInfo)

        WoWTools_ItemMixin:SetupInfo(btn.ContentsContainer, itemInfo.itemID and {
            itemID=itemInfo.itemID,
            itemLink=WoWTools_ItemMixin:GetLink(itemInfo.itemID),
            point=btn.ContentsContainer.Icon,
            size=12
        } or nil)
    end)
    Create_ItemTypeLabel(PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame.FrozenProductContainer.ProductButton)

    --WoWTools_DataMixin:Hook(PerksProgramFrozenProductButtonMixin, 'SetItemInfo', function(itemInfo)



    WoWTools_DataMixin:Hook(PerksProgramScrollItemDetailsMixin, 'InitItem', function(frame, data)
         WoWTools_ItemMixin:SetupInfo(frame, {itemID=data.itemID, point=frame.Icon})
    end)

end
