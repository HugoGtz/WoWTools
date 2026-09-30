
local function Save()
    return WoWToolsPlusSave['Plus_Gossip']
end


--https://wago.io/hR_KBVGdK
local PlayerGossipTab = {
        [38054] = {icon=236722, en='Borean Tundra', de='Boreanische Tundra', es='Tundra Boreal', fr='Toundra Boréenne', it='Tundra Boreale', pt='Tundra Boreana', ru='Борейская тундра', ko='북풍의 땅'},--npc 35646
        [38055] = {icon=236781, en='Howling Fjord', de='Der Heulende Fjord', es='Fiordo Aquilonal', fr='Fjord Hurlant', it='Fiordo Echeggiante', pt='Fiorde Uivante', ru='Ревущий фьорд', ko='울부짖는 협만'},
        [38056] = {icon=236817, en='Sholazar Basin', de='Sholazarbecken', es='Cuenca de Sholazar', fr='Bassin de Sholazar', it='Bacino di Sholazar', pt='Bacia Sholazar', ru='Низина Шолазар', ko='숄라자르 분지'},
        [38057] = {icon=236795, en='Icecrown', de='Eiskrone', es='Corona de Hielo', fr='La Couronne de glace', it='Corona di Ghiaccio', pt='Coroa de Gelo', ru='Ледяная Корона', ko='얼음왕관'},
        [38058] = {icon=236834, en='The Storm Peaks', de='Die Sturmgipfel', es='Las Cumbres Tormentosas', fr='Les pics Foudroyés', it='Cime Tempestose', pt='Picos Tempestuosos', ru='Грозовая гряда', ko='폭풍우 봉우리'},

        [42586] = {icon=1060981, en='Spires of Arak', de='Spitzen von Arak', es='Cumbres de Arak', fr='Flèches d’Arak', it='Guglie di Arakk', pt='Agulhas de Arak', ru='Пики Арака', ko='아라크 첨탑'},--81205
        [42587] = {icon=1060985, en='Talador', de='Talador', es='Talador', fr='Talador', it='Talador', pt='Talador', ru='Таладор', ko='탈라도르'},
        [42588] = {icon=1048304, en='Shadowmoon Valley', de='Schattenmondtal', es='Valle Sombraluna', fr='Vallée d’Ombrelune', it='Valle di Torvaluna', pt='Vale da Lua Negra', ru='Долина Призрачной Луны', ko='어둠달 골짜기'},
        [42589] = {icon=1032150, en='Nagrand', de='Nagrand', es='', fr='Nagrand', it='Nagrand', pt='Nagrand', ru='Награнд', ko='나그란드'},
        [42590] = {icon=1046803, en='Gorgrond', de='Gorgrond', es='Gorgrond', fr='Gorgrond', it='Gorgrond', pt='Gorgrond', ru='Горгронд', ko='고르그론드'},
        [42591] = {icon=1031536, en='Frostfire Ridge', de='Frostfeuergrat', es='Cresta Fuego Glacial', fr='Crête de Givrefeu', it='Landa di Fuocogelo', pt='Serra Fogofrio', ru='Хребет Ледяного Огня', ko='서리불꽃 마루'},

        [44982] = {icon=1405803, en='Auto-Hammer', de='Automatikhammer', es='Martillo automático', fr='Auto-marteau', it='Automartello', pt='Martelo Automático', ru='Автоматический молот', ko='자동 망치'},--101462
        [44983] = {icon=1405806, en='Failure Detection Pylon', de='Fehlschlagdetektorpylon', es='Pilón detector de errores', fr='Pylône de détection des échecs', it='Pilone d\'Individuazione Fallimenti', pt='Pilar Detector de Falhas', ru='Пилон для обнаружения проблем', ko='고장 감지 변환기'},
        [44984] = {icon=134279, en='Fireworks', de='Feuerwerk', es='Fuegos artificiales', fr='Feux d’artifice', it='Fuochi d\'Artificio', pt='Fogos de Artifício', ru='Фейерверк', ko='불꽃놀이'},
        [44985] = {icon=351502, en='Snack Table', de='Snacktisch', es='Mesa de merienda', fr='Table de collation', it='Tavolo per snack', pt='Mesa de lanche', ru='Пищевой', ko='스낵 테이블'},
        [44986] = {icon=134144, en='Blingtron 6000', de='Blingtron 6000', es='Joyatrón 6000', fr='Bling-o-tron 6000', it='Orotron 6000', pt='Blingtron 6000', ru='Блескотрон-6000', ko='블링트론 6000'},
        [44987] = {icon=2000841, en='Wormhole', de='Wurmloch', es='Agujero de gusano', fr='Tunnel spatiotemporel', it='Tunnel Spaziotemporale', pt='Buraco de Minhoca', ru='Червоточина', ko='웜홀'},

        [46325] = {icon= 1408998, en='Azsuna', de='Azsuna', es='Azsuna', fr='Azsuna', it='Azsuna', pt='Азсуна', ru='Азсуна', ko='아즈스나'},
        [46326] = {icon= 1409010, en='Val\'sharah', de='Val\'sharah', es='Val\'sharah', fr='Val\'sharah', it='Val\'sharah', pt='Val\'sharah', ru='Валь\'шара', ko='발샤라'},
        [46327] = {icon= 1409000, en='Highmountain', de='Der Hochberg', es='Monte Alto', fr='Haut-Roc', it='Alto Monte', pt='Alta Montanha', ru='Крутогорье', ko='높은산'},
        [46328] = {icon= 1409001, en='Stormheim', de='Sturmheim', es='Tormenheim', fr='Tornheim', it='Stromheim', pt='Trommheim', ru='Штормхейм', ko='스톰하임'},
        [46329] = {icon= 1409002, en='Suramar', de='Suramar', es='Suramar', fr='Suramar', it='Suramar', pt='Suramar', ru='Сурамар', ko='수라마르'},

        [51934] = {icon= 3847780, en='Oribos', de='Oribos', es='Oribos', fr='Oribos', it='Oribos', pt='Oribos', ru='Орибос', ko='오리보스'},
        [51935] = {icon= 3551337, en='Bastion', de='Bastion', es='Bastión', fr='Le Bastion', it='Bastione', pt='Bastião', ru='Бастион', ko='승천의 보루'},
        [51936] = {icon= 3551338, en='Maldraxxus', de='Maldraxxus', es='Maldraxxus', fr='Maldraxxus', it='Maldraxxus', pt='Maldraxxus', ru='말드락서스', ko='말드락서스'},
        [51937] = {icon= 3551336, en='Ardenweald', de='', es='Ardenweald', fr='Sylvarden', it='Selvarden', pt='Ardena', ru='Арденвельд', ko='몽환숲'},
        [51938] = {icon= 3551339, mapID=1525},
        [51939] = {icon= 3257863, en='The Maw', de='Der Schlund', es='Las Fauces', fr='Antre', it='La Fauce', pt='A Gorja', ru='Утроба', ko='나락'},
        [51941] = {icon= 4066373, en='Korthia', de='Korthia', es='Korthia', fr='Korthia', it='Korthia', pt='Korthia', ru='Кортия', ko='코르시아'},
        [51942] = {icon= 4226233, mapID=1970},

        [63907] = {icon= 'lootroll-icon-need', en='Random', de='Zufällig', es='Aleatorio', fr='Aléatoire', it='Casuale', pt='Aleatório', ru='Случайность', ko='무작위로'},
        [63911]  = {icon= 4672500, mapID=2022},
        [63910]  = {icon= 4672498, mapID=2023},
        [63909]  = {icon= 4672495, mapID=2024},
        [63908]  = {icon= 4672499, mapID=2025},
        [108016] = {icon= 4672496, mapID=2151},
        [109715] = {icon= 5140838, mapID=2133},
        [114080] = {icon= 5390645, mapID=2200},
    }


local GossipTextIcon={}


local function Init_Data()
    GossipTextIcon={}

    if Save().not_Gossip_Text_Icon or Save().notGossipPlayerData then
        return
    end

    for gossipID, tab in pairs(PlayerGossipTab) do
        local name
        if tab.mapID then
            local info = C_Map.GetMapInfo(tab.mapID) or {}
            name= info.name
        else
            name=(LOCALE_koKR and tab.ko)
                or (LOCALE_frFR and tab.fr)
                or (LOCALE_deDE and tab.de)
                or (LOCALE_esES and tab.es)
                or (LOCALE_zhTW and tab.tw)
                or (LOCALE_esMX and tab.es)
                or (LOCALE_ruRU and tab.ru)
                or (LOCALE_ptBR and tab.pt)
                or (LOCALE_itIT and tab.it)
                or tab.en
        end
        if name=='' or name==false then
            name= nil
        end
        if name then
            GossipTextIcon[gossipID]= {icon=tab.icon, name=name}
        end
    end


    if WoWTools_SC_Gossip and not C_AddOns.IsAddOnLoaded('WoWTools_Chinese_Scanner') then
        do
            for gossipID, name in pairs(WoWTools_SC_Gossip) do
                if not GossipTextIcon[gossipID] and not WoWToolsPlusPlayerDate['GossipTextIcon'][gossipID] then
                    GossipTextIcon[gossipID]= {name=name}
                end
            end
        end
        WoWTools_SC_Gossip={}
    end
    


    PlayerGossipTab=nil
    Init_Data=function()end
end


local function Init_Menu(_, root)
    local List= _G['WoWToolsGossipTextIconOptionsList']
    if not List then
        return
    end

    local find=false
    for gossipID, tab in pairs(GossipTextIcon) do
        local icon= select(3, WoWTools_TextureMixin:IsAtlas(tab.icon)) or ''
        root:CreateCheckbox(
            icon
            ..'|c'..(tab.hex and tab.hex~='' and tab.hex or 'ffffffff')..(tab.name or '')..'|r '
            ..(WoWToolsPlusPlayerDate['GossipTextIcon'][gossipID] and '|cnGREEN_FONT_COLOR:' or '|cffffffff')
            ..gossipID,

        function(data)
            return List:get_gossipID()==data.gossipID

        end, function(data)
            List:set_date(data.gossipID)

        end, {gossipID=gossipID, tab=tab})

        find=true
    end

    if find then
        WoWTools_MenuMixin:SetScrollMode(root)
    else
        root:CreateTitle(WoWTools_L.NONE)
    end
end


function WoWTools_GossipMixin:Init_Gossip_Data()
    Init_Data()
end



function WoWTools_GossipMixin:GossipData_Menu(frame)
    MenuUtil.CreateContextMenu(frame, function(...)
        Init_Menu(...)
    end)
end



function WoWTools_GossipMixin:Get_GossipData()
    return GossipTextIcon
end