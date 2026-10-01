local Category, Layout










local Init_Options= WoWTools_Once(function()
    WoWTools_PanelMixin:Header(Layout,
        (WoWTools_MainMenuMixin:Save().disabled and '|cff828282' or '')
        ..'1) Plus'
    )

    local initializer2= WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L.ENABLE,
        tooltip= WoWTools_L['Tip.MainMenu.Enable']..'|n|n'..WoWTools_MainMenuMixin.addName,
        GetValue= function() return not WoWTools_MainMenuMixin:Save().disabled end,
        category= Category,
        SetValue= function()
            WoWTools_MainMenuMixin:Save().disabled= not WoWTools_MainMenuMixin:Save().disabled and true or nil
            if not WoWTools_MainMenuMixin:Save().disabled then
                WoWTools_MainMenuMixin:Settings()
            else
                WoWTools_Print(
                    WoWTools_MainMenuMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(not WoWTools_MainMenuMixin:Save().disabled),
                    WoWTools_L.RELOADUI
                )
            end
        end
    })

    local initializer= WoWTools_PanelMixin:OnlySlider({
        name= WoWTools_L.FONT_SIZE,
        GetValue= function() return WoWTools_MainMenuMixin:Save().size end,
        minValue= 8,
        maxValue= 18,
        setp= 1,
        tooltip= WoWTools_L['Tip.MainMenu.FontSize']..'|n|n'..WoWTools_MainMenuMixin.addName,
        category= Category,
        SetValue= function(_, _, value2)
            if value2 then
                WoWTools_MainMenuMixin:Save().size=value2
                WoWTools_MainMenuMixin:Settings()
            end
        end
    })
    initializer:SetParentInitializer(initializer2, function() if WoWTools_MainMenuMixin:Save().plus then return true else return false end end)

    initializer= WoWTools_PanelMixin:Check_Slider({
        checkName= WoWTools_L.HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY,
        checkGetValue= function() return WoWTools_MainMenuMixin:Save().enabledMainMenuAlpha end,
        checkTooltip= WoWTools_L['Tip.MainMenu.Alpha']..'|n|n'..WoWTools_MainMenuMixin.addName,
        checkSetValue= function()
            WoWTools_MainMenuMixin:Save().enabledMainMenuAlpha= not WoWTools_MainMenuMixin:Save().enabledMainMenuAlpha and true or false
            WoWTools_Print(
                WoWTools_MainMenuMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_L.REQUIRES_RELOAD
            )
        end,
        sliderGetValue= function() return WoWTools_MainMenuMixin:Save().mainMenuAlphaValue end,
        minValue= 0.1,
        maxValue= 1,
        step= 0.1,
        sliderSetValue= function(_, _, value2)
            if value2 then
                WoWTools_MainMenuMixin:Save().mainMenuAlphaValue= WoWTools_DataMixin:GetFormatter1to10(value2, 0, 1)
                WoWTools_MainMenuMixin:Settings()
            end
        end,
        layout= Layout,
        category= Category,
    })
    initializer:SetParentInitializer(initializer2, function() if WoWTools_MainMenuMixin:Save().plus then return true else return false end end)

    WoWTools_PanelMixin:Header(Layout,
        (WoWTools_MainMenuMixin:Save().frameratePlus and '' or '|cff828282')
        ..'2) '..(WoWTools_L.SYSTEM)
    )

    initializer2= WoWTools_PanelMixin:OnlyCheck({
        name= (WoWTools_L.FRAMERATE_LABEL)..' Plus',
        tooltip= WoWTools_L['Tip.MainMenu.FrameratePlus']..'|n|n'..MicroButtonTooltipText(FRAMERATE_LABEL, "TOGGLEFPS"),
        GetValue= function() return WoWTools_MainMenuMixin:Save().frameratePlus end,
        category= Category,
        SetValue= function()
            WoWTools_MainMenuMixin:Save().frameratePlus= not WoWTools_MainMenuMixin:Save().frameratePlus and true or nil
            if _G['WoWToolsPlusFramerateButton'] then
                WoWTools_Print(
                    WoWTools_MainMenuMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(WoWTools_MainMenuMixin:Save().frameratePlus),
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
        GetValue= function() return WoWTools_MainMenuMixin:Save().framerateLogIn end,
        category= Category,
        SetValue= function()
            WoWTools_MainMenuMixin:Save().framerateLogIn= not WoWTools_MainMenuMixin:Save().framerateLogIn and true or nil
            WoWTools_MainMenuMixin:Init_Framerate_Plus()
            if WoWTools_MainMenuMixin:Save().framerateLogIn and not FramerateFrame:IsShown() then
                FramerateFrame:Toggle()
            end
        end
    })
    initializer:SetParentInitializer(initializer2, function() if WoWTools_MainMenuMixin:Save().frameratePlus then return true else return false end end)


end)




















--Módulo registrado con la API común (docs/REFACTOR.md, R2).
--Tiene su propia página de opciones (panel=false); los FPS y esa página van siempre (onLoad).
WoWTools_Module:Register({
    key= 'Plus_MainMenu',
    name= 'Module.Micro menu',
    icon= 'UI-HUD-MicroMenu-GameMenu-Mouseover',
    group= 'Interface',
    defaults= {
        plus=true,
        size=10,
        enabledMainMenuAlpha= true,
        mainMenuAlphaValue=0.7,
    },
    mixin= WoWTools_MainMenuMixin,
    panel= false,
    onLoad= function(M, save)
        Category, Layout= WoWTools_PanelMixin:AddSubCategory({
            name= M.addName,
            disabled= save.disabled and not save.frameratePlus,
        })
        WoWTools_MainMenuMixin:Init_Framerate_Plus()
        EventUtil.ContinueOnAddOnLoaded('Blizzard_Settings', Init_Options)
    end,
    onEnable= function()
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
    end,
})

