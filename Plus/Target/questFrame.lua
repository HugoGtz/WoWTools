
local THREAT_TOOLTIP= WoWTools_TextMixin:Magic(THREAT_TOOLTIP)
local questFrame
local function Save()
    return WoWToolsPlusSave['Plus_Target']
end


local function Find_Text(text)
    if canaccessvalue(text) and text and not text:find(THREAT_TOOLTIP) then
        if text:find('(%d+/%d+)') then
            local min, max= text:match('(%d+)/(%d+)')
            min, max= tonumber(min), tonumber(max)
            if min and max and max> min then
                return max- min
            end
        elseif text:find('[%d%.]+%%') then
            local value= text:match('([%d%.]+%%)')
            if value and value~='100%' then
                return value
            end
        end
    end
end



local function Get_Unit_Text(unit)
    local isAI= UnitInPartyIsAI(unit)

    if not canaccessvalue(isAI) then
        return

    elseif isAI then
        local role = UnitGroupRolesAssigned(unit)
        if role and role~='NONE' then
            return WoWTools_DataMixin.Icon[role]
        end--if role=='TANK' or role=='HEALER' then

    elseif not UnitIsPlayer(unit) then
        local data = C_TooltipInfo.GetUnit(unit)
        if data and data.lines then
            for i = 4, #data.lines do
                local line = data.lines[i]
                local text= Find_Text(line.leftText)
                if text then
                    return text
                end
            end
        end

        if C_QuestLog.UnitIsRelatedToActiveQuest(unit) then
            if UnitIsQuestBoss(unit) then
                return '|A:Crosshair_Attack_128:22:22|a'
            end

            return '|A:QuestLegendary:22:22|a'
        end


    else--if not UnitInParty(unit) and not UnitInRaid(unit) then

        local wow= WoWTools_UnitMixin:GetIsFriendIcon(nil, UnitGUID(unit), nil)
        local faction= WoWTools_UnitMixin:GetFaction(unit, nil, Save().questShowAllFaction)
        local text
        if Save().questShowPlayerClass then
            text= WoWTools_UnitMixin:GetClassIcon(unit)
        end
        if wow or faction then
            text= (text or '')..(wow or '')..(faction or '')
        end
        return text
    end
end


local function Set_Quest_Text(plate)
    local frame= plate and plate.UnitFrame

    if not frame then
        return
    end


    local text= Get_Unit_Text(frame.unit)


    if text and not frame.questProgress then
        frame.questProgress= frame:CreateFontString(nil, 'ARTWORK', 'ChatFontNormal') -- WoWTools_LabelMixin:Create(frame, {size=14, color={r=0,g=1,b=0}})--14, nil, nil, {0,1,0}, nil,'LEFT')
        frame.questProgress:SetTextColor(GREEN_FONT_COLOR:GetRGB())
        frame.questProgress:SetPoint('LEFT', frame.healthBar or frame, 'RIGHT', 2,0)
    end
    if frame.questProgress then
        frame.questProgress:SetText(text or '')
        frame.questProgress:SetFontHeight(frame.isSimplified and 44 or 22)
    end
end


local function Check_AllPlate()
    for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
        Set_Quest_Text(plate)
    end
end


local function RestPlate(plate)
    if plate and plate.UnitFrame and plate.UnitFrame.questProgress then
        plate.UnitFrame.questProgress:SetText('')
    end
end
local function RestAllPlate()
    for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
        RestPlate(plate)
    end
end


--#########
--#########
local function Init()
    if not Save().quest then
        return
    end

    questFrame= CreateFrame('Frame')


    function questFrame:settings()
        self:UnregisterAllEvents()

        if not Save().quest then
            RestAllPlate()
            return
        end

        self:RegisterEvent('PLAYER_ENTERING_WORLD')

        if IsInRaid()
            or (IsInInstance() and IsInGroup(LE_PARTY_CATEGORY_HOME) and not WoWTools_MapMixin:IsInDelve())
            or WoWTools_MapMixin:IsInPvPArea()
            or C_ChallengeMode.IsChallengeModeActive()
        then
            RestAllPlate()
            return
        end

        FrameUtil.RegisterFrameForEvents(self, {
            'UNIT_QUEST_LOG_CHANGED',
            'SCENARIO_UPDATE',
            'SCENARIO_CRITERIA_UPDATE',
            'SCENARIO_COMPLETED',
            'QUEST_POI_UPDATE',
            'NAME_PLATE_UNIT_ADDED',
            'GROUP_ROSTER_UPDATE',
            --'NAME_PLATE_UNIT_REMOVED',
        })

        Check_AllPlate()
    end


    questFrame:SetScript("OnEvent", function(self, event, arg1)
        if event=='PLAYER_ENTERING_WORLD' then
            self:settings()

        elseif event=='NAME_PLATE_UNIT_ADDED' then
            if arg1 then
                Set_Quest_Text(C_NamePlate.GetNamePlateForUnit(arg1, issecure()))
            end

        elseif event=='GROUP_ROSTER_UPDATE' then
            Check_AllPlate()

        else--event=='UNIT_QUEST_LOG_CHANGED' or event=='QUEST_POI_UPDATE' or event=='SCENARIO_COMPLETED' or event=='SCENARIO_UPDATE' or event=='SCENARIO_CRITERIA_UPDATE' then
            --un solo temporizador: se reinicia en cada evento
            if self.checkTimer then
                self.checkTimer:Cancel()
            end
            self.checkTimer= C_Timer.NewTimer(2, function()
                self.checkTimer= nil
                Check_AllPlate()
            end)
        end
    end)


    questFrame:settings()


    Init=function()
        questFrame:settings()
    end
end


function WoWTools_TargetMixin:Init_questFrame()
    Init()
end