

local P_Save={
    --disabled=true,
    --disabledTexture=true,
    alpha= 0.5,

    chatBubbleAlpha= 0.5,
    chatBubbleSacal= 0.85,

    classPowerNumSize= 23,


    Bg={
        All={
            texture='Interface\\AddOns\\WoWToolsPlus\\Source\\Background\\Black.tga',
            alpha=0.75,
            nineSlice=0,
        },
        Add={

        },
        Anims={
            --disabled=true,
            alpha=0.75,
            speed=10,
        }
    },
    no={},
}


local function SaveLog()
    return WoWToolsPlusPlayerDate['TextureClassColor']
end


local function Set_Color()
    local color= WoWTools_TextureMixin:Save().useColor and SaveLog()[WoWTools_DataMixin.Player.Class]
    if color and color.r and color.g and color.b then
        WoWTools_TextureMixin.Color= CreateColor(color.r, color.g, color.b, 1)
    else
        WoWTools_TextureMixin.Color= PlayerUtil.GetClassColor()
    end
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

local function Clear_Frame()
    WoWTools_TextureMixin.Events={}
    WoWTools_TextureMixin.Frames={}
    panel:UnregisterEvent('ADDON_LOADED')
    panel:SetScript('OnEvent', nil)
    Clear_Frame=function()end
end

--Despachador propio de ventanas de Blizzard (WoWTools_TextureMixin.Events): se migra en la fase R3
panel:SetScript("OnEvent", function(_, _, arg1)
    if WoWToolsPlusSave then
        if WoWTools_TextureMixin.Events[arg1] then
            if not WoWTools_TextureMixin:Save().no[arg1] then
                WoWTools_TextureMixin.Events[arg1](WoWTools_TextureMixin)
            end
            WoWTools_TextureMixin.Events[arg1]= nil
        end
    end
end)




--Sin casilla propia: el módulo no se puede desactivar, todo se hace en onLoad (siempre)
WoWTools_Module:Register({
    key= 'Plus_Texture',
    name= 'Module.Textures',
    icon= 'AnimCreate_Icon_Texture',
    defaults= P_Save,
    mixin= WoWTools_TextureMixin,
    panel= false,
    onLoad= function()
        WoWToolsPlusPlayerDate['TextureClassColor']= WoWToolsPlusPlayerDate['TextureClassColor'] or {}

        WoWTools_TextureMixin:Save().Bg= WoWTools_TextureMixin:Save().Bg or P_Save.Bg
        WoWTools_TextureMixin:Save().Bg.Anims= WoWTools_TextureMixin:Save().Bg.Anims or P_Save.Bg.Anims
        WoWTools_TextureMixin:Save().no= WoWTools_TextureMixin:Save().no or {}

        Set_Color()

        P_Save= nil

        WoWToolsPlusPlayerDate['BGTexture']= WoWToolsPlusPlayerDate['BGTexture'] or {}

        --Fork: el revestido de ventanas de Blizzard (teñir la interfaz) se ha eliminado: solo cosmético,
        --con riesgo de taint y se rompía con cada parche. Se conservan las funciones que usan
        --los marcos propios del addon (CreateBG, SetButton, IsAtlas...).
        Clear_Frame()

        --Estilo de barras de acción (ActionBars.lua): usa los ajustes de este módulo
        WoWTools_ActionBarsMixin:Init()
    end,
})
