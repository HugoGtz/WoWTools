local P_Save={
    --showNotOnLine=true,
}









WoWTools_Module:Register({
    key= 'ChatButtonGuild', name= 'Module.Guild', icon= 'UI-HUD-MicroMenu-GuildCommunities-Up',
    parent= 'ChatButton', defaults= P_Save, mixin= WoWTools_GuildMixin,
    options= {
        {type='section', text='GENERAL'},
        {type='check', key='showListName', text='SHOW+GUILD_TAB_ROSTER', tooltip='Tip.Guild.ShowList',
            get= function(save) return save.showListName end,
            set= function(save, value) save.showListName= value and true or nil end,
        },
        {type='check', key='showNotOnLine', text='COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE', tooltip='Tip.Guild.ShowOffline', indent=true,
            disabled= function(save) return not save.showListName end,
            get= function(save) return save.showNotOnLine end,
            set= function(save, value) save.showNotOnLine= value and true or nil end,
        },

        {type='section', text='Automations'},
        {type='check', key='autoRequestClub', text='SELF_CAST_AUTO+SIGN_UP', tooltip='Tip.Guild.AutoRequestClub', automation=true,
            get= function(save) return not save.notAutoRequestToJoinClub end,
            set= function(save, value) save.notAutoRequestToJoinClub= not value and true or nil end,
        },
        {type='check', key='petitionTarget', text='SELF_CAST_AUTO+REQUEST_SIGNATURE', tooltip='Tip.Guild.PetitionTarget', automation=true,
            get= function(save) return not save.disabledPetitionTarget end,
            set= function(save, value) save.disabledPetitionTarget= not value end,
            apply= function(_, save)
                local check= _G['PetitionFrameAutoPetitionTargetCheckBox']
                if check then
                    check:SetChecked(not save.disabledPetitionTarget)
                    check:set_event()
                end
            end,
        },

        {type='section', text='Appearance'},
        {type='slider', key='subGuildName', text='Truncate', tooltip='Tip.Guild.TruncateZero', min=0, max=93, step=1,
            get= function(save) return save.subGuildName or 0 end,
            set= function(save, value) save.subGuildName= value~=0 and value or nil end,
        },
    },
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
