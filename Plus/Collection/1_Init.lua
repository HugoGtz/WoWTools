local P_Save={
    --Heirlooms_Class_Scale=1,
    --Wardrober_Items_Labels_Scale=1, 
    hideTransmogModelName= true,
}
local Get_Options
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


--Esquema de opciones (docs/SETTINGS.md): mismos campos que los menús
--Los refrescos solo se aplican si la ventana de colecciones ya está cargada y el módulo arrancó
local function Is_Ready(M)
    return M.started and C_AddOns.IsAddOnLoaded('Blizzard_Collections')
end

local function Refresh_Mount()
    local btn= _G['WoWToolsMountDisplayInfo']
    if btn and btn.set_Text then
        btn:set_Text()
        btn:set_Alpha()
    end
end

function Get_Options()
    return {
        {type='section', text='GENERAL'},
        {type='check', key='pets', text='PETS', tooltip='Tip.Collection.Pets',
            get= function(save) return not save.hidePets end,
            set= function(save, value) save.hidePets= not value and true or nil end,
            apply= function(M) if Is_Ready(M) then Refresh_Pet() end end},
        {type='slider', key='petIcon', text='Pet ability icon size', tooltip='Tip.Collection.PetIconSize', indent=true,
            min=0, max=47, step=1,
            disabled= function(save) return save.hidePets end,
            get= function(save) return save.petListIconSize or 18 end,
            set= function(save, value) save.petListIconSize= value end,
            apply= function(M, save) if Is_Ready(M) and not save.hidePets then Refresh_Pet() end end},
        {type='check', key='heirloom', text='HEIRLOOMS', tooltip='Tip.Collection.Heirlooms',
            disabled= function() return PlayerIsTimerunning and PlayerIsTimerunning() end,
            get= function(save) return not save.hideHeirloom end,
            set= function(save, value) save.hideHeirloom= not value and true or nil end,
            apply= function(M)
                if Is_Ready(M) and HeirloomsJournal and HeirloomsJournal:IsShown() then
                    HeirloomsJournal:FullRefreshIfVisible()
                end
            end},
        {type='check', key='items', text='WARDROBE+WARDROBE_ITEMS', tooltip='Tip.Collection.WardrobeItems',
            get= function(save) return not save.hideItems end,
            set= function(save, value) save.hideItems= not value and true or nil end,
            apply= function(M) if Is_Ready(M) then WoWTools_CollectionMixin:Init_Wardrober_Items() end end},
        {type='check', key='sets', text='WARDROBE+WARDROBE_SETS', tooltip='Tip.Collection.WardrobeSets',
            get= function(save) return not save.hideSets end,
            set= function(save, value) save.hideSets= not value and true or nil end,
            apply= function(M) if Is_Ready(M) then WoWTools_CollectionMixin:Init_Wardrober_Sets() end end},
        {type='check', key='mountInfo', text='Show mount details', tooltip='Tip.Collection.MountInfo',
            get= function(save) return save.ShowMountDisplayInfo end,
            set= function(save, value) save.ShowMountDisplayInfo= value and true or nil end,
            apply= Refresh_Mount},
        {type='check', key='modelName', text='Model: show name', tooltip='Tip.Collection.ModelName',
            get= function(save) return not save.hideTransmogModelName end,
            set= function(save, value) save.hideTransmogModelName= not value and true or nil end,
            apply= function() WoWTools_CollectionMixin:Refresh_TransmogItems() end},

        {type='section', text='Appearance'},
        {type='check', key='classList', text='ALL_CLASSES', tooltip='Tip.Collection.ClassList',
            get= function(save) return not save.hideHeirloomClassList end,
            set= function(save, value) save.hideHeirloomClassList= not value and true or nil end,
            apply= function(M) if Is_Ready(M) then WoWTools_CollectionMixin:Init_ClassList() end end},
        {type='slider', key='classScale', text='HOUSING_EXPERT_DECOR_SUBMODE_SCALE', tooltip='Tip.Menu.Scale', indent=true,
            min=0.4, max=4, step=0.05, format='%.2f',
            disabled= function(save) return save.hideHeirloomClassList end,
            get= function(save) return save.Heirlooms_Class_Scale or 1 end,
            set= function(save, value) save.Heirlooms_Class_Scale= value end,
            apply= function(M) if Is_Ready(M) then WoWTools_CollectionMixin:Init_ClassList() end end},
    }
end


--Módulo registrado con la API común (docs/REFACTOR.md, R1)
WoWTools_Module:Register({
    key= 'Plus_Collection',
    name= 'Module.Collections',
    icon= 'UI-HUD-MicroMenu-Collections-Mouseover',
    group= 'Character',
    defaults= P_Save,
    tooltip= 'Tip.Collection.Enable',
    mixin= WoWTools_CollectionMixin,
    options= function()
        return Get_Options()
    end,
    onEnable= function()
        WoWTools_CollectionMixin:Init_DressUpFrames()
        WoWTools_CollectionMixin:Init_Transmog()
    end,
    blizzard= {Blizzard_Collections= function()
        Init()
    end},
})
