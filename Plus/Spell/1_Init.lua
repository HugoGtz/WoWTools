
local P_Save= {
    specButton={
    scale= 1,
    --isToTOP=true
    --point={}
    --strata='MEDIUM'
    hideInCombat=true,
    enabled=true,
    },

    bg={
        texture={},
        show=true,
        --icon='',
    },
    setUITexture=true,

    flyoutText=true,
    actionButtonRangeColor=true,

    spellBookPlus=true,
    talentsFramePlus=true,
}




local function Init_PlayerSpells()
    WoWTools_SpellMixin:Init_TalentsFrame()
    WoWTools_SpellMixin:Init_SpellBookFrame()
    WoWTools_SpellMixin:Init_Spec_Button()

    local reload= CreateFrame('Button', 'WoWToolsSpellBookReloadButton', PlayerSpellsFrame.TitleContainer, 'WoWToolsButtonTemplate')
    reload:SetPoint('LEFT', 28, -3)
    reload:SetNormalAtlas('common-icon-exit')
    reload.tooltip=WoWTools_DataMixin.Icon.icon2..(WoWTools_L['RELOADUI~2'])
    reload:SetScript('OnClick', function() WoWTools_DataMixin:Reload() end)
    WoWTools_TextureMixin:SetButton(reload, 0.5)
end









--Opciones del Centro de control (docs/SETTINGS.md). Antes estaban en una subpágina de Blizzard (2_Options.lua).
--Apagar una mejora requiere /reload (sus ganchos ya están puestos); encenderla se aplica al momento.
local function Feature(field, text, tooltip, func)
    return {type='check', key=field, text=text, tooltip=tooltip, reload=true,
        get= function(save) return save[field] and true or false end,
        set= function(save, value) save[field]= value and true or false end,
        apply= function(M)
            if M.started then
                M[func](M)
            end
        end,
    }
end

local function Spec(save)
    return save.specButton
end

local function Spec_Settings(what)
    return function(M)
        if M.started then
            M:Spec_Button_Settings(what)
        end
    end
end

local StrataList= {}
for _, strata in ipairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
    table.insert(StrataList, {value=strata, text=function() return strata end})
end

local Options= {
    {type='section', text='GENERAL'},
    Feature('spellBookPlus', 'SPELLBOOK', 'Tip.Spell.SpellBook', 'Init_SpellBookFrame'),
    Feature('talentsFramePlus', 'TALENT', 'Tip.Spell.Talents', 'Init_TalentsFrame'),
    Feature('flyoutText', 'Spell flyout', 'Tip.Spell.Flyout', 'Init_Spell_Flyout'),
    Feature('actionButtonRangeColor', 'ACTIONBARS_LABEL+COLOR', 'Tip.Spell.RangeColor', 'Init_ActionButton_UpdateRange'),

    {type='section', text='Specialization button'},
    {type='check', key='specButton.enabled', text='Specialization button', tooltip='Tip.Spell.SpecButton', reload=true,
        get= function(save) return Spec(save).enabled and true or false end,
        set= function(save, value) Spec(save).enabled= value and true or false end,
        apply= function(M)
            if M.started then
                M:Init_Spec_Button()
            end
        end,
    },
    {type='check', key='specButton.isUIParent', text='Free on screen (UIParent)', tooltip='Tip.Spell.SpecUIParent', reload=true, indent=true,
        disabled= function(save) return not Spec(save).enabled end,
        get= function(save) return Spec(save).isUIParent and true or false end,
        set= function(save, value) Spec(save).isUIParent= value and true or nil end,
        apply= Spec_Settings('parent'),
    },
    {type='check', key='specButton.isToTOP', text='Grow upwards', tooltip='Tip.Menu.ToTop', indent=true,
        disabled= function(save) return not Spec(save).enabled or not Spec(save).isUIParent end,
        get= function(save) return Spec(save).isToTOP and true or false end,
        set= function(save, value) Spec(save).isToTOP= value and true or nil end,
        apply= Spec_Settings(),
    },

    {type='section', text=function() return WoWTools_L['Appearance']..': '..WoWTools_L['Specialization button'] end},
    {type='slider', key='specButton.scale', text='HOUSING_EXPERT_DECOR_SUBMODE_SCALE', tooltip='Tip.Menu.Scale',
        min=0.4, max=4, step=0.1, format='%.1f',
        disabled= function(save) return not Spec(save).enabled end,
        get= function(save) return Spec(save).scale or 1 end,
        set= function(save, value) Spec(save).scale= value end,
        apply= Spec_Settings(),
    },
    {type='dropdown', key='specButton.strata', text='Strata', tooltip='Tip.Menu.Strata', values=StrataList,
        disabled= function(save) return not Spec(save).enabled end,
        get= function(save) return Spec(save).strata or 'MEDIUM' end,
        set= function(save, value) Spec(save).strata= value end,
        apply= Spec_Settings('strata'),
    },
}


WoWTools_Module:Register({
    key= 'Plus_Spell',
    name= 'SPELLS',
    icon= 'UI-HUD-MicroMenu-SpellbookAbilities-Mouseover',
    group= 'Character',
    defaults= P_Save,
    tooltip= 'Tip.Spell.Enable',
    mixin= WoWTools_SpellMixin,
    options= Options,
    onEnable= function(_, save)
        --Claves antiguas que ya no se usan
        WoWToolsPlusSave['Other_SpellFrame']=nil
        WoWToolsPlusSave['Other_SpellFlyout']=nil

        if not save.bg then
            save.bg={texture={},show=true}
        end
    end,
    blizzard= {Blizzard_PlayerSpells= Init_PlayerSpells},
    events= {PLAYER_ENTERING_WORLD= function()
        WoWTools_SpellMixin:Init_Spec_Button()
        WoWTools_SpellMixin:Init_Spell_Flyout()
        WoWTools_SpellMixin:Init_ActionButton_UpdateRange()
        return true
    end},
})
