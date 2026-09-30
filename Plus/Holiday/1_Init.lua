

WoWTools_HolidayMixin={}



local function Save()
    return WoWToolsPlusSave['Plus_Holiday']
end














local function Init()
    WoWTools_HolidayMixin:Init_CreateEventFrame()
    WoWTools_HolidayMixin:Init_Calendar_Uptate()
    WoWTools_HolidayMixin:Init_TrackButton()
    Init=function()end
end




local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_ENTERING_WORLD')






local function Init_Open()
    if InCombatLockdown() then
        panel:RegisterEvent('PLAYER_REGEN_ENABLED')
    else
        --cargar el calendario y pedir los eventos sin abrir/cerrar la ventana (evita el parpadeo)
        if not C_AddOns.IsAddOnLoaded('Blizzard_Calendar') then
            C_AddOns.LoadAddOn('Blizzard_Calendar')
        end
        C_Calendar.OpenCalendar()
    end
end





panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Plus_Holiday']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Holiday'], {
                onGoing=true,--仅限: 正在活动
                disabled= true
                --toTopTrack=true,--向上
                --showDate= true,--时间
            })

            WoWTools_HolidayMixin.addName= '|A:GarrisonTroops-Health:0:0|a'..(WoWTools_L['Module.Holidays'])

            WoWTools_PanelMixin:Check_Button({
                checkName= WoWTools_HolidayMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled = not Save().disabled and true or nil
                    WoWTools_Print(
                        WoWTools_HolidayMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_L.RELOADUI
                    )
                end,
                buttonText= WoWTools_L.RESET_POSITION,
                buttonFunc= function()
                    Save().point=nil
                    if WoWTools_HolidayMixin.TrackButton then
                        WoWTools_HolidayMixin.TrackButton:set_point()
                    end
                    WoWTools_Print(
                        WoWTools_HolidayMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_L.RESET_POSITION
                    )
                end,
                tooltip= WoWTools_L['Tip.Holiday.Enable'],
                layout= nil,
                category= nil,
            })

            if Save().disabled then
                self:SetScript('OnEvent', nil)
               self:UnregisterAllEvents()
            else
                if C_AddOns.IsAddOnLoaded('Blizzard_Calendar') then
                    Init()
                    self:UnregisterEvent(event)
                end
            end

        elseif arg1=='Blizzard_Calendar' and WoWToolsPlusSave then
            Init()
            self:UnregisterEvent(event)

        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        Init_Open()
        self:UnregisterEvent(event)

    elseif event == 'PLAYER_ENTERING_WORLD' and WoWToolsPlusSave then
        Init_Open()
        self:UnregisterEvent(event)
    end
end)