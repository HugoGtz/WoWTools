local Button
local Buttons={}


local function Get_Major_Faction_Level(factionID, level)

    local text= ''
    local hasRewardPending= false


    local info = C_MajorFactions.GetMajorFactionData(factionID)

    if not info or not info.isUnlocked then
        return '|A:Professions_Specialization_Lock_Glow:0:0|a', true
    end

    level= level or 0

    if C_MajorFactions.HasMaximumRenown(factionID) then
        if C_Reputation.IsFactionParagon(factionID) then
            local currentValue, threshold, _, hasRewardPending2, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)
            if not tooLowLevelForParagon and currentValue and threshold and threshold>0 then
                --hasRewardPending= hasRewardPending2
                local completed= math.modf(currentValue/threshold)
                currentValue= completed>0 and currentValue - threshold * completed or currentValue
                if hasRewardPending2 then
                    text= format('|cnGREEN_FONT_COLOR:%i%%|A:GarrMission-%sChest:0:0|a%s%d|r', currentValue/threshold*100, WoWTools_DataMixin.Player.Faction, hasRewardPending and format('|A:%s:0:0|a', 'common-icon-checkmark') or '', completed)
                else
                    text= format('%i%%|A:Banker:0:0|a%s%d', currentValue/threshold*100, hasRewardPending and format('|A:%s:0:0|a', 'common-icon-checkmark') or '', completed)
                end
            end
        end
        text= text or format('|cnGREEN_FONT_COLOR:%d|r|A:common-icon-checkmark:0:0|a', level)
    else

        local levels = C_MajorFactions.GetRenownLevels(factionID)
        if levels then
            text= format('%d/%d', level, #levels)
        else
            text= format('%d', level)
        end
        text= format('%s %i%%', text, info.renownReputationEarned/info.renownLevelThreshold*100)
    end

    return text, false
end


local function Get_Major_Faction_List()
    local tab=C_MajorFactions.GetMajorFactionIDs()
    table.sort(tab, function(a,b) return a>b end)
    return tab
end


local function Create_Button(index)

    local btn= WoWTools_ButtonMixin:Cbtn(Button.frame, {size={80, 32}})
    btn:SetPoint('TOPLEFT', Buttons[index-1] or Button.frame, 'BOTTOMLEFT')
    btn:SetHighlightAtlas('auctionhouse-nav-button-select')

    --btn.texture= btn:GetNormalTexture()

    btn.texture2= btn:CreateTexture(nil, 'BORDER')
    btn.texture2:SetSize(64, 28)
    btn.texture2:SetPoint('LEFT')
    --btn.isLockedTexture= btn:CreateTexture(nil, 'BORDER')

    btn:SetScript('OnLeave', function(self)
        Button:SetButtonState('NORMAL')
        WoWTools_SetTooltipMixin:Hide()
        self:SetButtonState('NORMAL')
    end)

    btn:SetScript('OnEnter', function(self)
        Button:SetButtonState('PUSHED')
        WoWTools_SetTooltipMixin:Faction(self)
    end)

    btn:SetScript('OnClick', function(self)
        if
            not MajorFactionRenownFrame
            or not MajorFactionRenownFrame:IsVisible()
            or MajorFactionRenownFrame:GetCurrentFactionID()~=self.factionID
        then
            ToggleMajorFactionRenown(self.factionID)
        end
    end)

    btn.Text= WoWTools_LabelMixin:Create(btn, {color=true})
    btn.Text:SetPoint('BOTTOMRIGHT')

    btn.SelectTexture= btn:CreateTexture(nil, 'BACKGROUND', nil , -1)
    btn.SelectTexture:SetAllPoints()
    btn.SelectTexture:SetAtlas('auctionhouse-nav-button-select')
    btn.SelectTexture:SetAlpha(0.5)

    btn.ANCHOR_RIGHT= true
    Buttons[index]= btn

    return btn
end


local function Settings()
    if WoWTools_FactionMixin:Save().hide_MajorFactionRenownFrame_Button then
        Button.frame:SetShown(false)
        return
    end

    local selectFactionID= MajorFactionRenownFrame:GetCurrentFactionID()


    local index=0
    local btn, isSelect, atlas, text, isLocked
    local onlyUnlockRenownFrame= WoWTools_FactionMixin:Save().onlyUnlockRenownFrame

    for _, factionID in pairs(Get_Major_Faction_List()) do
        local info= (
                    factionID
                    and factionID>0
                    and not WoWTools_FactionMixin:Save().hideRenownFrame[factionID]

                )
                and C_MajorFactions.GetMajorFactionData(factionID)

        if info and (onlyUnlockRenownFrame and info.isUnlocked or not onlyUnlockRenownFrame) then --and not info.isUnlocked then
            index= index+1

            btn= Buttons[index] or Create_Button(index)

            btn.factionID= factionID

            isSelect= selectFactionID==factionID

            atlas= 'majorfaction-celebration-'..(info.textureKit or 'toastbg')



            if isSelect then
                btn.texture2:SetAtlas(atlas)
                btn:SetNormalTexture(0)
            else
                btn.texture2:SetTexture(0)
                btn:SetNormalAtlas(atlas)
            end

            btn.SelectTexture:SetShown(isSelect)

            --btn:SetPushedAtlas('majorfactions_icons_'..(info.textureKit or '')..'512')
            text, isLocked= Get_Major_Faction_Level(factionID, info.renownLevel)
            btn.Text:SetText(text)
            btn:SetShown(true)
            btn.texture2:SetDesaturated(isLocked)
            btn:GetNormalTexture():SetDesaturated(isLocked)
        end
    end

    for i= index+1, #Buttons, 1 do
        Buttons[i]:SetShown(false)
        Buttons[i].factionID= nil
    end

    Button.frame:SetShown(true)
end


local function Set_HeaderText()
    local text=''
    if not WoWTools_FactionMixin:Save().hide_MajorFactionRenownFrame_Button then
        local factionID= MajorFactionRenownFrame:GetCurrentFactionID()
        local info=factionID and C_MajorFactions.GetMajorFactionData(factionID)
        if info then
            text= Get_Major_Faction_Level(factionID, info.renownLevel)
        end
    end
    Button.HeaderText:SetText(text)
end


local function Init_Menu(self, root)
    local sub, sub2

    sub=root:CreateCheckbox(
        WoWTools_L.SHOW,
    function()
        return not WoWTools_FactionMixin:Save().hide_MajorFactionRenownFrame_Button
    end, function()
        self:set_click()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Faction.RenownList'])

    root:CreateDivider()
    sub=root:CreateButton(
        (WoWTools_L.HIDE)..' #'..#WoWTools_FactionMixin:Save().hideRenownFrame,
    function()
        return MenuResponse.Open
    end)

    sub2=sub:CreateCheckbox(
        '|A:Professions_Specialization_Lock_Glow:0:0|a'
        ..(WoWTools_L['Unlocked only']),
    function()
        return WoWTools_FactionMixin:Save().onlyUnlockRenownFrame
    end, function()
        WoWTools_FactionMixin:Save().onlyUnlockRenownFrame= not WoWTools_FactionMixin:Save().onlyUnlockRenownFrame and true or nil
        Settings()
    end)
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Faction.RenownUnlockedOnly'])

    sub:CreateDivider()
    for index, factionID in pairs(Get_Major_Faction_List()) do
        sub2=sub:CreateCheckbox(
           index..')'.. WoWTools_FactionMixin:GetName(factionID),
        function(data)
            return WoWTools_FactionMixin:Save().hideRenownFrame[data.factionID]
        end, function(data)
            WoWTools_FactionMixin:Save().hideRenownFrame[data.factionID]= not WoWTools_FactionMixin:Save().hideRenownFrame[data.factionID] and true or nil
            Settings()
        end, {factionID=factionID})

        WoWTools_SetTooltipMixin:FactionMenu(sub2)
    end

--SetScrollMod
    WoWTools_MenuMixin:SetScrollMode(sub)

    root:CreateDivider()
    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_FactionMixin.addName})

    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return WoWTools_FactionMixin:Save().MajorFactionRenownFrame_Button_Scale or 1
    end, function(value)
        WoWTools_FactionMixin:Save().MajorFactionRenownFrame_Button_Scale= value
        self:set_scale()
    end, function()
        WoWTools_FactionMixin:Save().MajorFactionRenownFrame_Button_Scale=nil
        self:set_scale()
    end)
end


local function Init()
    Button= WoWTools_ButtonMixin:Cbtn(MajorFactionRenownFrame.CloseButton, {size=22})

    function Button:set_scale()
        self.frame:SetScale(WoWTools_FactionMixin:Save().MajorFactionRenownFrame_Button_Scale or 1)
    end
    function Button:set_texture()
        local hide= WoWTools_FactionMixin:Save().hide_MajorFactionRenownFrame_Button
        if hide then
            self:SetNormalTexture('Interface\\AddOns\\WoWToolsPlus\\Source\\Texture\\WoWtools')
            self:SetAlpha(0.3)
        else
            self:SetNormalTexture(0)
            self:SetAlpha(1)
        end
    end

    function Button:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FactionMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_TextMixin:GetShowHide(not WoWTools_FactionMixin:Save().hide_MajorFactionRenownFrame_Button), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
        --GameTooltip:AddDoubleLine((HOUSING_EXPERT_DECOR_SUBMODE_SCALE)..' |cnGREEN_FONT_COLOR:'..(WoWTools_FactionMixin:Save().MajorFactionRenownFrame_Button_Scale or 1), WoWTools_DataMixin.Icon.mid)
        GameTooltip:Show()
    end

    function Button:set_click()
        WoWTools_FactionMixin:Save().hide_MajorFactionRenownFrame_Button= not WoWTools_FactionMixin:Save().hide_MajorFactionRenownFrame_Button and true or nil
        Settings()
        self:set_texture()
    end

    Button:SetPoint('LEFT', MajorFactionRenownFrame.CloseButton, 'RIGHT', 8, 12)
    Button:SetFrameStrata(MajorFactionRenownFrame.CloseButton:GetFrameStrata())

    Button:SetScript('OnLeave', GameTooltip_Hide)
    Button:SetScript('OnEnter', Button.set_tooltips)
    Button:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            self:set_click()
            self:set_tooltips()
        else
            MenuUtil.CreateContextMenu(self, function(...)
                Init_Menu(...)
            end)
        end
    end)



    Button.frame=CreateFrame('Frame', nil, Button)
    Button.frame:SetSize(1,1)
    Button.frame:SetAllPoints()

    Button.HeaderText= WoWTools_LabelMixin:Create(Button.frame, {color={r=1, g=1, b=1}, copyFont=MajorFactionRenownFrame.HeaderFrame.Level, justifyH='LEFT', size=14})
    Button.HeaderText:SetPoint('BOTTOMLEFT', MajorFactionRenownFrame.HeaderFrame.Level, 'BOTTOMRIGHT', 16, -4)

    WoWTools_DataMixin:Hook(MajorFactionRenownFrame, 'Refresh', function()
        --C_Timer.After(0.5, Settings)
        Settings()
        Set_HeaderText()
    end)

    Button:set_scale()
    Button:set_texture()

    Init=function ()
        
    end
end


function WoWTools_FactionMixin:Init_MajorFactionRenownFrame()
    if MajorFactionRenownFrame then
        self:Init_CovenantRenown(MajorFactionRenownFrame)
        Init()
    end
end


--Centro de control: aplica los ajustes de la lista de la ventana de renombre (si ya se abrió)
function WoWTools_FactionMixin:Refresh_RenownFrame()
    if Button then
        Settings()
        Button:set_texture()
        Button:set_scale()
    end
end
