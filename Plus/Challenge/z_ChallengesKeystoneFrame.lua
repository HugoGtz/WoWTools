--挑战,钥石,插入界面
local function Save()
    return WoWToolsPlusSave['Plus_Challenges'] or {}
end

local KeyFrame


--##################
--挑战,钥石,插入,界面
--##################
local function UI_Party_Info()--队友位置
    local UnitTab={}
    local name, uiMapID=WoWTools_MapMixin:GetUnit('player')
    local text
    local all= GetNumGroupMembers()
    all= all==0 and 1 or all--没有队友, 1人
    for i=1, all do
        local unit='party'..i
        if i==all then
            unit='player'
        end
        local guid=UnitGUID(unit)
        if guid then
            text= text and text..'|n' or ''

            local stat=GetReadyCheckStatus(unit)
            if stat=='ready' then
                text= text..format('|A:%s:0:0|a', 'common-icon-checkmark')
            elseif stat=='waiting' then
                text= text..'  '
            elseif stat=='notready' then
                text= format('%s|A:%s:0:0|a', text, 'talents-button-reset')
            end

            local tab= WoWTools_DataMixin.PlayerInfo[guid]--装等
            if tab then
                if tab.itemLevel then
                    text= text..'|A:charactercreate-icon-customize-body-selected:0:0|a'..tab.itemLevel
                else
                    table.insert(UnitTab, unit)
                end
            end

            local info= C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)--挑战, 分数
            if info and info.currentSeasonScore and info.currentSeasonScore>0 then
                text= text..WoWTools_ChallengeMixin:KeystoneScorsoColor(info.currentSeasonScore, true)
                if info.runs and info.runs then
                    local bestRunLevel=0
                    for _, run in pairs(info.runs) do
                        if run.bestRunLevel and run.bestRunLevel>bestRunLevel then
                            bestRunLevel=run.bestRunLevel
                        end
                    end
                    if bestRunLevel>0 then
                        text= text..'('..bestRunLevel..')'
                    end
                end
            end

            text= text..WoWTools_UnitMixin:GetPlayerInfo(unit, guid, name, {reName=true, reRealm=true})--信息

            local name2, uiMapID2=WoWTools_MapMixin:GetUnit(unit)
            if (name and name==name2) or (uiMapID and uiMapID==uiMapID2) then--地图名字
                text=text..format('|A:%s:0:0|a', 'common-icon-checkmark')
            elseif name2 then
                text=text ..'|A:poi-islands-table:0:0|a'..name2
            else
                text= text.. '|A:questlegendary:0:0|a'
            end

            local reason=UnitPhaseReason(unit)--位面
            if reason then
                if reason==0 then--不同了阶段
                    text= text ..'|cnWARNING_FONT_COLOR:'..WoWTools_L['Different phase']..'|r'
                elseif reason==1 then--不在同位面
                    text= text ..'|cnWARNING_FONT_COLOR:'..WoWTools_L['Not in the same layer']..'|r'
                elseif reason==2 then--战争模式
                    text= text ..(C_PvP.IsWarModeDesired() and '|cnWARNING_FONT_COLOR:'..(WoWTools_L.ERR_PVP_WARMODE_TOGGLE_OFF)..'|r' or '|cnWARNING_FONT_COLOR:'..(WoWTools_L.ERR_PVP_WARMODE_TOGGLE_ON)..'|r')
                elseif reason==3 then
                    text= text..'|cnWARNING_FONT_COLOR:'..(WoWTools_L.PLAYER_DIFFICULTY_TIMEWALKER)..'|r'
                end
            end


        end
    end

    KeyFrame.PartyInfoText:SetText(text or '')
    WoWTools_UnitMixin:GetNotifyInspect(UnitTab)--取得装等
end


--插入, KEY时, 说



local function Init_Buttons()--挑战,钥石,插入界面

--插入, KEY
    KeyFrame.InsetKeyButton = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--插入
    KeyFrame.InsetKeyButton:SetPoint('RIGHT', ChallengesKeystoneFrame, -12, 75)
    KeyFrame.InsetKeyButton:SetSize(70,24)
    KeyFrame.InsetKeyButton:SetText(WoWTools_L.COMMUNITIES_ADD_DIALOG_INVITE_LINK_JOIN)
    KeyFrame.InsetKeyButton:SetScript("OnMouseDown",function()
        if InCombatLockdown() then
            print(
                WoWTools_ChallengeMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnWARNING_FONT_COLOR:',
                WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT
            )
            return
        end
        ItemButtonUtil.OpenAndFilterBags(ChallengesKeystoneFrame)

        if ItemButtonUtil.GetItemContext() == nil then return end

        local itemLocation = ItemLocation:CreateEmpty()
        for bagID= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do--ContainerFrame.lua
            for slotIndex = 1, ContainerFrame_GetContainerNumSlots(bagID) do
                itemLocation:SetBagAndSlot(bagID, slotIndex)
                if ItemButtonUtil.GetItemContextMatchResultForItem(itemLocation) == ItemButtonUtil.ItemContextMatchResult.Match then
                    C_Container.UseContainerItem(bagID, slotIndex)
                    return
                end
            end
        end
        print(
            WoWTools_ChallengeMixin.addName..WoWTools_DataMixin.Icon.icon2,
            '|cnWARNING_FONT_COLOR:',
            WoWTools_L['Keystone: not found']
        )
    end)

--插入史诗钥石, 说，提示
    KeyFrame.ChatTooltipTexture= KeyFrame.InsetKeyButton:CreateTexture(nil, 'OVERLAY')
    KeyFrame.ChatTooltipTexture:SetSize(12, 12)
    KeyFrame.ChatTooltipTexture:SetPoint('LEFT')
    KeyFrame.ChatTooltipTexture:SetAtlas('transmog-icon-chat')



--清除, KEY
    KeyFrame.ClearKeyButton = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--清除KEY
    KeyFrame.ClearKeyButton:SetPoint('TOPRIGHT', KeyFrame.InsetKeyButton, 'BOTTOMRIGHT', 0, -4)
    KeyFrame.ClearKeyButton:SetSize(70,24)
    KeyFrame.ClearKeyButton:SetText(WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2)
    KeyFrame.ClearKeyButton:SetScript("OnMouseDown",function()
        C_ChallengeMode.RemoveKeystone()
        ChallengesKeystoneFrame:Reset()
        ItemButtonUtil.CloseFilteredBags(ChallengesKeystoneFrame)
        ClearCursor()
    end)


--地下城挑战，分数，超链接
    KeyFrame.ScoreButton= CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')
    KeyFrame.ScoreButton:SetPoint('TOPRIGHT', KeyFrame.ClearKeyButton, 'BOTTOMRIGHT', 0, -4)
    KeyFrame.ScoreButton:SetSize(70, 24)
    KeyFrame.ScoreButton:SetScript('OnMouseDown', function(self, d)
        local link= WoWTools_ChallengeMixin:GetDungeonScoreLink()
        if d=='LeftButton' then
            WoWTools_ChatMixin:Chat(link, nil, nil)
        else
            WoWTools_ChatMixin:Chat(link, nil, true)
        end
    end)

    KeyFrame.ScoreButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        WoWTools_SetTooltipMixin:Frame(self, nil, {dungeonScore=true})
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine('|cnGREEN_FONT_COLOR:<'..(WoWTools_L.SEND_MESSAGE)..'>'..WoWTools_DataMixin.Icon.left..'|A:transmog-icon-chat:0:0|a')
        GameTooltip:AddLine('|cnGREEN_FONT_COLOR:<'..(WoWTools_L.COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT)..'>'..WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        WoWTools_ChatMixin:Chat(self.dungeonScore, nil, nil)
    end)

    function KeyFrame.ScoreButton:set_text()
        local score= C_ChallengeMode.GetOverallDungeonScore() or 0
        self:SetText(
            '|A:recipetoast-icon-star:0:0|a'
            ..(score>0 and WoWTools_ChallengeMixin:KeystoneScorsoColor(score) or 0)
        )
    end


--发送链接
    KeyFrame.KeyButton= CreateFrame("ItemButton", nil, KeyFrame)-- WoWTools_ButtonMixin:Cbtn(KeyFrame)
    KeyFrame.KeyButton:SetPoint('TOP', KeyFrame.ScoreButton, 'BOTTOM', 0, -4)
    KeyFrame.KeyButton:SetScript("OnMouseDown",function(self, d)
        if d=='LeftButton' then
            WoWTools_ChatMixin:Chat(self.item, nil, nil)
        else
            --WoWTools_ChatMixin:Chat(self.item, nil, true)
            MenuUtil.CreateContextMenu(self, function(...)
                WoWTools_ChallengeMixin:Say_Menu(...)
            end)
        end
    end)

    KeyFrame.KeyButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    KeyFrame.KeyButton:SetScript("OnEnter",function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            WoWTools_SetTooltipMixin:Frame(self)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(' ', '|cnGREEN_FONT_COLOR:<'..(WoWTools_L.SEND_MESSAGE)..'>'..WoWTools_DataMixin.Icon.left)
            GameTooltip:AddDoubleLine(' ', (WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL)..WoWTools_DataMixin.Icon.right)
          --  GameTooltip:AddLine('|cnGREEN_FONT_COLOR:<'..(WoWTools_DataMixin.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT)..'>'..WoWTools_DataMixin.Icon.right)
            GameTooltip:Show()
    end)
    KeyFrame.KeyButton.Text=WoWTools_LabelMixin:Create(KeyFrame.KeyButton, {size=14})
    KeyFrame.KeyButton.Text:SetPoint('RIGHT', KeyFrame.KeyButton, 'LEFT')
    function KeyFrame.KeyButton:set_text()
        local info, bagID, slotID= WoWTools_BagMixin:Ceca(nil, {isKeystone=true})
        if info then
            self:SetItemLocation(ItemLocation:CreateFromBagAndSlot(bagID, slotID))
            self.Text:SetText(WoWTools_HyperLink:CN_Link(info.hyperlink, {itemID=info.itemID, isName=true}) or '')
            self:SetItemButtonCount(C_MythicPlus.GetOwnedKeystoneLevel())
        end
        self:SetShown(info and true or false)
    end


--就绪
    local ready = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--就绪
    ready:SetText((WoWTools_L.READY)..format('|A:%s:0:0|a', 'common-icon-checkmark'))
    ready:SetPoint('LEFT', ChallengesKeystoneFrame.StartButton, 'RIGHT',2, 0)
    ready:SetSize(100,24)
    ready:SetScript("OnMouseDown", DoReadyCheck)


--倒计时7秒
    local countdown = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--倒计时7秒
    countdown:SetText((WoWTools_L.PLAYER_COUNTDOWN_BUTTON)..' 7')
    countdown:SetPoint('TOP', ChallengesKeystoneFrame, 'BOTTOM',100, 5)
    countdown:SetSize(150,24)
    countdown:SetScript("OnMouseDown",function()
        C_PartyInfo.DoCountdown(7)
    end)


--停止， 倒计时
    local stop = CreateFrame("Button",nil, KeyFrame, 'UIPanelButtonTemplate')--倒计时7秒
    stop:SetText((WoWTools_L.CANCEL)..' 0')
    stop:SetPoint('TOP', ChallengesKeystoneFrame, 'BOTTOM',-100, 5)
    stop:SetSize(100,24)
    stop:SetScript("OnMouseDown",function()
        C_PartyInfo.DoCountdown(0)--antes también enviaba 'Stop! Stop! Stop!' al grupo
    end)


--移动
    ChallengesKeystoneFrame.DungeonName:ClearAllPoints()
    ChallengesKeystoneFrame.DungeonName:SetPoint('BOTTOMLEFT', ChallengesKeystoneFrame, 'BOTTOMLEFT', 15, 110)
    ChallengesKeystoneFrame.DungeonName:SetJustifyH('LEFT')

    ChallengesKeystoneFrame.TimeLimit:ClearAllPoints()
    ChallengesKeystoneFrame.TimeLimit:SetPoint('BOTTOMRIGHT', ChallengesKeystoneFrame, 'BOTTOMRIGHT', -15, 120)
    ChallengesKeystoneFrame.TimeLimit:SetJustifyH('RIGHT')


    Create_Buttons= function()end
end


local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub
    sub=root:CreateCheckbox(
        'Plus',
    function()
        return not Save().hideKeyUI
    end, function()
        Save().hideKeyUI= not Save().hideKeyUI and true or nil
        WoWTools_ChallengeMixin:ChallengesKeystoneFrame()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Challenge.KeystonePlus'])

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().keystoneScale or 1
    end, function(value)
        Save().keystoneScale= value
        WoWTools_ChallengeMixin:ChallengesKeystoneFrame()
    end)

--说
    root:CreateDivider()
    root:CreateTitle(
        '|A:transmog-icon-chat:0:0|a'
        ..(WoWTools_L.SAY)
    )



--挑战结束
    sub= root:CreateCheckbox(
        WoWTools_L['PLAYER_DIFFICULTY5+COMPLETE'],
    function()
        return not Save().hideEndKeystoneSay
    end, function()
        Save().hideEndKeystoneSay= not Save().hideEndKeystoneSay and true or nil
        WoWTools_ChallengeMixin:Say_ChallengeComplete()
    end)
    sub:SetTooltip(function(tootip)
        WoWTools_MenuMixin:AddDescription(tootip, WoWTools_L['Tip.Challenge.EndSay'])
        tootip:AddLine('CHALLENGE_MODE_COMPLETED')
        tootip:AddLine(' ')
        tootip:AddLine( WoWTools_L['SHOW_QUICK_BUTTON~2'] )
    end)

    WoWTools_ChallengeMixin:Say_ChallengeComplete_Menu(self, sub)

    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_ChallengeMixin.addName})
end


local function Init()
    local btn= WoWTools_ButtonMixin:Menu(ChallengesKeystoneFrame.CloseButton, {name='ChallengesKeystoneFrameWoWToolsMenu'})
    btn:SetPoint('RIGHT', ChallengesKeystoneFrame.CloseButton, 'LEFT')

    btn:SetupMenu(Init_Menu)

    KeyFrame= CreateFrame('Frame', nil, ChallengesKeystoneFrame.CloseButton)
    KeyFrame:SetFrameLevel(ChallengesKeystoneFrame.CloseButton:GetFrameLevel()+1)
    KeyFrame:SetPoint('TOPLEFT')
    KeyFrame:SetSize(1,1)
    KeyFrame:Hide()


--队伍信息
    KeyFrame.PartyInfoText=WoWTools_LabelMixin:Create(KeyFrame, {size=16})
    KeyFrame.PartyInfoText:SetPoint('TOPLEFT', ChallengesKeystoneFrame, 'TOPRIGHT', 2, 0)


    Init_Buttons()


    KeyFrame:SetScript("OnUpdate", function (self, elapsed)--更新队伍数据
        self.elapsed= (self.elapsed or 0.8) + elapsed
        if self.elapsed > 0.8 then
            self.elapsed=0
            UI_Party_Info()
        end

        local has= C_ChallengeMode.HasSlottedKeystone() and true or false
        if self.hasSlotted~=has then--solo cuando cambia, no en cada fotograma
            self.hasSlotted= has
            self.InsetKeyButton:SetEnabled(not has)
            self.ClearKeyButton:SetEnabled(has)
        end
    end)




    KeyFrame:SetScript('OnHide', function(self)
        self.elapsed=nil
        self.hasSlotted=nil
        self.KeyButton:Reset()
        self.KeyButton.Text:SetText('')

        self.ScoreButton.Text:SetText('')

        self.PartyInfoText:SetText('')
        self:UnregisterAllEvents()
    end)

    KeyFrame:SetScript('OnShow', function(self)
        self.ScoreButton:set_text()--地下城挑战，分数，超链接
        self.KeyButton:set_text()--发送链接
        self:RegisterEvent('BAG_UPDATE_DELAYED')
    end)

    KeyFrame:SetScript('OnEvent', function(self)
        self.KeyButton:set_text()--发送链接
    end)

    function KeyFrame:settings()

        self.ChatTooltipTexture:SetShown(false)
        self:SetShown(not Save().hideKeyUI)
        self:SetScale(Save().keystoneScale or 1)
    end



    KeyFrame:settings()

    Init=function()
        KeyFrame:settings()
    end
end



function WoWTools_ChallengeMixin:ChallengesKeystoneFrame()
    Init()
end

function WoWTools_ChallengeMixin:ChallengesKeystoneFrame_Menu(frame, root)
    if KeyFrame and frame:IsMouseOver() then
        Init_Menu(KeyFrame, root)
    end
end