local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2, name
    local isInCombat= InCombatLockdown()


    name='|A:QuestLegendary:0:0|a'..(WoWTools_L['INSTANCE+INFO'])
    sub= root:CreateCheckbox(
        name,
    function()
        return not WoWTools_ChallengeMixin:Save().hideIns
    end, function()
        WoWTools_ChallengeMixin:Save().hideIns = not WoWTools_ChallengeMixin:Save().hideIns and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Info()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Challenge.DungeonInfo'])

--gsub
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return WoWTools_ChallengeMixin:Save().insNamegsub or 0
        end, setValue=function(value)
            WoWTools_ChallengeMixin:Save().insNamegsub=value>0 and value or nil
            WoWTools_ChallengeMixin:ChallengesUI_Info()
        end,
        name=WoWTools_L['Truncate'],
        minValue=0,
        maxValue=30,
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_L['INSTANCE+NAME'])
            tooltip:AddLine(WoWTools_L['Truncate'])
            tooltip:AddLine(" ")
            tooltip:AddLine(WoWTools_L['0 - Do not truncate'])
        end,
        step=1,
    })
    sub:CreateSpacer()

    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return WoWTools_ChallengeMixin:Save().insScale or 1
    end, function(value)
        WoWTools_ChallengeMixin:Save().insScale=value
        WoWTools_ChallengeMixin:ChallengesUI_Info()
    end, function()
        WoWTools_ChallengeMixin:Save().insScale=nil
        WoWTools_ChallengeMixin:Save().insNamegsub=nil
        WoWTools_ChallengeMixin:ChallengesUI_Info()
    end)

    sub:CreateSpacer()
    sub:CreateTitle(name)


    sub= root:CreateCheckbox(
        '|A:WarlockPortal-Yellow-32x32:0:0|a|cnWARNING_FONT_COLOR:'
        ..(WoWTools_L['SPELLS~2']),
    function()
        return not WoWTools_ChallengeMixin:Save().hidePort
    end, function()
        WoWTools_ChallengeMixin:Save().hidePort = not WoWTools_ChallengeMixin:Save().hidePort and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Challenge.Portals'])
        GameTooltip_AddErrorLine(tooltip, WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        GameTooltip_AddErrorLine(tooltip, 'Cannot: '..MicroButtonTooltipText(BINDING_NAME_TOGGLEGROUPFINDER, "TOGGLEGROUPFINDER"))
    end)
    sub:SetEnabled(not isInCombat)

    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return WoWTools_ChallengeMixin:Save().portScale or 1
    end, function(value)
        WoWTools_ChallengeMixin:Save().portScale=value
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end, function()
        WoWTools_ChallengeMixin:Save().portScale=nil
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end)

    sub:CreateDivider()
    --sub:CreateTitle(name)
    WoWTools_MenuMixin:Reload(sub)


    root:CreateDivider()

    --WoWTools_ChallengeMixin:ChallengesUI_Left_Menu(self, root)


    local hasRewar= C_WeeklyRewards.HasAvailableRewards()
    name= (hasRewar and '|cnGREEN_FONT_COLOR:' or '')
        ..'|A:'..(WoWTools_DataMixin.Player.Faction=='Alliance' and 'activities-chest-sw' or 'activities-chest-org')..':0:0|a'
        ..(WoWTools_L.RATED_PVP_WEEKLY_VAULT)
        ..(hasRewar and '|A:BonusLoot-Chest:0:0|a' or '')

    sub= root:CreateCheckbox(
        name,
    function()
        return not WoWTools_ChallengeMixin:Save().hideActivities
    end, function()
        WoWTools_ChallengeMixin:Save().hideActivities= not WoWTools_ChallengeMixin:Save().hideActivities and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Activities()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Challenge.Vault'])
        WoWTools_ChallengeMixin:ActivitiesTooltip(tooltip)
    end)

    sub2=sub:CreateCheckbox(
        WoWTools_L.RATED_PVP_WEEKLY_VAULT,
    function()
        return WeeklyRewardsFrame and WeeklyRewardsFrame:IsShown()
    end, WoWTools_LoadUIMixin.WeeklyRewards)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_L.WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS)
    end)
    sub:CreateDivider()

    local tipSub= sub:CreateCheckbox(
        'PvP '
        ..(WoWTools_L.INFO),
    function()
        return not WoWTools_ChallengeMixin:Save().activitiesHidePvP
    end, function()
        WoWTools_ChallengeMixin:Save().activitiesHidePvP= not WoWTools_ChallengeMixin:Save().activitiesHidePvP and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Activities()
    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.Challenge.VaultPvP'])


--X
    sub:CreateSpacer()
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return WoWTools_ChallengeMixin:Save().activitiesX or 10
        end, setValue=function(value)
            WoWTools_ChallengeMixin:Save().activitiesX=value
            WoWTools_ChallengeMixin:ChallengesUI_Activities()
        end,
        name='X',
        minValue=-1024,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()

--Y
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return WoWTools_ChallengeMixin:Save().activitiesY or -53
        end, setValue=function(value)
            WoWTools_ChallengeMixin:Save().activitiesY=value
            WoWTools_ChallengeMixin:ChallengesUI_Activities()
        end,
        name='Y',
        minValue=-1024,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()

    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return WoWTools_ChallengeMixin:Save().activitiesScale or 1
    end, function(value)
        WoWTools_ChallengeMixin:Save().activitiesScale=value
        WoWTools_ChallengeMixin:ChallengesUI_Activities()
    end, function()
        WoWTools_ChallengeMixin:Save().activitiesScale=nil
        WoWTools_ChallengeMixin:Save().activitiesX=nil
        WoWTools_ChallengeMixin:Save().activitiesY=nil
        WoWTools_ChallengeMixin:ChallengesUI_Activities()
    end)

    sub:CreateSpacer()
    sub:CreateTitle(name)


    local isInGuild= IsInGuild()
    name= '|A:communities-guildbanner-background:0:0|a'
        ..(isInGuild and '' or '|cff828282')
        ..(WoWTools_L.GUILD_CHALLENGE_LABEL)
    sub= root:CreateCheckbox(
        name,
    function()
        return not WoWTools_ChallengeMixin:Save().hideGuild
    end, function()
        WoWTools_ChallengeMixin:Save().hideGuild= not WoWTools_ChallengeMixin:Save().hideGuild and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Guild()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Challenge.Guild'])
        if not isInGuild then
            tooltip:AddLine(WoWTools_L.ERR_GUILD_PLAYER_NOT_IN_GUILD)
        end
    end)
--X
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return WoWTools_ChallengeMixin:Save().guildX or -15
    end, setValue=function(value)
        WoWTools_ChallengeMixin:Save().guildX=value
        WoWTools_ChallengeMixin:ChallengesUI_Guild()
    end,
        name='X',
        minValue=-1024,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()

--Y
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return WoWTools_ChallengeMixin:Save().guildY or -32
    end, setValue=function(value)
        WoWTools_ChallengeMixin:Save().guildY=value
        WoWTools_ChallengeMixin:ChallengesUI_Guild()
    end,
        name='Y',
        minValue=-1024,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()


    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return WoWTools_ChallengeMixin:Save().guildBgAlpha or 0.5
        end, setValue=function(value)
            WoWTools_ChallengeMixin:Save().guildBgAlpha=value
            WoWTools_ChallengeMixin:ChallengesUI_Guild()
        end,
        name=WoWTools_L.HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY,
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
    })
    sub:CreateSpacer()

    
    sub:CreateSpacer()
    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return WoWTools_ChallengeMixin:Save().guildScale or 1
    end, function(value)
        WoWTools_ChallengeMixin:Save().guildScale=value
        WoWTools_ChallengeMixin:ChallengesUI_Guild()
    end, function()
        WoWTools_ChallengeMixin:Save().guildScale=nil
        WoWTools_ChallengeMixin:Save().guildX=nil
        WoWTools_ChallengeMixin:Save().guildY=nil
        WoWTools_ChallengeMixin:Save().guildBgAlpha=nil
        WoWTools_ChallengeMixin:ChallengesUI_Guild()
    end)

    sub:CreateSpacer()
    sub:CreateTitle(name)


    name= '|T463829:0|t'
        ..(C_MythicPlus.GetCurrentSeason()==WoWTools_DataMixin.SeasonAffixSchedule and '' or '|cff828282')
        ..WoWTools_L['Affix list']
    sub= root:CreateCheckbox(
        name,
    function()
        return not WoWTools_ChallengeMixin:Save().hideAffix
    end, function()
        WoWTools_ChallengeMixin:Save().hideAffix= not WoWTools_ChallengeMixin:Save().hideAffix and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Affix()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Challenge.Affix'])
        local season= C_MythicPlus.GetCurrentSeason() or 0
        tooltip:AddLine(
            format(WoWTools_L.MYTHIC_PLUS_SEASON_DESC3, season..'')
        )
        if season~=WoWTools_DataMixin.SeasonAffixSchedule then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(
                '|cnWARNING_FONT_COLOR:'
                ..(WoWTools_L['Current season data mismatch'])
            )
        end
    end)


--W
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return WoWTools_ChallengeMixin:Save().affixW or 238
    end, setValue=function(value)
        WoWTools_ChallengeMixin:Save().affixW=value
        WoWTools_ChallengeMixin:ChallengesUI_Affix()
    end,
        name=WoWTools_L.HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH,
        minValue=220,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()

--H
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return WoWTools_ChallengeMixin:Save().affixH or 177
    end, setValue=function(value)
        WoWTools_ChallengeMixin:Save().affixH=value
        WoWTools_ChallengeMixin:ChallengesUI_Affix()
    end,
        name=WoWTools_L.HUD_EDIT_MODE_SETTING_CHAT_FRAME_HEIGHT,
        minValue=58,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()


--X
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return WoWTools_ChallengeMixin:Save().affixX or -45
    end, setValue=function(value)
        WoWTools_ChallengeMixin:Save().affixX=value
        WoWTools_ChallengeMixin:ChallengesUI_Affix()
    end,
        name='X',
        minValue=-2048,
        maxValue=2048,
        step=1,
    })
sub:CreateSpacer()

--Y
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return WoWTools_ChallengeMixin:Save().affixY or 300
    end, setValue=function(value)
        WoWTools_ChallengeMixin:Save().affixY=value
        WoWTools_ChallengeMixin:ChallengesUI_Affix()
    end,
        name='Y',
        minValue=-2048,
        maxValue=2048,
        step=1,
    })
    sub:CreateSpacer()

    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return WoWTools_ChallengeMixin:Save().affixScale or 0.4
    end, function(value)
        WoWTools_ChallengeMixin:Save().affixScale=value
        WoWTools_ChallengeMixin:ChallengesUI_Affix()
    end, function()
        WoWTools_ChallengeMixin:Save().affixScale=nil
        WoWTools_ChallengeMixin:Save().affixW=nil
        WoWTools_ChallengeMixin:Save().affixH=nil
        WoWTools_ChallengeMixin:Save().affixX=nil
        WoWTools_ChallengeMixin:Save().affixY=nil
        WoWTools_ChallengeMixin:ChallengesUI_Affix()
    end)

sub:CreateSpacer()
sub:CreateTitle(name)


    name= '|A:challenges-medal-gold:0:0|a'
    ..(WoWTools_L['PLAYER_DIFFICULTY5+INFO'])
    sub= root:CreateCheckbox(
        name,
    function()
        return not WoWTools_ChallengeMixin:Save().hideRight
    end, function()
        WoWTools_ChallengeMixin:Save().hideRight= not WoWTools_ChallengeMixin:Save().hideRight and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Right()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Challenge.RightInfo'])

--X
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return WoWTools_ChallengeMixin:Save().rightX or 10
    end, setValue=function(value)
        WoWTools_ChallengeMixin:Save().rightX=value
        WoWTools_ChallengeMixin:ChallengesUI_Right()
    end,
        name='X',
        minValue=-1024,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()

--Y
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return WoWTools_ChallengeMixin:Save().rightY or -53
    end, setValue=function(value)
        WoWTools_ChallengeMixin:Save().rightY=value
        WoWTools_ChallengeMixin:ChallengesUI_Right()
    end,
        name='Y',
        minValue=-1024,
        maxValue=1024,
        step=1,
        })
    sub:CreateSpacer()

    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return WoWTools_ChallengeMixin:Save().rightScale or 1
    end, function(value)
        WoWTools_ChallengeMixin:Save().rightScale=value
        WoWTools_ChallengeMixin:ChallengesUI_Right()
    end, function()
        WoWTools_ChallengeMixin:Save().rightScale=nil
        WoWTools_ChallengeMixin:Save().rightX=nil
        WoWTools_ChallengeMixin:Save().rightY=nil
        WoWTools_ChallengeMixin:ChallengesUI_Right()
    end)

    sub:CreateSpacer()
    sub:CreateTitle(name)




    root:CreateDivider()


    sub=root:CreateButton(
        '|A:ChallengeMode-KeystoneSlotFrame:0:0|a'
        ..(WoWTools_L.CHALLENGE_MODE_INSERT_KEYSTONE),
    function()
        ChallengesKeystoneFrame:SetShown(not ChallengesKeystoneFrame:IsShown())
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_L['Show UI'])
    end)

    WoWTools_ChallengeMixin:ChallengesKeystoneFrame_Menu(self, sub)

    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_ChallengeMixin.addName})
end


local function Init()
    local btn= WoWTools_ButtonMixin:Menu(ChallengesFrame, {name='WoWToolsChallengesFrameMenuButton'})
    btn:SetPoint('RIGHT', PVEFrameCloseButton, 'LEFT')
    btn:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)

    btn:SetupMenu(Init_Menu)

    Init=function()end
end


function WoWTools_ChallengeMixin:ChallengesUI_Menu()
    Init()
end