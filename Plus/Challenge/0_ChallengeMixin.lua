WoWTools_ChallengeMixin={}
--[[
name, id, timeLimit, texture, backgroundTexture, mapID = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
journalInstanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)
]]










function WoWTools_ChallengeMixin:GetRewardText(type)--得到，周奖励，信息
    local text
    for _, info in pairs(C_WeeklyRewards.GetActivities(type) or {}) do
        if info.level and info.level>=0 and info.type==type then
            text= (text and text..'/' or '')..info.level
        end
    end
    if text=='0/0/0' then
        text= nil
    end
    return text
end




local function GetActivities()--Enum.WeeklyRewardChestThresholdType
    local R = {}
    for  _, info in pairs(C_WeeklyRewards.GetActivities() or {}) do
        if info.type and info.type>0 and info.level then--and info.type>= 1 and info.type<= 3
            local head
            local difficultyText
--史诗地下城 1
            if info.type == Enum.WeeklyRewardChestThresholdType.Activities then
                head= WoWTools_L.MYTHIC_DUNGEONS
                difficultyText= string.format(WoWTools_L.WEEKLY_REWARDS_MYTHIC, info.level)
--PVP 2
            elseif info.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
                head= WoWTools_L.PVP
                if WoWTools_DataMixin.onlyChinese then
                    local tab={
                        [0]= "休闲者",
                        [1]= "争斗者 I",
                        [2]= "挑战者 I",
                        [3]= "竞争者 I",
                        [4]= "决斗者",
                        [5]= "精锐",
                        [6]= "争斗者 II",
                        [7]= "挑战者 II",
                        [8]= "竞争者 II",
                    }
                    difficultyText=tab[info.level]
                end
                difficultyText=  difficultyText or PVPUtil.GetTierName(info.level)-- _G["PVP_RANK_"..tierEnum.."_NAME"] PVPUtil.lua
--团队副本 3
            elseif info.type == Enum.WeeklyRewardChestThresholdType.Raid then
                head= WoWTools_L.RAIDS
                difficultyText=  DifficultyUtil.GetDifficultyName(info.level)
--AlsoReceive 4
            elseif info.type== Enum.WeeklyRewardChestThresholdType.AlsoReceive then
                head= WoWTools_L.WEEKLY_REWARDS_ALSO_RECEIVE
--5 Concession
            elseif info.type== Enum.WeeklyRewardChestThresholdType.Concession then
                head= WoWTools_L.WEEKLY_REWARDS_GET_CONCESSION

--世界 6
            elseif info.type== Enum.WeeklyRewardChestThresholdType.World then
                head= WoWTools_L.WORLD

            end
            if head then
                R[head]= R[head] or {}
                R[head][info.index] = {
                    level = info.level,
                    difficulty = difficultyText or (WoWTools_L.PVP_RANK_0_NAME),
                    progress = info.progress,
                    threshold = info.threshold,
                    unlocked = info.progress>=info.threshold,
                    id= info.id,
                    type= info.type,
                    itemDBID= info.rewards and info.rewards.itemDBID or nil,
                }
            end

        end
    end

    return R
end



function WoWTools_ChallengeMixin:ActivitiesTooltip(tooltip)
    if (not WoWTools_DataMixin.Player.IsMaxLevel or PlayerIsTimerunning())--不是，最高等级时，退出
        and not WoWTools_DataMixin.Player.husandro
    then
        return
    end

    tooltip= tooltip or GameTooltip
    local find
    for head, tab in pairs(GetActivities()) do
        tooltip:AddLine('|cnNORMAL_FONT_COLOR:|A:common-icon-rotateright:0:0|a'..head)
        for index, info in pairs(tab) do
            if info.unlocked then
                local itemLink=  C_WeeklyRewards.GetExampleRewardItemHyperlinks(info.id)
                local texture= itemLink and select(5, C_Item.GetItemInfoInstant(itemLink))
                local itemLevel= itemLink and WoWTools_ItemMixin:GetItemLevel(itemLink)
                tooltip:AddLine(
                    '   '..index..') '
                    ..(texture and itemLevel and '|T'..texture..':0|t'..itemLevel or info.difficulty)
                    ..format('|A:%s:0:0|a', 'common-icon-checkmark')..((info.level and info.level>0) and info.level or ''))
            else
                tooltip:AddLine('    |cff828282'..index..') '
                    ..info.difficulty
                    .. ' '..(info.progress>0 and '|cnGREEN_FONT_COLOR:'..info.progress..'|r' or info.progress)
                    .."/"..info.threshold..'|r')
            end
        end
        find=true
    end
--local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon, pvpTier, ranking, roundsSeasonPlayed, roundsSeasonWon, roundsWeeklyPlayed, roundsWeeklyWon = GetPersonalRatedInfo(1)
    local CONQUEST_SIZE_STRINGS = {'', '2v2', '3v3', '10v10'}--PVP
    for i = 2, 4 do
        local rating, seasonBest, _, seasonPlayed, seasonWon, _, _, _, _, pvpTier = GetPersonalRatedInfo(1)
        local tierInfo = pvpTier and C_PvP.GetPvpTierInfo(pvpTier)
        if tierInfo and rating then
            seasonBest= seasonBest or 0
            seasonPlayed= seasonPlayed or 0
            seasonWon= seasonWon or 0
            local text=''
            if seasonPlayed>0 then
                local best=''
                if seasonBest>0 and seasonBest~=rating then
                    best= '|cff626262'..seasonBest..'|r '
                end
                text= ' ('..best..'|cnGREEN_FONT_COLOR:'..seasonWon..'|r/'..seasonPlayed..')'
            end
            text= (tierInfo.tierIconID and '|T'..tierInfo.tierIconID..':0|t' or '')
                ..NORMAL_FONT_COLOR:WrapTextInColorCode(CONQUEST_SIZE_STRINGS[i])
                ..(rating==0 and ' |cff626262' or ' |cffffffff')..rating..'|r' ..text
            tooltip:AddLine(text)
            find=true
        end
    end

    return find
end












local function Create_Activities_SubLable(frame, head, index, last)
    local label= WoWTools_LabelMixin:Create(frame, {mouse= true})

    label:SetPoint('TOPLEFT', last, 'BOTTOMLEFT')
    label:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    label:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self,  self.anchor or "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        local link= self:Get_ItemLink()
        if link then
            GameTooltip:SetHyperlink(link)
        else
            GameTooltip:AddDoubleLine(format(WoWTools_L.LFG_LIST_CROSS_FACTION,WoWTools_L.STAT_AVERAGE_ITEM_LEVEL ),WoWTools_L.NONE)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('Activities Type '..self.type, 'id '..self.id)
        end
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
    function label:Get_ItemLink()
        local link
        if self.itemDBID then
            link= C_WeeklyRewards.GetItemHyperlink(self.itemDBID)
        elseif self.id then
            link= C_WeeklyRewards.GetExampleRewardItemHyperlinks(self.id)
        end
        if link and link~='' then
           WoWTools_DataMixin:Load(link, 'item')
            return link
        end
    end
    frame.WeekRewards['rewardChestSub'..head..index]= label

    return label
end


local function Create_Activities_HeaderLable(frame, head, point, last)
    local label= WoWTools_LabelMixin:Create(frame)
    if last then
        label:SetPoint('TOPLEFT', last, 'BOTTOMLEFT',0,-4)
    elseif point and point[1] then
        label:SetPoint(point[1], point[2] or frame, point[3], point[4], point[5])
    else
        label:SetPoint('TOPLEFT')
    end

    frame.WeekRewards['rewardChestHead'..head]= label

    return label
end




function WoWTools_ChallengeMixin:ActivitiesFrame(frame, settings)--周奖励，提示
    if not WoWTools_DataMixin.Player.IsMaxLevel and not WoWTools_DataMixin.Player.husandro then--不是，最高等级时，退出
        return
    end

    settings= settings or {}
    if settings.isClear then

        for _, label in pairs(frame.WeekRewards or {}) do
            label:SetText('')
            label.id= nil
            label.type= nil
            label.itemDBID= nil
            label.anchor= nil
        end

        return
    end

    frame.WeekRewards= frame.WeekRewards or {}

    WoWTools_TextureMixin:CreateBG(frame)
    frame.Background:SetPoint('TOPLEFT', -2, 2)
    local w=0

    local R= GetActivities()
    local last
    local point= settings.point
    local anchor= settings.anchor

    for head, tab in pairs(R) do
        local label= frame.WeekRewards['rewardChestHead'..head] or Create_Activities_HeaderLable(frame, head, point, last)
        label:SetText('|A:common-icon-rotateright:0:0|a'..head)

        last= label

        w= math.max(w, label:GetWidth())

        for index, info in pairs(tab) do
            label= frame.WeekRewards['rewardChestSub'..head..index] or Create_Activities_SubLable(frame, head, index, last)

            label.id= info.id
            label.type= info.type
            label.itemDBID= info.itemDBID
            label.anchor= anchor
            last= label

            local text
            local itemLink= label:Get_ItemLink()
            if itemLink then
                local texture= select(5, C_Item.GetItemInfoInstant(itemLink))
                local itemLevel= WoWTools_ItemMixin:GetItemLevel(itemLink)
                text= '    '..index..') '..(texture and '|T'..texture..':0|t' or itemLink)
                text= text..((itemLevel and itemLevel>0) and itemLevel or '')..format('|A:%s:0:0|a', 'common-icon-checkmark')..((info.level and info.level>0) and info.level or '')
            else
                if info.unlocked then
                    text='   '..index..') '..info.difficulty..format('|A:%s:0:0|a', 'common-icon-checkmark')..(info.level or '')--.. ' '..(WoWTools_L.COMPLETE)
                else
                    text='    |cff828282'..index..') '
                        ..info.difficulty
                        .. ' '..(info.progress>0 and '|cnGREEN_FONT_COLOR:'..info.progress..'|r' or info.progress)
                        .."/"..info.threshold..'|r'
                end
            end
            label:SetText(text or '')

            w= math.max(w, label:GetWidth())
        end
    end



    if settings.isPvP then
        local CONQUEST_SIZE_STRINGS = {'', '2v2', '3v3', '10v10'}--PVP
        for i = 2, 4 do
            local rating, seasonBest, weeklyBest, seasonPlayed, seasonWon, weeklyPlayed, weeklyWon, lastWeeksBest, hasWon, pvpTier, ranking, roundsSeasonPlayed, roundsSeasonWon, roundsWeeklyPlayed, roundsWeeklyWon = GetPersonalRatedInfo(1)
            local tierInfo = pvpTier and C_PvP.GetPvpTierInfo(pvpTier)
            if tierInfo and rating then
                seasonBest= seasonBest or 0
                seasonPlayed= seasonPlayed or 0
                seasonWon= seasonWon or 0
                local text=''
                if seasonPlayed>0 then
                    local best=''
                    if seasonBest>0 and seasonBest~=rating then
                        best= '|cff626262'..seasonBest..'|r '
                    end
                    text= ' ('..best..'|cnGREEN_FONT_COLOR:'..seasonWon..'|r/'..seasonPlayed..')'
                end
                text= (tierInfo.tierIconID and '|T'..tierInfo.tierIconID..':0|t' or '')..CONQUEST_SIZE_STRINGS[i]..(rating==0 and ' |cff626262' or ' |cffffffff')..rating..'|r' ..text

                local head= CONQUEST_SIZE_STRINGS[i]

                local label= frame.WeekRewards['rewardChestHead'..head] or Create_Activities_HeaderLable(frame, head, nil, last)
                label:SetText(text)
                last= label

                w= math.max(w, label:GetWidth())
            end
        end
    end

    frame.Background:SetPoint('BOTTOMLEFT', last or frame, 0, -2)
    frame.Background:SetWidth(w+2)

    return last
end








function WoWTools_ChallengeMixin:KeystoneScorsoColor(score, texture, overall)--地下城史诗, 分数, 颜色 C_ChallengeMode.GetOverallDungeonScore()
    score= score or 0
    score= type(score)~='number' and tonumber(score) or score or 0
    if score<=0 then
        return ''
    end

    local color= not overall and C_ChallengeMode.GetDungeonScoreRarityColor(score) or C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(score)

    local scoreText= format('%d', score)

    if color then
        scoreText= color:WrapTextInColorCode(score)
    end
    if texture then
        scoreText= '|T4352494:0|t'..scoreText
    end

    return score, color
end


--[[
ItemRef.lua
DungeonScoreInfoMixin:OnClick()
Blizzard_ChallengesUI.lua
]]
function WoWTools_ChallengeMixin:GetDungeonScoreLink()
    local dungeonScore = C_ChallengeMode.GetOverallDungeonScore() or 0
    return GetDungeonScoreLink(dungeonScore, UnitName("player"))
end

--Hechizo de portal de una mazmorra de míticas+.
--La tabla WoWTools_ChallengesSpellData está escrita a mano y se queda sin las mazmorras de temporadas nuevas:
--si falta, se busca en los desplegables "Camino del héroe" (los conocidos y los que haya en el libro de hechizos)
--el portal cuya descripción o nombre menciona la mazmorra.
local PortalCache= {}

--Portales que el jugador puede no tener aprendidos (y por eso su desplegable no está en el libro de hechizos).
--Se asignan a su mazmorra por la descripción, igual que los demás. Midnight, temporada 2:
local ExtraPortals= {
    1286801,--Path of the Blooming Verdure (El Valle Encegador)
    1286804,--Path of the Brutal Combatant (Arena de la Cicatriz del Vacío)
    1286807,--Path of the Worthy Aspirant (Guarida de Nalorakk)
    1286809,--Path of the Devious Smuggler (Frontal de la Muerte)
    1286812,--Path of Venomous Evolution (Altar de los Colmillos)
}

local function Get_Flyouts()
    local list, seen= {}, {}
    for _, info in ipairs(WoWTools_DataMixin.FlyoutID or {}) do
        if info.flyoutID and not info.isRaid and not seen[info.flyoutID] then
            seen[info.flyoutID]= true
            table.insert(list, info.flyoutID)
        end
    end
    if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines and Enum.SpellBookItemType then
        for line= 1, C_SpellBook.GetNumSpellBookSkillLines() or 0 do
            local lineInfo= C_SpellBook.GetSpellBookSkillLineInfo(line)
            if lineInfo and lineInfo.itemIndexOffset and lineInfo.numSpellBookItems then
                for index= lineInfo.itemIndexOffset+1, lineInfo.itemIndexOffset+lineInfo.numSpellBookItems do
                    local item= C_SpellBook.GetSpellBookItemInfo(index, Enum.SpellBookSpellBank.Player)
                    if item and item.itemType==Enum.SpellBookItemType.Flyout and item.actionID and not seen[item.actionID] then
                        seen[item.actionID]= true
                        table.insert(list, item.actionID)
                    end
                end
            end
        end
    end
    return list
end

local function Name_Variants(name)
    local list= {name}
    for _, sep in ipairs({':', '：'}) do--búsqueda literal: '：' ocupa 3 bytes y no puede ir en una clase [ ]
        local pos= name:find(sep, 1, true)
        if pos then
            local before= name:sub(1, pos-1):gsub('%s+$', '')
            local after= name:sub(pos+#sep):gsub('^%s+', '')
            if after~='' then
                table.insert(list, after)--"Tazavesh: Calle…" -> "Calle…"
            end
            if before~='' then
                table.insert(list, before)
            end
        end
    end
    return list
end

function WoWTools_ChallengeMixin:GetPortalSpellID(mapID)
    if not mapID then
        return
    end
    local data= WoWTools_ChallengesSpellData and WoWTools_ChallengesSpellData[mapID]
    if data and data.spell then
        return data.spell
    end
    if PortalCache[mapID] then
        return PortalCache[mapID]
    end

    local mapName= C_ChallengeMode.GetMapUIInfo(mapID)
    if type(mapName)~='string' or mapName=='' then
        return
    end
    local names= Name_Variants(mapName)

    --Portales disponibles (una sola pasada por los desplegables)
    local portals= {}
    for _, flyoutID in ipairs(Get_Flyouts()) do
        local _, _, numSlots= GetFlyoutInfo(flyoutID)
        for slot= 1, numSlots or 0 do
            local spellID, _, _, spellName= GetFlyoutSlotInfo(flyoutID, slot)
            if spellID then
                local desc= C_Spell.GetSpellDescription(spellID) or ''
                if desc=='' then
                    C_Spell.RequestLoadSpellData(spellID)--la descripción llega más tarde; se reintenta en la próxima actualización
                end
                table.insert(portals, {spellID=spellID, desc=desc, name=spellName or ''})
            end
        end
    end
    for _, spellID in ipairs(ExtraPortals) do
        local desc= C_Spell.GetSpellDescription(spellID) or ''
        if desc=='' then
            C_Spell.RequestLoadSpellData(spellID)
        end
        table.insert(portals, {spellID=spellID, desc=desc, name=C_Spell.GetSpellName(spellID) or ''})
    end

    --Del nombre más completo al más corto: así "Operación" no elige el portal de otra "Operación: …"
    for _, name in ipairs(names) do
        for _, portal in ipairs(portals) do
            if portal.desc:find(name, 1, true) or portal.name:find(name, 1, true) then
                PortalCache[mapID]= portal.spellID
                return portal.spellID
            end
        end
    end

    --Reserva: por palabras. El nombre de la ventana y el de la descripción pueden variar
    --("El Valle…" / "del Valle…"): gana el portal con más palabras del nombre, solo si no hay empate.
    local skip= {el=true, la=true, los=true, las=true, del=true, ['de']=true, the=true, ['of']=true, le=true, les=true, der=true, die=true, das=true}
    local words= {}
    for word in mapName:lower():gmatch('[^%s%p]+') do
        if #word>=3 and not skip[word] then
            table.insert(words, word)
        end
    end
    local best, bestScore, tie= nil, 0, false
    for _, portal in ipairs(portals) do
        local text= (portal.desc..' '..portal.name):lower()
        local score= 0
        for _, word in ipairs(words) do
            if text:find(word, 1, true) then
                score= score+1
            end
        end
        if score>bestScore then
            best, bestScore, tie= portal.spellID, score, false
        elseif score==bestScore and score>0 then
            tie= true
        end
    end
    if best and not tie then
        PortalCache[mapID]= best
        return best
    end
end

--Diagnóstico: /wtportal muestra el portal encontrado para cada mazmorra de la temporada
SLASH_WOWTOOLSPORTAL1= '/wtportal'
SlashCmdList['WOWTOOLSPORTAL']= function()
    wipe(PortalCache)
    for _, mapID in ipairs(C_ChallengeMode.GetMapTable() or {}) do
        local name= C_ChallengeMode.GetMapUIInfo(mapID)
        local spellID= WoWTools_ChallengeMixin:GetPortalSpellID(mapID)
        print(
            WoWTools_DataMixin.Icon.icon2..mapID,
            name,
            '->',
            spellID and (C_Spell.GetSpellLink(spellID) or spellID) or '|cnWARNING_FONT_COLOR:'..WoWTools_L['Not found']..'|r'
        )
    end
end
