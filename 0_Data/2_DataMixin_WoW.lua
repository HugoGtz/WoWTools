


local function Update_Challenge_Mode()
    local all, weekNum, weekLevel
    local score=C_ChallengeMode.GetOverallDungeonScore()
    if score and score>0 then
        all= #C_MythicPlus.GetRunHistory(true, true)
        local info = C_MythicPlus.GetRunHistory(false, true)
        if info and #info>0 then
            weekNum=#info
            local activities= C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Activities)
            if activities then
                local lv=0
                for _,v in pairs(activities) do
                    if v and v.level then
                        if v.level and v.level >lv then
                            lv=v.level;
                        end
                    end
                end
                if lv > 0 then
                    weekLevel=lv
                end
            end
        end
    end

    WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone={
        score= score,
        all= all,
        week= WoWTools_DataMixin.Player.Week,
        weekNum= weekNum,
        weekLevel= weekLevel,

        weekPvE= WoWTools_ChallengeMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.Raid),--Raid
        weekMythicPlus= WoWTools_ChallengeMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.Activities),--MythicPlus
        weekPvP= WoWTools_ChallengeMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.RankedPvP),--RankedPvP
        weekWorld=WoWTools_ChallengeMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.World),--world
        link= WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone.link,
        --itemLevel= C_MythicPlus.GetOwnedKeystoneLevel(),
    }
end

EventRegistry:RegisterFrameEventAndCallback("CHALLENGE_MODE_MAPS_UPDATE", function()
    C_MythicPlus.RequestRewards()
    C_Timer.After(4, Update_Challenge_Mode)
end)
EventRegistry:RegisterFrameEventAndCallback("WEEKLY_REWARDS_UPDATE", function()
    C_MythicPlus.RequestRewards()
    C_Timer.After(4, Update_Challenge_Mode)
end)


local function Get_Info_Challenge()
    C_MythicPlus.RequestCurrentAffixes()
    C_MythicPlus.RequestMapInfo()
    C_MythicPlus.RequestRewards()
    for _, mapChallengeModeID in pairs(C_ChallengeMode.GetMapTable() or {}) do
        WoWTools_DataMixin:Load(mapChallengeModeID, 'challengeMap')
    end
end

EventRegistry:RegisterFrameEventAndCallback("CHALLENGE_MODE_COMPLETED", function()
    Get_Info_Challenge()
end)


EventRegistry:RegisterFrameEventAndCallback("BAG_UPDATE_DELAYED", function()
    local guid= WoWTools_DataMixin.Player.GUID
    WoWToolsPlus_WoWDate[guid].Keystone.link=nil
    WoWToolsPlus_WoWDate[guid].Item={}
    for bagID= Enum.BagIndex.Backpack,  NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do
        for slotID=1, C_Container.GetContainerNumSlots(bagID) do
            local itemID = C_Container.GetContainerItemID(bagID, slotID)
            if itemID then

                if C_Item.IsItemKeystoneByID(itemID) then
                    WoWToolsPlus_WoWDate[guid].Keystone.link= C_Container.GetContainerItemLink(bagID, slotID)
                elseif not WoWToolsPlus_WoWDate[guid].Item[itemID] then--una sola consulta por objeto (no por hueco)
                    local bag=C_Item.GetItemCount(itemID)
                    WoWToolsPlus_WoWDate[guid].Item[itemID]={
                        bag=bag,
                        bank=C_Item.GetItemCount(itemID, true, false, true)-bag,
                    }
                end
            end
        end
    end
end)


EventRegistry:RegisterFrameEventAndCallback("CURRENCY_DISPLAY_UPDATE", function(_, arg1)
    if arg1 and arg1~=2032 then
        if not C_CurrencyInfo.IsAccountWideCurrency(arg1) then
            local info = C_CurrencyInfo.GetCurrencyInfo(arg1)
            if info and info.quantity then
                WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Currency[arg1]= info.quantity~=0 and info.quantity or nil
            end
        end
    else
        for i=1, C_CurrencyInfo.GetCurrencyListSize() do
            local link =C_CurrencyInfo.GetCurrencyListLink(i)
            local currencyID = link and C_CurrencyInfo.GetCurrencyIDFromLink(link)

            local info = C_CurrencyInfo.GetCurrencyListInfo(i)
            if currencyID and info and info.quantity and currencyID~=2032 and not C_CurrencyInfo.IsAccountWideCurrency(currencyID) then
                WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Currency[currencyID]= info.quantity~=0 and info.quantity or nil
            end
        end
    end
end)


--##
--##
local function Set_Money()
    WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Money= GetMoney() or 0
end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_MONEY", function()
    Set_Money()
end)


EventRegistry:RegisterFrameEventAndCallback("TIME_PLAYED_MSG", function(_, arg1, arg2)
    if arg1 and arg2 then
        WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Time={
            totalTime= arg1,
            levelTime= arg2,
            upData= date('%Y-%m-%d %H:%M:%S'),
        }
    end
end)


EventRegistry:RegisterFrameEventAndCallback("UPDATE_INSTANCE_INFO", function()--encounterID, encounterName)
    local tab={}
    for i=1, GetNumSavedWorldBosses() do
        local bossName, worldBossID, reset=GetSavedWorldBossInfo(i)
        if bossName and (not reset or reset>0) then
            tab[bossName] = worldBossID
            if WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Rare.boss[bossName] then
                WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Rare.boss[bossName]=nil
            end
        end
    end

    WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Worldboss={
        week=WoWTools_DataMixin.Player.Week,
        day= date('%x'),
        boss=tab
    }

    tab={}
    for i=1, GetNumSavedInstances() do
        local name, _, reset, difficulty, _, _, _, _, _, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
        if name and reset and reset>0 and numEncounters and encounterProgress and numEncounters>0 and encounterProgress>0 and difficultyName then

            local killed = encounterProgress ..'/'..numEncounters;
            killed = encounterProgress ==numEncounters and '|cnGREEN_FONT_COLOR:'..killed..'|r' or killed
            difficultyName=WoWTools_MapMixin:GetDifficultyColor(difficultyName, difficulty)

            tab[name] = tab[name] or {}

            tab[name][difficultyName]=killed
        end
    end
    WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Instance = {
        week=WoWTools_DataMixin.Player.Week,
        day=date('%x'),
        ins=tab
    }
end)



EventRegistry:RegisterFrameEventAndCallback("LOOT_OPENED", function()
    if select(2, IsInInstance())~='none' then
        return
    end
    local classification = UnitClassification('target')
    if classification == "rare" or classification == "rareelite" then
        local name=WoWTools_TextMixin:CN(UnitName('target'), {unit='target', isName=true})
        if name then
            WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Rare.boss[name]= UnitGUID('target')
        end
    end
end)


EventRegistry:RegisterFrameEventAndCallback("BOSS_KILL", function()
    RequestRaidInfo()
end)


--Crea las SavedVariables (y migra las del WoWTools original). Idempotente: la llama también
--z_Panel.lua por si su ADDON_LOADED llega antes que este (instalación limpia).
local IsSavedInit
function WoWTools_DataMixin:Init_SavedVariables()
    if IsSavedInit then
        return
    end
    IsSavedInit= true

    --Migración: las primeras versiones del fork guardaban con los nombres del WoWTools original.
    --Si el original está cargado, esos globales son suyos y no se tocan.
    if not C_AddOns.IsAddOnLoaded('WoWTools') then
        if WoWToolsPlusSave==nil then WoWToolsPlusSave= WoWToolsSave end
        if WoWToolsPlus_WoWDate==nil then WoWToolsPlus_WoWDate= WoWTools_WoWDate end
        if WoWToolsPlusPlayerDate==nil then WoWToolsPlusPlayerDate= WoWToolsPlayerDate end
        WoWToolsSave, WoWTools_WoWDate, WoWToolsPlayerDate= nil, nil, nil
    end

    WoWToolsPlusSave= WoWToolsPlusSave or {}

    WoWToolsPlus_WoWDate= WoWToolsPlus_WoWDate or {}

    WoWToolsPlusPlayerDate= WoWToolsPlusPlayerDate or {}
end

EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
    if arg1~='WoWToolsPlus' then
        return
    end

    WoWTools_DataMixin:Init_SavedVariables()

    WoWTools_DataMixin.Icon.Player= WoWTools_UnitMixin:GetRaceIcon('player')

    WoWTools_DataMixin.Player.GUID= UnitGUID('player')

    WoWTools_DataMixin.Player.Week= WoWTools_DataMixin:GetWeek() or WoWTools_DataMixin.Player.Week

    local day= date('%x')
    local guid= WoWTools_DataMixin.Player.GUID
    if guid and not WoWToolsPlus_WoWDate[guid] then
        WoWToolsPlus_WoWDate[guid]= {
            Item={},
            Currency={},

            Keystone={week=WoWTools_DataMixin.Player.Week},

            Instance={ins={}, week=WoWTools_DataMixin.Player.Week, day=day},
            Worldboss={boss={}, week=WoWTools_DataMixin.Player.Week, day=day},
            Rare={day=day, boss={}},
            Time={},
            Guild={
                data={},-- {guildName, guildRankName, guildRankIndex, realm} = GetGuildInfo('player')
            },
            Bank={},
            region= WoWTools_DataMixin.Player.Region
            --faction
            --level
            --battleTag
        }
    end

    WoWToolsPlus_WoWDate[guid].Bank= WoWToolsPlus_WoWDate[guid].Bank or {}

    WoWToolsPlus_WoWDate[guid].Guild= WoWToolsPlus_WoWDate[guid].Guild or {data={}}

    WoWToolsPlus_WoWDate[guid].region= WoWTools_DataMixin.Player.Region
    WoWToolsPlus_WoWDate[guid].faction= WoWTools_DataMixin.Player.Faction
    WoWToolsPlus_WoWDate[guid].level= WoWTools_DataMixin.Player.Level

    if not WoWTools_DataMixin.Player.BattleTag and WoWToolsPlus_WoWDate[guid].battleTag then
        WoWTools_DataMixin.Player.BattleTag= WoWToolsPlus_WoWDate[guid].battleTag
    else
        WoWToolsPlus_WoWDate[guid].battleTag= WoWTools_DataMixin.Player.BattleTag-- or WoWToolsPlus_WoWDate[guid].battleTag
    end

    local isTimerunning= PlayerIsTimerunning()
    for guid2, tab in pairs(WoWToolsPlus_WoWDate) do

        GetPlayerInfoByGUID(guid2)

        if tab.Keystone.week ~=WoWTools_DataMixin.Player.Week then
            WoWToolsPlus_WoWDate[guid2].Keystone={week=WoWTools_DataMixin.Player.Week}
        end
        if tab.Instance.week~=WoWTools_DataMixin.Player.Week or (isTimerunning and tab.Keystone.day and tab.Keystone.day~=day) then
            WoWToolsPlus_WoWDate[guid2].Instance={ins={}, day=day}
        end
        if (tab.Worldboss.week~=WoWTools_DataMixin.Player.Week) or (isTimerunning and tab.Keystone.day and tab.Keystone.day~=day) then
            WoWToolsPlus_WoWDate[guid2].Worldboss={boss={}, day=day}
        end

        if tab.Rare.day~=day then
            WoWToolsPlus_WoWDate[guid2].Rare={day=day,boss={}}
        end
    end



    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)


local function Save_WoWGuild()
    if IsInGuild() then
        local clubID= C_Club.GetGuildClubId()

        if clubID then
            WoWTools_GuildMixin:Load_Club(clubID)
        end

        local club= clubID and C_ClubFinder.GetRecruitingClubInfoFromClubID(clubID) or {}
        local guildName, guildRankName, guildRankIndex, realm= GetGuildInfo('player')

        realm= (realm=='' or not realm) and WoWTools_DataMixin.Player.Realm or realm
        local old= WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Guild
        if guildName and guildName~=old.data[1] then
            old={}
        end

        WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Guild= {
            guid= club.clubFinderGUID or old.guid,
            link= WoWTools_GuildMixin:GetClubLink(clubID, club.clubFinderGUID) or old.link,
            --clubID= clubID or old.clubID,
            data={guildName, guildRankName, guildRankIndex, realm},
            text= old.text,
            --tabardData=C_GuildInfo.GetGuildTabardInfo('player'),-- or old.tabardData,
            --emblemFilename = select(10, GetGuildLogoInfo()) or old.emblemFilename
        }
    else
        WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Guild= {data={}}
    end
end

EventRegistry:RegisterFrameEventAndCallback('PLAYER_GUILD_UPDATE', function()
    C_Timer.After(2, Save_WoWGuild)
end)
EventRegistry:RegisterFrameEventAndCallback('GUILD_RENAME_REQUIRED', function()
    C_Timer.After(2, Save_WoWGuild)
end)
EventRegistry:RegisterFrameEventAndCallback('LOADING_SCREEN_DISABLED', function(owner)
    C_Timer.After(2, Save_WoWGuild)
    EventRegistry:UnregisterCallback('LOADING_SCREEN_DISABLED', owner)
end)


EventRegistry:RegisterFrameEventAndCallback('PLAYER_ENTERING_WORLD', function(owner)
    if not WoWTools_DataMixin.Icon.Player then
        WoWTools_DataMixin.Icon.Player= WoWTools_UnitMixin:GetRaceIcon('player')
    end

    if  WoWTools_DataMixin.Player.IsMaxLevel then
        Get_Info_Challenge()
    end

    --C_MajorFactions.RequestCatchUpState()
    C_FriendList.ShowFriends()

    --C_PerksProgram.RequestPendingChestRewards()
    if not C_CurrencyInfo.IsAccountCharacterCurrencyDataReady() then
        C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()
    end

    RequestRaidInfo()

    --C_Calendar.OpenCalendar()


    --Update_Bag_Items()
    Set_Money()
    Update_Challenge_Mode()



    EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
end)

