--[[
Esquema de opciones declarativo (docs/SETTINGS.md): la lógica sin marcos.
Textos, lectura y escritura de valores, cambios que requieren /reload y búsqueda.
Lo dibuja el Centro de control (1_Mixin/ControlCenter.lua).

Una "página" es {id=, M=módulo o nil, save=function() return tabla end, options=lista o function(M)}.
Cada opción de la lista es una tabla {type=..., text=..., get=..., set=..., ...} (ver docs/SETTINGS.md).
]]

WoWTools_Options= {
    Pending= {},   --id -> {orig=, text=}: cambios hechos que requieren /reload
    Listeners= {}, --funciones que se llaman cuando cambia la lista de pendientes
}
local Options= WoWTools_Options

--Tipos que reconoce el esquema (los demás se ignoran)
Options.Types= {
    section=true, check=true, slider=true, dropdown=true, color=true,
    input=true, button=true, note=true, children=true,
}




--------------------------------------------------------------------------------
--Textos
--------------------------------------------------------------------------------

--Texto visible: clave de WoWTools_L (si no existe se usa tal cual) o función que lo devuelve
function Options:Text(value, ...)
    if type(value)=='function' then
        value= value(...)
    end
    if type(value)=='string' then
        if value=='' then
            return ''
        end
        local text= WoWTools_L and WoWTools_L[value]
        return type(text)=='string' and text or value
    elseif value~=nil then
        return tostring(value)
    end
end


--Quita iconos, colores y saltos de línea del texto
function Options:Plain(text)
    if type(text)~='string' then
        return text~=nil and tostring(text) or ''
    end
    text= text:gsub('|A.-|a', '')
        :gsub('|T.-|t', '')
        :gsub('|c%x%x%x%x%x%x%x%x', '')
        :gsub('|cn.-:', '')
        :gsub('|r', '')
        :gsub('|n', ' ')
        :gsub('\n', ' ')
        :gsub('%s+', ' ')
        :gsub('^%s+', '')
        :gsub('%s+$', '')
    return text
end


--Primer icono que lleva pegado el texto (|A:atlas...|a o |Truta...|t), para dibujarlo aparte
function Options:GetInlineIcon(text)
    if type(text)~='string' then
        return
    end
    local atlas= text:match('|A:([^:|]+)')
    if atlas then
        return atlas
    end
    local path= text:match('|T([^:|]+)')
    if path then
        return tonumber(path) or path
    end
end


--Minúsculas y sin tildes (para buscar en español escribiendo "metodo" o "MÉTODO")
local Accents= {
    ['á']='a', ['à']='a', ['â']='a', ['ä']='a', ['ã']='a',
    ['é']='e', ['è']='e', ['ê']='e', ['ë']='e',
    ['í']='i', ['ì']='i', ['î']='i', ['ï']='i',
    ['ó']='o', ['ò']='o', ['ô']='o', ['ö']='o', ['õ']='o',
    ['ú']='u', ['ù']='u', ['û']='u', ['ü']='u',
    ['ñ']='n', ['ç']='c',
    ['Á']='a', ['À']='a', ['Â']='a', ['Ä']='a', ['Ã']='a',
    ['É']='e', ['È']='e', ['Ê']='e', ['Ë']='e',
    ['Í']='i', ['Ì']='i', ['Î']='i', ['Ï']='i',
    ['Ó']='o', ['Ò']='o', ['Ô']='o', ['Ö']='o', ['Õ']='o',
    ['Ú']='u', ['Ù']='u', ['Û']='u', ['Ü']='u',
    ['Ñ']='n', ['Ç']='c',
}

function Options:Fold(text)
    text= self:Plain(text):lower()
    return (text:gsub('\195[\128-\191]', Accents))
end


--¿Contiene el texto todas las palabras de la búsqueda? (query ya pasada por Fold)
function Options:Match(query, ...)
    if not query or query=='' then
        return false
    end
    local hay= {}
    for i= 1, select('#', ...) do
        local text= select(i, ...)
        if text and text~='' then
            hay[#hay+1]= self:Fold(text)
        end
    end
    local all= table.concat(hay, ' ')
    for word in query:gmatch('%S+') do
        if not all:find(word, 1, true) then
            return false
        end
    end
    return true
end




--------------------------------------------------------------------------------
--Páginas y valores
--------------------------------------------------------------------------------

function Options:GetSave(page)
    if page.save then
        return page.save() or {}
    elseif page.M and page.M.Save then
        return page.M:Save() or {}
    end
    return {}
end


--Lista de opciones de una página, ya validadas y con su id. Las funciones se evalúan cada vez
--(al abrir la página o buscar), así que deben ser rápidas y sin efectos secundarios.
function Options:Resolve(page)
    local list= page.options
    if type(list)=='function' then
        list= list(page.M, self:GetSave(page))
    end
    local items= {}
    if type(list)~='table' then
        return items
    end
    local section
    for index, opt in ipairs(list) do
        if type(opt)=='table' and self.Types[opt.type] then
            opt.page= page
            opt.id= page.id..':'..(opt.key or index)
            if opt.type=='section' then
                section= opt
            else
                opt.section= section
            end
            items[#items+1]= opt
        end
    end
    return items
end


local function Eval(value, opt, self)
    if type(value)=='function' then
        return value(self:GetSave(opt.page), opt.page.M)
    end
    return value
end

function Options:IsHidden(opt)
    return Eval(opt.hidden, opt, self) and true or false
end

function Options:IsDisabled(opt)
    if Eval(opt.disabled, opt, self) then
        return true
    end
    if opt.noCombat and InCombatLockdown and InCombatLockdown() then
        return true
    end
    return false
end


--Valor actual (color: r, g, b, a)
function Options:GetValue(opt)
    if opt.get then
        return opt.get(self:GetSave(opt.page), opt.page.M)
    end
end


--Representación comparable de un valor (para saber si se ha vuelto al valor original)
local function Snapshot(...)
    local n= select('#', ...)
    local out= {}
    for i= 1, n do
        local v= select(i, ...)
        if type(v)=='number' then
            out[i]= format('%.4f', v)
        else
            out[i]= tostring(v)
        end
    end
    return table.concat(out, ',')
end


--Combate: las opciones con noCombat=true aplazan su apply hasta salir del combate
local Deferred= {}
local DeferFrame
local function Defer_Apply(opt)
    Deferred[opt]= true
    if not DeferFrame then
        DeferFrame= CreateFrame('Frame')
        DeferFrame:SetScript('OnEvent', function(frame)
            frame:UnregisterAllEvents()
            local list= Deferred
            Deferred= {}
            for item in pairs(list) do
                item.apply(item.page.M, Options:GetSave(item.page), Options:GetValue(item))
            end
        end)
    end
    DeferFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
end


--Escribe el valor (color: r, g, b, a), llama a apply y anota si requiere /reload
function Options:SetValue(opt, ...)
    if not opt.set then
        return
    end
    local save= self:GetSave(opt.page)
    local before= opt.reload and Snapshot(self:GetValue(opt))

    local n= select('#', ...)
    if n<=1 then
        opt.set(save, (...), opt.page.M)
    else
        local args= {...}
        args[n+1]= opt.page.M
        opt.set(save, unpack(args, 1, n+1))
    end

    if opt.apply then
        if opt.noCombat and InCombatLockdown and InCombatLockdown() then
            Defer_Apply(opt)
        else
            opt.apply(opt.page.M, save, self:GetValue(opt))
        end
    end
    if opt.reload then
        self:Track(opt.reloadId or opt.id, before, Snapshot(self:GetValue(opt)), self:Text(opt.text))
    end
end


--Botón: func(M, save); con confirm pide confirmación antes
function Options:Run(opt)
    if not opt.func then
        return
    end
    local function Do()
        opt.func(opt.page.M, self:GetSave(opt.page))
        if opt.reload then
            self:Track(opt.id, 'run', 'done', self:Text(opt.text))
        end
    end
    if opt.confirm and StaticPopup_Show then
        local text= opt.confirm==true and self:Text(opt.text) or self:Text(opt.confirm)
        StaticPopup_Show('WoWTools_OK', text, nil, {SetValue= Do})
    else
        Do()
    end
end




--------------------------------------------------------------------------------
--Cambios pendientes de /reload
--------------------------------------------------------------------------------

--before/after: valores comparables. Si se vuelve al valor original, deja de estar pendiente.
function Options:Track(id, before, after, text)
    local item= self.Pending[id]
    if item then
        if item.orig==after then
            self.Pending[id]= nil
        end
    elseif before~=after then
        self.Pending[id]= {orig= before, text= text}
    end
    for _, func in ipairs(self.Listeners) do
        func(self:GetPendingCount())
    end
end

function Options:GetPendingCount()
    local n= 0
    for _ in pairs(self.Pending) do
        n= n+1
    end
    return n
end

function Options:IsPending(id)
    return self.Pending[id]~=nil
end

function Options:OnPendingChanged(func)
    table.insert(self.Listeners, func)
end

function Options:Reload()
    if WoWTools_DataMixin and WoWTools_DataMixin.Reload then
        WoWTools_DataMixin:Reload()
    else
        ReloadUI()
    end
end




--------------------------------------------------------------------------------
--Página General (la rellena 0_Data/z_Panel.lua)
--------------------------------------------------------------------------------

--options: lista del esquema. save: function() que devuelve la tabla de ajustes generales.
function Options:SetGeneral(options, save)
    self.General= {id='general', options= options, save= save}
end
