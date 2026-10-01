
local function Init()
    WoWTools_UnitMixin:Init_PlayerFrame()
    WoWTools_UnitMixin:Init_PetFrame()
    WoWTools_UnitMixin:Init_TargetFrame()

    WoWTools_UnitMixin:Init_PartyFrame()

    WoWTools_UnitMixin:Init_BossFrame()--BOSS

    WoWTools_UnitMixin:Init_ClassTexture()
end



--Opciones del Centro de control (docs/SETTINGS.md). Antes estaban en una subpágina de Blizzard (2_Options.lua).
--Encender una mejora se aplica al momento; apagarla requiere /reload (sus ganchos ya están puestos).
local function Frame(field, text, tooltip, func)
    return {type='check', key=field, text=text, tooltip=tooltip, reload=true, noCombat=true,
        get= function(save) return not save[field] end,
        set= function(save, value) save[field]= not value and true or nil end,
        apply= function(M, save)
            if M.started and not save[field] then
                M[func](M)
            end
        end,
    }
end

local Options= {
    {type='section', text='Frames to enhance'},
    Frame('hidePlayerFrame', 'HUD_EDIT_MODE_PLAYER_FRAME_LABEL', 'Tip.Unit.PlayerFrame', 'Init_PlayerFrame'),
    {type='check', key='showLootButton', text='Always show loot specialization', tooltip='Tip.Unit.LootButtonAlways', indent=true,
        disabled= function(save) return save.hidePlayerFrame end,
        get= function(save) return save.showLootButton and true or false end,
        set= function(save, value) save.showLootButton= value and true or nil end,
        apply= function()
            local btn= _G['WoWToolsPlayerFrameLootButton']
            if btn and btn.settings then
                btn:settings()
            end
        end,
    },
    Frame('hideTargetFrame', 'HUD_EDIT_MODE_TARGET_FRAME_LABEL', 'Tip.Unit.TargetFrame', 'Init_TargetFrame'),
    Frame('hidePartyFrame', 'HUD_EDIT_MODE_PARTY_FRAMES_LABEL', 'Tip.Unit.PartyFrame', 'Init_PartyFrame'),
    Frame('hideBossFrame', 'HUD_EDIT_MODE_BOSS_FRAMES_LABEL', 'Tip.Unit.BossFrame', 'Init_BossFrame'),
    Frame('hideClassColor', 'CLASS+EMBLEM_SYMBOL', 'Tip.Unit.ClassTexture', 'Init_ClassTexture'),
}


WoWTools_Module:Register({
    key= 'Plus_UnitFrame',
    name= 'Module.Unit frames',
    icon= 'UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged',
    group= 'Interface',
    defaults= {
        raidFrameScale= 1,
        PartyDeadData={}
    },
    tooltip= 'Tip.Unit.Module',
    mixin= WoWTools_UnitMixin,
    options= Options,
    onEnable= Init,
})
