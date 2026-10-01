local CurrentWeek
local Frame


local function Find_Cursor_Affix()
    if CurrentWeek then
        return
    end

    local currentAffixes=C_MythicPlus.GetCurrentAffixes()
    if not currentAffixes then
        return
    end
    for index, affixes in pairs(WoWTools_DataMixin.affixSchedule) do
        if currentAffixes[1] and affixes[1]== currentAffixes[1].id
            and currentAffixes[2] and affixes[2]==currentAffixes[2].id
            and currentAffixes[3] and affixes[3]==currentAffixes[3].id
            and currentAffixes[4] and affixes[4]==currentAffixes[4].id
        then
            CurrentWeek= index
            return
        end
    end
end


local function Initializer(btn, data)
    local isCurrent= data.index==CurrentWeek
    for index, affixID in pairs(data.data) do
        local frame= btn['Affix'..index]
        if frame then
            frame:SetUp(affixID)
            if isCurrent then
                frame.Border:SetVertexColor(0, 1, 0)
            else
                frame.Border:SetVertexColor(1, 1, 1)
            end
        end
    end

    --btn.Text:SetText(isCurrent and '|A:common-icon-rotateright:0:0|a' or data.index)
    btn.Text:SetText(
        (isCurrent and '|cnGREEN_FONT_COLOR:' or '')
        .. data.index
    )

    --local name, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID)
end


local function Set_List()
    Find_Cursor_Affix()

    local data = CreateDataProvider()
    for index, info in pairs(WoWTools_DataMixin.affixSchedule) do
        data:Insert({
            index= index,
            data=info,
        })
    end
    Frame.view:SetDataProvider(data, ScrollBoxConstants.RetainScrollPosition)
    Frame.ScrollBox:ScrollToElementDataIndex(CurrentWeek or 1)

    local season= C_MythicPlus.GetCurrentSeason()
    Frame.Text:SetText(
        (season==WoWTools_DataMixin.SeasonAffixSchedule and '' or '|cff828282')
        ..season
    )
end


local function Init()
    if WoWTools_ChallengeMixin:Save().hideAffix then
        return
    end



    Frame= CreateFrame('Frame', 'WoWToolsChallengeAffixFrame', ChallengesFrame)
    Frame:SetFrameStrata('HIGH')
    Frame:SetFrameLevel(3)
    Frame:Hide()


    Frame.ScrollBox= CreateFrame('Frame', nil, Frame, 'WowScrollBoxList')
    Frame.ScrollBox:SetAllPoints()

    Frame.ScrollBar= CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    Frame.ScrollBar:SetPoint("TOPLEFT", Frame, "TOPRIGHT", 6, -12)
    Frame.ScrollBar:SetPoint("BOTTOMLEFT", Frame, "BOTTOMRIGHT", 6, 12)
    WoWTools_TextureMixin:SetScrollBar(Frame.ScrollBar)

    Frame.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(Frame.ScrollBox, Frame.ScrollBar, Frame.view)
    Frame.view:SetElementInitializer('WoWToolsChallengeAffixTemplate', Initializer)



    function Frame:Settings()
        self:SetSize(WoWTools_ChallengeMixin:Save().affixW or 238, WoWTools_ChallengeMixin:Save().affixH or 177)
        self:SetPoint('BOTTOMRIGHT', ChallengesFrame, 'BOTTOMRIGHT', WoWTools_ChallengeMixin:Save().affixX or -45, WoWTools_ChallengeMixin:Save().affixY or 300)
        self:SetScale(WoWTools_ChallengeMixin:Save().affixScale or 0.4)
        self:SetShown(not WoWTools_ChallengeMixin:Save().hideAffix)
    end

    Frame:SetScript('OnShow', function(self)
        Set_List()
        self:RegisterEvent('MYTHIC_PLUS_CURRENT_AFFIX_UPDATE')
    end)

    Frame:SetScript('OnHide', function(self)
        self.view:SetDataProvider(CreateDataProvider())
        self:UnregisterEvent('MYTHIC_PLUS_CURRENT_AFFIX_UPDATE')
    end)


    Frame:SetScript('OnEvent', function()
        Set_List()
    end)



    Frame.Text= WoWTools_LabelMixin:Create(Frame, {color=true, mouse=true, size=32})
    Frame.Text:SetPoint('BOTTOMRIGHT', Frame.ScrollBar, 'TOPRIGHT',9, 3)
    Frame.Text:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    Frame.Text:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        local sea=  C_MythicPlus.GetCurrentSeason() or 0
        local isCurrentWeek= sea==WoWTools_DataMixin.SeasonAffixSchedule

        GameTooltip:AddLine(
            format(
                WoWTools_L.EXPANSION_SEASON_NAME,
                WoWTools_DataMixin.Icon.wow2,
                sea
            )
        )
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(
            WoWTools_DataMixin.Icon.left
            ..(isCurrentWeek and '' or '|cff828282')
            ..(WoWTools_L['ITEM_UPGRADE_CURRENT~2'])
            ..(CurrentWeek or 1)
        )
        if not isCurrentWeek then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(
                '|cnWARNING_FONT_COLOR:'
                ..(WoWTools_L['Current season data mismatch'])
            )
        end
        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)
    Frame.Text:SetScript('OnMouseDown', function(self)
        self:GetParent().ScrollBox:ScrollToElementDataIndex(CurrentWeek or 1)
    end)




    WoWTools_TextureMixin:CreateBG(Frame,{point=function(texture)
        texture:SetPoint('TOPLEFT', -2, 6)
        texture:SetPoint('BOTTOMLEFT', -2, -2)
        texture:SetPoint('RIGHT', Frame.ScrollBar, 10, 0)
    end})


    C_Timer.After(1, function() Set_List() end)
    Frame:Settings()

    Init=function()
        Frame:Settings()
    end
end


function WoWTools_ChallengeMixin:ChallengesUI_Affix()
    Init()
end
