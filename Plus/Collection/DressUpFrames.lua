



local function GetItemLink(self)
    local link
    if self.transmogID then
        if type(self.item)=='table' and self.item.GetItemLink then
            link= self.item:GetItemLink()
        elseif self.item then
            local data= C_TransmogCollection.GetAppearanceSourceInfo(self.transmogID)
            if data then
                link= data.itemLink
            end
        else
            link = select(2, C_TransmogCollection.GetIllusionStrings(self.transmogID))
        end
    end
    return link
end


local function Init()

    DressUpFrame.SetSelectionPanel.Border:SetTexture(0)
   -- if DressUpFrame.SetSelectionPanel then --self.setID = setID; self.setItems = setItems; self.cachedSlotUpdates = {};
    DressUpFrame.SetSelectionPanel.SetName:EnableMouse(true)
    DressUpFrame.SetSelectionPanel.SetName:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip_Hide()
    end)
    DressUpFrame.SetSelectionPanel.SetName:SetScript('OnEnter', function(self)
        if self.setLink then
            GameTooltip:SetOwner(self:GetParent(), 'ANCHOR_RIGHT')
            GameTooltip:SetHyperlink(self.setLink)
            GameTooltip:Show()
        end
        self:SetAlpha(0.3)
    end)
    DressUpFrame.SetSelectionPanel.SetName:HookScript('OnHide', function(self)
        self.setLink=nil
    end)
    DressUpFrame.SetSelectionPanel.collectedText= DressUpFrame.SetSelectionPanel:CreateFontString(nil, 'BORDER', 'GameFontNormal')
    --DressUpFrame.SetSelectionPanel.collectedText:SetPoint('RIGHT', DressUpFrame.SetSelectionPanel.SetName)
    DressUpFrame.SetSelectionPanel.collectedText:SetPoint('TOPRIGHT', -10, -10)
    WoWTools_DataMixin:Hook(DressUpFrame.SetSelectionPanel, 'SetData', function(frame, setID, setLink, setItems)
        local co, all= 0, 0
        for _, data in pairs(setItems or {}) do
            if data.itemModifiedAppearanceID then
                local info= C_TransmogCollection.GetAppearanceSourceInfo(data.itemModifiedAppearanceID)
                if info and info.isCollected then
                    co= co+1
                end
            end
            all= all+1
        end
        local collect, numAll = select(2, WoWTools_CollectionMixin:SetID(setID))

        frame.collectedText:SetText(
            (numAll and numAll==collect and '|cnGREEN_FONT_COLOR:' or '')
            ..(all>0 and co..'/'..all or '')
            ..(numAll and numAll~=all and ' ('..collect..'/'..numAll..')' or '')
        )
        frame.SetName.setLink= setLink
    end)

    WoWTools_DataMixin:Hook(DressUpFrameTransmogSetButtonMixin, 'InitItem', function(frame, data)
        if not frame.collectedTexture then
            frame.collectedTexture= frame:CreateTexture(nil, 'BORDER')
            frame.collectedTexture:SetSize(14,14)
            frame.collectedTexture:SetPoint('RIGHT', frame.ItemSlot, 'LEFT')
            frame.collectedTexture:SetAtlas('transmog-icon-hidden')
            frame.collectedTexture:SetAlpha(0.5)
            frame.indexText= frame:CreateFontString(nil, 'BORDER', 'GameFontDisableSmall2')
            frame.indexText:SetPoint('RIGHT', frame.Icon, 'LEFT', -2.5, 0)
            frame.indexText:SetAlpha(0.7)
            frame.SelectedTexture:SetAtlas('ReportList-ButtonSelect')
            frame.BackgroundTexture:ClearAllPoints()
            frame.BackgroundTexture:SetAtlas('_UI-Frame-Metal-EdgeBottom')
            frame.BackgroundTexture:SetPoint('BOTTOMLEFT', 40, -2)
            frame.BackgroundTexture:SetPoint('BOTTOMRIGHT', -15, -2)
            frame.BackgroundTexture:SetHeight(32)
        end
        local isNotColleced
        if data.itemModifiedAppearanceID then
            local info= C_TransmogCollection.GetAppearanceSourceInfo(data.itemModifiedAppearanceID)
            if info then
                isNotColleced= info.isCollected==false
            end
        end
        frame.collectedTexture:SetShown(isNotColleced)
        if isNotColleced then
            frame.ItemSlot:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
        else
            frame.ItemSlot:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
        end
        frame.indexText:SetText(frame:GetOrderIndex() or '')
    end)
    WoWTools_DataMixin:Hook(DressUpFrameTransmogSetButtonMixin, 'Refresh', function(frame)
        frame.BackgroundTexture:SetAlpha(frame.elementData.selected and 0 or 1)
        local color= WoWTools_ItemMixin:GetColor(frame.elementData.itemQuality)
        frame.BackgroundTexture:SetVertexColor(color:GetRGB())
        frame.BackgroundTexture:SetAlpha(frame.elementData.selected and 0 or 1)
    end)


    WoWTools_DataMixin:Hook(DressUpCustomSetDetailsSlotMixin or DressUpOutfitDetailsSlotMixin, 'SetDetails', function(frame)
        if frame.chatButton then
            return
        end

        frame.chatButton= CreateFrame('Button', nil, frame, 'WoWToolsButtonTemplate')
        frame.chatButton:SetNormalAtlas('transmog-icon-chat')
        frame.chatButton:SetPoint("RIGHT")
        frame.chatButton:SetSize(23,23)
        local icon= frame.chatButton:GetNormalTexture()
        icon:SetPoint("TOPLEFT", 8, -8)
        icon:SetPoint("BOTTOMRIGHT", -8, 8)
        frame.chatButton:SetAlpha(0.3)
        frame.chatButton.alpha=0.3
        frame.chatButton.tooltip=function(self, tooltip)
            local link= GetItemLink(self:GetParent())
            if link then
                tooltip:SetHyperlink(link)
            end
        end
        frame.chatButton:SetScript('OnClick', function()
            local link= GetItemLink(frame)
            if link then
                WoWTools_ChatMixin:Chat(link, nil, true)
            end
        end)

        frame.findButton= CreateFrame('Button', nil, frame, 'WoWToolsButtonTemplate')
        frame.findButton:SetNormalAtlas('common-search-magnifyingglass')
        frame.findButton:SetPoint('RIGHT', frame.chatButton, 'LEFT')
        frame.findButton:SetSize(23,23)
        icon= frame.findButton:GetNormalTexture()
        icon:SetPoint("TOPLEFT", 8, -8)
        icon:SetPoint("BOTTOMRIGHT", -8, 8)
        frame.findButton:SetAlpha(0.3)
        frame.findButton.alpha=0.3
        frame.findButton.tooltip=function(self, tooltip)
            local link= GetItemLink(self:GetParent())
            if link then
                tooltip:SetHyperlink(link)
            end
        end
        frame.findButton:SetScript('OnClick', function(self)
            local p= self:GetParent()
                WoWTools_LoadUIMixin:Journal(5)
            local wcFrame= WardrobeCollectionFrame
            if wcFrame.activeFrame ~= wcFrame.ItemsCollectionFrame then
                wcFrame:ClickTab(wcFrame.ItemsTab)
            end
            if p.transmogLocation then
                WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveSlot(p.transmogLocation)
            end
            WardrobeCollectionFrameSearchBox:SetText(p.name or '')
        end)

        frame.Icon:EnableMouse(true)
        frame.Icon:SetScript("OnMouseUp", function(self)
            self:SetAlpha(0.3)
        end)

        frame.Icon:SetScript("OnMouseDown", function(self, d)
            local p= self:GetParent()
            local link= GetItemLink(p)
            if d=='LeftButton' then
                WoWTools_ChatMixin:Chat(link, nil, true)
            elseif d=='RightButton' then
                WoWTools_LoadUIMixin:Journal(5)
                local wcFrame= WardrobeCollectionFrame
                if wcFrame.activeFrame ~= wcFrame.ItemsCollectionFrame then
                    wcFrame:ClickTab(wcFrame.ItemsTab)
                end
                if p.transmogLocation then
                    WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveSlot(p.transmogLocation)
                end
                WardrobeCollectionFrameSearchBox:SetText(p.name or '')
            end
            self:SetAlpha(0.3)
        end)
        frame.Icon:SetScript("OnLeave", function(self)
            GameTooltip_Hide()
            self:SetAlpha(1)
        end)

        frame.Icon:SetScript("OnEnter", function(self)
            local p= self:GetParent()
            local link= GetItemLink(p)
            if not link then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:SetHyperlink(link)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_L['COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK~2'], WoWTools_DataMixin.Icon.left)
            if p.name then
                GameTooltip:AddDoubleLine(WoWTools_L.SEARCH, WoWTools_DataMixin.Icon.right)
            end
            GameTooltip:Show()
            self:SetAlpha(0.5)
        end)
    end)


    WoWTools_DataMixin:Hook(DressUpCustomSetDetailsSlotMixin or DressUpOutfitDetailsSlotMixin, 'OnEnter', function(frame)
        if frame.transmogID then
            GameTooltip:AddLine('sourceID|cffffffff'..WoWTools_DataMixin.Icon.icon2..frame.transmogID)
            GameTooltip:Show()
        end
    end)

    Init=function()end
end



function WoWTools_CollectionMixin:Init_DressUpFrames()
    Init()
end