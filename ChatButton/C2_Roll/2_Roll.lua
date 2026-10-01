local P_Save={
    autoClear=true,
    save={},
}

local M= {}--tabla del módulo (WoWTools_Module)
local addName
local RollButton
local RollTab={}

local panel= CreateFrame('Frame')

local RANDOM_ROLL_RESULT= WoWTools_TextMixin:Magic(RANDOM_ROLL_RESULT)


--local MaxPlayer, MinPlayer


local Max, Min
local function findRolled(name)
    for _, tab in pairs(RollTab) do
        if tab.name==name then
            return true
        end
    end
end

















local function setCHAT_MSG_SYSTEM(text)
    if not canaccessvalue(text) or not text then
        return
    end
    local name, roll, minText, maxText=text:match(RANDOM_ROLL_RESULT)
    roll=  roll and tonumber(roll)
    if not (name and roll and minText=='1' and (maxText=='100' or maxText=='1000')) then
        return
    end
    name=name:find('%-') and name or (name..'-'..WoWTools_DataMixin.Player.Realm)
    if not findRolled(name) then
        if not Max or roll>Max then
            if Max then
                Min= (not Min or Min>Max) and Max or Min
            end
            Max=roll
        elseif not Min or Min>roll then
            Min=roll
        end

        RollButton.rightTopText:SetText(Max)

        if Min then
            RollButton.rightBottomText:SetText(Min)
        end
    end

    local faction,guid
    if name==WoWTools_DataMixin.Player.Name_Realm then
        faction= WoWTools_DataMixin.Player.Faction
        guid= WoWTools_DataMixin.Player.GUID
    
    elseif WoWTools_DataMixin.GroupGuid[name] then
        faction= WoWTools_DataMixin.GroupGuid[name].faction
        guid= WoWTools_DataMixin.GroupGuid[name].guid
    end

    table.insert(RollTab, {name=name,
                        roll=roll,
                        date=date('%X'),
                        text=text,
                        guid= guid,
                        faction= faction,
                    })

    if GameTooltip:IsOwned(RollButton) then
        RollButton:set_tooltip()
    end
end












local function get_Save_Max()
    if not M:Save().saveLog then
        return
    end

    local maxTab, max= nil, 0
    for _, tab in pairs(RollTab) do
        if tab.roll and tab.roll>max then
            max= tab.roll
            maxTab= tab
            if max>=100 then
                break
            end
        end
    end
    if maxTab then
        if #M:Save().save>=40 then
            table.remove(M:Save().save, 1)
        end
        table.insert(M:Save().save, maxTab)
    end
end

local function setRest()
    get_Save_Max()
    RollTab={}
    Max, Min= nil, nil
    RollButton.rightBottomText:SetText('')
    RollButton.rightTopText:SetText('')
end



local function setAutoClearRegisterEvent()
    if M:Save().autoClear then
        panel:RegisterEvent('PLAYER_REGEN_DISABLED')
    else
        panel:UnregisterEvent('PLAYER_REGEN_DISABLED')
    end
    RollButton.autoClearTips:SetShown(M:Save().autoClear)
end

















--#####
--#####

local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2

    root:SetScrollMode(20*44)

    sub=root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'..(WoWTools_L.CLEAR_ALL),
    function()
        setRest()
        return MenuResponse.Close
    end, {rightText=#RollTab})
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Roll.Clear'])
        tooltip:AddLine(WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2)
    end)
    WoWTools_MenuMixin:SetRightText(sub)

    sub2=sub:CreateCheckbox(
        '1000',
    function()
        return M:Save().is1000
    end, function()
        M:Save().is1000= not M:Save().is1000 and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Roll.Roll1000'])
        tooltip:AddLine('1-1000')
        tooltip:AddLine('1-100')
    end)
--
    sub2= sub:CreateCheckbox(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_L['SELF_CAST_AUTO+SLASH_STOPWATCH_PARAM_STOP2']),
    function ()
        return M:Save().autoClear
    end, function ()
        M:Save().autoClear= not M:Save().autoClear and true or false
        setAutoClearRegisterEvent()
    end)
    sub2:SetTooltip(function (tooltip)
        GameTooltip_SetTitle(tooltip, WoWTools_L['Entering combat: Clear'])
    end)
    sub2=sub:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_L['SLASH_STOPWATCH_PARAM_STOP2+EVENTTRACE_LOG_HEADER']),
    function()
        M:Save().save={}
        return MenuResponse.CloseAll
    end, {rightText= #M:Save().save})
    WoWTools_MenuMixin:SetRightText(sub2)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Roll.ClearLog'])

    sub2= sub2:CreateCheckbox(
        (WoWTools_L.SAVE)
        .. ' 40 '
        ..(WoWTools_L['AUCTION_HOUSE_QUANTITY_LABEL~3']),
    function()
        return M:Save().saveLog
    end, function()
        M:Save().saveLog= not M:Save().saveLog and true or nil
        panel:set_event()
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Roll.SaveLog'])

    sub:CreateDivider()
    for index, tab in pairs(M:Save().save) do
        sub2= sub:CreateButton(
            '|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t'
            ..HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(tab.roll)
            ..(tab.roll<10 and '  ' or (tab.roll<100 and ' ') or '')
            ..WoWTools_UnitMixin:GetPlayerInfo(tab.unit, tab.guid, tab.name, {reName=true, reRealm=true})..' '..tab.date,
        function(data)
            WoWTools_ChatMixin:Chat(data.text, nil, nil)
            return MenuResponse.Refresh
        end, {text=tab.text, rightText=index})

        sub2:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(desc.data.text)
            GameTooltip_AddHighlightLine(tooltip, '|A:voicechat-icon-textchat-silenced:0:0|a'..(WoWTools_L.SEND_MESSAGE))
        end)
        WoWTools_MenuMixin:SetRightText(sub2)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)


    root:CreateDivider()
    local _tabNew={}
    for index, tab in pairs(RollTab) do
        local header='|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t'
                ..HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(tab.roll)
                ..(tab.roll<10 and '  ' or (tab.roll<100 and ' ') or '')
                ..WoWTools_UnitMixin:GetPlayerInfo(tab.unit, tab.guid, tab.name, {reName=true, reRealm=true})
                ..' '..tab.date
                ..(tab.roll==Max and '|A:auctionhouse-icon-checkmark:0:0|a' or (tab.roll==Min and '|T450905:0|a') or '')

        if not _tabNew[tab.name] then
            _tabNew[tab.name]={
                text=tab.text,
                header= header,
                index=index,
                list={}
            }
        else
            table.insert(_tabNew[tab.name].list, {
                text=tab.text,
                header=header,
            })
        end
    end

    --table.sort no ordena una tabla por nombre: pasarla a array
    local sorted={}
    for _, tab in pairs(_tabNew) do
        table.insert(sorted, tab)
    end
    table.sort(sorted, function(a, b)
        return a.index< b.index
    end)

    for _, tab in ipairs(sorted) do
        sub=root:CreateButton(
            tab.header,
        function(data)
            WoWTools_ChatMixin:Chat(data.text, nil, nil)
            return MenuResponse.Open
        end, {text=tab.text, rightText=#tab.list})
        sub:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(desc.data.text)
            GameTooltip_AddHighlightLine(tooltip, '|A:voicechat-icon-textchat-silenced:0:0|a'..(WoWTools_L.SEND_MESSAGE))
        end)
        WoWTools_MenuMixin:SetRightText(sub)

        for i, list in pairs(tab.list) do
            sub2=sub:CreateButton(
                list.header,
            function(data)
                WoWTools_ChatMixin:Chat(data.text, nil, nil)
                return MenuResponse.Open
            end, {text=list.text, rightText=i})
            sub2:SetTooltip(function(tooltip, desc)
                tooltip:AddLine(desc.data.text)
                GameTooltip_AddHighlightLine(tooltip, '|A:voicechat-icon-textchat-silenced:0:0|a'..(WoWTools_L.SEND_MESSAGE))
            end)
            WoWTools_MenuMixin:SetRightText(sub2)
        end
        WoWTools_MenuMixin:SetScrollMode(sub)
    end

    root:CreateDivider()
    WoWTools_ChatMixin:Open_SettingsPanel(root, addName)

    WoWTools_MenuMixin:SetScrollMode(root)

    _tabNew= nil
end

















--####
--####
local function Init()


    RollButton.texture:SetTexture('Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47')

    RollButton.autoClearTips= RollButton:CreateTexture(nil,'OVERLAY')
    RollButton.autoClearTips:SetPoint('BOTTOMLEFT',4, 4)
    RollButton.autoClearTips:SetSize(12,12)
    RollButton.autoClearTips:SetAtlas('bags-button-autosort-up')

    RollButton.rightBottomText=WoWTools_LabelMixin:Create(RollButton, {color={r=0,g=1,b=0}})
    RollButton.rightBottomText:SetPoint('BOTTOMRIGHT',-2,3)

    RollButton.rightTopText=WoWTools_LabelMixin:Create(RollButton, {color={r=0,g=1,b=0}})
    RollButton.rightTopText:SetPoint('TOPLEFT',2,-3)


    function RollButton:set_tooltip()
        self:set_owner()
        GameTooltip:AddLine(addName..WoWTools_DataMixin.Icon.left..'/roll')
        if #RollTab>0 then
            local _tabNew={}
            for _, tab in pairs(RollTab) do
                if not _tabNew[tab.name] then
                    local icon=tab.roll==Max and '|A:auctionhouse-icon-checkmark:0:0|a' or (tab.roll==Min and '|T450905:0|a') or ''
                    GameTooltip:AddLine(
                        '|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t'
                        ..(tab.roll<10 and '  ' or (tab.roll<100 and ' ') or '')
                        ..HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(tab.roll)
                        ..WoWTools_UnitMixin:GetPlayerInfo(tab.unit, tab.guid, tab.name, {reName=true, reRealm=true})
                        ..' '..tab.date..icon)
                    _tabNew[tab.name]=true
                end
            end
            _tabNew= nil
        end
        GameTooltip:Show()
    end

    function RollButton:set_OnMouseDown()
        if M:Save().is1000 then
            RandomRoll(1, 1000)
        else
            RandomRoll(1, 100)
        end
    end

    RollButton:SetupMenu(Init_Menu)

    setAutoClearRegisterEvent()
end

















function panel:set_event()
    self:UnregisterEvent('PLAYER_LOGOUT')
    if M:Save().saveLog then
        self:RegisterEvent('PLAYER_LOGOUT')
    end
end



--Marco propio: eventos continuos del módulo (no de arranque)
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            get_Save_Max()
        end

    elseif event=='CHAT_MSG_SYSTEM' then
        setCHAT_MSG_SYSTEM(arg1)

    elseif event=='PLAYER_REGEN_DISABLED' then
        setRest()

    end
end)



WoWTools_Module:Register({
    key= 'ChatButton_Roll', name= 'ROLL', icon= 'Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47',
    parent= 'ChatButton', defaults= P_Save, mixin= M, tooltip= 'Tip.Roll.Enable',
    options= {
        {type='section', text='GENERAL'},
        {type='check', key='is1000', text='Roll 1-1000', tooltip='Tip.Roll.Roll1000',
            get= function(save) return save.is1000 end,
            set= function(save, value) save.is1000= value and true or nil end},
        {type='check', key='saveLog', text='Save the last 40 rolls', tooltip='Tip.Roll.SaveLog',
            get= function(save) return save.saveLog end,
            set= function(save, value) save.saveLog= value and true or nil end,
            apply= function() panel:set_event() end},
        {type='button', key='clearLog', text='SLASH_STOPWATCH_PARAM_STOP2+EVENTTRACE_LOG_HEADER', buttonText='SLASH_STOPWATCH_PARAM_STOP2',
            tooltip='Tip.Roll.ClearLog', confirm=true,
            disabled= function(save) return #(save.save or {})==0 end,
            func= function(_, save) save.save={} end},

        {type='section', text='Automations'},
        {type='check', key='autoClear', text='Entering combat: Clear', tooltip='Tip.Roll.AutoClear', automation=true,
            get= function(save) return save.autoClear end,
            set= function(save, value) save.autoClear= value and true or false end,
            apply= function()
                if RollButton and RollButton.autoClearTips then
                    setAutoClearRegisterEvent()
                end
            end},
    },
    onEnable= function()
        addName= M.addName

        RollButton= WoWTools_ChatMixin:CreateButton('Roll', addName)

        if RollButton then
            panel:set_event()
            panel:RegisterEvent('CHAT_MSG_SYSTEM')
            Init()
        end
    end,
})
