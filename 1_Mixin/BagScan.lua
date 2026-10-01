--[[
Escaneo de bolsas compartido (refactor R1, docs/MEJORAS.md sección 4).
Antes, cada módulo (Comida, Abrir objetos, Usar objetos, Monedas, Míticas+...) recorría todas las bolsas en cada
BAG_UPDATE por su cuenta. Ahora hay un único escaneo tras BAG_UPDATE_DELAYED (agrupado en 0,2 s) y los módulos
leen el resultado:

    WoWTools_BagScan:Subscribe(owner, function(scan) ... end) --se llama tras cada escaneo (y al suscribirse si ya hay datos)
    WoWTools_BagScan:Unsubscribe(owner)
    WoWTools_BagScan:GetItems()            --lista {bag=, slot=, info=GetContainerItemInfo}
    WoWTools_BagScan:GetCount(itemID)      --cantidad total en las bolsas (incluida la bolsa de componentes)
    WoWTools_BagScan:Find(itemID)          --primer {bag=, slot=, info=} con ese objeto
]]

WoWTools_BagScan= {}

local Items= {}
local Counts= {}
local Subscribers= {}
local Pending
local Scanned

local function Scan()
    Pending= nil
    wipe(Items)
    wipe(Counts)
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do
        for slot= 1, C_Container.GetContainerNumSlots(bag) or 0 do
            local info= C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID then
                table.insert(Items, {bag=bag, slot=slot, info=info})
                Counts[info.itemID]= (Counts[info.itemID] or 0) + (info.stackCount or 1)
            end
        end
    end
    Scanned= true
    for _, func in pairs(Subscribers) do
        func(WoWTools_BagScan)
    end
end

local function Queue()
    if not Pending then
        Pending= C_Timer.NewTimer(0.2, Scan)
    end
end

local Frame= CreateFrame('Frame')
Frame:RegisterEvent('BAG_UPDATE_DELAYED')
Frame:RegisterEvent('PLAYER_ENTERING_WORLD')
Frame:SetScript('OnEvent', Queue)




function WoWTools_BagScan:Subscribe(owner, func)
    Subscribers[owner]= func
    if Scanned then
        func(self)
    end
end

function WoWTools_BagScan:Unsubscribe(owner)
    Subscribers[owner]= nil
end

function WoWTools_BagScan:GetItems()
    return Items
end

function WoWTools_BagScan:GetCount(itemID)
    return itemID and Counts[itemID] or 0
end

function WoWTools_BagScan:Find(itemID)
    for _, item in ipairs(Items) do
        if item.info.itemID==itemID then
            return item
        end
    end
end

--Forzar un escaneo ya (p. ej. justo después de usar un objeto)
function WoWTools_BagScan:Refresh()
    if Pending then
        Pending:Cancel()
    end
    Scan()
end
