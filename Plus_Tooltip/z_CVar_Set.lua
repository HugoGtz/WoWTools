

--设置Cvar
function WoWTools_TooltipMixin:Set_CVar(reset, tips, notPrint)
    local tab={
        {   name='missingTransmogSourceInItemTooltips',
            value='1',
            msg=WoWTools_L['Show transmog sources'],
        },
        {   name='nameplateOccludedAlphaMult',
            value='0.15',
            msg=WoWTools_L['Out of line of sight: nameplate alpha'],
        },
        {   name='dontShowEquipmentSetsOnItems',
            value='0',
            msg=WoWTools_L['Show equipment sets'],
        },
        {   name='UberTooltips',
            value='1',
            msg=WoWTools_L['SHOW+SPELL_MESSAGES']
        },
        {   name="alwaysCompareItems",
             value= "1",
             msg= WoWTools_L['Always compare items']
        },
        {   name="profanityFilter",
            value= '0',
            msg= '禁用语言过虑 /reload',
            zh=true,
        },
        {   name="overrideArchive",
            value= '0',
            msg= '反和谐 /reload',
            zh=true
        },
        {   name='cameraDistanceMaxZoomFactor',
            value= '2.6',
            msg= WoWTools_L['FARCLIP~3']
        },
        {   name="showTargetOfTarget",
            value= "1",
            msg= WoWTools_L.OPTION_TOOLTIP_TARGETOFTARGET5,
        },
        {   name='worldPreloadNonCritical',--https://wago.io/ZtSxpza28
            value='0',--2
            msg= WoWTools_L['World Preload Non Critical']
        }
    }

    if tips then
        local text
        for _, info in pairs(tab) do
            if info.zh and LOCALE_zhCN or not info.zh then
                text= (text and text..'|n|n' or '')..WoWTools_DataMixin:Get_CVar_Tooltips(info)
            end
        end
        return text
    end

    for _, info in pairs(tab) do
        if info.zh and LOCALE_zhCN or not info.zh then
            if reset then
                local defaultValue = C_CVar.GetCVarDefault(info.name)
                local value = C_CVar.GetCVar(info.name)
                if defaultValue~=value then
                    C_CVar.SetCVar(info.name, defaultValue)
                    if not notPrint then
                        print(WoWTools_DataMixin.Icon.icon2..WoWTools_TooltipMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_L.RESET_TO_DEFAULT)..'|r', info.name, defaultValue, info.msg)
                    end
                end
            else
                local value = C_CVar.GetCVar(info.name)
                if value~=info.value then
                    C_CVar.SetCVar(info.name, info.value)
                    if not notPrint then
                        print(WoWTools_DataMixin.Icon.icon2..WoWTools_TooltipMixin.addName, info.name, info.value..'('..value..')', info.msg)
                    end
                end
            end
        end
    end
end


function WoWTools_TooltipMixin:Init_CVar()
    if WoWToolsPlusSave['Plus_Tootips'].setCVar and not InCombatLockdown() then
        WoWTools_TooltipMixin:Set_CVar(nil, nil, true)--设置CVar
    end

--为自已开启，功能
    if WoWTools_DataMixin.Player.husandro then
        EventRegistry:RegisterFrameEventAndCallback("SETTINGS_LOADED", function(owner)
            local set= Settings.GetSetting("PROXY_SHOW_ACTIONBAR_4")

            if not InCombatLockdown() and(not set or not set:GetValue())  then
                Settings.SetValue("PROXY_SHOW_ACTIONBAR_2", true)
                Settings.SetValue("PROXY_SHOW_ACTIONBAR_3", true)
                Settings.SetValue("PROXY_SHOW_ACTIONBAR_4", true)
            end

            EventRegistry:UnregisterCallback('SETTINGS_LOADED', owner)
        end)
      --  Enum.EditModeActionBarSetting.HideBarArt=0
    end
end