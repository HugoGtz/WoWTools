--TalkingHeadUI.lua
local addName
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")



local function Save()
    return WoWToolsPlusSave['Other_VoiceTalking']
end














local function Init()
    addName= '|A:TalkingHeads-Glow-TopSpike:0:0|a'..(WoWTools_L['HIDE+VOICE_TALKING'])

    --添加控制面板
    local root= WoWTools_PanelMixin:OnlyCheck({
        name= addName,
        tooltip=WoWTools_Join(WoWTools_L.HIDE , WoWTools_L.HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL)
                ..'|n|n'..(WoWTools_L['SOUND~2'])
                ..'|nChat Button, '..(WoWTools_L['COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK+EMBLEM_SYMBOL'])
                ..'|n'..(WoWTools_L['EVENTS_LABEL+SOUND']),
        GetValue= function() return not Save().disabled end,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            panel:set_event()
        end,
        layout= WoWTools_OtherMixin.Layout,
        category= WoWTools_OtherMixin.Category,
    })

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L.LOCALE_TEXT_LABEL,
        GetValue= function() return not Save().notPrint end,
        tooltip= WoWTools_L['Chat box text'],
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