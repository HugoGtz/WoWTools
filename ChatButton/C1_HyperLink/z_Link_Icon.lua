--escapa todos los caracteres mágicos de un patrón Lua (incluidos % y ])
local function EscapePattern(text)
    return (text:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', '%%%0'))
end

--"%s recibe botín: %s." -> "(.-) recibe botín: .+%." (antes %s se tomaba como "espacio" y casi nunca coincidía)
local function FormatToPattern(fmt)
    local first= true
    local pat= fmt:gsub('%%%d?%$?s', '\001')
    pat= EscapePattern(pat)
    pat= pat:gsub('\001', function()
        if first then
            first= false
            return '(.-)'
        end
        return '.+'
    end)
    return pat
end

local LOOT_ITEM =FormatToPattern(LOOT_ITEM)
local IsShowTimestamps
local Size=':0:0'
--DEFAULT_CHAT_FRAME.P_AddMessage= DEFAULT_CHAT_FRAME.AddMessage



local function Get_CompletedIcon(isCompleted)
    return isCompleted and '|A:common-icon-checkmark:0:0|a' or '|A:questlegendary:0:0|a'
end


local ChannelIcon= {
[TRADE]='|A:Banker:0:0|a',

[CHAT_MSG_GUILD]='|A:UI-Achievement-Shield-NoPoints:0:0|a',
[CHAT_MSG_MONSTER_YELL]='|A:BuildanAbomination-32x32:0:0|a',
[CHAT_MSG_PARTY] = '|A:questlog-questtypeicon-group:0:0|a',
[CHAT_MSG_PARTY_LEADER] = '|A:Ping_Marker_Icon_Assist:0:0|a',
[CHAT_MSG_RAID] = '|A:groupfinder-waitdot:0:0|a',
[CHAT_MSG_RAID_LEADER] = '|A:Ping_Map_Whole_Assist_Deprecated:0:0|a',
[CHAT_MSG_RAID_WARNING] = '|A:Ping_Marker_Icon_Threat:0:0|a',

[INSTANCE_CHAT]='|A:Raid:0:0|a',
[INSTANCE_CHAT_LEADER] = '|A:Ping_Marker_Icon_Assist:0:0|a',

}


local function SetChannels(link)
    local name=link:match('%[(.-)]')
    if not name or WoWTools_HyperLink:Save().disabledKeyColor then
        return
    end

    if WoWTools_HyperLink:Save().channels then
        for k, v in pairs(WoWTools_HyperLink:Save().channels) do
            if name:find(k) then
                return link:gsub('%[.-]', v)
            end
        end
    end

    name= name:match('%d+%. (.+)') or name
    name= name:match('%- (.+)') or name:match(':(.+)') or name

    local icon= ChannelIcon[name]
    if icon then
        return icon
    end

    name=WoWTools_TextMixin:sub(WoWTools_TextMixin:CN(name), 2, 6)
    return link:gsub('%[.-]', '['..name..']')
end

local function Set_Realm(link)
    local name
    local split= LinkUtil.SplitLink(link)
    if split then
        name= split:match('player:(.-):')
    end
    name= name or link:match('|Hplayer:.-|h%[|cff......(.-)|r]') or link:match('|Hplayer:.-|h%[(.-)]|h')

    if not name then
        return
    end

    local server= name:match('%-(.+)')
    if name==WoWTools_DataMixin.Player.Name_Realm or name==UnitName('player') then
        return '[|A:auctionhouse-icon-favorite:0:0|a'
            ..WoWTools_ColorMixin:SetStringColor(WoWTools_L.COMBATLOG_FILTER_STRING_ME)
            ..']'
    else
        local text= WoWTools_UnitMixin:GetPlayerInfo(nil, nil, name)
        if server then
            if server== WoWTools_DataMixin.Player.Realm then
                return (text or '')..link:gsub('%-'..EscapePattern(server)..'|r]|h', '|r]|h')--reinos con guion
            else
                return (text or '')..link:gsub('%-'..EscapePattern(server)..'|r]|h',
                    (WoWTools_DataMixin.Player.Realms[server] and '|cnGREEN_FONT_COLOR:' or '|cnDISABLED_FONT_COLOR:')..'*|r|r]|h')
            end
        elseif text then
            return text..link
        end
    end
end

local function Pet(speciesID)
    if speciesID then
        local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
        if numCollected and limit then
            return (
                    numCollected == limit and GREEN_FONT_COLOR_CODE
                    or (numCollected==0 and WARNING_FONT_COLOR_CODE)
                    or YELLOW_FONT_COLOR_CODE
                )
                ..'['..numCollected ..'/'.. limit..']|r'
        end
    end
end
local function Mount(itemID, spellID)
    local mountID= (
        itemID and C_MountJournal.GetMountFromItem(itemID)
        or spellID and C_MountJournal.GetMountFromSpell(spellID)
    )
    if mountID then
        local _, _, icon, _, _, _, _, _, _, _, isCollected =C_MountJournal.GetMountInfoByID(mountID)
        return Get_CompletedIcon(isCollected), icon
    end
end


local function PetType(petType)
    local type=PET_TYPE_SUFFIX[petType]
    if type then
        return '|TInterface\\Icons\\Icon_PetFamily_'..type..Size..'|t'
    end
end


local function Item(link)
    local itemID, _, _, _, icon, classID, subclassID= C_Item.GetItemInfoInstant(link)

    if not itemID then
        return
    end

    local t= WoWTools_HyperLink:CN_Link(link, {itemID=itemID, isName=true})
    t= icon and '|T'..icon..Size..'|t'..t or t
    if classID==2 or classID==4 then
        local lv= WoWTools_ItemMixin:GetItemLevel(link)
        if lv and lv>10 then
            t=t..'['..lv..']'
        end
        local sourceID=select(2,C_TransmogCollection.GetItemInfo(link))
        if sourceID then
            local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
            if sourceInfo then
                if not sourceInfo.isCollected then
                    local hasItemData, canCollect = C_TransmogCollection.PlayerCanCollectSource(sourceID)
                    t=t..(
                        hasItemData and canCollect and
                        '|T132288:0|t'
                        or '|A:transmog-icon-hidden:0:0|a'
                    )
                end
            end
        end
    elseif classID==15 and (subclassID==2 or subclassID==5) then
        if  subclassID==2 then
            local _, _, petType, _, _, _, _, _, _, _, _, _, speciesID=C_PetJournal.GetPetInfoByItemID(itemID)
            t=(PetType(petType) or '')
                ..t
                ..(Pet(speciesID) or '')

        elseif subclassID==5 then
            t= t..(Mount(itemID, nil) or '')
        end

    elseif C_ToyBox.GetToyInfo(itemID) then
        t= t..Get_CompletedIcon(PlayerHasToy(itemID))
    end

    local count= not WoWTools_HyperLink:Save().notShowItemCount and WoWTools_ItemMixin:GetCount(itemID, {notZero=true})
    if count then
        t=t..count
    end

    if t~=link then
        return t
    end
end


local function Spell(link)
    local spellID
    spellID= (C_Spell.GetSpellInfo(link) or {}).spellID

    if not spellID then
        spellID= link:match('Hspell:(%d+)')
        if spellID  then
            spellID= spellID and tonumber(spellID)
        end
    end

    if not spellID then
        return
    end

    local t= WoWTools_HyperLink:CN_Link(link, {spellID=spellID, isName=true})

    local icon= C_Spell.GetSpellTexture(link)
    t= (icon and '|T'..icon..Size..'|t' or '')..t

    t=t..(Mount(nil, spellID) or '')

    if t~=link then
        return t
    end
end

local function PetLink(link)
    local speciesID =link:match('Hbattlepet:(%d+)')
    if not speciesID  then
        return
    end
    local _, icon, petType= C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    return (PetType(petType) or '')
        ..(icon and '|T'..icon..Size..'|t' or '')
        ..WoWTools_HyperLink:CN_Link(link)
        ..(Pet(speciesID) or '')
end


--battlePetAbil : abilityID : maxHealth : power : speed
--|HbattlePetAbil:493:1465:264:301|h[Zoccolata]|h
local function PetAblil(link, petChannel)
    local abilityID=link:match('HbattlePetAbil:(%d+)')
    if not abilityID then
        return
    end
    local abilityID2, _, icon, _, _, _, petType=C_PetBattles.GetAbilityInfoByID(abilityID)
    local cnName= WoWTools_TextMixin:CN(nil, {petAbilityID=abilityID2, isName=true})
    if cnName then
        link= link:gsub('%[.-]', '['..cnName..']')
    end
    if petType then
        if petChannel then
            return PetType(petType)..link
        else
            return (PetType(petType) or '')..'|T'..(icon or 0)..Size..'|t'..link
        end
    elseif cnName then
        return link
    end
end

local function Trade(link)
    local id2=link:match('Htrade:.-:(%d+):')
    if not id2 then
        return
    end

    local icon = C_Spell.GetSpellTexture(id2)

    return (icon and '|T'..icon..Size..'|t' or '')
        ..WoWTools_HyperLink:CN_Link(link)
end

local function Enchant(link)
    local id2=link:match('Henchant:(%d+)')
    if not id2 then
        return
    end
    local icon = C_Spell.GetSpellTexture(id2)
    return (icon and '|T'..icon..Size..'|t' or '')
        ..WoWTools_HyperLink:CN_Link(link)
end

local function Currency(link)
    local info, num, _, _, isMax, canWeek, canEarned, canQuantity= WoWTools_CurrencyMixin:GetInfo(nil, nil, link)
    if not info or not info.iconFileID then
        return
    end
    return
        '|T'..info.iconFileID..Size..'|t'
        ..WoWTools_HyperLink:CN_Link(link)
        ..(isMax and '|cnWARNING_FONT_COLOR:' or ((canWeek or canEarned or canQuantity) and '|cnGREEN_FONT_COLOR:' ) or '|cffffffff')
        ..(num and WoWTools_DataMixin:MK(num,3))
        ..'|r'
        ..(WoWTools_CurrencyMixin:GetAccountIcon(info.currencyID) or '')
end

local function Achievement(link)
    local id2=link:match('Hachievement:(%d+)')
    if not id2 then
        return
    end
    local _, _, _, completed, _, _, _, _, _, icon = GetAchievementInfo(id2)
    return (icon and '|T'..icon..Size..'|t' or '')
        ..WoWTools_HyperLink:CN_Link(link)
        ..Get_CompletedIcon(completed)
end

local function Quest(link)
    local id2=link:match('Hquest:(%d+)')
    if not id2 then
        return
    end
    return (C_QuestLog.IsAccountQuest(id2) and WoWTools_DataMixin.Icon.wow2 or '')
        ..WoWTools_HyperLink:CN_Link(link)
        ..Get_CompletedIcon(C_QuestLog.IsQuestFlaggedCompleted(id2))
end

local function Talent(link)
    local id2=link:match('Htalent:(%d+)')
    if not id2 then
        return
    end
    local _, _, icon, _, _, _, _, _ ,_, known= GetTalentInfoByID(id2)
    return (icon and '|T'..icon..Size..'|t' or '')
        ..WoWTools_HyperLink:CN_Link(link)
        ..Get_CompletedIcon(known)
end

local function Pvptal(link)
    local id2=link:match('Hpvptal:(%d+)')
    if not id2 then
        return
    end
    local _, _, icon, _, _, _, _, _ ,_, known=GetPvpTalentInfoByID(id2)
    return (icon and '|T'..icon..Size..'|t' or '')
        ..WoWTools_HyperLink:CN_Link(link)
        ..Get_CompletedIcon(known)
end


local function Outfit(link)
    local list = C_TransmogCollection.GetItemTransmogInfoListFromOutfitHyperlink(link)
    if not list then
        return
    end
    local co,to=0,0
    for _,v in pairs(list) do
        local appearanceID=v.appearanceID--v.illusionID
        local illusionID=v.illusionID
        if appearanceID and appearanceID>0 then
            local hide=C_TransmogCollection.IsAppearanceHiddenVisual(appearanceID)
            if not hide then
                local has=C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(appearanceID)
                if has then
                    co=co+1
                end
                to=to+1
            end
        end
        if illusionID and illusionID>0 then
            local info = C_TransmogCollection.GetIllusionInfo(illusionID)
            if info then
                if info.isCollected then
                    co=co+1
                end
                to=to+1
            end
        end
    end
    if to>0 then
        if to==co then
            return WoWTools_HyperLink:CN_Link(link)
                ..Get_CompletedIcon(true)
        else
            return WoWTools_HyperLink:CN_Link(link)
                ..(co>0 and YELLOW_FONT_COLOR_CODE or WARNING_FONT_COLOR_CODE)
                ..co..'/'..to..'|r'
        end
    end
end

local function Transmogillusion(link)
    local illusionID=link:match('Htransmogillusion:(%d+)')
    local info= illusionID and C_TransmogCollection.GetIllusionInfo(illusionID)
    if not info then
        return
    end
    return WoWTools_HyperLink:CN_Link(link)
        ..(
            info.isCollected and info.isUsable and '|T132288:0|t'
            or Get_CompletedIcon(info.isCollected)
        )
end

local function TransmogAppearance(link)
    local appearanceID=link:match('Htransmogappearance:(%d+)')
    if appearanceID then
        return WoWTools_HyperLink:CN_Link(link)
            ..Get_CompletedIcon(C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(appearanceID))
    end
end


local function Keystone(link)
    local itemID, _, _, affix1, affix2, affix3, affix4= link:match('Hkeystone:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)')
    return
        '|T'..(select(5, C_Item.GetItemInfoInstant(link)) or 525134)..Size..'|t'
        ..WoWTools_HyperLink:CN_Link(link, {itemID=tonumber(itemID), isName=true})
        ..(WoWTools_HyperLink:GetKeyAffix(link, {affix1, affix2, affix3, affix4}) or '')
end


local function DungeonScore(link)
    local score, guid, itemLv=link:match('|HdungeonScore:(%d+):(.-):.-:%d+:(%d+):')
    local t=WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil)
        ..(score=='0' and '0' or WoWTools_ChallengeMixin:KeystoneScorsoColor(score))
    t=t..WoWTools_HyperLink:CN_Link(link)
    if itemLv and itemLv~='0' then
        t=t..'|A:charactercreate-icon-customize-body-selected:0:0|a'..itemLv
    end
    return t
end

local function Journal(link)
    local journalType, journalID, journalName=link:match('Hjournal:(%d+):(%d+):.-%[(.-)]')
    local type= journalID and journalType and tonumber(journalType)
    if  type then
        if type==2 then
           local sectionID = select(3, EJ_HandleLinkPath(type, journalID))
           if sectionID then
                local info = C_EncounterJournal.GetSectionInfo(sectionID)
                if info and info.abilityIcon then
                    return '|T'..info.abilityIcon..Size..'|t'..WoWTools_HyperLink:CN_Link(link)
                end
           end
        elseif type==1 and journalName then
            local _, encounterID = EJ_HandleLinkPath(type, journalID)
            for index=1,9 do
                local _, name, _, _, iconImage = EJ_GetCreatureInfo(index, encounterID)
                if name and iconImage then
                    if name==journalName then
                        return '|T'..iconImage..Size..'|t'..WoWTools_HyperLink:CN_Link(link)
                    end
                else
                    break
                end
            end
        elseif type==0 then--Instance
            local buttonImage2 = select(6, EJ_GetInstanceInfo(journalID))
            if buttonImage2 then
                return '|T'..buttonImage2..Size..'|t'..WoWTools_HyperLink:CN_Link(link)
            end
        end
    end
end

local function Instancelock(link)
    local guid, InstanceID, DifficultyID=link:match('Hinstancelock:(.-):(%d+):(%d+):')
    local t=WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil)..WoWTools_HyperLink:CN_Link(link)
    if DifficultyID and InstanceID then
        local name= WoWTools_MapMixin:GetDifficultyColor(nil, tonumber(DifficultyID)) or GetDifficultyInfo(DifficultyID)
        if name then--[[|Hjournal:0:320:5|h[Terrazza dell'Eterna Primavera]|h]]
            return t..'|Hjournal:0:'..InstanceID..':'..DifficultyID..'|h['..name..']|h'
        end
    end
end

--"|cffffff00|Hperksactivity:6|h[Completa 5 spedizioni Mitiche+]|h|r"
local function Perksactivity(link)
    local perksActivityID, name
    perksActivityID, name= link:match('|Hperksactivity:(%d+)|h%[(.+)]|h')
    perksActivityID= perksActivityID and tonumber(perksActivityID)
    if not perksActivityID or not name then
        return
    end

    local t=link
    local cnName= WoWTools_TextMixin:CN(name)
    if cnName and name~=cnName then
        t= t:gsub('|h%[(.+)]|h', '|h['..cnName..']|h')
    end

    local info= C_PerksActivities.GetPerksActivityInfo(perksActivityID)
    if info then
        t= t..Get_CompletedIcon(info.completed)
    end

    if t and t~=link then
        return t
    end
end

local function TransmogSet(link)
    local t= WoWTools_HyperLink:CN_Link(link)
    local setID=link:match('transmogset:(%d+)')
    local info= setID and C_TransmogSets.GetSetPrimaryAppearances(setID)
    if not info then
        return
    end
    local n,to=0,0
    for _,v in pairs(info) do
        to=to+1
        if v.collected then
            n=n+1
        end
    end
    if to>0 then
        if n==to then
            t= t..Get_CompletedIcon(true)
        else
            t= t..(n==0 and WARNING_FONT_COLOR_CODE or YELLOW_FONT_COLOR_CODE)..n..'/'..to..'|r'
        end
    end
    if t~=link then
        return t
    end
end

local function setMount(link)
    local spellID= link:match('mount:(%d+)')
    local mount, icon= Mount(nil, spellID)
    if mount then
        return (icon and '|T'..icon..Size..'|t' or '')..WoWTools_HyperLink:CN_Link(link)..mount
    end
end

--|cffffff00|Hworldmap:84:7222:2550|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a Map Pin Location]|h|r
local function Waypoint(text)
    local uiMapID= WoWTools_WorldMapMixin:GetMapID()
    if uiMapID and C_Map.CanSetUserWaypointOnMap(uiMapID) then
        local x, y= text:match('(%d+%.%d%d) (%d+%.%d%d)')
        if x and y then
            return '|Hworldmap:'..uiMapID..':'..x:gsub('%.','')..':'..y:gsub('%.','')..'|h['..text..']|h'
        end
    end
end
--return '|cffffff00|Hworldmap:'..uiMapID..':'..x:gsub('%.','')..'0:'..y:gsub('%.','')..'0|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a'..text..']|h|r'




local function ClubFinder(link)
    local clubFinderGUID= link:match('|HclubFinder:(.-)|h%[')
    local clubInfo = clubFinderGUID and C_ClubFinder.GetRecruitingClubInfoFromFinderGUID(clubFinderGUID)
    if canaccesstable(clubInfo) and clubInfo then
        return
            (clubInfo.isGuild and '|A:hud-microbutton-Guild-Banner:0:0|a' or '')
            ..(clubInfo.isCrossFaction and '|A:CrossedFlags:0:0|a' or '')
            ..link
    end
end
local function New_AddMessage(self, s, ...)
    --Texto secreto (12.0), con |K (BNet) o vacío: pasarlo sin tocar. Antes se descartaba y el mensaje desaparecía
    if not s or WoWTools_TextMixin:CanText(s) then
        return self.P_AddMessage(self, s, ...)
    end

    local petChannel=s:find('|Hchannel:.-'..PET_BATTLE_COMBAT_LOG..']|h') and true or false

    s=s:gsub('|Hchannel:.-]|h', SetChannels)

    s=s:gsub('|Hitem:.-]|h',Item)
    s=s:gsub('|Hspell:.-]|h',Spell)
    s=s:gsub('|Hmount:.-]|h',setMount)

    s=s:gsub('|Hbattlepet:.-]|h',PetLink)
    s=s:gsub('|HbattlePetAbil:.-]|h',function(link) return PetAblil(link, petChannel) end)

    s=s:gsub('|Htrade:.-]|h', Trade)
    s=s:gsub('|Henchant:.-]|h', Enchant)
    s=s:gsub('|Hcurrency:.-]|h', Currency)
    s=s:gsub('|Hachievement:.-]|h', Achievement)
    s=s:gsub('|Hquest:.-]|h', Quest)
    s=s:gsub('|Htalent:.-]|h', Talent)
    s=s:gsub('|Hpvptal:.-]|h', Pvptal)

    s=s:gsub('|Houtfit:.-]|h', Outfit)
    s=s:gsub('|Htransmogillusion:.-]|h', Transmogillusion)
    s=s:gsub('|Htransmogappearance:.-]|h', TransmogAppearance)
    s=s:gsub('|Htransmogset:.-]|h', TransmogSet)

    s=s:gsub('|Hkeystone:.-]|h', Keystone)
    s=s:gsub('|HdungeonScore:.-]|h', DungeonScore)
    s=s:gsub('|Hjournal:.-]|h', Journal)
    s=s:gsub('|Hinstancelock:.-]|h', Instancelock)

    s=s:gsub('|Hperksactivity:.-]|h', Perksactivity)
    --s=s:gsub('|Hhousing:.-]|h', Housing)

    s=s:gsub('|HclubFinder:.-]|h', ClubFinder)
    --s=s:gsub('|HclubTicket:.-]|h', ClubTicket)

    if not WoWTools_HyperLink:Save().notShowMapPin then
        s=s:gsub('(%d+%.%d%d %d+%.%d%d)', Waypoint)
    end


    if not WoWTools_HyperLink:Save().notShowPlayerInfo then
        s=s:gsub('|Hplayer:.-]|h', Set_Realm)
        if not IsShowTimestamps then
            local unitName= s:match(LOOT_ITEM)
            if unitName and unitName~='' then
                if unitName==UnitName('player') or unitName==YOU then
                    s=s:gsub(EscapePattern(unitName), '[|A:auctionhouse-icon-favorite:0:0|a'..WoWTools_ColorMixin:SetStringColor(WoWTools_L.COMBATLOG_FILTER_STRING_ME)..']')
                else
                    local unitLink= WoWTools_UnitMixin:GetLink(nil, nil, unitName, false)
                    if unitLink then
                        s=s:gsub(EscapePattern(unitName), function() return unitLink end)
                    end
                end
            end
        end
    end

    if not WoWTools_HyperLink:Save().disabledKeyColor then
        for k in pairs(WoWToolsPlusPlayerDate['HyperLinkColorText']) do
            if type(k)=='string' and k~='' then
                --palabra literal: con ( [ % - . daba "malformed pattern" y el chat dejaba de mostrarse
                s=s:gsub(EscapePattern(k), function(m) return '|cnGREEN_FONT_COLOR:'..m..'|r' end)
            end
        end
    end

    s= s:gsub(CHAT_SAY_SEND, '|A:transmog-icon-chat:0:0|a ')

    return self.P_AddMessage(self, s, ...)
end


local function Set_AddMessage(frame, enable)
    if not frame then
        return
    end

    if enable then
        if not frame.P_AddMessage then
            frame.P_AddMessage= frame.AddMessage
        end
        frame.AddMessage= New_AddMessage
    else
        if frame.P_AddMessage then
            frame.AddMessage= frame.P_AddMessage
        end
    end
end



local function Set_HyperLlinkIcon()
    local enable= WoWTools_HyperLink:Save().linkIcon and not C_SocialRestrictions.IsChatDisabled()

    for i = 3, NUM_CHAT_WINDOWS do
        Set_AddMessage(_G["ChatFrame"..i], enable)
    end

    Set_AddMessage(DEFAULT_CHAT_FRAME, enable)

    local btn= WoWTools_ChatMixin:GetButtonForName('HyperLink')
    if btn then
        btn.texture:SetAtlas(enable and 'orderhalltalents-done-glow' or 'voicechat-icon-STT-on')
        btn.texture:SetDesaturated(not enable)
    end
end


local function Init()
    IsShowTimestamps= C_CVar.GetCVar('showTimestamps')~='none'

    EventRegistry:RegisterFrameEventAndCallback("CVAR_UPDATE", function(_, arg1, arg2)
        if arg1=='showTimestamps' then
            IsShowTimestamps= arg2~='none'
        end
    end)

    WoWTools_DataMixin:Hook('ChatConfigFrame_OnChatDisabledChanged', function()
        Set_HyperLlinkIcon()
    end)

    Set_HyperLlinkIcon()

    Init=function()
        Set_HyperLlinkIcon()
    end
end


function WoWTools_HyperLink:Init_Link_Icon()
    self:Link_Icon_Settings()
    Init()
end

function WoWTools_HyperLink:Link_Icon_Settings()
    local s= WoWTools_HyperLink:Save().iconSize or 0
    s = s<8  and 0 or s
    Size= ':'..s..':'..s
end

