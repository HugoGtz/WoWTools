
local P_Save= {
    saveWhisper=true,
    WhisperTab={},


    type= SLASH_SAY1,
    --text= SAY
    --isWoW=bool,
    numWhisper=0,
}

local M= {}--tabla del módulo (WoWTools_Module)
local addName
local SayButton



--#######
--#######
local function set_numWhisper_Tips()
    SayButton.numWhisper:SetText(M:Save().numWhisper>0 and M:Save().numWhisper or '')
end

local function rest_numWhisper_Tips()
    M:Save().numWhisper=0
    set_numWhisper_Tips()
end

local MaxWhisperMsg= 50--mensajes guardados por contacto (antes sin límite)

local function findWhisper(name, battleTag)
    for index, tab in pairs(M:Save().WhisperTab) do
        if tab.name==name or (battleTag and tab.battleTag==battleTag) then
            return index
        end
    end
end

--BNet: el nombre |K..|k solo vale en esta sesión; buscar el actual por BattleTag
local function Get_BNetName(tab)
    if tab.battleTag then
        for i=1, BNGetNumFriends() do
            local info= C_BattleNet.GetFriendAccountInfo(i)
            if info and info.battleTag==tab.battleTag and info.accountName then
                return info.accountName
            end
        end
    end
    return tab.name
end

local function getWhisper(event, text, name, _, _, _, _, _, _, _, _, _, guid, bnSenderID)
    if not canaccessvalue(text) or not canaccessvalue(name) or not canaccessvalue(guid) then--valores secretos (12.0)
        return
    end
    if WoWTools_DataMixin.Player.Name_Realm~=name and name then
        local type= event:find('INFORM') and true or nil
        local wow= event:find('MSG_BN') and true or nil
        local battleTag
        if wow and canaccessvalue(bnSenderID) and bnSenderID then
            local info= C_BattleNet.GetAccountInfoByID(bnSenderID)
            battleTag= info and info.battleTag
        end
        local index=findWhisper(name, battleTag)
        local tab= {text=text, type=type, player=WoWTools_DataMixin.Player.Name_Realm, time=date('%X')}
        if index then
            local data= M:Save().WhisperTab[index]
            data.guid=guid
            if wow then
                data.name= name--token de la sesión actual
                data.battleTag= battleTag or data.battleTag
            end
            table.insert(data.msg, tab)
            while #data.msg>MaxWhisperMsg do
                table.remove(data.msg, 1)
            end
        else
            table.insert(M:Save().WhisperTab, 1, {name=name, wow=wow, battleTag=battleTag, guid=guid, msg={tab}})
        end
        if not type then
            M:Save().numWhisper= M:Save().numWhisper + 1
            set_numWhisper_Tips()
        end
    end
end


local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2, name, num
    --local isInCombat= InCombatLockdown()

    local chatType={
        {text= WoWTools_L.SAY, type= SLASH_SAY1, type2='SLASH_SAY'},--/s
        {text= WoWTools_L.YELL, type= SLASH_YELL1, type2='SLASH_YELL'},--/p
        {text= WoWTools_L.SLASH_TEXTTOSPEECH_WHISPER, type=SLASH_WHISPER1, type2='SLASH_WHISPER', isWhisper=true,}
    }
    for _, tab in pairs(chatType) do
        tab.rightText=tab.type

        sub=root:CreateCheckbox(
                tab.text
                --..' '
                --..tab.type
                ..(tab.isWhisper and ' '..WoWTools_UnitMixin:GetPlayerInfo('target', nil, nil, {reName=true}) or ''),
        function(data)
                return M:Save().type==data.type

        end, function(data)
            local name2
            if data.isWhisper then
                if UnitIsPlayer('target') and UnitIsFriend('target', 'player') then
                    name2= GetUnitName("target", true)
                end
            end
            WoWTools_ChatMixin:Say(data.type, name2, nil)
            self:settings(data.type, data.text, name2, nil)
        end, tab)

        WoWTools_MenuMixin:SetRightText(sub)

        sub:SetTooltip(function(tooltip, description)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Say.Channel'])
            tooltip:AddLine(description.data.text)
            for i=2, 12 do
                local str=_G[description.data.type2..i]
                if str then
                    if str~=description.data.type then
                        tooltip:AddLine(str..' ')
                    end
                else
                    break
                end
            end
        end)

        sub:AddInitializer(function(button)
            if button.leftTexture1 then
                button.leftTexture1:SetShown(false)
            end
            if button.leftTexture2 then
                button.leftTexture2:SetAtlas('newplayertutorial-icon-mouse-leftbutton')
            end
        end)
    end



    num= #M:Save().WhisperTab
    if num>0 then

        sub2=sub:CreateButton(
            WoWTools_L.CLEAR_ALL,
        function(data)
            StaticPopup_Show('WoWTools_OK',
                (WoWTools_L.CLEAR_ALL)..' |cffffffff #'..data.rightText,
            nil,
            {SetValue=function()
                M:Save().WhisperTab={}
                rest_numWhisper_Tips()
            end})
            return MenuResponse.Open
        end, {rightText=num})

        WoWTools_MenuMixin:SetRightText(sub2)

        sub2:SetTooltip(function(tooltip)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Say.ClearWhispers'])
            tooltip:AddLine(WoWTools_L['Save up to 120 records'])
        end)

        sub:CreateDivider()


        for index, tab in pairs(M:Save().WhisperTab) do
            tab.rightText= index
            tab.rightColor=DISABLED_FONT_COLOR

            local playerName= WoWTools_UnitMixin:GetPlayerInfo(tab.unit, tab.guid, tab.name, {faction=tab.faction, reName=true, reRealm=true})
            playerName= playerName=='' and tab.name or playerName

            local color= WoWTools_UnitMixin:GetColor(tab.unit, tab.guid)
            tab.hex= color:GenerateHexColorMarkup()

            sub2=sub:CreateButton(
                (tab.wow and WoWTools_DataMixin.Icon.wow2 or '')..(playerName or ' '),
            function(data)
                local toName= data.wow and Get_BNetName(data) or data.name
                WoWTools_ChatMixin:Say(nil, toName, data.wow)
                self:settings(SLASH_WHISPER1, WoWTools_L.SLASH_TEXTTOSPEECH_WHISPER, toName, data.wow)
                return MenuResponse.Open
            end, tab)

            WoWTools_MenuMixin:SetRightText(sub2)

            sub2:SetTooltip(function(tooltip, desc)
                local find
                for _, msg in pairs(desc.data.msg) do
                    local player= msg.player and msg.player~=WoWTools_DataMixin.Player.Name_Realm and msg.player

                    if msg.type then
                        tooltip:AddLine((player and '|cnGREEN_FONT_COLOR:' or '|cff626262')..msg.time..' |A:voicechat-icon-textchat-silenced:0:0|a'..msg.text..'|r')
                    else
                        tooltip:AddDoubleLine(
                            desc.data.hex..msg.time,

                            desc.data.hex
                            ..(
                                WoWTools_UnitMixin:GetIsFriendIcon(nil, desc.data.guid, desc.data.name)
                                or '|A:common-icon-rotateright:0:0|a'
                            )
                            ..(WoWTools_UnitMixin:GetRaceIcon(nil, desc.data.guid, nil) or '')
                            ..msg.text.. (player and ' |cnGREEN_FONT_COLOR:*|r' or '')
                        )
                    end
                    find=true
                end
                if find then
                    tooltip:AddLine(' ')
                end
                tooltip:AddLine((WoWTools_L.SLASH_TEXTTOSPEECH_WHISPER)..WoWTools_DataMixin.Icon.left)
                rest_numWhisper_Tips()
            end)

            sub2:CreateButton(
                WoWTools_L.SHOW,
            function(data)
                local text= '|cff626262'
                        ..WoWTools_DataMixin.Player.Name_Realm
                        ..'|r'..WoWTools_DataMixin.Icon.Player
                        ..' <-> '
                        ..(WoWTools_UnitMixin:GetRaceIcon(nil, data.guid, nil) or '')
                        ..data.hex
                        ..data.name
                        ..'|r|n|n'

                local playerList={}
                for _, msg in pairs(data.msg) do
                    text= text and text..'|n' or ''
                    if msg.type then
                        text= text..'|cff626262'..msg.time..' '..(msg.player or WoWTools_DataMixin.Player.Name_Realm)..': '..msg.text..'|r'
                        if msg.player and msg.player~=WoWTools_DataMixin.Player.Name_Realm then
                            playerList[msg.player]= true
                            text=text..' |cnGREEN_FONT_COLOR:*|r'
                        end
                    else
                        text= text..data.hex..msg.time..' '..data.name..': '..msg.text..'|r'
                        if msg.player and msg.player~=WoWTools_DataMixin.Player.Name_Realm then
                            playerList[msg.player]= true
                            text=text..' ->|cnGREEN_FONT_COLOR:'..msg.player'|r'
                        end
                    end
                end

                for player in pairs(playerList) do
                    text=text
                        ..'|n|cff626262'
                        ..player..'|r <-> '
                        ..(WoWTools_UnitMixin:GetRaceIcon(nil, data.guid, nil) or '')
                        ..data.hex
                        ..data.name
                        ..'|r|n'
                end
                WoWTools_TextMixin:ShowText({text}, WoWTools_UnitMixin:GetPlayerInfo(nil, data.guid, data.name, {reName=true, reRealm=true}))
                return MenuResponse.Open
            end, tab)


            sub2:CreateDivider()
            sub2:CreateButton(WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2,
            function(data)
                local findIndex= findWhisper(data.name)
                if findIndex then
                    table.remove(M:Save().WhisperTab, findIndex)--=nil dejaba un hueco en la lista
                    WoWTools_Print(
                        addName..WoWTools_DataMixin.Icon.icon2,
                        '|cnGREEN_FONT_COLOR:'..(WoWTools_L.REMOVE)..'|r',
                        WoWTools_UnitMixin:GetLink(data.unit, data.guid, data.name, false)
                    )
                else
                    WoWTools_Print(
                        addName..WoWTools_DataMixin.Icon.icon2,
                        '|cff626262'..(WoWTools_L.TAXI_PATH_UNREACHABLE)..'|r',
                        WoWTools_UnitMixin:GetLink(data.unit, data.guid, data.name, false)
                    )
                end
                return MenuResponse.Open
            end, tab)
        end
--SetScrollMod
        WoWTools_MenuMixin:SetScrollMode(sub)
    end




    root:CreateDivider()

    local numOline, onlineList= 0, {}
    local playerMapNamp=WoWTools_MapMixin:GetUnit('player')
    for i=1 ,BNGetNumFriends() do
        local wow=C_BattleNet.GetFriendAccountInfo(i)
        if wow and wow.gameAccountInfo and wow.gameAccountInfo.isOnline and wow.accountName then
            numOline=numOline+1
            table.insert(onlineList, wow)
        end
    end
    sub=root:CreateButton(
        WoWTools_DataMixin.Icon.net2..(WoWTools_L.COMMUNITY_COMMAND_BATTLENET),--..' '..numOline,
    function()
        ToggleFriendsFrame(1)
    end, {rightText=numOline})

    WoWTools_MenuMixin:SetRightText(sub)

    local maxLevel= GetMaxLevelForLatestExpansion()
    for index, wow in pairs(onlineList) do
        local color, icon= select(2, FriendsFrame_GetBNetAccountNameAndStatus(wow, true))
        local text=wow.accountName

        text= color and color:WrapTextInColorCode(wow.accountName) or text

        local gameAccountInfo= wow.gameAccountInfo
        local zone
        if gameAccountInfo then
            if gameAccountInfo.clientProgram then
                local atlas=BNet_GetBattlenetClientAtlas(gameAccountInfo.clientProgram)
                if atlas then
                    text='|A:'..atlas..':0:0|a'.. text
                end
            end
            if gameAccountInfo.playerGuid then
                text= text..WoWTools_UnitMixin:GetPlayerInfo(nil, gameAccountInfo.playerGuid, nil, {faction=gameAccountInfo.factionName, reName=true, reRealm=true,})
                if gameAccountInfo.areaName then
                    if gameAccountInfo.areaName==playerMapNamp then
                        text=text..'|A:poi-islands-table:0:0|a'
                    end
                    zone= gameAccountInfo.areaName
                end
            end
            if gameAccountInfo.characterLevel and gameAccountInfo.characterLevel~=maxLevel then
                text=text ..' |cff00ff00'..gameAccountInfo.characterLevel..'|r'
            end
        end
        icon= icon and format('|T%d:0|t', icon) or ''

        sub2=sub:CreateButton(
            icon..text,
        function(data)
            WoWTools_ChatMixin:Say(nil, data.name, true)
            self:settings(nil, WoWTools_L.COMMUNITY_COMMAND_BATTLENET, data.name, true)
            return MenuResponse.Open
        end, {name=wow.accountName, note=wow.note, zone=zone, rightText=index, rightColor=DISABLED_FONT_COLOR})

        WoWTools_MenuMixin:SetRightText(sub2)

        sub2:SetTooltip(function(tooltip, description)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Say.BNetFriend'])
            tooltip:AddLine(description.data.note)
            tooltip:AddLine(WoWTools_TextMixin:CN(description.data.zone))
        end)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)

    root:CreateDivider()
    WoWTools_ChatMixin:Open_SettingsPanel(root, addName)
end


--####
--####
local Init= WoWTools_Once(function()
    SayButton.typeText=WoWTools_LabelMixin:Create(SayButton, {color=true})--10, nil, nil, true)
    SayButton.typeText:SetPoint('BOTTOM',0,2)

    SayButton.numWhisper=WoWTools_LabelMixin:Create(SayButton, {color={r=0,g=1,b=0}})
    SayButton.numWhisper:SetPoint('TOPRIGHT',-3, 0)

    SayButton.texture:SetAtlas('common-icon-speak')--transmog-icon-chat')

    function SayButton:set_tooltip()
        self:set_owner()
        if M:Save().type or M:Save().text or M:Save().name then
            local name
            if M:Save().type==SLASH_WHISPER1 then
                name= GetUnitName('target', true)
            elseif M:Save().name then
                name= M:Save().isWoW and WoWTools_DataMixin.Icon.net2..'|cff28a3ff'..M:Save().name or M:Save().name
            end
            GameTooltip:AddDoubleLine((M:Save().text or '')..(M:Save().type and ' '..M:Save().type or ''),(name or '')..WoWTools_DataMixin.Icon.left)
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_L['SLASH_TEXTTOSPEECH_WHISPER+AUCTION_HOUSE_QUANTITY_LABEL'], M:Save().numWhisper)
        GameTooltip:Show()
    end

    SayButton:SetupMenu(Init_Menu)

    function SayButton:set_OnMouseDown()
        if M:Save().type or M:Save().name then
            local name, wow= M:Save().name, M:Save().isWoW
            if M:Save().type==SLASH_WHISPER1 and UnitIsPlayer('target') then
                name= GetUnitName('target', true)
                wow= false
            end
            WoWTools_ChatMixin:Say(M:Save().type, name, wow)
        else
            return true
        end
    end

    function SayButton:settings(type, text, name, isWoW)
        M:Save().type= type
        M:Save().text= text
        M:Save().name= name
        M:Save().isWoW= isWoW

        if type and text:find('%w') then
            text=type:gsub('/','')
        else
            text=WoWTools_TextMixin:sub(text, 1, 3)
        end

        self.typeText:SetText(text)
    end


    SayButton:settings(M:Save().type, M:Save().text, M:Save().name, M:Save().isWoW)
    set_numWhisper_Tips()
end)


--###########
--###########
local panel= CreateFrame('Frame')
--Marco propio: susurros (se registran en onEnable)
panel:SetScript("OnEvent", function(_, event, arg1, arg2, ...)
    if event=='CHAT_MSG_WHISPER_INFORM' or event=='CHAT_MSG_WHISPER' or event=='CHAT_MSG_BN_WHISPER' or event=='CHAT_MSG_BN_WHISPER_INFORM' then
        getWhisper(event, arg1, arg2, ...)
    end
end)



WoWTools_Module:Register({
    key= 'ChatButton_Say', name= 'SAY', icon= 'transmog-icon-chat',
    parent= 'ChatButton', defaults= P_Save, mixin= M,
    options= {
        {type='section', text='GENERAL'},
        --Canal del botón (clic izquierdo): el mismo campo que eligen las casillas del menú
        {type='dropdown', key='type', text='Default channel', tooltip='Tip.Say.DefaultChannel',
            values= {
                {value=SLASH_SAY1, text='SAY'},
                {value=SLASH_YELL1, text='YELL'},
                {value=SLASH_WHISPER1, text='Whisper target'},
            },
            get= function(save)
                if save.type==SLASH_SAY1 or save.type==SLASH_YELL1 then
                    return save.type
                end
                return SLASH_WHISPER1--susurro al objetivo o a un contacto
            end,
            set= function(save, value)
                local text= value==SLASH_SAY1 and WoWTools_L.SAY
                    or value==SLASH_YELL1 and WoWTools_L.YELL
                    or WoWTools_L.SLASH_TEXTTOSPEECH_WHISPER
                if SayButton then
                    SayButton:settings(value, text, nil, nil)
                else
                    save.type, save.text, save.name, save.isWoW= value, text, nil, nil
                end
            end,
        },
        {type='button', key='clearWhispers', text='Whisper history', buttonText='CLEAR_ALL', tooltip='Tip.Say.ClearWhispers',
            confirm='CLEAR_ALL',
            func= function(_, save)
                save.WhisperTab={}
                if SayButton then
                    rest_numWhisper_Tips()
                else
                    save.numWhisper=0
                end
            end,
        },
    },
    onEnable= function()
        M:Save().text= M:Save().text or (WoWTools_L.SAY)

        addName= M.addName
        SayButton= WoWTools_ChatMixin:CreateButton('Say', addName)

        if SayButton then
            panel:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
            panel:RegisterEvent("CHAT_MSG_WHISPER")
            panel:RegisterEvent("CHAT_MSG_BN_WHISPER")
            panel:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")

            if #M:Save().WhisperTab>120 then
                for i=121, #M:Save().WhisperTab do
                    M:Save().WhisperTab[i]=nil
                end
            end
            for _, tab in pairs(M:Save().WhisperTab) do--recortar historiales antiguos
                if type(tab.msg)=='table' then
                    while #tab.msg>MaxWhisperMsg do
                        table.remove(tab.msg, 1)
                    end
                end
            end

            Init()
        end
    end,
})
