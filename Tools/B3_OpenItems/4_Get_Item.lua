

local function Save()
    return WoWToolsPlusSave['Tools_OpenItems']
end


local function Set_Att(self, bag, slot, icon, itemID)
    if self.isDisabled then
        return
    elseif not self:CanChangeAttribute()  then
        self.isInCombat=true
        return
    end


    local num
    if bag and slot then
            --self:SetAttribute('type1', 'macro')
            self:SetAttribute("macrotext1", '/use '..bag..' '..slot)
            --self:SetAttribute('target-item', nil)


        num = C_Item.GetItemCount(itemID)
        num= num~=1 and num or ''
        self:SetShown(true)
        self:SetBagAndSlot(bag, slot)

    else
        --self:SetAttribute('type1', nil)
        --self:SetAttribute('item1', nil)
        --self:SetAttribute('spell1', nil)
        self:SetAttribute('macrotext1', nil)
        --self:SetAttribute('target-item', nil)
        self:Clear()
    end




    self.count:SetText(num or '')

    if icon then
        self.texture:SetTexture(icon)
    else
        self.texture:SetAtlas('BonusLoot-Chest')
    end
    self.texture:SetAlpha(icon and 1 or 0.3)

    self:set_key(not bag or not slot)
end


local function Get_ValeItem(bag, slot)
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if not info
        or not info.itemID
        or not info.hyperlink
        or info.isLocked
        or not info.iconFileID
        or (Save().no[info.itemID] and not Save().use[info.itemID])
    then
        return
    end




    local itemMinLevel, _, _, _, _, _, _, classID, subclassID= select(5, C_Item.GetItemInfo(info.itemID))

    if classID==Enum.ItemClass.Key
        or classID==Enum.ItemClass.Gem
        or classID==Enum.ItemClass.ItemEnhancement
    then
        return
    end

    local duration, enable = select(2, C_Container.GetContainerItemCooldown(bag, slot))

    if duration and duration>2 and enable~=0 then
        return
    end


    local isWQ= classID==Enum.ItemClass.Weapon or classID==Enum.ItemClass.Armor

    if itemMinLevel and itemMinLevel > WoWTools_DataMixin.Player.Level
        and not C_Item.IsItemBindToAccount(info.hyperlink)
        and not C_Item.IsItemBindToAccountUntilEquip(info.hyperlink)
        and not isWQ
    then
        return
    end



    if Save().use[info.itemID] then
        if Save().use[info.itemID]<=info.stackCount then
            return info
        end

    elseif C_Item.IsCurioItem(info.hyperlink) then
        local dateInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=info.hyperlink, text={SPELL_FAILED_CUSTOM_ERROR_1042}, onlyText=true})
        if not dateInfo.text[SPELL_FAILED_CUSTOM_ERROR_1042] then
            return info
        end

    elseif C_Item.IsCosmeticItem(info.hyperlink) or isWQ then-- itemEquipLoc and _G[itemEquipLoc] then
        if Save().mago then--and not C_Item.IsCosmeticItem(info.itemID) then --and info.quality then
            local isCollected, isSelf= select(2, WoWTools_CollectionMixin:Item(info.hyperlink, nil, nil, true))

            --No equipar objetos sin ligar (BoE): se ligarían y perderían su valor
            if isCollected==false and (isSelf or isWQ) and info.isBound then
                info.IsEquipItem= true

                return info
            end
        end

    else

        local dateInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=info.hyperlink, red=true, text={LOCKED}})
        if dateInfo.red then-- or not C_PlayerInfo.CanUseItem(info.itemID) then
            return
        end

        if info.hasLoot then
            if Save().open then
                if dateInfo.text[LOCKED] and WoWTools_DataMixin.Player.Class=='ROGUE' then--DZ
                    return info
                else--if not dateInfo.text[LOCKED] then
                    return info
                end
            end
        elseif classID==Enum.ItemClass.Recipe then
            if Save().ski then
                if subclassID == 0 then
                    if C_Item.GetItemSpell(info.hyperlink) then
                        return info
                    end
                else
                    return info
                end
            end
        elseif classID==Enum.ItemClass.Miscellaneous and subclassID==Enum.ItemMiscellaneousSubclass.Mount then
            if Save().mount then
                local mountID = C_MountJournal.GetMountFromItem(info.itemID)
                if mountID then
                    local isCollected =select(11, C_MountJournal.GetMountInfoByID(mountID))
                    if isCollected==false then
                        return info
                    end
                end
            end
        elseif C_ToyBox.GetToyInfo(info.itemID) then
            if Save().toy and not PlayerHasToy(info.itemID) then
                return info
            end

        elseif info.hyperlink:find('Hbattlepet:(%d+)') or (classID==Enum.ItemClass.Miscellaneous and subclassID==Enum.ItemMiscellaneousSubclass.CompanionPet) then
            if Save().pet then
                local speciesID = info.hyperlink:match('Hbattlepet:(%d+)') or select(13, C_PetJournal.GetPetInfoByItemID(info.itemID))
                if speciesID then
                    local numCollected, limit= C_PetJournal.GetNumCollectedInfo(speciesID)
                    if numCollected and limit and numCollected <  limit then
                        return info
                    end
                end
            end

        elseif Save().alt
            and C_Item.IsUsableItem(info.hyperlink)
            and (
                (classID~=Enum.ItemClass.Questitem
                    and (classID==Enum.ItemClass.Consumable and subclassID==Enum.ItemConsumableSubclass.Other or classID~=Enum.ItemClass.Consumable)
                )
                or (classID==Enum.ItemClass.Miscellaneous and subclassID==Enum.ItemMiscellaneousSubclass.Other)
            )
        then
            local spell= select(2, C_Item.GetItemSpell(info.hyperlink))
            --no proponer objetos ligados a la cuenta/banda (fichas de reputación o conocimiento): pueden gastarse en el personaje equivocado
            local bindType= select(14, C_Item.GetItemInfo(info.hyperlink))
            local isAccount= bindType and Enum.ItemBind and (
                bindType==Enum.ItemBind.ToWoWAccount
                or bindType==Enum.ItemBind.ToBnetAccount
                or bindType==Enum.ItemBind.ToBnetAccountUntilEquipped
            )
            if spell and not isAccount and not C_Item.IsAnimaItemByID(info.hyperlink) then-- or C_Item.IsArtifactPowerItem(info.hyperlink)) then
                if info.itemID==207002 then
                    if not WoWTools_AuraMixin:Get('player', {[415603]=true}) then
                        return info
                    end
                else
                    return info
                end
            end
        end
    end
end


local function Get_Items(self)
    if not self:CanChangeAttribute() then
        self.isInCombat=true
        return
    end

    self.IsEquipItem=nil
    self:Clear()

    local bagMax= Save().reagent and (NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES ) or NUM_BAG_FRAMES
    for bag= Enum.BagIndex.Backpack, bagMax do--Constants.InventoryConstants.NumBagSlots
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info= Get_ValeItem(bag, slot)
            if info then
                self.IsEquipItem= info.IsEquipItem

                return Set_Att(self, bag, slot, info.iconFileID, info.itemID)
            end
        end
    end

    Set_Att(self)
    self:set_key(true)
end


function WoWTools_OpenItemMixin:Get_Item()
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('OpenItems')
    if btn then
        Get_Items(btn)
    end
end

