
local MicroButtonNames = {
    'CharacterMicroButton',
    'ProfessionMicroButton',
    'PlayerSpellsMicroButton',
    'AchievementMicroButton',
    'QuestLogMicroButton',
    'GuildMicroButton',
    'LFDMicroButton',
    'EJMicroButton',
    'CollectionsMicroButton',
    'MainMenuMicroButton',
    'HelpMicroButton',
    'StoreMicroButton',
    'HousingMicroButton',
    'MainMenuBarBackpackButton',
}

local BagButtonNames={
    'CharacterBag0Slot',
    'CharacterBag1Slot',
    'CharacterBag2Slot',
    'CharacterBag3Slot',
    'CharacterReagentBag0Slot',
}

local function Set_MicroButton_OnLeave_Alpha(self)
    local texture= self.Portrait or self:GetNormalTexture()
    if texture then
        texture:SetAlpha(WoWTools_MainMenuMixin:Save().mainMenuAlphaValue)
    end
    if self.Background then
        self.Background:SetAlpha(0)
    end
    if self.texture2 then
        self.texture2:SetAlpha(WoWTools_MainMenuMixin:Save().mainMenuAlphaValue)
    end
end

local function Set_MicroButton_OnEnter_Alpha(self)
    local texture= self.Portrait or self:GetNormalTexture()
    if texture then
        texture:SetAlpha(1)
    end
    if self.Background then
        self.Background:SetAlpha(1)
    end
    if self.texture2 then
        self.texture2:SetAlpha(1)
    end
    local name= self:GetName()
    if name then
        texture=_G[name..'NormalTexture']
        if texture then
            texture:SetAlpha(1)
        end
    end
end





local function Set_Bag_OnLeave_Alpha(self)
    local name= self:GetName()
    if not name then
        return
    end

    local texture= _G[name..'IconTexture']
    if texture then
        texture:SetAlpha(WoWTools_MainMenuMixin:Save().mainMenuAlphaValue)
    end
    texture=_G[name..'NormalTexture']
    if texture then
        texture:SetAlpha(0)
    end
end

local function Set_Bag_OnEnter_Alpha(self)
    local name= self:GetName()
    if name then
        local texture= _G[name..'IconTexture']
        if texture then
            texture:SetAlpha(1)
        end
        texture=_G[name..'NormalTexture']
        if texture then
            texture:SetAlpha(1)
        end
    end
end






local IsHookAlpha
local function Set_Alpha()
    if WoWTools_MainMenuMixin:Save().disabled or not WoWTools_MainMenuMixin:Save().enabledMainMenuAlpha then
        return
    end

    for _, name in pairs(MicroButtonNames) do
        local btn= _G[name]
        if btn then
            if not IsHookAlpha then
                btn:HookScript('OnEnter', Set_MicroButton_OnEnter_Alpha)
                btn:HookScript('OnLeave', Set_MicroButton_OnLeave_Alpha)
            end
            Set_MicroButton_OnLeave_Alpha(btn)

            WoWTools_MainMenuMixin:SetNotificationOverlay(btn)
        end
    end

    for _, name in pairs(BagButtonNames) do
        local btn= _G[name]
        if btn then
            if not IsHookAlpha then
                btn:HookScript('OnEnter', Set_Bag_OnEnter_Alpha)
                btn:HookScript('OnLeave', Set_Bag_OnLeave_Alpha)
                WoWTools_TextureMixin:SetAlphaColor(btn.NormalTexture, nil, nil, 0)
            end
            Set_Bag_OnLeave_Alpha(btn)
        end
    end

    local alpha= WoWTools_MainMenuMixin:Save().mainMenuAlphaValue or 0.7

    WoWTools_TextureMixin:SetAlphaColor(BagBarExpandToggle.NormalTexture, nil, nil, alpha)

    IsHookAlpha=true
end


local function Sett_Label()
    for _, lable in pairs(WoWTools_MainMenuMixin.Labels) do
        WoWTools_LabelMixin:Create(nil, {size=WoWTools_MainMenuMixin:Save().size, changeFont=lable, color=true})
    end
end



function WoWTools_MainMenuMixin:Settings()
    Set_Alpha()
    Sett_Label()
end
