WoWTools_ChatMixin={

}


function WoWTools_ChatMixin:Chat(text, name, printText)
    if not text then
        return
    end

    --12.0: durante encuentros no se puede enviar chat desde addons
    local locked= not printText and C_ChatInfo.InChatMessagingLockdown and C_ChatInfo.InChatMessagingLockdown()

    if locked then
        return

    elseif name then
        C_ChatInfo.SendChatMessage(text, 'WHISPER', nil, name)
    elseif printText then
        if not ChatEdit_InsertLink(text) then
            WoWTools_DataMixin:Call(ChatFrame_OpenChat, text)
        end
    elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then--antes fallaba con grupo manual dentro de una instancia
        C_ChatInfo.SendChatMessage(text, 'INSTANCE_CHAT')
    elseif IsInRaid() then
        C_ChatInfo.SendChatMessage(text, 'RAID')
    elseif IsInGroup() then--and C_CVar.GetCVarBool("chatBubblesParty") then
        C_ChatInfo.SendChatMessage(text, 'PARTY')
    
    else
        if canaccessvalue(text) and text:find('{rt%d}') then
            text= text:gsub('{rt%d}', function(s)
                local icon= s:match('%d')
                if icon then
                    return format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%s:0|t', icon)
                end
            end)
        end
        print(text)
    end
end


--ChatFrameEditBoxMixin.SendText 11.2.7才有
function WoWTools_ChatMixin:SendText(text)
    if not text then
        return
    end
    local msg= DEFAULT_CHAT_FRAME:IsShown() and DEFAULT_CHAT_FRAME.editBox:GetText() or ''
    DEFAULT_CHAT_FRAME.editBox:SetText(text)
    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
    if msg~='' then
        ChatFrame_OpenChat(msg, DEFAULT_CHAT_FRAME)
        if DEFAULT_CHAT_FRAME.editbox then
            DEFAULT_CHAT_FRAME.editbox:ClearFocus()
        end
    end
end


function WoWTools_ChatMixin:Say(type, name, wow, text)
    local chat= SELECTED_DOCK_FRAME
    local msg = chat.editBox:GetText() or ''
    if text and text==msg then
        text=''
    else
        text= text or ''
    end
    if msg:find('/') then msg='' end
    msg=' '..msg
    if name then
        if wow then
            ChatFrame_SendBNetTell(name..msg..(text or ''))
        else
            ChatFrame_OpenChat("/w " ..name..msg..(text or ''), chat)
        end
    elseif type then
        ChatFrame_OpenChat(type..msg..(text or ''), chat)
    end
end