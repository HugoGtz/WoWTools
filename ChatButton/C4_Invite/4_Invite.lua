

WoWTools_InviteMixin={
    InvPlateGuid={},
}


function WoWTools_InviteMixin:Get_Leader()
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player') or not IsInGroup()
end



























--####
--####
local Init= WoWTools_Once(function(btn)
    btn.texture:SetAtlas('communities-icon-addgroupplus')

    btn.summonTips= btn:CreateTexture(nil,'OVERLAY')
    btn.summonTips:SetPoint('BOTTOMLEFT', 0, 3)
    btn.summonTips:SetSize(16,16)
    btn.summonTips:SetAtlas('Raid-Icon-SummonPending')

    btn.invTips= btn:CreateTexture(nil,'OVERLAY')
    btn.invTips:SetPoint('BOTTOMRIGHT', -2, 0)
    btn.invTips:SetSize(16,16)
    btn.invTips:SetAtlas('poi-traveldirections-arrow2')

    function btn:settings()
        self.summonTips:SetShown(WoWTools_InviteMixin:Save().Summon)
        self.invTips:SetShown(WoWTools_InviteMixin:Save().Channel and WoWTools_InviteMixin:Save().ChannelText or WoWTools_InviteMixin:Save().InvTar)
    end

    function btn:set_tooltip()
        self:set_owner()
        GameTooltip:AddDoubleLine(WoWTools_InviteMixin.addName, WoWTools_DataMixin.Icon.left)
        if WoWTools_InviteMixin:Save().InvTar then
            GameTooltip:AddLine(WoWTools_L['INVITE+TARGET'])
        end
        if WoWTools_InviteMixin:Save().Channel and WoWTools_InviteMixin:Save().ChannelText then
            GameTooltip:AddLine((WoWTools_L.CHANNEL)..'|cnGREEN_FONT_COLOR: '..WoWTools_InviteMixin:Save().ChannelText)
        end
        GameTooltip:Show()
    end

    WoWTools_InviteMixin:Setup_Menu(btn)

    function btn:set_OnMouseDown()
        WoWTools_InviteMixin:Inv_All_Unit()
    end

    btn:settings()
end)















--Refresco de los iconos del botón (invocar / invitar)
function WoWTools_InviteMixin:Refresh_Button()
    local btn= WoWTools_ChatMixin:GetButtonForName('Invite')
    if btn and btn.settings then
        btn:settings()
    end
end

local function Refresh_Button()
    WoWTools_InviteMixin:Refresh_Button()
end

--Esperas: sin valor guardado se usan los 3 s de siempre; el valor por defecto no se guarda
local function Delay_Get(field)
    return function(save) return save[field] or 3 end
end
local function Delay_Set(field)
    return function(save, value)
        value= math.floor(value+0.5)
        save[field]= value~=3 and value or nil
    end
end
local function Seconds(value)
    return format('%d %s', value, WoWTools_L.LOSS_OF_CONTROL_SECONDS)
end

local function No_InvitePlus(save)
    return save.notInvitePlus
end

local Options= {
    {type='section', text='GENERAL'},
    {type='check', key='restingTips', text='|cnGREEN_FONT_COLOR:Rest|r Zone Info', tooltip='Tip.Invite.RestingTips',
        get= function(save) return save.restingTips end,
        set= function(save, value) save.restingTips= value and true or false end,
        apply= function(M) M:Resting_Settings() end,
    },
    {type='check', key='focus', text='Set focus with a modifier key', tooltip='Tip.Invite.Focus', reload=true,
        get= function(save) return save.setFucus end,
        set= function(save, value) save.setFucus= value and true or nil end,
    },
    {type='dropdown', key='focusKey', text='Modifier key', tooltip='Tip.Invite.FocusKey', reload=true, indent=true,
        values= {{value='Shift', text='SHIFT_KEY'}, {value='Ctrl', text='CTRL_KEY'}, {value='Alt', text='ALT_KEY'}},
        disabled= function(save) return not save.setFucus end,
        get= function(save) return save.focusKey or 'Shift' end,
        set= function(save, value) save.focusKey= value end,
    },

    {type='section', text='Automations'},
    {type='check', key='invitePlus', text='Improve the group invite dialog', tooltip='Tip.Invite.InvitePlus', automation=true, reload=true,
        get= function(save) return not save.notInvitePlus end,
        set= function(save, value) save.notInvitePlus= not value and true or nil end,
        apply= function(M)
            if M.started and WoWTools_ChatMixin:GetButtonForName('Invite') then
                M:Init_StaticPopup()
            end
        end,
    },
    {type='check', key='friendAccept', text='Accept invites from friends', tooltip='Tip.Invite.AcceptFriends', automation=true, indent=true,
        disabled= No_InvitePlus,
        get= function(save) return save.FriendAceInvite end,
        set= function(save, value) save.FriendAceInvite= value and true or false end,
    },
    {type='slider', key='friendAcceptSec', text='Wait before accepting', tooltip='Tip.Invite.AcceptDelay', automation=true, indent=true,
        min=1, max=30, step=1, format=Seconds,
        disabled= function(save) return save.notInvitePlus or not save.FriendAceInvite end,
        get= Delay_Get('FriendAceInviteSec'),
        set= Delay_Set('FriendAceInviteSec'),
    },
    {type='check', key='declineResting', text='Decline in rest zone', tooltip='Tip.Invite.DeclineResting', automation=true, indent=true,
        disabled= No_InvitePlus,
        get= function(save) return save.NoInvInResting end,
        set= function(save, value) save.NoInvInResting= value and true or nil end,
    },
    {type='slider', key='declineSec', text='Wait before declining', tooltip='Tip.Invite.DeclineDelay', automation=true, indent=true,
        min=1, max=30, step=1, format=Seconds,
        disabled= No_InvitePlus,
        get= Delay_Get('InvDeclineSec'),
        set= Delay_Set('InvDeclineSec'),
    },
    {type='check', key='summon', text='Accept summons automatically', tooltip='Tip.Invite.Summon', automation=true,
        get= function(save) return save.Summon end,
        set= function(save, value) save.Summon= value and true or false end,
        apply= Refresh_Button,
    },
    {type='slider', key='summonSec', text='Wait before accepting the summon', tooltip='Tip.Invite.SummonDelay', automation=true, indent=true,
        min=1, max=30, step=1, format=Seconds,
        disabled= function(save) return not save.Summon end,
        get= Delay_Get('SummonSec'),
        set= Delay_Set('SummonSec'),
    },
    {type='check', key='invTarget', text='INVITE+TARGET', tooltip='Tip.Invite.Target', automation=true,
        get= function(save) return save.InvTar end,
        set= function(save, value) save.InvTar= value and true or nil end,
        apply= function(M)
            M:Refresh_Button()
            M:Inv_Target_Settings()
        end,
    },
    {type='check', key='channel', text='Invite by keyword', tooltip='Tip.Invite.Channel', automation=true,
        get= function(save) return save.Channel end,
        set= function(save, value) save.Channel= value and true or nil end,
        apply= function(M)
            if _G['WoWToolsChatInviteChanellFrame'] then
                _G['WoWToolsChatInviteChanellFrame']:set_event()
            end
            M:Refresh_Button()
        end,
    },
    {type='input', key='channelText', text='KBASE_DEFAULT_SEARCH_TEXT', tooltip='Tip.Invite.Keyword', indent=true, maxLetters=50,
        disabled= function(save) return not save.Channel end,
        get= function(save) return save.ChannelText end,
        set= function(save, value)
            value= value and strtrim(tostring(value)) or ''
            if value~='' then--vacía invitaría a cualquiera que hable
                save.ChannelText= string.upper(value)
            end
        end,
    },

    {type='section', text='Advanced'},
    {type='button', key='test', text='Test', buttonText='Test', tooltip='Tip.Invite.Test',
        disabled= No_InvitePlus,
        func= function()
            local name= UnitName('player')
            StaticPopup_Show("PARTY_INVITE", '|n'..format(WoWTools_L.INVITATION, name)..'|n|n')
            EventRegistry:TriggerEvent('PARTY_INVITE_REQUEST', UnitName('player'), true, true, true, false, true, WoWTools_DataMixin.Player.GUID, false)
        end,
    },
    {type='button', key='clearDecline', text='Clear the declined players list', buttonText='CLEAR_ALL', tooltip='Tip.Invite.DeclineList',
        confirm='CLEAR_ALL',
        disabled= function(save) return not next(save.InvNoFriend or {}) end,
        func= function(_, save)
            save.InvNoFriend= {}
        end,
    },
}




WoWTools_Module:Register({
    key= 'ChatButton_Invite', name= 'Module.Invites', icon= 'communities-icon-addgroupplus',
    parent= 'ChatButton', mixin= WoWTools_InviteMixin,
    options= Options,
    defaults= {
        InvNoFriend={},
        FriendAceInvite=true,
        InvNoFriendNum=0,
        restingTips=true,
        ChannelText=WoWTools_DataMixin.Player.IsCN and '1' or 'inv',

        Summon= nil,
        notSummonChat=nil,
        SummonChat=nil,--decir gracias al grupo (opcional)
        SummonThxText=nil,
        SummonThxInRaid=nil,

        setFrameFun= true,
        focusKey= 'Shift',
    },
    onEnable= function()
        if WoWTools_ChatMixin:CreateButton('Invite', WoWTools_InviteMixin.addName) then
            --el resto arranca en el primer PLAYER_ENTERING_WORLD (como antes)
            WoWTools_ChatMixin:OnEnterWorld(function()
                WoWTools_InviteMixin:Init_Chanell()
                WoWTools_InviteMixin:Init_Focus()
                WoWTools_InviteMixin:Init_Summon()
                WoWTools_InviteMixin:Init_Resting()
                WoWTools_InviteMixin:Init_Target()
                WoWTools_InviteMixin:Init_StaticPopup()
            end)
            Init(WoWTools_ChatMixin:GetButtonForName('Invite'))
        end
    end,
})
