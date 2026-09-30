
local P_Save= {
    saveWhisper=true,
    WhisperTab={},


    type= SLASH_SAY1,
    --text= SAY
    --isWoW=bool,
    numWhisper=0,
}

local function Save()
    return WoWToolsPlusSave['ChatButton_Say'] or {}
end

local addName
local SayButton


 local function set_chatBubbles_Tips()
    SayButton.tipBubbles:SetShown(not C_CVar.GetCVarBool("chatBubbles"))
end


--#######
--#######
local function set_numWhisper_Tips()
    SayButton.numWhisper:SetText(Save().numWhisper>0 and Save().numWhisper or '')
end

local function rest_numWhisper_Tips()
    Save().numWhisper=0
    set_numWhisper_Tips()
end

local MaxWhisperMsg= 50--mensajes guardados por contacto (antes sin límite)

local function findWhisper(name, battleTag)
    for index, tab in pairs(Save().WhisperTab) do
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
            local data= Save().WhisperTab[index]
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
            table.insert(Save().WhisperTab, 1, {name=name, wow=wow, battleTag=battleTag, guid=guid, msg={tab}})
        end
        if not type then
            Save().numWhisper= Save().numWhisper + 1
            set_numWhisper_Tips()
        end
    end
end


local function set_InInstance_Disabled_Bubbles()
    if Save().inInstanceBubblesDisabled and not InCombatLockdown() then
        if select(2, IsInInstance())~='none' then
            C_CVar.SetCVar("chatBubbles", '0')
        else
            C_CVar.SetCVar("chatBubbles", '1')
        end
    end
end


local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2, sub3, name, num
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
                return Save().type==data.type

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



    num= #Save().WhisperTab
    if num>0 then

        sub2=sub:CreateButton(
            WoWTools_L.CLEAR_ALL,
        function(data)
            StaticPopup_Show('WoWTools_OK',
                (WoWTools_L.CLEAR_ALL)..' |cffffffff #'..data.rightText,
            nil,
            {SetValue=function()
                Save().WhisperTab={}
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


        for index, tab in pairs(Save().WhisperTab) do
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
                    table.remove(Save().WhisperTab, findIndex)--=nil dejaba un hueco en la lista
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
    sub2=root:CreateCheckbox(WoWTools_L.CHAT_BUBBLES_TEXT, function()
        return C_CVar.GetCVarBool("chatBubbles")
    end, function()
        if not InCombatLockdown() then
            C_CVar.SetCVar("chatBubbles", not C_CVar.GetCVarBool("chatBubbles") and '1' or '0')
        else
            WoWTools_Print(
                addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT
            )
        end
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Say.Bubbles'])
        tooltip:AddLine('C_CVar.SetCVar(\"chatBubbles\")')
    end)

    sub3=sub2:CreateCheckbox(WoWTools_L.SELF_CAST_AUTO, function()
        return Save().inInstanceBubblesDisabled
    end, function()
        Save().inInstanceBubblesDisabled= not Save().inInstanceBubblesDisabled and true or nil
        set_InInstance_Disabled_Bubbles()
    end)

    sub3:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_L.CHAT_BUBBLES_TEXT)
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine((WoWTools_L.AGGRO_WARNING_IN_INSTANCE)..':', WoWTools_TextMixin:GetEnabeleDisable(false))
        tooltip:AddDoubleLine((WoWTools_L.OTHER)..':', WoWTools_TextMixin:GetEnabeleDisable(true))
    end)
end


--####
--####
local function Init()
    SayButton.typeText=WoWTools_LabelMixin:Create(SayButton, {color=true})--10, nil, nil, true)
    SayButton.typeText:SetPoint('BOTTOM',0,2)

    SayButton.tipBubbles= SayButton:CreateTexture(nil, 'OVERLAY')
    SayButton.tipBubbles:SetSize(8, 8)
    SayButton.tipBubbles:SetPoint('TOPLEFT', 3, -0)
    SayButton.tipBubbles:SetAtlas('talents-button-reset')

    SayButton.numWhisper=WoWTools_LabelMixin:Create(SayButton, {color={r=0,g=1,b=0}})
    SayButton.numWhisper:SetPoint('TOPRIGHT',-3, 0)

    SayButton.texture:SetAtlas('common-icon-speak')--transmog-icon-chat')

    function SayButton:set_tooltip()
        self:set_owner()
        if Save().type or Save().text or Save().name then
            local name
            if Save().type==SLASH_WHISPER1 then
                name= GetUnitName('target', true)
            elseif Save().name then
                name= Save().isWoW and WoWTools_DataMixin.Icon.net2..'|cff28a3ff'..Save().name or Save().name
            end
            GameTooltip:AddDoubleLine((Save().text or '')..(Save().type and ' '..Save().type or ''),(name or '')..WoWTools_DataMixin.Icon.left)
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_L['SLASH_TEXTTOSPEECH_WHISPER+AUCTION_HOUSE_QUANTITY_LABEL'], Save().numWhisper)
        GameTooltip:Show()
    end

    SayButton:SetupMenu(Init_Menu)

    function SayButton:set_OnMouseDown()
        if Save().type or Save().name then
            local name, wow= Save().name, Save().isWoW
            if Save().type==SLASH_WHISPER1 and UnitIsPlayer('target') then
                name= GetUnitName('target', true)
                wow= false
            end
            WoWTools_ChatMixin:Say(Save().type, name, wow)
        else
            return true
        end
    end

    function SayButton:settings(type, text, name, isWoW)
        Save().type= type
        Save().text= text
        Save().name= name
        Save().isWoW= isWoW

        if type and text:find('%w') then
            text=type:gsub('/','')
        else
            text=WoWTools_TextMixin:sub(text, 1, 3)
        end

        self.typeText:SetText(text)
    end


    SayButton:settings(Save().type, Save().text, Save().name, Save().isWoW)
    set_chatBubbles_Tips()
    set_numWhisper_Tips()

    Init=function()end
end


--###########
--###########
local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1, arg2, ...)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['ChatButton_Say']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['ChatButton_Say'], P_Save)
            Save().text= Save().text or (WoWTools_L.SAY)
            P_Save=nil

            addName= '|A:transmog-icon-chat:0:0|a'..(WoWTools_L.SAY)
            SayButton= WoWTools_ChatMixin:CreateButton('Say', addName)

            if SayButton then
                self:RegisterEvent("CHAT_MSG_WHISPER_INFORM")
                self:RegisterEvent("CHAT_MSG_WHISPER")
                self:RegisterEvent("CHAT_MSG_BN_WHISPER")
                self:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM")
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                self:RegisterEvent('CVAR_UPDATE')

                if #Save().WhisperTab>120 then
                    for i=121, #Save().WhisperTab do
                        Save().WhisperTab[i]=nil
                    end
                end
                for _, tab in pairs(Save().WhisperTab) do--recortar historiales antiguos
                    if type(tab.msg)=='table' then
                        while #tab.msg>MaxWhisperMsg do
                            table.remove(tab.msg, 1)
                        end
                    end
                end

                Init()
            else
                self:SetScript('OnEvent', nil)
            end
            self:UnregisterEvent(event)
        end

    elseif event=='CHAT_MSG_WHISPER_INFORM' or event=='CHAT_MSG_WHISPER' or event=='CHAT_MSG_BN_WHISPER' or event=='CHAT_MSG_BN_WHISPER_INFORM' then
        getWhisper(event, arg1, arg2, ...)

    elseif event== 'PLAYER_ENTERING_WORLD' then
        set_InInstance_Disabled_Bubbles()

    elseif event=='CVAR_UPDATE' and arg1=='chatBubbles' then
        set_chatBubbles_Tips()
    end
end)