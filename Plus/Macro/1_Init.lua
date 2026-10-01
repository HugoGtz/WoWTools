


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
--La casilla es propia (panel=false, en onLoad): su tooltip avisa de errores en combate.
WoWTools_Module:Register({
    key= 'Plus_Macro2',
    name= 'Module.Macros',
    icon= 'Interface\\MacroFrame\\MacroFrame-Icon',
    group= 'Character',
    defaults= P_Save,
    mixin= WoWTools_MacroMixin,
    panel= false,
    onLoad= function(_, save)
        WoWToolsPlusSave['Plus_Macro']=nil

        if save.noteText then
            WoWToolsPlusPlayerDate['MacroNoteText']= save.noteText
            save.noteText = nil
        end

        WoWTools_PanelMixin:OnlyCheck({
            name= WoWTools_MacroMixin.addName,
            tooltip= WoWTools_L['Tip.Macro.Module']..'|n|n'..('|cnWARNING_FONT_COLOR:'..(WoWTools_L['HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT+ERRORS']))
                ..'|r|n'..(WoWTools_L['Note: if you get errors, disable this']),
            GetValue= function() return not WoWTools_MacroMixin:Save().disabled end,
            SetValue= function()
                WoWTools_MacroMixin:Save().disabled = not WoWTools_MacroMixin:Save().disabled and true or nil
                WoWTools_Print(
                    WoWTools_MacroMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(not WoWTools_MacroMixin:Save().disabled),
                    WoWTools_L['REQUIRES_RELOAD~2']
                )
            end
        })
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
