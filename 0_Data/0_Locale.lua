--Textos propios del fork (es/en). En la fase 3 se irán moviendo aquí los literales del addon.
--Uso: WoWTools_L['clave']. Si falta la clave en el idioma actual se usa enUS, y si tampoco existe, la propia clave.
local locale= GetLocale()

local enUS= {
    AutoEnterDelve= 'Auto enter',
    AutoEnterDelveTip= 'Enters the delve automatically after 3 seconds.\nHold Alt to cancel.',
}

local esES= {
    AutoEnterDelve= 'Entrar solo',
    AutoEnterDelveTip= 'Entra en la profundidad automáticamente a los 3 segundos.\nMantén Alt para cancelar.',

    --Textos del addon original: la clave es el texto en inglés (se usa tal cual en enUS)
    ['Chapter']= 'Capítulo',
    ['Chinese font (ARHei)']= 'Fuente china (ARHei)',
    ['0 - Do not truncate']= '0 - No recortar',
    ['AFK']= 'Ausente',
    ['Background opacity']= 'Opacidad del fondo',
    ['Border opacity']= 'Opacidad del borde',
    ['Button']= 'Botón',
    ['Button Plus']= 'Botones mejorados',
    ['Cannot set waypoints on this map']= 'No se pueden poner marcas en este mapa',
    ['Chat box text']= 'Texto de la caja de chat',
    ['Clear input data']= 'Borrar datos introducidos',
    ['Click outside the color picker: auto-hide']= 'Clic fuera del selector de color: ocultar',
    ['Current season data mismatch']= 'Los datos de la temporada actual no coinciden',
    ['Custom position when shown']= 'Posición personalizada al mostrarse',
    ['Daisy']= 'Daisy',
    ['Decimals']= 'Decimales',
    ['Decimals ']= 'Decimales ',
    ['Difficulty can be changed']= 'Se puede cambiar la dificultad',
    ['Dismiss pet']= 'Retirar mascota',
    ['Dormant seeds']= 'Semillas latentes',
    ['Download']= 'Descargar',
    ['Effective']= 'Efectivo',
    ['Errors may occur']= 'Pueden producirse errores',
    ['Except for group instances']= 'Excepto en instancias de grupo',
    ['Fails when there is a clickable item button']= 'Falla si hay un botón de objeto clicable',
    ['Fix']= 'Corregir',
    ['Flyout']= 'Desplegable',
    ['Health bar']= 'Barra de salud',
    ['Index']= 'Índice',
    ['Insert']= 'Insertar',
    ['Interval']= 'Intervalo',
    ['Invalid coordinates']= 'Coordenadas no válidas',
    ['Lowercase']= 'Minúsculas',
    ['Lua data']= 'Datos Lua',
    ['MapID not found']= 'No se encontró MapID',
    ['Mount show']= 'Exhibir montura',
    ['Name-Realm']= 'Nombre-Reino',
    ['No data']= 'Sin datos',
    ['Note: errors may occur']= 'Nota: pueden producirse errores',
    ['Note: if you get errors, disable this']= 'Nota: si da errores, desactívalo',
    ['Numbers']= 'Números',
    ['Pick up']= 'Coger',
    ['Players around']= 'Jugadores cercanos',
    ['Please do not use in combat']= 'No usar en combate',
    ['Portrait']= 'Retrato',
    ['Press Esc to hide the frame']= 'Pulsa Esc para ocultar el marco',
    ['Random']= 'Aleatorio',
    ['Random icon']= 'Icono aleatorio',
    ['Realm']= 'Reino',
    ['Save up to %d colors']= 'Guarda hasta %d colores',
    ['Save up to 120 records']= 'Guarda hasta 120 registros',
    ['Selected']= 'Seleccionado',
    ['Shortcut list']= 'Lista de atajos',
    ['Shortcut list ']= 'Lista de atajos ',
    ['Showing the map in combat causes an error']= 'Mostrar el mapa en combate provoca un error',
    ['Spell flyout']= 'Desplegable de hechizos',
    ['Story']= 'Historia',
    ['Strata']= 'Capa',
    ['Tab']= 'Pestaña',
    ['Test']= 'Prueba',
    ['Truncate']= 'Recortar',
    ['Unified/Separate']= 'Unificado/Separado',
    ['Uppercase']= 'Mayúsculas',
    ['Vehicle']= 'Vehículo',
    ['Weapons can be switched during combat']= 'Se pueden cambiar las armas en combate',
    ['Welcome to join']= 'Bienvenida',
    ['When there is only one option, select it automatically.']= 'Si solo hay una opción, se elige automáticamente.',
    ['WoWTools Data']= 'Datos de WoWTools',
    ['Word count']= 'Número de caracteres',
    ['World Preload Non Critical']= 'Precarga no crítica del mundo',
    ['uiMapID not found']= 'No se encontró uiMapID',
    ['value: ']= 'valor: ',
}

local current= (locale=='esES' or locale=='esMX') and esES or enUS

WoWTools_L= setmetatable({}, {__index= function(_, key)
    return current[key] or enUS[key] or key
end})

--Une dos textos con un espacio, en el orden dado.
--Sustituye a WoWTools_Join(a, b), que es el formato "especialización clase"
--de Blizzard: en otros idiomas puede cambiar el orden o añadir preposiciones.
function WoWTools_Join(a, b)
    return tostring(a or '')..' '..tostring(b or '')
end
