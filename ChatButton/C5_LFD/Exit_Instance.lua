
local ExitIns
local ExitTimer--temporizador cancelable de la salida automática
local ExitCancelled--el jugador canceló la salida en esta instancia: no volver a proponerla

local function Cancel_Exit_Timer()
    if ExitTimer then
        ExitTimer:Cancel()
        ExitTimer= nil
    end
end




local function Save_Instance_Num(name)
    name= name or GetInstanceInfo()
    if name then
        WoWTools_LFDMixin:Save().wow[name]= (WoWTools_LFDMixin:Save().wow[name] or 0)+1
    end
end



local function exit_Instance()
    ExitTimer= nil
    local ins = select(2, IsInInstance())~='none'
    if not ExitIns or not ins or IsModifierKeyDown() or LFGDungeonReadyStatus:IsVisible() or LFGDungeonReadyDialog:IsVisible() then
        ExitIns= nil
        StaticPopup_Hide('WoWTools_LFD_ExitIns')
        return
    end

    local name= GetInstanceInfo()

    --Save_Instance_Num(name)

    local num= WoWTools_LFDMixin:Get_Instance_Num(name)

    if IsInLFDBattlefield() then
        local currentMapID, _, lfgID = select(8, GetInstanceInfo())
        if lfgID then
            local _, _, subtypeID, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, lfgMapID = GetLFGDungeonInfo(lfgID)
            if currentMapID == lfgMapID and subtypeID == LE_LFG_CATEGORY_BATTLEFIELD then
                LFGTeleport(true)
            end
        end
    else
        C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANCE)
    end


    WoWTools_Print(
        WoWTools_DataMixin.Icon.icon2..WoWTools_LFDMixin.addName,
        WoWTools_L.LEAVE,
        WoWTools_TextMixin:CN(name) or WoWTools_L.INSTANCE,
        num
    )
    ExitIns=nil
end


local function Init_Frame()
    local frame= CreateFrame('Frame')
    frame:RegisterEvent('LFG_COMPLETION_REWARD')
    frame:RegisterEvent('PLAYER_ENTERING_WORLD')
    frame:RegisterEvent('ISLAND_COMPLETED')
    frame:RegisterEvent('PVP_MATCH_COMPLETE')
    frame:RegisterEvent('CONFIRM_LOOT_ROLL')

    frame:SetScript('OnEvent', function(self, event, arg1, arg2)
        if event=='LFG_COMPLETION_REWARD' or event=='LOOT_CLOSED' then
            if WoWTools_LFDMixin:Save().leaveInstance
                and IsInLFGDungeon()
                and IsLFGComplete()
                and not LFGDungeonReadyStatus:IsVisible()
                and not LFGDungeonReadyDialog:IsVisible()
                and not ExitCancelled
                and not ExitTimer
                and not StaticPopup_Visible('WoWTools_LFD_ExitIns') then
                    WoWTools_DataMixin:PlaySound()
                    local leaveSce= 30
                    if WoWTools_LFDMixin:Save().autoROLL and event=='LOOT_CLOSED' then
                        leaveSce= WoWTools_LFDMixin:Save().sec
                    end
                    ExitIns=true
                    ExitTimer= C_Timer.NewTimer(leaveSce, exit_Instance)
                    --El aviso muestra y dura los mismos segundos que el temporizador real
                    StaticPopupDialogs['WoWTools_LFD_ExitIns'].timeout= leaveSce
                    StaticPopup_Show('WoWTools_LFD_ExitIns', leaveSce)

                    WoWTools_CooldownMixin:Setup(WoWTools_DataMixin:StaticPopup_FindVisible('WoWTools_LFD_ExitIns') or StaticPopup1, nil, leaveSce, nil, true, true)
            end

        elseif event=='PLAYER_ENTERING_WORLD' then
            if select(2, IsInInstance())~='none' then
                self:RegisterEvent('LOOT_CLOSED')
            else
                self:UnregisterEvent('LOOT_CLOSED')
            end
            ExitIns=nil
            ExitCancelled=nil
            Cancel_Exit_Timer()

        elseif event=='ISLAND_COMPLETED' then
            Save_Instance_Num('island')
            if not WoWTools_LFDMixin:Save().leaveInstance then
                return
            end
            WoWTools_DataMixin:PlaySound()
            C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANCE)
            LFGTeleport(true)
            WoWTools_Print(
                WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_L.ISLANDS_HEADER,
                WoWTools_LFDMixin:Get_Instance_Num('island')
            )

        elseif event=='PVP_MATCH_COMPLETE' then
            if WoWTools_LFDMixin:Save().leaveInstance then
                WoWTools_DataMixin:PlaySound()
                if PVPMatchResults and PVPMatchResults.buttonContainer and PVPMatchResults.buttonContainer.leaveButton then
                    WoWTools_CooldownMixin:Setup(PVPMatchResults.buttonContainer.leaveButton, nil, WoWTools_LFDMixin:Save().sec, nil, true, true)
                end
                WoWTools_Print(
                    WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    '|cnGREEN_FONT_COLOR:'..(WoWTools_L.LEAVE_BATTLEGROUND),
                    SecondsToTime(WoWTools_LFDMixin:Save().sec or 5)
                )
                C_Timer.After(WoWTools_LFDMixin:Save().sec or 5, function()
                    if not IsModifierKeyDown() then
                        if IsInLFDBattlefield() then
                            ConfirmOrLeaveLFGParty()
                        else
                            ConfirmOrLeaveBattlefield()
                        end
                    end
                end)
            end

        elseif event=='CONFIRM_LOOT_ROLL' then
            --opcional (clave nueva): antes se confirmaba siempre y el objeto quedaba ligado sin preguntar
            if WoWTools_LFDMixin:Save().autoConfirmLootRoll and arg1 and arg2 then
                ConfirmLootRoll(arg1, arg2)
                StaticPopup_Hide("CONFIRM_LOOT_ROLL", arg1)
            end
        end
    end)
end


local function Init()
    StaticPopupDialogs['WoWTools_LFD_ExitIns']={
        text = WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2
            ..'|n|n|cff00ff00'
            ..(WoWTools_L.LEAVE)..'|r: '
            ..(WoWTools_L.INSTANCE)
            ..'|cff00ff00 %s |r'
            ..(WoWTools_L.LOSS_OF_CONTROL_SECONDS),
        button1 = WoWTools_L.LEAVE,
        button2 = WoWTools_L.CANCEL,
        OnAccept=function()
            ExitIns=true
            Cancel_Exit_Timer()
            exit_Instance()
        end,
        OnCancel=function(_, _, d)
            if d=='clicked' then
                ExitIns=nil
                ExitCancelled=true
                Cancel_Exit_Timer()
                WoWTools_Print(
                    WoWTools_LFDMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    '|cff00ff00'..(WoWTools_L.CANCEL)..'|r',
                    WoWTools_L.LEAVE
                )
            end
        end,
        OnUpdate= function(self)
            if IsModifierKeyDown() or RolePollPopup:IsShown() then
                self:Hide()
                ExitIns=nil
                ExitCancelled=true
                Cancel_Exit_Timer()
            end
        end,
        whileDead=true, exclusive=true,--hideOnEscape=true, 
        timeout=WoWTools_LFDMixin:Save().sec or 5}

    Init_Frame()

    LFGDungeonReadyStatus:HookScript('OnShow', function()
        if WoWTools_LFDMixin:Save().leaveInstance then
            exit_Instance()
        end
    end)
    LFGDungeonReadyDialog:HookScript('OnShow', function()
        if WoWTools_LFDMixin:Save().leaveInstance then
            exit_Instance()
        end
    end)

    WoWTools_ChatMixin:GetButtonForName('LFD').leaveInstance:SetShown(WoWTools_LFDMixin:Save().leaveInstance)

    Init=function()
         WoWTools_ChatMixin:GetButtonForName('LFD').leaveInstance:SetShown(WoWTools_LFDMixin:Save().leaveInstance)
    end
end


function WoWTools_LFDMixin:Init_Exit_Instance()
    Init()
end