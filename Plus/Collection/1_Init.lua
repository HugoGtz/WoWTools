local P_Save={
    --hideHeirloom= true,--传家宝
    --hideSets= true,--套装, 幻化, 界面
    --hideItems= true,--物品, 幻化, 界面
    --Heirlooms_Class_Scale=1,
    --Wardrober_Items_Labels_Scale=1, 
    hideTransmogModelName= true,
}
local function Save()
    return WoWToolsPlusSave['Plus_Collection'] or {}
end


local function Refresh_Pet()
    WoWTools_CollectionMixin:Init_Pet()
    if PetJournal and PetJournal:IsVisible() then
        do
            WoWTools_DataMixin:Call('PetJournal_OnHide', PetJournal)
        end
        WoWTools_DataMixin:Call('PetJournal_OnShow', PetJournal)
        --WoWTools_DataMixin:Call(PetJournal_UpdateAll)
    end
end




local function Init_Menu(self, root)
    if not self:IsMouseOver() then return end

    local sub
--宠物

    sub=root:CreateCheckbox(
        WoWTools_L.PETS,
    function()
        return not Save().hidePets
    end, function()
        Save().hidePets= not Save().hidePets and true or nil
        Refresh_Pet()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Collection.Pets'])

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().petListIconSize or 18
        end, setValue=function(value)
            Save().petListIconSize=value
            if not Save().hidePets then
                Refresh_Pet()
            end
        end,
        name=WoWTools_L.EMBLEM_SYMBOL,
        minValue=0,
        maxValue=47,
        step=1,
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_L.PROFESSIONS_CURRENT_LISTINGS )
            tooltip:AddLine(WoWTools_L['ABILITIES+EMBLEM_SYMBOL'])
        end

    })
    sub:CreateSpacer()

    sub:CreateButton(
        WoWTools_L.RESET,
    function()
        Save().petListIconSize=nil
        Refresh_Pet()
    end)

--传家宝
    sub=root:CreateCheckbox(
        WoWTools_L.HEIRLOOMS,
    function()
        return not Save().hideHeirloom
    end, function()
        Save().hideHeirloom= not Save().hideHeirloom and true or nil
        if HeirloomsJournal and HeirloomsJournal:IsShown() then
            HeirloomsJournal:FullRefreshIfVisible()
        end
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Collection.Heirlooms'])
    sub:SetEnabled(not PlayerIsTimerunning())


--外观：物品
    sub= root:CreateCheckbox(
        WoWTools_L['WARDROBE+WARDROBE_ITEMS'],
    function()
        return not Save().hideItems
    end, function()
        Save().hideItems= not Save().hideItems and true or nil
        WoWTools_CollectionMixin:Init_Wardrober_Items()--幻化 5
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Collection.WardrobeItems'])
        tooltip:AddLine(WoWTools_L['NEED+REFRESH'])
    end)

--外观：套装
    sub= root:CreateCheckbox(
        WoWTools_L['WARDROBE+WARDROBE_SETS'],
    function()
        return not Save().hideSets
    end, function()
        Save().hideSets= not Save().hideSets and true or nil
        WoWTools_CollectionMixin:Init_Wardrober_Sets()--幻化,套装 5
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Collection.WardrobeSets'])
        tooltip:AddLine(WoWTools_L['NEED+REFRESH'])
    end)

    root:CreateDivider()
    sub=root:CreateCheckbox(
        WoWTools_L.ALL_CLASSES,
    function()
        return not Save().hideHeirloomClassList
    end, function()
        Save().hideHeirloomClassList= not Save().hideHeirloomClassList and true or nil
        WoWTools_CollectionMixin:Init_ClassList()--职业列表
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Collection.ClassList'])

--缩放
    WoWTools_MenuMixin:Scale(self, sub,
    function()
        return Save().Heirlooms_Class_Scale or 1
    end, function(value)
        Save().Heirlooms_Class_Scale= value
        WoWTools_CollectionMixin:Init_ClassList()--职业列表
    end, function()
        Save().Heirlooms_Class_Scale= nil
        WoWTools_CollectionMixin:Init_ClassList()--职业列表
    end)

    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_CollectionMixin.addName})
end


local function Init()
    WoWTools_CollectionMixin:Init_Mount()--坐骑 1
    WoWTools_CollectionMixin:Init_Pet()--宠物 2
    WoWTools_CollectionMixin:Init_ToyBox()--玩具 3
    WoWTools_CollectionMixin:Init_Heirloom()--传家宝 4
    WoWTools_CollectionMixin:Init_Wardrober_Items()--幻化,物品 5
    WoWTools_CollectionMixin:Init_Wardrober_Sets()--幻化,套装 5
    WoWTools_CollectionMixin:Init_ClassList()--职业列表

    local btn= CreateFrame('DropdownButton', 'WoWToolsCollectionsJournalMenuButton', CollectionsJournalCloseButton, 'WoWToolsMenuTemplate')
    btn:SetPoint('RIGHT', CollectionsJournalCloseButton, 'LEFT')
    btn:SetupMenu(Init_Menu)

    Init=function()end
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Plus_Collection']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Collection'], P_Save)
            P_Save=nil

            WoWTools_CollectionMixin.addName= '|A:UI-HUD-MicroMenu-Collections-Mouseover:0:0|a'..(WoWTools_L['Module.Collections'])

--添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_CollectionMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                end,
                tooltip=WoWTools_L['Tip.Collection.Enable']..'|n|n'..WoWTools_L.REQUIRES_RELOAD
            })

            if Save().disabled then
                self:SetScript('OnEvent', nil)
                self:UnregisterEvent(event)
            else
                WoWTools_CollectionMixin:Init_DressUpFrames()--试衣间, 外观列表
                WoWTools_CollectionMixin:Init_Transmog()

                if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
                    Init()
                    self:SetScript('OnEvent', nil)
                    self:UnregisterEvent(event)
                end
            end

        elseif arg1=='Blizzard_Collections' and WoWToolsPlusSave then
            Init()
            self:SetScript('OnEvent', nil)
            self:UnregisterEvent(event)
        end
    end
end)