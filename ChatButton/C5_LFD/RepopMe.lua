--释放, 复活

local function Save()
    return WoWToolsPlusSave['ChatButton_LFD'] or {}
end
local frame







local function Init()
    if not Save().ReMe then
        return
    end

    frame= CreateFrame('Frame')
    frame:Hide()

    function frame:settings()
        self:UnregisterAllEvents()

        if Save().ReMe then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            if WoWTools_MapMixin:IsInPvPArea() then
                self:RegisterEvent('PLAYER_DEAD')
                self:RegisterEvent('AREA_SPIRIT_HEALER_IN_RANGE')

                if WoWTools_DataMixin.Player.husandro then
                    print(WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,'开启了PvP区域自动释放和复活')
                end

            elseif Save().ReMe_AllZone and (select(2, IsInInstance())=='none' or not IsInGroup()) then
                self:RegisterEvent('PLAYER_DEAD')
                self:RegisterEvent('CORPSE_IN_RANGE')
                self:RegisterEvent('CORPSE_OUT_OF_RANGE')

                if WoWTools_DataMixin.Player.husandro then
                    print(WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_L['Auto release and resurrect enabled in all zones']
                    )
                end
            end
        end
    end



    frame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' then
            C_Timer.After(2, function()
                self:settings()
            end)

        elseif event=='PLAYER_DEAD' then
            --no liberar si hay piedra de alma/reencarnación o se pulsa un modificador
            local options= C_DeathInfo.GetSelfResurrectOptions and C_DeathInfo.GetSelfResurrectOptions()
            if IsModifierKeyDown()
                or (options and canaccesstable(options) and #options>0)
                or (HasSoulstone and HasSoulstone())
            then
                return
            end

            RepopMe()--死后将你的幽灵释放到墓地。

            if HasNoReleaseAura() then
                if WoWTools_MapMixin:IsInPvPArea() then
                    print(
                        WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        '|cnGREEN_FONT_COLOR:',
                        WoWTools_L.BATTLE_PET_RELEASE
                    )

                else

                    print(
                        WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        '|cnGREEN_FONT_COLOR:'..WoWTools_L.BATTLE_PET_RELEASE..'|r',
                        SecondsToTime(GetCorpseRecoveryDelay() or 0)
                    )
                end
            end


        elseif event=='AREA_SPIRIT_HEALER_IN_RANGE' then

            AcceptAreaSpiritHeal()--在范围内时在战场上注册灵魂治疗师的复活计时器

            print(
                WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnGREEN_FONT_COLOR:',
                WoWTools_L.RESURRECT
            )

            local time= GetAreaSpiritHealerTime()
            if time>0 then
                print(
                    WoWTools_DataMixin.Icon.icon2..(WoWTools_L.SPIRIT_HEALER_RELEASE_RED),
                    SecondsToTime(time)
                )
            end

        elseif event=='CORPSE_IN_RANGE' then
            local time= GetCorpseRecoveryDelay()
            if time==0 then

                C_Timer.After(1, function()
                    RetrieveCorpse()--当玩家站在它的尸体附近时复活。
                    print(
                        WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        '|cnGREEN_FONT_COLOR:'..(WoWTools_L.RESURRECT)
                    )
                end)
                self:SetShown(false)

            else

                print(
                    WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    '|cnGREEN_FONT_COLOR:'..(WoWTools_L.RESURRECT)..'|r', SecondsToTime(time)
                )
                print(
                    WoWTools_DataMixin.Icon.icon2..'|cffff00ffAlt',
                    WoWTools_L.CANCEL
                )
                self:SetShown(true)

            end

        elseif event=='CORPSE_OUT_OF_RANGE' then
            self:SetShown(false)

        end
    end)


    frame:SetScript('OnUpdate', function(self)
        if IsModifierKeyDown() then
            print(
                WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnGREEN_FONT_COLOR:',
                WoWTools_L['CANCEL+RESURRECT']
            )
            self:Hide()

        elseif GetCorpseRecoveryDelay()==0 then
            C_Timer.After(1, function() RetrieveCorpse() end)--当玩家站在它的尸体附近时复活。
            self:Hide()
        end
    end)


    frame:settings()





    Init=function()
        frame:settings()
    end
end







function WoWTools_LFDMixin:Init_RepopMe()--释放, 复活
    Init()
end
