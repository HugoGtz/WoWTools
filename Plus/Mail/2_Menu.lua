local function Save()
    return WoWToolsPlusSave['Plus_Mail']
end





local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    
    local sub

    root:CreateTitle(WoWTools_L.INBOX)
    local tipSub= root:CreateCheckbox(
        (WoWTools_L.INBOX)..' Plus',
    function()
        return not Save().hide
    end, function()
        Save().hide= not Save().hide and true or nil
        WoWTools_MailMixin:Init_InBox()--收信箱，物品，提示
    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.Mail.InBoxPlus'])


    root:CreateTitle(WoWTools_L.SENDMAIL)

    sub=root:CreateCheckbox(
        WoWTools_L.WHO_LIST,
    function()
        return not Save().hideSendNameList
    end, function()
        Save().hideSendNameList= not Save().hideSendNameList and true or nil
        WoWTools_MailMixin:Init_Send_Name_List()--收件人，列表
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Mail.NameList'])


    sub=root:CreateCheckbox(
        WoWTools_L['Recipient history'],
    function()
        return not Save().hideHistoryList
    end, function()
        Save().hideHistoryList= not Save().hideHistoryList and true or nil
        WoWTools_MailMixin:Init_Send_History_Name()--收件人，历史记录
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Mail.History'])


    sub=root:CreateCheckbox(
        WoWTools_L['ITEMS+SETTINGS_KEYBINDINGS_LABEL'],
    function()
        return not Save().hideItemButtonList
    end, function()
        Save().hideItemButtonList= not Save().hideItemButtonList and true or nil
        WoWTools_MailMixin:Init_Fast_Button()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Mail.FastButtons'])

    sub=root:CreateCheckbox(
        WoWTools_L['Auto switch to Send Mail'],
    function()
        return not Save().notAutoToSendFrame
    end, function()
        Save().notAutoToSendFrame= not Save().notAutoToSendFrame and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Mail.AutoSend'])
        tooltip:AddLine(WoWTools_L['TAXI_PATH_UNREACHABLE+MAIL_LABEL'])
    end)


    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().autoToSendFrameSecond or 1
        end, setValue=function(value)
            Save().autoToSendFrameSecond=value
        end,
        name=WoWTools_L.LOSS_OF_CONTROL_SECONDS ,
        minValue=0.5,
        maxValue=5,
        step=0.1,
        bit='%.1f',
    })
    sub:CreateSpacer()

    root:CreateDivider()


--打开选项界面
    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MailMixin.addName})
    WoWTools_MenuMixin:Reload(sub)
end










local function Init()
    local btn=WoWTools_ButtonMixin:Menu(MailFrameCloseButton, {name='WoWToolsMailMenuButton'})
    btn:SetPoint('RIGHT', MailFrameCloseButton, 'LEFT')

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MailMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine((WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL), WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)


    btn:SetupMenu(Init_Menu)
end




function WoWTools_MailMixin:Init_Menu_Button()
    Init()
end