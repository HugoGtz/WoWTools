
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









--Tiene su propia página de opciones (2_Options.lua, se crea al entrar al juego): panel=false
WoWTools_Module:Register({
    key= 'Plus_Spell',
    name= 'SPELLS',
    icon= 'UI-HUD-MicroMenu-SpellbookAbilities-Mouseover',
    group= 'Character',
    defaults= P_Save,
    tooltip= 'Tip.Spell.Enable',
    mixin= WoWTools_SpellMixin,
    panel= false,
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
        WoWTools_SpellMixin:Init_Options()
        WoWTools_SpellMixin:Init_Spec_Button()
        WoWTools_SpellMixin:Init_Spell_Flyout()
        WoWTools_SpellMixin:Init_ActionButton_UpdateRange()
        return true
    end},
})
