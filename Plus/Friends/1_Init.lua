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
    onEnable= function()
        WoWTools_FriendsMixin:Blizzard_QuickJoin()
        WoWTools_FriendsMixin:Blizzard_RaidFrame()
        WoWTools_FriendsMixin:Blizzard_FriendsFrame()
    end,
    blizzard= {Blizzard_RaidUI= function()
        WoWTools_FriendsMixin:Blizzard_RaidUI()
    end},
})
