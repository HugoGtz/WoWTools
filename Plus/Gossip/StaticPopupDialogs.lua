local function Save()
    return WoWToolsPlusSave['Plus_Gossip']
end


local FORBIDDEN_ID

local Err={}

--No modificar StaticPopupDialogs de Blizzard (taint) ni ocultar ADDON_ACTION_FORBIDDEN:
--el jugador debe ver qué addon ha sido bloqueado. Solo se añade el aviso en el chat.
local function Init()
    if Save().gossip then
        if not FORBIDDEN_ID then
            FORBIDDEN_ID= EventRegistry:RegisterFrameEventAndCallback("ADDON_ACTION_FORBIDDEN", function(_, arg1, func)
                if not Err[arg1] or not Err[arg1][func] then
                    Err[arg1]= Err[arg1] or {}
                    Err[arg1][func]=true
                    print(
                        WoWTools_GossipMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WARNING_FONT_COLOR:WrapTextInColorCode(format(
                            WoWTools_L.ADDON_ACTION_FORBIDDEN,
                            arg1 or '')
                        ),
                        func
                    )
                end
            end)
        end
    elseif FORBIDDEN_ID  then
        EventRegistry:UnregisterFrameEventAndCallback('ADDON_ACTION_FORBIDDEN', FORBIDDEN_ID)
        FORBIDDEN_ID= nil
    end
end



function WoWTools_GossipMixin:Init_StaticPopupDialogs()
    Init()
end