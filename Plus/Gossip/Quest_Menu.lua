
local function Save()
    return WoWToolsPlusSave['Plus_Gossip']
end









local function Init_Menu(self, root)
    local sub, sub2, num

--启用
    sub=root:CreateCheckbox(
        (WoWTools_L.ENABLE)
        ..'|A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest:0:0|a',
    function()
        return Save().quest
    end, function()
       self:set_enable()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('Alt+'..(WoWTools_L['BOOSTED_CHAR_SPELL_TEMPLOCK+DISABLE']))
    end)

--低等级任务
    sub2=sub:CreateCheckbox(
        '|A:TrivialQuests:0:0|a'..(WoWTools_L.MINIMAP_TRACKING_TRIVIAL_QUESTS),--低等任务
    function()
        return WoWTools_MapMixin:Get_Minimap_Tracking(MINIMAP_TRACKING_TRIVIAL_QUESTS, false)
    end, function()
        WoWTools_MapMixin:Get_Minimap_Tracking(MINIMAP_TRACKING_TRIVIAL_QUESTS, true)
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(WoWTools_L.TRACKING))
    end)

--自动:选择奖励
    root:CreateDivider()
    num= CountTable(Save().questRewardCheck or {})
    sub=root:CreateCheckbox(
        WoWTools_L['Auto choose reward']
        ..(num==0 and ' |cff626262' or ' ')
        ..num,
    function()
        return Save().autoSelectReward
    end, function()
        Save().autoSelectReward= not Save().autoSelectReward and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_L['Highest quality'])
        tooltip:AddLine(WoWTools_L.GARRISON_MISSION_RARE)
        tooltip:AddLine('|cff0000ff'..(WoWTools_L.GARRISON_MISSION_RARE)..'|r')
    end)

--子目录，自动:选择奖励
    for questID, index in pairs(Save().questRewardCheck) do
       WoWTools_DataMixin:Load(questID, 'quest')
        sub2=sub:CreateCheckbox(
            WoWTools_QuestMixin:GetName(questID)..' |cnGREEN_FONT_COLOR:'..index,
        function(data)
            return Save().questRewardCheck[data.questID]
        end, function(data)
            Save().questRewardCheck[data.questID]= not Save().questRewardCheck[data.questID] and data.index or nil
        end, {questID=questID, index=index})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end
    if num>1 then
        sub:CreateDivider()
--全部清除
        WoWTools_MenuMixin:ClearAll(sub, function()
            Save().questRewardCheck={}
        end)
        WoWTools_MenuMixin:SetScrollMode(sub)
    end


--自定义任务
    num= CountTable(Save().questOption or {})
    
    sub=root:CreateButton(
        '     '..(WoWTools_L['CUSTOM+QUESTS_LABEL'])
        ..(num==0 and ' |cff626262' or ' ')
        ..num,
    function()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_L['Auto select'])
    end)


--子目录，自定义任务
    for questID, text in pairs(Save().questOption) do
        WoWTools_DataMixin:Load(questID, 'quest')
        sub2=sub:CreateCheckbox(
            WoWTools_QuestMixin:GetName(questID),
        function(data)
            return Save().questOption[data.questID]
        end, function(data)
            Save().questOption[data.questID]= not Save().questOption[data.questID] and data.text or nil
        end, {questID=questID, text=text})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end

    if num>1 then
        sub:CreateDivider()
--全部清除
        WoWTools_MenuMixin:ClearAll(sub, function()
            Save().questOption={}
        end)
        WoWTools_MenuMixin:SetScrollMode(sub)
    end



--共享任务
    root:CreateDivider()
    sub=root:CreateCheckbox(
        (IsInGroup() and '' or '|cff626262')
        ..(WoWTools_L.SHARE_QUEST)
        ..'|A:groupfinder-waitdot:0:0|a',
    function()
        return Save().pushable
    end, function()
        Save().pushable= not Save().pushable and true or nil
        self:set_Event()--设置事件
        self:set_PushableQuest()--共享,任务
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(
            WoWTools_L['Only in a party']
        )
    end)

--数量
    sub=root:CreateCheckbox(
        (WoWTools_L.AUCTION_HOUSE_QUANTITY_LABEL),
    function()
        return Save().showAllQuestNum
    end, function()
        Save().showAllQuestNum= not Save().showAllQuestNum and true or nil
        self:set_Quest_Num_Text()
        self:set_Event()--设置事件
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(
            WoWTools_L['SHOW+ALL']
        )
        tooltip:AddLine(
            WoWTools_L['Disabled in instances|nQuests >0']
        )
    end)

--文本转语音
    WoWTools_GossipMixin:Init_QuestPlayTextMenu(self, root)



--追踪
    root:CreateDivider()
    root:CreateTitle(WoWTools_L.TRACKING)

--自动任务追踪
    sub=root:CreateCheckbox(
        (WoWTools_L.AUTO_QUEST_WATCH_TEXT),
    function()
        return C_CVar.GetCVarBool("autoQuestWatch")
    end, function()
        if not InCombatLockdown() then
            C_CVar.SetCVar("autoQuestWatch", C_CVar.GetCVarBool("autoQuestWatch") and '0' or '1')
        end
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine('CVar|cffffffff autoQuestWatch')
    end)
    sub:SetEnabled(not InCombatLockdown())


--当前地图
    root:CreateCheckbox(
        WoWTools_L['REFORGE_CURRENT+WORLD_MAP'],
    function()
        return Save().autoSortQuest
    end, function()
        Save().autoSortQuest= not Save().autoSortQuest and true or nil
        self:set_Event()--仅显示本地图任务,事件
        self:set_Only_Show_Zone_Quest()--显示本区域任务
    end)


end
















function WoWTools_GossipMixin:Init_Menu_Quest(...)
    Init_Menu(...)
end