--if GameLimitedMode_IsActive() or PlayerIsTimerunning() then
--    WoWTools_AuctionHouseMixin.disabled=true



local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub
    root:CreateTitle('Plus')

    sub= root:CreateCheckbox(
        WoWTools_L.AUCTION_HOUSE_BUY_TAB,
    function()
        return not WoWTools_AuctionHouseMixin:Save().disabledBuyPlus
    end, function()
        WoWTools_AuctionHouseMixin:Save().disabledBuyPlus= not WoWTools_AuctionHouseMixin:Save().disabledBuyPlus and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.AuctionHouse.BuyPlus'])
        tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
    end)

    sub= root:CreateCheckbox(
        WoWTools_L.AUCTION_HOUSE_SELL_TAB,
    function()
        return not WoWTools_AuctionHouseMixin:Save().disabledSellPlus
    end, function()
        WoWTools_AuctionHouseMixin:Save().disabledSellPlus= not WoWTools_AuctionHouseMixin:Save().disabledSellPlus and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.AuctionHouse.SellPlus'])
        tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
    end)

    sub= root:CreateCheckbox(
        WoWTools_L.AUCTION_HOUSE_AUCTIONS_SUB_TAB,
    function()
        return not WoWTools_AuctionHouseMixin:Save().disabledAuctionsPlus
    end, function()
        WoWTools_AuctionHouseMixin:Save().disabledAuctionsPlus= not WoWTools_AuctionHouseMixin:Save().disabledAuctionsPlus and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.AuctionHouse.AuctionsPlus'])
        tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
    end)

    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_AuctionHouseMixin.addName})

    WoWTools_MenuMixin:Reload(sub)
end










local Init= WoWTools_Once(function()
    WoWTools_AuctionHouseMixin:Init_BrowseResultsFrame()
    WoWTools_AuctionHouseMixin:Init_AllAuctions()
    WoWTools_AuctionHouseMixin:Init_Sell()
    WoWTools_AuctionHouseMixin:Sell_Other()

    local btn= CreateFrame('DropdownButton', 'WoWToolsAuctionHouseMenuButton', AuctionHouseFrameCloseButton, 'WoWToolsMenuTemplate') --WoWTools_ButtonMixin:Menu(AuctionHouseFrameCloseButton, {name='WoWToolsAuctionHouseMenuButton'})
    btn:SetPoint('RIGHT', AuctionHouseFrameCloseButton, 'LEFT')
    btn.tootip= WoWTools_AuctionHouseMixin.addName
    btn:SetupMenu(Init_Menu)

end)






--Módulo registrado con la API común (docs/REFACTOR.md, R1)
WoWTools_Module:Register({
    key= 'Plus_AuctionHouse',
    name= 'Module.Auction House',
    icon= 'Auctioneer',
    group= 'Items',
    defaults= {
        numButton=14,
        scaleSellButton=0.95,
        isMaxSellItem= true,
        hideSellItem={
            [201469]=true,
            [202071]=true,
            [192658]=true,
            [192615]=true,
        },
        hideSellPet={
        },
        sellItemQualiy=1,
        SellItemDefaultPrice={},
    },
    tooltip= 'Tip.AuctionHouse.Enable',
    mixin= WoWTools_AuctionHouseMixin,
    onLogin= function()
        WoWTools_AuctionHouseMixin:Init_AccountStore()
    end,
    blizzard= {Blizzard_AuctionHouseUI= function()
        Init()
    end},
})
