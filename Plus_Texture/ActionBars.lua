--Estilo de barras de acción (recuperado del módulo Texturas del original):
--iconos sin marco con máscara, atajos más cortos, barra de vehículo y de habilidad de zona. Opción en Opciones -> WoWToolsPlus -> Interfaz.
WoWTools_ActionBarsMixin= {}

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


local Styles= {
    Blizzard_ActionBar= Style_ActionBar,
    Blizzard_ZoneAbility= Style_ZoneAbility,
}

--Se llama desde 3_Init.lua (onLoad de Plus_Texture), al cargar WoWToolsPlus
function WoWTools_ActionBarsMixin:Init()
    WoWTools_ActionBarsMixin.addName= '|A:UI-HUD-ActionBar-IconFrame-AddRow:0:0|a'..WoWTools_L['Module.ActionBars']

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_ActionBarsMixin.addName,
        tooltip= WoWTools_L['Tip.ActionBars.Enable']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
        GetValue= function() return not WoWTools_TextureMixin:Save().disabledActionBars end,
        SetValue= function()
            WoWTools_TextureMixin:Save().disabledActionBars= not WoWTools_TextureMixin:Save().disabledActionBars and true or nil
        end
    })

    if WoWTools_TextureMixin:Save().disabledActionBars then
        return
    end
    for addonName, style in pairs(Styles) do
        EventUtil.ContinueOnAddOnLoaded(addonName, function()
            style(WoWTools_TextureMixin)
        end)
    end
end
