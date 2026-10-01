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
--Refresco en vivo desde el Centro de control (la lista de venta existe solo tras abrir la casa de subastas)
local function Refresh_Sell(M)
    M:Refresh_Sell()
end

local function Sell_Disabled(save)
    return save.disabledSellPlus
end

--Calidades: Pobre .. Ficha de WoW
local function Quality_Values()
    local list= {}
    for quality= Enum.ItemQuality.Poor, Enum.ItemQuality.WoWToken do
        local text= WoWTools_ItemMixin.QualityText[quality] or tostring(quality)
        table.insert(list, {value=quality, text= WoWTools_ItemMixin:GetColor(quality, {text=text}) or text})
    end
    return list
end

local Options= {
    {type='section', text='GENERAL'},
    {type='check', key='buyPlus', text='AUCTION_HOUSE_BUY_TAB', tooltip='Tip.AuctionHouse.BuyPlus', reload=true,
        get= function(save) return not save.disabledBuyPlus end,
        set= function(save, value) save.disabledBuyPlus= not value and true or nil end,
    },
    {type='check', key='sellPlus', text='AUCTION_HOUSE_SELL_TAB', tooltip='Tip.AuctionHouse.SellPlus', reload=true,
        get= function(save) return not save.disabledSellPlus end,
        set= function(save, value) save.disabledSellPlus= not value and true or nil end,
    },
    {type='check', text='Show sell list', tooltip='Tip.AuctionHouse.SellList', indent=true,
        disabled= Sell_Disabled,
        get= function(save) return not save.hideSellItemList end,
        set= function(save, value) save.hideSellItemList= not value and true or nil end,
        apply= Refresh_Sell,
    },
    {type='check', text='Hide marked items', tooltip='Tip.AuctionHouse.HideMarked', indent=true,
        disabled= Sell_Disabled,
        get= function(save) return save.hideSellItemListButton end,
        set= function(save, value) save.hideSellItemListButton= value and true or nil end,
        apply= Refresh_Sell,
    },
    {type='dropdown', text='Minimum quality', tooltip='Tip.AuctionHouse.SellQuality', indent=true,
        disabled= Sell_Disabled,
        values= Quality_Values,
        get= function(save) return save.sellItemQualiy end,
        set= function(save, value) save.sellItemQualiy= value end,
        apply= Refresh_Sell,
    },
    {type='slider', text='HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS', tooltip='Tip.AuctionHouse.SellRows', indent=true,
        min=1, max=40, step=1,
        disabled= Sell_Disabled,
        get= function(save) return save.numButton or 14 end,
        set= function(save, value) save.numButton= value end,
        apply= Refresh_Sell,
    },
    {type='check', key='auctionsPlus', text='AUCTION_HOUSE_AUCTIONS_SUB_TAB', tooltip='Tip.AuctionHouse.AuctionsPlus', reload=true,
        get= function(save) return not save.disabledAuctionsPlus end,
        set= function(save, value) save.disabledAuctionsPlus= not value and true or nil end,
    },

    {type='section', text='Automations'},
    {type='check', text='NPE_TURN+AUCTION_HOUSE_SELL_TAB', tooltip='Tip.AuctionHouse.GoToSell', automation=true,
        disabled= Sell_Disabled,
        get= function(save) return save.intShowSellItem end,
        set= function(save, value) save.intShowSellItem= value and true or nil end,
    },
    {type='check', text='Always sell max quantity', tooltip='Tip.AuctionHouse.MaxQuantity', automation=true,
        disabled= Sell_Disabled,
        get= function(save) return save.isMaxSellItem end,
        set= function(save, value) save.isMaxSellItem= value and true or false end,
        apply= function(M)
            if M.Refresh_MaxSellItem then
                M:Refresh_MaxSellItem()
            end
        end,
    },

    {type='section', text='Appearance'},
    {type='slider', text='Sell list scale', tooltip='Tip.Menu.Scale', min=0.4, max=4, step=0.1, format='%.1f',
        disabled= Sell_Disabled,
        get= function(save) return save.scaleSellButton or 1 end,
        set= function(save, value) save.scaleSellButton= value end,
        apply= Refresh_Sell,
    },

    {type='section', text='Advanced'},
    {type='button', text='Clear hidden items', buttonText='CLEAR_ALL', confirm=true,
        tooltip='Tip.AuctionHouse.ClearHidden',
        func= function(M, save)
            save.hideSellItem= {}
            save.hideSellPet= {}
            M:Refresh_Sell()
            M:Print(WoWTools_L['Clear hidden items'])
        end,
    },
    {type='note', text='Tip.AuctionHouse.OptionsNote'},
}

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
    options= Options,
    mixin= WoWTools_AuctionHouseMixin,
    onLogin= function()
        WoWTools_AuctionHouseMixin:Init_AccountStore()
    end,
    blizzard= {Blizzard_AuctionHouseUI= function()
        Init()
    end},
})
