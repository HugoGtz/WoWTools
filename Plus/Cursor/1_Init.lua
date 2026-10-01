
WoWTools_CursorMixin={
    Color= PlayerUtil.GetClassColor(),
    DefaultTexture= 'bonusobjectives-bar-starburst',
    DefaultGCDTexture= 'Interface\\Addons\\WoWToolsPlus\\Source\\Mouse\\Aura73',
}

local P_Save={
    disabled= true,
    disabledGCD= true,
    color={r=0, g=1, b= 0, a=1},
    usrClassColor=true,
    size=32,--8 64
    gravity=512, -- -512 512
    duration=0.3,--0.1 4
    rotate=32,-- 0 32
    atlasIndex=1,
    rate=0.03,
    X=40,
    Y=-30,
    alpha=1,
    maxParticles= 50,
    minDistance=3,
    randomTexture=true,
    Atlas={
        'bonusobjectives-bar-starburst',
        'Adventures-Buff-Heal-Burst',
        'OBJFX_StarBurst',
        'worldquest-questmarker-glow',
        'Relic-Frost-TraitGlow',
        'Relic-Holy-TraitGlow',
        'Relic-Life-TraitGlow',
        'Relic-Iron-TraitGlow',
        'Relic-Wind-TraitGlow',
        'Relic-Water-TraitGlow',
        'Azerite-Trait-RingGlow',
        'AzeriteFX-Whirls',
        'ArtifactsFX-Whirls',
        'ArtifactsFX-SpinningGlowys',
        'Azerite-TitanBG-Glow-Rank2',
        '!ItemUpgrade_FX_FrameDecor_IdleGlow',
        'Artifacts-Anim-Sparks',
        'AftLevelup-SoftCloud',
        'BossBanner-RedLightning',
        'Cast_Channel_Sparkles_01',
        'ChallengeMode-Runes-GlowLarge',
        'ChallengeMode-Runes-Shockwave',
        'CovenantSanctum-Reservoir-Idle-Kyrian-Speck',
        'CovenantSanctum-Reservoir-Idle-Kyrian-Glass',

        'housing-item-toast-leaf03',
        'housing-item-toast-leaf05',

        [[Interface\Addons\WoWToolsPlus\Source\Mouse\Aura121]],

        [[Interface\Addons\WoWToolsPlus\Source\Mouse\Aura73.tga]],
        [[Interface\Addons\WoWToolsPlus\Source\Mouse\Aura94.tga]],
        [[Interface\Addons\WoWToolsPlus\Source\Mouse\Aura103.tga]],
        [[Interface\Addons\WoWToolsPlus\Source\Mouse\Aura142.tga]],
    },
    GCDTexture={
        [[Interface\Addons\WoWToolsPlus\Source\Mouse\Aura73.tga]],
        [[Interface\Addons\WoWToolsPlus\Source\Mouse\Aura94.tga]],
        [[Interface\Addons\WoWToolsPlus\Source\Mouse\Aura103.tga]],
        [[Interface\Addons\WoWToolsPlus\Source\Mouse\Aura142.tga]],
    },
    gcdSize=15,
    gcdTextureIndex=1,
    gcdAlpha=1,
    gcdX=0,
    gcdY=0,
    --gcdDrawBling=false,
    --gcdReverse=false,
}



--Lienzo de la página de opciones del cursor
local panel= CreateFrame("Frame")

--Módulo registrado con la API común (docs/REFACTOR.md, R2).
--'disabled' aquí es el rastro del cursor (desactivado por defecto), no el módulo: las opciones y el GCD
--arrancan siempre, por eso van en onLoad y no en onEnable. Página de opciones propia (panel=false).
WoWTools_Module:Register({
    key= 'Plus_Cursor',
    name= 'Module.Cursor',
    icon= 'newplayertutorial-icon-mouse-turn',
    group= 'Interface',
    defaults= P_Save,
    mixin= WoWTools_CursorMixin,
    panel= false,
    onLoad= function()
        EventUtil.RegisterOnceFrameEventAndCallback('PLAYER_ENTERING_WORLD', function()
            WoWTools_CursorMixin:GCD_Settings()
        end)

        WoWTools_CursorMixin:Set_Options(panel)

        if not C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
            EventUtil.ContinueOnAddOnLoaded('Blizzard_Settings', function()
                WoWTools_CursorMixin:Set_Options(panel)
            end)
        end
    end,
})
