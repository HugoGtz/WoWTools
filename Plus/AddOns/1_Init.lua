local P_Save={
    buttons={
        [BASE_SETTINGS_TAB]={
            ['BugSack']=true,
            ['!BugGrabber']=true,
            ['TextureAtlasViewer']=true,-- true, i or guid
            ['WoWToolsPlus']=true,
        }, [PET_BATTLE_COMBAT_LOG]={
            ['BugSack']=true,
            ['!BugGrabber']=true,
            ['tdBattlePetScript']=true,
            --['zAutoLoadPetTeam_Rematch']=true,
            ['Rematch']=true,
            ['WoWToolsPlus']=true,
        }, [INSTANCE]={
            ['BugSack']=true,
            ['!BugGrabber']=true,
            --['WeakAuras']=true,
            --['WeakAurasOptions']=true,
            ['Details']=true,
            ['DBM-Core']=true,
            ['DBM-Challenges']=true,
            ['DBM-StatusBarTimers']=true,
            ['WoWToolsPlus']=true,
        }
    },
    fast={
        ['TextureAtlasViewer']=true,
        ['WoWToolsPlus']=true,
        --['WeakAuras']=true,
        --['WeakAurasOptions']=true,
    },


    --load_list_top=true,
    load_list_onlyIcon=true,
    load_list_size=22,

    rightListScale=1,

    leftListScale=1,
    --hideLeftList

    --bgAlpha=0.3
}



--#####
--#####
local function Init()
    WoWTools_AddOnsMixin:Init_Menu_Button()
    WoWTools_AddOnsMixin:Init_Bottom_Buttons()
    WoWTools_AddOnsMixin:Init_Right_Buttons()
    WoWTools_AddOnsMixin:Init_Left_Buttons()
    WoWTools_AddOnsMixin:Init_Info_Plus()
end


--Refresco en vivo: solo si el módulo ya arrancó (si no, crearía sus marcos con el módulo desactivado)
local function Refresh(M, ...)
    if not M.started then
        return
    end
    for _, name in ipairs({...}) do
        WoWTools_AddOnsMixin[name](WoWTools_AddOnsMixin)
    end
end

local function Refresh_All(M)
    Refresh(M, 'Init_Left_Buttons', 'Init_Bottom_Buttons', 'Init_Right_Buttons')
end

--Esquema del Centro de control (docs/SETTINGS.md): los mismos ajustes que el menú de la ventana de accesorios
local Options= {
    {type='section', text='Shortcut list'},
    {type='check', key='leftList', text='SHOW', tooltip='Tip.AddOns.LeftList',
        get= function(save) return not save.hideLeftList end,
        set= function(save, value) save.hideLeftList= not value and true or nil end,
        apply= function(M) Refresh(M, 'Init_Left_Buttons') end,
    },
    {type='slider', key='leftScale', text='HOUSING_EXPERT_DECOR_SUBMODE_SCALE', min=0.4, max=4, step=0.1, format='%.1f', indent=true,
        disabled= function(save) return save.hideLeftList end,
        get= function(save) return save.leftListScale or 1 end,
        set= function(save, value) save.leftListScale= tonumber(format('%.1f', value)) or 1 end,
        apply= function(M) Refresh(M, 'Init_Left_Buttons') end,
    },
    {type='button', key='leftClear', text='Clear shortcut list', buttonText='CLEAR_ALL', tooltip='Tip.AddOns.LeftListClear', confirm=true, indent=true,
        func= function(M, save)
            save.fast= {}
            Refresh(M, 'Init_Left_Buttons')
        end,
    },

    {type='section', text='ADDONS+EMBLEM_SYMBOL'},
    {type='check', key='bottomList', text='SHOW', tooltip='Tip.AddOns.BottomList',
        get= function(save) return save.load_list end,
        set= function(save, value) save.load_list= value and true or nil end,
        apply= function(M) Refresh(M, 'Init_Bottom_Buttons') end,
    },
    {type='check', key='bottomTop', text='Position: top', tooltip='Tip.AddOns.BottomListTop', indent=true,
        disabled= function(save) return not save.load_list end,
        get= function(save) return save.load_list_top end,
        set= function(save, value) save.load_list_top= value and true or nil end,
        apply= function(M) Refresh(M, 'Init_Bottom_Buttons') end,
    },
    {type='check', key='bottomIcon', text='Icon only', tooltip='Tip.AddOns.BottomListIconOnly', indent=true,
        disabled= function(save) return not save.load_list end,
        get= function(save) return save.load_list_onlyIcon end,
        set= function(save, value) save.load_list_onlyIcon= value and true or false end,
        apply= function(M) Refresh(M, 'Init_Bottom_Buttons') end,
    },
    {type='slider', key='bottomSize', text='HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE', min=8, max=72, step=1, indent=true,
        disabled= function(save) return not save.load_list end,
        get= function(save) return save.load_list_size or 22 end,
        set= function(save, value) save.load_list_size= math.floor(value) end,
        apply= function(M) Refresh(M, 'Init_Bottom_Buttons') end,
    },

    {type='section', text='Addon profiles'},
    {type='check', key='rightList', text='SHOW', tooltip='Tip.AddOns.RightList',
        get= function(save) return not save.hideRightList end,
        set= function(save, value) save.hideRightList= not value and true or nil end,
        apply= function(M) Refresh(M, 'Init_Right_Buttons') end,
    },
    {type='slider', key='rightScale', text='HOUSING_EXPERT_DECOR_SUBMODE_SCALE', min=0.4, max=4, step=0.1, format='%.1f', indent=true,
        disabled= function(save) return save.hideRightList end,
        get= function(save) return save.rightListScale or 1 end,
        set= function(save, value) save.rightListScale= tonumber(format('%.1f', value)) or 1 end,
        apply= function(M) Refresh(M, 'Init_Right_Buttons') end,
    },
    {type='button', key='rightClear', text='Delete all profiles', buttonText='CLEAR_ALL', tooltip='Tip.AddOns.RightListClear', confirm=true, indent=true,
        func= function(M, save)
            save.buttons= {}
            Refresh(M, 'Init_Right_Buttons')
        end,
    },

    {type='section', text='Appearance'},
    {type='slider', key='bgAlpha', text='BACKGROUND+HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', tooltip='Tip.Menu.BgAlpha',
        min=0, max=1, step=0.1, format='%.1f',
        get= function(save) return save.bgAlpha or 0.5 end,
        set= function(save, value) save.bgAlpha= tonumber(format('%.1f', value)) end,
        apply= Refresh_All,
    },

    {type='section', text='Advanced'},
    {type='check', key='infoPlus', text= function() return WoWTools_L.INFO..' Plus' end, tooltip='Tip.AddOns.InfoPlus', reload=true,
        get= function(save) return not save.disabledInfoPlus end,
        set= function(save, value) save.disabledInfoPlus= not value and true or nil end,
        apply= function(M) Refresh(M, 'Init_Info_Plus') end,
    },
    {type='check', key='keepEnabled', text='Keep WoWToolsPlus on "Disable all"', tooltip='Tip.AddOns.KeepEnabled', indent=true,
        disabled= function(save) return save.disabledInfoPlus end,
        get= function(save) return save.enableAllButtn end,
        set= function(save, value) save.enableAllButtn= value and true or nil end,
        apply= function()
            local btn= _G['WoWToolsAddonsNotDisableButton']
            if btn then
                btn:set_icon()
            end
        end,
    },
}


WoWTools_Module:Register({
    key= 'Plus_AddOns',
    name= 'Module.AddOn manager',
    icon= 'Garr_Building-AddFollowerPlus',
    group= 'Tools',
    defaults= P_Save,
    tooltip= 'Tip.AddOns.Enable',
    mixin= WoWTools_AddOnsMixin,
    options= Options,
    onEnable= function(_, save)
        save.Bg_Alpha= nil--clave antigua que ya no se usa
        Init()
    end,
})
