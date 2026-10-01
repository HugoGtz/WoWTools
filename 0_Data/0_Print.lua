--Mensajes del addon en el chat. Todo el addon usa WoWTools_Print en lugar de print.
--Por defecto no se muestran (opción "Mostrar mensajes del addon en el chat" en General).
function WoWTools_Print(...)
    local save= WoWToolsPlusSave and WoWToolsPlusSave['WoWTools_Settings']
    if save and save.showChatMessages then
        print(...)
    end
end
