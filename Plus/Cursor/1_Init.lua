
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



local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Plus_Cursor']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Cursor'], P_Save)
            P_Save=nil

            WoWTools_CursorMixin.addName= '|A:newplayertutorial-icon-mouse-turn:0:0|a'..(WoWTools_L['Module.Cursor'])

            self:RegisterEvent('PLAYER_ENTERING_WORLD')

            WoWTools_CursorMixin:Set_Options(self)

            if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_Settings' and WoWToolsPlusSave then
            WoWTools_CursorMixin:Set_Options(self)
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_CursorMixin:GCD_Settings()
        self:UnregisterEvent(event)
    end
end)