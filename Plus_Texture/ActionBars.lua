--Estilo de barras de acción (recuperado del módulo Texturas del original):
--iconos sin marco con máscara, atajos más cortos, barra de vehículo y de habilidad de zona,
--y botones de las batallas de mascotas. Opción en Opciones -> WoWToolsPlus -> Interfaz.
WoWTools_ActionBarsMixin= {}

local function Save()
    return WoWToolsPlusSave['Plus_Texture'] or {}
end

local function Set_Texture(self)
    if self then
        WoWTools_TextureMixin:HideTexture(self.SlotArt)--, nil, true, 0)
        WoWTools_TextureMixin:HideTexture(self.NormalTexture)
        WoWTools_TextureMixin:HideTexture(self.SlotBackground)
        if self.CheckedTexture then
            self.CheckedTexture:SetVertexColor(0,1,0)
        end

        if not self.IconMask then
            WoWTools_ButtonMixin:AddMask(self, false, self.Icon)
        else
            self.IconMask:ClearAllPoints()
            self.IconMask:SetAtlas('UI-HUD-CoolDownManager-Mask')
            self.IconMask:SetPoint('TOPLEFT', self.Icon or self, 0.5, -0.5)
            self.IconMask:SetPoint('BOTTOMRIGHT', self.Icon or self, -0.5, 0.5)
        end
    end
end

local function Set_Assisted(self)
    if self:GetFrameStrata()=='BACKGROUND' then
        return
    elseif not InCombatLockdown() then
        self:SetFrameStrata('BACKGROUND')
        self:SetScale(0.9)
    else
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
            Set_Assisted(self)
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end)
    end
end

local function Set_KeyText(self)
    local text= WoWTools_KeyMixin:GetHotKeyText(self.HotKey:GetText(), nil)
    if text then
        self.HotKey:SetText(text)
    end
    self.HotKey:SetTextColor(1,1,1,1)
end

local function Set_MainMenuBarPool()
    local dividersPool = MainActionBar.isHorizontal and MainActionBar.HorizontalDividersPool or MainActionBar.VerticalDividersPool
    if dividersPool then
        for pool in dividersPool:EnumerateActive() do
            WoWTools_TextureMixin:HideFrame(pool)
        end
    end
end

local function Init_HooKey(btn)
    if not btn then
        return
    end
    Set_Texture(btn)

    if btn.UpdateHotkeys then
        Set_KeyText(btn)
        WoWTools_DataMixin:Hook(btn, 'UpdateHotkeys', function(b)
            Set_KeyText(b)
        end)
    end

    if btn.cooldown then
        btn.cooldown:SetCountdownFont('NumberFontNormal')
    end

    if btn.AssistedCombatRotationFrame then
        Set_Assisted(btn.AssistedCombatRotationFrame)
    end
end

local function Style_ActionBar(self)
    for i=1, 12 do
        for _, name in pairs({
            "ActionButton",
            "MultiBarBottomLeftButton",
            "MultiBarBottomRightButton",
            "MultiBarLeftButton",
            "MultiBarRightButton",
            "MultiBar5Button",
            "MultiBar6Button",
            "MultiBar7Button",
            "PetActionButton",
            "OverrideActionBarButton",
        }) do
            Init_HooKey(_G[name..i])
        end
    end

    Init_HooKey(_G['ExtraActionButton1'])

    for i=1, 10 do
        Set_Texture(_G['StanceButton'..i])--..'NormalTexture'])
    end

    WoWTools_DataMixin:Hook(ActionBarButtonAssistedCombatRotationFrameMixin, 'OnLoad', function(frame)
        Set_Assisted(frame)
    end)

    EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
        Set_MainMenuBarPool()
        EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
    end)

    EditModeManagerFrame:HookScript('OnHide', function()
        for i=1, 12 do--MAIN_MENU_BAR_NUM_BUTTONS
            Set_Texture(_G['ActionButton'..i])
        end
       Set_MainMenuBarPool()
    end)

    OverrideActionBarExpBarOverlayFrameText:SetAlpha(0.5)
    OverrideActionBarExpBar:HookScript('OnLeave', function()
        OverrideActionBarExpBarOverlayFrameText:SetAlpha(0.5)
    end)
    OverrideActionBarExpBar:HookScript('OnEnter', function()
        OverrideActionBarExpBarOverlayFrameText:SetAlpha(1)
    end)
    self:SetFrame(OverrideActionBarExpBar, {index=1, alpha=0.3})
    self:SetStatusBar(OverrideActionBarExpBar)
    OverrideActionBarExpBar:SetHeight(12)

    self:SetFrame(MainActionBar.ActionBarPageNumber.UpButton, {alpha=0.5})
    self:SetFrame(MainActionBar.ActionBarPageNumber.DownButton, {alpha=0.5})
    WoWTools_ColorMixin:SetLabelColor(MainActionBar.ActionBarPageNumber.Text)

    if MainActionBar.EndCaps then
        self:SetAlphaColor(MainActionBar.EndCaps.LeftEndCap, true, nil, nil)
        self:SetAlphaColor(MainActionBar.EndCaps.RightEndCap, true, nil, nil)
        MainActionBar.EndCaps.LeftEndCap:Hide()
        MainActionBar.EndCaps.RightEndCap:Hide()
    end
    self:SetAlphaColor(MainActionBar.BorderArt, nil, nil, 0)

    self:HideTexture(SpellFlyout.Background.Start)
    self:HideTexture(SpellFlyout.Background.End)
    self:HideTexture(SpellFlyout.Background.HorizontalMiddle)
    self:HideTexture(SpellFlyout.Background.VerticalMiddle)
end

local function Style_ZoneAbility(self)
    for btn in ZoneAbilityFrame.SpellButtonContainer:EnumerateActive() do
        Set_Texture(btn)
    end

    self:SetAlphaColor(ZoneAbilityFrame.Style, nil, nil, 0.3)

    WoWTools_DataMixin:Hook(ZoneAbilityFrame, 'UpdateDisplayedZoneAbilities', function(frame)
        for btn in frame.SpellButtonContainer:EnumerateActive() do
            if not btn.IconMask then
                Set_Texture(btn)
            end
        end
    end)
end

local function Style_PetBattle(self)
    self:HideTexture(PetBattleFrame.TopArtLeft)
    self:HideTexture(PetBattleFrame.TopArtRight)
    self:HideTexture(PetBattleFrame.TopVersus)
    PetBattleFrame.TopVersusText:SetText('')
    PetBattleFrame.TopVersusText:SetShown(false)
    self:HideTexture(PetBattleFrame.WeatherFrame.BackgroundArt)

    self:HideTexture(PetBattleFrameXPBarLeft)
    self:HideTexture(PetBattleFrameXPBarRight)
    self:HideTexture(PetBattleFrameXPBarMiddle)

    self:HideTexture(PetBattleFrame.BottomFrame.LeftEndCap)
    self:HideTexture(PetBattleFrame.BottomFrame.RightEndCap)
    self:HideTexture(PetBattleFrame.BottomFrame.Background)

    self:HideTexture(PetBattleFrame.BottomFrame.TurnTimer.ArtFrame2)
    self:SetUIButton(PetBattleFrame.BottomFrame.TurnTimer.SkipButton)
    for _, t in pairs({'ForfeitButton', 'CatchButton', 'SwitchPetButton'}) do
        local btn= PetBattleFrame.BottomFrame[t]
        if btn then
            self:HideTexture(btn.NormalTexture)
            WoWTools_ButtonMixin:AddMask(btn)
        end
    end
    WoWTools_DataMixin:Hook('PetBattleAbilityButton_OnLoad', function(btn)
        self:HideTexture(btn.NormalTexture)
        WoWTools_ButtonMixin:AddMask(btn)
    end)

    PetBattleFrame.BottomFrame.FlowFrame:SetShown(false)
    PetBattleFrame.BottomFrame.Delimiter:SetShown(false)

    for i=1, NUM_BATTLE_PETS_IN_BATTLE do
        local frame= PetBattleFrame.BottomFrame.PetSelectionFrame['Pet'..i]
        if frame and frame.SelectedTexture then
            frame.SelectedTexture:SetVertexColor(0,1,1)
        end
    end

    WoWTools_DataMixin:Hook('PetBattleAbilityButton_UpdateHotKey', function(frame)
        if not frame.HotKey:IsShown() then
            return
        end
        local key= WoWTools_KeyMixin:GetHotKeyText(GetBindingKey("ACTIONBUTTON"..frame:GetID()), nil)
        if key then
            frame.HotKey:SetText(key)
        end
        frame.HotKey:SetTextColor(1,1,1)
    end)

    self:HideFrame(PetBattleFrame.BottomFrame.MicroButtonFrame)

    WoWTools_DataMixin:Hook('PetBattleFrame_UpdatePassButtonAndTimer', function(frame)--Blizzard_PetBattleUI.lua
        self:HideTexture(frame.BottomFrame.TurnTimer.TimerBG)
        self:HideTexture(frame.BottomFrame.TurnTimer.ArtFrame)
        self:HideTexture(frame.BottomFrame.TurnTimer.ArtFrame2)
    end)

    PetBattlePrimaryUnitTooltip:SetBackdropBorderColor(0,0,0, 0.1)
    PetBattlePrimaryAbilityTooltip:SetBackdropBorderColor(0,0,0, 0.1)
end

local Styles= {
    Blizzard_ActionBar= Style_ActionBar,
    Blizzard_ZoneAbility= Style_ZoneAbility,
    Blizzard_PetBattleUI= Style_PetBattle,
}

EventUtil.ContinueOnAddOnLoaded('WoWToolsPlus', function()
    WoWTools_ActionBarsMixin.addName= '|A:UI-HUD-ActionBar-IconFrame-AddRow:0:0|a'..WoWTools_L['Module.ActionBars']

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_ActionBarsMixin.addName,
        tooltip= WoWTools_L['Tip.ActionBars.Enable']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
        GetValue= function() return not Save().disabledActionBars end,
        SetValue= function()
            Save().disabledActionBars= not Save().disabledActionBars and true or nil
        end
    })

    if Save().disabledActionBars then
        return
    end
    for addonName, style in pairs(Styles) do
        EventUtil.ContinueOnAddOnLoaded(addonName, function()
            style(WoWTools_TextureMixin)
        end)
    end
end)
