
--Minimap.lua
local function Save()
    return  WoWToolsPlusSave['Minimap_Plus']
end









local function Init_Menu(_, root)
    local frame= _G['WoWToolsMinimapUpdatZoomFrame']
    if not frame then
        return
    end

    local sub
    for _, value in pairs({'min', 2, 3, 4, 5, 'max'}) do
        sub=root:CreateRadio(
            value=='min' and (WoWTools_L.ZOOM_OUT)
            or (value=='max' and (WoWTools_L.ZOOM_IN))
            or value,
        function(data)
            return data.value==Save().ZoomOut
        end, function(data)
            if Save().ZoomOut== data.value then
                Save().ZoomOut= nil
            else
                Save().ZoomOut= data.value
            end
            frame:set_event()
            return MenuResponse.Refresh
        end, {value=value})

        sub:SetTooltip(function(tooltip)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.MiniMap.ZoomLevel'])
            tooltip:AddLine(WoWTools_L.LOCK)
        end)
    end
end




local function Init()
    Minimap.ZoomIn:HookScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)
    Minimap.ZoomOut:HookScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)

    Minimap.viewRadius=WoWTools_LabelMixin:Create(Minimap, {color=true, justifyH='CENTER', mouse=true})
    Minimap.viewRadius:SetPoint('BOTTOMLEFT', Minimap, 'BOTTOM', 8, -8)
    Minimap.viewRadius:SetAlpha(0.5)
    Minimap.viewRadius:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(0.5) end)
    Minimap.viewRadius:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_L.CAMERA_FOV, format(WoWTools_L.IN_GAME_NAVIGATION_RANGE, format('%i', C_Minimap.GetViewRadius() or 100)))
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MinimapMixin.addName)
        GameTooltip:Show()
        self:SetAlpha(1)
    end)

    Minimap.zoomText= WoWTools_LabelMixin:Create(Minimap, {color=true, mouse=true})
    Minimap.zoomText:SetPoint('BOTTOM', Minimap.ZoomOut, 'TOP', 3, 0)
    Minimap.zoomText:SetAlpha(0.5)
    Minimap.zoomText:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(0.5) end)
    Minimap.zoomText:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_L.HOUSING_EXPERT_DECOR_SUBMODE_SCALE, self:GetText())
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MinimapMixin.addName)
        GameTooltip:Show()
        self:SetAlpha(1)
    end)










    local Frame=CreateFrame('Frame', 'WoWToolsMinimapUpdatZoomFrame')
    function Frame:set_event()
        self:UnregisterAllEvents()
        if Save().ZoomOutInfo then
            self:RegisterEvent('MINIMAP_UPDATE_ZOOM')
            self:MINIMAP_UPDATE_ZOOM()
        else
            Minimap.zoomText:SetText('')
            Minimap.viewRadius:SetText('')
        end

        if Save().ZoomOut then
            self:RegisterEvent('ZONE_CHANGED')
            self:RegisterEvent('ZONE_CHANGED_INDOORS')
            self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
            self:ZONE_CHANGED()
        end
    end

    function Frame:ZONE_CHANGED()
        local value= Save().ZoomOut
        if value==nil then
            return
        end
        local max= (Minimap:GetZoomLevels() or 1)-1--índices válidos: 0 .. niveles-1
        local select=  (type(value)=='number' and value-1)
                        or (value=='max' and max)
                        or 0
        select= math.min(select, max)
        select= math.max(select, 0)

        if select~=Minimap:GetZoom() then
            Minimap:SetZoom(select)
        end
    end

    function Frame:MINIMAP_UPDATE_ZOOM()
        local level = Minimap:GetZoom()
        local max= Minimap:GetZoomLevels()
        Minimap.zoomText:SetText(
            max and max>0 and level
            and (max-(level or 0))..'/'..max
            or ''
        )
        Minimap.viewRadius:SetFormattedText('%i', C_Minimap.GetViewRadius() or 100)
    end

    Frame:SetScript("OnEvent", function(self, event)
        if event=='MINIMAP_UPDATE_ZOOM' then
            self:MINIMAP_UPDATE_ZOOM()
        else
            self:ZONE_CHANGED()
        end
    end)
    Frame:set_event()


    Init= function()
        _G['WoWToolsMinimapUpdatZoomFrame']:set_event()
    end
end



function WoWTools_MinimapMixin:Init_Minimap_Zoom()
    Init()
end

function WoWTools_MinimapMixin:Zoom_Menu(...)
    Init_Menu(...)
end
