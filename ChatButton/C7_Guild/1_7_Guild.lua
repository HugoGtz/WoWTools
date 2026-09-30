local P_Save={
    --showNotOnLine=true,
}









local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then
            WoWToolsPlusSave['ChatButtonGuild']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['ChatButtonGuild'], P_Save)
            P_Save=nil

            WoWTools_GuildMixin.addName= '|A:UI-HUD-MicroMenu-GuildCommunities-Up:0:0|a'..(WoWTools_L['Module.Guild'])

            if WoWTools_ChatMixin:CreateButton('Guild', WoWTools_GuildMixin.addName) then
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                C_ClubFinder.RequestSubscribedClubPostingIDs()
            else
                self:SetScript('OnEvent', nil)
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_GuildMixin:Init_Button()
        WoWTools_GuildMixin:Init_Menu()
        WoWTools_GuildMixin:Init_ClubFinder()
        WoWTools_GuildMixin:Plus_CommunitiesFrame()
        WoWTools_GuildMixin:Init_PetitionFrame()

        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)