


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
end


WoWTools_Module:Register({
    key= 'Plus_Challenges',
    name= 'Module.Mythic+',
    icon= 'UI-HUD-MicroMenu-Groupfinder-Mouseover',
    group= 'World',
    defaults= {
        rightX= 2,
        rightY= -22,

        hidePort= true,
        portScale=1,
    },
    tooltip= 'Tip.Challenge.Module',
    mixin= WoWTools_ChallengeMixin,
    onLoad= function(_, save)
        save.hideAffixSay= nil
    end,
    onEnable= function()
        for _, tab in pairs(WoWTools_ChallengesSpellData) do
           WoWTools_DataMixin:Load(tab.spell, 'spell')
        end
    end,
    blizzard= {
        Blizzard_ChallengesUI= Init,
        Blizzard_WeeklyRewards= function()
            WoWTools_ChallengeMixin:Blizzard_WeeklyRewards()
        end,
    },
    events= {
        CHALLENGE_MODE_COMPLETED= function()
            WoWTools_ChallengeMixin:Say_ChallengeComplete()
            --WoWTools_ChallengeMixin:Chat_Affix()
        end,
        --CHALLENGE_MODE_START
        PLAYER_ENTERING_WORLD= function(_, save)
            WoWTools_ChallengeMixin:AvailableRewards()

            if save.allShowEndKeystoneSay then
                WoWTools_ChallengeMixin:Say_ChallengeComplete()
            end
            return true
        end,
    },
})
