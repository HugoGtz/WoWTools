
function WoWTools_ItemMixin.Frames:BossBanner_ConfigureLootFrame()
    WoWTools_DataMixin:Hook('BossBanner_ConfigureLootFrame', function(lootFrame, data)--LevelUpDisplay.lua
        WoWTools_ItemMixin:SetItemStats(lootFrame, data.itemLink, {point=lootFrame.Icon})
    end)
end



function WoWTools_ItemMixin.Frames:LootFrame()
    WoWTools_DataMixin:Hook(LootFrameItemElementMixin, 'Init', function(btn)
        WoWTools_ItemMixin:SetupInfo(btn.Item, {lootIndex= btn:GetSlotIndex()})
    end)
end
