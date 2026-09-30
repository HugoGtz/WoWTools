local function Save()
    return WoWToolsPlusSave['Adventure_Journal'] or {}
end


local function Init_Encounter()--冒险指南界面
    WoWTools_EncounterMixin:Init_Menu()
    WoWTools_EncounterMixin:Init_Plus()
    WoWTools_EncounterMixin:Init_ListInstances()--界面, 副本击杀
   -- WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
    WoWTools_EncounterMixin:Init_JourneysList()--12.0才有
    WoWTools_EncounterMixin:Init_JourneysPlus()


--记录上次选择版本
    C_Timer.After(0.3, function()
        if Save().EncounterJournalTier and not InCombatLockdown() then--记录上次选择TAB
            local max= EJ_GetNumTiers()
            if max then
                local tier= math.min(Save().EncounterJournalTier, max)
                EJ_SelectTier(tier)
            end
        end

        WoWTools_DataMixin:Hook('EJ_SelectTier', function(tier)
            Save().EncounterJournalTier= Save().isSaveTier and tier or nil
        end)
    end)

    Init_Encounter=function()end
end


local function Init()
    WoWTools_EncounterMixin:Init_LootSpec()--BOSS战时, 指定拾取, 专精

--击杀次数，拾取专精，提示,
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

        local data= not Save().hideLootSpec and WoWToolsPlusPlayerDate['LootSpec'][encounterID]
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

    Init=function()end
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Adventure_Journal']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Adventure_Journal'], {
                favorites={},--副本收藏 WoWTools_DataMixin.Player.GUID= {}
                LootSpec= {},--拾取专精
                JourneysList= {
                    disabled= Save().hideJourneysList,
                    noExpansion={},
                    showName={},
                },
            })

            WoWToolsPlusPlayerDate['BossKilled']= WoWToolsPlusPlayerDate['BossKilled'] or {}

            Save().favorites[WoWTools_DataMixin.Player.GUID]= Save().favorites[WoWTools_DataMixin.Player.GUID] or {}

            Save().JourneysList= Save().JourneysList or {noExpansion={}, showName={}}
            Save().JourneysList.noExpansion= Save().JourneysList.noExpansion or {}
            Save().JourneysList.showName= Save().JourneysList.showName or {}

            Save().plus= not Save().hideEncounterJournal
            Save().hideEncounterJournal= nil


            WoWTools_EncounterMixin.addName= '|A:UI-HUD-MicroMenu-AdventureGuide-Mouseover:0:0|a'..(WoWTools_L['Module.Adventure Guide'])

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_EncounterMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    WoWTools_Print(
                        WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_L.REQUIRES_RELOAD
                    )
                end,
                tooltip= WoWTools_L['Tip.Encounter.Module']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
            })

--为了保存击杀数据，保持这个开启
            EventRegistry:RegisterFrameEventAndCallback("BOSS_KILL", function(_, ncounterID, encounterName)
                if not ncounterID then
                    return
                end
                local num= (WoWToolsPlusPlayerDate['BossKilled'][ncounterID] or 0)+ 1
                WoWToolsPlusPlayerDate['BossKilled'][ncounterID]= num--Boss击杀数量
                if Save().plus then
                    WoWTools_Print(
                        WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        '|cnWARNING_FONT_COLOR:'..(WoWTools_TextMixin:CN(encounterName) or ncounterID)..'|r',
                        format(WoWTools_L.REAGENT_COST_CONSUME_CHARGES,
                            WoWTools_L.DUNGEON_ENCOUNTER_DEFEATED,
                            num)
                    )
                end
            end)

            if Save().disabled then
                self:UnregisterEvent(event)
                self:SetScript('OnEvent', nil)
            else


                Init()

                if C_AddOns.IsAddOnLoaded('Blizzard_EncounterJournal') then
                    Init_Encounter()--冒险指南界面
                    self:UnregisterEvent(event)
                    self:SetScript('OnEvent', nil)
                end
            end

        elseif arg1=='Blizzard_EncounterJournal' and WoWToolsPlusSave then---冒险指南
            Init_Encounter()--冒险指南界面
            self:UnregisterEvent(event)
            self:SetScript('OnEvent', nil)
        end
    end
end)