

WoWTools_DataMixin.WoWGUID={}
WoWTools_DataMixin.PlayerInfo={}
WoWTools_DataMixin.GroupGuid={}













local function Cached_ItemLevel(unit, guid)
    if not canaccessvalue(unit) or not canaccessvalue(guid) then
        return
    end

    unit= unit or (guid and UnitTokenFromGUID(guid))
    guid= guid or (unit and UnitGUID(unit))

    if not unit or not guid then
        return
    end


    --local color= WoWTools_UnitMixin:GetColor(unit, guid)
    --local r,g,b= color:GetRGB()
    --local hex= color:GenerateHexColorMarkup()
    local itemLevel, specID
    local data= WoWTools_DataMixin.PlayerInfo[guid] or {}

    local combatRole= UnitGroupRolesAssigned(unit)-- TANK, HEALER, DAMAGER, NONE
    local faction= UnitFactionGroup(unit)--facción de la unidad, no la del jugador

    combatRole= combatRole~='NONE' and combatRole or nil
    faction= faction~='' and faction or data.faction

    if guid==WoWTools_DataMixin.Player.GUID then
        itemLevel= GetAverageItemLevel()
        specID= PlayerUtil.GetCurrentSpecID()
        WoWToolsPlus_WoWDate[guid].itemLevel= itemLevel
        WoWToolsPlus_WoWDate[guid].specID= specID
        WoWToolsPlus_WoWDate[guid].faction= faction
    else
        itemLevel= C_PaperDollInfo.GetInspectItemLevel(unit)
        itemLevel= itemLevel>0 and itemLevel or data.itemLevel or nil

        specID= GetInspectSpecialization(unit) or 0
        specID= specID>0 and specID or data.specID or nil
    end

    if itemLevel then
        itemLevel= math.floor(itemLevel+ 0.5)
    end

    local info= {
        faction= faction,
        level=UnitLevel(unit),

        itemLevel= itemLevel,
        specID= specID,

        color= WoWTools_UnitMixin:GetColor(unit, guid),
        combatRole= combatRole,
        time= GetTime(),--para no reinspeccionar datos recientes
        --sex= UnitSex(unit),
        --col= hex,
        --r=r,
        --g=g,
        --b=b,
    }

    WoWTools_DataMixin.PlayerInfo[guid] = info
    EventRegistry:TriggerEvent("WoWTools_Cached_ItemLevel", guid, unit, info)
end
















local function GetGroupGuidDate()
    local UnitTab={}
    if not IsInGroup() then
        return
    end

    if IsInRaid() then
        for index= 1, MAX_RAID_MEMBERS do --GetNumGroupMembers() do
            local unit= 'raid'..index
            if WoWTools_UnitMixin:UnitExists(unit) then
                local _, _, subgroup, _, _, _, _, _, _, role, _, combatRole = GetRaidRosterInfo(index)
                table.insert(UnitTab, {
                    name= UnitName(unit),
                    faction= UnitFactionGroup(unit),
                    unit=unit,
                    guid= UnitGUID(unit),
                    combatRole= combatRole or role,
                    subgroup= subgroup
                })
            end
        end

    else
        for index= 1, 4 do
            local unit= 'party'..index
            if WoWTools_UnitMixin:UnitExists(unit) then
                table.insert(UnitTab, {
                    name= UnitName(unit),
                    faction= UnitFactionGroup(unit),
                    unit= unit,
                    guid= UnitGUID(unit),
                    combatRole=UnitGroupRolesAssigned(unit),
                })
            end
        end
    end

    local unitList= {'player'}
    local now= GetTime()
    for _, tab in pairs(UnitTab) do
        if canaccessvalue(tab.name) and tab.name then
            WoWTools_DataMixin.GroupGuid[tab.name]= tab
        end
        if canaccessvalue(tab.guid) and tab.guid then
            WoWTools_DataMixin.GroupGuid[tab.guid]= tab
            --Solo inspeccionar si no hay datos de los últimos 5 min
            local info= WoWTools_DataMixin.PlayerInfo[tab.guid]
            if not (info and info.time and now-info.time<300) then
                table.insert(unitList, tab.unit)
            end
        end
    end

    if not InCombatLockdown() then
        WoWTools_UnitMixin:GetNotifyInspect(unitList)
    end
end
















local function setwowguidTab(info)
    if info and info.characterName then
        local name= WoWTools_UnitMixin:GetFullName(info.characterName)
        if name then
            if info.isOnline and info.wowProjectID==1 then
                WoWTools_DataMixin.WoWGUID[name]={guid=info.playerGuid, faction=info.factionName, level= info.characterLevel}
            else
                WoWTools_DataMixin.WoWGUID[name]=nil
            end
        end
    end
end

local function Get_WoW_GUID_Info(_, friendIndex)
    if friendIndex then
        local accountInfo =C_BattleNet.GetFriendAccountInfo(friendIndex)
        setwowguidTab(accountInfo and accountInfo.gameAccountInfo)
    else
        WoWTools_DataMixin.WoWGUID={}
        for i=1 ,BNGetNumFriends() do
            local accountInfo =C_BattleNet.GetFriendAccountInfo(i);
            setwowguidTab(accountInfo and accountInfo.gameAccountInfo)
        end
    end
end





local function Set_New_Layer(self, unit)
    WoWTools_DataMixin.Player.Layer= select(2, WoWTools_UnitMixin:GetNpcID(unit)) or select(2, WoWTools_UnitMixin:GetNpcID('vehicle'))
    if not WoWTools_DataMixin.Player.Layer then
        self:RegisterEvent('NAME_PLATE_UNIT_ADDED')
    end
end



local frame= CreateFrame('Frame')
FrameUtil.RegisterFrameForEvents(frame, {
    'PLAYER_ENTERING_WORLD',
    'INSPECT_READY',

    'GROUP_LEFT',
    'GROUP_ROSTER_UPDATE',

    'PLAYER_EQUIPMENT_CHANGED',
    'PLAYER_SPECIALIZATION_CHANGED',
    'PLAYER_AVG_ITEM_LEVEL_UPDATE',
    'BARBER_SHOP_RESULT',
    'PLAYER_LEVEL_UP',
    'NEUTRAL_FACTION_SELECT_RESULT',

    'BN_FRIEND_INFO_CHANGED',

    'ZONE_CHANGED_NEW_AREA',

})




frame:SetScript('OnEvent', function(self, event, arg1)
    if event=='PLAYER_ENTERING_WORLD' then
        WoWTools_DataMixin.Player.Week= WoWTools_DataMixin:GetWeek() or WoWTools_DataMixin.Player.Week--por si la sesión cruza el reinicio semanal
        WoWTools_DataMixin.Player.IsMaxLevel= UnitLevel('player')>=GetMaxLevelForLatestExpansion()--recalcular (Timerunning, cambios de expansión)
        C_Timer.After(2, function()
            GetGroupGuidDate()
            WoWTools_UnitMixin:GetNotifyInspect(nil, 'player')
            Set_New_Layer(self, 'party1')
            Get_WoW_GUID_Info()
        end)

    elseif event=='ZONE_CHANGED_NEW_AREA' then
        Set_New_Layer(self, 'party1')

    elseif event=='GROUP_LEFT' or event=='GROUP_ROSTER_UPDATE' then
        --GROUP_ROSTER_UPDATE es muy frecuente en banda: agrupar en un único timer
        if self.rosterTimer then
            self.rosterTimer:Cancel()
            self.rosterTimer= nil
        end
        if event=='GROUP_LEFT' then
            GetGroupGuidDate()
        else
            self.rosterTimer= C_Timer.NewTimer(2, function()
                self.rosterTimer= nil
                GetGroupGuidDate()
            end)
        end

    elseif event=='BARBER_SHOP_RESULT' then
        local success= arg1
        if success then
            WoWTools_DataMixin.Player.Sex= UnitSex("player")
            WoWTools_DataMixin.Icon.Player= WoWTools_UnitMixin:GetRaceIcon('player') or ''
        end

    elseif event=='PLAYER_LEVEL_UP' then
        local level= arg1
        level= level or UnitLevel('player')
        WoWTools_DataMixin.Player.IsMaxLevel= level==GetMaxLevelForLatestExpansion()
        WoWTools_DataMixin.Player.Level= level
        WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].level= level

    elseif event=='NEUTRAL_FACTION_SELECT_RESULT' then
        local success= arg1
        if success then
            WoWTools_DataMixin.Player.Faction= UnitFactionGroup('player')
        end

    elseif event=='PLAYER_EQUIPMENT_CHANGED'
        or event=='PLAYER_SPECIALIZATION_CHANGED'
        or event=='PLAYER_AVG_ITEM_LEVEL_UPDATE'
    then
        WoWTools_UnitMixin:GetNotifyInspect(nil, 'player')


    elseif event=='BN_FRIEND_INFO_CHANGED' then
        local friendIndex= arg1
        Get_WoW_GUID_Info(_, friendIndex)

    elseif event=='INSPECT_READY' then
        local guid= arg1

        local unit= canaccessvalue(guid) and guid and UnitTokenFromGUID(guid)
        if unit then
            Cached_ItemLevel(unit, guid)
            if  GameTooltip.textLeft and GameTooltip:IsShown() then
                local name2, unit2, guid2= GameTooltip:GetUnit()
                --local name2, unit2, guid2= TooltipUtil.GetDisplayedUnit(GameTooltip)
                if canaccessvalue(guid2) and guid2==guid then
                    WoWTools_TooltipMixin:Set_Unit_Player(GameTooltip, name2, unit2, guid2)
                end
            end
        end

    elseif event=='NAME_PLATE_UNIT_ADDED' then
        if canaccessvalue(arg1) then
            Set_New_Layer(self, arg1)
        end
        if WoWTools_DataMixin.Player.Layer then
            self:UnregisterEvent(event)
        end
    end
end)
