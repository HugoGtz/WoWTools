local P_Save={
    buttons={
        [BASE_SETTINGS_TAB]={
            ['BugSack']=true,
            ['!BugGrabber']=true,
            ['TextureAtlasViewer']=true,-- true, i or guid
            ['WoWTools_Chinese']=(not LOCALE_zhCN and not LOCALE_zhTW) and true or nil,
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



local function Save()
    return WoWToolsPlusSave['Plus_AddOns'] or {}
end


--#####
--#####
local function Init()
    WoWTools_AddOnsMixin:Init_Menu_Button()
    WoWTools_AddOnsMixin:Init_Bottom_Buttons()
    WoWTools_AddOnsMixin:Init_Right_Buttons()
    WoWTools_AddOnsMixin:Init_Left_Buttons()
    WoWTools_AddOnsMixin:Init_Info_Plus()
    Init=function()end
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1~= 'WoWToolsPlus' then
        return
    end

    WoWToolsPlusSave['Plus_AddOns']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_AddOns'], P_Save)
    P_Save=nil
    Save().Bg_Alpha= nil

    WoWTools_AddOnsMixin.addName='|A:Garr_Building-AddFollowerPlus:0:0|a'..(WoWTools_L['Module.AddOn manager'])

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_AddOnsMixin.addName,
        tooltip= WoWTools_L['Tip.AddOns.Enable']..'|n|n'..WoWTools_L['REQUIRES_RELOAD~2'],
        Value= not Save().disabled,
        GetValue=function () return not Save().disabled end,
        SetValue= function()
            Save().disabled = not Save().disabled and true or nil
            if not Save().disabled then
                if Init() then
                    Init=function()end
                    return
                end
            end
            WoWTools_Print(
                WoWTools_AddOnsMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                WoWTools_L['REQUIRES_RELOAD~2']
            )
        end
    })



    if not Save().disabled then
        Init()
    end

    self:SetScript('OnEvent', nil)
    self:UnregisterEvent(event)
end)