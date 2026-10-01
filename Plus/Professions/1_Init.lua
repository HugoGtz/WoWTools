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
    options= {
        {type='section', text='GENERAL'},
        {type='check', key='setButton', text='SHOW_QUICK_BUTTON~3', tooltip='Tip.Professions.QuickButtons', noCombat=true,
            get= function(save) return save.setButton end,
            set= function(save, value) save.setButton= value and true or false end,
            apply= function() WoWTools_ProfessionMixin:Refresh_ProfessionsFrame_Button() end},
        {type='check', key='fire', text='Cooking fire button', tooltip='Tip.Professions.CookingFire', indent=true, reload=true,
            disabled= function(save) return not save.setButton end,
            get= function(save) return save.showFuocoButton end,
            set= function(save, value) save.showFuocoButton= value and true or nil end},
        {type='check', key='trainer', text='Learn all button', tooltip='Tip.Professions.LearnAll',
            get= function(save) return not save.disabledClassTrainer end,
            set= function(save, value) save.disabledClassTrainer= not value and true or nil end,
            apply= function(_, save)
                if ClassTrainerFrame and ClassTrainerFrame.BuyAll then
                    ClassTrainerFrame.BuyAll:SetShown(not save.disabledClassTrainer)
                end
            end},
        {type='check', key='sound', text='Archaeology sound alert', tooltip='Tip.Professions.ArchaeologySound',
            get= function(save) return save.ArcheologySound end,
            set= function(save, value) save.ArcheologySound= value and true or false end,
            apply= function()
                local btn= _G['WoWToolsArcheologyProgressBarSounButton']
                if btn and btn.set_event then
                    btn:set_event()
                end
            end},

        {type='section', text='Automations'},
        {type='check', key='enchant', text='Auto use enchanting vellum', tooltip='Tip.Professions.AutoVellum', automation=true,
            get= function(save) return not save.disabledEnchant end,
            set= function(save, value) save.disabledEnchant= not value and true or nil end},
        {type='check', key='digBar', text='Auto show dig site bar', tooltip='Tip.Professions.AutoDigBar', automation=true,
            get= function(save) return save.showArcheologyBar end,
            set= function(save, value) save.showArcheologyBar= value and true or nil end,
            apply= function()
                local bar= _G['WoWToolsArcheologyProgressBarBranchButton']
                if bar and bar.set_event then
                    bar:set_event()
                end
            end},

        {type='section', text='Appearance'},
        {type='slider', key='scale', text='HOUSING_EXPERT_DECOR_SUBMODE_SCALE', tooltip='Tip.Menu.Scale', noCombat=true,
            min=0.4, max=4, step=0.05, format='%.2f',
            disabled= function(save) return not save.setButton end,
            get= function(save) return save.scaleButton or 1 end,
            set= function(save, value) save.scaleButton= value end,
            apply= function() WoWTools_ProfessionMixin:Refresh_ProfessionsFrame_Button() end},
    },
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
