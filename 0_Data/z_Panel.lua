local P_Save={
    --useColor=1,
}

local function Save()
    return WoWToolsPlusSave['WoWTools_Settings'] or {}
end













--Página General del Centro de control (esquema de docs/SETTINGS.md):
--ajustes del addon, apariencia (color de acento) y datos/restablecimiento.

--Tooltip con las primeras claves de una tabla guardada
local function Keys_Tooltip(title, tab, func)
    local text= title..'|n|n'
    local index= 0
    for key, value in pairs(tab or {}) do
        text= text..'|n'..(func and func(key, value) or tostring(key))
        index= index+1
        if index>10 then
            text= text..'|n|cffffffff...'
            break
        end
    end
    return text
end

local function Realm_Tooltip()
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
    return WoWTools_L['Tip.Panel.Realm']..'|n|n'..(text or '')
end

local function Has_Realm_Region()
    return WoWTools_DataMixin.Player.Region==1 or WoWTools_DataMixin.Player.Region==3
end

--Color de acento: el de la clase si no hay uno guardado
local function Use_ClassAccent()
    local style= WoWToolsPlusSave['Style']
    return not (style and style.accent)
end

local function Reset_Popup(title, func)
    StaticPopup_Show('WoWTools_RestData', title, nil, func)
end

local function Init_Options()
    WoWTools_Options:SetGeneral({
        {type='section', text='Behavior'},
        {type='check', key='chat', text='Show addon messages in chat', tooltip='Tip.Panel.ChatMessages',
            get= function(save) return save.showChatMessages end,
            set= function(save, value) save.showChatMessages= value and true or nil end,
        },
        {type='check', key='realm', text='Show realm region', tooltip= Realm_Tooltip, reload=true,
            hidden= function() return not Has_Realm_Region() end,
            get= function(save) return not save.disabledRealm end,
            set= function(save, value) save.disabledRealm= not value and true or nil end,
        },

        {type='section', text='Appearance'},
        {type='check', key='classAccent', text='Use class color', tooltip='Tip.Panel.ClassAccent',
            get= Use_ClassAccent,
            set= function(_, value)
                if value then
                    WoWTools_Style:SetAccent()
                else
                    WoWTools_Style:SetAccent(WoWTools_Style:GetAccent())
                end
            end,
        },
        {type='color', key='accent', text='Accent color', tooltip='Tip.Panel.Accent', indent=true,
            disabled= Use_ClassAccent,
            get= function() return WoWTools_Style:GetAccent() end,
            set= function(_, r, g, b) WoWTools_Style:SetAccent(r, g, b) end,
        },

        {type='section', text='Data and reset'},
        {type='button', key='reset', text='Reset addon settings', buttonText='RESET',
            tooltip= function() return Keys_Tooltip(WoWTools_L['Tip.Panel.ResetSettings'], WoWToolsPlusSave) end,
            func= function()
                Reset_Popup(WoWTools_L['Reset all addon settings'], function()
                    WoWTools_DataMixin.ClearAllSave= true
                    WoWToolsPlusSave= {}
                end)
            end,
        },
        {type='button', key='input', text='Clear input data', buttonText='SLASH_STOPWATCH_PARAM_STOP2',
            tooltip= function() return Keys_Tooltip(WoWTools_L['Tip.Panel.ClearInput'], WoWToolsPlusPlayerDate) end,
            func= function()
                Reset_Popup(WoWTools_L['Clear input data'], function()
                    WoWToolsPlusPlayerDate= {}
                end)
            end,
        },
        {type='button', key='warband', text='Clear Warband data', buttonText='SLASH_STOPWATCH_PARAM_STOP2',
            tooltip= function()
                return Keys_Tooltip(WoWTools_L['Tip.Panel.ClearWarband'], WoWToolsPlus_WoWDate, function(guid, tab)
                    return WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {
                        faction=tab.faction,
                        reName=true,
                        reRealm=true,
                        level=tab.level
                    })
                end)
            end,
            func= function()
                Reset_Popup(WoWTools_L['Clear Warband data'], function()
                    WoWToolsPlus_WoWDate= {}
                end)
            end,
        },
        {type='button', key='all', text='All addon data', buttonText='CLEAR_ALL',
            tooltip= function()
                return WoWTools_L['Tip.Panel.ClearAll']..'|n|n'
                    ..WoWTools_L['ADDONS+OPTIONS']..'|n'
                    ..WoWTools_L['Clear input data']..'|n'
                    ..WoWTools_L['Clear Warband data']
            end,
            func= function()
                Reset_Popup(WoWTools_DataMixin.addName, function()
                    WoWToolsPlusSave={}
                    WoWToolsPlusPlayerDate= {}
                    WoWToolsPlus_WoWDate= {}
                end)
            end,
        },
    }, Save)

    if Has_Realm_Region() and Save().disabledRealm then
        WoWTools_RealmMixin:Get_Region(nil, nil, nil, true)
    end
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
