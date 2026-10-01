WoWTools_WorldMapMixin={}


function WoWTools_WorldMapMixin:ShowWorldFrame(mapID)
    if mapID then
        --if not WorldMapFrame.mapID  then
        OpenWorldMap(mapID)
    elseif not WorldMapFrame or not WorldMapFrame:IsShown() then
        ToggleWorldMap()
    end
end

function WoWTools_WorldMapMixin:Refresh(isQuest)
    if not WoWTools_FrameMixin:IsLocked(WorldMapFrame) and WorldMapFrame:IsShown() then
        if isQuest then
            WoWTools_DataMixin:Call(WorldMapFrame.RefreshQuestLog, WorldMapFrame)
        else
            WoWTools_DataMixin:Call(WorldMapFrame.RefreshOverlayFrames, WorldMapFrame)
        end
    end
end




function WoWTools_WorldMapMixin:GetMapID()
    return WorldMapFrame.mapID or MapUtil.GetDisplayableMapForPlayer()--C_Map.GetBestMapForUnit("player")
end


function WoWTools_WorldMapMixin:GetPlayerXY()
    local uiMapID= C_Map.GetBestMapForUnit("player")
    if uiMapID then
        local position = C_Map.GetPlayerMapPosition(uiMapID, "player")
        if position then
            local x, y
            x,y=position:GetXY()
            if x and y then
                x= format('%.2f', x*100)
                y= format('%.2f', y*100)
                return x, y, uiMapID
            end
        end
    end
end

function WoWTools_WorldMapMixin:GetMapXY()
    local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
    if x and y then
        return format('%.2f', x*100), format('%.2f', y*100)
    end
end


function WoWTools_WorldMapMixin:SendPlayerPoint()
    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID then
        --GetPlayerMapPosition puede ser nil (posición restringida) aunque se permitan waypoints
        local pos= C_Map.CanSetUserWaypointOnMap(mapID) and C_Map.GetPlayerMapPosition(mapID, "player")
        if pos then
            local point= C_Map.GetUserWaypoint()
            local mapPoint = UiMapPoint.CreateFromVector2D(mapID, pos)
            C_Map.SetUserWaypoint(mapPoint)
            WoWTools_ChatMixin:Chat(C_Map.GetUserWaypointHyperlink(), nil, true)
            --ChatFrame_OpenChat(SELECTED_DOCK_FRAME.editBox:GetText()..C_Map.GetUserWaypointHyperlink())
            if point then
                C_Map.SetUserWaypoint(point)
            else
                C_Map.ClearUserWaypoint()
            end
            return

        else
            local xy= self:GetTextForXY(nil, nil, false, true)
            if xy then
                local info=C_Map.GetMapInfo(mapID)
                WoWTools_ChatMixin:Chat(
                    xy
                    ..(info and info.name and ' '..info.name or ''),

                    nil,
                    true
                )
                --ChatFrame_OpenChat(SELECTED_DOCK_FRAME.editBox:GetText()..pointText)
                return
            end
        end
    end

    local name= GetMinimapZoneText()
    local name2
    if mapID then
        local info=C_Map.GetMapInfo(mapID)
        name2=info and info.name
    end
    if name  or name2 then
        if name2 and name~=name2 then
            name=name2..'('..name..')'
        end
        name =name or name2
        WoWTools_ChatMixin:Chat(name, nil, true)
    else
        WoWTools_Print(WoWTools_L['Cannot set waypoints on this map'])
    end
end


--['50.02 74.76']
function WoWTools_WorldMapMixin:GetXYForText(text)
    text= text and tostring(text)
    if text then
        text= text:gsub('  ', ' ')
        local x, y= text:match('(.-) (.+)')
        if x and y then
            x, y= tonumber(x), tonumber(y)
            if x and y and x>=0 and x<=100 and y>=0 and y<=100 then
                return x, y
            end
        end
    end
end

 function WoWTools_WorldMapMixin:GetTextForXY(x, y, isMap, isPlayer)
    local mapID
    if isMap then
        x, y= self:GetMapXY()
    elseif isPlayer then
        x, y, mapID= self:GetPlayerXY()
    end
    if x and y then
        return x..' '..y, mapID
    end
 end

