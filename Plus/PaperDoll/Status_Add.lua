
if WoWTools_DataMixin.Player.Ver<120005 then
    return
end

local AttributesCategory={}
local P_PAPERDOLL_STATCATEGORIES= PAPERDOLL_STATCATEGORIES










local function Data_Save()
    WoWTools_PaperDollMixin:UpdateStats()
    WoWTools_PaperDollMixin:Save().PAPERDOLL_STATCATEGORIES= PAPERDOLL_STATCATEGORIES
end




local function Find_Stats(stat, index, P)
    local tabs
    if P then
        tabs=P_PAPERDOLL_STATCATEGORIES[index]
    else
       tabs= PAPERDOLL_STATCATEGORIES[index]
    end
    if tabs then
        for _, tab in pairs(tabs.stats or {}) do
            if tab.stat==stat then
                return tab
            end
        end
    end
    return false
end

local function Find_Roles(roles)
    local tank, n, dps= false, false, false
    for _, num in pairs(roles or {}) do
        if num== Enum.LFGRole.Tank then--0
            tank=true
        elseif num== Enum.LFGRole.Healer then--1
            n=true
        elseif num== Enum.LFGRole.Damage then--2
            dps=true
        end
    end
    return tank, n, dps
end

local function Add_Stat(tab)
    local index= tab.index
    local stat=tab.stat
    if not PAPERDOLL_STATCATEGORIES[index] then
        local categoryFrame= index==1 and 'AttributesCategory'
                    or (index==2 and 'EnhancementsCategory')
                    or (index==3 and 'GeneralCategory')
                    or (index==4 and 'AttackCategory')
                    or 'OtherCategory'
        PAPERDOLL_STATCATEGORIES[index]= {
            categoryFrame= categoryFrame,
            stats={},
        }
        if not CharacterStatsPane[categoryFrame] then
            local frame= CreateFrame("Frame", nil, CharacterStatsPane, 'CharacterStatFrameCategoryTemplate')
            local title= index==3 and (WoWTools_L.GENERAL)
                    or index==4 and (WoWTools_L.ATTACK)
                    or (WoWTools_L.OTHER)
            frame.titleText=title
            frame.Title:SetText(title)
            CharacterStatsPane[categoryFrame]= frame
        end
    end
    local P_tab= Find_Stats(stat, index, true)
    if not PAPERDOLL_STATCATEGORIES[index] then
        PAPERDOLL_STATCATEGORIES[index]= {categoryFrame= index}
    end
    if P_tab then
        table.insert(PAPERDOLL_STATCATEGORIES[index].stats, P_tab)
    else
        table.insert(PAPERDOLL_STATCATEGORIES[index].stats, {
            stat=stat,
            hideAt=-1,
            --roles= tab.roles,
            --primary= tab.primary,
            --showFunc= tab.showFunc,
        })
    end
    --WoWTools_Print(WoWTools_DataMixin.Icon.icon2..WoWTools_PaperDollMixin.addName, format('|cnGREEN_FONT_COLOR:%s|r', stat), ADD)
end

local function Remove_Stat(tab)
    local index= tab.index
    local stat= tab.stat
    --local name= tab.name
    if PAPERDOLL_STATCATEGORIES[index] then
        for i, info in pairs(PAPERDOLL_STATCATEGORIES[index].stats or {}) do
            if info.stat==stat then
                table.remove(PAPERDOLL_STATCATEGORIES[index].stats, i)
                --WoWTools_Print(WoWTools_DataMixin.Icon.icon2..WoWTools_PaperDollMixin.addName, format('|cnWARNING_FONT_COLOR:%s|r', REMOVE), stat, name)
                return
            end
        end
    end
    --WoWTools_Print(WoWTools_DataMixin.Icon.icon2..WoWTools_PaperDollMixin.addName, format('|cnWARNING_FONT_COLOR:%s|r', TAXI_PATH_UNREACHABLE), stat, name)
end

local function Get_Primary_Text(primary)
    if primary then
        if primary==LE_UNIT_STAT_STRENGTH then
            return format('|cffc69b6d%s|r', WoWTools_L.SPEC_FRAME_PRIMARY_STAT_STRENGTH)
        elseif primary==LE_UNIT_STAT_AGILITY then
            return format('|cff16c663%s|r', WoWTools_L.SPEC_FRAME_PRIMARY_STAT_AGILITY)
        elseif primary==LE_UNIT_STAT_INTELLECT then
            return format('|cff00ccff%s|r', WoWTools_L.SPEC_FRAME_PRIMARY_STAT_INTELLECT)
        end
    end
end


local function Get_Role_Text(roleIndex)
    return
        roleIndex== Enum.LFGRole.Tank and format('%s%s', WoWTools_DataMixin.Icon.TANK, WoWTools_L.TANK)
        or (roleIndex==Enum.LFGRole.Healer and format('%s%s', WoWTools_DataMixin.Icon.HEALER, WoWTools_L.HEALER))
        or (roleIndex==Enum.LFGRole.Damage and format('%s%s', WoWTools_DataMixin.Icon.DAMAGER, WoWTools_L.DAMAGER))
        or (WoWTools_L.NONE)

end

















local function Init_Sub_Menu(_, root, stat, index, name)
    local stats= Find_Stats(stat, index, false)

    if not stats then
        return
    end

    local p_stats= Find_Stats(stat, index, true) or {}

    local sub
    root:CreateTitle(name..' '..stat..' '..index)

    root:CreateDivider()
    for va=-1, 0 do
        sub=root:CreateCheckbox(
            (WoWTools_L['SELF_CAST_AUTO+HIDE'])
            ..(p_stats.hideAt==va and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
        function(data)
            local tab= Find_Stats(data.stat, data.index, false)
            return tab and tab.hideAt== data.value
        end, function(data)
            local tab=Find_Stats(data.stat, data.index, false)
            if tab then
                if not tab.hideAt or tab.hideAt~=data.value then
                    tab.hideAt= data.value
                else
                    tab.hideAt= nil
                end
                Data_Save()
            end
        end, {stat=stat, index=index, value=va, hideAt=stats.hideAt, p_hideAt=p_stats.hideAt, rightText=va, rightColor=GREEN_FONT_COLOR})
        WoWTools_MenuMixin:SetRightText(sub)

        sub:SetTooltip(function(tooltip, description)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.PaperDoll.StatHideAt'])
            tooltip:AddLine(
                (WoWTools_L.DEFAULT)
                ..': '
                ..(description.data.p_hideAt or (WoWTools_L.NONE))
            )
            tooltip:AddLine(' ')
            tooltip:AddLine(format('<='..description.data.value..' %s', WoWTools_L.HIDE))
        end)
    end

    root:CreateDivider()
    for i= Enum.LFGRole.Tank, Enum.LFGRole.Damage, 1 do
        sub=root:CreateCheckbox(
            Get_Role_Text(i)
            ..(p_stats.roles and (p_stats.roles[1]==i or p_stats.roles[2]==i or p_stats.roles[3]==i) and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
        function(data)
            local tank, n, dps= Find_Roles(stats.roles)
            if data.value==Enum.LFGRole.Tank then
                return tank
            elseif data.value==Enum.LFGRole.Healer then
                return n
            elseif data.value== Enum.LFGRole.Damage then
                return dps
            end
        end, function(data)
            local tab= Find_Stats(data.stat, data.index, false)
            if tab then
                if tab.stat==data.stat then
                    local findTank, findN, findDps
                    if not tab.roles then
                        tab.roles={data.value}
                    else
                        findTank, findN, findDps= Find_Roles(stats.roles)
                        if data.value==Enum.LFGRole.Tank then
                            findTank = not findTank and true or false
                        elseif data.value==Enum.LFGRole.Healer then
                            findN = not findN and true or false
                        elseif data.value==Enum.LFGRole.Damage then
                            findDps = not findDps and true or false
                        end
                        if findTank or findN or findDps then
                            local roles={}
                            if findTank then table.insert(roles, Enum.LFGRole.Tank) end
                            if findN then table.insert(roles, Enum.LFGRole.Healer) end
                            if findDps then table.insert(roles, Enum.LFGRole.Damage) end
                            tab.roles= roles
                        else
                            tab.roles=nil
                        end
                    end
                    Data_Save()
                end
            end
        end, {stat=stat, index=index, value=i, roles=stats.roles, p_roles=p_stats.roles})

        sub:SetTooltip(function(tooltip, description)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.PaperDoll.StatRole'])
            local find
            if description.data.p_roles then
                for _, roleIndex in pairs(description.data.p_roles) do
                    tooltip:AddLine((WoWTools_L.DEFAULT)..': '..Get_Role_Text(roleIndex))
                    find= true
                end
            end
            if not find then
                tooltip:AddLine(WoWTools_L.NONE)
            end
        end)
    end

    root:CreateDivider()
    for _, primary in pairs({LE_UNIT_STAT_STRENGTH, LE_UNIT_STAT_AGILITY , LE_UNIT_STAT_INTELLECT}) do
        sub=root:CreateRadio(
            format(WoWTools_L.LFG_LIST_CROSS_FACTION, Get_Primary_Text(primary))
            ..(p_stats.primary==primary and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
        function(data)
            local tab= Find_Stats(data.stat, data.index, false) or {}
            return tab and tab.primary==data.value
        end, function(data)
            local tab= Find_Stats(data.stat, data.index, false)
            if tab then
                if not tab.primary or tab.primary~=data.value then
                    tab.primary=data.value
                else
                    tab.primary=nil
                end
                Data_Save()
            end
            return MenuResponse.Refresh
        end, {stat=stat, index=index, value=primary})

        sub:SetTooltip(function(tooltip, description)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.PaperDoll.StatPrimary'])
            local tab= Find_Stats(description.data.stat, description.data.index, true)
            tooltip:AddLine(
                (WoWTools_L.DEFAULT)
                ..': '..
                (Get_Primary_Text(tab and tab.primary) or (WoWTools_L.NONE))
            )
        end)
    end


    if stats.showFunc then
        root:CreateDivider()
        root:CreateTitle('|cnGREEN_FONT_COLOR:showFunc|r')
    end
end























local function Init_Menu(self, root)
    if not self:IsMouseOver() or WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

    local sub


    for _, tab in pairs(AttributesCategory) do
        if tab.stat=='-' then
            root:CreateDivider()
        else
            local index= tab.index
            local stat= tab.stat
            local name= tab.name or WoWTools_TextMixin:CN(_G[stat] or _G['STAT_'..stat]) or stat

            local stats= Find_Stats(stat, index, false) or {}
            local tank, n, dps= Find_Roles(stats.roles)
            local role= format(
                '%s%s%s',
                tank and WoWTools_DataMixin.Icon.TANK or '',
                n and WoWTools_DataMixin.Icon.HEALER or '',
                dps and WoWTools_DataMixin.Icon.DAMAGER or ''
            )
            
            local primary
            if stats.primary and tab.primary and stats.primary~=tab.primary then
                primary=Get_Primary_Text(stats and stats.primary)
            end
            sub=root:CreateCheckbox(
                name..(role or '')..(primary or ''),
            function(data)
                return Find_Stats(data.stat, data.index, false)
            end, function(data)
                if not Find_Stats(data.stat, data.index) then
                    Add_Stat(data.tab)
                else
                    Remove_Stat(data.tab)
                end
                Data_Save()
            end, {stat=stat, index=index, tab=tab, rightText=stats.hideAt, rightColor=GREEN_FONT_COLOR})
            WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.PaperDoll.StatItem'])

            WoWTools_MenuMixin:SetRightText(sub)

            Init_Sub_Menu(self, sub, stat, index, name)
        end
    end


    root:CreateDivider()
    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_PaperDollMixin.addName})


    local clearName= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_L.CLEAR_ALL)
    local tipSub= sub:CreateButton(
        clearName,
    function()
        StaticPopup_Show('WoWTools_OK',
        clearName,
        nil,
        {SetValue=function()
            PAPERDOLL_STATCATEGORIES= {}
            Data_Save()
        end})
        return MenuResponse.Open
    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.PaperDoll.StatClear'])

    local restName= (WoWTools_PaperDollMixin:Save().PAPERDOLL_STATCATEGORIES and '' or '|cff626262')
        ..'|A:uitools-icon-refresh:0:0|a'
        ..(WoWTools_L.TRANSMOGRIFY_TOOLTIP_REVERT)
    local tipSub= sub:CreateButton(
        restName,
    function()
        StaticPopup_Show('WoWTools_OK',
        restName,
        nil,
        {SetValue=function()
            PAPERDOLL_STATCATEGORIES= P_PAPERDOLL_STATCATEGORIES
            WoWTools_PaperDollMixin:Save().PAPERDOLL_STATCATEGORIES=nil
            WoWTools_PaperDollMixin:UpdateStats()
        end})
        return MenuResponse.Open
    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.PaperDoll.StatRevert'])
end






































--CharacterStatsPane
local function Init()
    if WoWTools_PaperDollMixin:Save().notStatusPlus then
        return
    end


    if WoWTools_PaperDollMixin:Save().PAPERDOLL_STATCATEGORIES then
        PAPERDOLL_STATCATEGORIES= WoWTools_PaperDollMixin:Save().PAPERDOLL_STATCATEGORIES
    end


    AttributesCategory={
        {stat='STRENGTH', index=1, name=WoWTools_L.SPEC_FRAME_PRIMARY_STAT_STRENGTH, primary=LE_UNIT_STAT_STRENGTH},--AttributesCategory
        {stat='AGILITY', index=1, name=WoWTools_L.SPEC_FRAME_PRIMARY_STAT_AGILITY, rimary=LE_UNIT_STAT_AGILITY},
        {stat='INTELLECT', index=1, name=WoWTools_L.SPEC_FRAME_PRIMARY_STAT_INTELLECT, primary=LE_UNIT_STAT_INTELLECT},
        {stat='-'},
        {stat='STAMINA', index=1, name= WoWTools_L.STA_LCD},
        {stat='ARMOR', index=1},
        {stat='STAGGER', index=1},
        {stat='MANAREGEN', index=1, name=WoWTools_L.MANA_REGEN},
        {stat='SPELLPOWER', index=1, name=WoWTools_L.STAT_SPELLPOWER},

        {stat='HEALTH', index=1},
        {stat='POWER', index=1, name=WoWTools_L.POWER_TYPE_POWER},
        {stat='ALTERNATEMANA', index=1, name=WoWTools_L.MANA},

        {stat='-'},
    --}
    --local EnhancementsCategory={
        {stat='CRITCHANCE', index=2, name=WoWTools_L.STAT_CRITICAL_STRIKE},
        {stat='HASTE', index=2},
        {stat='MASTERY', index=2},
        {stat='VERSATILITY', index=2},
        {stat='LIFESTEAL', index=2},
        {stat='AVOIDANCE', index=2},
        {stat='SPEED', index=2},
        {stat='DODGE', index=2},
        {stat='PARRY', index=2},
        {stat='BLOCK', index=2},

        {stat='ENERGY_REGEN', index=2},
        {stat='RUNE_REGEN', index=2},
        {stat='FOCUS_REGEN', index=2},

        {stat='MOVESPEED', index=2, name=WoWTools_L.NPE_MOVE},
        {stat='ATTACK_DAMAGE', index=2, name=WoWTools_L.DAMAGE, },
        {stat='ATTACK_AP', index=2,  name=WoWTools_L.STAT_ATTACK_POWER, },
        {stat='ATTACK_ATTACKSPEED', index=2, name=WoWTools_L.ATTACK_SPEED},
    }





    local menu= CreateFrame('DropdownButton', 'WoWToolsPaperDollStatusMenuButton', PaperDollFrame, 'WoWToolsMenu3Template')
    menu.texture= menu:CreateTexture()
    menu.texture:SetSize(18,18)
    menu.texture:SetPoint('CENTER')
    menu.texture:SetAtlas(WoWTools_DataMixin.Player.Sex==Enum.UnitSex.Female and 'charactercreate-gendericon-female-selected' or 'charactercreate-gendericon-male-selected')
    WoWTools_TextureMixin:SetAlphaColor(menu.texture)

    menu:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT', -22, 0)
    menu:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
    menu:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)
    menu.tooltip= WoWTools_PaperDollMixin.addName2..WoWTools_DataMixin.Icon.left

    menu:SetupMenu(Init_Menu)

    Init=function()
        _G['WoWToolsPaperDollStatusMenuButton']:SetShown(not WoWTools_PaperDollMixin:Save().notStatusPlus)
    end
end







function WoWTools_PaperDollMixin:Init_Status()
    Init()
end
