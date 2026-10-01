local P_Save={
    --Heirlooms_Class_Scale=1,
    --Wardrober_Items_Labels_Scale=1, 
    hideTransmogModelName= true,
}
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

    sub=root:CreateCheckbox(
        WoWTools_L.PETS,
    function()
        return not WoWTools_CollectionMixin:Save().hidePets
    end, function()
        WoWTools_CollectionMixin:Save().hidePets= not WoWTools_CollectionMixin:Save().hidePets and true or nil
        Refresh_Pet()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Collection.Pets'])

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return WoWTools_CollectionMixin:Save().petListIconSize or 18
        end, setValue=function(value)
            WoWTools_CollectionMixin:Save().petListIconSize=value
            if not WoWTools_CollectionMixin:Save().hidePets then
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
        WoWTools_CollectionMixin:Save().petListIconSize=nil
        Refresh_Pet()
    end)

    sub=root:CreateCheckbox(
        WoWTools_L.HEIRLOOMS,
    function()
        return not WoWTools_CollectionMixin:Save().hideHeirloom
    end, function()
        WoWTools_CollectionMixin:Save().hideHeirloom= not WoWTools_CollectionMixin:Save().hideHeirloom and true or nil
        if HeirloomsJournal and HeirloomsJournal:IsShown() then
            HeirloomsJournal:FullRefreshIfVisible()
        end
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Collection.Heirlooms'])
    sub:SetEnabled(not PlayerIsTimerunning())


    sub= root:CreateCheckbox(
        WoWTools_L['WARDROBE+WARDROBE_ITEMS'],
    function()
        return not WoWTools_CollectionMixin:Save().hideItems
    end, function()
        WoWTools_CollectionMixin:Save().hideItems= not WoWTools_CollectionMixin:Save().hideItems and true or nil
        WoWTools_CollectionMixin:Init_Wardrober_Items()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Collection.WardrobeItems'])
        tooltip:AddLine(WoWTools_L['NEED+REFRESH'])
    end)

    sub= root:CreateCheckbox(
        WoWTools_L['WARDROBE+WARDROBE_SETS'],
    function()
        return not WoWTools_CollectionMixin:Save().hideSets
    end, function()
        WoWTools_CollectionMixin:Save().hideSets= not WoWTools_CollectionMixin:Save().hideSets and true or nil
        WoWTools_CollectionMixin:Init_Wardrober_Sets()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Collection.WardrobeSets'])
        tooltip:AddLine(WoWTools_L['NEED+REFRESH'])
    end)

    root:CreateDivider()
    sub=root:CreateCheckbox(
        WoWTools_L.ALL_CLASSES,
    function()
        return not WoWTools_CollectionMixin:Save().hideHeirloomClassList
    end, function()
        WoWTools_CollectionMixin:Save().hideHeirloomClassList= not WoWTools_CollectionMixin:Save().hideHeirloomClassList and true or nil
        WoWTools_CollectionMixin:Init_ClassList()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Collection.ClassList'])

    WoWTools_MenuMixin:Scale(self, sub,
    function()
        return WoWTools_CollectionMixin:Save().Heirlooms_Class_Scale or 1
    end, function(value)
        WoWTools_CollectionMixin:Save().Heirlooms_Class_Scale= value
        WoWTools_CollectionMixin:Init_ClassList()
    end, function()
        WoWTools_CollectionMixin:Save().Heirlooms_Class_Scale= nil
        WoWTools_CollectionMixin:Init_ClassList()
    end)

    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_CollectionMixin.addName})
end


local Init= WoWTools_Once(function()
    WoWTools_CollectionMixin:Init_Mount()
    WoWTools_CollectionMixin:Init_Pet()
    WoWTools_CollectionMixin:Init_ToyBox()
    WoWTools_CollectionMixin:Init_Heirloom()
    WoWTools_CollectionMixin:Init_Wardrober_Items()
    WoWTools_CollectionMixin:Init_Wardrober_Sets()
    WoWTools_CollectionMixin:Init_ClassList()

    local btn= CreateFrame('DropdownButton', 'WoWToolsCollectionsJournalMenuButton', CollectionsJournalCloseButton, 'WoWToolsMenuTemplate')
    btn:SetPoint('RIGHT', CollectionsJournalCloseButton, 'LEFT')
    btn:SetupMenu(Init_Menu)

end)


--Módulo registrado con la API común (docs/REFACTOR.md, R1)
WoWTools_Module:Register({
    key= 'Plus_Collection',
    name= 'Module.Collections',
    icon= 'UI-HUD-MicroMenu-Collections-Mouseover',
    group= 'Character',
    defaults= P_Save,
    tooltip= 'Tip.Collection.Enable',
    mixin= WoWTools_CollectionMixin,
    onEnable= function()
        WoWTools_CollectionMixin:Init_DressUpFrames()
        WoWTools_CollectionMixin:Init_Transmog()
    end,
    blizzard= {Blizzard_Collections= function()
        Init()
    end},
})
