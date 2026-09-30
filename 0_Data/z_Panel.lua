local P_Save={
    --useColor=1,
}

local function Save()
    return WoWToolsPlusSave['WoWTools_Settings'] or {}
end













--####
--####
--Sección "Datos y restablecimiento": se añade al final, después de los módulos
local function Init_Data()
    WoWTools_PanelMixin:Header(nil, WoWTools_L['Data and reset'])

    local optionHeader= WoWTools_L['ADDONS+OPTIONS']
    WoWTools_PanelMixin:OnlyButton({
        title= '|A:talents-button-undo:0:0|a'..WoWTools_L['Reset addon settings'],
        buttonText= '|A:QuestArtifact:0:0|a'..(WoWTools_L.RESET ),
        addSearchTags= optionHeader,
        SetValue= function()
            StaticPopup_Show('WoWTools_RestData',
                (WoWTools_L['Reset all addon settings']),
                nil,
            function()
                WoWTools_DataMixin.ClearAllSave= true
                WoWToolsPlusSave= {}
            end)
        end,
        tooltip=function()
            local text= WoWTools_L['Tip.Panel.ResetSettings']..'|n|n'
            local index=0
            for name in pairs(WoWToolsPlusSave) do
                text= (text and text..'\n' or '')..name
                index= index+1
                if index>10 then
                    text= text..'\n|cffffffff...'
                    break
                end
            end
            return text
        end
    })








    local playerHeader= WoWTools_L['Clear input data']
    WoWTools_PanelMixin:OnlyButton({
        title= '|A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:0:0|a'..playerHeader,
        buttonText= '|A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:0:0|a'..(WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2),
        addSearchTags= playerHeader,
        SetValue= function()
            StaticPopup_Show('WoWTools_RestData',
                WoWTools_DataMixin.Icon.wow2..playerHeader,
                nil,
                function()
                    WoWToolsPlusPlayerDate= {}
                end
            )
        end,
        tooltip=function()
            local text= WoWTools_L['Tip.Panel.ClearInput']..'|n|n'
            local index=0
            for name in pairs(WoWToolsPlusPlayerDate) do
                text= (text and text..'\n' or '')..name
                index= index+1
                if index>10 then
                    text= text..'\n|cffffffff...'
                    break
                end
            end
            return text
        end,
    })






    local wowHeader= WoWTools_L['Clear Warband data']
    WoWTools_PanelMixin:OnlyButton({
        title= WoWTools_DataMixin.Icon.wow2..wowHeader,
        buttonText= WoWTools_DataMixin.Icon.wow2..(WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2),
        addSearchTags= wowHeader,
        SetValue= function()
            StaticPopup_Show('WoWTools_RestData',
                WoWTools_DataMixin.Icon.wow2..wowHeader,
                nil,
                function()
                    WoWToolsPlus_WoWDate= {}
                end
            )
        end,
        tooltip=function()
            local text= WoWTools_L['Tip.Panel.ClearWarband']..'|n|n'
            for guid, tab in pairs(WoWToolsPlus_WoWDate) do
                text= (text and text..'\n' or '')
                   ..WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil,{
                        faction=tab.faction,
                        reName=true,
                        reRealm=true,
                        level=tab.level
                    })
            end
            return text
        end
    })


    WoWTools_PanelMixin:OnlyButton({
        title= WoWTools_DataMixin.Icon.wow2..WoWTools_L['ACCOUNT_QUEST_LABEL+ITEMS'],
        buttonText= WoWTools_L.SHOW,
        SetValue= function()
           WoWTools_DataMixin:OpenWoWItemListFrame()
        end,
        tooltip= WoWTools_L['Tip.Panel.WarbandItems']
    })









    local header= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_L.CLEAR_ALL)
    WoWTools_PanelMixin:OnlyButton({
        title= WoWTools_L['All addon data'],
        buttonText= header,
        addSearchTags= header,
        SetValue= function()
            StaticPopup_Show('WoWTools_RestData',
                WoWTools_DataMixin.addName,
                nil,
            function()
                WoWToolsPlusSave={}
                WoWToolsPlusPlayerDate= {}
                WoWToolsPlus_WoWDate= {}
            end)
        end,
        tooltip= WoWTools_L['Tip.Panel.ClearAll']..'|n|n'
            ..optionHeader..'\n'
            ..playerHeader..'\n'
            ..wowHeader,
    })








    Init_Data=function()end
end


local MainStartIndex

local function Init_Options()
    WoWTools_PanelMixin:Header(nil, WoWTools_L.GENERAL)

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L['Show addon messages in chat'],
        tooltip= WoWTools_L['Tip.Panel.ChatMessages'],
        GetValue= function() return Save().showChatMessages end,
        SetValue= function()
            Save().showChatMessages= not Save().showChatMessages and true or nil
        end
    })

    --WoWTools_PanelMixin:Header(nil, SETTINGS)



    if WoWTools_DataMixin.Player.Region==1 or WoWTools_DataMixin.Player.Region==3 then
        local function get_tooltip()
            local tabs= WoWTools_DataMixin.Player.Region==3 and
                {
                    ["deDE"] = {col="|cFF00FF00DE|r", text='DE', realm="Germany"},
                    ["frFR"] = {col="|cFF00FFFFFR|r", text='FR', realm="France"},
                    ["enGB"] = {col="|cFFFF00FFGB|r", text='GB', realm="Great Britain"},
                    ["itIT"] = {col="|cFFFFFF00IT|r", text='IT', realm="Italy"},
                    ["esES"] = {col="|cFFFFBF00ES|r", text='ES', realm="Spain"},
                    ["ruRU"] = {col="|cFFCCCCFFRU|r" ,text='RU', realm="Russia"},
                    ["ptBR"] = {col="|cFF8fce00PT|r", text='PT', realm="Portuguese"},
                }
            or
                {
                    ["oce"] = {col="|cFF00FF00OCE|r", text='CE', realm="Oceanic"},
                    ["usp"] = {col="|cFF00FFFFUSP|r", text='USP', realm="US Pacific"},
                    ["usm"] = {col="|cFFFF00FFUSM|r", text='USM', realm="US Mountain"},
                    ["usc"] = {col="|cFFFFFF00USC|r", text='USC', realm="US Central"},
                    ["use"] = {col="|cFFFFBF00USE|r", text='USE', realm="US East"},
                    ["mex"] = {col="|cFFCCCCFFMEX|r", text='MEX', realm="Mexico"},
                    ["bzl"] = {col="|cFF8fce00BZL|r", text='BZL', realm="Brazil"},
                }
            local text
            for text2, tab in pairs(tabs) do
                text= (text and text..'|n' or '')..tab.col..'  '..tab.realm.. '  ('..tab.text..')  '.. text2
            end
            return text
        end

        WoWTools_PanelMixin:OnlyCheck({
            name= WoWTools_L['Show realm region'],
            tooltip=WoWTools_L['Tip.Panel.Realm']..'|n|n'..(get_tooltip() or ''),
            Value= not Save().disabledRealm,
            GetValue= function() return not Save().disabledRealm end,
            SetValue= function()
                Save().disabledRealm= not Save().disabledRealm and true or nil
                WoWTools_Print(WoWTools_DataMixin.addName,  WoWTools_L.REQUIRES_RELOAD)
            end
        })

        if Save().disabledRealm then
            WoWTools_RealmMixin:Get_Region(nil, nil, nil, true)
        end
    end



    MainStartIndex= WoWTools_PanelMixin:GetMainCount()+1--aquí empiezan los módulos


    Init_Options=function()end
end
















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1~= 'WoWToolsPlus' then
        return
    end

    WoWTools_DataMixin:Init_SavedVariables()--por si llega antes que el de 2_DataMixin_WoW
    WoWToolsPlusSave['WoWTools_Settings']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['WoWTools_Settings'], P_Save)
    P_Save= nil


    --Save().useColor= Save().useColor or 1
    --Save().useCustomColorTab= Save().useCustomColorTab or {r=1, g=0.82, b=0, a=1, hex='|cffffd100'}
    Save().useColor= nil
    Save().useCustomColorTab= nil

    Init_Options()

    WoWTools_DataMixin.Language.layer=WoWTools_DataMixin.Language.layer..'|A:Ping_Wheel_Icon_OnMyWay_Disabled_Small:0:0|a'


    WoWTools_DataMixin.StausText={
        [ITEM_MOD_HASTE_RATING_SHORT]= WoWTools_TextMixin:sub(ITEM_MOD_HASTE_RATING_SHORT, 1, 2, true),
        [ITEM_MOD_CRIT_RATING_SHORT]= WoWTools_TextMixin:sub(ITEM_MOD_CRIT_RATING_SHORT, 1, 2, true),
        [ITEM_MOD_MASTERY_RATING_SHORT]= WoWTools_TextMixin:sub(ITEM_MOD_MASTERY_RATING_SHORT, 1, 2, true),
        [ITEM_MOD_VERSATILITY]= WoWTools_TextMixin:sub(ITEM_MOD_VERSATILITY, 1, 2, true),

        [ITEM_MOD_CR_AVOIDANCE_SHORT]= WoWTools_TextMixin:sub(ITEM_MOD_CR_AVOIDANCE_SHORT, 1, 2, true),
        [ITEM_MOD_CR_LIFESTEAL_SHORT]= WoWTools_TextMixin:sub(ITEM_MOD_CR_LIFESTEAL_SHORT, 1, 2, true),
        [ITEM_MOD_CR_SPEED_SHORT]= WoWTools_TextMixin:sub(ITEM_MOD_CR_SPEED_SHORT, 1,2,true),
        [ITEM_MOD_PARRY_RATING_SHORT]=WoWTools_TextMixin:sub(PARRY, 1,2,true),

        [ITEM_MOD_MODIFIED_CRAFTING_STAT_1] = WoWTools_TextMixin:sub(ITEM_MOD_MODIFIED_CRAFTING_STAT_1, 1,2,true),
        [ITEM_MOD_MODIFIED_CRAFTING_STAT_2] = WoWTools_TextMixin:sub(ITEM_MOD_MODIFIED_CRAFTING_STAT_2, 1,2,true),
        [ITEM_MOD_BLOCK_RATING_SHORT] = WoWTools_TextMixin:sub(ITEM_MOD_BLOCK_RATING_SHORT, 1,2,true),
        [ITEM_MOD_ATTACK_POWER_SHORT] = WoWTools_TextMixin:sub(ITEM_MOD_ATTACK_POWER_SHORT, 1,2,true),
        [ITEM_MOD_EXTRA_ARMOR_SHORT]= WoWTools_TextMixin:sub(ARMOR, 1,2,true),
    }

    self:UnregisterEvent(event)
end)

--Al iniciar sesión todos los módulos ya han registrado su casilla: se agrupan por tema
--y después se añade la sección de datos al final de la página.
local Groups= {
    {title='Module group: Interface', mixins={'WoWTools_MoveMixin', 'WoWTools_TextureMixin', 'WoWTools_TooltipMixin', 'WoWTools_ItemMixin', 'WoWTools_CursorMixin', 'WoWTools_TargetMixin', 'WoWTools_UnitMixin', 'WoWTools_AttributesMixin', 'WoWTools_MainMenuMixin', 'WoWTools_MinimapMixin', 'WoWTools_ColorMixin', 'WoWTools_ObjectiveMixin'}},
    {title='Module group: Chat and social', mixins={'WoWTools_ChatMixin', 'WoWTools_FriendsMixin'}},
    {title='Module group: Items and gold', mixins={'WoWTools_BagMixin', 'WoWTools_BankMixin', 'WoWTools_GuildBankMixin', 'WoWTools_MerchantMixin', 'WoWTools_MailMixin', 'WoWTools_AuctionHouseMixin', 'WoWTools_CurrencyMixin', 'WoWTools_ProfessionMixin', 'WoWTools_GemMixin'}},
    {title='Module group: Character and collections', mixins={'WoWTools_PaperDollMixin', 'WoWTools_SpellMixin', 'WoWTools_MacroMixin', 'WoWTools_CollectionMixin', 'WoWTools_FactionMixin', 'WoWTools_HunterMixin', 'WoWTools_PetBattleMixin', 'WoWTools_HouseMixin'}},
    {title='Module group: World and dungeons', mixins={'WoWTools_WorldMapMixin', 'WoWTools_GossipMixin', 'WoWTools_EncounterMixin', 'WoWTools_ChallengeMixin', 'WoWTools_HolidayMixin'}},
    {title='Module group: Tools', mixins={'WoWTools_ToolsMixin', 'WoWTools_AddOnsMixin', 'WoWTools_OtherMixin'}},
}

EventUtil.ContinueOnPlayerLogin(function()
    if not MainStartIndex then
        return
    end
    local groups= {}
    for _, group in ipairs(Groups) do
        local names= {}
        for _, mixin in ipairs(group.mixins) do
            local name= _G[mixin] and _G[mixin].addName
            if type(name)=='string' and name~='' then
                table.insert(names, name)
            end
        end
        table.insert(groups, {title= WoWTools_L[group.title], names= names})
    end
    WoWTools_PanelMixin:Organize_Main(MainStartIndex, groups, WoWTools_L.OTHER)
    Init_Data()
end)
