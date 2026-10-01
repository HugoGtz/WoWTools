--Módulo registrado con la API común (docs/REFACTOR.md, R2)
WoWTools_Module:Register({
    key= 'Plus_Professions',
    name= 'Module.Professions',
    icon= 'Professions_Icon_FirstTimeCraft',
    group= 'Items',
    defaults= {
        setButton=true,
        ArcheologySound=true,
    },
    tooltip= 'Tip.Professions.Enable',
    mixin= WoWTools_ProfessionMixin,
    onEnable= function()
        WoWTools_ProfessionMixin:Init_Archaeology()
    end,
    blizzard= {
        Blizzard_ArchaeologyUI= function()
            WoWTools_ProfessionMixin:Init_ArchaeologyFrame()
        end,
        Blizzard_TrainerUI= function()
            WoWTools_ProfessionMixin:Init_Blizzard_TrainerUI()
        end,
        Blizzard_Professions= function()--10.1.5
            WoWTools_ProfessionMixin:Init_ProfessionsFrame()
        end,
    },
})
