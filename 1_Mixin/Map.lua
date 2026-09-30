
WoWTools_MapMixin={}

--local _x, _y, _z, mapID = UnitPosition("player");
function WoWTools_MapMixin:GetPosition()
    return UnitPosition("player")
end


--InstanceDifficulty.lua
function WoWTools_MapMixin:IsInDelve()
    local mapID= select(4, self:GetPosition())
    return mapID and C_DelvesUI.HasActiveDelve(mapID)
end


function WoWTools_MapMixin:Get_Minimap_Tracking(checkName, isSettings)
    for trackingID=1, C_Minimap.GetNumTrackingTypes() do
        local info= C_Minimap.GetTrackingInfo(trackingID)
        if info and info.name== checkName then
            local active= info.active
            if isSettings then
                active= not info.active and true or false
                C_Minimap.SetTracking(trackingID, active)
            end
            return active
        end
    end
end


function WoWTools_MapMixin:GetUnit(unit)
    local text
    local uiMapID= C_Map.GetBestMapForUnit(unit)
    if unit=='player' and select(2, IsInInstance())~='none' then
        local name, _, _, difficultyName= GetInstanceInfo()
        if name then
            text= name .. ((difficultyName and difficultyName~='') and '('..difficultyName..')' or '')
        else
            text=GetMinimapZoneText()
        end
    elseif uiMapID then
        local info = C_Map.GetMapInfo(uiMapID)
        if info and info.name then
            text=info.name
        end
    end
    return text, uiMapID
end


function WoWTools_MapMixin:IsInPvPArea()
    return C_PvP.IsArena()
        or C_PvP.IsBattleground()
        or C_PvP.IsSoloShuffle()
        or C_PvP.IsInBrawl()
        or C_PvP.IsPVPMap()
end
--PVPMatchUtil.lua




local DifficultyType={
    [1]='normal',--DifficultyUtil.ID.DungeonNormal
    [2]='heroic',--DifficultyUtil.ID.DungeonHeroic
    [3]='classic',--DifficultyUtil.ID.Raid10Normal
    [4]='classic',--DifficultyUtil.ID.Raid25Normal
    [5]='classic',--DifficultyUtil.ID.Raid10Heroic
    [6]='classic',--DifficultyUtil.ID.Raid25Heroic
    [7]='random',--DifficultyUtil.ID.RaidLFR
    [8]='challenge',--DifficultyUtil.ID.DungeonChallenge Mythic Keystone
    [9]='classic',--DifficultyUtil.ID.Raid40 40 Player

    [11]='heroic',
    [12]='normal',

    [14]='normal',
    [15]='heroic',
    [16]='mythic',
    [17]='random',

    [19]='normal',
    [20]='normal',
    [23]='mythic',--DifficultyUtil.ID.DungeonMythic
    [24]='timewalking',--DifficultyUtil.ID.DungeonTimewalker
    [25]='PvP',--World PvP Scenario	scenario
    [29]='pvp',--PvEvP Scenario	pvp	
    [30]='normal',--Event	scenario	
    [32]='PvP',--World PvP Scenario	scenario	
    [33]='timewalking',--DifficultyUtil.ID.RaidTimewalker	Timewalking	raid	
    [34]='PvP',--PvP pvp	
    [38]='normal',--Normal	scenario	
    [39]='heroic',--Heroic	scenario	displayHeroic
    [40]='mythic',--Mythic	scenario	displayMythic
    [45]='PvP',--PvP	scenario	displayHeroic
    [147]='normal',--Normal	scenario	Warfronts
    [149]='heroic',--Heroic	scenario	displayHeroic Warfronts
    [150]='normal',--Normal	party	
    [151]='timewalking',--Looking For Raid	raid	Timewalking
    [152]='normal',--Visions of N'Zoth	scenario	
    [153]='heroic',--Teeming Island	scenario	displayHeroic
    [167]='normal',--Torghast	scenario	
    [168]='normal',--Path of Ascension: Courage	scenario	
    [169]='normal',--Path of Ascension: Loyalty	scenario	
    [170]='normal',--Path of Ascension: Wisdom	scenario	
    [171]='normal',--Path of Ascension: Humility	scenario
    [205]='follower',
    [208]='delve',
    [220]='story',--DifficultyUtil.ID.RaidStory
    [230]='heroic',
}

local DifficultyColor= {}
EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
    DifficultyColor= {
        ['classic']= {name= WoWTools_L.LAYOUT_STYLE_CLASSIC, r=0.62, g=0.62, b=0.62},-- hex='|cff9d9d9d'
        ['scenario']= {name= WoWTools_L['SCENARIOS~2'], r=0.78, g=1, b=0.79},-- hex='|cffc6ffc9',
        ['random']= {name= WoWTools_L.LFG_TYPE_RANDOM_DUNGEON, r=0.12, g=1, b=0},--hex='|cff1eff00',
        ['normal']= {name= WoWTools_L.PLAYER_DIFFICULTY1, r=1, g=1, b=1},-- hex='|cffffffff',
        ['heroic']= {name= WoWTools_L.PLAYER_DIFFICULTY2, r=0, g=0.44, b=0.87},--hex='|cff0070dd', 
        ['mythic']= {name= WoWTools_L.PLAYER_DIFFICULTY6, r=1, g=0, b=1},--hex='|cffff00ff',
        ['challenge']= {name= WoWTools_L.PLAYER_DIFFICULTY5, r=1, g=0.51, b=0},--hex='|cffff8200', 
        ['timewalking']= {name= WoWTools_L['PLAYER_DIFFICULTY_TIMEWALKER~2'], r=0, g=1, b=1},--hex='|cff00ffff', 
        ['PvP']= {name= 'PvP', r=1, g=0, b=0},--hex='|cffff4800',
        ['follower']= {name= WoWTools_L.LFG_TYPE_FOLLOWER_DUNGEON, r=0.69, g=1, b=0, a=1},--hex='|cffb1ff00', 
        ['delve']= {name= WoWTools_L.DELVES_LABEL, r=0.93, g=0.82, b=0, a=1},--hex='|cffedd100', 
        ['story']={name= WoWTools_L.PLAYER_DIFFICULTY_STORY_RAID, r=0.67, g=1.00, b=0.67}--hex='|cffaaffaa',
    }
    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)

function WoWTools_MapMixin:GetDifficultyColor(difficultyName, difficultyID)--DifficultyUtil.lua
    local color, name
    if difficultyID and difficultyID>0 then
        name= DifficultyType[difficultyID]
        if name then
            local tab= DifficultyColor[name]
            if tab then
                difficultyName= tab.name
                if IsLegacyDifficulty(difficultyID) then
                    local id= NormalizeLegacyDifficultyID(difficultyID)
                    if id== DifficultyUtil.ID.Raid10Normal then
                        difficultyName= WoWTools_Join(difficultyName, '10')
                    elseif id==DifficultyUtil.ID.Raid25Normal then
                        difficultyName= WoWTools_Join(difficultyName, '25')
                    end

                    color= DISABLED_FONT_COLOR
                else
                    color= CreateColor(tab.r, tab.g, tab.b)
                end
            end
        end
    end

    if not difficultyName then
        difficultyName= difficultyID and GetDifficultyInfo(difficultyID) or difficultyName or ''
        difficultyName= WoWTools_TextMixin:CN(difficultyName)
    end

    color= color or PlayerUtil.GetClassColor()
    difficultyName= color:WrapTextInColorCode(difficultyName )

    return difficultyName, color
end


