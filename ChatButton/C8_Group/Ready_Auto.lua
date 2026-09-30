
local function Save()
    return WoWToolsPlusSave['ChatButtonGroup'] or {}
end

local function Get_LeftTime()
    if ReadyCheckListenerFrame.time then
        return select(2, WoWTools_TimeMixin:Info(nil, false, nil, ReadyCheckListenerFrame.time))
    end
end

local AutoReadyTime
local PlayerNameText










local function Set_Ready(timeLeft)
    if AutoReadyTime then
        AutoReadyTime:Cancel()
        AutoReadyTime= nil
    end

    local autoReady= Save().autoReady or 0

    if autoReady>0 then
        WoWTools_Print(
            WoWTools_GroupMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_GroupMixin:Get_ReadyText(),
            '|cffff00ffAlt', WoWTools_L.CANCEL
        )

        --no esperar más que el tiempo que queda de la comprobación (antes math.mix, que no existe, en código muerto)
        local left= Get_LeftTime()
        timeLeft= math.min(Save().autoReadySeconds or 3, (left and left>0) and left or 35)

        AutoReadyTime= C_Timer.NewTimer(timeLeft, function()
            if ReadyCheckFrame:IsShown() then
                ConfirmReadyCheck(autoReady==1 and 1 or nil)
                ReadyCheckFrame:SetShown(false)
            end
        end)
    end

    WoWTools_CooldownMixin:Setup(ReadyCheckListenerFrame, nil, timeLeft or Get_LeftTime() or 35, nil, true, true)
end
















local function Init()
    ReadyCheckFrame:SetHeight(124)--100
    --ReadyCheckFrameText:SetPoint('TOP', 20, ---45)--="TOP" x="20" y="-37"/>

    WoWTools_DataMixin:Hook('ShowReadyCheck', function(initiator, timeLeft)--ReadyCheckListenerFrame
        WoWTools_DataMixin:PlaySound(SOUNDKIT.READY_CHECK)

        if not initiator or not ReadyCheckListenerFrame:IsVisible() then
            return
        end

        if timeLeft then
            ReadyCheckListenerFrame.time= timeLeft+ GetTime()
        end

        local name= WoWTools_UnitMixin:GetPlayerInfo(nil, nil, initiator, {reName=true})
        name= name~='' and name or initiator or ''

        local _, difficultyID
        difficultyID = select(3, GetInstanceInfo())
        if ( not difficultyID or difficultyID == 0 ) then
            if UnitInRaid("player") then
                difficultyID = GetRaidDifficultyID()
            else
                difficultyID = GetDungeonDifficultyID()
            end
        end

        local difficultyName, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(difficultyID)

        if ( toggleDifficultyID and toggleDifficultyID > 0 ) then
            difficultyName=  WoWTools_MapMixin:GetDifficultyColor(difficultyName, difficultyID) or difficultyName

            ReadyCheckFrameText:SetFormattedText(
                WoWTools_L['%s has initiated a ready check.|nRaid Difficulty: ']
                ..difficultyName..'|r', name)
        else
           ReadyCheckFrameText:SetFormattedText(WoWTools_L['%s|nhas initiated a ready check.'], name)
       end

        Set_Ready(timeLeft)
    end)





    ReadyCheckListenerFrame:HookScript('OnHide', function(self)
        if PlayerNameText then
            PlayerNameText:SetText("")
        end
        if AutoReadyTime then
            AutoReadyTime:Cancel()
            AutoReadyTime= nil
        end
        self.time= nil
    end)


    ReadyCheckListenerFrame:HookScript('OnUpdate', function(self)
        if AutoReadyTime
            and IsModifierKeyDown()
        then

            AutoReadyTime:Cancel()
            AutoReadyTime= nil

            WoWTools_Print(
                WoWTools_GroupMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_GroupMixin:Get_ReadyText(),
                '|cff00ff00'..(WoWTools_L.CANCEL)
            )

            WoWTools_CooldownMixin:Setup(self, nil, Get_LeftTime(), nil, true, true)
        end
    end)











    for i=0, 2 do
        local check= CreateFrame('CheckButton', 'WoWToolsReadyCheckButton'..i, ReadyCheckListenerFrame, 'UIRadialButtonTemplate')


        check:SetSize(24,24)
        WoWTools_TextureMixin:SetCheckBox(check)
        --check.text= check:CreateFontString(nil, "BORDER", 'WoWToolsFont2')
        check.text:ClearAllPoints()
        check.text:SetPoint('RIGHT', check, 'LEFT')
        check.text:SetText(WoWTools_GroupMixin:Get_ReadyText(i))

        check:SetPoint('RIGHT', ReadyCheckListenerFrame, 'LEFT', -2, 20-(i*20))
        check.value= i>0 and i or nil

        check:SetScript('OnShow', function(self)
            self:SetChecked(self.value== Save().autoReady)
        end)
        check.value= i
        check:SetScript('OnMouseUp', function(self)
            Save().autoReady= self.value
            Set_Ready()
            for index=0,2 do
                if self.value~=index then
                    _G['WoWToolsReadyCheckButton'..index]:SetChecked(false)
                end
            end
            _G['WoWToolsReadyCheckAltCanellLabel']:SetShown(self.value~=0)
        end)

        check:SetScript('OnLeave', function()
            GameTooltip:Hide()
        end)
        check:SetScript('OnEnter', function(self)
            GameTooltip_ShowSimpleTooltip(GameTooltip, WoWTools_GroupMixin.addName..WoWTools_DataMixin.Icon.icon2, nil, nil, self)
        end)
    end

    local altLabel= ReadyCheckListenerFrame:CreateFontString('WoWToolsReadyCheckAltCanellLabel', 'BORDER', 'GameFontNormal')--  WoWTools_LabelMixin:Create(ReadyCheckListenerFrame)
    altLabel:SetPoint('TOPRIGHT', _G['WoWToolsReadyCheckButton2'], 'BOTTOMRIGHT', 0,-8)
    altLabel:SetText('Alt '..(WoWTools_L.CANCEL))



    Init=function()end
end


--ReadyCheckFrame
--ReadyCheckListenerFrame


function WoWTools_GroupMixin:Init_AutoReady()
    Init()
end
