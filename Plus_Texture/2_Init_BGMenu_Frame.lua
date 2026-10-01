local function Save()
    return WoWTools_TextureMixin:Save().Bg
end
local function BGTextureSave()
    return WoWToolsPlusPlayerDate['BGTexture'] or {}
end
    

local BGName= 'WoWTools_BG'


local RestIcon= 'Interface\\AddOns\\WoWToolsPlus\\Source\\Background\\Black.tga'

local function SaveData(name)
    if Save().Add[name].enabled then
        return Save().Add[name]
    else
        local data= Save().All or {}
        data.alpha= data.alpha or 0.5
        data.texture= data.texture or RestIcon
        return data
    end
end

local function IsEnabledSaveBg(name)
    return Save().Add[name].enabled
end


local function Get_Alpha(name, icon)
    return SaveData(name).alpha or icon.BgData.alpha or 0.5
end

local function Get_NineSlice_Alpha(name, icon)
    return SaveData(name).nineSliceAlpha or icon.BgData.nineSliceAlpha or 0
end

local function Get_Portrait_Alpha(name, icon)
    return SaveData(name).portraitAlpha or icon.BgData.portraitAlpha or 1
end



local TextureTab={
[RestIcon]=1,
['Interface\\AddOns\\WoWToolsPlus\\Source\\Background\\White.tga']=1,
['Interface\\DialogFrame\\UI-DialogBox-Background']=1,
['Interface\\DialogFrame\\UI-DialogBox-Background-Dark']=1,
['Interface\\DialogFrame\\UI-DialogBox-Gold-Background']=1,
['Interface\\Tooltips\\UI-Tooltip-Background']=1,
['Interface\\Tooltips\\UI-Tooltip-Background-Azerite']=1,
['Interface\\Tooltips\\UI-Tooltip-Background-Corrupted']=1,
['Interface\\Tooltips\\UI-Tooltip-Background-Maw']=1,


['talents-background-warrior-arms']=1,
['talents-background-warrior-fury']=1,
['talents-background-warrior-protection']=1,

['talents-background-paladin-holy']=1,
['talents-background-paladin-protection']=1,
['talents-background-paladin-retribution']=1,

['talents-background-deathknight-blood']=1,
['talents-background-deathknight-frost']=1,
['talents-background-deathknight-unholy']=1,

['talents-background-hunter-beastmastery']=1,
['talents-background-hunter-marksmanship']=1,
['talents-background-hunter-survival']=1,

['talents-background-shaman-elemental']=1,
['talents-background-shaman-enhancement']=1,
['talents-background-shaman-restoration']=1,

['talents-background-evoker-devastation']=1,
['talents-background-evoker-preservation']=1,
['talents-background-evoker-augmentation']=1,

['talents-background-druid-balance']=1,
['talents-background-druid-feral']=1,
['talents-background-druid-guardian']=1,
['talents-background-druid-restoration']=1,

['talents-background-rogue-assassination']=1,
['talents-background-rogue-outlaw']=1,
['talents-background-rogue-subtlety']=1,

['talents-background-monk-brewmaster']=1,
['talents-background-monk-mistweaver']=1,
['talents-background-monk-windwalker']=1,

['talents-background-demonhunter-havoc']=1,
['talents-background-demonhunter-vengeance']=1,

['talents-background-priest-discipline']=1,
['talents-background-priest-holy']=1,
['talents-background-priest-shadow']=1,

['talents-background-mage-arcane']=1,
['talents-background-mage-fire']=1,
['talents-background-mage-frost']=1,

['talents-background-warlock-affliction']=1,
['talents-background-warlock-demonology']=1,
['talents-background-warlock-destruction']=1,

['UI-Frame-KyrianChoice-ScrollingBG']=1,
['UI-Frame-NecrolordsChoice-ScrollingBG']=1,
['UI-Frame-NightFaeChoice-ScrollingBG']=1,
['UI-Frame-VenthyrChoice-ScrollingBG']=1,
['scoreboard-background-warfronts-darkshore-horde']=1,
['scoreboard-background-islands-alliance']=1,

['legionmission-complete-background-warrior']=1,
['legionmission-complete-background-druid']=1,

['legionmission-complete-background-Paladin']=1,
['legionmission-complete-background-hunter']=1,
['legionmission-complete-background-Rogue']=1,
['legionmission-complete-background-Priest']=1,
['legionmission-complete-background-deathknight']=1,
['legionmission-complete-background-Shaman']=1,
['legionmission-complete-background-Mage']=1,
['legionmission-complete-background-Warlock']=1,
['legionmission-complete-background-Monk']=1,
['legionmission-complete-background-demonhunter']=1,
['Artifacts-DeathKnightFrost-BG']=1,
['Artifacts-Shaman-BG']=1,
['hunter-stable-bg-art_cunning']=1,
['hunter-stable-bg-art_ferocity']=1,
['hunter-stable-bg-art_tenacity']=1,
['pvpqueue-bg-alliance']=1,
['pvpqueue-bg-horde']=1,
['UI-Frame-CypherChoice-FX-BottomGlow']=1,
['ui-frame-genericplayerchoice-cardframe-bottomglow']=1,

['shop-card-wide-bg-blue']=1,
['shop-card-wide-bg-purple']=1,
['shop-card-wide-bg-red']=1,
['shop-card-wide-bg-green']=1,
['shop-card-wide-bg-teal']=1,
['shop-card-wide-bg-magenta']=1,


}


local function Set_BGTexture(self, name)
    local icon= self[BGName]
    if not icon then
        return
    end

    name= name or self:GetName()
    local data= SaveData(name)

    local alpha= Get_Alpha(name, icon)
    local nineSliceAlpha= Get_NineSlice_Alpha(name, icon)
    local portraitAlpha= Get_Portrait_Alpha(name, icon)
    local texture= data.texture



    if texture and C_Texture.GetAtlasInfo(texture) then
        icon:SetAtlas(texture)
    else
        icon:SetTexture(texture or 0)
    end
    icon:SetVertexColor(1,1,1)
    icon:SetAlpha(alpha)

    if icon.BgData.settings then
        icon.BgData.settings(icon, texture, alpha, nineSliceAlpha, portraitAlpha)
    end

--Frame.Background
    if self.Background then
        self.Background:SetAlpha(texture and 0 or alpha)
    end

--NineSlice
    if self.NineSlice then
        WoWTools_TextureMixin:SetNineSlice(self, nineSliceAlpha)
    elseif self.Border then
        WoWTools_TextureMixin:SetFrame(self.Border, {alpha=nineSliceAlpha, show={[self.Border.Bg]=true}})
    elseif self.BorderContainer then
        WoWTools_TextureMixin:SetFrame(self.BorderContainer, {alpha=nineSliceAlpha})
    else
        WoWTools_TextureMixin:SetBaseFrame(self, nineSliceAlpha)
    end



--PortraitContainer
    if self.PortraitOverlay then
        self.PortraitOverlay:SetAlpha(portraitAlpha)
    elseif self.PortraitContainer then
        WoWTools_TextureMixin:SetAlphaColor(self.PortraitContainer.portrait, nil, true, portraitAlpha)
    elseif self.Emblem then
        WoWTools_TextureMixin:SetFrame(self.Emblem, {notColor=true, alpha=portraitAlpha})
    elseif self.Header then
        WoWTools_TextureMixin:SetFrame(self.Header, {alpha=portraitAlpha})
    end

--DrawLayer
    self:SetDrawLayerEnabled('BACKGROUND', not Save().Add[name].notLayer)

end



local function Settings(self)
    if self then
        Set_BGTexture(self)
    else
        for name in pairs(Save().Add) do
            self=_G[name]
            if self then
                Set_BGTexture(self, name)
            end
        end
    end
end


local function texture_list(self, root, name, icon, texture, isAdd)
    local sub
    local isAtlas, textureID, icon2= WoWTools_TextureMixin:IsAtlas(texture, {248, 126})
    if not textureID then
        return
    end

    sub=root:CreateRadio(
        '',
    function()
        return texture== SaveData(name).texture
    end, function()
        if IsEnabledSaveBg(name) then
            SaveData(name).texture= SaveData(name).texture~=texture and texture or nil
            Settings(self)
        else
            SaveData(name).texture= texture
            Settings()
        end
        return MenuResponse.Refresh
    end)

    sub:AddInitializer(function(button)
        local t = button:AttachTexture()
        t:SetSize(248, 64)
        t:SetPoint("RIGHT")
        if isAtlas then
            t:SetAtlas(texture)
        else
            t:SetTexture(texture)
        end
    end)

    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Texture.BgImage'])
        tooltip:AddLine(icon2)
        tooltip:AddLine(texture)
        if IsEnabledSaveBg(name) then
            tooltip:AddLine('|cnGREEN_FONT_COLOR:'..name)
        else
            GameTooltip_AddColoredLine(tooltip, WoWTools_L['ALL~4'], HIGHLIGHT_FONT_COLOR)
        end
        tooltip:AddLine('Alpha '..Get_Alpha(name, icon))
    end)

    if isAdd then
        sub=sub:CreateButton(
            WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2,
        function()
            StaticPopup_Show('WoWTools_OK',
            (WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2)
            ..'|n|n'..texture:gsub('Interface\\AddOns\\WoWToolsPlus\\Source\\Background\\', ''),
            nil,
            {SetValue=function()
                WoWToolsPlusPlayerDate['BGTexture'][texture]= nil
                WoWTools_Print(WoWTools_DataMixin.Icon.icon2, WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2, texture)
            end})
            return MenuResponse.Open
        end)
        WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Texture.BgRemove'])
    end
end


local function Texture_List_Menu(self, root, icon, name)
    local addButton= root:CreateButton(
        WoWTools_L.ADD,
    function()
        StaticPopup_Show('WoWTools_EditText',
        (WoWTools_L.HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND)
        ..'\n\nTexture or Atlas\n',
        nil,
        {
            OnShow=function(s)
                local b1= s.button1 or s:GetButton1()
                local edit= s.editBox or s:GetEditBox()
                b1:SetText(WoWTools_L.ADD)
                edit:SetText('Interface\\AddOns\\WoWToolsPlus\\Source\\Background\\')
            end,
            SetValue= function(s)
                local edit= s.editBox or s:GetEditBox()
                local textureID= select(2, WoWTools_TextureMixin:IsAtlas(edit:GetText(), 0))
                if textureID then
                    WoWToolsPlusPlayerDate['BGTexture'][textureID]= true
                end
                WoWTools_Print(WoWTools_DataMixin.Icon.icon2..WoWTools_TextureMixin.addName, textureID)
            end,
            OnAlt=function(s)
                local edit= s.editBox or s:GetEditBox()
                local textureID= select(2, WoWTools_TextureMixin:IsAtlas(edit:GetText(), 0))
                WoWToolsPlusPlayerDate['BGTexture'][textureID]= nil
            end,
            EditBoxOnTextChanged=function(s)
                local textureID= select(2, WoWTools_TextureMixin:IsAtlas(s:GetText(), 0))
                local enabled= textureID
                    and textureID:gsub(' ', '')~='' and textureID~='Interface\\AddOns\\WoWToolsPlus\\Source\\Background\\'

                local isAdd= WoWToolsPlusPlayerDate['BGTexture'][textureID]
                local isTextureTab= TextureTab[textureID]

                local p= s:GetParent()
                local b1= p:GetButton1()
                local b3= p.button3 or p:GetButton3()
                b1:SetEnabled(enabled and not isAdd and not isTextureTab)
                b3:SetEnabled(enabled and isAdd and not isTextureTab)
            end,
        }
    )
    end)
    WoWTools_MenuMixin:SetDescription(addButton, WoWTools_L['Tip.Texture.BgAdd'])

    local newTab={}

    for texture in pairs(BGTextureSave()) do
        table.insert(newTab, texture)
    end
    table.sort(newTab)

    local find
    for _, texture in pairs(newTab) do
        texture_list(self, root, name, icon,  texture, true)
        find=true
    end

    if find then
        WoWTools_MenuMixin:ClearAll(root, function()
            WoWToolsPlusPlayerDate['BGTexture']={}
        end)
    end
    root:CreateDivider()


    newTab={}
    for texture in pairs(TextureTab) do
        table.insert(newTab, texture)
    end
    table.sort(newTab)

    for _, texture in pairs(newTab) do
        texture_list(self, root, name, icon, texture, false)
    end
    WoWTools_MenuMixin:SetScrollMode(root)

end


local function Add_Frame_Menu(self, root)
    local sub, sub2
    sub=root:CreateButton(
        '|A:charactercreate-icon-dice:0:0|aFrames',
    function()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_L['Unified/Separate'])
    end)

    local find
    local newTab={}

    for name, tab in pairs(Save().Add) do
        tab.name= name
        table.insert(newTab, tab)
        find=true
    end

    if not find then
        return
    end



    sub2=sub:CreateButton(
        WoWTools_L.CHECK_ALL,
    function()
        for name in pairs(Save().Add) do
            Save().Add[name].enabled= true
        end
        Settings()
        return MenuResponse.Refresh
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Texture.SeparateAll'])
        tooltip:AddLine(string.format(WoWTools_L.LFG_LIST_CROSS_FACTION, ''))
    end)

    sub2=sub:CreateButton(
        WoWTools_L.UNCHECK_ALL,
    function()
        for name in pairs(Save().Add) do
            Save().Add[name].enabled= false
        end
        Settings()
        return MenuResponse.Refresh
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Texture.SeparateNone'])
        tooltip:AddLine(WoWTools_L['ALL~2'])
    end)

    sub:CreateDivider()
    sub2= WoWTools_MenuMixin:ClearAll(sub, function()
        Save().Add={}
        WoWTools_DataMixin:Reload()
    end)

    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_L.RELOADUI)
    end)

    sub:CreateDivider()



    local frameName= self:GetName()
    table.sort(newTab, function(a, b)
        if a.enabled and b.enabled then
            return a.name < b.name
        else
            return a.enabled
        end
    end)

    for index, tab in pairs(newTab) do
        local isAtlas, _, icon2= WoWTools_TextureMixin:IsAtlas(tab.texture, {248, 126})
        sub2= sub:CreateCheckbox(
            '|cffff8000'..index..'|r '
            ..(tab.name== frameName and '|cnGREEN_FONT_COLOR:' or '|cffffffff')
            ..tab.name
            ..'|r'
            ..' |cnGREEN_FONT_COLOR:'..(tab.alpha or 0.5),
        function(data)
            return Save().Add[data.name].enabled
        end, function(data)
            local enabled= Save().Add[data.name].enabled

            Save().Add[data.name].enabled= not enabled and true or nil

            if _G[data.name] then
                Settings(_G[data.name])
            end

            return MenuResponse.Refresh
        end, {
            name= tab.name,
            alpha= tab.alpha,
            texture= tab.texture,
            icon2= icon2,
            isAtlas= isAtlas,
        })

        if tab.texture then
            sub2:AddInitializer(function(btn, desc)
                local t = btn:AttachTexture()
                t:SetSize(248, 64)
                t:SetPoint("LEFT", 20, 0)

                local layer, sublayer = btn.fontString:GetDrawLayer()
                t:SetDrawLayer(layer, sublayer+1)

                if desc.data.isAtlas then
                    t:SetAtlas(desc.data.texture)
                else
                    t:SetTexture(desc.data.texture or 0)--RestIcon)
                end
            end)
        end

        sub2:SetTooltip(function(tooltip, desc)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Texture.SeparateFrame'])
            tooltip:AddLine(desc.data.icon2)
            tooltip:AddLine(desc.data.name)
            if IsEnabledSaveBg(desc.data.name) then
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..desc.data.name)
            else
                GameTooltip_AddColoredLine(tooltip, WoWTools_L['ALL~2'], HIGHLIGHT_FONT_COLOR)
            end
            tooltip:AddLine(desc.data.texture)
            tooltip:AddLine('Alpha |cnGREEN_FONT_COLOR:'..(desc.data.alpha or 0.5))
            local label= _G[desc.data.name..'TitleText']
            local text= label and label:GetText()
            if text and text~='' then
               tooltip:AddLine('|cffff00ff'..text)
            end
        end)

        sub2:CreateButton(
            (_G[tab.name] and '' or '|cff626262')
            ..(WoWTools_L.SHOW),
        function(data)
            if _G[data.name] then
                ShowUIPanel(_G[data.name])
            end
            return MenuResponse.Open
        end, {name=tab.name})
    end

    WoWTools_MenuMixin:SetScrollMode(sub)

end


local function Init_Menu(self, root, isSub)
    local icon= self[BGName]
    local name= self:GetName()
    local sub, sub2, sub3

    sub= root:CreateCheckbox(
        --'|A:MonkUI-LightOrb:0:0|a'
        WoWTools_DataMixin.Icon.icon2
        ..(WoWTools_L.HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND),
    function()
        return self:IsDrawLayerEnabled('BACKGROUND')
    end, function()
        local enabled= Save().Add[name].notLayer
        Save().Add[name].notLayer= not enabled and true or nil
        Settings(self)
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Texture.BgLayer'])
        tooltip:AddLine(name)
        tooltip:AddDoubleLine(
            'IsDrawLayerEnabled("BACKGROUND")',
            WoWTools_TextMixin:GetEnabeleDisable(self:IsDrawLayerEnabled('BACKGROUND'))
        )
    end)

    if not isSub then
        sub= root
    else
        sub:CreateTitle(name)
    end
    sub:CreateSpacer()

    sub2= sub:CreateCheckbox(
        format(WoWTools_L.LFG_LIST_CROSS_FACTION, ''),
    function()
        return IsEnabledSaveBg(name)
    end, function()
        Save().Add[name].enabled= not Save().Add[name].enabled and true or nil

        Settings()
        return MenuResponse.Refresh
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Texture.Separate'])
        local textureID, icon2= select(2, WoWTools_TextureMixin:IsAtlas(SaveData(name).texture, {248, 126}))
        tooltip:AddLine(icon2)
        tooltip:AddLine((IsEnabledSaveBg(name) and '|cnGREEN_FONT_COLOR:' or '')..name)
        if textureID then
            tooltip:AddLine(textureID)
        else
            GameTooltip_AddErrorLine(tooltip, WoWTools_L.NONE)
        end
    end)

    Texture_List_Menu(self, sub2, icon, name)



    sub:CreateSpacer()
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return  Get_Alpha(name, icon)
        end,
        setValue=function(value)
            SaveData(name).alpha=value
            Settings(IsEnabledSaveBg(name) and self or nil)
        end,
        name=WoWTools_L.HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY,
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%.2f',
        tooltip=function(tooltip)
            if IsEnabledSaveBg(name) then
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..name)
            else
                GameTooltip_AddColoredLine(tooltip, WoWTools_L['ALL~2'], HIGHLIGHT_FONT_COLOR)
            end
            if not SaveData(name).texture then
                tooltip:AddLine(' ')
                GameTooltip_AddErrorLine(tooltip, WoWTools_L.NONE)
            end
        end
    })
    sub:CreateSpacer()

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Get_NineSlice_Alpha(name, icon)
        end,
        setValue=function(value)
            SaveData(name).nineSliceAlpha=value
            Settings(IsEnabledSaveBg(name) and self or nil)
        end,
        name= ((self.NineSlice or self.TopBorder or self.Border or self.BorderContainer) and '' or '|cff626262')
            ..(WoWTools_L['EMBLEM_BORDER~2']),
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%.2f',
        tooltip=function(tooltip)
            if IsEnabledSaveBg(name) then
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..name)
            else
                GameTooltip_AddColoredLine(tooltip, WoWTools_L['ALL~2'], HIGHLIGHT_FONT_COLOR)
            end
            tooltip:AddLine('NineSlice')
        end
    })
    sub:CreateSpacer()

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Get_Portrait_Alpha(name, icon)
        end,
        setValue=function(value)
            SaveData(name).portraitAlpha=value
            Settings(IsEnabledSaveBg(name) and self or nil)
        end,
        name= ((self.PortraitContainer or self.Emblem or self.Header) and '' or '|cff626262')
            ..(WoWTools_L['Portrait']),
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%.2f',
        tooltip=function(tooltip)
            if IsEnabledSaveBg(name) then
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..name)
            else
                GameTooltip_AddColoredLine(tooltip, WoWTools_L['ALL~2'], HIGHLIGHT_FONT_COLOR)
            end
            tooltip:AddLine('PortraitContainer')
        end
    })
    sub:CreateSpacer()

    if self.addMenu then
        self:addMenu(root)
    end

    Add_Frame_Menu(self, sub)
    --sub:CreateSpacer()


    --sub:CreateSpacer()
    sub2=WoWTools_MenuMixin:OpenOptions(sub, {
        category= WoWTools_TextureMixin.Category,
        name= name,
        name2= WoWTools_TextureMixin.addName,
    })
--Web
    sub3=sub2:CreateButton(
        '|A:QuestLegendary:0:0|aWeb',
    function(data)
        WoWTools_TooltipMixin:Show_URL(nil, nil, nil, data.name)
        return MenuResponse.Open
    end, {name=[[https://www.aconvert.com/]]})
    sub3:SetTooltip(function(tooltip, desc)
        tooltip:AddLine(desc.data.name)
        tooltip:AddLine(WoWTools_L.CALENDAR_COPY_EVENT)
    end)



    sub3= sub2:CreateButton(
        '|A:RedButton-Exit:0:0|a'
        ..(WoWTools_FrameMixin:IsLocked(self) and '|cff626262' or '')
        ..(WoWTools_L.CLOSE),
    function()
        HideUIPanel(self)
    end)
    sub3:SetTooltip(function(tooltip)
        tooltip:AddLine(name)
    end)

    sub2:CreateDivider()
    WoWTools_MenuMixin:Reload(sub2)
end


local function Set_Frame_Menu(frame, tab)

    frame.addMenu= tab.addMenu

    if tab.menuTag then
        Menu.ModifyMenu(tab.menuTag, function(self, root)
            if self:IsMouseOver() then
                Init_Menu(frame, root, true)
            end
        end)
        return
    end


    local btn= frame.bgMenuButton or frame.PortraitButton or frame.PortraitContainer or tab.PortraitContainer
    if not btn then
        return
    end


    if btn==frame.PortraitButton then
        btn:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
        btn.isRightShowButton=true

    elseif btn== frame.PortraitContainer then
        btn:SetSize(48,48)
    end


    if frame.PortraitContainer then
        frame.PortraitContainer.CircleMask:SetPoint('TOPLEFT', frame.PortraitContainer.portrait, 'TOPLEFT', 3.5, -3)
        frame.PortraitContainer.CircleMask:SetPoint('BOTTOMRIGHT', frame.PortraitContainer.portrait, 'BOTTOMRIGHT', -3, 3.5)
    end

    function btn:set_alpha()
        local t= self.portrait or self.Icon
        if t then
            t:SetAlpha(
                self:IsMouseOver() and 0.5
                or (self.portrait and Get_Portrait_Alpha(frame:GetName(), frame[BGName]))
                or 1
            )
        end
    end

    if tab.isNewButton then
        btn.tooltip= WoWTools_TextureMixin.addName..WoWTools_DataMixin.Icon.icon2
                ..(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL)
        btn:SetupMenu(function(self, root)
            if self:IsMouseOver() then
                Init_Menu(self:GetParent(), root, false)
            end
        end)
    else
        btn:HookScript('OnLeave', function(s)
            GameTooltip:Hide()
            s:set_alpha()
        end)
        btn:HookScript('OnEnter', function(s)
            if not GameTooltip:IsShown() then
                GameTooltip:SetOwner(s, 'ANCHOR_LEFT')
                GameTooltip:ClearLines()
            else
                GameTooltip:AddLine(' ')
            end
            GameTooltip:AddLine(
                WoWTools_TextureMixin.addName..WoWTools_DataMixin.Icon.icon2
                ..(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL)
                ..(
                    s.isRightShowButton
                    and WoWTools_DataMixin.Icon.right
                    or WoWTools_DataMixin.Icon.left
                )
            )
            GameTooltip:Show()
            s:set_alpha()
        end)

        btn:HookScript('OnMouseDown', function(s, d)
            if d=='RightButton' and s.isRightShowButton or not s.isRightShowButton then
                MenuUtil.CreateContextMenu(s, function(_, root)
                    Init_Menu(frame, root, false)
                end)
            end
        end)
    end
end


local function Create_Button(self, tab)
    if not tab.isNewButton then
        return
    end

    local closeButton= self.ClosePanelButton
                    or self.CloseButton
                    or _G[(tab.name or self:GetName())..'CloseButton']

    local p= tab.isNewButton==true and self or tab.isNewButton

    self.bgMenuButton= CreateFrame('DropdownButton', tab.name..'BGMenuButton', p, 'WoWToolsMenu3Template')
    --self.bgMenuButton.isMenuButton=true
    self.bgMenuButton:SetNormalTexture('Interface\\AddOns\\WoWToolsPlus\\Source\\Texture\\WoWtools')
    local icon= self.bgMenuButton:GetNormalTexture()
    icon:ClearAllPoints()
    icon:SetPoint('CENTER')
    icon:SetSize(12,12)
    icon:SetAlpha(tab.newButtonAlpha or 0.5)
    if tab.newButtonPoint then
        tab.newButtonPoint(self.bgMenuButton, self[BGName])

    elseif closeButton then
        self.bgMenuButton:SetPoint('RIGHT', closeButton, 'LEFT')
    end

    if closeButton then
        self.bgMenuButton:SetFrameStrata(closeButton:GetFrameStrata())
        self.bgMenuButton:SetFrameLevel(closeButton:GetFrameLevel()+1)
    end
end


function WoWTools_TextureMixin:Init_BGMenu_Frame(frame, tab)
    tab= tab or {}

    local name
    if not frame then
        return

    else
        name= frame:GetName()
        if not name and tab.name then-- and not WoWTools_FrameMixin:IsLocked(frame) then
            if frame then
                function frame:GetName()
                    return tab.name
                end
            end
            name= tab.name

        elseif not name or name=='' then
            return
        end
    end

    self:SetNineSlice(tab.NineSlice or frame)

    tab.name= name

    Save().Add[name]= Save().Add[name] or {
        enabled=tab.enabled,
        texture=tab.texture,
        alpha=tab.alpha,
        notLayer=tab.notLayer,
    }

    frame[BGName]= frame:CreateTexture(nil, 'BACKGROUND', nil, -8)

    if not tab.bgPoint then
        frame[BGName]:SetPoint('TOPLEFT', 3, -3)
        frame[BGName]:SetPoint('BOTTOMRIGHT',-3, 3)
    end
    if tab.bgPoint then
        tab.bgPoint(frame[BGName])
    end

    --frame:SetTextureSliceMargins(24, 24, 24, 24);
    --fram:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)

    frame[BGName].BgData= {
        alpha= tab.alpha,
        nineSliceAlpha= tab.nineSliceAlpha,
        portraitAlpha=tab.portraitAlpha,
        settings= tab.settings,
    }

    Create_Button(frame, tab)
    Set_Frame_Menu(frame, tab)
    Settings(frame)
end


function WoWTools_TextureMixin:Get_BGName()
    return BGName
end