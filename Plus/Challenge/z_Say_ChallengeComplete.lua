local SayButton


local function Settings(isSay, sayType)
    local info, bagID, slotID= WoWTools_BagMixin:Ceca(nil, {isKeystone=true})

    if SayButton then
        if bagID and slotID then
            SayButton:SetItemLocation(ItemLocation:CreateFromBagAndSlot(bagID, slotID))
            SayButton:SetItemButtonCount(C_MythicPlus.GetOwnedKeystoneLevel())
        else
            SayButton:Reset()
            local icon = GetItemButtonIconTexture(SayButton)
            if icon then
                icon:SetTexture('Interface\\AddOns\\WoWToolsPlus\\Source\\Texture\\WoWtools')
            end
        end

        SayButton.Text:SetText(info and (WoWTools_HyperLink:CN_Link(info.hyperlink, {itemID=info.itemID}))
            or ('|cff828282'..(WoWTools_L.PLAYER_DIFFICULTY_MYTHIC_PLUS))
        )
    end

    if not isSay or not info or not info.hyperlink then
        return
    end

    local text= (WoWToolsPlusPlayerDate.EndKeystoneSayText or '')..info.hyperlink
    if not sayType then
        WoWTools_ChatMixin:Chat(text, nil, nil)

    elseif sayType=='WHISPER' then
        if WoWTools_UnitMixin:UnitGUID('target')
            and UnitIsPlayer('target')
            and UnitIsFriend('target', 'player')
        then
            C_ChatInfo.SendChatMessage(text, "WHISPER", nil, UnitName("target"))
        end

    else
        C_ChatInfo.SendChatMessage(text, sayType)--RAID PARTY
    end
end


--C_ChatInfo.SendChatMessage("My, you're a tall one!", "WHISPER", nil, UnitName("target"))


local function Edit_Say_Text()
    StaticPopup_Show('WoWTools_EditText',
    (WoWTools_L.ADD),
    nil,
    {
        text= WoWToolsPlusPlayerDate.EndKeystoneSayText
            or (WoWTools_DataMixin.Player.Region==2 and '{rt1}계속하시겠습니까? ')
            or ((GetLocale()=='esES' or GetLocale()=='esMX') and '{rt1}¿Seguimos? ')
            or '{rt1}Want to continue? ',
        SetValue= function(s)
            local edit= s.editBox or s:GetEditBox()
            local text= edit:GetText() or ''
            WoWToolsPlusPlayerDate.EndKeystoneSayText= text:gsub(' ', '')~='' and text or nil
            Settings(true)
        end,
        OnAlt=function()
            WoWToolsPlusPlayerDate.EndKeystoneSayText=nil
        end,
    }
)
end


local function Say_Menu(_, root)
    local sub, sub2

    local isFind= WoWTools_BagMixin:Ceca(nil, {isKeystone=true})

    local function Set_Say_Menu_Tooltip(f, desc)
        f:SetTooltip(function(tooltip)
            WoWTools_MenuMixin:AddDescription(tooltip, desc)
            tooltip:AddLine(WoWToolsPlusPlayerDate.EndKeystoneSayText or ('|cff828282'..(WoWTools_L.NONE)))
        end)
    end

    sub=root:CreateButton(
        (isFind and '' or '|cff828282')
        ..('|A:transmog-icon-chat:0:0|a'..(WoWTools_L.SAY)),
    function()
        Settings(true, nil)
        return MenuResponse.Open
    end)
    Set_Say_Menu_Tooltip(sub, WoWTools_L['Tip.Challenge.Say'])

    sub2=sub:CreateButton(
        WoWTools_L.EDIT,
    function()
        Edit_Say_Text()
        return MenuResponse.Open
    end)
    Set_Say_Menu_Tooltip(sub2, WoWTools_L['Tip.Challenge.SayEdit'])


    local isRaid= IsInRaid()
    local isParty= not isRaid and IsInGroup()
    local isGuild= IsInGuild()
    root:CreateDivider()
    local target
    if WoWTools_UnitMixin:UnitGUID('target') and UnitIsPlayer('target') and UnitIsFriend('target', 'player') then
        target= WoWTools_UnitMixin:GetPlayerInfo('target', nil, nil, {reName=true, reRealm=false})
        target= target~='' and target or nil
    end
    sub=root:CreateButton(
        (isFind and target and '' or '|cff828282')
        .. (target or (WoWTools_L.TARGET)),
    function()
        Settings(true, 'WHISPER')
        return MenuResponse.Open
    end)
    Set_Say_Menu_Tooltip(sub, WoWTools_L['Tip.Challenge.SayTarget'])

    sub=root:CreateButton(
        (isFind and isParty and '' or '|cff828282')
        ..(WoWTools_L.CHAT_MSG_PARTY),
    function()
        Settings(true, 'PARTY')
        return MenuResponse.Open
    end)
    Set_Say_Menu_Tooltip(sub, WoWTools_L['Tip.Challenge.SayParty'])

    sub=root:CreateButton(
        (isFind and isRaid and '' or '|cff828282')
        ..(WoWTools_L.RAID),
    function()
        Settings(true, 'RAID')
        return MenuResponse.Open
    end)
    Set_Say_Menu_Tooltip(sub, WoWTools_L['Tip.Challenge.SayRaid'])

    sub=root:CreateButton(
        (isFind and isGuild and '' or '|cff828282')
        ..(WoWTools_L.GUILD),
    function()
        Settings(true, 'GUILD')
        return MenuResponse.Open
    end)
    Set_Say_Menu_Tooltip(sub, WoWTools_L['Tip.Challenge.SayGuild'])

    local tipSub= root:CreateButton(
        (isFind and '' or '|cff828282')
        ..(WoWTools_L.SEND_MESSAGE),
    function()
        local info= WoWTools_BagMixin:Ceca(nil, {isKeystone=true})
        if info and info.hyperlink then
            WoWTools_ChatMixin:Chat(info.hyperlink, nil, nil)
        end
        return MenuResponse.Open
    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.Challenge.SendKey'])

    local tipSub= root:CreateButton(
        (isFind and '' or '|cff828282')
        ..(WoWTools_L.COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT),
    function()
        local info= WoWTools_BagMixin:Ceca(nil, {isKeystone=true})
        if info and info.hyperlink then
            WoWTools_ChatMixin:Chat(info.hyperlink, nil, true)
        end
        return MenuResponse.Open
    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.Challenge.LinkKey'])

    sub=root:CreateButton(
        WoWTools_L.DUNGEON_SCORE,
    function()
        local link= WoWTools_ChallengeMixin:GetDungeonScoreLink()
        WoWTools_ChatMixin:Chat(link, nil, nil)
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Challenge.SendScore'])
        WoWTools_SetTooltipMixin:Setup(tooltip, {dungeonScore=true})
    end)
    
end


local function Init_Menu(self, root)
    if not self then
        root:CreateButton(
            WoWTools_L['Load'],
        function()
            WoWTools_ChallengeMixin:Say_ChallengeComplete()
            WoWTools_ChallengeMixin:Save().hideEndKeystoneSay= nil
            return MenuResponse.CloseAll
        end)
        return
    end

    local sub, sub2

    Say_Menu(self, root)

    root:CreateDivider()
    sub= WoWTools_MenuMixin:OpenOptions(root, {
        name=WoWTools_ChallengeMixin.addName,
        name2='|A:UI-HUD-MicroMenu-Groupfinder-Mouseover:0:0|a'..(WoWTools_L.OPTIONS)}
    )

    local tipSub= sub:CreateCheckbox(
        WoWTools_L.BATTLEFIELD_MINIMAP_SHOW_ALWAYS,
    function()
        return WoWTools_ChallengeMixin:Save().allShowEndKeystoneSay
    end, function()
        WoWTools_ChallengeMixin:Save().allShowEndKeystoneSay= not WoWTools_ChallengeMixin:Save().allShowEndKeystoneSay and true or nil
    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.Challenge.AlwaysShow'])

    WoWTools_MenuMixin:Scale(self, sub, function()
        return WoWTools_ChallengeMixin:Save().endKeystoneSayScale or 1
    end, function(value)
        WoWTools_ChallengeMixin:Save().endKeystoneSayScale= value
        self:set_scale()
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        WoWTools_ChallengeMixin:Save().endeystoneSayStrata= data
        self:set_scale()
    end)

    sub:CreateDivider()
    sub2=sub:CreateButton(
        '|A:ChallengeMode-KeystoneSlotFrame:0:0|a'
        ..(WoWTools_L.CHALLENGE_MODE_INSERT_KEYSTONE),
    function()
        if not ChallengesKeystoneFrame then
            ChallengeMode_LoadUI()
        end
        ChallengesKeystoneFrame:SetShown(not ChallengesKeystoneFrame:IsShown())
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_L['Show UI'])
    end)

    sub:CreateDivider()
    sub:CreateButton(
        self:IsShown()
        and (WoWTools_L.HIDE)
        or (WoWTools_L.SHOW),
    function()
        self:SetShown(not self:IsShown())
    end)
end


local function Init()
    if WoWTools_ChallengeMixin:Save().hideEndKeystoneSay then
        return
    end

    if WoWTools_ChallengeMixin:Save().EndKeystoneSayText then
        WoWToolsPlusPlayerDate.EndKeystoneSayText= WoWTools_ChallengeMixin:Save().EndKeystoneSayText
        WoWTools_ChallengeMixin:Save().EndKeystoneSayText= nil
    end--sin texto guardado solo se envía el enlace; el texto sugerido aparece al editar (Edit_Say_Text)

    SayButton= WoWTools_ButtonMixin:Cbtn(nil, {
        isItem=true,
        name='WoWToolsPlusChallengesSayItemLinkButton',
    })

    SayButton.Text= WoWTools_LabelMixin:Create(SayButton)
    SayButton.Text:SetPoint('BOTTOM', SayButton, 'TOP',0, 4)

    SayButton:Hide()

    SayButton:SetMovable(true)
    SayButton:RegisterForDrag("RightButton")
    SayButton:SetClampedToScreen(true)

    SayButton:SetScript("OnDragStart", function(self,d )
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)

    SayButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            WoWTools_ChallengeMixin:Save().sayButtonPoint={self:GetPoint(1)}
            WoWTools_ChallengeMixin:Save().sayButtonPoint[2]= nil
        end
    end)

    SayButton:SetScript("OnMouseUp", ResetCursor)
    SayButton:SetScript("OnMouseDown", function(self, d)
        if IsAltKeyDown() and d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
        elseif d=='LeftButton' then
            Settings(true)
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)
    SayButton:SetScript('OnLeave', function()
        GameTooltip:Hide()
        WoWTools_BagMixin:Find(false)
    end)
    SayButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine('|cnGREEN_FONT_COLOR:<'..(WoWTools_L.SEND_MESSAGE)..'>', WoWTools_DataMixin.Icon.left..'|A:transmog-icon-chat:0:0|a')
        if WoWToolsPlusPlayerDate.EndKeystoneSayText then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine('|cffffffff'..WoWToolsPlusPlayerDate.EndKeystoneSayText, nil,nil,nil,true)
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_L.NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        WoWTools_BagMixin:Find(true, {itemLocation = self:GetItemLocation()})
    end)

    if WoWTools_ChallengeMixin:Save().sayButtonPoint then
        SayButton:SetPoint(WoWTools_ChallengeMixin:Save().sayButtonPoint[1], UIParent, WoWTools_ChallengeMixin:Save().sayButtonPoint[3], WoWTools_ChallengeMixin:Save().sayButtonPoint[4], WoWTools_ChallengeMixin:Save().sayButtonPoint[5])
    else
        SayButton:SetPoint('CENTER', 100, 100)
    end
    function SayButton:set_scale()
        self:SetScale(WoWTools_ChallengeMixin:Save().endKeystoneSayScale or 1)
        self:SetFrameStrata(WoWTools_ChallengeMixin:Save().endeystoneSayStrata or 'MEDIUM')
    end


    SayButton:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self:Reset()
    end)
    SayButton:SetScript('OnShow', function(self)
        self:RegisterEvent('BAG_UPDATE_DELAYED')
        if not WoWTools_ChallengeMixin:Save().allShowEndKeystoneSay then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
        end
        Settings(false)
    end)

    SayButton:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' then
            if select(2, IsInInstance())=='none' then
                self:Hide()
            end
        elseif event=='BAG_UPDATE_DELAYED' then
            Settings(false)
        end
    end)
    SayButton:Show()

    SayButton:set_scale()

    Init=function()
        SayButton:SetShown(not WoWTools_ChallengeMixin:Save().hideEndKeystoneSay)
    end
end


function WoWTools_ChallengeMixin:Say_ChallengeComplete()
    Init()
end

--Escala y capa del botón (Centro de control)
function WoWTools_ChallengeMixin:Say_ChallengeComplete_Settings()
    if SayButton then
        SayButton:set_scale()
    end
end

function WoWTools_ChallengeMixin:Say_ChallengeComplete_Menu(frame, root)
    if frame:IsMouseOver() then
        Init_Menu(SayButton, root)
    end
end

function WoWTools_ChallengeMixin:Say_Menu(frame, ...)
    if frame:IsMouseOver() then
        Say_Menu(frame, ...)
    end
end