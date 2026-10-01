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
    options= function()
        local function Refresh(what)
            return function()
                WoWTools_HolidayMixin:Refresh_TrackButton(what)
            end
        end
        local strata= {}
        for _, name in ipairs({'BACKGROUND', 'LOW', 'MEDIUM', 'HIGH', 'DIALOG', 'FULLSCREEN', 'FULLSCREEN_DIALOG'}) do
            table.insert(strata, {value=name, text=name})
        end
        return {
            {type='section', text='GENERAL'},
            {type='check', key='show', text='Show event list', tooltip='Tip.Holiday.ShowList',
                get= function(save) return not save.hide end,
                set= function(save, value) save.hide= not value and true or nil end,
                apply= Refresh('shown')},
            {type='check', key='onGoing', text='Ongoing only', tooltip='Tip.Holiday.OngoingOnly', indent=true,
                disabled= function(save) return save.hide end,
                get= function(save) return save.onGoing end,
                set= function(save, value) save.onGoing= value and true or false end,
                apply= Refresh('text')},
            {type='check', key='showDate', text='Show event times', tooltip='Tip.Holiday.ShowTime', indent=true,
                disabled= function(save) return save.hide end,
                get= function(save) return save.showDate end,
                set= function(save, value) save.showDate= value and true or nil end,
                apply= Refresh('text')},

            {type='section', text='Appearance'},
            {type='check', key='left', text='Text on the left', tooltip='Tip.Holiday.AlignLeft',
                get= function(save) return save.left end,
                set= function(save, value) save.left= value and true or nil end,
                apply= Refresh('init')},
            {type='check', key='toTopTrack', text='Grow upwards', tooltip='Tip.Holiday.GrowUp',
                get= function(save) return save.toTopTrack end,
                set= function(save, value) save.toTopTrack= value and true or nil end,
                apply= Refresh('init')},
            {type='slider', key='scale', text='SCALE', tooltip='Tip.Menu.Scale', min=0.4, max=4, step=0.1, format='%.1f',
                get= function(save) return save.scale or 1 end,
                set= function(save, value) save.scale= value end,
                apply= Refresh('settings')},
            {type='slider', key='bgAlpha', text='BACKGROUND+HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', tooltip='Tip.Menu.BgAlpha',
                min=0, max=1, step=0.1, format='%.1f',
                get= function(save) return save.bgAlpha or 0.5 end,
                set= function(save, value) save.bgAlpha= value end,
                apply= Refresh('settings')},
            {type='dropdown', key='strata', text='Strata', tooltip='Tip.Menu.Strata', values= strata,
                get= function(save) return save.strata or 'MEDIUM' end,
                set= function(save, value) save.strata= value end,
                apply= Refresh('settings')},
            {type='button', key='resetPoint', text='RESET_POSITION', buttonText='RESET',
                disabled= function(save) return not save.point end,
                func= function(_, save)
                    save.point= nil
                    WoWTools_HolidayMixin:Refresh_TrackButton('point')
                    WoWTools_Print(
                        WoWTools_HolidayMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_L.RESET_POSITION
                    )
                end},
        }
    end,
    blizzard= {Blizzard_Calendar= Init},
    events= {PLAYER_ENTERING_WORLD= function()
        Init_Open()
        return true
    end},
})
