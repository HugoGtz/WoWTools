local P_Save= {
    items={
        [210715]=true,
        [216640]=true,
        [211106]=true,
        [211108]=true,

        [210714]=true,
        [216644]=true,
        [211123]=true,
        [211102]=true,

        [210681]=true,
        [216643]=true,
        [211107]=true,
        [211110]=true,

        [220371]=true,
        [220372]=true,
        [220374]=true,
        [220373]=true,
    },
}

local MaxNumeri= 9
local addName

local function Save()
    return WoWToolsPlusSave['Other_ScrappingMachine']
end


local function get_num_items()
    local n= 0
    if ScrappingMachineFrame then
        for btn in ScrappingMachineFrame.ItemSlots.scrapButtons:EnumerateActive() do
            if btn and btn.itemLink then
                n=n +1
            end
        end
    end
    return n
end


local function can_scrap_item(bag, slot, onlyEquip, classID)
    if not ScrappingMachineFrame:IsShown() then
        return
    end

    local itemLocation= ItemLocation:CreateFromBagAndSlot(bag, slot)

    if itemLocation and itemLocation:IsValid() and C_Item.CanScrapItem(itemLocation) then
        local itemID= C_Item.GetItemID(itemLocation)
        if Save().items[itemID] then
            return
        end

        if not onlyEquip and not classID then
            return itemLocation
        end

        local itemLink= C_Item.GetItemLink(itemLocation)
        if itemLink then
            local itemEquipLoc, _, classID2 = select(4, C_Item.GetItemInfoInstant(itemLink))
            if onlyEquip then
                local invSlot= WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)
                if invSlot then
                    return itemLocation
                end
            elseif classID then
                if classID== classID2 then
                    return itemLocation
                end
            end
        end
    end
end


local ButtonList={
    {
        name='AddGem',
        texture=135998,
        classID=3,
        tooltip=WoWTools_L['ADD+AUCTION_CATEGORY_GEMS'],
        click=function()
            local free= MaxNumeri- get_num_items()
            if free==0 or InCombatLockdown() then
                return
            end
            for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+NUM_REAGENTBAG_FRAMES do
                for slot=1, C_Container.GetContainerNumSlots(bag) do
                    if can_scrap_item(bag, slot, nil, 3) then
                        C_Container.UseContainerItem(bag, slot)
                        free= free-1
                        if free==0 then
                            return
                        end
                    end
                end
            end
        end
    },{
        name='AddItem',
        texture=135995,
        tooltip=WoWTools_L['ADD+BAG_FILTER_EQUIPMENT'],
        click=function()
            local free= MaxNumeri-get_num_items()
            if free==0 or InCombatLockdown() then
                return
            end
            for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+NUM_REAGENTBAG_FRAMES do
                for slot=1, C_Container.GetContainerNumSlots(bag) do
                    if can_scrap_item(bag, slot, true, nil) then
                        C_Container.UseContainerItem(bag, slot)
                        free= free-1
                        if free<=0 then
                            return
                        end
                    end
                end
            end
        end
    },
    {
        name='ClearItem',
        atlas='bags-button-autosort-up',
        tooltip=(WoWTools_L.CLEAR_ALL),
        click=function() C_ScrappingMachineUI.RemoveAllScrapItems() end
    },{
        name='AddAll',
        atlas='communities-chat-icon-plus',
        tooltip=WoWTools_L['ADD+ALL'],
        click=function()
            local free= MaxNumeri-get_num_items()
            if free==0 or InCombatLockdown() then
                return
            end
            for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+NUM_REAGENTBAG_FRAMES do
                for slot=1, C_Container.GetContainerNumSlots(bag) do
                    if can_scrap_item(bag, slot, nil, nil) then
                        C_Container.UseContainerItem(bag, slot)
                        free= free-1
                        if free==0 then
                            return
                        end
                    end
                end
            end
        end
    },
}


local function Init_SubItem_Menu(self, sub, items)
    local sub2
    for itemID in pairs(items) do
        sub2=sub:CreateCheckbox(
            WoWTools_ItemMixin:GetName(itemID),
        function(data)
            return Save().items[data.itemID]
        end, function(data)
            Save().items[data.itemID]= not Save().items[data.itemID] and true or nil
            self:settings()
        end, {itemID=itemID, tooltip=WoWTools_L['Tip.Scrapping.ExcludeItem']})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)
end


local function Init_Menu(self, root)
    local sub
    local tab={}

    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+NUM_REAGENTBAG_FRAMES do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local itemLocation= can_scrap_item(bag, slot, nil, nil)
            local itemLink= itemLocation and C_Item.GetItemLink(itemLocation)
            if itemLink then
                local itemID, _, _, _, _, classID= C_Item.GetItemInfoInstant(itemLink)
                if itemID then
                    tab[classID]=tab[classID] or {}
                    tab[classID][itemID]=true-- '|T'..(icon or 0)..':0|t'--{icon=icon, itemLink=itemLink}
                end
            end
        end
    end

    for classID, info in pairs(tab) do
        sub=root:CreateButton(
            '|cff606060'..classID..'|r '..(WoWTools_TextMixin:CN(C_Item.GetItemClassInfo(classID)) or ''),
        function()
            return MenuResponse.Open
        end)

        Init_SubItem_Menu(self, sub, info)
    end

    root:CreateDivider()
    sub=root:CreateButton(
        (WoWTools_L.DISABLE)
        ..'|cnGREEN_FONT_COLOR:#'..self.Text:GetText(),
    function()
        return MenuResponse.Open
    end)

    Init_SubItem_Menu(self, sub, Save().items)
    sub:CreateDivider()
    sub=sub:CreateButton(
        WoWTools_L.CLEAR_ALL,
    function()
        StaticPopup_Show('WoWTools_OK',
        WoWTools_L.CLEAR_ALL,
        nil,
        {SetValue=function()
            Save().items={}
        end})
        return MenuResponse.Open
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Scrapping.ClearExcluded'])


    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {
    name=addName,
    category=WoWTools_OtherMixin.Category
    })
end


local function Init_Button()
    local ItemsButton= CreateFrame('Button', 'WoWToolsScrappingItemButton', ScrappingMachineFrame, 'WoWToolsButtonTemplate')--  WoWTools_ButtonMixin:Cbtn(ScrappingMachineFrame, {size=23})

    ItemsButton.Text= WoWTools_LabelMixin:Create(ItemsButton)
    ItemsButton.Text:SetPoint('CENTER')
    ItemsButton:SetPoint('TOPLEFT', ScrappingMachineFrame.ItemSlots, 'TOPRIGHT', 12, 0)

    function ItemsButton:get_num()
        return CountTable(Save().items or {})
    end
    function ItemsButton:settings()
        local num= self:get_num()
        self.Text:SetText(num)
        if num==0 then
            self.Text:SetTextColor(0.62, 0.62, 0.62)
        else
            self.Text:SetTextColor(1,0,0)
        end
        self:SetNormalAtlas('talents-node-choiceflyout-circle-red')
    end
    function ItemsButton:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()

        local infoType, _, itemLink= GetCursorInfo()
        if infoType == "item" and itemLink then
            local texture= select(5, C_Item.GetItemInfoInstant(itemLink))
            if texture then
                self:SetNormalTexture(texture)
                GameTooltip:SetHyperlink(itemLink)
                GameTooltip:Show()
                return
            end
        end

        GameTooltip:AddDoubleLine(
            (WoWTools_L.DISABLE)
            ..'|A:talents-button-reset:0:0|a'
            ..(WoWTools_L['SELF_CAST_AUTO+ADD']),
            '|cnGREEN_FONT_COLOR:#'..self.Text:GetText()
        )
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.Icon.left..(WoWTools_L['DRAG_MODEL+ITEMS']),
            (WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL)..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:Show()
    end
    ItemsButton:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:settings()
    end)
    ItemsButton:SetScript('OnEnter', function(self)
        self:set_tooltips()
    end)
    ItemsButton:SetScript('OnMouseDown', function(self)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID then
            Save().items[itemID]= not Save().items[itemID] and true or nil
            WoWTools_Print(addName..WoWTools_DataMixin.Icon.icon2,
                Save().items[itemID] and '|cnGREEN_FONT_COLOR:'..(WoWTools_L.ADD)..'|r'
                    or ('|cnWARNING_FONT_COLOR:'..(WoWTools_L.REMOVE)..'|r'),
                itemLink or itemID
            )
            ClearCursor()
            self:settings()
            self:set_tooltips()
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)
    ItemsButton:settings()




    for index, info in pairs(ButtonList) do
        local btn= CreateFrame('Button', 'WoWToolsScrapping'..info.name..'Button', ScrappingMachineFrame, 'WoWToolsButtonTemplate')

        if info.atlas then
            btn:SetNormalAtlas(info.atlas)
        elseif info.texture then
            btn:SetNormalTexture(info.texture)
        end

        btn.tooltip= (info.texture and format('|T%d:0|t', info.texture) or format('|A:%s:0:0|a', info.atlas))..info.tooltip
        btn.click= info.click

        if info.name=='AddAll' then
            btn:SetPoint('LEFT', ScrappingMachineFrame.ScrapButton, 'RIGHT', 2, 0)
        elseif info.name=='ClearItem' then
            btn:SetPoint('LEFT', ScrappingMachineFrame.ScrapButton, 'RIGHT', 30, 0)
        else
            btn:SetPoint('TOP', ItemsButton, 'BOTTOM', 0, -(index*23))
        end
        btn:SetScript('OnLeave', function()
            GameTooltip:Hide()
        end)
        btn:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip_SetTitle(GameTooltip, self.tooltip..WoWTools_DataMixin.Icon.icon2)
            GameTooltip:Show()
        end)

        btn:SetScript('OnClick', function(self)
            local spellID= C_ScrappingMachineUI.GetScrapSpellID()
            if spellID and C_Spell.IsCurrentSpell(spellID) then
                return
            end
            self:click()
        end)
    end

    ButtonList=nil

    WoWTools_DataMixin:Hook(ScrappingMachineFrame, 'UpdateScrapButtonState', function()
        _G['WoWToolsScrappingClearItemButton']:SetAlpha(C_ScrappingMachineUI.HasScrappableItems() and 1 or 0.5)
        _G['WoWToolsScrappingAddAllButton']:SetAlpha(MaxNumeri> get_num_items() and 1 or 0.5)
    end)

    Init_Button=function()end
end


local function Init()
    ScrappingMachineFrame.ScrapButton:HookScript('OnLeave', GameTooltip_Hide)
    ScrappingMachineFrame.ScrapButton:HookScript('OnEnter', function(self)
        local spellID= C_ScrappingMachineUI.GetScrapSpellID()
        if not spellID then
            return
        end
        GameTooltip:SetOwner(self:GetParent(), "ANCHOR_BOTTOMRIGHT")
        GameTooltip:ClearLines()
        GameTooltip:SetSpellByID(spellID)
        GameTooltip:Show()
    end)

    for btn in ScrappingMachineFrame.ItemSlots.scrapButtons:EnumerateActive() do
        if (btn) then
            WoWTools_DataMixin:Hook(btn, 'RefreshIcon', function(self)
                local tab= (self.itemLink or self.itemLocation) and {itemLink=self.itemLink, itemLocation= self.itemLocation} or nil
                WoWTools_ItemMixin:SetupInfo(self, tab)
            end)
        end
    end



    Init_Button()

    Init=function()end
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1== 'WoWToolsPlus' then

        WoWToolsPlusSave['Other_ScrappingMachine']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Other_ScrappingMachine'], P_Save)
        P_Save= nil

        addName= '|TInterface\\Icons\\inv_gizmo_03:0|t'..(WoWTools_L.SCRAPPING_MACHINE_TITLE)

        WoWTools_PanelMixin:OnlyCheck({
            name= addName,
            Value= not Save().disabled,
            GetValue=function() return not Save().disabled end,
            SetValue= function()
                Save().disabled= not Save().disabled and true or nil
                WoWTools_Print(addName..WoWTools_DataMixin.Icon.icon2, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_L.REQUIRES_RELOAD)
            end,
            tooltip= WoWTools_L['Tip.Scrapping.Option']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
            layout= WoWTools_OtherMixin.Layout,
            category= WoWTools_OtherMixin.Category,
        })

        if Save().disabled then
            self:SetScript('OnEvent', nil)
            self:UnregisterEvent(event)
        else
            if C_AddOns.IsAddOnLoaded('Blizzard_ScrappingMachineUI') then
                Init()
                self:UnregisterEvent(event)
            end
        end

    elseif arg1=='Blizzard_ScrappingMachineUI' and WoWToolsPlusSave then
        Init()
        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)