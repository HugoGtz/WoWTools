--Textos propios del fork (es/en). En la fase 3 se irán moviendo aquí los literales del addon.
--Uso: WoWTools_L['clave']. Si falta la clave en el idioma actual se usa enUS.
local locale= GetLocale()

local enUS= {
    AutoEnterDelve= 'Auto enter',
    AutoEnterDelveTip= 'Enters the delve automatically after 3 seconds.\nHold Alt to cancel.',
}

local esES= {
    AutoEnterDelve= 'Entrar solo',
    AutoEnterDelveTip= 'Entra en la profundidad automáticamente a los 3 segundos.\nMantén Alt para cancelar.',
}

local current= (locale=='esES' or locale=='esMX') and esES or enUS

WoWTools_L= setmetatable({}, {__index= function(_, key)
    return current[key] or enUS[key] or key
end})
