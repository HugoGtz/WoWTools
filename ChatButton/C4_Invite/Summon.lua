
local Init= WoWTools_Once(function()
    WoWTools_DataMixin:Hook(StaticPopupDialogs["CONFIRM_SUMMON"], "OnUpdate", function(self)
        if IsModifierKeyDown() or self.isCancelledAuto or not WoWTools_InviteMixin:Save().Summon then
            if not self.isCancelledAuto then
                WoWTools_CooldownMixin:Setup(self, nil, C_SummonInfo.GetSummonConfirmTimeLeft(), nil, true, true, nil)
                if self.SummonTimer then
                    self.SummonTimer:Cancel()
                    self.SummonTimer=nil
                end
            end
            self.isCancelledAuto=true
            return
        end

        if not InCombatLockdown() and PlayerCanTeleport() then
            if not self.enabledAutoSummon then
                self.enabledAutoSummon= true
                if self.SummonTimer then
                    self.SummonTimer:Cancel()
                    self.SummonTimer= nil
                end
                local sec= WoWTools_InviteMixin:Save().SummonSec or 3--espera configurable (por defecto 3 s)
                WoWTools_CooldownMixin:Setup(self, nil, sec, nil, true, true, nil)

                self.SummonTimer= C_Timer.NewTimer(sec, function()
                    if not InCombatLockdown() and PlayerCanTeleport() then
                        C_SummonInfo.ConfirmSummon()
                        StaticPopup_Hide("CONFIRM_SUMMON")
                    end
                end)
            end

        elseif self.enabledAutoSummon then
            WoWTools_CooldownMixin:Setup(self, nil, C_SummonInfo.GetSummonConfirmTimeLeft(), nil, true, true, nil)
            if self.SummonTimer then
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
        WoWTools_DataMixin:PlaySound(SOUNDKIT.IG_PLAYER_INVITE)
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
end)












function WoWTools_InviteMixin:Init_Summon()
    Init()
end