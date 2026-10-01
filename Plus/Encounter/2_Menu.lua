
local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub, sub2

    sub= root:CreateCheckbox(
        WoWTools_L.JOURNEYS_LABEL,
    function()
        return not WoWTools_EncounterMixin:Save().hideJourneys
    end, function()
        WoWTools_EncounterMixin:Save().hideJourneys= not WoWTools_EncounterMixin:Save().hideJourneys and true or nil
         WoWTools_EncounterMixin:Init_JourneysList()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Encounter.Journeys'])
        tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
    end)

    sub=root:CreateCheckbox(
        WoWTools_L['Renown list'],
    function()
        return not WoWTools_EncounterMixin:Save().JourneysList.disabled
    end, function()
        WoWTools_EncounterMixin:Save().JourneysList.disabled= not WoWTools_EncounterMixin:Save().JourneysList.disabled and true or nil
        WoWTools_EncounterMixin:Init_JourneysList()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Encounter.RenownList'])
        tooltip:AddLine(WoWTools_L.JOURNEYS_LABEL)
    end)


--Plus
    sub=root:CreateCheckbox(
        'Plus',
    function()
        return WoWTools_EncounterMixin:Save().plus
    end, function()
        WoWTools_EncounterMixin:Save().plus= not WoWTools_EncounterMixin:Save().plus and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Encounter.Plus'])
        tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
    end)
    sub=root:CreateCheckbox(
        WoWTools_L['Instance listings'],
    function()
        return not WoWTools_EncounterMixin:Save().hideInsList
    end, function()
        WoWTools_EncounterMixin:Save().hideInsList= not WoWTools_EncounterMixin:Save().hideInsList and true or nil
        WoWTools_EncounterMixin:Init_ListInstances()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Encounter.InstanceList'])
        tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
    end)

    sub:CreateSpacer()
    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return WoWTools_EncounterMixin:Save().insListScale or 1
    end, function(value)
        WoWTools_EncounterMixin:Save().insListScale= value
        WoWTools_DataMixin:Call('EncounterJournal_ListInstances')
    end, function()
        WoWTools_EncounterMixin:Save().insListScale= nil
        WoWTools_DataMixin:Call('EncounterJournal_ListInstances')
    end)


    sub=root:CreateCheckbox(
        WoWTools_L.SELECT_LOOT_SPECIALIZATION,
    function()
        return not WoWTools_EncounterMixin:Save().hideLootSpec
    end, function()
        WoWTools_EncounterMixin:Save().hideLootSpec= not WoWTools_EncounterMixin:Save().hideLootSpec and true or nil
        WoWTools_EncounterMixin:Init_LootSpec()
        WoWTools_DataMixin:Call('EncounterJournal_Refresh')
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Encounter.LootSpec'])
        tooltip:AddLine('ENCOUNTER_START')
        tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
    end)


    sub2=sub:CreateCheckbox(
        format(WoWTools_L.LFG_LIST_CROSS_FACTION,
            (WoWTools_UnitMixin:GetClassIcon(nil, nil, self.classFile) or '')
            ..WoWTools_ColorMixin:SetStringColor(
                WoWTools_DataMixin.onlyChinese and WoWTools_DataMixin.ClassName_CN[WoWTools_DataMixin.Player.Class] or UnitClass('player')
            )
        ),
    function()
        return WoWTools_EncounterMixin:Save().lootOnlyClass
    end, function()
        WoWTools_EncounterMixin:Save().lootOnlyClass= not WoWTools_EncounterMixin:Save().lootOnlyClass and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Encounter.LootOnlyClass'])
        tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
    end)

    sub:CreateSpacer()
    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return WoWTools_EncounterMixin:Save().lootScale or 1
    end, function(value)
        WoWTools_EncounterMixin:Save().lootScale= value
        WoWTools_DataMixin:Call('EncounterJournal_Refresh')
    end, function()
        WoWTools_EncounterMixin:Save().lootScale= nil
        WoWTools_DataMixin:Call('EncounterJournal_Refresh')
    end)


    root:CreateDivider()
    local tier= WoWTools_EncounterMixin:Save().EncounterJournalTier or EJ_GetCurrentTier() or 1
    local tierName= EJ_GetTierInfo(tier)
    sub=root:CreateCheckbox(
        WoWTools_TextMixin:CN(tierName) or 'EJ Tier',
    function()
        return WoWTools_EncounterMixin:Save().isSaveTier
    end, function()
        WoWTools_EncounterMixin:Save().isSaveTier= not WoWTools_EncounterMixin:Save().isSaveTier and true or false
        WoWTools_EncounterMixin:Save().EncounterJournalTier= WoWTools_EncounterMixin:Save().isSaveTier and EJ_GetCurrentTier() or nil
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Encounter.SaveTier'])
        tooltip:AddLine(WoWTools_L.EDIT_TICKET)
        tooltip:AddLine(' ')
        tooltip:AddLine('EJ Tier|cffffffff '..tier)
        tooltip:AddLine(WoWTools_L['Only on reload'])
    end)


    root:CreateDivider()
    
    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_EncounterMixin.addName})
    WoWTools_MenuMixin:Reload(sub)

end


local function Init()
    local menu= CreateFrame('DropdownButton', 'WoWToolsAdventureJournalMenuButton', EncounterJournalCloseButton, 'WoWToolsMenuTemplate')
    menu:SetPoint('RIGHT', EncounterJournalCloseButton, 'LEFT')
    menu:SetupMenu(Init_Menu)


    local great= EncounterJournalInstanceSelect.GreatVaultButton
    great:ClearAllPoints()
    great:SetPoint('RIGHT', menu, 'LEFT', -4, 0)
    great:SetFrameStrata(menu:GetFrameStrata())
    great:SetFrameLevel(menu:GetFrameLevel())
    great:SetSize(23,23)
    great:SetParent(EncounterJournalCloseButton)
    local icon= great:GetNormalTexture()
    if icon then
        icon:ClearAllPoints()
        icon:SetPoint('TOPLEFT', -2, 2)
        icon:SetPoint('BOTTOMRIGHT', 2, -2)
    end

    local key =WoWTools_ButtonMixin:Cbtn(menu, {size=22})
    key:SetPoint('RIGHT', great, 'LEFT', -4, 0)
    key.texture= key:CreateTexture(nil,'BORDER')
    key.texture:SetPoint('TOPLEFT', 2, -2)
    key.texture:SetPoint('BOTTOMRIGHT', -2, 2)
    key.texture:SetTexture('Interface\\EncounterJournal\\UI-EJ-PortraitIcon')--4352494)
    key:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        local find= WoWTools_ChallengeMixin:ActivitiesTooltip()
        local link= WoWToolsPlus_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone.link
        if link then
            GameTooltip:AddLine(WoWTools_HyperLink:CN_Link(link, {isName=true}))
        end

        if find or link then
            GameTooltip:AddLine(' ')
        end

        GameTooltip:AddLine(
            (WoWTools_L.MYTHIC_DUNGEONS)
            ..WoWTools_DataMixin.Icon.left
        )

        GameTooltip:Show()
    end)
    key:SetScript("OnLeave",GameTooltip_Hide)
    key:SetScript('OnMouseDown', function()
        PVEFrame_ToggleFrame('ChallengesFrame', 3)
    end)
    --WoWTools_TextureMixin:SetButton(key)


    local com= CreateFrame('Button', 'WoWToolsEJPlayerCompanionMenuButton', menu, 'WoWToolsButtonTemplate')
    com.texture= com:CreateTexture()
    com.texture:SetAllPoints()
    com:SetPoint('RIGHT', key, 'LEFT', -4, 0)
    function com:tooltip(tooltip)
        local find
        for companionID=1, 20 do
            local traitTreeID = C_DelvesUI.GetTraitTreeForCompanion(companionID)
            if traitTreeID and traitTreeID>0 then
                if WoWTools_FactionMixin:GetCompanionInfo(companionID, tooltip) then
                    find=true
                end

            else
                break
            end
        end
        if find then
            GameTooltip:AddLine(' ')
        end
        GameTooltip:AddDoubleLine(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
    end

    function com:Get_CompanionID()
        local factionID= C_DelvesUI.GetDelvesFactionForSeason()-- or 2272
        if factionID then
            local major= C_MajorFactions.GetMajorFactionData(factionID)
            if major then
                return major.playerCompanionID
            end
        end
    end

    function com:setting()
        local companionID= self:Get_CompanionID() or 1
        local traitTreeID = C_DelvesUI.GetTraitTreeForCompanion(companionID)
        local configID= traitTreeID and C_Traits.GetConfigIDByTreeID(traitTreeID)
        SetPortraitTextureFromCreatureDisplayID(self.texture, C_DelvesUI.GetCreatureDisplayInfoForCompanion(companionID))
        self.texture:SetDesaturated(InCombatLockdown() or not configID)
    end

    com:SetScript('OnClick', function(self, d)
        self:setting()
        if d=='LeftButton' then
            WoWTools_LoadUIMixin:OpenCompanion()
            return
        end
        MenuUtil.CreateContextMenu(self, function(_, root)
            local enabled= not InCombatLockdown()
            for companionID=1, 20 do
                local traitTreeID = C_DelvesUI.GetTraitTreeForCompanion(companionID)
                if traitTreeID and traitTreeID>0 then
                    local info= WoWTools_FactionMixin:GetCompanionInfo(companionID)
                    if info then
                        local sub=root:CreateButton(
                            (info.configID and enabled  and '' or DISABLED_FONT_COLOR:GenerateHexColorMarkup())
                            ..info.compaionName
                            ..(info.compaionLevel and ' '..info.compaionLevel or ''),
                        function(data)
                            WoWTools_LoadUIMixin:OpenCompanion(data.companionID)
                            return MenuResponse.Open
                        end, {
                            companionID=companionID,
                            factionID= info.factionID,
                        })
                        sub:AddInitializer(function(button, desc)
                            local icon = button:AttachTexture()
                            icon:SetSize(23, 23)
                            icon:SetPoint("RIGHT")
                            SetPortraitTextureFromCreatureDisplayID(icon, C_DelvesUI.GetCreatureDisplayInfoForCompanion(desc.data.companionID))
                        end)
                        WoWTools_SetTooltipMixin:FactionMenu(sub)
                    end

                else
                    break
                end
            end
        end)
    end)

    com:HookScript('OnShow', function(self)
        self:setting()
    end)


    Init=function()end
end

function WoWTools_EncounterMixin:Init_Menu()
    Init()
end


