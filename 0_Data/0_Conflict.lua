--Aviso: WoWToolsPlus y el WoWTools original usan los mismos globales y SavedVariables.
--Si ambos están activos se pisan entre sí, así que solo debe estar activo uno.
EventUtil.ContinueOnPlayerLogin(function()
    if C_AddOns.IsAddOnLoaded('WoWTools') then
        local msg= '|cffff0000WoWToolsPlus:|r el addon original |cffffff00WoWTools|r también está activo. Desactiva uno de los dos y recarga la interfaz (/reload).'
        print(msg)
        UIErrorsFrame:AddMessage(msg, 1, 0.1, 0.1)
    end
end)
