--WoWTools_GuildBankMixin={}
local P_Save={
    showIndex=true,
    plusItem=true,
    plusTab=true,

    onlyMemberOutMoney=true,

    saveItemSeconds=0.8,
    sortRightToLeft=true,
}


local function Save()
    return WoWToolsPlusSave['Plus_GuildBank']
end


local function Init()
    WoWTools_GuildBankMixin:Init_Plus()
    WoWTools_GuildBankMixin:Init_Menu()
    WoWTools_GuildBankMixin:Init_Sort()
    WoWTools_GuildBankMixin:Init_InOut_Item()
    WoWTools_GuildBankMixin:Init_Out_Money()

    GuildBankFrame:HookScript('OnShow', function(self)
        if WoWToolsPlusSave['Plus_GuildBank'].autoOpenBags and not InCombatLockdown() then
            do
                WoWTools_BagMixin:OpenBag(nil, false)
            end
            self:Raise()
        end
    end)

    Init=function()end
end


local panel= CreateFrame("Frame")

panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then
            WoWToolsPlusSave['Plus_GuildBank']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_GuildBank'], P_Save)
            P_Save=nil

            WoWTools_GuildBankMixin.addName= '|A:VignetteLoot:0:0|a'..(WoWTools_L['Module.Guild bank'])

            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_GuildBankMixin.addName,
                tooltip= WoWTools_L['Tip.GuildBank.Option']..'|n|n'..WoWTools_L.RELOADUI,
                GetValue=function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    WoWTools_Print(
                        WoWTools_GuildBankMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_L.RELOADUI
                    )
                end
            })

            if Save().disabled then
                self:SetScript('OnEvent', nil)
                self:UnregisterEvent(event)

            elseif C_AddOns.IsAddOnLoaded('Blizzard_GuildBankUI') then
                Init()
                self:SetScript('OnEvent', nil)
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_GuildBankUI' and WoWToolsPlusSave then
            Init()
            self:SetScript('OnEvent', nil)
            self:UnregisterEvent(event)
        end
    end
end)