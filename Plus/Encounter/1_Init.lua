local function Init_Encounter()
    WoWTools_EncounterMixin:Init_Menu()
    WoWTools_EncounterMixin:Init_Plus()
    WoWTools_EncounterMixin:Init_ListInstances()
    WoWTools_EncounterMixin:Init_JourneysList()
    WoWTools_EncounterMixin:Init_JourneysPlus()


    C_Timer.After(0.3, function()
        if WoWTools_EncounterMixin:Save().EncounterJournalTier and not InCombatLockdown() then
            local max= EJ_GetNumTiers()
            if max then
                local tier= math.min(WoWTools_EncounterMixin:Save().EncounterJournalTier, max)
                EJ_SelectTier(tier)
            end
        end

        WoWTools_DataMixin:Hook('EJ_SelectTier', function(tier)
            WoWTools_EncounterMixin:Save().EncounterJournalTier= WoWTools_EncounterMixin:Save().isSaveTier and tier or nil
        end)
    end)
end


local function Init()
    WoWTools_EncounterMixin:Init_LootSpec()

    WoWTools_DataMixin:Hook(EncounterJournalPinMixin, 'OnMouseEnter', function(frame)
        local encounterID= frame.tooltipTitle and frame.encounterID and select(7, EJ_GetEncounterInfo(frame.encounterID))
        if not encounterID then
            return
        end

        local numKill= encounterID and WoWToolsPlusPlayerDate['BossKilled'][encounterID] or 0
        if numKill>0 then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(
                WoWTools_DataMixin.Icon.icon2
                ..format(WoWTools_L.REAGENT_COST_CONSUME_CHARGES,
                    WoWTools_L.DUNGEON_ENCOUNTER_DEFEATED,
                    numKill)
            )
        end

        local data= not WoWTools_EncounterMixin:Save().hideLootSpec and WoWToolsPlusPlayerDate['LootSpec'][encounterID]
        local lootSpecID= data and data.class[WoWTools_DataMixin.Player.Class]
        local loot
        if lootSpecID then
            local _, name, _, icon, role = GetSpecializationInfoByID(lootSpecID)
            if name then
                if numKill==0 then
                    GameTooltip:AddLine(' ')
                end
                GameTooltip:AddLine(
                    WoWTools_DataMixin.Icon.icon2
                    ..(WoWTools_L.SELECT_LOOT_SPECIALIZATION)
                    ..': |cffffffff'
                    ..'|T'..(icon or 0)..':0|t'
                    ..(WoWTools_DataMixin.Icon[role] or '')
                    ..WoWTools_TextMixin:CN(name)
                )
                loot= true
            end
        end

        if numKill>0 or loot then
            GameTooltip:Show()
        end
    end)
end


--Arreglos de los ajustes guardados: antes se hacían siempre al cargar (también con el módulo desactivado)
local Init_Save= WoWTools_Once(function()
    WoWToolsPlusPlayerDate['BossKilled']= WoWToolsPlusPlayerDate['BossKilled'] or {}

    WoWTools_EncounterMixin:Save().favorites[WoWTools_DataMixin.Player.GUID]= WoWTools_EncounterMixin:Save().favorites[WoWTools_DataMixin.Player.GUID] or {}

    WoWTools_EncounterMixin:Save().JourneysList= WoWTools_EncounterMixin:Save().JourneysList or {disabled= WoWTools_EncounterMixin:Save().hideJourneysList, noExpansion={}, showName={}}
    WoWTools_EncounterMixin:Save().JourneysList.noExpansion= WoWTools_EncounterMixin:Save().JourneysList.noExpansion or {}
    WoWTools_EncounterMixin:Save().JourneysList.showName= WoWTools_EncounterMixin:Save().JourneysList.showName or {}

    WoWTools_EncounterMixin:Save().plus= not WoWTools_EncounterMixin:Save().hideEncounterJournal
    WoWTools_EncounterMixin:Save().hideEncounterJournal= nil
end)


local function Init_BossKill()
    EventRegistry:RegisterFrameEventAndCallback("BOSS_KILL", function(_, ncounterID, encounterName)
        if not ncounterID then
            return
        end
        local num= (WoWToolsPlusPlayerDate['BossKilled'][ncounterID] or 0)+ 1
        WoWToolsPlusPlayerDate['BossKilled'][ncounterID]= num
        if WoWTools_EncounterMixin:Save().plus then
            WoWTools_Print(
                WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnWARNING_FONT_COLOR:'..(WoWTools_TextMixin:CN(encounterName) or ncounterID)..'|r',
                format(WoWTools_L.REAGENT_COST_CONSUME_CHARGES,
                    WoWTools_L.DUNGEON_ENCOUNTER_DEFEATED,
                    num)
            )
        end
    end)
end




WoWTools_Module:Register({
    key= 'Adventure_Journal',
    name= 'Module.Adventure Guide',
    icon= 'UI-HUD-MicroMenu-AdventureGuide-Mouseover',
    group= 'World',
    defaults= {
        favorites={},
        LootSpec= {},
        --JourneysList: lo crea Init_Save (su valor por defecto depende de hideJourneysList)
    },
    tooltip= 'Tip.Encounter.Module',
    mixin= WoWTools_EncounterMixin,
    onLoad= function()--el contador de jefes muertos funciona también con el módulo desactivado
        Init_Save()
        Init_BossKill()
    end,
    onEnable= function()
        Init_Save()
        Init()
    end,
    blizzard= {Blizzard_EncounterJournal= Init_Encounter},
})

