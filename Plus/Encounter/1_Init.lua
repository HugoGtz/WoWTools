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




--Opciones del Centro de control (docs/SETTINGS.md): los mismos campos que el menú de la Guía de aventuras
local function EJ_Call(func)
    if EncounterJournal and EncounterJournal:IsShown() then
        WoWTools_DataMixin:Call(func)
    end
end

local function JourneysList(M)
    if M.started and EncounterJournal then
        M:Init_JourneysList()
        M:JourneysList_Settings()
    end
end

local function List_Disabled(save)
    return save.JourneysList.disabled
end

--Una casilla por expansión (lista de la fila "Nombre" u "Ocultar" del menú de renombre)
local function Expansion_Checks(options, field, tooltip)
    for expansionID= WoWTools_DataMixin.ExpansionLevel or 0, 9, -1 do
        table.insert(options, {type='check', key='JourneysList.'..field..expansionID, indent=true, tooltip=tooltip,
            text= function() return WoWTools_DataMixin:GetExpansionText(expansionID) or tostring(expansionID) end,
            disabled= List_Disabled,
            get= function(save) return save.JourneysList[field][expansionID] and true or false end,
            set= function(save, value) save.JourneysList[field][expansionID]= value and true or nil end,
            apply= JourneysList,
        })
    end
end

local function Get_Options()
    local options= {
        {type='section', text='GENERAL'},
        {type='check', key='plus', text='Plus', tooltip='Tip.Encounter.Plus', reload=true,
            get= function(save) return save.plus and true or false end,
            set= function(save, value) save.plus= value and true or nil end,
        },
        {type='check', key='hideJourneys', text='JOURNEYS_LABEL', tooltip='Tip.Encounter.Journeys', reload=true,
            get= function(save) return not save.hideJourneys end,
            set= function(save, value) save.hideJourneys= not value and true or nil end,
        },
        {type='check', key='hideInsList', text='Instance listings', tooltip='Tip.Encounter.InstanceList', reload=true,
            get= function(save) return not save.hideInsList end,
            set= function(save, value) save.hideInsList= not value and true or nil end,
            apply= function(M)
                if M.started and EncounterJournal then
                    M:Init_ListInstances()
                end
            end,
        },
        {type='check', key='hideLootSpec', text='SELECT_LOOT_SPECIALIZATION', tooltip='Tip.Encounter.LootSpec', reload=true,
            get= function(save) return not save.hideLootSpec end,
            set= function(save, value) save.hideLootSpec= not value and true or nil end,
            apply= function(M)
                if M.started then
                    M:Init_LootSpec()
                    EJ_Call('EncounterJournal_Refresh')
                end
            end,
        },
        {type='check', key='lootOnlyClass', text='Only my class', tooltip='Tip.Encounter.LootOnlyClass', reload=true, indent=true,
            disabled= function(save) return save.hideLootSpec end,
            get= function(save) return save.lootOnlyClass and true or false end,
            set= function(save, value) save.lootOnlyClass= value and true or nil end,
        },
        {type='check', key='isSaveTier', text='Remember expansion', tooltip='Tip.Encounter.SaveTier',
            get= function(save) return save.isSaveTier and true or false end,
            set= function(save, value)
                save.isSaveTier= value and true or false
                save.EncounterJournalTier= value and EJ_GetCurrentTier and EJ_GetCurrentTier() or nil
            end,
        },

        {type='section', text='Renown list'},
        {type='check', key='JourneysList.disabled', text='Renown list', tooltip='Tip.Encounter.RenownList',
            get= function(save) return not save.JourneysList.disabled end,
            set= function(save, value) save.JourneysList.disabled= not value and true or nil end,
            apply= JourneysList,
        },
        {type='slider', key='JourneysList.scale', text='HOUSING_EXPERT_DECOR_SUBMODE_SCALE', tooltip='Tip.Menu.Scale', indent=true,
            min=0.4, max=4, step=0.1, format='%.1f', disabled=List_Disabled,
            get= function(save) return save.JourneysList.scale or 1 end,
            set= function(save, value) save.JourneysList.scale= value end,
            apply= JourneysList,
        },
        {type='slider', key='JourneysList.bgAlpha', text='BACKGROUND+HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', tooltip='Tip.Menu.BgAlpha', indent=true,
            min=0, max=1, step=0.1, format='%.1f', disabled=List_Disabled,
            get= function(save) return save.JourneysList.bgAlpha or 0.5 end,
            set= function(save, value) save.JourneysList.bgAlpha= value end,
            apply= JourneysList,
        },
        {type='note', text='Tip.Encounter.RenownShowName', indent=true, hidden=List_Disabled},
    }
    Expansion_Checks(options, 'showName', 'Tip.Encounter.RenownShowName')
    table.insert(options, {type='note', text='Tip.Encounter.RenownHideExpansion', indent=true, hidden=List_Disabled})
    Expansion_Checks(options, 'noExpansion', 'Tip.Encounter.RenownHideExpansion')

    for _, opt in ipairs({
        {type='section', text='Appearance'},
        {type='slider', key='insListScale', text=function() return WoWTools_L['Instance listings']..': '..WoWTools_L.HOUSING_EXPERT_DECOR_SUBMODE_SCALE end,
            tooltip='Tip.Encounter.InsListScale', min=0.4, max=4, step=0.1, format='%.1f',
            disabled= function(save) return save.hideInsList end,
            get= function(save) return save.insListScale or 1 end,
            set= function(save, value) save.insListScale= value end,
            apply= function() EJ_Call('EncounterJournal_ListInstances') end,
        },
        {type='slider', key='lootScale', text=function() return WoWTools_L.SELECT_LOOT_SPECIALIZATION..': '..WoWTools_L.HOUSING_EXPERT_DECOR_SUBMODE_SCALE end,
            tooltip='Tip.Encounter.LootScale', min=0.4, max=4, step=0.1, format='%.1f',
            disabled= function(save) return save.hideLootSpec end,
            get= function(save) return save.lootScale or 1 end,
            set= function(save, value) save.lootScale= value end,
            apply= function() EJ_Call('EncounterJournal_Refresh') end,
        },

        {type='section', text='Advanced'},
        {type='button', key='favorites', text='Clear favorites', buttonText='CLEAR_ALL', tooltip='Tip.Encounter.FavoriteClear', confirm=true,
            func= function(_, save)
                save.favorites= {}
                EJ_Call('EncounterJournal_ListInstances')
            end,
        },
    }) do
        table.insert(options, opt)
    end
    return options
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
    options= function() return Get_Options() end,
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

