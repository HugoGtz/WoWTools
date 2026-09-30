
--收藏
function WoWTools_TextureMixin.Events:Blizzard_Collections()
    self:HideTexture(CollectionsJournal.TopTileStreaks)
    self:SetButton(CollectionsJournalCloseButton)
    self:HideTexture(CollectionsJournalBg)
    self:SetButton(PetJournalTutorialButton)
    PetJournalTutorialButton:SetFrameLevel(CollectionsJournal.TitleContainer:GetFrameLevel()+1)

    for i=1, 10 do
        self:SetTabButton(_G['CollectionsJournalTab'..i])
    end


--坐骑
    --self:SetMenu(MountJournal.FilterDropdown)
    self:SetUIButton(MountJournalMountButton)
    self:SetFrame(MountJournal.MountCount, {alpha=0.3})
    self:HideTexture(MountJournal.LeftInset.Bg)
    self:HideTexture(MountJournal.MountDisplay.YesMountsTex)
    self:SetCheckBox(MountJournal.MountDisplay.ModelScene.TogglePlayer)
    self:SetAlphaColor(MountJournal.MountDisplay.ShadowOverlay, nil, nil, 0)
    self:SetAlphaColor(MountJournal.RightInset.Bg, nil, nil, 0.3)
    MountJournal.RightInset.Bg:ClearAllPoints()
    MountJournal.RightInset.Bg:SetPoint('TOPLEFT', MountJournalIcon, -2, 2)
    MountJournal.RightInset.Bg:SetPoint('BOTTOMRIGHT', MountJournalLore, 2, -2)
    self:HideFrame(MountJournal.BottomLeftInset)
    self:SetNineSlice(MountJournal.BottomLeftInset)
    self:SetScrollBar(MountJournal)
    self:SetEditBox(MountJournalSearchBox)
    self:SetNineSlice(MountJournal.RightInset)
    self:SetNineSlice(MountJournal.LeftInset)
    if MountJournal.ToggleDynamicFlightFlyoutButton then--11.1.7
        self:SetAlphaColor(MountJournal.ToggleDynamicFlightFlyoutButton.Border, true)
    end
    if MountJournal.SummonRandomFavoriteSpellFrame then
        self:SetAlphaColor(MountJournal.SummonRandomFavoriteSpellFrame.Button.Border, true)
    end
    --WoWTools_DataMixin:Hook('MountJournal_InitMountButton', function(btn)

--宠物
    self:SetUIButton(PetJournalSummonButton)
    self:SetUIButton(PetJournalFindBattle)
    self:HideFrame(PetJournalLoadoutBorder)

    self:HideTexture(PetJournalPetCardInset.Bg)
    self:SetAlphaColor(PetJournalPetCardBG, nil, nil, 0.3)

    self:HideTexture(PetJournalRightInset.Bg)
    self:SetAlphaColor(PetJournalLoadoutPet1BG)
    self:SetAlphaColor(PetJournalLoadoutPet2BG)
    self:SetAlphaColor(PetJournalLoadoutPet3BG)
    self:HideTexture(PetJournalLeftInset.Bg)

    self:SetScrollBar(PetJournal)
    self:SetEditBox(PetJournalSearchBox)

    self:SetFrame(PetJournal.PetCount, {alpha=0.3})

    self:SetAlphaColor(PetJournal.SummonRandomPetSpellFrame.Button.Border, true, nil, nil)
    self:SetAlphaColor(PetJournal.HealPetSpellFrame.Button.Border, true, nil, nil)

    self:SetNineSlice(PetJournalLeftInset)
    self:SetNineSlice(PetJournalPetCardInset)
    self:SetNineSlice(PetJournalRightInset)


--玩具
    self:SetEditBox(ToyBox.searchBox)
    self:HideFrame(ToyBox.iconsFrame)
    self:SetNineSlice(ToyBox.iconsFrame)
    ToyBox.progressBar:DisableDrawLayer('BACKGROUND')
    self:SetStatusBar(ToyBox.progressBar)
    self:SetButton(ToyBox.PagingFrame.PrevPageButton, 1)
    self:SetButton(ToyBox.PagingFrame.NextPageButton, 1)

--传家宝
    self:SetButton(HeirloomsJournal.PagingFrame.NextPageButton, 1)
    self:SetButton(HeirloomsJournal.PagingFrame.PrevPageButton, 1)
    self:SetEditBox(HeirloomsJournalSearchBox)
    self:HideFrame(HeirloomsJournal.iconsFrame)
    self:SetNineSlice(HeirloomsJournal.iconsFrame)
    HeirloomsJournal.progressBar:DisableDrawLayer('BACKGROUND')
    self:SetStatusBar(HeirloomsJournal.progressBar)
    self:SetAlphaColor(HeirloomsJournal.progressBar.border, nil, nil, 0.3)


--物品
    self:SetButton(WardrobeCollectionFrame.InfoButton)
    WardrobeCollectionFrame.InfoButton:SetFrameLevel(CollectionsJournal.TitleContainer:GetFrameLevel()+1)
    self:SetMenu(WardrobeCollectionFrame.ClassDropdown)
    self:SetNineSlice(WardrobeCollectionFrame.ItemsCollectionFrame)
    self:HideFrame(WardrobeCollectionFrame.ItemsCollectionFrame)
    WardrobeCollectionFrame.progressBar:DisableDrawLayer('BACKGROUND')

    self:SetStatusBar(WardrobeCollectionFrame.progressBar)
    self:SetEditBox(WardrobeCollectionFrameSearchBox)

    self:SetButton(WardrobeCollectionFrame.ItemsCollectionFrame.PagingFrame.PrevPageButton, 1)
    self:SetButton(WardrobeCollectionFrame.ItemsCollectionFrame.PagingFrame.NextPageButton, 1)

--套装
    self:SetScrollBar(WardrobeCollectionFrame.SetsCollectionFrame.ListContainer)
    self:SetNineSlice(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset.Bg)
    self:HideFrame(WardrobeCollectionFrame.SetsCollectionFrame.RightInset)
    self:SetNineSlice(WardrobeCollectionFrame.SetsCollectionFrame.RightInset)
    self:HideTexture(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.ModelFadeTexture)

--营区
    self:SetButton(WarbandSceneJournal.IconsFrame.Icons.Controls.PagingControls.PrevPageButton, 1)
    self:SetButton(WarbandSceneJournal.IconsFrame.Icons.Controls.PagingControls.NextPageButton, 1)
    self:SetCheckBox(WarbandSceneJournal.IconsFrame.Icons.Controls.ShowOwned.Checkbox)



--试衣间，物品 WardrobeItemsModelTemplate
    for _, btn in pairs(WardrobeCollectionFrame.ItemsCollectionFrame.Models) do
        btn:DisableDrawLayer('BACKGROUND')
        btn.Border:SetAlpha(0)
    end

    WardrobeCollectionFrame:HookScript('OnSizeChanged', function(frame)
        for _, btn in pairs(frame.ItemsCollectionFrame.Models) do
            btn:DisableDrawLayer('BACKGROUND')
            btn.Border:SetAlpha(0)
        end
    end)


    self:HideFrame(WarbandSceneJournal.IconsFrame)
    self:SetNineSlice(WarbandSceneJournal.IconsFrame)

--玩具, 传家宝，建立按钮，Bg, CollectionsSpellButton_OnLoad
    WoWTools_DataMixin:Hook('CollectionsSpellButton_OnShow', function(btn)--CollectionsSpellButton_OnLoad
        if btn.Bg or not btn.name then
            return
        end
        btn.Bg= btn:CreateTexture(nil, 'BACKGROUND')
        btn.Bg:SetColorTexture(0,0,0,0.3)
        btn.Bg:SetPoint('TOPLEFT', btn.name, -2, 2)
        btn.Bg:SetPoint('RIGHT', btn.name, 2, 0)
        btn.Bg:SetPoint('BOTTOM', btn.special or btn.name, 0,-2)
    end)



--收集
    self:Init_BGMenu_Frame(CollectionsJournal)
end


