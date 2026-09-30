local function Save()
    return WoWToolsPlusSave['Plus_Bank2']
end


--num 以金为单位
local function Save_Value(num)
    num= num or Save().autoSaveMoney
    if num then
        num= num *10000
        local money= GetMoney()-num
        if money>0 then
            return money--铜
        end
    end
end

local function Save_Text(num)
    local money= Save_Value(num)
    local text=''
    if money then
       text= ' '..WoWTools_DataMixin:MK(math.modf(money/10000), 3)..'|A:Coin-Gold:0:0|a'
    end
    return '|cff00ccff'
            ..(WoWTools_L.DEPOSIT)
            ..text
end

local function Save_Tooltip(tooltip, num)
    local money= Save_Value(num) or 0
    tooltip:AddLine(
        WoWTools_DataMixin.Icon.Player
        ..WoWTools_ColorMixin:SetStringColor(C_CurrencyInfo.GetCoinTextureString(GetMoney()- money))
    )

    tooltip:AddLine(
        '|A:Banker:0:0|a|cff00ccff'..C_CurrencyInfo.GetCoinTextureString((C_Bank.FetchDepositedMoney(Enum.BankType.Account) or 0)+ money)
    )

    tooltip:AddLine(' ')
    tooltip:AddLine(
        (WoWTools_L.DEPOSIT)
        ..(money and '|cnGREEN_FONT_COLOR:' or '|cff606060')
        ..' '
        ..C_CurrencyInfo.GetCoinTextureString(money)
    )
end

--自动存钱
local function Save_Money(num)
    local money= C_Bank.CanDepositMoney(Enum.BankType.Account)
                and Save_Value(num)

    if not money then
        return
    end

    C_Bank.DepositMoney(Enum.BankType.Account, money)

    print(
        WoWTools_BankMixin.addName..WoWTools_DataMixin.Icon.icon2,
        '|A:Banker:0:0|a|cff00ccff'
        ..(WoWTools_L['SELF_CAST_AUTO+DEPOSIT'])
        ..'|r',
        C_CurrencyInfo.GetCoinTextureString(money)
    )

    return true
end


--WITHDRAW = "填充";
local function Out_Value(num)
    num= num or Save().autoOutMoney
    if num then
        num= num *10000
        local bank= C_Bank.FetchDepositedMoney(Enum.BankType.Account) or 0
        local money= num-GetMoney()
        if money>0 and bank>=money then
            return money--铜
        end
    end
end

local function Out_Text(num)
    local money= Out_Value(num)
    local text=''
    if money then
       text= ' '..WoWTools_DataMixin:MK(math.modf(money/10000), 3)..'|A:Coin-Gold:0:0|a'
    end
    return WoWTools_ColorMixin:SetStringColor(
        (WoWTools_L.WITHDRAW)..text
    )
end

local function Out_Tooltip(tooltip, num)
    local money= Out_Value(num) or 0
    tooltip:AddLine(
        WoWTools_DataMixin.Icon.Player
        ..WoWTools_ColorMixin:SetStringColor(C_CurrencyInfo.GetCoinTextureString(GetMoney()+ money))
    )

    tooltip:AddLine(
        '|A:Banker:0:0|a|cff00ccff'
        ..(C_CurrencyInfo.GetCoinTextureString(
            (C_Bank.FetchDepositedMoney(Enum.BankType.Account) or 0)- money
        ))
    )
    tooltip:AddLine(' ')
    tooltip:AddLine(
        (WoWTools_L['WITHDRAW~3'])
        ..(money>0 and '|cnGREEN_FONT_COLOR:' or '|cff606060')
        ..' '
        ..C_CurrencyInfo.GetCoinTextureString(money)
    )
end

--自动填充
local function Out_Money(num)
    local money= C_Bank.CanWithdrawMoney(Enum.BankType.Account)
                and Out_Value(num)

    if not money then
        return
    end

    C_Bank.WithdrawMoney(Enum.BankType.Account, money)

    print(
        WoWTools_BankMixin.addName..WoWTools_DataMixin.Icon.icon2,
        WoWTools_DataMixin.Icon.Player
        ..WoWTools_ColorMixin:SetStringColor(WoWTools_L['SELF_CAST_AUTO+WITHDRAW~2']),
        C_CurrencyInfo.GetCoinTextureString(money)
    )

    return true
end


--存钱
local function Init_Save_Menu(self, root)
    if not C_Bank.CanDepositMoney(Enum.BankType.Account) then
        root:CreateTitle('|cff606060'..(WoWTools_L.DEPOSIT))
        return
    end

    local sub, sub2

--存钱
    local autoSub=root:CreateButton(
        Save_Text(),
    function()
        Save_Money()
        return MenuResponse.Open
    end)
    autoSub:AddInitializer(function(btn)
        btn:SetScript("OnUpdate", function(frame, elapsed)
            frame.elapsed= (frame.elapsed or 0.3) +elapsed
            if frame.elapsed>0.3 then
                frame.elapsed=0
                frame.fontString:SetText(Save_Text())
            end
        end)
        btn:SetScript('OnHide', function(frame)
            frame:SetScript('OnUpdate', nil)
            frame.elapsed=nil
        end)
    end)
    autoSub:SetTooltip(function(tooltip)
        Save_Tooltip(tooltip)
    end)

--自动存钱
    local deposit= Save().autoSaveMoney or 500
    sub=autoSub:CreateCheckbox(
        '|cff00ccff'
        ..(WoWTools_L['SELF_CAST_AUTO+DEPOSIT']),
    function()
        return Save().autoSaveMoney
    end, function()
        Save().autoSaveMoney= not Save().autoSaveMoney and deposit or nil
        self:settings()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Bank.AutoDeposit'])
        tooltip:AddLine(WoWTools_L['OPENING+BANK'])
        if Save().autoSaveMoney then
            Save_Tooltip(tooltip)
        end
    end)

--自定义数量
    --autoSub:CreateSpacer()
    sub=WoWTools_MenuMixin:CreateSlider(autoSub, {
        getValue=function()
            return Save().autoSaveMoney or 500
        end, setValue=function(value)
            if Save().autoSaveMoney then
                Save().autoSaveMoney=value
            end
            deposit= value
            self:settings()
        end,
        name='',
        tooltip=function(tooltip)
            Save_Tooltip(tooltip)
        end,
        minValue=0,
        maxValue=100000,
        step=100,
    })
    sub:AddInitializer(function(btn)
        btn:SetScript('OnUpdate', function(frame, elapsed)
            frame.elapsed= (frame.elapsed or 0.3) +elapsed
            if frame.elapsed>0.3 then
                frame.elapsed=0
                frame:SetEnabled(Save().autoSaveMoney and true or false)
            end
        end)
    end)
    autoSub:CreateSpacer()


--全部存钱
    sub=root:CreateButton(
        '|cff00ccff'
        ..(WoWTools_L['ALL+DEPOSIT~2']),
    function()
        C_Bank.DepositMoney(Enum.BankType.Account, GetMoney())
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        local bank= C_Bank.FetchDepositedMoney(Enum.BankType.Account) or 0
        local bag= GetMoney()
        tooltip:AddLine(
            '|A:Banker:0:0|a|cff00ccff'..C_CurrencyInfo.GetCoinTextureString(bag+ bank)
        )
        tooltip:AddLine(' ')
        tooltip:AddLine(
            (WoWTools_L.DEPOSIT)
            ..' '
            ..C_CurrencyInfo.GetCoinTextureString(bag)
        )
    end)

--存钱 100, 500, 1000, 5000, 10000
    for _, num in pairs({100000,50000, 10000,5000, 1000, 500, 100}) do
        sub2= sub:CreateButton(
            WoWTools_DataMixin:MK(num, 0)
            ..'|A:Coin-Gold:0:0|a',
        function(data)
            Save_Money(data)
            return MenuResponse.Open
        end, num)
        sub2:SetTooltip(function(tooltip, desc)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Bank.DepositKeep'])
            Save_Tooltip(tooltip, desc.data)
        end)
        sub2:AddInitializer(function(btn, desc)
            btn:SetScript("OnUpdate", function(frame, elapsed)
                frame.elapsed= (frame.elapsed or 0.3) +elapsed
                if frame.elapsed>0.3 then
                    frame.elapsed=0
                    if Save_Value(desc.data) then
                        frame.fontString:SetTextColor(0,0.8,1)
                    else
                        frame.fontString:SetTextColor(0.62, 0.62, 0.62)
                    end
                end
            end)
            btn:SetScript('OnHide', function(frame)
                frame:SetScript('OnUpdate', nil)
                frame.elapsed=nil
            end)
        end)
    end

end


--提取
local function Init_Out_Menu(self, root)
    if not C_Bank.CanWithdrawMoney(Enum.BankType.Account) then
        root:CreateTitle('|cff606060'..(WoWTools_L['WITHDRAW~4']))
        return
    end

    local sub, sub2

--提取
    local autoSub=root:CreateButton(
        Out_Text(),
    function()
        Out_Money()
        return MenuResponse.Open
    end)
    autoSub:AddInitializer(function(btn)
        btn:SetScript("OnUpdate", function(frame, elapsed)
            frame.elapsed= (frame.elapsed or 0.3) +elapsed
            if frame.elapsed>0.3 then
                frame.elapsed=0
                frame.fontString:SetText(Out_Text())
            end
        end)
        btn:SetScript('OnHide', function(frame)
            frame:SetScript('OnUpdate', nil)
            frame.elapsed=nil
        end)
    end)
    autoSub:SetTooltip(function(tooltip)
        Out_Tooltip(tooltip)
    end)

--自动提取
    local out= Save().autoOutMoney or 500
    sub=autoSub:CreateCheckbox(
        WoWTools_ColorMixin:SetStringColor(
            WoWTools_L['SELF_CAST_AUTO+WITHDRAW']
        ),
    function()
        return Save().autoOutMoney
    end, function()
        Save().autoOutMoney= not Save().autoOutMoney and out or nil
        self:settings()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Bank.AutoWithdraw'])
        tooltip:AddLine(WoWTools_L['OPENING+BANK'])
        if Save().autoOutMoney then
            Out_Tooltip(tooltip)
        end
    end)

--自定义数量
    --autoSub:CreateSpacer()
    sub=WoWTools_MenuMixin:CreateSlider(autoSub, {
        getValue=function()
            return Save().autoOutMoney or 500
        end, setValue=function(value)
            if Save().autoOutMoney then
                Save().autoOutMoney=value
            end
            out= value
            self:settings()
        end,
        name='',
        tooltip=function(tooltip)
            Out_Tooltip(tooltip)
        end,
        minValue=0,
        maxValue=100000,
        step=100,
    })
    sub:AddInitializer(function(btn)
        btn:SetScript('OnUpdate', function(frame, elapsed)
            frame.elapsed= (frame.elapsed or 0.3) +elapsed
            if frame.elapsed>0.3 then
                frame.elapsed=0
                frame:SetEnabled(Save().autoOutMoney and true or false)
            end
        end)
    end)
    autoSub:CreateSpacer()


--全部提取
    sub=root:CreateButton(
        WoWTools_ColorMixin:SetStringColor(WoWTools_L['ALL+DEPOSIT']),
    function()
        C_Bank.WithdrawMoney(Enum.BankType.Account, C_Bank.FetchDepositedMoney(Enum.BankType.Account) or 0)
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        local bank= C_Bank.FetchDepositedMoney(Enum.BankType.Account) or 0
        local bag= GetMoney()
        tooltip:AddLine(
            WoWTools_DataMixin.Icon.Player
            ..WoWTools_ColorMixin:SetStringColor(
                C_CurrencyInfo.GetCoinTextureString(bag+bank)
            )
        )
        tooltip:AddLine(' ')
        tooltip:AddLine(
            (WoWTools_L['WITHDRAW~3'])
            ..' '
            ..C_CurrencyInfo.GetCoinTextureString(bank)
        )
    end)

--填充 100, 500, 1000, 5000, 10000
    for _, num in pairs({100000,50000, 10000,5000, 1000, 500, 100}) do
        sub2= sub:CreateButton(
            WoWTools_DataMixin:MK(num, 0)
            ..'|A:Coin-Gold:0:0|a',
        function(data)
            local money= Out_Value(data)
            if money then
                C_Bank.WithdrawMoney(Enum.BankType.Account, money)
            end
            return MenuResponse.Open
        end, num)
        sub2:SetTooltip(function(tooltip, desc)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Bank.WithdrawUpTo'])
            Out_Tooltip(tooltip, desc.data)
        end)
        sub2:AddInitializer(function(btn, desc)
            btn:SetScript("OnUpdate", function(frame, elapsed)
                frame.elapsed= (frame.elapsed or 0.3) +elapsed
                if frame.elapsed>0.3 then
                    frame.elapsed=0
                    if Out_Value(desc.data) then
                        frame.fontString:SetTextColor(PlayerUtil.GetClassColor():GetRGB())
                    else
                        frame.fontString:SetTextColor(0.62, 0.62, 0.62)
                    end
                end
            end)
            btn:SetScript('OnHide', function(frame)
                frame:SetScript('OnUpdate', nil)
                frame.elapsed=nil
            end)
        end)
    end

end


local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    self:set_tooltip()

    if C_Bank.FetchBankLockedReason(Enum.BankType.Account)~=nil
        or not C_Bank.DoesBankTypeSupportMoneyTransfer(Enum.BankType.Account)
    then
        local sub=root:CreateTitle(WoWTools_L.LOCKED)
        sub:SetTooltip(function(tooltip)
            GameTooltip_AddErrorLine(tooltip,
                WoWTools_TextMixin:CN(BankPanelLockPromptMixin:GetBankLockedMessage()),
                true
            )
        end)
        return
    end

    Init_Save_Menu(self, root)
    root:CreateDivider()
    Init_Out_Menu(self, root)

    local sub, sub2

--过滤器
    local num= CountTable(Save().filterSaveMoney or {})
    root:CreateDivider()
    sub=root:CreateButton(
        (WoWTools_L.CALENDAR_FILTERS)
        ..'|r |cnGREEN_FONT_COLOR:#'..num,
    function()
        return MenuResponse.Open
    end)
--我
    sub2=sub:CreateCheckbox(
        WoWTools_UnitMixin:GetPlayerInfo(nil, WoWTools_DataMixin.Player.GUID, nil, {faction=WoWTools_DataMixin.Player.Faction, reName=true,reRealm=true, level=WoWTools_DataMixin.Player.Level}),
    function()
        return Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID]
    end, function()
        Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID]= not Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID] and true or nil
        self:settings()
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Bank.MoneyFilter'])
--战团
    for guid, wow in pairs(WoWToolsPlus_WoWDate) do
        if guid~=WoWTools_DataMixin.Player.GUID
            and wow.region== WoWTools_DataMixin.Player.Region
            and wow.battleTag== WoWTools_DataMixin.Player.BattleTag
        then
            sub2=sub:CreateCheckbox(
                WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {faction=wow.faction, reName=true,reRealm=true, level=wow.level}),
            function(data)
                return Save().filterSaveMoney[data.guid]
            end, function(data)
                Save().filterSaveMoney[data.guid]= not Save().filterSaveMoney[data.guid] and true or nil
            end, {guid=guid})
            WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Bank.MoneyFilter'])
        end
    end
    sub:CreateDivider()
--勾选所有
    sub2=sub:CreateCheckbox(
        WoWTools_L.EVENTTRACE_BUTTON_ENABLE_FILTERS,
    function()
        for guid in pairs(WoWToolsPlus_WoWDate) do
            if not Save().filterSaveMoney[guid] then
                return false
            end
        end
        return true
    end, function()
        Save().filterSaveMoney={}
        for guid, wow in pairs(WoWToolsPlus_WoWDate) do
            if wow.region== WoWTools_DataMixin.Player.Region and wow.battleTag== WoWTools_DataMixin.Player.BattleTag then
                Save().filterSaveMoney[guid]= true
            end
        end
        self:settings()
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Bank.MoneyFilterAll'])
--撤选所有
    sub2=sub:CreateCheckbox(
        WoWTools_L.EVENTTRACE_BUTTON_DISABLE_FILTERS,
    function()
        for _ in pairs(Save().filterSaveMoney) do
            return false
        end
        return true
    end, function()
        Save().filterSaveMoney={}
        self:settings()
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Bank.MoneyFilterNone'])
    WoWTools_MenuMixin:SetScrollMode(sub)



--打开选项界面
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_BankMixin.addName})
end


local function Init()
    local btn= WoWTools_ButtonMixin:Menu(BankPanel.MoneyFrame, {size=24,icon='hide', name='WoWToolsPlusBankMoneyButton'})
    btn.texture= btn:CreateTexture(nil, 'BORDER')
    btn.texture:SetPoint('CENTER')
    btn.texture:SetSize(24,24)
    btn.texture:SetAtlas('greatVault-whole-normal')

    btn:SetPoint('RIGHT', BankPanel.MoneyFrame.MoneyDisplay.GoldButton, 'LEFT', -2, 0)

    btn.Text= WoWTools_LabelMixin:Create(btn, {color={r=0, g=0.8, b=1}})
    btn.Text:SetPoint('TOPRIGHT', btn, 'TOPLEFT')
    btn.Text2= WoWTools_LabelMixin:Create(btn, {color={r=0.62, g=0.62, b=0.62}})
    btn.Text2:SetPoint('BOTTOMRIGHT', btn, 'BOTTOMLEFT')


    function btn:set_tooltip()
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        GameTooltip:AddLine(
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_L['OPENING+BANK'])
        )
        GameTooltip:AddLine(' ')

        GameTooltip:AddLine(
            WoWTools_DataMixin.Icon.Player
            ..WoWTools_ColorMixin:SetStringColor(WoWTools_L.CALENDAR_FILTERS)
            ..': '..WoWTools_TextMixin:GetYesNo(Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID])
        )
        GameTooltip:AddLine(' ')

        GameTooltip:AddLine(
            '|cff00ccff'
            ..(WoWTools_L.DEPOSIT)
            ..' |cnGREEN_FONT_COLOR:>|r '
            ..(Save().autoSaveMoney
                and WoWTools_DataMixin:MK(Save().autoSaveMoney, 3)..'|A:Coin-Gold:0:0|a'
                or WoWTools_TextMixin:GetEnabeleDisable(false)
            )
        )

        GameTooltip:AddLine(
            WoWTools_ColorMixin:SetStringColor(WoWTools_L['WITHDRAW~3'])
            ..' |cnGREEN_FONT_COLOR:>|r '
            ..(Save().autoOutMoney
                and WoWTools_DataMixin:MK(Save().autoOutMoney, 3)..'|A:Coin-Gold:0:0|a'
                or WoWTools_TextMixin:GetEnabeleDisable(false)
            )
        )

        GameTooltip_AddErrorLine(GameTooltip,
            WoWTools_TextMixin:CN(BankPanelLockPromptMixin:GetBankLockedMessage()),
            true
        )

        GameTooltip:Show()
    end
    btn:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltip()
    end)

    btn:SetupMenu(Init_Menu)

    function btn:settings()
        local save, out
        if not Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID] then
            save= Save().autoSaveMoney
            out= Save().autoOutMoney
        end
        self.texture:SetAlpha((save or out) and 1 or 0.5)
        self.texture:SetDesaturated(not (save and out) and true or false)
        self.Text:SetText(save and '|cff00ccff'..WoWTools_DataMixin:MK(save, 3) or '')
        self.Text2:SetText(WoWTools_ColorMixin:SetStringColor(WoWTools_DataMixin:MK(out, 3)))
    end

    WoWTools_DataMixin:Hook(BankPanel.MoneyFrame.DepositButton, 'Refresh', function()
        btn:settings()
    end)
    BankFrame:HookScript('OnShow', function()
        if
            C_Bank.FetchBankLockedReason(Enum.BankType.Account)==nil--锁定
            and C_Bank.DoesBankTypeSupportMoneyTransfer(Enum.BankType.Account)--不可用
            and not Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID]--过滤GUID
            and not IsModifierKeyDown()
        then
            if not Save_Money() then
                Out_Money()
            end
        end
    end)

--提升，有时头像会 覆盖
    BankPanel.MoneyFrame:SetFrameStrata('HIGH')
    Init=function()end
end

function WoWTools_BankMixin:Init_Money_Plus()
    Init()
end