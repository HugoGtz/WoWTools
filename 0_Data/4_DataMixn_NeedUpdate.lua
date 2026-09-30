

--z_ItemInteractionFrame.lua
--WoWTools_DataMixin.CurrencyUpdateItemLevelID=nil
--C_MythicPlus.GetCurrentSeason()




--WoWTools_LabelMixin:ItemCurrencyTips
WoWTools_DataMixin.ItemCurrencyTips= {


    {type='currency', id=3378},


    {type='currency', id=1602, line=true},
    {type='currency', id=1191},
}


--https://www.wowhead.com/guide/midnight/season-1-overview-dungeons-raids-dates#dungeon-pool

local endOfRunRewardLevel={--Midnight: Season 1 Mythic+ Item Level Table
    [2]=259,
    [3]=259,
    [4]=263,
    [5]=263,
    [6]=266,
    [7]=269,
    [8]=269,
    [9]=269,
    [10]=272,
    
    [11]=272,
    [12]=272,
}

local WeekItemLevel, Init_WeekItemLevel
function Init_WeekItemLevel()
    local tab={
        --['Veteran']= format('|cff1eff00%s|r', 'Veteran'),
        ['Champion']= format('|cff0070dd%s|r', WoWTools_L.FOLLOWERLIST_LABEL_CHAMPIONS),
        ['Hero']= format('|cffa334ee%s|r', WoWTools_L.ITEM_HEROIC),
        ['Myth']= format('|cffff8000%s|r', WoWTools_L.ITEM_QUALITY4_DESC),
    }
    WeekItemLevel={
        [2]='%d'..tab['Champion']..'2/6  %d'..tab['Hero']..'1/6|T7639519:0|t10',
        [3]='%d'..tab['Champion']..'2/6  %d'..tab['Hero']..'1/6|T7639519:0|t12',
        [4]='%d'..tab['Champion']..'3/6  %d'..tab['Hero']..'2/6|T7639521:0|t14',
        [5]='%d'..tab['Champion']..'4/6  %d'..tab['Hero']..'2/6|T7639521:0|t16',

        [6]='%d'..tab['Hero']..'1/6  %d'..tab['Hero']..'3/6|T7639521:0|t18',
        [7]='%d'..tab['Hero']..'1/6  %d'..tab['Hero']..'4/6|T7639523:0|t10',
        [8]='%d'..tab['Hero']..'2/6  %d'..tab['Hero']..'4/6|T7639523:0|t12',
        [9]='%d'..tab['Hero']..'2/6  %d'..tab['Hero']..'4/6|T7639523:0|t14',
        [10]='%d'..tab['Hero']..'3/6  %d'..tab['Myth']..'1/6|T7639523:0|t16',

        [11]='%d'..tab['Hero']..'3/6  %d'..tab['Myth']..'1/6|T7639523:0|t16',
        [12]='%d'..tab['Hero']..'3/6  %d'..tab['Myth']..'1/6|T7639523:0|t16',

        min=2,
        max=10,
    }
end


function WoWTools_DataMixin:GetChallengesWeekItemLevel(level, isGetNum)
    do
        if not WeekItemLevel then
            Init_WeekItemLevel()
            Init_WeekItemLevel=nil
        end
    end

    if isGetNum then
        return WeekItemLevel.min, WeekItemLevel.max
    else

        level= math.min(WeekItemLevel.max, level or WeekItemLevel.min)
        level= math.max(WeekItemLevel.min, level or WeekItemLevel.max)

        local weekly, endOfRun= C_MythicPlus.GetRewardLevelForDifficultyLevel(level)

        endOfRun= (endOfRun and endOfRun>0) and endOfRun or endOfRunRewardLevel[level] or 0
        weekly= weekly or 0

        return format(WeekItemLevel[level], endOfRun, weekly)
    end
end


-- TWW Season 2 (Sort:[1](Level 4+);[2](Level 7+);[3](Level 10+);[4](Level 12+))
-- AngryKeystones Schedule
WoWTools_DataMixin.SeasonAffixSchedule= 17
	--{ [1] = 162, [2] = 10, [3] = 9 , [4] = 147, }
WoWTools_DataMixin.affixSchedule = {
    {162, 10, 9, 147},
}




WoWTools_ChallengesSpellData={
    [399]= {spell=393256, ins=1202},
    [400]= {spell=393262, ins=1198},
    [401]= {spell=393279, ins=1203},
    [402]= {spell=393273, ins=1201},
    [403]= {spell=393222, ins=1197},
    [404]= {spell=393276, ins=1199},
    [405]= {spell=393267, ins=1196},
    [406]= {spell=393283, ins=1204},

    [198]= {spell=424163, ins=762},
    [199]= {spell=424153, ins=740},
    [168]= {spell=159901, ins=556},
    [248]= {spell=424167, ins=1021},
    [244]= {spell=424187, ins=1176},
    [463]= {spell=424197, ins=1209},
    [464]= {spell=424197, ins=1209},
    [456]= {spell=424142, ins=65},

    [206]= {spell=410078, ins=767},
    [245]= {spell=410071, ins=1001},
    [251]= {spell=410074, ins=1022},
    [438]= {spell=410080, ins=68},
    [353]= {spell=464256, ins=1023},
    [247]= {spell=467555, ins=1012},




    [2]={spell=131204, ins=313},
    [200]={spell=393764, ins=721},
    [210]={spell=393766, ins=800},
    [165]={spell=159899, ins=537},

    [391]={spell=367416, ins=1194},
    [392]={spell=367416, ins=1194},
    [166]={spell=159900, ins=536},
    [369]={spell=373274, ins=1178},
    [370]={spell=373274, ins=1178},


    [169]={spell=159896, ins=558},
    [227]={spell=373262, ins=860},
    [234]={spell=373262, ins=860},


    [56]={spell=131205, ins=302},
    [57]={spell=131225, ins=303},
    [58]={spell=131206, ins=321},
    [59]={spell=131228, ins=324},
    [60]={spell=131222, ins=321},
    [76]={spell=131232, ins=246},
    [77]={spell=131231, ins=311},
    [78]={spell=131229, ins=316},




    [163]={spell=159895, ins=385},
    [167]={spell=159902, ins=559},
    [161]={spell=159898, ins=476},
    [164]={spell=159897, ins=547},
    [379]={spell=354463, ins=1183},
    [375]={spell=354464, ins=1184},
    [377]={spell= 354468, ins=1188},

    [380]={spell=354469, ins=1189},
    [378]={spell=354465, ins=1185},
    [382]={spell=354467, ins=1187},
    [376]={spell=354462, ins=1182},
    [381]={spell=354466, ins=1186},


    [499]= {spell=445444, ins=1267},
    [500]= {spell=445443, ins=1268},
    [501]= {spell=445269, ins=1269},
    [502]= {spell=445416, ins=1274},
    [503]= {spell=445417, ins=1271},
    [504]= {spell=445441, ins=1210},
    [505]= {spell=445414, ins=1270},
    [506]= {spell=445440, ins=1272},
    [507]= {spell=445424, ins=71},
    [525]= {spell=1216786, ins=1298},

    [541]= {spell=nil, ins=67},--12.05
    [542]= {spell=1237215, ins=1303},

    [556]= {spell=1254555, ins=658},
    [557]= {spell=1254400, ins=2805},
    [558]= {spell=1254572, ins=2811},

    [559]= {spell=1254563, ins=2915},
    [560]= {spell=1254559, ins=2874},

    [239]= {spell=1254551, ins=1753},
    [583]= {spell=nil, ins=1753},

}

if WoWTools_DataMixin.Player.Faction=='Alliance' then
    WoWTools_ChallengesSpellData[353].spell= 445418
    WoWTools_ChallengesSpellData[247].spell= 467553
end


--https://wago.tools/db2/SpellFlyout?locale=zhCN
--Interface\\AddOns\\WoWToolsPlus\\Source\\Texture\\WoW\\0.tga
WoWTools_DataMixin.FlyoutID={
    {flyoutID= 246, ver=11},

    {flyoutID= 244, ver=10},
    {flyoutID= 232, ver=10},
    {flyoutID= 242, ver=10, isRaid=true},

    {flyoutID= 227, ver=9},
    {flyoutID= 231, ver=9, isRaid=true},

    {flyoutID= 220, ver=8},
    {flyoutID= 222, ver=8, isRaid=true},

    {flyoutID= 223, ver=7},
    {flyoutID= 224, ver=6},
    {flyoutID= 96, ver=5},
    {flyoutID= 84, ver=4},
    {flyoutID= 230, ver=3},
}
