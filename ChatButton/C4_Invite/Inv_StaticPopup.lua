local function Save()
    return WoWToolsPlusSave['ChatButton_Invite'] or {}
end


local function isInLFG()
    for type=1, NUM_LE_LFG_CATEGORYS do
        if GetLFGQueueStats(type) then
            return true
        end
    end
end

local InviterPlayerGUID
local InvTimer




local function Decline()
    Save().InvNoFriendNum=Save().InvNoFriendNum+1
    if InviterPlayerGUID then
        Save().InvNoFriend[InviterPlayerGUID]= (Save().InvNoFriend[InviterPlayerGUID] or 0) + 1
    end
    DeclineGroup()
    StaticPopup_Hide("PARTY_INVITE")
end

--rechazar sin apuntar al que invita (p.ej. zona de descanso)
local function DeclineOnly()
    DeclineGroup()
    StaticPopup_Hide("PARTY_INVITE")
end

local function Accept()
    AcceptGroup()
    StaticPopup_Hide("PARTY_INVITE")
end











local function Settings(_, name, isTank, isHealer, isDamage, isNativeRealm, allowMultipleRoles, inviterGUID, questSessionActive)

    InviterPlayerGUID= inviterGUID

    local StaticPopupFrame, TimeLeft= WoWTools_DataMixin:StaticPopup_FindVisible('PARTY_INVITE')
    if not inviterGUID or not name or not StaticPopupFrame then
        return

    end

    local text
    local sec

    local function setPrint()
        WoWTools_DataMixin:PlaySound(SOUNDKIT.IG_PLAYER_INVITE)

        WoWTools_Print(
            WoWTools_InviteMixin.addName..WoWTools_DataMixin.Icon.icon2
        )
        WoWTools_Print(
            '|cnGREEN_FONT_COLOR:'..(sec or ''), (WoWTools_L.LOSS_OF_CONTROL_SECONDS)..'|r',

            text,

            (isTank and WoWTools_DataMixin.Icon.TANK or '')
            ..(isHealer and WoWTools_DataMixin.Icon.HEALER or '')
            ..(isDamage and WoWTools_DataMixin.Icon.DAMAGER or '')
            ..(allowMultipleRoles and '|cffff8200'..(WoWTools_L.CLUB_FINDER_MULTIPLE_ROLES)..'|r' or ''),

            (questSessionActive and '|cff00ffff'..(WoWTools_L.SCENARIOS) or '')
        )
        if isNativeRealm then
             WoWTools_Print(
                WoWTools_DataMixin.Icon.icon2
                ..'|cffff00ff'
                ..format(
                    WoWTools_L['%s invites you to a group. Accepting this invitation may transport you to another realm.'],
                    WoWTools_UnitMixin:GetLink(nil, inviterGUID, name, false)
                )
            )
        end
        if sec then
            WoWTools_Print(
                WoWTools_DataMixin.Icon.icon2..'|cnGREEN_FONT_COLOR:Alt',
                WoWTools_L.CANCEL
            )
        end
        WoWTools_CooldownMixin:Setup(StaticPopupFrame, nil, sec or TimeLeft, nil, true, true, nil)
    end


    if Save().InvNoFriend[inviterGUID] then
        sec= 3
        text= '|cnWARNING_FONT_COLOR:'..(WoWTools_L.DECLINE)..' '..Save().InvNoFriend[inviterGUID]..'/'..Save().InvNoFriendNum..'|r'
        setPrint()

        StaticPopupFrame.button3:SetText(WoWTools_L['REMOVE+DECLINE'])

        if InvTimer then InvTimer:Cancel() InvTimer=nil end

        InvTimer = C_Timer.NewTimer(3, Decline)

    elseif WoWTools_UnitMixin:GetIsFriendIcon(nil, inviterGUID, nil) then
        if not Save().FriendAceInvite then
            WoWTools_CooldownMixin:Setup(StaticPopupFrame, nil, TimeLeft or 30, nil, true, true, nil)
            return
        end

        sec=isInLFG() and 10 or 3

        text= '|cnGREEN_FONT_COLOR:'
            ..(WoWTools_L['ACCEPT+FRIENDS'])
            ..'|r'
        setPrint()

        if InvTimer then InvTimer:Cancel() InvTimer=nil end
        InvTimer = C_Timer.NewTimer(sec, Accept)

    elseif IsResting() and Save().NoInvInResting and not questSessionActive then
        sec= 3
        text= '|cnWARNING_FONT_COLOR:'
            ..WoWTools_L['Decline in rest zone']
            ..'|r'
        setPrint()

        if InvTimer then InvTimer:Cancel() InvTimer=nil end
        InvTimer = C_Timer.NewTimer(3, DeclineOnly)

    else

        WoWTools_CooldownMixin:Setup(StaticPopupFrame, nil, TimeLeft or StaticPopupTimeoutSec, nil, true, true, nil)
    end
end





local function Init()
    if Save().notInvitePlus then
        return
    end


    EventRegistry:RegisterFrameEventAndCallback("PARTY_INVITE_REQUEST", function(...)
        Settings(...)
    end)


    StaticPopupDialogs["PARTY_INVITE"].button3= WoWTools_L['Add Decline']
    StaticPopupDialogs["PARTY_INVITE"].OnAlt=function()
        if not InviterPlayerGUID then
            return
        end

        if Save().InvNoFriend[InviterPlayerGUID] then
            Save().InvNoFriend[InviterPlayerGUID] =nil

            WoWTools_Print(
                WoWTools_InviteMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_L.REMOVE,
                WoWTools_UnitMixin:GetLink(nil, InviterPlayerGUID, nil, false)
            )
            Accept()


        else

            Save().InvNoFriend[InviterPlayerGUID] = (Save().InvNoFriend[InviterPlayerGUID] or 0)+ 1
            Save().InvNoFriendNum=Save().InvNoFriendNum+1

            WoWTools_Print(
                WoWTools_InviteMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_L.ADD,
                WoWTools_UnitMixin:GetLink(nil, InviterPlayerGUID, nil, false)
            )
            DeclineOnly()--ya se sumó arriba
        end
    end

    local oldOnUpdate= StaticPopupDialogs["PARTY_INVITE"].OnUpdate--encadenar, no pisar
    StaticPopupDialogs["PARTY_INVITE"].OnUpdate=function(self, ...)
        if oldOnUpdate then
            oldOnUpdate(self, ...)
        end
        if InvTimer and IsModifierKeyDown() then
            InvTimer:Cancel()
            InvTimer=nil
            WoWTools_CooldownMixin:Setup(self, nil, select(2, WoWTools_DataMixin:StaticPopup_FindVisible('PARTY_INVITE')), nil, true, true, nil)
        end
    end

    WoWTools_DataMixin:Hook(StaticPopupDialogs["PARTY_INVITE"], 'OnHide', function(self)
        if InvTimer then InvTimer:Cancel() InvTimer=nil end
        InviterPlayerGUID=nil
        WoWTools_CooldownMixin:Setup(self)
    end)

    Init=function()end
end











function WoWTools_InviteMixin:Init_StaticPopup()
    Init()
end