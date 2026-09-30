local function Save()
    return WoWToolsPlusSave['Plus_MainMenu']
end

local Category, Layout










local function Init_Options()
    WoWTools_PanelMixin:Header(Layout,
        (Save().disabled and '|cff828282' or '')
        ..'1) Plus'
    )

    local initializer2= WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L.ENABLE,
        tooltip= WoWTools_L['Tip.MainMenu.Enable']..'|n|n'..WoWTools_MainMenuMixin.addName,
        GetValue= function() return not Save().disabled end,
        category= Category,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            if not Save().disabled then
                WoWTools_MainMenuMixin:Settings()
            else
                WoWTools_Print(
                    WoWTools_MainMenuMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                    WoWTools_L.RELOADUI
                )
            end
        end
    })

    local initializer= WoWTools_PanelMixin:OnlySlider({
        name= WoWTools_L.FONT_SIZE,
        GetValue= function() return Save().size end,
        minValue= 8,
        maxValue= 18,
        setp= 1,
        tooltip= WoWTools_L['Tip.MainMenu.FontSize']..'|n|n'..WoWTools_MainMenuMixin.addName,
        category= Category,
        SetValue= function(_, _, value2)
            if value2 then
                Save().size=value2
                WoWTools_MainMenuMixin:Settings()
            end
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().plus then return true else return false end end)

    initializer= WoWTools_PanelMixin:Check_Slider({
        checkName= WoWTools_L.HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY,
        checkGetValue= function() return Save().enabledMainMenuAlpha end,
        checkTooltip= WoWTools_L['Tip.MainMenu.Alpha']..'|n|n'..WoWTools_MainMenuMixin.addName,
        checkSetValue= function()
            Save().enabledMainMenuAlpha= not Save().enabledMainMenuAlpha and true or false
            WoWTools_Print(
                WoWTools_MainMenuMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_L.REQUIRES_RELOAD
            )
        end,
        sliderGetValue= function() return Save().mainMenuAlphaValue end,
        minValue= 0.1,
        maxValue= 1,
        step= 0.1,
        sliderSetValue= function(_, _, value2)
            if value2 then
                Save().mainMenuAlphaValue= WoWTools_DataMixin:GetFormatter1to10(value2, 0, 1)
                WoWTools_MainMenuMixin:Settings()
            end
        end,
        layout= Layout,
        category= Category,
    })
    initializer:SetParentInitializer(initializer2, function() if Save().plus then return true else return false end end)

    WoWTools_PanelMixin:Header(Layout,
        (Save().frameratePlus and '' or '|cff828282')
        ..'2) '..(WoWTools_L.SYSTEM)
    )

    initializer2= WoWTools_PanelMixin:OnlyCheck({
        name= (WoWTools_L.FRAMERATE_LABEL)..' Plus',
        tooltip= WoWTools_L['Tip.MainMenu.FrameratePlus']..'|n|n'..MicroButtonTooltipText(FRAMERATE_LABEL, "TOGGLEFPS"),
        GetValue= function() return Save().frameratePlus end,
        category= Category,
        SetValue= function()
            Save().frameratePlus= not Save().frameratePlus and true or nil
            if _G['WoWToolsPlusFramerateButton'] then
                WoWTools_Print(
                    WoWTools_MainMenuMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(Save().frameratePlus),
                    WoWTools_L.RELOADUI
                )
            else
                WoWTools_MainMenuMixin:Init_Framerate_Plus()
            end
        end
    })
    initializer= WoWTools_PanelMixin:OnlyCheck({
        name= (WoWTools_L.LOG_IN)..' WoW: '..(WoWTools_L.SHOW),
        tooltip= WoWTools_L['Tip.MainMenu.FramerateLogIn']..'|n|n'..MicroButtonTooltipText(FRAMERATE_LABEL, "TOGGLEFPS"),
        GetValue= function() return Save().framerateLogIn end,
        category= Category,
        SetValue= function()
            Save().framerateLogIn= not Save().framerateLogIn and true or nil
            WoWTools_MainMenuMixin:Init_Framerate_Plus()
            if Save().framerateLogIn and not FramerateFrame:IsShown() then
                FramerateFrame:Toggle()
            end
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().frameratePlus then return true else return false end end)


    Init_Options= function()end
end




















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1== 'WoWToolsPlus' then

        WoWToolsPlusSave['Plus_MainMenu']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_MainMenu'], {
                                                                        plus=true,
                                                                        size=10,
                                                                        enabledMainMenuAlpha= true,
                                                                        mainMenuAlphaValue=0.7,
                                                                    })

        WoWTools_MainMenuMixin.addName= '|A:UI-HUD-MicroMenu-GameMenu-Mouseover:0:0|a'..(WoWTools_L['Module.Micro menu'])

        Category, Layout= WoWTools_PanelMixin:AddSubCategory({
            name= WoWTools_MainMenuMixin.addName,
            disabled= Save().disabled and not Save().frameratePlus,
        })


        if not WoWToolsPlusSave['Plus_MainMenu'].disabled then
            WoWTools_MainMenuMixin:Settings()
            WoWTools_MainMenuMixin:Init_Character()
            WoWTools_MainMenuMixin:Init_Professions()
            WoWTools_MainMenuMixin:Init_Talent()
            WoWTools_MainMenuMixin:Init_Achievement()
            WoWTools_MainMenuMixin:HousingMicroButton()
            WoWTools_MainMenuMixin:Init_Quest()
            WoWTools_MainMenuMixin:Init_Guild()
            WoWTools_MainMenuMixin:Init_LFD()
            WoWTools_MainMenuMixin:Init_Collections()
            WoWTools_MainMenuMixin:Init_EJ()
            WoWTools_MainMenuMixin:Init_Store()
            WoWTools_MainMenuMixin:Init_Help()
            WoWTools_MainMenuMixin:Init_Bag()
        end

        WoWTools_MainMenuMixin:Init_Framerate_Plus()

        if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
            Init_Options()
            self:SetScript('OnEvent', nil)
            self:UnregisterEvent(event)
        end

    elseif arg1=='Blizzard_Settings' then
        Init_Options()
        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)