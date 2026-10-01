
local function Invite(unit)
    if WoWTools_UnitMixin:UnitIsUnit('player', unit)~=false
        or not WoWTools_UnitMixin:UnitGUID(unit)
        or not UnitIsConnected(unit)
        or not UnitIsPlayer(unit)
        or UnitIsEnemy('player', unit)
    then
        return
    end

    local guid= UnitGUID(unit)
    if guid and not IsPlayerInGuildFromGUID(guid) then
        OfferPetition()
    end
end















local Init_Once= WoWTools_Once(function()
    local btn= WoWTools_ButtonMixin:Cbtn(PetitionFrame, {isUI=true, size={120, 23}})

    btn:SetText(WoWTools_L.NAMEPLATES_LABEL)
    btn:SetPoint('TOPLEFT', 50, -33)

    btn:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip_SetTitle(GameTooltip,
            WoWTools_DataMixin.Icon.icon2..(WoWTools_L.NAMEPLATES_MESSAGE_FRIENDLY_ON)
        )
        if InCombatLockdown() then
            GameTooltip_AddErrorLine(GameTooltip, WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        end
        GameTooltip:Show()
    end)
    btn:SetScript('OnClick', function()
        if InCombatLockdown() then
            return
        end
        C_CVar.SetCVar('nameplateShowFriendlyPlayers', C_CVar.GetCVarBool('nameplateShowFriendlyPlayers') and '0' or '1')
    end)

    local check= CreateFrame('CheckButton', 'PetitionFrameAutoPetitionTargetCheckBox', PetitionFrame, 'InterfaceOptionsCheckButtonTemplate')
    check:SetPoint('LEFT', btn, 'RIGHT', 2, 0)
    check.Text:SetText(WoWTools_L.TARGET)
    check:SetScript('OnLeave', GameTooltip_Hide)
    check:SetChecked(not WoWTools_GuildMixin:Save().disabledPetitionTarget)
    WoWTools_TextureMixin:SetCheckBox(check)
    check:SetScript('OnClick', function(self)
        WoWTools_GuildMixin:Save().disabledPetitionTarget= not self:GetChecked()
        self:set_event()
    end)
    check:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_ChatMixin.addName, WoWTools_GuildMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_L['SELF_CAST_AUTO+REQUEST_SIGNATURE'], WoWTools_L.TARGET)
        GameTooltip:Show()
    end)

    function check:set_event()
        if self:IsVisible() and self:GetChecked() then
            self:RegisterEvent('PLAYER_TARGET_CHANGED')
            Invite('target')
        else
            self:UnregisterEvent('PLAYER_TARGET_CHANGED')
        end
    end

    check:SetScript('OnEvent',  function()
        Invite('target')
    end)

    PetitionFrame:HookScript('OnHide', function()
        check:set_event()
    end)
    PetitionFrame:HookScript('OnShow', function()
        check:set_event()
    end)
end)

--La comprobación queda fuera del "una sola vez": se vuelve a mirar en cada llamada
local function Init()
    if IsInGuild() then
        return
    end
    Init_Once()
end





function WoWTools_GuildMixin:Init_PetitionFrame()
    Init()
end
