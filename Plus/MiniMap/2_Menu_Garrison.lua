


--要塞,任务，列表
local function Get_Garrison_List_Num(followerType)
    local num, all, text= 0, 0, ''
    if followerType then
        local missions = C_Garrison.GetInProgressMissions(followerType) or {}--GarrisonBaseUtils.lua
        for _, mission in ipairs(missions) do
            if (mission.isComplete == nil) then
                mission.isComplete = mission.timeLeftSeconds == 0
            end
            if mission.isComplete then
                num = num + 1
            end
            all = all + 1
        end
        if all==0 then
            text= ''--format('|cff626262%d/%d|r', num, all)
        elseif num==0 then
            text= format('|cff626262%d|r/%d', num, all)
        elseif all==num then
            text= format('|cffff00ff%d/%d|r', num, all)..format('|A:%s:0:0|a', 'common-icon-checkmark')
        else
            text= format('|cnGREEN_FONT_COLOR:%d|r/%d', num, all)
        end
    end
    return text
end


--LuaEnum.lua
local GarrisonList
local function Init_GarrisonList()
    GarrisonList={

    {name=WoWTools_L.WAR_WITHIN_LANDING_PAGE_TITLE,--Blizzard_WarWithinLandingPage.lua
    garrisonType= Enum.ExpansionLandingPageType and Enum.ExpansionLandingPageType.WarWithin or 2,
    --garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower,
    disabled=  PlayerIsTimerunning() or not ExpansionLandingPage,
    --check= function() return ExpansionLandingPage and ExpansionLandingPage:IsShown() end,
    atlas= 'warwithin-landingbutton-up',
    --tooltip= DRAGONFLIGHT_LANDING_PAGE_TOOLTIP,
    func= function()
        if ExpansionLandingPage then
            ToggleExpansionLandingPage()
        end
    end,
    },

    {name='-'},

    {name=  WoWTools_L.GARRISON_TYPE_9_0_LANDING_PAGE_TITLE,
    garrisonType= Enum.GarrisonType.Type_9_0_Garrison,
    garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower,
    disabled= C_Covenants.GetActiveCovenantID()==0,
    atlas= function()
        local info= C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID() or 0) or {}
        local icon=''
        if info.textureKit then
            icon= format('CovenantChoice-Celebration-%sSigil', info.textureKit or '')
        end
        return icon
    end,
    --tooltip= GARRISON_TYPE_9_0_LANDING_PAGE_TOOLTIP,
    },


    {name=  WoWTools_L['Class Hall'],
    garrisonType= Enum.GarrisonType.Type_7_0_Garrison,
    garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower,
    frame='OrderHallMissionFrame',
    atlas= WoWTools_UnitMixin:GetClassIcon('player', nil, nil, {reAtlas=true}),--职业图标 -- WoWTools_DataMixin.Player.Class == "EVOKER" and "UF-Essence-Icon-Active" or string.format("legionmission-landingbutton-%s-up", WoWTools_DataMixin.Player.Class),
    --tooltip= MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP,
    },

    {name= WoWTools_L.GARRISON_LOCATION_TOOLTIP,
    garrisonType= Enum.GarrisonType.Type_6_0_Garrison,
    garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower,
    garrFollowerTypeID2=Enum.GarrisonFollowerType.FollowerType_6_0_Boat,
    atlas= format("GarrLanding-MinimapIcon-%s-Up", WoWTools_DataMixin.Player.Faction),
    atlas2= format('Islands-%sBoat', WoWTools_DataMixin.Player.Faction),
    --tooltip= MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP,
    },



}

end


--要塞报告 GarrisonBaseUtils.lua
function WoWTools_MinimapMixin:Garrison_Menu(_, root)
    local sub

--宏伟宝库
    local hasRewar= C_WeeklyRewards.HasAvailableRewards()
    sub=root:CreateButton(
        (hasRewar and '|cnGREEN_FONT_COLOR:' or '')
        ..'|A:gficon-chest-evergreen-greatvault-collect:0:0|a'..(WoWTools_L.RATED_PVP_WEEKLY_VAULT)
        ..(hasRewar and '|A:BonusLoot-Chest:0:0|a' or ''),
    --function()
        --return WeeklyRewardsFrame and WeeklyRewardsFrame:IsShown()
    function()
        WoWTools_LoadUIMixin:WeeklyRewards()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_ChallengeMixin:ActivitiesTooltip(tooltip)--周奖励，提示
    end)


--驭空术
    WoWTools_MenuMixin:OpenDragonriding(root)

    do
        if not GarrisonList then
            Init_GarrisonList()
        end
    end

    for _, info in pairs(GarrisonList) do
        if info.name=='-' then
            root:CreateDivider()

        else
            local has= C_Garrison.HasGarrison(info.garrisonType)
            local num, num2= '', ''
            if has and info.garrFollowerTypeID then
                num= ' '..Get_Garrison_List_Num(info.garrFollowerTypeID)
                if info.garrFollowerTypeID2 then
                    num2= format(' |A:%s:0:0|a%s', info.atlas2 or '',  Get_Garrison_List_Num(info.garrFollowerTypeID2))
                end
            end
            local atlas= type(info.atlas)=='function' and info.atlas() or info.atlas or ''

            sub=root:CreateButton(
                format('|A:%s:0:0|a%s%s%s', atlas, info.name, num, num2),
            --info.check or function(data)
                --return GarrisonLandingPage and GarrisonLandingPage:IsShown() and GarrisonLandingPage.garrTypeID==data.garrisonType
            --end, 
            function(data)
                if data.func then
                    data.func()
                else
                    if GarrisonLandingPage and GarrisonLandingPage:IsShown() and GarrisonLandingPage.garrTypeID==data.garrisonType then
                        GarrisonLandingPage:Hide()
                    else
                        ShowGarrisonLandingPage(data.garrisonType)
                    end
                end
                return MenuResponse.Open
            end, {
                garrisonType= info.garrisonType,
                tooltip= info.tooltip,
                func=info.func
            })


            local disabled
            if info.disabled~=nil then
                disabled= info.disabled
            else
                disabled= not has
            end
            sub:SetEnabled(not disabled and true or false)

--盟约 9.0
            if info.garrisonType== Enum.GarrisonType.Type_9_0_Garrison then
                for covenantID=1, 4 do
                    local info2 = C_Covenants.GetCovenantData(covenantID)
                    local tab = C_CovenantSanctumUI.GetRenownLevels(covenantID)
                    if info2 and info2.name and tab then
                        local level= 0
                        for i=#tab, 1, -1 do
                            if not tab[i].locked then
                                level= tab[i].level
                                break
                            end
                        end

                        sub:CreateButton(
                            (info2.textureKit and format('|A:SanctumUpgrades-%s-32x32:0:0|a', info2.textureKit) or '')
                            ..WoWTools_TextMixin:CN(info2.name)..' '..level,
                        function(data)
                            WoWTools_LoadUIMixin:CovenantRenown(nil, data.covenantID)
                            return MenuResponse.Open
                        end, {covenantID=covenantID})

                    end
                end
            end
        end
    end
end