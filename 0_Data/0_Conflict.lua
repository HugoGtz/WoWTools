--Aviso: WoWToolsPlus y el WoWTools original comparten los mismos globales de código (mixins, marcos).
--Los ajustes guardados ya son independientes, pero si ambos están activos el código se pisa.
EventUtil.ContinueOnPlayerLogin(function()
    if C_AddOns.IsAddOnLoaded('WoWTools') then
        local msg= '|cffff0000WoWToolsPlus:|r el addon original |cffffff00WoWTools|r también está activo. Desactiva uno de los dos y recarga la interfaz (/reload).'
        print(msg)
        UIErrorsFrame:AddMessage(msg, 1, 0.1, 0.1)
    end
end)
