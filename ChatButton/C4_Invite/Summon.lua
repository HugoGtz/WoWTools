
local function Save()
    return WoWToolsPlusSave['ChatButton_Invite'] or {}
end














--接受, 召唤
local function Init()
    WoWTools_DataMixin:Hook(StaticPopupDialogs["CONFIRM_SUMMON"], "OnUpdate", function(self)
        if IsModifierKeyDown() or self.isCancelledAuto or not Save().Summon then
            if not self.isCancelledAuto then
                WoWTools_CooldownMixin:Setup(self, nil, C_SummonInfo.GetSummonConfirmTimeLeft(), nil, true, true, nil)--冷却条
                if self.SummonTimer then--取消，计时
                    self.SummonTimer:Cancel()
                    self.SummonTimer=nil
                end
            end
            self.isCancelledAuto=true
            return
        end

        if not InCombatLockdown() and PlayerCanTeleport() then--启用，召唤
            if not self.enabledAutoSummon then
                self.enabledAutoSummon= true
                if self.SummonTimer then
                    self.SummonTimer:Cancel()
                    self.SummonTimer= nil
                end
                WoWTools_CooldownMixin:Setup(self, nil, 3, nil, true, true, nil)--冷却条

                self.SummonTimer= C_Timer.NewTimer(3, function()
                    if not InCombatLockdown() and PlayerCanTeleport() then
                        C_SummonInfo.ConfirmSummon()
                        StaticPopup_Hide("CONFIRM_SUMMON")
                    end
                end)
            end

        elseif self.enabledAutoSummon then--取消，召唤
            WoWTools_CooldownMixin:Setup(self, nil, C_SummonInfo.GetSummonConfirmTimeLeft(), nil, true, true, nil)--冷却条
            if self.SummonTimer then--取消，计时
                self.SummonTimer:Cancel()
                self.SummonTimer=nil
            end
            self.enabledAutoSummon=nil
        end
    end)

    local function onHide(self)
        if self.SummonTimer then
            self.SummonTimer:Cancel()
            self.SummonTimer=nil
        end
        self.enabledAutoSummon=nil
        self.isCancelled=nil
        self.isCancelledAuto=nil--si no, tras cancelar una vez ya no se autoacepta nunca
    end
    if StaticPopupDialogs["CONFIRM_SUMMON"].OnHide then--encadenar en vez de pisar la de Blizzard
        WoWTools_DataMixin:Hook(StaticPopupDialogs["CONFIRM_SUMMON"], "OnHide", onHide)
    else
        StaticPopupDialogs["CONFIRM_SUMMON"].OnHide= onHide
    end

    WoWTools_DataMixin:Hook(StaticPopupDialogs["CONFIRM_SUMMON"], "OnShow",function()--StaticPopup.lua
        WoWTools_DataMixin:PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音
        local name= C_SummonInfo.GetSummonConfirmSummoner()
        local info= WoWTools_DataMixin.GroupGuid[name]
        if info and info.guid then
            local playerInfo= WoWTools_UnitMixin:GetPlayerInfo(nil, info.guid, nil, {reLink=true})
            name= playerInfo~='' and playerInfo or name
        end
        WoWTools_Print(
            WoWTools_InviteMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_L.SUMMON,
            name,
            '|A:poi-islands-table:0:0|a|cnGREEN_FONT_COLOR:',
            WoWTools_TextMixin:CN(C_SummonInfo.GetSummonConfirmAreaName()),
            WoWTools_TextMixin:CN(C_SummonInfo.GetSummonReason ()),
            WoWTools_TimeMixin:SecondsToClock(C_SummonInfo.GetSummonConfirmTimeLeft() or 0)
        )
    end)

    Init=function()end
end












function WoWTools_InviteMixin:Init_Summon()
    Init()
end