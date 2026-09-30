

--z_ItemInteractionFrame.lua
--套装，转换，货币, 不指定, 值可能是nil
--WoWTools_DataMixin.CurrencyUpdateItemLevelID=nil
--C_MythicPlus.GetCurrentSeason()




--WoWTools_LabelMixin:ItemCurrencyTips
WoWTools_DataMixin.ItemCurrencyTips= {---物品升级界面，挑战界面，物品，货币提示
    --{type='currency', id=3008},--神勇石

    --{type='currency', id=3289},--符文虚灵纹章 11.2
    --{type='currency', id=3291},--鎏金虚灵纹章

    {type='currency', id=3378},--黎明之光法力熔剂


    --{type='currency', id=WoWTools_DataMixin.CurrencyUpdateItemLevelID, show=true},--套装，转换，货币
    {type='currency', id=1602, line=true},--征服点数
    {type='currency', id=1191},--勇气点数
}


--挑战数据 Challenges.lua C_MythicPlus.GetRewardLevelForDifficultyLevel()
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
        [2]='%d'..tab['Champion']..'2/6  %d'..tab['Hero']..'1/6|T7639519:0|t10',--需要修改
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
-- Information from(资料来自)：https://www.wowhead.com/guide/mythic-plus-dungeons/the-war-within-season-2/overview
-- AngryKeystones Schedule
WoWTools_DataMixin.SeasonAffixSchedule= 17--第几赛季--C_MythicPlus.GetCurrentSeason()
	-- Information from(资料来自)：https://www.wowhead.com/guide/midnight/mythic-plus-season-1-overview
	--{ [1] = 162, [2] = 10, [3] = 9 , [4] = 147, }
WoWTools_DataMixin.affixSchedule = {
    {162, 10, 9, 147},
}




WoWTools_ChallengesSpellData={
    [399]= {spell=393256, ins=1202},--传送到红玉新生法池的入口。 利爪防御者之路
    [400]= {spell=393262, ins=1198},--传送至诺库德阻击战的入口。 啸风平原之路
    [401]= {spell=393279, ins=1203},--传送至碧蓝魔馆的入口。 奥秘之路
    [402]= {spell=393273, ins=1201},--传送到艾杰斯亚学院的入口。 巨龙学位之路
    [403]= {spell=393222, ins=1197},--传送到奥达曼：提尔的遗产的入口 看护者遗产之路    
    [404]= {spell=393276, ins=1199},--传送到奈萨鲁斯的入口。 黑曜宝藏之路
    [405]= {spell=393267, ins=1196},--传送到蕨皮山谷的入口。 腐木之路
    [406]= {spell=393283, ins=1204},----传送到注能大厅的入口 泰坦水库之路

    [198]= {spell=424163, ins=762},--黑心林地 Darkheart Thicket (Legion)
    [199]= {spell=424153, ins=740},--黑鸦堡垒 Black Rook Hold (Legion)
    [168]= {spell=159901, ins=556},--永茂林地 The Everbloom (Warlords of Draenor)    
    [248]= {spell=424167, ins=1021},--维克雷斯庄园 Waycrest Manor (Battle for Azeroth)
    [244]= {spell=424187, ins=1176},--阿塔达萨 Atal'Dazar (Battle for Azeroth)
    [463]= {spell=424197, ins=1209, insName='永恒黎明'},--永恒黎明：迦拉克隆的陨落 Dawn of the Infinite: Galakrond's Fall
    [464]= {spell=424197, ins=1209, insName='永恒黎明'},--永恒黎明：姆诺兹多的崛起 Dawn of the Infinite: Murozond's Rise    
    [456]= {spell=424142, ins=65},--潮汐王座 Throne of the Tides (Cataclysm)

    [206]= {spell=410078, ins=767},--奈萨里奥的巢穴
    [245]= {spell=410071, ins=1001},--自由镇
    [251]= {spell=410074, ins=1022},--地渊孢林
    [438]= {spell=410080, ins=68},--旋云之巅
    [353]= {spell=464256, ins=1023},--围攻伯拉勒斯
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
--[161]={spell=159898, ins=476, name='通天峰', spellName='通天之路', spellDes='传送至|cff00ccff通天峰|r入口处。'},
--https://www.wowhead.com/cn/spell=1254557/加冕巅峰之路 传送到通天峰的入口

--双法术
if WoWTools_DataMixin.Player.Faction=='Alliance' then
    WoWTools_ChallengesSpellData[353].spell= 445418 --围攻伯拉勒斯
    WoWTools_ChallengesSpellData[247].spell= 467553 --暴富矿区
end


--https://wago.tools/db2/SpellFlyout?locale=zhCN
--Interface\\AddOns\\WoWToolsPlus\\Source\\Texture\\WoW\\0.tga
WoWTools_DataMixin.FlyoutID={
    {flyoutID= 246, ver=11},--英雄之路：“至暗之夜”

    {flyoutID= 244, ver=10},--英雄之路：“地心之战”第3赛季
    {flyoutID= 232, ver=10},--'英雄之路：地心之战--11
    {flyoutID= 242, ver=10, isRaid=true},--英雄之路：地心之战团队副本

    {flyoutID= 227, ver=9},--巨龙时代 10
    {flyoutID= 231, ver=9, isRaid=true},--英雄之路：巨龙时代团队副本

    {flyoutID= 220, ver=8},--暗影国度 9
    {flyoutID= 222, ver=8, isRaid=true},--英雄之路：暗影国度团队副本

    {flyoutID= 223, ver=7},--争霸艾泽拉斯 8
    {flyoutID= 224, ver=6},--军团再临 7
    {flyoutID= 96, ver=5},--德拉诺这王 6
    {flyoutID= 84, ver=4},--熊猫人之谜 5
    {flyoutID= 230, ver=3},--大地的裂变 4
    --巫妖王之怒 3
    --燃烧的远征 2
    --经典旧世 1
}
