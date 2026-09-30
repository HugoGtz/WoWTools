


local function Save()
    return WoWToolsPlusSave['Plus_Challenges']
end


local function Init()
    WoWTools_ChallengeMixin:ChallengesUI_Info()
    WoWTools_ChallengeMixin:ChallengesUI_Porta()
    --WoWTools_ChallengeMixin:ChallengesUI_Left()
    WoWTools_ChallengeMixin:ChallengesUI_Right()
    WoWTools_ChallengeMixin:ChallengesUI_Activities()
    WoWTools_ChallengeMixin:ChallengesUI_Affix()
    WoWTools_ChallengeMixin:ChallengesUI_Guild()
    WoWTools_ChallengeMixin:ChallengesUI_Menu()
    WoWTools_ChallengeMixin:ChallengesKeystoneFrame()

    Init=function()end
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Plus_Challenges']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Challenges'], {

                rightX= 2,
                rightY= -22,

                hidePort= true,
                portScale=1,


            })


            Save().hideAffixSay= nil

            WoWTools_ChallengeMixin.addName= '|A:UI-HUD-MicroMenu-Groupfinder-Mouseover:0:0|a'..(WoWTools_L['Module.Mythic+'])

            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_ChallengeMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    WoWTools_Print(
                        WoWTools_ChallengeMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_L.REQUIRES_RELOAD
                    )
                end,
                tooltip= WoWTools_L['Tip.Challenge.Module']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
            })

            if Save().disabled then
                self:SetScript('OnEvent', nil)
                self:UnregisterEvent(event)

            else
                self:RegisterEvent('CHALLENGE_MODE_COMPLETED')
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                --self:RegisterEvent('CHALLENGE_MODE_START')

                for _, tab in pairs(WoWTools_ChallengesSpellData) do
                   WoWTools_DataMixin:Load(tab.spell, 'spell')
                end

                if C_AddOns.IsAddOnLoaded('Blizzard_WeeklyRewards') then
                    WoWTools_ChallengeMixin:Blizzard_WeeklyRewards()
                end

                if C_AddOns.IsAddOnLoaded('Blizzard_ChallengesUI') then
                    Init()
                end
            end

        elseif arg1=='Blizzard_ChallengesUI' and WoWToolsPlusSave then
            Init()

        elseif arg1=='Blizzard_WeeklyRewards' and WoWToolsPlusSave then
            WoWTools_ChallengeMixin:Blizzard_WeeklyRewards()
        end

    elseif event=='CHALLENGE_MODE_COMPLETED' then
        WoWTools_ChallengeMixin:Say_ChallengeComplete()

        --WoWTools_ChallengeMixin:Chat_Affix()

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_ChallengeMixin:AvailableRewards()

        if Save().allShowEndKeystoneSay then
            WoWTools_ChallengeMixin:Say_ChallengeComplete()
        end
        self:UnregisterEvent(event)
    end
end)