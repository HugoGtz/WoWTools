local function Save()
    return WoWToolsPlusSave['Adventure_Journal']
end

local function SaveUse()
    return WoWToolsPlusPlayerDate['LootSpec']
end




local function Init_Menu(self, root)
    local encounterID = self:IsMouseOver() and self:GetParent().encounterID
    if not encounterID then
        return
    end

    local sub, sub2
    local bossName, _, _, _, _, _, dungeonEncounterID= EJ_GetEncounterInfo(encounterID)
    if not dungeonEncounterID then
        return
    end

    local curID= PlayerUtil.GetCurrentSpecID() or 0
    local sex= self.classFile== WoWTools_DataMixin.Player.Class and WoWTools_DataMixin.Player.Sex or nil
    local color= WoWTools_UnitMixin:GetColor(nil, nil, self.classFile)

    local hex= color:GenerateHexColorMarkup()

    for specIndex= 1, C_SpecializationInfo.GetNumSpecializationsForClassID(self.classID) or 0 do
        local specID, name, desc, icon, role= GetSpecializationInfoForClassID(self.classID, specIndex, sex)
        if icon and specID and name then

            sub=root:CreateRadio(
                '|T'..(icon or 0)..':0|t'
                ..(WoWTools_DataMixin.Icon[role] or '')
                ..hex
                ..WoWTools_TextMixin:CN(name)
                ..(curID==specID and '|A:auctionhouse-icon-favorite:0:0|a' or '')
                ..' '..specID,
            function(data)
                    return SaveUse()[dungeonEncounterID] and SaveUse()[dungeonEncounterID].class[self.classFile]==data.specID

            end, function(data)
                SaveUse()[dungeonEncounterID]= SaveUse()[dungeonEncounterID] or {
                    class={},
                    encounterID= encounterID,
                    index= self.index,
                }
                if SaveUse()[dungeonEncounterID].class[self.classFile]==data.specID then
                    SaveUse()[dungeonEncounterID].class[self.classFile]= nil
                else
                    SaveUse()[dungeonEncounterID].class[self.classFile]= data.specID
                end
                self:settings()
                return MenuResponse.Refresh
            end, {specID=specID, desc=desc})

            sub:SetTooltip(function(tooltip, desc2)
                WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Encounter.LootSpecRadio'])
                tooltip:AddLine(WoWTools_TextMixin:CN(desc2.data.desc), nil, nil, nil, true)
            end, {specID= specID, })
        end
    end


    root:CreateDivider()
    local classTab={}
    local classNum=0
    if SaveUse()[dungeonEncounterID] then
        classNum= CountTable(SaveUse()[dungeonEncounterID].class or {})
        classTab= SaveUse()[dungeonEncounterID].class
    end

    bossName= WoWTools_TextMixin:CN(bossName) or dungeonEncounterID
    sub=root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..bossName,
        --..' #'..classNum,
    function()
        StaticPopup_Show('WoWTools_OK',
            bossName
            ..'|n'..(self:GetParent().link or encounterID)
            ..'|n|n|A:bags-button-autosort-up:0:0|a|cnWARNING_FONT_COLOR:'
            ..(WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2),
            nil,
            {SetValue=function()
                SaveUse()[dungeonEncounterID]= nil
                WoWTools_DataMixin:Call('EncounterJournal_Refresh')
            end}
        )
    end, {rightText=classNum})
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Encounter.LootSpecClearBoss'])
        GameTooltip_AddErrorLine(tooltip, WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2)
    end)

    for className, specID in pairs(classTab) do
        local _, name, desc, icon, role = GetSpecializationInfoByID(specID)
        local color2= WoWTools_UnitMixin:GetColor(nil, nil, className)

        sub2=sub:CreateCheckbox(
            color2:GenerateHexColorMarkup()
            ..(WoWTools_UnitMixin:GetClassIcon(nil, nil, className) or '')
            ..'|T'..(icon or 0)..':0|t'
            ..(WoWTools_DataMixin.Icon[role] or '')
            ..(WoWTools_TextMixin:CN(name) or specID),
        function(d)
            return SaveUse()[dungeonEncounterID] and SaveUse()[dungeonEncounterID].class[d.className]
        end, function(d)
            if not SaveUse()[dungeonEncounterID].class[d.className] then
                SaveUse()[dungeonEncounterID].class[d.className]= d.specID
            else
                SaveUse()[dungeonEncounterID].class[d.className]= nil
            end
            WoWTools_DataMixin:Call('EncounterJournal_Refresh')
        end, {className=className, specID=specID, desc=desc})
        sub2:SetTooltip(function(tooltip, d)
            tooltip:AddLine(d.data.desc)
        end)
    end

    WoWTools_MenuMixin:SetRightText(sub)


    local classSpecTab={}
    for id, data in pairs(SaveUse()) do
        local specID= data.class[self.classFile]
        if specID then
            local boss, _, _, _, _, instanceID= EJ_GetEncounterInfo(data.encounterID)
            local insName= instanceID and WoWTools_TextMixin:CN(EJ_GetInstanceInfo(instanceID)) or ''

            table.insert(classSpecTab, {
                dungeonEncounterID= id,
                specID= specID,
                instanceID= instanceID or 0,
                insName= insName,
                bossName= boss,
                bossIcon=  select(5, EJ_GetCreatureInfo(1, data.encounterID)),

                class= data.class,
                encounterID= data.encounterID,
                index= data.index or 0
            })

        end
    end

    local classIcon= hex
        ..(WoWTools_UnitMixin:GetClassIcon(nil, nil, self.classFile) or '')
        ..(WoWTools_TextMixin:CN(self.className) or self.classFile)
    sub=root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..classIcon,
        --..' #'..#classSpecTab,
    function()
        StaticPopup_Show('WoWTools_OK',
            classIcon
            ..'|n|n|A:bags-button-autosort-up:0:0|a|cnWARNING_FONT_COLOR:'
            ..(WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2),
            nil,
            {SetValue=function()
                for id in pairs(SaveUse()) do
                    SaveUse()[id].class[self.classFile]=nil
                end
                WoWTools_DataMixin:Call('EncounterJournal_Refresh')
            end}
        )
    end, {rightText=#classSpecTab})
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Encounter.LootSpecClearClass'])
        GameTooltip_AddErrorLine(tooltip, WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2)
    end)


    table.sort(classSpecTab, function(a,b)
        if a.instanceID==b.instanceID then
            return a.index< b.index
        else
            return a.instanceID> b.instanceID
        end
    end)

    local pInstanceID
    for _, data in pairs(classSpecTab) do
        local col2= EncounterJournal.instanceID==data.instanceID and '|cff00ccff'
        if pInstanceID~=data.instanceID then
            sub:CreateTitle((col2 or '')..(data.insName or ' '))
            pInstanceID= data.instanceID
        end

        sub2= sub:CreateCheckbox(
            (col2 or '|cffff00ff')..data.index..'|r'
            ..'|T'..(select(4, GetSpecializationInfoByID(data.specID)) or 0)..':0|t'
            ..'|T'..(data.bossIcon or "Interface\\EncounterJournal\\UI-EJ-BOSS-Default")..':0|t'
            ..(WoWTools_TextMixin:CN(data.bossName) or data.encounterID),
        function(d)
                return SaveUse()[d.dungeonEncounterID] and SaveUse()[d.dungeonEncounterID].class[self.classFile]
        end, function(d)
            SaveUse()[d.dungeonEncounterID].class[self.classFile]= not SaveUse()[d.dungeonEncounterID].class[self.classFile] and d.specID or nil
            if EncounterJournal.instanceID~= d.instanceID then
                WoWTools_DataMixin:Call('EncounterJournal_DisplayInstance', d.instanceID)
            end
            if (EncounterJournal.encounterID ~= d.encounterID) then
                WoWTools_DataMixin:Call('EncounterJournal_DisplayEncounter', d.encounterID)
            end

            WoWTools_DataMixin:Call('EncounterJournal_Refresh')
        end, data)

        sub2:SetTooltip(function(tooltip, desc)
            tooltip:AddLine('encounterID|n|cffffffff'..desc.data.dungeonEncounterID)
            if desc.data.bossIcon then
                	local textureSettings = {
                        width = 128,
                        height = 64,
                    };
                tooltip:AddTexture(desc.data.bossIcon, textureSettings)
            end
        end)
    end

    WoWTools_MenuMixin:SetRightText(sub)
    WoWTools_MenuMixin:SetScrollMode(sub)


    root:CreateDivider()
    sub=root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_L.CLEAR_ALL),
    function()
       StaticPopup_Show('WoWTools_OK',
        WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2
        ..'|n|n|A:bags-button-autosort-up:0:0|a|cnWARNING_FONT_COLOR:'
        ..(WoWTools_L.CLEAR_ALL),
        nil,
        {SetValue=function()
            WoWToolsPlusPlayerDate['LootSpec']={}
            WoWTools_DataMixin:Call('EncounterJournal_Refresh')
        end})
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Encounter.LootSpecClearAll'])
        GameTooltip_AddErrorLine(tooltip, WoWTools_L.ALL)
    end)
end


local function Init_Button(btn)
    btn.specButtons={}
    local isOnlyClass= Save().lootOnlyClass

    local index= 0
    local level= btn:GetFrameLevel()+5
    for class= 1, GetNumClasses() do
        local classInfo = C_CreatureInfo.GetClassInfo(class) or {}
        local isCurClass= classInfo.classFile==WoWTools_DataMixin.Player.Class

        if classInfo.classFile and (isCurClass or not isOnlyClass) then
            local s= 16
            btn.specButtons[classInfo.classID]= CreateFrame('DropdownButton', nil, btn, 'WoWToolsMenu2Template')

            local b= btn.specButtons[classInfo.classID]
            b:SetSize(s,s)
            b:SetFrameLevel(level)

            local x= index +1
            if isCurClass then
                x=0
            else
                index= index+1
            end
            b:SetPoint('BOTTOMRIGHT', (-x*(s+2))-5, -8)
            b.texture2= b:CreateTexture(nil, 'BACKGROUND', nil, -1)
            b.texture2:SetPoint('TOPLEFT', b, -1, 1)
            b.texture2:SetPoint('BOTTOMRIGHT', b, 1, -2)
            b.texture2:SetAtlas('groupfinder-icon-class-color-'..classInfo.classFile)
--tooltip
            local color= WoWTools_UnitMixin:GetColor(nil, nil, classInfo.classFile)

            b.tooltip= (WoWTools_L.SELECT_LOOT_SPECIALIZATION)
                    ..color:GenerateHexColorMarkup()
                    ..(WoWTools_UnitMixin:GetClassIcon(nil, nil, classInfo.classFile) or '')
                    ..(WoWTools_TextMixin:CN(classInfo.className) or classInfo.classFile)
            b.classID= classInfo.classID
            b.classFile= classInfo.classFile
            b.className= classInfo.className
--settings
            function b:settings()
                local encounterID= self:GetParent().encounterID
                local  dungeonEncounterID= select(7, EJ_GetEncounterInfo(encounterID))

                local data= SaveUse()[dungeonEncounterID]
                local lootSpecID= data and data.class[self.classFile]

                local icon= lootSpecID and select(4, GetSpecializationInfoByID(lootSpecID))

                if icon then
                    self.texture:SetTexture(icon)
                else
                    self.texture:SetAtlas(WoWTools_UnitMixin:GetClassIcon(nil, nil, self.classFile, {reAtlas=true}) or '')
                end

                self:SetAlpha(icon and 1 or 0.3)
                self.texture2:SetShown(icon)
            end

            b:SetupMenu(Init_Menu)
        end
    end
end


local function Set_LootSpec(self, encounterID)
    local data= SaveUse()[encounterID]
    local lootSpecID= data and data.class[WoWTools_DataMixin.Player.Class]
    local logID

    if lootSpecID then
        local prevLoot= GetLootSpecialization() or 0
        local curID= PlayerUtil.GetCurrentSpecID()

        local loot= prevLoot==0 and curID or prevLoot

        if loot>0 and loot~= lootSpecID then
            logID= prevLoot--guardar el valor previo (0 = especialización actual) para restaurarlo tal cual

            SetLootSpecialization(lootSpecID)

            local _, name, _, icon, role = GetSpecializationInfoByID(lootSpecID)
            if name then
               WoWTools_Print(
                    WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    '|cnGREEN_FONT_COLOR:'..(WoWTools_L.SETTINGS)..'|r',
                    (WoWTools_L.SELECT_LOOT_SPECIALIZATION)
                    ..(icon and '|T'..(icon or '')..':0|t' or '')
                    ..(WoWTools_DataMixin.Icon[role] or '')
                    ..(name and '|cffff00ff'..WoWTools_TextMixin:CN(name) or '')
                )
            end
        end
    end

    self.spceLog= logID
end

local function Rest_LootSpec(self)
    if not self.spceLog  then
        return
    end
    local loot= GetLootSpecialization() or 0
    if loot~= self.spceLog then
        SetLootSpecialization(self.spceLog)

        local specID= self.spceLog==0 and PlayerUtil.GetCurrentSpecID() or self.spceLog
        local _, name, _, icon, role = GetSpecializationInfoByID(specID or 0)

        if name then
            WoWTools_Print(
                WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnWARNING_FONT_COLOR:'..(WoWTools_L['RESET~2'])..'|r',
                (WoWTools_L.SELECT_LOOT_SPECIALIZATION)
                ..(icon and '|T'..(icon or 0)..':0|t' or '')
                ..(WoWTools_DataMixin.Icon[role] or '')
                ..(name and '|cffff00ff'..WoWTools_TextMixin:CN(name) or '')
            )
        end
    end
    self.spceLog= nil
end


local DisabledShowBoossTabs={
    [2870]=1,
    [2869]=1,
}
local function Init_Loot()
    WoWTools_DataMixin:Hook(EncounterBossButtonMixin, 'Init', function(self, data)--{data={bossID index link rootSectionID, desctiption, name} }
        if not self.specButtons then
            Init_Button(self)
        end

        local scale= Save().lootScale or 1
        local show= not Save().hideLootSpec and not DisabledShowBoossTabs[data.bossID]

        for _, btn in pairs(self.specButtons) do
            if show then
                btn:settings()
                btn:SetScale(scale)
                btn.index= data.index
            end
            btn:SetShown(show)
        end
    end)

    Init_Loot=function()end
end


local function Init()
    WoWToolsPlusPlayerDate['LootSpec']= WoWToolsPlusPlayerDate['LootSpec'] or {}


    if Save().hideLootSpec then
        return
    end


    local frame= CreateFrame('Frame', 'WoWToolsEJLootFrame')

    function frame:set_event()
        self:UnregisterAllEvents()
        if not Save().hideLootSpec then
            self:RegisterEvent('ENCOUNTER_START')
            self:RegisterEvent('ENCOUNTER_END')
        end
    end
    frame:set_event()

    frame:SetScript('OnEvent', function(self, event, encounterID)
        if event=='ENCOUNTER_START' and encounterID then
            Set_LootSpec(self, encounterID)

        elseif event=='ENCOUNTER_END' then
            Rest_LootSpec(self)
        end
    end)


    WoWTools_DataMixin:Hook(EncounterJournalPinMixin, 'OnLoad', function(self)
        self.lootTexture= self:CreateTexture(nil, 'OVERLAY')
        self.lootTexture:SetSize(20,20)
        self.lootTexture:SetPoint('BOTTOMLEFT', 3, 3)
        WoWTools_ButtonMixin:AddMask(self, true, self.lootTexture)
    end)

    WoWTools_DataMixin:Hook(EncounterJournalPinMixin, 'Refresh', function(self)
        local icon
        local encounterID= self.encounterID and select(7, EJ_GetEncounterInfo(self.encounterID))
        if not Save().hideLootSpec and encounterID and SaveUse()[encounterID] then
            local lootSpecID=  SaveUse()[encounterID].class[WoWTools_DataMixin.Player.Class]
            if lootSpecID then
                icon= select(4, GetSpecializationInfoByID(lootSpecID))
            end
        end
        self.lootTexture:SetTexture(icon or 0)
    end)

    if C_AddOns.IsAddOnLoaded('Blizzard_EncounterJournal') then
        Init_Loot()
    else
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_EncounterJournal' then
                Init_Loot()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
    end



    Init=function()
        _G['WoWToolsEJLootFrame']:set_event()
    end
end




function WoWTools_EncounterMixin:Init_LootSpec()
    Init()
end
