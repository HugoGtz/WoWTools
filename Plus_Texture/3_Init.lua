

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


local function Save()
    return WoWToolsPlusSave['Plus_Texture']
end
local function SaveLog()
    return WoWToolsPlusPlayerDate['TextureClassColor']
end


local function Set_Color()
    local color= Save().useColor and SaveLog()[WoWTools_DataMixin.Player.Class]
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

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Plus_Texture']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Texture'], P_Save)
            WoWToolsPlusPlayerDate['TextureClassColor']= WoWToolsPlusPlayerDate['TextureClassColor'] or {}

            Save().Bg= Save().Bg or P_Save.Bg
            Save().Bg.Anims= Save().Bg.Anims or P_Save.Bg.Anims
            Save().no= Save().no or {}

            Set_Color()

            P_Save= nil

            WoWToolsPlusPlayerDate['BGTexture']= WoWToolsPlusPlayerDate['BGTexture'] or {}

            WoWTools_TextureMixin.addName= '|A:AnimCreate_Icon_Texture:0:0|a'..(WoWTools_L['Module.Textures'])

            --Fork: el revestido de ventanas de Blizzard (teñir la interfaz) se ha eliminado: solo cosmético,
            --con riesgo de taint y se rompía con cada parche. Se conservan las funciones que usan
            --los marcos propios del addon (CreateBG, SetButton, IsAtlas...).
            Clear_Frame()
            self:UnregisterEvent(event)

        elseif WoWToolsPlusSave then
            if WoWTools_TextureMixin.Events[arg1] then
                if not Save().no[arg1] then
                    WoWTools_TextureMixin.Events[arg1](WoWTools_TextureMixin)
                end
                WoWTools_TextureMixin.Events[arg1]= nil
            end
        end
    end
end)