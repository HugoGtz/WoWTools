--ItemLocation.lua

WoWTools_ItemLocationMixin={
    itemLocation={},
}




function WoWTools_ItemLocationMixin:Clear()
    self.itemLocation={}
end
function WoWTools_ItemLocationMixin:HasAnyLocation()
	return self:IsEquipmentSlot() or self:IsBagAndSlot();
end
function WoWTools_ItemLocationMixin:IsValid()
	if self:HasAnyLocation() then
		return C_Item.DoesItemExist(self.itemLocation)
	end
end

function WoWTools_ItemLocationMixin:SetBagAndSlot(bagID, slotIndex)
	self:Clear();
	self.itemLocation.bagID = bagID;
	self.itemLocation.slotIndex = slotIndex;
end
function WoWTools_ItemLocationMixin:GetBagAndSlot()
	return self.itemLocation.bagID, self.itemLocation.slotIndex
end
function WoWTools_ItemLocationMixin:IsBagAndSlot()
	return self.itemLocation.bagID ~= nil and self.itemLocation.slotIndex ~= nil;
end



function WoWTools_ItemLocationMixin:GetEquipmentSlot()
	return self.itemLocation.equipmentSlotIndex;
end
function WoWTools_ItemLocationMixin:IsEquipmentSlot()
	return self.itemLocation.equipmentSlotIndex ~= nil;
end





function WoWTools_ItemLocationMixin:GetItemID()
	if self:IsValid() then
		if self:IsBagAndSlot() then
			return C_Container.GetContainerItemID(self:GetBagAndSlot())
		elseif self:IsEquipmentSlot() then
			return GetInventoryItemID('player', self.itemLocation.equipmentSlotIndex)
		end
	end
end

function WoWTools_ItemLocationMixin:GetItemLink()
	if self:IsValid() then
		if self:IsBagAndSlot() then
			return C_Container.GetContainerItemLink(self:GetBagAndSlot())
		elseif self:IsEquipmentSlot() then
			return GetInventoryItemLink('player', self.itemLocation.equipmentSlotIndex)
		end
	end
end

function WoWTools_ItemLocationMixin:GetItemCount()
	local count
	if self:IsValid() then
		if self:IsBagAndSlot() then
			local itemID= self:GetItemID()
			if itemID then
				count= C_Item.GetItemCount(itemID, true, false, true, true)
			end
		elseif self:IsEquipmentSlot() then
			count= GetInventoryItemCount('player', self.itemLocation.equipmentSlotIndex) or 0
		end
	end
	count= count or 0

	local text= count>0 and ' x'..count or ' |cff626262x0|r'
	return count or 0, text
end

function WoWTools_ItemLocationMixin:GetItemCooldown()
	if self:IsValid() then
		if self:IsBagAndSlot() then
			return C_Container.GetContainerItemCooldown(self:GetBagAndSlot())
		elseif self:IsEquipmentSlot() then

			return GetInventoryItemCooldown('player', self.itemLocation.equipmentSlotIndex)
		end
	end
end

function WoWTools_ItemLocationMixin:GetItemQuality()
	if self:IsValid() then
		if self:IsBagAndSlot() then
			local containerInfo=C_Container.GetContainerItemInfo(self:GetBagAndSlot())
			if containerInfo then
				return containerInfo.quality
			end
		elseif self:IsEquipmentSlot() then
			return GetInventoryItemQuality('player', self.itemLocation.equipmentSlotIndex)
		end
	end
end


function WoWTools_ItemLocationMixin:GetItemName(isText)
	if self:IsValid() then
		local itemID= self:GetItemID()
		local itemName= itemID and C_Item.GetItemNameByID(itemID)
		if itemName then
			return itemName, isText and WoWTools_ItemMixin:GetName(itemID)
		end
	end
end


