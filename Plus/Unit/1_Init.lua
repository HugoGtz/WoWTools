
local function Init()
    WoWTools_UnitMixin:Init_PlayerFrame()
    WoWTools_UnitMixin:Init_PetFrame()
    WoWTools_UnitMixin:Init_TargetFrame()

    WoWTools_UnitMixin:Init_PartyFrame()

    WoWTools_UnitMixin:Init_BossFrame()--BOSS

    WoWTools_UnitMixin:Init_ClassTexture()
end



--Tiene su propia página de opciones (2_Options.lua): panel=false
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
    panel= false,
    onLoad= function(M)--desactivado también hace falta su página de opciones (con la casilla para activarlo)
        if not M:IsEnabled() then
            WoWTools_UnitMixin:Init_Options()
        end
    end,
    onEnable= function()
        WoWTools_UnitMixin:Init_Options()
        Init()
    end,
    blizzard= {Blizzard_Settings= function()
        WoWTools_UnitMixin:Init_Options()
    end},
})

