

local P_Save={
    --disabled=true,
    --disabledTexture=true,
    --useColor=true,自定义，颜色
    UIButton=WoWTools_DataMixin.Player.husandro,
    CheckBox= WoWTools_DataMixin.Player.husandro,
    alpha= 0.5,

    --disabledChatBubble=true,--禁用，聊天泡泡
    chatBubbleAlpha= 0.5,--聊天泡泡
    chatBubbleSacal= 0.85,

    classPowerNum= WoWTools_DataMixin.Player.husandro,--职业，显示数字
    classPowerNumSize= 23,

    --disabledMainMenu= not WoWTools_DataMixin.Player.husandro, --主菜单，颜色，透明度
    --disabledHelpTip=true,--隐藏所有教程

    Bg={
        All={--统一设置
            texture='Interface\\AddOns\\WoWToolsPlus\\Source\\Background\\Black.tga',
            alpha=0.75,
            nineSlice=0,
        },
        Add={--分开设置

        },
        Anims={
            --disabled=true,
            alpha=0.75,
            speed=10,
        }
    },
    no={},--禁用
}


local function Save()
    return WoWToolsPlusSave['Plus_Texture']
end
local function SaveLog()
    return WoWToolsPlusPlayerDate['TextureClassColor']
end


--自定义，颜色
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

            Set_Color()--自定义，颜色

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