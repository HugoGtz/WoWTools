local P_Save={
    --showNotOnLine=true,
}









WoWTools_Module:Register({
    key= 'ChatButtonGuild', name= 'Module.Guild', icon= 'UI-HUD-MicroMenu-GuildCommunities-Up',
    parent= 'ChatButton', defaults= P_Save, mixin= WoWTools_GuildMixin,
    onEnable= function()
        if WoWTools_ChatMixin:CreateButton('Guild', WoWTools_GuildMixin.addName) then
            --el resto arranca en el primer PLAYER_ENTERING_WORLD (como antes)
            WoWTools_ChatMixin:OnEnterWorld(function()
                WoWTools_GuildMixin:Init_Button()
                WoWTools_GuildMixin:Init_Menu()
                WoWTools_GuildMixin:Init_ClubFinder()
                WoWTools_GuildMixin:Plus_CommunitiesFrame()
                WoWTools_GuildMixin:Init_PetitionFrame()
            end)
            C_ClubFinder.RequestSubscribedClubPostingIDs()
        end
    end,
})
