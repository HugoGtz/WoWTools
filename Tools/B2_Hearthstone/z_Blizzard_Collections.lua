
local function SaveItems()
    return WoWToolsPlusPlayerDate['HearthstoneItems']
end







local function Remove_Toy(itemID)
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('Hearthstone')
    if not btn then
        return
    end

    SaveItems()[itemID]=nil
    local isSelect, isLock= btn:Check_Random_Value(itemID)
    if isLock or isSelect then
        if isSelect then
            btn:Set_SelectValue_Random(nil)
        end
        if isLock then
            WoWTools_HearthstoneMixin:Save().lockedToy=nil
            btn:Set_LockedValue_Random(nil)
        end
    elseif btn.itemID==itemID then
        btn:Init_Random(WoWTools_HearthstoneMixin:Save().lockedToy)
    end
end



local function Add_Remove_Toy(itemID)
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('Hearthstone')
    if itemID and btn then
        if SaveItems()[itemID] then
            Remove_Toy(itemID)
        else
            SaveItems()[itemID]= true
            if btn then
                btn:Init_Random(WoWTools_HearthstoneMixin:Save().lockedToy)
            end
        end
    end
end









local function Create_Button(btn)
    btn.hearthstone= WoWTools_ButtonMixin:Cbtn(btn,{size=16, texture=134414})
    btn.hearthstone:SetPoint('TOPLEFT',btn.name,'BOTTOMLEFT')

    function btn.hearthstone:get_itemID()
        return self:GetParent().itemID
    end
    function btn.hearthstone:set_alpha()
        self:SetAlpha(SaveItems()[self:get_itemID()] and 1 or 0.1)
    end
    function btn.hearthstone:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_HearthstoneMixin.addName)
        GameTooltip:AddLine(' ')
        local itemID=self:get_itemID()
        local icon= select(5, C_Item.GetItemInfoInstant(itemID))
        GameTooltip:AddDoubleLine(
            (icon and '|T'..icon..':0|t' or '')..(itemID and C_ToyBox.GetToyLink(itemID) or itemID),
            WoWTools_TextMixin:GetEnabeleDisable(SaveItems()[itemID])..WoWTools_DataMixin.Icon.left
        )
        GameTooltip:AddDoubleLine(WoWTools_L.SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        self:SetAlpha(1)
    end
    btn.hearthstone:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            Add_Remove_Toy(self:get_itemID())
            self:set_tooltips()
            self:set_alpha()
        else
            MenuUtil.CreateContextMenu(self, function(...)
                WoWTools_HearthstoneMixin:Init_Menu_Toy(...)
            end)
        end
    end)
    btn.hearthstone:SetScript('OnLeave', function(self) GameTooltip:Hide() self:set_alpha() end)
    btn.hearthstone:SetScript('OnEnter', function(self) self:set_tooltips() end)
end







local Init= WoWTools_Once(function()
    WoWTools_DataMixin:Hook('ToySpellButton_UpdateButton', function(btn)
        if not btn.hearthstone then
            Create_Button(btn)
        end
        btn.hearthstone:set_alpha()
    end)
end)





function WoWTools_HearthstoneMixin:Blizzard_Collections()
    Init()
end

function WoWTools_HearthstoneMixin:Remove_Toy(itemID)
    Remove_Toy(itemID)
end