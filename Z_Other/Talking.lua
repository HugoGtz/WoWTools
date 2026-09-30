--TalkingHeadUI.lua
local addName
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")



local function Save()
    return WoWToolsPlusSave['Other_VoiceTalking']
end














local function Init()
    addName= '|A:TalkingHeads-Glow-TopSpike:0:0|a'..(WoWTools_DataMixin.onlyChinese and '隐藏NPC发言' or WoWTools_Join(HIDE, VOICE_TALKING))

    --添加控制面板
    local root= WoWTools_PanelMixin:OnlyCheck({
        name= addName,
        tooltip=WoWTools_Join(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE , WoWTools_DataMixin.onlyChinese and '对话特写头像' or HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL)
                ..'|n|n'..(WoWTools_DataMixin.onlyChinese and '声音' or SOUND)
                ..'|nChat Button, '..(WoWTools_DataMixin.onlyChinese and '超链接图标' or WoWTools_Join(COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, EMBLEM_SYMBOL))
                ..'|n'..(WoWTools_DataMixin.onlyChinese and '事件声音' or WoWTools_Join(EVENTS_LABEL, SOUND)),
        GetValue= function() return not Save().disabled end,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            panel:set_event()
        end,
        layout= WoWTools_OtherMixin.Layout,
        category= WoWTools_OtherMixin.Category,
    })

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '文本' or LOCALE_TEXT_LABEL,
        GetValue= function() return not Save().notPrint end,
        tooltip= WoWTools_DataMixin.onlyChinese and '聊天框提示，内容' or WoWTools_L['Chat box text'],
        SetValue= function()
            Save().notPrint= not Save().notPrint and true or false
        end,
        layout= WoWTools_OtherMixin.Layout,
        category= WoWTools_OtherMixin.Category,
    }, root)


    panel:set_event()

    Init=function()end
end




local voHandle


function panel:set_event()
    local event= 'TALKINGHEAD_REQUESTED'
    if Save().disabled then
        self:UnregisterEvent(event)
    else
        self:RegisterEvent(event)
    end
end

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then
            WoWToolsPlusSave['Other_VoiceTalking']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Other_VoiceTalking'], {notPrint=true})
            Init()
            self:UnregisterEvent(event)
        end

    elseif event=='TALKINGHEAD_REQUESTED' then
        local _, _, vo, _, _, _, name, text = C_TalkingHead.GetCurrentLineInfo()
        TalkingHeadFrame:CloseImmediately()
        if vo and vo>0 then
            if voHandle then
                StopSound(voHandle)
                voHandle = nil
            end
            local success, vo2 = WoWTools_DataMixin:PlaySound(vo, true)--PlaySound(vo, "Talking Head", true, true)
            if success then
                voHandle = vo2
            end
        end

        if not Save().notPrint and (text or voHandle) then
            print(WoWTools_DataMixin.Icon.icon2,
                '|cff00ff00'..name..'|r',
                '|cffff00ff'..text..'|r',
                addName,
                'soundKitID',
                vo
            )
        end
    end
end)