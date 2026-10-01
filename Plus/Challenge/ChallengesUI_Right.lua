local Frame


local function Set_Text()
    local w= 0


    Frame.history:SetText(
        (WoWTools_L.HISTORY)
        ..' |cff00ff00'..#C_MythicPlus.GetRunHistory(true)
        ..'|r/'..#C_MythicPlus.GetRunHistory(true, true)
    )
    w= Frame.history:GetStringWidth()


    local completed, all= 0,0
    local tabs={}
    for _, tab in pairs(C_MythicPlus.GetRunHistory(false, true) or {}) do
        local mapID= tab.mapChallengeModeID
        if tab and tab.level and mapID and mapID>0 and tab.thisWeek then
            if not tabs[mapID] then
                tabs[mapID]={
                    LV={},--{level, completed}
                    runScore= 0,
                    c=0,
                    t=0,
                    completed=false,
                    mapID= mapID,
                }
            end

            tabs[mapID].runScore= (tab.runScore and tab.runScore> tabs[mapID].runScore) and tab.runScore or tabs[mapID].runScore

            table.insert(tabs[mapID].LV, {
                level=tab.level,
                text=tab.completed and '|cff00ff00'..tab.level..'|r' or '|cff828282'..tab.level..'|r'})

            if tab.completed then
                completed= completed+1
                tabs[mapID].c= tabs[mapID].c +1
            end
            tabs[mapID].t=tabs[mapID].t+1
            all= all+1
        end
    end

    local newTab={}
    for _, tab in pairs(tabs) do
        table.insert(newTab, tab)
    end
    table.sort(newTab, function(a, b)  return a.runScore> b.runScore end)


    local weekText
    for _, tab in pairs(newTab) do
        local name, _, _, texture = C_ChallengeMode.GetMapUIInfo(tab.mapID)
        if name then
            weekText= weekText and weekText..'|n' or ''
            local bestOverAllScore = select(2, C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(tab.mapID)) or 0
            local score= WoWTools_ChallengeMixin:KeystoneScorsoColor(bestOverAllScore, nil, true)

            weekText= weekText..(texture and '|T'..texture..':0|t' or '')
                    ..(tab.c>0 and '|cff00ff00' or '|cff828282')..tab.c..'|r/'..tab.t
                    ..' '..score..' '..name--(col and col:WrapTextInColorCode(name) or name)
            table.sort(tab.LV, function(a, b) return a.level> b.level end)
            for _,v2 in pairs(tab.LV) do
                weekText= weekText..' '..v2.text
            end
        end
    end

    Frame.week:SetText(
        (WoWTools_L.CHALLENGE_MODE_THIS_WEEK)
        ..' |cff00ff00'..completed..'|r/'..all--.. ' '..(WoWTools_ChallengeMixin:GetRewardText(1) or '')
        ..(weekText and '|n'..weekText or '')
    )

    w= math.max(Frame.week:GetStringWidth(), w)

    Frame.loot:SetText(
        WoWTools_L['Difficulty Loot Weekly']
    )
    w= math.max(Frame.loot:GetStringWidth(), w)
    w= math.max(Frame.week:GetStringWidth(), w)

    local curLevel=0
    local curKey= C_MythicPlus.GetOwnedKeystoneLevel() or 0

    for _, info in pairs(C_MythicPlus.GetRunHistory(false, true) or {}) do
        if info.completed and info.level and info.level>curLevel then
            curLevel= info.level
        end
    end

    curLevel= math.max(curLevel, curKey)

    Frame.loot.curLevel= curLevel
    Frame.loot.curKey= curKey

    local min, max= WoWTools_DataMixin:GetChallengesWeekItemLevel(nil, true)
    local minNum= math.max(min, curLevel-3)
    local maxNum = math.min(curLevel+4, max)

    local lootText
    for level=minNum, maxNum do
        local text= Frame.loot:get_Loot_itemLevel(level)
        if text then
            lootText= lootText and lootText..'|n'..text or text
        end
    end
    Frame.loot2:SetText(lootText or '')
    w= math.max(Frame.loot2:GetStringWidth(), w)


    local last= WoWTools_LabelMixin:ItemCurrencyTips({
        frame=Frame,
        point={'TOPLEFT', Frame.loot2, 'BOTTOMLEFT',0, -12},
        showAll=true,
        showName=true,
        size=14,
    })
    if last then
        w= math.max(last:GetStringWidth(), w)
    end

    Frame.Background:SetPoint('BOTTOM', last or Frame.loot2, 0, -6)
    Frame.Background:SetWidth(w+4)
end


local function History_Tooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:ClearLines()

    local curMaps = {}
    for _, v in pairs( (C_ChallengeMode.GetMapTable() or {})) do
        curMaps[v]=true
    end

    local tabs={}
    local completed, all= 0,0
    for _, info in pairs(C_MythicPlus.GetRunHistory(true, true) or {}) do
        local mapID=info.mapChallengeModeID
        tabs[mapID]= tabs[mapID] or
                    {
                        level=0,
                        c=0,
                        t=0,
                        mapID= mapID,
                        isCurrent= curMaps[mapID],
                    }
        tabs[mapID].t= tabs[mapID].t+1
        if info.completed then
            tabs[mapID].c= tabs[mapID].c+1
            tabs[mapID].level= (info.level and info.level>tabs[mapID].level) and info.level or tabs[mapID].level
            completed= completed+ 1
        end
        all= all+1
    end

    local newTab={}
    for _, tab in pairs(tabs) do
        if tab.isCurrent then
            table.insert(newTab, tab)
        else
            table.insert(newTab, 1, tab)
        end
    end
    GameTooltip:AddDoubleLine(WoWTools_L.HISTORY, completed..'/'..all)

    for _, tab in pairs(newTab) do
        local name, _, _, texture= C_ChallengeMode.GetMapUIInfo(tab.mapID)
        if name then
            local text= (texture and '|T'..texture..':0|t' or '').. name..' ('..tab.level..') '
            local text2= tab.c..'/'..tab.t
            if tab.isCurrent then
                local bestOverAllScore = select(2, C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(tab.mapID)) or 0
                local score, col= WoWTools_ChallengeMixin:KeystoneScorsoColor(bestOverAllScore, nil, true)
                text= (col and col:WrapTextInColorCode(text) or text)..score
                text2= col and col:WrapTextInColorCode(text2) or text2
            else
                text='|cff828282'..text
                text2='|cff828282'..text2
            end
            GameTooltip:AddDoubleLine(text, text2)
        end
    end
    GameTooltip:Show()
end


local function Create_Label()

    Frame.history= WoWTools_LabelMixin:Create(Frame, {mouse=true, size=14})
    --Frame.history:SetPoint('TOPLEFT', Frame.dungeonScore, 'BOTTOMLEFT',0,-12)
    Frame.history:SetPoint('TOPLEFT')
    Frame.history:SetScript('OnLeave', function(self) self:SetAlpha(1) GameTooltip:Hide() end)
    Frame.history:SetScript('OnEnter', function(self)
        History_Tooltip(self)
        self:SetAlpha(0.5)
    end)

    Frame.week= WoWTools_LabelMixin:Create(Frame)
    Frame.week:SetPoint('TOPLEFT', Frame.history, 'BOTTOMLEFT')

    Frame.loot= WoWTools_LabelMixin:Create(Frame, {mouse=true, size=14})
    Frame.loot:SetPoint('TOPLEFT', Frame.week, 'BOTTOMLEFT',0,-12)
    function Frame.loot:get_Loot_itemLevel(level)
        local weeklyRewardLevel2 = C_MythicPlus.GetRewardLevelForDifficultyLevel(level)

        local min, max= WoWTools_DataMixin:GetChallengesWeekItemLevel(nil, true)
        weeklyRewardLevel2= math.max(weeklyRewardLevel2, min)
        weeklyRewardLevel2= math.min(weeklyRewardLevel2, max)

        local week= level..') '..(level<10 and ' ' or '')..(WoWTools_DataMixin:GetChallengesWeekItemLevel(level) or '')

        local isCurKey= self.curKey==level
        local isCurLevel= self.curLevel==level

        local text= week
            ..(isCurKey and '|T4352494:0|t' or '')
            ..(isCurLevel and '|A:common-icon-checkmark:0:0|a' or '')

        return isCurKey and '|cffffffff'..text..'|r' or (isCurLevel and '|cnGREEN_FONT_COLOR:'..text..'|r') or text
    end
    Frame.loot:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    Frame.loot:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(self:GetText())
        local min, max= WoWTools_DataMixin:GetChallengesWeekItemLevel(nil, true)
        for level=min, max do
            GameTooltip:AddLine(self:get_Loot_itemLevel(level))
        end
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    Frame.loot2= WoWTools_LabelMixin:Create(Frame)
    Frame.loot2:SetPoint('TOPLEFT', Frame.loot, 'BOTTOMLEFT')
end


local function Init()
    if WoWTools_ChallengeMixin:Save().hideRight then
        return
    end

    Frame= CreateFrame('Frame', nil, ChallengesFrame)
    Frame:SetFrameStrata('HIGH')
    Frame:SetFrameLevel(3)
    Frame:SetSize(1,1)
    Frame:Hide()

    Create_Label()

    function Frame:Settings()
        self:SetPoint('TOPLEFT', ChallengesFrame, 'TOPRIGHT', WoWTools_ChallengeMixin:Save().rightX or 2, WoWTools_ChallengeMixin:Save().rightY or -22)
        self:SetShown(not WoWTools_ChallengeMixin:Save().hideRight)
        self:SetScale(WoWTools_ChallengeMixin:Save().rightScale or 1)
     end

    Frame:SetScript('OnShow', function(self)
        Set_Text()
        self:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')
        self:RegisterEvent('BAG_UPDATE_DELAYED')
        self:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
        self:RegisterEvent('MYTHIC_PLUS_NEW_WEEKLY_RECORD')
    end)
    Frame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self.week:SetText('')
        self.loot:SetText('')
        self.loot.curLevel= nil
        self.loot.curKey= nil
        self.loot2:SetText('')
        WoWTools_LabelMixin:ItemCurrencyTips({frame=Frame, isClear=true})
    end)
    Frame:SetScript('OnEvent', function()
        Set_Text()
    end)



    WoWTools_TextureMixin:CreateBG(Frame,{point=function(texture)
        texture:SetPoint('TOPLEFT', -2, 6)
    end})


    C_Timer.After(1, function() Set_Text() end)
    Frame:Settings()

    Init= function()
        Frame:Settings()
    end
end


function WoWTools_ChallengeMixin:ChallengesUI_Right()
    Init()
end