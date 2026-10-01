--[[
API común de módulos (refactor R1). Un módulo se declara así:

local M= WoWTools_Module:Register({
    key      = 'Plus_Color',            --clave en WoWToolsPlusSave (la de siempre: no se pierden ajustes)
    name     = 'Module.Color picker',   --clave de WoWTools_L para el nombre
    icon     = 'colorblind-colorwheel', --atlas (o ruta de textura) del icono
    group    = 'Interface',             --grupo del Centro de control (Interface, Chat, Items, Character, World, Tools)
    parent   = 'WoWTools_ToolsButton',  --submódulo: se muestra dentro de la página de ese módulo (sin tarjeta propia)
    defaults = {logColor={}},           --valores por defecto (WoWTools_DataMixin:SetDefaults)
    tooltip  = 'Tip.Color.Enable',      --clave de WoWTools_L con la descripción (tarjeta y página del módulo)
    reload   = true,                    --activar/desactivar pide /reload (por defecto true)
    button   = {text='SHOW', func=function(M) ... end}, --botón opcional en la página del módulo
    mixin    = WoWTools_ColorMixin,     --tabla del módulo que se completa (opcional)
    options  = {...} o function(M, save) return {...} end, --esquema de opciones (docs/SETTINGS.md)
    openSettings = function(M) ... end, --abre lo que tenga hoy (su menú...) si no tiene options ni subpágina
    toggle   = true|false,              --interruptor de activar en la tarjeta. Por defecto sí, salvo con panel=false
                                        --(entonces solo si el módulo creó su casilla con OnlyCheck en onLoad)
    onToggle = function(M, enabled, save) ... end, --al activarlo/desactivarlo desde el Centro de control
    childToggle = {get=function(M, child) end, set=function(M, child, value) end}, --interruptor de sus submódulos
                                        --(por defecto: activar/desactivar el submódulo, child:SetEnabled)
    panel    = false,                   --tiene su propia casilla o página de Blizzard (no se le pone interruptor)
    onLoad   = function(M, save) ... end,       --se ejecuta siempre, aunque el módulo esté desactivado
    onEnable = function(M, save) ... end,       --arranque: una sola vez y solo si está activado
    onLogin  = function(M, save) ... end,       --al entrar al juego (PLAYER_ENTERING_WORLD), una vez
    blizzard = {Blizzard_X= function(M, save) ... end}, --cuando esa ventana de Blizzard esté cargada
    events   = {PET_STABLE_SHOW= function(M, save, ...) ... end}, --eventos del juego (un solo marco para todos);
                                                                  --devolver true deja de escuchar ese evento
})

Después, en cualquier archivo del módulo: M:Save().algo, M:IsEnabled(), M:SetEnabled(v), M:Print(...), M.addName, M.name
Todos los módulos migrados comparten un solo marco para ADDON_LOADED.
El Centro de control (1_Mixin/ControlCenter.lua) lee WoWTools_Module.List: ya no se crean casillas en el panel de Blizzard.
]]

WoWTools_Module= {
    List= {},           --módulos en orden de registro
    ByKey= {},
    GroupNames= {},     --grupo -> {addName,...} (compatibilidad)
    Current= nil,       --módulo cuyo onLoad/onEnable/... se está ejecutando: el panel le asocia lo que cree
}

local Loaded--ya llegó ADDON_LOADED de WoWToolsPlus

--Despachador único de eventos de los módulos: evento -> {M= handler}
local Handlers= {}
local EventFrame= CreateFrame('Frame')
EventFrame:SetScript('OnEvent', function(self, event, ...)
    for M, func in pairs(Handlers[event] or {}) do
        if func(M, M:Save(), ...) then
            WoWTools_Module:UnregisterEvent(M, event)
        end
    end
end)

function WoWTools_Module:RegisterEvent(M, event, func)
    Handlers[event]= Handlers[event] or {}
    Handlers[event][M]= func
    EventFrame:RegisterEvent(event)
end

function WoWTools_Module:UnregisterEvent(M, event)
    local list= Handlers[event]
    if list then
        list[M]= nil
        if not next(list) then
            EventFrame:UnregisterEvent(event)
        end
    end
end

--Envoltorio "ejecutar una sola vez" (sustituye al truco Init=function()end)
function WoWTools_Once(func)
    local done
    return function(...)
        if not done then
            done= true
            return func(...)
        end
    end
end




local ModuleMixin= {}

function ModuleMixin:Save()
    return WoWToolsPlusSave and WoWToolsPlusSave[self.key] or {}
end

function ModuleMixin:IsEnabled()
    return not self:Save().disabled
end

--Activa o desactiva el módulo (lo usa el Centro de control). Devuelve true si hace falta /reload.
function ModuleMixin:SetEnabled(enabled)
    local def= self.def
    local save= self:Save()
    save.disabled= not enabled and true or nil
    if def.onToggle then
        def.onToggle(self, enabled and true or false, save)
    end
    if enabled and def.reload==false and not self.started then
        WoWTools_Module:Enable(self)
    end
    return def.reload~=false
end

function ModuleMixin:Print(...)
    WoWTools_Print(self.addName..WoWTools_DataMixin.Icon.icon2, ...)
end




local function Get_Icon(icon)
    if not icon then
        return ''
    elseif type(icon)=='number' or icon:find('[\\/]') then
        return '|T'..icon..':0|t'
    end
    return '|A:'..icon..':0:0|a'
end

--Ejecuta una función del módulo anotando cuál es (WoWTools_Module.Current). Un error no corta el arranque de los demás.
local function Error_Handler(err)
    local handler= geterrorhandler and geterrorhandler()
    if handler then
        return handler(err)
    end
    print(err)
end

local function Call(M, func, ...)
    local prev= WoWTools_Module.Current
    WoWTools_Module.Current= M
    xpcall(func, Error_Handler, ...)--el manejador de errores de WoW recibe la pila completa
    WoWTools_Module.Current= prev
end

--Arranque de un módulo activado: una sola vez
function WoWTools_Module:Enable(M)
    if M.started then
        return
    end
    M.started= true
    local def= M.def
    if def.onEnable then
        Call(M, def.onEnable, M, M:Save())
    end
    if def.onLogin then
        EventUtil.ContinueOnPlayerLogin(function()
            Call(M, def.onLogin, M, M:Save())
        end)
    end
    for event, func in pairs(def.events or {}) do
        self:RegisterEvent(M, event, func)
    end
    for addonName, func in pairs(def.blizzard or {}) do
        EventUtil.ContinueOnAddOnLoaded(addonName, function()
            Call(M, func, M, M:Save())
        end)
    end
end

local function Start(M)
    local def= M.def
    WoWToolsPlusSave[M.key]= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave[M.key], def.defaults or {})

    M.name= def.name and WoWTools_L[def.name] or M.key
    M.icon= def.icon
    M.addName= Get_Icon(def.icon)..M.name
    if def.group and not def.parent then
        WoWTools_Module.GroupNames[def.group]= WoWTools_Module.GroupNames[def.group] or {}
        table.insert(WoWTools_Module.GroupNames[def.group], M.addName)
    end

    if def.onLoad then
        Call(M, def.onLoad, M, M:Save())
    end

    if M:IsEnabled() then
        WoWTools_Module:Enable(M)
    end
end




function WoWTools_Module:Register(def)
    assert(type(def)=='table' and type(def.key)=='string', 'WoWTools_Module:Register: falta key')
    assert(not self.ByKey[def.key], 'WoWTools_Module:Register: key repetida '..def.key)

    local M= def.mixin or {}
    Mixin(M, ModuleMixin)
    M.key= def.key
    M.def= def
    M.group= def.group
    M.parent= def.parent

    table.insert(self.List, M)
    self.ByKey[def.key]= M

    if Loaded then--registrado tarde: arranca ya
        Start(M)
    end
    return M
end

function WoWTools_Module:Get(key)
    return self.ByKey[key]
end

--childToggle para padres cuyos botones se activan con save.disabledADD[nombre] (Herramientas, Botón de chat).
--map: clave del submódulo -> nombre en disabledADD; los que no están en map usan su propio interruptor.
function WoWTools_Module:DisabledADDToggle(map)
    return {
        get= function(parent, child)
            local name= map[child.key]
            if name then
                return not parent:Save().disabledADD[name]
            end
            return child:IsEnabled()
        end,
        set= function(parent, child, value)
            local name= map[child.key]
            if name then
                parent:Save().disabledADD[name]= not value and true or nil
            else
                child:SetEnabled(value)
            end
        end,
    }
end

--Submódulos de un módulo (def.parent==key), en orden de registro
function WoWTools_Module:GetChildren(key)
    local list= {}
    for _, M in ipairs(self.List) do
        if M.parent==key then
            table.insert(list, M)
        end
    end
    return list
end




--Marco propio (y no EventUtil) para que se ejecute después del de 0_Data/z_Panel.lua
--(ajustes generales): los marcos reciben el evento en el orden en que se registraron.
local Frame= CreateFrame('Frame')
Frame:RegisterEvent('ADDON_LOADED')
Frame:SetScript('OnEvent', function(self, event, arg1)
    if arg1~='WoWToolsPlus' then
        return
    end
    self:UnregisterEvent(event)
    Loaded= true
    WoWTools_DataMixin:Init_SavedVariables()
    for _, M in ipairs(WoWTools_Module.List) do
        Start(M)
    end
end)
