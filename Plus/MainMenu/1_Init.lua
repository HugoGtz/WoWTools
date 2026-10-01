local function Framerate_Button()
    return _G['WoWToolsPlusFramerateButton']
end

local StrataValues= {}
for _, strata in ipairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
    table.insert(StrataValues, {value=strata, text=strata})
end

--Esquema del Centro de control (docs/SETTINGS.md). Antes: subpágina de Blizzard.
local Options= {
    {type='section', text='GENERAL'},
    {type='slider', key='size', text='FONT_SIZE', tooltip='Tip.MainMenu.FontSize', min=8, max=18, step=1,
        get= function(save) return save.size or 10 end,
        set= function(save, value) save.size= math.floor(value) end,
        apply= function() WoWTools_MainMenuMixin:Settings() end,
    },

    {type='section', text='Appearance'},
    {type='check', key='alpha', text='Fade buttons', tooltip='Tip.MainMenu.Alpha', reload=true,
        get= function(save) return save.enabledMainMenuAlpha end,
        set= function(save, value) save.enabledMainMenuAlpha= value and true or false end,
    },
    {type='slider', key='alphaValue', text='HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', min=0.1, max=1, step=0.1, format='%.1f', indent=true,
        disabled= function(save) return not save.enabledMainMenuAlpha end,
        get= function(save) return save.mainMenuAlphaValue or 0.7 end,
        set= function(save, value) save.mainMenuAlphaValue= WoWTools_DataMixin:GetFormatter1to10(value, 0, 1) end,
        apply= function() WoWTools_MainMenuMixin:Settings() end,
    },

    {type='section', text='FRAMERATE_LABEL'},
    {type='check', key='frameratePlus', text= function() return WoWTools_L.FRAMERATE_LABEL..' Plus' end,
        tooltip='Tip.MainMenu.FrameratePlus', reload=true,
        get= function(save) return save.frameratePlus end,
        set= function(save, value) save.frameratePlus= value and true or nil end,
        apply= function(_, save)
            if save.frameratePlus and not Framerate_Button() then
                WoWTools_MainMenuMixin:Init_Framerate_Plus()
            end
        end,
    },
    {type='check', key='framerateLogIn', text='Show at login', tooltip='Tip.MainMenu.FramerateLogIn', indent=true, automation=true,
        disabled= function(save) return not save.frameratePlus end,
        get= function(save) return save.framerateLogIn end,
        set= function(save, value) save.framerateLogIn= value and true or nil end,
        apply= function(_, save)
            WoWTools_MainMenuMixin:Init_Framerate_Plus()
            if save.framerateLogIn and FramerateFrame and not FramerateFrame:IsShown() then
                FramerateFrame:Toggle()
            end
        end,
    },
    {type='slider', key='framerateSize', text='FONT_SIZE', tooltip='Tip.MainMenu.FramerateSize', min=6, max=72, step=1, indent=true,
        disabled= function(save) return not save.frameratePlus end,
        get= function(save) return save.framerateSize or 12 end,
        set= function(save, value) save.framerateSize= math.floor(value) end,
        apply= function()
            local btn= Framerate_Button()
            if btn then
                btn:set_size()
            end
        end,
    },

    {type='section', text='Advanced'},
    {type='dropdown', key='shopStrata', text='Shop window strata', tooltip='Tip.Menu.Strata', values=StrataValues,
        get= function(save) return save.CatalogShopFrameStrata or 'MEDIUM' end,
        set= function(save, value) save.CatalogShopFrameStrata= value end,
        apply= function(_, save)
            if CatalogShopFrame and not WoWTools_FrameMixin:IsLocked(CatalogShopFrame) then
                CatalogShopFrame:SetFrameStrata(save.CatalogShopFrameStrata)
            end
        end,
    },
}


--Módulo registrado con la API común (docs/REFACTOR.md, R2).
--Los FPS van siempre (onLoad), aunque el micromenú esté desactivado. Interruptor estándar (save.disabled, pide /reload).
WoWTools_Module:Register({
    key= 'Plus_MainMenu',
    name= 'Module.Micro menu',
    icon= 'UI-HUD-MicroMenu-GameMenu-Mouseover',
    group= 'Interface',
    tooltip= 'Tip.MainMenu.Enable',
    defaults= {
        plus=true,
        size=10,
        enabledMainMenuAlpha= true,
        mainMenuAlphaValue=0.7,
    },
    mixin= WoWTools_MainMenuMixin,
    options= Options,
    onLoad= function()
        WoWTools_MainMenuMixin:Init_Framerate_Plus()
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

