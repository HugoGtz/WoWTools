


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


--Opciones del Centro de control (docs/SETTINGS.md). Usan los mismos campos que el menú de la pestaña de Míticas+.
--Los marcos se crean al cargar Blizzard_ChallengesUI: hasta entonces solo se guarda el valor.
local function Refresh(func)
    return function(M)
        if M.started and ChallengesFrame then
            M[func](M)
        end
    end
end

--Interruptor "Mostrar X" sobre un campo invertido (hideX)
local function Show(field, text, tooltip, func, extra)
    local opt= {type='check', key=field, text=text, tooltip=tooltip, apply=Refresh(func),
        get= function(save) return not save[field] end,
        set= function(save, value) save[field]= not value and true or nil end,
    }
    for k, v in pairs(extra or {}) do
        opt[k]= v
    end
    return opt
end

local function Num(field, text, default, min, max, step, func, hideField, extra)
    local opt= {type='slider', key=field, text=text, min=min, max=max, step=step,
        format= step<1 and (step<0.1 and '%.2f' or '%.1f') or nil,
        apply=Refresh(func),
        get= function(save) return save[field] or default end,
        set= function(save, value) save[field]= value end,
        disabled= hideField and function(save) return save[hideField] end,
    }
    for k, v in pairs(extra or {}) do
        opt[k]= v
    end
    return opt
end

local function Scale(field, default, func, hideField, extra)
    extra= extra or {}
    extra.tooltip= extra.tooltip or 'Tip.Menu.Scale'
    return Num(field, 'HOUSING_EXPERT_DECOR_SUBMODE_SCALE', default, 0.4, 4, 0.1, func, hideField, extra)
end

--Restablecer: lo mismo que el botón "Restablecer" del menú (borra escala y posición)
local function Reset(key, fields, func, hideField)
    return {type='button', key=key, text='RESET+STATUS_TEXT_VALUE', buttonText='RESET', tooltip='Tip.Challenge.ResetValues',
        disabled= hideField and function(save) return save[hideField] end,
        func= function(M, save)
            for _, field in ipairs(fields) do
                save[field]= nil
            end
            Refresh(func)(M)
        end,
    }
end

local function Section(name)
    return {type='section', text=function()
        return WoWTools_L['Appearance']..': '..WoWTools_Options:Plain(WoWTools_L[name])
    end}
end

local StrataList= {}
for _, strata in ipairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
    table.insert(StrataList, {value=strata, text=function() return strata end})
end

local function Say_Settings(M)
    if M.started then
        M:Say_ChallengeComplete_Settings()
    end
end

local Options= {
    {type='section', text='GENERAL'},
    Show('hideIns', 'INSTANCE+INFO', 'Tip.Challenge.DungeonInfo', 'ChallengesUI_Info'),
    Num('insNamegsub', 'Truncate', 0, 0, 30, 1, 'ChallengesUI_Info', 'hideIns', {indent=true, tooltip='Tip.Challenge.Truncate',
        set= function(save, value) save.insNamegsub= value>0 and value or nil end}),
    Show('hidePort', 'SPELLS~2', 'Tip.Challenge.Portals', 'ChallengesUI_Porta', {noCombat=true}),
    Show('hideActivities', 'RATED_PVP_WEEKLY_VAULT', 'Tip.Challenge.Vault', 'ChallengesUI_Activities'),
    Show('activitiesHidePvP', function() return 'PvP '..WoWTools_L.INFO end, 'Tip.Challenge.VaultPvP', 'ChallengesUI_Activities', {indent=true,
        disabled= function(save) return save.hideActivities end}),
    Show('hideGuild', 'GUILD_CHALLENGE_LABEL', 'Tip.Challenge.Guild', 'ChallengesUI_Guild'),
    Show('hideAffix', 'Affix list', 'Tip.Challenge.Affix', 'ChallengesUI_Affix'),
    Show('hideRight', 'PLAYER_DIFFICULTY5+INFO', 'Tip.Challenge.RightInfo', 'ChallengesUI_Right'),
    Show('hideKeyUI', 'Keystone window info', 'Tip.Challenge.KeystonePlus', 'ChallengesKeystoneFrame'),

    {type='section', text='Automations'},
    {type='check', key='hideEndKeystoneSay', text='PLAYER_DIFFICULTY5+COMPLETE', tooltip='Tip.Challenge.EndSay', automation=true,
        get= function(save) return not save.hideEndKeystoneSay end,
        set= function(save, value) save.hideEndKeystoneSay= not value and true or nil end,
        apply= function(M)
            if M.started then
                M:Say_ChallengeComplete()
            end
        end,
    },
    {type='check', key='allShowEndKeystoneSay', text='BATTLEFIELD_MINIMAP_SHOW_ALWAYS', tooltip='Tip.Challenge.AlwaysShow', indent=true, automation=true,
        disabled= function(save) return save.hideEndKeystoneSay end,
        get= function(save) return save.allShowEndKeystoneSay end,
        set= function(save, value) save.allShowEndKeystoneSay= value and true or nil end,
    },
    {type='input', key='sayText', text='Announcement text', tooltip='Tip.Challenge.SayEdit', indent=true, placeholder='{rt1}...',
        disabled= function(save) return save.hideEndKeystoneSay end,
        get= function() return WoWToolsPlusPlayerDate and WoWToolsPlusPlayerDate.EndKeystoneSayText or '' end,
        set= function(_, text)
            if WoWToolsPlusPlayerDate then
                WoWToolsPlusPlayerDate.EndKeystoneSayText= text:gsub(' ', '')~='' and text or nil
            end
        end,
    },

    Section('INSTANCE+INFO'),
    Scale('insScale', 1, 'ChallengesUI_Info', 'hideIns'),
    Reset('resetIns', {'insScale', 'insNamegsub'}, 'ChallengesUI_Info', 'hideIns'),

    Section('SPELLS~2'),
    Scale('portScale', 1, 'ChallengesUI_Porta', 'hidePort', {noCombat=true}),

    Section('RATED_PVP_WEEKLY_VAULT'),
    Num('activitiesX', 'Position X', 10, -1024, 1024, 1, 'ChallengesUI_Activities', 'hideActivities', {tooltip='Tip.Challenge.Offset'}),
    Num('activitiesY', 'Position Y', -53, -1024, 1024, 1, 'ChallengesUI_Activities', 'hideActivities', {tooltip='Tip.Challenge.Offset'}),
    Scale('activitiesScale', 1, 'ChallengesUI_Activities', 'hideActivities'),
    Reset('resetActivities', {'activitiesScale', 'activitiesX', 'activitiesY'}, 'ChallengesUI_Activities', 'hideActivities'),

    Section('GUILD_CHALLENGE_LABEL'),
    Num('guildX', 'Position X', -15, -1024, 1024, 1, 'ChallengesUI_Guild', 'hideGuild', {tooltip='Tip.Challenge.Offset'}),
    Num('guildY', 'Position Y', -32, -1024, 1024, 1, 'ChallengesUI_Guild', 'hideGuild', {tooltip='Tip.Challenge.Offset'}),
    Num('guildBgAlpha', 'BACKGROUND+HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', 0.5, 0, 1, 0.05, 'ChallengesUI_Guild', 'hideGuild', {tooltip='Tip.Menu.BgAlpha'}),
    Scale('guildScale', 1, 'ChallengesUI_Guild', 'hideGuild'),
    Reset('resetGuild', {'guildScale', 'guildX', 'guildY', 'guildBgAlpha'}, 'ChallengesUI_Guild', 'hideGuild'),

    Section('Affix list'),
    Num('affixW', 'HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH', 238, 220, 1024, 1, 'ChallengesUI_Affix', 'hideAffix'),
    Num('affixH', 'HUD_EDIT_MODE_SETTING_CHAT_FRAME_HEIGHT', 177, 58, 1024, 1, 'ChallengesUI_Affix', 'hideAffix'),
    Num('affixX', 'Position X', -45, -2048, 2048, 1, 'ChallengesUI_Affix', 'hideAffix', {tooltip='Tip.Challenge.Offset'}),
    Num('affixY', 'Position Y', 300, -2048, 2048, 1, 'ChallengesUI_Affix', 'hideAffix', {tooltip='Tip.Challenge.Offset'}),
    Scale('affixScale', 0.4, 'ChallengesUI_Affix', 'hideAffix'),
    Reset('resetAffix', {'affixScale', 'affixW', 'affixH', 'affixX', 'affixY'}, 'ChallengesUI_Affix', 'hideAffix'),

    Section('PLAYER_DIFFICULTY5+INFO'),
    Num('rightX', 'Position X', 2, -1024, 1024, 1, 'ChallengesUI_Right', 'hideRight', {tooltip='Tip.Challenge.Offset'}),
    Num('rightY', 'Position Y', -22, -1024, 1024, 1, 'ChallengesUI_Right', 'hideRight', {tooltip='Tip.Challenge.Offset'}),
    Scale('rightScale', 1, 'ChallengesUI_Right', 'hideRight'),
    Reset('resetRight', {'rightScale', 'rightX', 'rightY'}, 'ChallengesUI_Right', 'hideRight'),

    Section('Keystone window info'),
    Scale('keystoneScale', 1, 'ChallengesKeystoneFrame', 'hideKeyUI'),

    Section('PLAYER_DIFFICULTY5+COMPLETE'),
    Scale('endKeystoneSayScale', 1, nil, 'hideEndKeystoneSay', {apply=Say_Settings}),
    {type='dropdown', key='endeystoneSayStrata', text='Strata', tooltip='Tip.Menu.Strata', values=StrataList,
        disabled= function(save) return save.hideEndKeystoneSay end,
        get= function(save) return save.endeystoneSayStrata or 'MEDIUM' end,
        set= function(save, value) save.endeystoneSayStrata= value end,
        apply= Say_Settings,
    },
}


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
    options= Options,
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
