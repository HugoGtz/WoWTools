--回购物品

local function Save()
    return WoWToolsPlusSave['Plus_SellBuy']
end


--购回物品
local function set_buyback_item()
    local num= GetNumBuybackItems() or 0
    if IsModifierKeyDown() or num==0 then
        return
    end

    local tab={}
    local no={}
    for index=num, 1, -1 do--hacia atrás: al recomprar la lista se desplaza
        local itemID = C_MerchantFrame.GetBuybackItemID(index)
        if itemID and WoWToolsPlusPlayerDate['SellBuyItems'].noSell[itemID] then
            local itemLink= GetBuybackItemLink(index) or itemID
            local co= select(3, GetBuybackItemInfo(index)) or 0
            if co<=GetMoney() then
                table.insert(tab, itemLink)
                BuybackItem(index)
            else
                table.insert(no, {itemLink, co or 0})
            end
        end
    end

    C_Timer.After(0.3, function()
        for index, itemLink in pairs(tab) do
            WoWTools_Print(
                WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
                index..')|cnGREEN_FONT_COLOR:'..(WoWTools_L['BUYBACK~2']),
                itemLink
            )
        end
        for index, info in pairs(no) do
            WoWTools_Print(
                WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,

                index
                ..')|cnWARNING_FONT_COLOR:'
                ..(WoWTools_L['BUYBACK+INCOMPLETE']),

                info[1],
                info[2] and C_CurrencyInfo.GetCoinTextureString(info[2]) or ''
            )
        end
    end)
end


--添加，移除，到Save
local function Add_Remove_ToSave(itemID)
    local text
    if WoWToolsPlusPlayerDate['SellBuyItems'].noSell[itemID] then
        WoWToolsPlusPlayerDate['SellBuyItems'].noSell[itemID]=nil
        text= '|cnWARNING_FONT_COLOR:'..(WoWTools_L.REMOVE)
    else
        WoWToolsPlusPlayerDate['SellBuyItems'].noSell[itemID]=true
        WoWToolsPlusPlayerDate['SellBuyItems'].sell[itemID]=nil
        text='|cnGREEN_FONT_COLOR:'..(WoWTools_L.ADD)
        set_buyback_item()
    end
    WoWTools_Print(
        WoWTools_DataMixin.addName,
        WoWTools_MerchantMixin.addName,
        WoWTools_L.BUYBACK,
        text
    )
end


local function Init_Menu(self, root)
    local sub, itemID, itemLink
    local allNum= GetNumBuybackItems() or 0

    sub= root:CreateButton(
        '|A:bag-main:0:0|a'
        ..(WoWTools_L['BUYBACK~2']),
        --..' #|cnGREEN_FONT_COLOR:'..allNum,
    function()
        allNum= GetNumBuybackItems() or 0

        if allNum==0 then
            return
        end

        local tab={}

        for index= allNum, 1, -1 do
            BuybackItem(index)
            table.insert(tab, GetBuybackItemLink(index))
        end

        C_Timer.After(0.3, function()
            WoWTools_Print(
                WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
                table.concat(tab, '|n'),
                '|n',
                allNum..(WoWTools_L['BUYBACK~2'])
            )
        end)
        return MenuResponse.Open
    end, {rightText=allNum})
    WoWTools_MenuMixin:SetRightText(sub)

    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Merchant.BuybackAll'])
        for index=1, GetNumBuybackItems() do
            tooltip:AddDoubleLine(WoWTools_ItemMixin:GetName(nil, GetBuybackItemLink(index)), index)
        end
    end)

    root:CreateDivider()
    if allNum>0 then
        for index= allNum, 1, -1 do
            itemID, itemLink = C_MerchantFrame.GetBuybackItemID(index), GetMerchantItemLink(index)
            sub=root:CreateCheckbox(
                WoWTools_ItemMixin:GetName(itemID, itemLink, nil),--取得物品，名称
            function(data)
                return WoWToolsPlusPlayerDate['SellBuyItems'].noSell[data.itemID]
            end, function(data)
                Add_Remove_ToSave(data.itemID)
            end, {itemID=itemID})

            sub:SetTooltip(function(tooltip)
                WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Merchant.BuybackItem'])
                tooltip:AddLine(WoWTools_L['ADD+BUYBACK'])
            end)
        end
    end

    

    WoWTools_MerchantMixin:Buyback_Menu(self, root)

    root:CreateDivider()
    root:CreateTitle(WoWTools_L['DRAG_MODEL+ITEMS'])
end


--购回
local function Init()

    local BuybackButton= CreateFrame('Button', 'WoWTools_BuybackButton', MerchantFrame, 'WoWToolsButtonTemplate')
    BuybackButton:SetSize(35,35)

    if Save().notPlus then
        BuybackButton:SetPoint('BOTTOMRIGHT', MerchantBuyBackItem, 6,18)
        BuybackButton:SetSize(22, 22)
    else
        BuybackButton:SetPoint('LEFT', MerchantBuyBackItemItemButtonIconTexture, 'RIGHT', 10, 0)
    end

    BuybackButton.texture= BuybackButton:CreateTexture(nil, 'BORDER')
    BuybackButton.texture:SetAllPoints()
    function BuybackButton:set_texture()
        self.texture:SetAtlas('common-icon-undo')
    end

    function BuybackButton:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()

        GameTooltip:AddDoubleLine(
            '|A:common-icon-undo:0:0|a'
            ..(WoWTools_L.BUYBACK),
            '|cnGREEN_FONT_COLOR: #'..(self:set_text() or '')
        )
        GameTooltip:AddLine(' ')

        local infoType, itemID= GetCursorInfo()
        if infoType=='merchant' and itemID then
            itemID= GetMerchantItemID(itemID)
        end

        if (infoType=='item' or infoType=='merchant') and itemID then
            local name= WoWTools_ItemMixin:GetName(itemID)
            if WoWToolsPlusPlayerDate['SellBuyItems'].noSell[itemID] then
                GameTooltip:AddDoubleLine(name, (WoWTools_L.REMOVE)..WoWTools_DataMixin.Icon.left)
                self.texture:SetAtlas('bags-button-autosort-up')
            else
                GameTooltip:AddDoubleLine(name, (WoWTools_L.ADD)..WoWTools_DataMixin.Icon.left)
                local icon= select(5, C_Item.GetItemInfoInstant(itemID))
                if icon then
                    self.texture:SetTexture(icon)
                end
            end

        else
            GameTooltip:AddLine(WoWTools_L['DRAG_MODEL+ITEMS'])
            GameTooltip:AddDoubleLine(WoWTools_L.SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
        end
        GameTooltip:Show()
    end


    BuybackButton:SetScript('OnMouseDown', function(self, d)
        local infoType, itemID = GetCursorInfo()
        if infoType=='merchant' and itemID then--购买物品
            itemID= GetMerchantItemID(itemID)
        end

        if (infoType=='item' or infoType=='merchant') and itemID then
            Add_Remove_ToSave(itemID)
            ClearCursor()
        else
            MenuUtil.CreateContextMenu(self, function(...)
                Init_Menu(...)
            end)
        end
        self:set_tooltip()
    end)


    BuybackButton:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        self:set_texture()
    end)
    BuybackButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
    end)
    BuybackButton:SetScript('OnMouseUp', function(self)
        self:set_texture()
    end)


    BuybackButton.Text= WoWTools_LabelMixin:Create(BuybackButton, {justifyH='RIGHT', color={r=1,g=1,b=1}})
    BuybackButton.Text:SetPoint('BOTTOMRIGHT')

    function BuybackButton:set_text()--回购，数量，提示
        local num= CountTable(WoWToolsPlusPlayerDate['SellBuyItems'].noSell or {})

        self.Text:SetText(num>0 and num or '')
        self.texture:SetDesaturated(num==0)
        return num
    end



    BuybackButton:RegisterEvent('MERCHANT_UPDATE')
    BuybackButton:RegisterEvent('MERCHANT_SHOW')
    BuybackButton:SetScript('OnEvent', set_buyback_item)

    BuybackButton:set_text()--回购，数量，提示
    BuybackButton:set_texture()

--清除，回购买，图标
    MerchantBuyBackItemItemButton.UndoFrame.Arrow:ClearAllPoints()
    MerchantBuyBackItemItemButton.UndoFrame.Arrow:SetTexture(0)
end


function WoWTools_MerchantMixin:Init_Buyback_Button()--回购物品
    Init()
end