WoWTools_HolidayMixin={}




local function Init()
    WoWTools_HolidayMixin:Init_CreateEventFrame()
    WoWTools_HolidayMixin:Init_Calendar_Uptate()
    WoWTools_HolidayMixin:Init_TrackButton()
end




local M

local function Init_Open()
    if InCombatLockdown() then
        --reintentar al salir de combate
        WoWTools_Module:RegisterEvent(M, 'PLAYER_REGEN_ENABLED', function()
            Init_Open()
            return true
        end)
    else
        --cargar el calendario y pedir los eventos sin abrir/cerrar la ventana (evita el parpadeo)
        if not C_AddOns.IsAddOnLoaded('Blizzard_Calendar') then
            C_AddOns.LoadAddOn('Blizzard_Calendar')
        end
        C_Calendar.OpenCalendar()
    end
end




--Módulo registrado con la API común (docs/REFACTOR.md, R1)
M= WoWTools_Module:Register({
    key= 'Plus_Holiday',
    name= 'Module.Holidays',
    icon= 'GarrisonTroops-Health',
    group= 'World',
    defaults= {
        onGoing=true,
        disabled= true
    },
    tooltip= 'Tip.Holiday.Enable',
    mixin= WoWTools_HolidayMixin,
    button= {text= 'RESET_POSITION', func= function()
        WoWTools_HolidayMixin:Save().point=nil
        if WoWTools_HolidayMixin.TrackButton then
            WoWTools_HolidayMixin.TrackButton:set_point()
        end
        WoWTools_Print(
            WoWTools_HolidayMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_L.RESET_POSITION
        )
    end},
    blizzard= {Blizzard_Calendar= Init},
    events= {PLAYER_ENTERING_WORLD= function()
        Init_Open()
        return true
    end},
})
