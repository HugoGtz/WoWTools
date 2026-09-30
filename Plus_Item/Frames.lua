
--boss掉落，物品, 可能，会留下 StaticPopup1 框架
function WoWTools_ItemMixin.Frames:BossBanner_ConfigureLootFrame()
    WoWTools_DataMixin:Hook('BossBanner_ConfigureLootFrame', function(lootFrame, data)--LevelUpDisplay.lua
        WoWTools_ItemMixin:SetItemStats(lootFrame, data.itemLink, {point=lootFrame.Icon})
    end)
end



--拾取
function WoWTools_ItemMixin.Frames:LootFrame()
    WoWTools_DataMixin:Hook(LootFrameItemElementMixin, 'Init', function(btn)
        WoWTools_ItemMixin:SetupInfo(btn.Item, {lootIndex= btn:GetSlotIndex()})
    end)
end
