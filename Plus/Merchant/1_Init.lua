

local function Save()
    return WoWToolsPlusSave['Plus_SellBuy']
end








local function Init()
    WoWTools_MerchantMixin:Init_AutoLoot()
    WoWTools_MerchantMixin:Init_Auto_Repair()


    WoWTools_MerchantMixin:Init_Auto_Sell_Junk()

    WoWTools_MerchantMixin:Init_Buy_Items_Button()
    WoWTools_MerchantMixin:Init_Buyback_Button()
    WoWTools_MerchantMixin:Init_Menu()

    WoWTools_MerchantMixin:Init_WidthX2()
    WoWTools_MerchantMixin:Plus_ItemInfo()


    Init=function()end
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Plus_SellBuy']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_SellBuy'], {
                --noSell={},
                --Sell={},
                --buyItems={},
                notAutoLootPlus= true,

                bossItems={},


                MERCHANT_ITEMS_PER_PAGE= 24,
                numLine=6,

            })

            Save().notDELETE= nil

            if Save().repairItems then
                WoWToolsPlusPlayerDate['RepairMoney']= Save().repairItems
                Save().repairItems= nil
            else
                WoWToolsPlusPlayerDate['RepairMoney']= WoWToolsPlusPlayerDate['RepairMoney'] or {date=date('%x'), player=0, guild=0, num=0}
            end

            WoWToolsPlusPlayerDate['SellBuyItems']= WoWToolsPlusPlayerDate['SellBuyItems'] or {
                buy={},--[guid]={[itemID]=numbre,}
                sell={
                    [34498]=true,
                },
                noSell={
                    [144341]=true,
                    [49040]=true,
                    [114943]=true,
                    [103678]=true,
                    [142469]=true,
                    [139590]=true,
                    [144391]=true,
                    [144392]=true,
                    [37863]=true,
                },
            }

            WoWToolsPlusPlayerDate['SellBuyItems'].buy= WoWToolsPlusPlayerDate['SellBuyItems'].buy or {}

            if not WoWToolsPlusPlayerDate['SellBuyItems'].buy[WoWTools_DataMixin.Player.GUID] then
                WoWToolsPlusPlayerDate['SellBuyItems'].buy[WoWTools_DataMixin.Player.GUID]= {}
            end

            WoWTools_MerchantMixin.addName= '|A:SpellIcon-256x256-SellJunk:0:0|a'..(WoWTools_L['Module.Merchant'])

            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_MerchantMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    if Save().disabled then
                        WoWTools_Print(
                            WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
                            WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                            WoWTools_L.RELOADUI
                        )
                        self:UnregisterEvent('PLAYER_LOGOUT')
                    else
                        self:RegisterEvent("PLAYER_LOGOUT")
                        Init()
                    end
                end,
                tooltip= WoWTools_L['Tip.Merchant.Module'],
            })

            if not Save().disabled then
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                self:RegisterEvent("PLAYER_LOGOUT")
            else
                self:SetScript('OnEvent', nil)
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        Init()
        self:UnregisterEvent(event)

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            if not Save().saveBossLootList then
                Save().bossItems={}
            end
        end
    end
end)