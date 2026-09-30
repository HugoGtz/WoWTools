local function Save()
    return WoWToolsPlusSave['Plus_WorldMap']
end


local function Init()
    do
        WoWTools_WorldMapMixin:Init_Menu()--设置菜单
    end
    WoWTools_WorldMapMixin:Init_MpaID()--地图ID，信息
    WoWTools_WorldMapMixin:Init_XY_Map()--地图坐标
    WoWTools_WorldMapMixin:Init_XY_Player()--实时玩家当前坐标

    WoWTools_WorldMapMixin:Init_AreaPOI_Name()--地图POI提示，加名称
    WoWTools_WorldMapMixin:Init_Dungeon_Name()--地下城，加名称
    WoWTools_WorldMapMixin:Init_WorldQuest_Name()--世界地图任务，加名称

    WoWTools_WorldMapMixin:Init_Plus_Menu()--设置菜单
    WoWTools_WorldMapMixin:Init_Plus()

    WoWTools_WorldMapMixin:Init_FlightMap_Name()--飞行点，加名称

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
        ShowMapID= true,--地图ID
        ShowMapXY= true,--地图坐标
        PlayerXY={--实时玩家当前坐标
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
            ["47.40 52.60"]={name=PROFESSIONS_BUTTON,},--antes la condición estaba al revés y salía "专业" para todos
        },
    }



    WoWTools_WorldMapMixin.addName= '|A:poi-islands-table:0:0|a'..(WoWTools_L['Module.World map'])
    WoWTools_WorldMapMixin.addName2= '|A:Gear:0:0|a'..(WoWTools_L.MAP_PIN)
    --添加控制面板
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