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
    WoWTools_MailMixin.isInit= true--ya se abrió el buzón: las opciones pueden refrescar en vivo
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


--Refresco en vivo desde el Centro de control: solo si el buzón ya se abrió (los marcos existen)
--func: nombre de la función del mixin (se definen en archivos posteriores) o función
local function Apply(func)
    return function()
        if WoWTools_MailMixin.isInit then
            if type(func)=='string' then
                WoWTools_MailMixin[func](WoWTools_MailMixin)
            else
                func()
            end
        end
    end
end

--Mostrar desconectados en la lista de nombres (save.show[tipo])
local function Offline_Option(kind, text)
    return {type='check', text=text, tooltip='COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE', indent=true,
        disabled= function(save) return save.hideSendNameList end,
        get= function(save) return save.show[kind] end,
        set= function(save, value) save.show[kind]= value and true or nil end,
    }
end

local Options= {
    {type='section', text='GENERAL'},
    {type='check', text=function() return WoWTools_L.INBOX..' Plus' end, tooltip='Tip.Mail.InBoxPlus',
        get= function(save) return not save.hide end,
        set= function(save, value) save.hide= not value and true or nil end,
        apply= Apply('Init_InBox'),
    },
    {type='check', text='WHO_LIST', tooltip='Tip.Mail.NameList',
        get= function(save) return not save.hideSendNameList end,
        set= function(save, value) save.hideSendNameList= not value and true or nil end,
        apply= Apply('Init_Send_Name_List'),
    },
    Offline_Option('WoW', 'Show offline Battle.net friends'),
    Offline_Option('FRIEND', 'Show offline friends'),
    Offline_Option('GUILD', 'Show offline guild members'),
    Offline_Option('CLUB', 'Show offline community members'),
    {type='check', text='Saved content', tooltip='Tip.Mail.SaveContent',
        get= function(save) return save.logSendInfo end,
        set= function(save, value) save.logSendInfo= value and true or nil end,
        apply= Apply(function()
            if SendMailNameEditBox.save_log then
                SendMailNameEditBox:save_log()
                SendMailSubjectEditBox:save_log()
                SendMailBodyEditBox:save_log()
            end
        end),
    },
    {type='check', text='Recipient history', tooltip='Tip.Mail.History',
        get= function(save) return not save.hideHistoryList end,
        set= function(save, value) save.hideHistoryList= not value and true or nil end,
        apply= Apply('Init_Send_History_Name'),
    },
    {type='check', text='Show recipient list', tooltip='Tip.Mail.HistoryShow', indent=true,
        disabled= function(save) return save.hideHistoryList end,
        get= function(save) return not save.hideSendPlayerList end,
        set= function(save, value) save.hideSendPlayerList= not value and true or nil end,
        apply= Apply('Refresh_Send_History'),
    },
    {type='slider', text='History size', tooltip='Tip.Mail.HistoryMax', indent=true, min=5, max=100, step=1,
        disabled= function(save) return save.hideHistoryList end,
        get= function(save) return save.lastMaxSendPlayerList or 20 end,
        set= function(save, value) save.lastMaxSendPlayerList= value end,
    },
    {type='check', text='ITEMS+SETTINGS_KEYBINDINGS_LABEL', tooltip='Tip.Mail.FastButtons',
        get= function(save) return not save.hideItemButtonList end,
        set= function(save, value) save.hideItemButtonList= not value and true or nil end,
        apply= Apply('Init_Fast_Button'),
    },
    {type='check', text='Show item buttons', tooltip='Tip.Mail.FastShow', indent=true,
        disabled= function(save) return save.hideItemButtonList end,
        get= function(save) return save.fastShow end,
        set= function(save, value) save.fastShow= value and true or false end,
        apply= Apply('Refresh_Fast_Button'),
    },

    {type='section', text='Automations'},
    {type='check', text='Auto switch to Send Mail', tooltip='Tip.Mail.AutoSend', automation=true,
        get= function(save) return not save.notAutoToSendFrame end,
        set= function(save, value) save.notAutoToSendFrame= not value and true or nil end,
    },
    {type='slider', text='Delay (seconds)', tooltip='Tip.Mail.AutoSendDelay', indent=true,
        min=0.5, max=5, step=0.1, format='%.1f',
        disabled= function(save) return save.notAutoToSendFrame end,
        get= function(save) return save.autoToSendFrameSecond or 1 end,
        set= function(save, value) save.autoToSendFrameSecond= value end,
    },

    {type='section', text='Appearance'},
    {type='slider', text='Recipient history scale', tooltip='Tip.Menu.Scale', min=0.4, max=4, step=0.1, format='%.1f',
        disabled= function(save) return save.hideHistoryList end,
        get= function(save) return save.scaleSendPlayerFrame or 1 end,
        set= function(save, value) save.scaleSendPlayerFrame= value end,
        apply= Apply('Refresh_Send_History'),
    },
    {type='slider', text='Item buttons scale', tooltip='Tip.Menu.Scale', min=0.4, max=4, step=0.1, format='%.1f',
        disabled= function(save) return save.hideItemButtonList end,
        get= function(save) return save.scaleFastButton or 1 end,
        set= function(save, value) save.scaleFastButton= value end,
        apply= Apply('Refresh_Fast_Button'),
    },

    {type='section', text='Advanced'},
    {type='button', text='Clear recipient history', buttonText='CLEAR_ALL', confirm='CLEAR_ALL',
        tooltip='Tip.Mail.ClearHistory',
        func= function(M, save)
            save.lastSendPlayerList= {}
            if M.isInit then
                M:Refresh_Send_History()
            end
        end,
    },
    {type='note', text='Tip.Mail.OptionsNote'},
}

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
    options= Options,
    events= {MAIL_SHOW= function()
        Init()
        return true
    end},
})
