WoWTools_FriendsMixin={}




--Módulo registrado con la API común (docs/REFACTOR.md, R2)
WoWTools_Module:Register({
    key= 'Plus_FriendsList',
    name= 'Module.Friends list',
    icon= 'socialqueuing-icon-group',
    group= 'Chat',
    defaults= {Friends={}},
    tooltip= 'Tip.Friends.Enable',
    mixin= WoWTools_FriendsMixin,
    options= {
        {type='section', text='GENERAL'},
        {type='check', key='friendPlus', text= function() return WoWTools_L.FRIEND..' Plus' end, tooltip='Tip.Friends.FriendPlus',
            get= function(save) return not save.disabledFriendPlus end,
            set= function(save, value) save.disabledFriendPlus= not value and true or nil end,
            apply= function(M)
                if M.started and FriendsList_Update then
                    WoWTools_DataMixin:Call('FriendsList_Update', true)
                end
            end,
        },

        {type='section', text='Automations'},
        {type='dropdown', key='status', text='Battle.net status at login', tooltip='Tip.Friends.LoginStatus', automation=true,
            values= {
                {value='none', text='NONE'},
                {value='Availabel', text='FRIENDS_LIST_AVAILABLE'},
                {value='Away', text='FRIENDS_LIST_AWAY'},
                {value='DND', text='FRIENDS_LIST_BUSY'},
            },
            get= function(save) return save.Friends and save.Friends[WoWTools_DataMixin.Player.GUID] or 'none' end,
            set= function(save, value)
                save.Friends= save.Friends or {}
                save.Friends[WoWTools_DataMixin.Player.GUID]= value~='none' and value or nil
            end,
            apply= function()
                local btn= _G['WoWToolsFriendsMenuButton']
                if btn then
                    btn:set_status()
                end
            end,
        },
        {type='button', key='clear', text='Clear status of all characters', buttonText='CLEAR_ALL', confirm=true,
            tooltip='Tip.Friends.ClearStatus',
            func= function(_, save)
                save.Friends= {}
                local btn= _G['WoWToolsFriendsMenuButton']
                if btn then
                    btn:set_status()
                end
            end,
        },
    },
    onEnable= function()
        WoWTools_FriendsMixin:Blizzard_QuickJoin()
        WoWTools_FriendsMixin:Blizzard_RaidFrame()
        WoWTools_FriendsMixin:Blizzard_FriendsFrame()
    end,
    blizzard= {Blizzard_RaidUI= function()
        WoWTools_FriendsMixin:Blizzard_RaidUI()
    end},
})
