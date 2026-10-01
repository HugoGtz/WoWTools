--[[
API común de módulos (refactor R1). Un módulo se declara así:

local M= WoWTools_Module:Register({
    key      = 'Plus_Color',            --clave en WoWToolsPlusSave (la de siempre: no se pierden ajustes)
    name     = 'Module.Color picker',   --clave de WoWTools_L para el nombre
    icon     = 'colorblind-colorwheel', --atlas (o ruta de textura) del icono
    group    = 'Interface',             --grupo del panel principal (ver Groups en 0_Data/z_Panel.lua)
    defaults = {logColor={}},           --valores por defecto (WoWTools_DataMixin:SetDefaults)
    tooltip  = 'Tip.Color.Enable',      --clave de WoWTools_L con la descripción
    reload   = true,                    --activar/desactivar pide /reload (por defecto true)
    button   = {text='SHOW', func=function(M) ... end}, --botón opcional junto a la casilla
    mixin    = WoWTools_ColorMixin,     --tabla del módulo que se completa (opcional)
    onEnable = function(M, save) ... end,       --arranque: una sola vez y solo si está activado
    onLogin  = function(M, save) ... end,       --al entrar al juego (PLAYER_ENTERING_WORLD), una vez
    blizzard = {Blizzard_X= function(M, save) ... end}, --cuando esa ventana de Blizzard esté cargada
    events   = {PET_STABLE_SHOW= function(M, save, ...) ... end}, --eventos del juego (un solo marco para todos);
                                                                  --devolver true deja de escuchar ese evento
})

Después, en cualquier archivo del módulo: M:Save().algo, M:IsEnabled(), M:Print(...), M.addName
Todos los módulos migrados comparten un solo marco para ADDON_LOADED.
]]

WoWTools_Module= {
    List= {},           --módulos en orden de registro
    ByKey= {},
    GroupNames= {},     --grupo -> {addName,...}: lo usa el panel principal para agruparlos
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

local function Add_Panel(M)
    local def= M.def
    if def.panel==false then
        return
    end
    local tooltip= def.tooltip and WoWTools_L[def.tooltip] or nil
    if def.reload~=false then
        tooltip= (tooltip and tooltip..'|n|n' or '')..WoWTools_L.REQUIRES_RELOAD
    end
    local tab= {
        tooltip= tooltip,
        GetValue= function() return M:IsEnabled() end,
        SetValue= function()
            M:Save().disabled= M:IsEnabled() and true or nil
            M:Print(WoWTools_TextMixin:GetEnabeleDisable(M:IsEnabled()), def.reload~=false and WoWTools_L.REQUIRES_RELOAD or '')
        end,
    }
    if def.button then
        tab.checkName= M.addName
        tab.buttonText= Get_Icon(def.icon)..(WoWTools_L[def.button.text] or def.button.text)
        tab.buttonFunc= function() def.button.func(M, M:Save()) end
        WoWTools_PanelMixin:Check_Button(tab)
    else
        tab.name= M.addName
        WoWTools_PanelMixin:OnlyCheck(tab)
    end
end

local function Start(M)
    local def= M.def
    WoWToolsPlusSave[M.key]= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave[M.key], def.defaults or {})

    M.addName= Get_Icon(def.icon)..(def.name and WoWTools_L[def.name] or M.key)
    if def.group then
        WoWTools_Module.GroupNames[def.group]= WoWTools_Module.GroupNames[def.group] or {}
        table.insert(WoWTools_Module.GroupNames[def.group], M.addName)
    end

    Add_Panel(M)

    if not M:IsEnabled() then
        return
    end

    if def.onEnable then
        def.onEnable(M, M:Save())
    end
    if def.onLogin then
        EventUtil.ContinueOnPlayerLogin(function()
            def.onLogin(M, M:Save())
        end)
    end
    for event, func in pairs(def.events or {}) do
        WoWTools_Module:RegisterEvent(M, event, func)
    end
    for addonName, func in pairs(def.blizzard or {}) do
        EventUtil.ContinueOnAddOnLoaded(addonName, function()
            func(M, M:Save())
        end)
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




--Marco propio (y no EventUtil) para que se ejecute después del de 0_Data/z_Panel.lua,
--que crea la cabecera del panel principal: los marcos reciben el evento en el orden en que se registraron.
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
