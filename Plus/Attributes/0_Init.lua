


local P_Save={
    redColor= '|cffff4800',
    greenColor='|cff00ff00',
    font={r=0, g=0, b=0, a=1, x=0, y=0},
    tab={
        ['STATUS']={bit=2},
        ['CRITCHANCE']= {r=0.99, g=0.35, b=0.31},
        ['HASTE']= {r=0, g=1, b=0.77},
        ['MASTERY']= {r=0.82, g=0.28, b=0.82},
        ['VERSATILITY']= {r=0, g=0.77, b=1},
        ['LIFESTEAL']= {r=1, g=0.33, b=0.5},
        ['AVOIDANCE']= {r=0.90, g=0.80, b=0.60},

        ['ARMOR']={r=0.71, g=0.55, b=0.22, a=1},
        ["DODGE"]= {r=1, g=0.51, b=1},
        ["PARRY"]= {r=0.59, g=0.85, b=1},
        ["BLOCK"]= {r=0.75, g=0.53, b=0.78},
        ["STAGGER"]= {r=0.38, g=1, b=0.62},

        ["SPEED"]= {r=1, g=0.82, b=0},
    },
    bar= true,
    barTexture2=true,
    barWidth= -60,
    barX=22,
    scale= 1.1,
    vertical=3,
    horizontal=9,
    setMaxMinValue= true,
    bitPrecet=0,
    onlyDPS=true,
    textColor= {r=1,g=1,b=1,a=1},
    bit=0,


    hideInPetBattle=true,
    buttonAlpha=0.3,
    --gsubText
    --strlower
    --strupper

}

-- STAT_CATEGORY_ATTRIBUTES--PaperDollFrame.lua

--Módulo registrado con la API común (docs/REFACTOR.md, R2).
--Opciones: esquema del Centro de control (5_Blizzard_Settings.lua); interruptor estándar (save.disabled, pide /reload).
WoWTools_Module:Register({
    key= 'Plus_Attributes',
    name= 'Module.Attributes',
    icon= 'charactercreate-icon-customize-body-selected',
    group= 'Interface',
    tooltip= 'Tip.Attributes.Enable',
    defaults= P_Save,
    mixin= WoWTools_AttributesMixin,
    options= function()
        return WoWTools_AttributesMixin:Get_Options()
    end,
    events= {PLAYER_ENTERING_WORLD= function()
        do
            WoWTools_AttributesMixin:Create_Button()
        end
        WoWTools_AttributesMixin:Frame_Init(true)
        WoWTools_AttributesMixin:Init_Vehicle_Speed()
        return true
    end},
})
