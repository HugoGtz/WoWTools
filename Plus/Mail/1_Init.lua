WoWTools_MailMixin={}



function WoWTools_MailMixin:SetSendName(name, guid)
    name= name or WoWTools_UnitMixin:GetFullName(nil, nil, guid)
    if not name then
        return
    end
    name= name:gsub('%-'..WoWTools_DataMixin.Player.Realm, '')
    SendMailNameEditBox:SetText(name)
    SendMailNameEditBox:SetCursorPosition(0)
    SendMailNameEditBox:ClearFocus()
    C_Timer.After(0.5, function()
        if SendMailSubjectEditBox:GetText()=='' then
            SendMailSubjectEditBox:SetText(EMOTE56_CMD1:gsub('/',''))
            SendMailSubjectEditBox:SetCursorPosition(0)
            SendMailSubjectEditBox:ClearFocus()
        end
    end)
end

function WoWTools_MailMixin:GetNameInfo(name)
    if not name then
        return
    end
    local reName
    name = WoWTools_UnitMixin:GetFullName(name)
    for guid, tab in pairs(WoWToolsPlus_WoWDate) do
        if name== WoWTools_UnitMixin:GetFullName(nil, nil, guid) then
            reName= WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {faction=tab.faction, reName=true, realm=true})
            break
        end
    end
    reName= reName or WoWTools_UnitMixin:GetPlayerInfo(nil, nil, name, {reName=true, reRealm=true})
    return reName and reName:gsub('%-'..WoWTools_DataMixin.Player.Realm, '') or name
end


function WoWTools_MailMixin:GetRealmInfo(name)
    if not name then
        return
    end
    local realm= name:match('%-(.+)')
    if realm and not (WoWTools_DataMixin.Player.Realms[realm] or realm==WoWTools_DataMixin.Player.Realm) then
        return format('|cnWARNING_FONT_COLOR:%s|r', WoWTools_L.ERR_PETITION_NOT_SAME_SERVER)
    end
end


function WoWTools_MailMixin:RefreshAll()
    if InboxFrame:IsShown() then
        WoWTools_DataMixin:Call('InboxFrame_Update')
    elseif SendMailFrame:IsShown() then
        WoWTools_DataMixin:Call('SendMailFrame_Update')
    end
    if OpenMailFrame:IsShown() then
        WoWTools_DataMixin:Call('OpenMail_Update')
    end
end


local Init= WoWTools_Once(function()--SendMailNameEditBox
    --rellenar con lo último enviado solo si el jugador activó guardarlo (logSendInfo)
    if WoWTools_MailMixin:Save().logSendInfo and WoWTools_MailMixin:Save().lastSendPlayer then
        WoWTools_MailMixin:SetSendName(WoWTools_MailMixin:Save().lastSendPlayer)
    end

    if WoWTools_MailMixin:Save().logSendInfo and WoWTools_MailMixin:Save().lastSendSub then
        SendMailSubjectEditBox:SetText(WoWTools_MailMixin:Save().lastSendSub)
    end

    if WoWTools_MailMixin:Save().logSendInfo and WoWTools_MailMixin:Save().lastSendBody then
        SendMailBodyEditBox:SetText(WoWTools_MailMixin:Save().lastSendBody)
    end
    SendMailNameEditBox:ClearFocus()

    if not WoWTools_MailMixin:Save().notAutoToSendFrame and not GameLimitedMode_IsActive() then
        C_Timer.After(WoWTools_MailMixin:Save().autoToSendFrameSecond or 1, function()
            if GetInboxNumItems()==0 then
                MailFrameTab_OnClick(nil, 2)
            end
        end)
    end

    WoWTools_MailMixin:Init_Menu_Button()

    WoWTools_MailMixin:Init_InBox()

--UI Plus
    WoWTools_MailMixin:Init_Edit_Letter_Num()
    WoWTools_MailMixin:Init_Clear_All_Send_Items()

    WoWTools_MailMixin:Init_Send_Name_List()


    WoWTools_MailMixin:Init_Send_History_Name()

    WoWTools_MailMixin:Init_Fast_Button()

end)


--Módulo registrado con la API común (docs/REFACTOR.md, R1)
WoWTools_Module:Register({
    key= 'Plus_Mail',
    name= 'Module.Mail',
    icon= 'UI-HUD-Minimap-Mail-Mouseover',
    group= 'Items',
    defaults= {
        --hideUIPlus=true,
        --hideSendNameList=true,
        --hideHistoryList=true,
        --hideItemButtonList=true

        --autoToSendFrameSecond=1,

        lastSendPlayerList= {},
        lastMaxSendPlayerList=20,
        show={
            ['FRIEND']=true,
        },
        fast={},
        fastShow=true,
        scaleFastButton=1.3,
        --INBOXITEMS_TO_DISPLAY=7,
    },
    tooltip= 'Tip.Mail.Module',
    mixin= WoWTools_MailMixin,
    events= {MAIL_SHOW= function()
        Init()
        return true
    end},
})
