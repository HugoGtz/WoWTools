

local function Save()
    return WoWToolsPlusSave['Plus_Professions']
end




local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1== 'WoWToolsPlus' then

        WoWToolsPlusSave['Plus_Professions']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Professions'], {
            setButton=true,
            ArcheologySound=true,
        })

        WoWTools_ProfessionMixin.addName= '|A:Professions_Icon_FirstTimeCraft:0:0|a'..(WoWTools_L['Module.Professions'])

        WoWTools_PanelMixin:OnlyCheck({
            name= WoWTools_ProfessionMixin.addName,
            tooltip= WoWTools_L['Tip.Professions.Enable']..'|n|n'..WoWTools_ProfessionMixin.addName,
            GetValue= function() return not Save().disabled end,
            SetValue= function()
                Save().disabled= not Save().disabled and true or nil
                WoWTools_Print(WoWTools_DataMixin.Icon.icon2..WoWTools_ProfessionMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_L.REQUIRES_RELOAD)
            end
        })

        if Save().disabled then
            self:SetScript('OnEvent', nil)
            self:UnregisterEvent(event)
        else
            WoWTools_ProfessionMixin:Init_Archaeology()

            if C_AddOns.IsAddOnLoaded("Blizzard_TrainerUI") then
                WoWTools_ProfessionMixin:Init_Blizzard_TrainerUI()
            end
            if C_AddOns.IsAddOnLoaded("Blizzard_Professions") then
                WoWTools_ProfessionMixin:Init_ProfessionsFrame()
            end
 
        end

    elseif arg1== 'Blizzard_TrainerUI' and WoWToolsPlusSave then
        WoWTools_ProfessionMixin:Init_Blizzard_TrainerUI()

    elseif arg1== 'Blizzard_Professions' and WoWToolsPlusSave then --10.1.5
        WoWTools_ProfessionMixin:Init_ProfessionsFrame()


    end
end)