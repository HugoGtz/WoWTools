


local P_Save={
    --disabled= true,
    toRightLeft=3,
    macro={},--{[|T..icon..:0|t..name..spllID..itemName]={name=tab.name, icon=tab.icon, body=tab.body}}

    bottomListScale=1,
}

local function Save()
    return WoWToolsPlusSave['Plus_Macro2']
end




local function Init_Load()
    WoWTools_MacroMixin:Init_Set_UI()
    WoWTools_MacroMixin:Init_Button()
    WoWTools_MacroMixin:Init_Select_Macro_Button()
    WoWTools_MacroMixin:Init_List_Button()
    WoWTools_MacroMixin:Init_AddNew_Button()
    WoWTools_MacroMixin:Init_ChangeTab()
    WoWTools_MacroMixin:Init_MacroButton_Plus()

    Init_Load=function()end
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

    Init=function()end
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Plus_Macro2']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Macro2'], P_Save)
            WoWToolsPlusSave['Plus_Macro']=nil
            P_Save= nil

            if Save().noteText then
                WoWToolsPlusPlayerDate['MacroNoteText']= Save().noteText
                Save().noteText = nil
            end

            WoWTools_MacroMixin.addName= '|TInterface\\MacroFrame\\MacroFrame-Icon:0|t'..(WoWTools_L['Module.Macros'])

            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_MacroMixin.addName,
                tooltip= WoWTools_L['Tip.Macro.Module']..'|n|n'..('|cnWARNING_FONT_COLOR:'..(WoWTools_L['HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT+ERRORS']))
                    ..'|r|n'..(WoWTools_L['Note: if you get errors, disable this']),
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled = not Save().disabled and true or nil
                    WoWTools_Print(
                        WoWTools_MacroMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_L['REQUIRES_RELOAD~2']
                    )
                end
            })

            if Save().disabled  then
                self:SetScript('OnEvent', nil)
                self:UnregisterEvent(event)
            else
                if C_AddOns.IsAddOnLoaded('Blizzard_MacroUI') then
                    Init()
                    self:UnregisterEvent(event)
                end
                self:RegisterEvent("PLAYER_LOGOUT")
            end

        elseif arg1=='Blizzard_MacroUI' and WoWToolsPlusSave then
            self:UnregisterEvent(event)
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            local edit= _G['WoWToolsMacroPlusNoteEditBox']
            if edit and edit:IsVisible() then
                edit:Hide()
            end
        end
    end
end)