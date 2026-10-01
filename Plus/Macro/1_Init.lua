


local P_Save={
    --disabled= true,
    toRightLeft=3,
    macro={},--{[|T..icon..:0|t..name..spllID..itemName]={name=tab.name, icon=tab.icon, body=tab.body}}

    bottomListScale=1,
}

local function Init_Load()
    WoWTools_MacroMixin:Init_Set_UI()
    WoWTools_MacroMixin:Init_Button()
    WoWTools_MacroMixin:Init_Select_Macro_Button()
    WoWTools_MacroMixin:Init_List_Button()
    WoWTools_MacroMixin:Init_AddNew_Button()
    WoWTools_MacroMixin:Init_ChangeTab()
    WoWTools_MacroMixin:Init_MacroButton_Plus()
end

local function Init()
    if InCombatLockdown() then
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
            Init_Load()
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end)
    else
        Init_Load()
    end
end







--Módulo registrado con la API común (docs/REFACTOR.md, R2).
WoWTools_Module:Register({
    key= 'Plus_Macro2',
    name= 'Module.Macros',
    icon= 'Interface\\MacroFrame\\MacroFrame-Icon',
    group= 'Character',
    defaults= P_Save,
    tooltip= 'Tip.Macro.Module',
    mixin= WoWTools_MacroMixin,
    onLoad= function(_, save)
        WoWToolsPlusSave['Plus_Macro']=nil

        if save.noteText then
            WoWToolsPlusPlayerDate['MacroNoteText']= save.noteText
            save.noteText = nil
        end
    end,
    options= function()
        local function NoList(save)
            return save.hideBottomList
        end
        return {
            {type='note', kind='warning', text= function()
                return WoWTools_L['HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT+ERRORS']
                    ..'|n'..WoWTools_L['Note: if you get errors, disable this']
            end},
            {type='section', text='GENERAL'},
            {type='check', key='hideBottomList', text='Button Plus', tooltip='Tip.Macro.ButtonPlus', noCombat=true,
                get= function(save) return not save.hideBottomList end,
                set= function(save, value) save.hideBottomList= not value and true or nil end,
                apply= function() WoWTools_MacroMixin:Refresh_BottomList() end},
            {type='button', key='open', text='MACROS', buttonText='SHOW', tooltip='Tip.Macro.OpenFrame',
                func= function()
                    if not InCombatLockdown() and ShowMacroFrame then
                        ShowMacroFrame()
                    end
                end},

            {type='section', text='Appearance'},
            {type='dropdown', key='toRightLeft', text='Layout', noCombat=true,
                tooltip= function()
                    return WoWTools_L['Tip.Macro.LayoutLeft']..'|n|n'..WoWTools_L['Tip.Macro.LayoutRight']
                        ..'|n|n'..WoWTools_L['Tip.Macro.LayoutDefault']..'|n|n'..WoWTools_L['Tip.Macro.LayoutSplit']
                end,
                values= {
                    {value=1, text='HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT'},
                    {value=2, text='HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT'},
                    {value=3, text='DEFAULT'},
                    {value=4, text='Left|Right'},
                },
                get= function(save) return save.toRightLeft or 3 end,
                set= function(save, value) save.toRightLeft= value end,
                apply= function() WoWTools_MacroMixin:Refresh_Layout() end},
            {type='slider', key='bottomListScale', text='SCALE', tooltip='Tip.Menu.Scale', min=0.4, max=4, step=0.1, format='%.1f',
                disabled= NoList,
                get= function(save) return save.bottomListScale or 1 end,
                set= function(save, value) save.bottomListScale= value end,
                apply= function() WoWTools_MacroMixin:Refresh_BottomList(true) end},
            {type='slider', key='bottomListAlpha', text='BACKGROUND+HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', tooltip='Tip.Menu.BgAlpha',
                min=0, max=1, step=0.1, format='%.1f',
                disabled= NoList,
                get= function(save) return save.bottomListAlpha or 0.5 end,
                set= function(save, value) save.bottomListAlpha= value end,
                apply= function() WoWTools_MacroMixin:Refresh_BottomList(true) end},
        }
    end,
    blizzard= {Blizzard_MacroUI= Init},
    events= {PLAYER_LOGOUT= function()
        if not WoWTools_DataMixin.ClearAllSave then
            local edit= _G['WoWToolsMacroPlusNoteEditBox']
            if edit and edit:IsVisible() then
                edit:Hide()
            end
        end
    end},
})
