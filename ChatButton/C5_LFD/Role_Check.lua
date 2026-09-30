
local function Save()
    return WoWToolsPlusSave['ChatButton_LFD']
end


local function Set_PvERoles()
    local isTank, isHealer, isDPS = select(2, GetLFGRoles())

    if Save().autoSetRole or not (isTank or isHealer or isDPS) then
        local role = select(5, C_SpecializationInfo.GetSpecializationInfo(GetSpecialization() or 0))
        if role=='TANK' then
            isTank, isHealer, isDPS=true, false, false
        elseif role=='HEALER' then
            isTank, isHealer, isDPS=false, true, false
        elseif role=='DAMAGER' then
            isTank, isHealer, isDPS=false, false ,true
        else
            isTank, isHealer, isDPS=true, true, true
        end

        SetLFGRoles(true , isTank, isHealer, isDPS)
    end
end


local function Set_PvPRoles()
    local tank, healer, dps = GetPVPRoles()

    if Save().autoSetRole or not (tank or healer or dps) then
        tank, healer, dps= true,true,true
        local sid=GetSpecialization()
        if sid then
            local role = select(5, C_SpecializationInfo.GetSpecializationInfo(sid))
            if role then
                if role=='TANK' then
                    tank, healer, dps = true, false, false
                elseif role=='HEALER' then
                    tank, healer, dps= false, true, false
                elseif role=='DAMAGER' then
                    tank, healer, dps= false, false,true
                end
            end
        end

        SetPVPRoles(tank, healer, dps)
    end
end

--StaticPopupTimeoutSec = 60


local function Init()
    if not Save().autoSetPvPRole then
        return
    end


    PVPReadyDialog:HookScript('OnShow', function(self)
        WoWTools_DataMixin:PlaySound()
        WoWTools_CooldownMixin:Setup(self, nil, BATTLEFIELD_TIMER_THRESHOLDS[3] or 60, nil, true)
    end)

    PVPTimerFrame:HookScript('OnShow', function(self)
        WoWTools_DataMixin:PlaySound()
        WoWTools_CooldownMixin:Setup(self, nil, BATTLEFIELD_TIMER_THRESHOLDS[3] or 60, nil, true)
    end)


    function LFDRoleCheckPopup:CancellORSetTime(seconds)
        if self.acceptTime then
            self.acceptTime:Cancel()
            self.acceptTime=nil
        end
        if not seconds then
            if self:IsShown() then
                WoWTools_CooldownMixin:Setup(self, self.onShowTime, StaticPopupTimeoutSec *2, nil, true, true)
            else
                WoWTools_CooldownMixin:Setup(self)
            end
        else
            WoWTools_CooldownMixin:Setup(self, nil, seconds, nil, true, true)
        end
    end



    LFDRoleCheckPopup:HookScript("OnUpdate",function(self)
        if IsModifierKeyDown() then
            self:CancellORSetTime(nil)
        end
    end)

    LFDRoleCheckPopup:HookScript("OnHide",function(self)
        self:CancellORSetTime(nil)
        self.onShowTime=nil
    end)

    LFDRoleCheckPopup:HookScript("OnShow",function(self)
        self.onShowTime= GetTime()

        WoWTools_DataMixin:PlaySound()
        if IsModifierKeyDown() then
            return
        end

        local _, _, _, _, _, isBGRoleCheck = GetLFGRoleUpdate();
        if isBGRoleCheck  then
            Set_PvPRoles()
        else
            Set_PvERoles()
        end

        if not LFDRoleCheckPopupAcceptButton:IsEnabled() then
            LFDRoleCheckPopup_UpdateAcceptButton()
        end

        WoWTools_Print(
            WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,

            '|cnGREEN_FONT_COLOR:'
            ..(WoWTools_L.ROLE_POLL)
            ..': |cfff00fff'.. SecondsToTime(Save().sec or 5)..'|r '
            ..(WoWTools_L.ACCEPT)..'|r',

            '|cnWARNING_FONT_COLOR:'..'Alt '
            ..(WoWTools_L.CANCEL)
        )

        self:CancellORSetTime(Save().sec or 5)

        self.acceptTime= C_Timer.NewTimer(Save().sec or 5, function()
            if LFDRoleCheckPopupAcceptButton:IsEnabled() and not IsModifierKeyDown() then
                local t=LFDRoleCheckPopupDescriptionText:GetText()
                if t~='' then
                    WoWTools_Print(
                        WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        '|cffff00ff',
                        WoWTools_TextMixin:CN(t)
                    )
                end
                LFDRoleCheckPopupAcceptButton:Click()--LFDRoleCheckPopupAccept_OnClick
            end
        end)
    end)


    WoWTools_DataMixin:Hook('RolePollPopup_Show', function(self)
        WoWTools_DataMixin:PlaySound()
        if IsModifierKeyDown() or InCombatLockdown() then
            return
        end

        local icon
        local btn2

        local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles("player")
        local role = select(5, C_SpecializationInfo.GetSpecializationInfo(GetSpecialization() or 0))
        if role=='DAMAGER' and canBeDamager then
            btn2= RolePollPopupRoleButtonDPS
            icon= WoWTools_DataMixin.Icon['DAMAGER']
        elseif role=='TANK' and canBeTank then
            btn2= RolePollPopupRoleButtonTank
            icon= WoWTools_DataMixin.Icon['TANK']
        elseif role=='HEALER' and canBeHealer then
            btn2= RolePollPopupRoleButtonHealer
            icon= WoWTools_DataMixin.Icon['HEALER']
        end


        if btn2 then
            btn2.checkButton:SetChecked(true)
            WoWTools_DataMixin:Call('RolePollPopupRoleButtonCheckButton_OnClick', btn2.checkButton, btn2)
            WoWTools_CooldownMixin:Setup(self, nil, Save().sec or 5, nil, true)
            self.aceTime=C_Timer.NewTimer(Save().sec or 5, function()
                if self.acceptButton:IsEnabled()
                    and self:IsShown()
                    and not IsMetaKeyDown()
                    and not InCombatLockdown()
                then
                    self.acceptButton:Click()
                    WoWTools_Print(
                        WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_L.ROLE_POLL,
                        icon or ''
                    )
                end
            end)
        end
    end)

    --RolePollPopup:HookScript('OnShow', function(self)


    RolePollPopup:HookScript('OnUpdate', function(self)
        if IsModifierKeyDown() or not self.acceptButton:IsEnabled() or InCombatLockdown() then
            if self.aceTime then
                self.aceTime:Cancel()
                self.aceTime= nil
            end
            WoWTools_CooldownMixin:Setup(self)
        end
    end)

    RolePollPopup:HookScript('OnHide', function(self)
        if self.aceTime then
            self.aceTime:Cancel()
            self.aceTime= nil
        end
    end)


    LFGListInviteDialog:HookScript("OnShow", function(self)
        WoWTools_DataMixin:PlaySound(SOUNDKIT.IG_PLAYER_INVITE)

        WoWTools_CooldownMixin:Setup(self, nil, StaticPopupTimeoutSec, nil, true, true, nil)

        if not self.resultID then
            return
        end

        local status, _, _, role= select(2,C_LFGList.GetApplicationInfo(self.resultID))
        local info= C_LFGList.GetSearchResultInfo(self.resultID)

        if status~="invited" or not info then
            return
        end

        local leaderGuid = info.partyGUID and select(8, C_SocialQueue.GetGroupInfo(info.partyGUID))

        WoWTools_Print(
            WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,

            info.leaderOverallDungeonScore and info.leaderOverallDungeonScore>0 and
                '|T4352494:0|t'..WoWTools_ChallengeMixin:KeystoneScorsoColor(info.leaderOverallDungeonScore)
            or '',

            info.leaderPvpRatingInfo and info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating>0 and
                '|A:pvptalents-warmode-swords:0:0|a|cnWARNING_FONT_COLOR:'..info.leaderPvpRatingInfo.rating..'|r'
            or '',

            (info.leaderName or leaderGuid) and format(
                WoWTools_L.COMMUNITY_INVITATION_FRAME_INVITATION_TEXT,
                WoWTools_UnitMixin:GetLink(nil, leaderGuid, info.leaderName, false)..' '
            )
            or '',

            info.name,

            WoWTools_DataMixin.Icon[role] or '',

            info.numMembers and info.numMembers>0 and
                (WoWTools_L.PLAYERS_IN_GROUP)..'|cff00ff00 '..info.numMembers..'|r'
            or '',

            info.numBNetFriends and info.numBNetFriends>0 and
            '|cff00ccff'..WoWTools_DataMixin.Icon.wow2..(WoWTools_L['PLAYERS_IN_GROUP~2'])..' '..info.numMembers..'|r'
            or '',

            info.numCharFriends and info.numCharFriends>0 and
            '|cffedd100'..WoWTools_DataMixin.Icon.wow2..(WoWTools_L.FRIEND)..' '..info.numCharFriends..'|r'
            or '',

            info.autoAccept and
                '|cnGREEN_FONT_COLOR:'..(WoWTools_L['SELF_CAST_AUTO+INVITE'])..'|r'
            or '',

            info.activityID and
                '|cffff00ff'..WoWTools_TextMixin:CN(C_LFGList.GetActivityFullName(info.activityID))..'|r'
            or '',

            info.isWarMode and-- info.isWarMode ~= C_PvP.IsWarModeDesired() and
                '|A:pvptalents-warmode-swords:0:0|a|cnWARNING_FONT_COLOR:'..(WoWTools_L.TALENT_FRAME_LABEL_WARMODE)..'|r'
            or ''
        )
    end)


    LFGInvitePopup:HookScript("OnShow", function(self)
        WoWTools_DataMixin:PlaySound()
        WoWTools_CooldownMixin:Setup(self, nil, self.timeOut and StaticPopupTimeoutSec, nil, true, true)
    end)

    LFGDungeonReadyDialog:HookScript("OnShow", function(self)
        WoWTools_DataMixin:PlaySound()
        WoWTools_CooldownMixin:Setup(self, nil, self.timeOut or 38, nil, true, true)
    end)
    WoWTools_DataMixin:Hook('LFGDungeonReadyPopup_OnFail', function()
        if LFGDungeonReadyPopup:IsShown() then
            WoWTools_CooldownMixin:Setup(LFGDungeonReadyPopup, nil, LFGDungeonReadyPopup.closeIn or 5, nil, true, true)
        end
    end)



    LFGDungeonReadyDialog.bossTipsLabel= WoWTools_LabelMixin:Create(LFGDungeonReadyDialog)
    LFGDungeonReadyDialog.bossTipsLabel:SetPoint('LEFT', LFGDungeonReadyDialog, 'RIGHT', 4, 0)

    LFGDungeonReadyDialog:HookScript('OnHide', function(self)
        self.bossTipsLabel:SetText('')
    end)

    LFGDungeonReadyDialog:HookScript('OnShow', function(self)
        local totalEncounters= select(9, GetLFGProposal())
        local text
        local dead=0
        for i=1, totalEncounters or 0 do
            local bossName, _, isKilled = GetLFGProposalEncounter(i)
            if bossName then
                text= (text and text..'|n' or '')..i..') '

                if isKilled then
                    text= text
                        ..'|A:common-icon-checkmark:0:0|a|cnWARNING_FONT_COLOR:'..WoWTools_TextMixin:CN(bossName)
                        ..'|r |cffffffff'..(WoWTools_L.BOSS_DEAD)..'|r'
                    dead= dead+1
                else
                    text= text
                        ..'|A:QuestLegendary:0:0|a|cnGREEN_FONT_COLOR:'..WoWTools_TextMixin:CN(bossName)
                        ..'|r |cffffffff'..(WoWTools_L.BOSS_ALIVE)..'|r'
                end
            end
        end

        if text then
            text= (totalEncounters==dead and '|cff626262' or '|cffffffff')
                ..(WoWTools_L.BOSSES)
                ..format(WoWTools_L['BOSSES_KILLED~2'], dead, totalEncounters)
                ..'|r|n|n'
                ..text
                ..'|n|n'..WoWTools_ChatMixin.addName..' '..WoWTools_LFDMixin.addName
        end
        self.bossTipsLabel:SetText(text or '')
    end)


    LFGDungeonReadyDialogCloseButton:HookScript('OnLeave', GameTooltip_Hide)
    LFGDungeonReadyDialogCloseButton:HookScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip,
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_L.HIDE)
        )
        GameTooltip:Show()
    end)

    Menu.ModifyMenu("MENU_QUEUE_STATUS_FRAME", function(self, root)
        if self:IsMouseOver() then
            WoWTools_LFDMixin:ShowMenu_LFGDungeonReadyDialog(root)
        end
    end)


    EventRegistry:RegisterFrameEventAndCallback("PLAYER_SPECIALIZATION_CHANGED", function(_, arg1)
        if arg1=='player' and Save().autoSetRole then
            Set_PvERoles()
            Set_PvPRoles()
        end
    end)



    EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
        Set_PvERoles()
        Set_PvPRoles()

        if GetLFGProposal() and not LFGDungeonReadyPopup:IsShown() then
            StaticPopupSpecial_Show(LFGDungeonReadyPopup)
            WoWTools_DataMixin:Call('LFGDungeonReadyPopup_Update')
        end
        EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
    end)

    Init=function()
        Set_PvERoles()
        Set_PvPRoles()
    end
end


function WoWTools_LFDMixin:Init_RolePollPopup()
    Init()
end