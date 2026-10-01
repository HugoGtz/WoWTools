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


WoWTools_Module:Register({
    key= 'Plus_AddOns',
    name= 'Module.AddOn manager',
    icon= 'Garr_Building-AddFollowerPlus',
    group= 'Tools',
    defaults= P_Save,
    tooltip= 'Tip.AddOns.Enable',
    mixin= WoWTools_AddOnsMixin,
    onEnable= function(_, save)
        save.Bg_Alpha= nil--clave antigua que ya no se usa
        Init()
    end,
})
