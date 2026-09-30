local function Save()
    return WoWToolsPlusSave['Plus_WorldMap']
end


local function Init()
    do
        WoWTools_WorldMapMixin:Init_Menu()
    end
    WoWTools_WorldMapMixin:Init_MpaID()
    WoWTools_WorldMapMixin:Init_XY_Map()
    WoWTools_WorldMapMixin:Init_XY_Player()

    WoWTools_WorldMapMixin:Init_AreaPOI_Name()
    WoWTools_WorldMapMixin:Init_Dungeon_Name()
    WoWTools_WorldMapMixin:Init_WorldQuest_Name()

    WoWTools_WorldMapMixin:Init_Plus_Menu()
    WoWTools_WorldMapMixin:Init_Plus()

    WoWTools_WorldMapMixin:Init_FlightMap_Name()

    WoWTools_WorldMapMixin:Init_PlayerPin()

    Init=function()end
end




local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1~= 'WoWToolsPlus' then
        return
    end

    WoWToolsPlusSave['Plus_WorldMap']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_WorldMap'], {
        ShowMapID= true,
        ShowMapXY= true,
        PlayerXY={
            disabled= true,
            textY=-2,
        },
        ShowAreaPOI_Name=true,
        ShowDungeon_Name=true,
        ShowWorldQues_Name=true,
        PlayerPin={},
        AreaPOI={}
    })

    Save().PlayerXY= Save().PlayerXY or {}
    Save().PlayerPin= Save().PlayerPin or {size=12}

    WoWToolsPlusPlayerDate.WorldMapUserAreaPoiName= WoWToolsPlusPlayerDate.WorldMapUserAreaPoiName or {
        noShow={},
        pinName={},
    }

    WoWToolsPlusPlayerDate.WorldMapPin= nil

    WoWToolsPlusPlayerDate.PlayerMapPin= WoWToolsPlusPlayerDate.PlayerMapPin or {
        [2393]= {
            options={},
            ["50.02 74.76"]= {name=WoWTools_L['BUTTON_LAG_AUCTIONHOUSE~2'],},
            ["47.40 52.60"]={name=PROFESSIONS_BUTTON,},
        },
    }



    WoWTools_WorldMapMixin.addName= '|A:poi-islands-table:0:0|a'..(WoWTools_L['Module.World map'])
    WoWTools_WorldMapMixin.addName2= '|A:Gear:0:0|a'..(WoWTools_L.MAP_PIN)
    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_WorldMapMixin.addName,
        tooltip=  WoWTools_L['Tip.WorldMap.Enable']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
        GetValue= function() return not Save().disabled end,
        func= function()
            Save().disabled= not Save().disabled and true or nil
            Init()
        end
    })

    if not Save().disabled then
        Init()
    end

    self:SetScript('OnEvent', nil)
    self:UnregisterEvent(event)
end)