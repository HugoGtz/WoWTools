WoWTools_MailMixin={}



local function Save()
    return WoWToolsPlusSave['Plus_Mail']
end


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


local function Init()--SendMailNameEditBox
    --rellenar con lo último enviado solo si el jugador activó guardarlo (logSendInfo)
    if Save().logSendInfo and Save().lastSendPlayer then
        WoWTools_MailMixin:SetSendName(Save().lastSendPlayer)
    end

    if Save().logSendInfo and Save().lastSendSub then
        SendMailSubjectEditBox:SetText(Save().lastSendSub)
    end

    if Save().logSendInfo and Save().lastSendBody then
        SendMailBodyEditBox:SetText(Save().lastSendBody)
    end
    SendMailNameEditBox:ClearFocus()

    if not Save().notAutoToSendFrame and not GameLimitedMode_IsActive() then
        C_Timer.After(Save().autoToSendFrameSecond or 1, function()
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

    Init=function()end
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Plus_Mail']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Mail'], {
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
            })

            WoWTools_MailMixin.addName= '|A:UI-HUD-Minimap-Mail-Mouseover:0:0|a'..(WoWTools_L['Module.Mail'])

            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_MailMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    if Save().disabled then
                        WoWTools_Print(
                            WoWTools_MailMixin.addName..WoWTools_DataMixin.Icon.icon2,
                            WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                            WoWTools_L.REQUIRES_RELOAD
                        )
                    end
                    Init()
                end,
                tooltip= WoWTools_L['Tip.Mail.Module'],
            })

            if not Save().disabled then                
                self:RegisterEvent('MAIL_SHOW')
            else
                self:SetScript('OnEvent', nil)
            end
            self:UnregisterEvent(event)
        end

    elseif event=='MAIL_SHOW' then
        Init()
        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)
