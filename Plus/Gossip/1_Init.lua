WoWTools_GossipMixin= {}
--更新GossipFrame
function WoWTools_GossipMixin:UpdateGossip()--更新GossipFrame
    if GossipFrame:IsShown() then
        GossipFrame:Update()
    end
end



local function Save()
    return WoWToolsPlusSave['Plus_Gossip']
end





















local function Init()
    WoWTools_GossipMixin:Init_Gossip_Data()--自定义，对话，文本
    WoWTools_GossipMixin:Init_WoW_MoveList()

    do
        WoWTools_GossipMixin:Init_Gossip()--对话，初始化
    end

    WoWTools_GossipMixin:Init_Quest()--任务，初始化
    WoWTools_GossipMixin:Init_QuestInfo_Display()--任务目标，类型提示

    WoWTools_GossipMixin:Init_StaticPopupDialogs()
    WoWTools_GossipMixin:Init_Delves()
    WoWTools_GossipMixin:Init_PlayerChoice()

    if Save().gossip then
        if SubscriptionInterstitialFrame and SubscriptionInterstitialFrame:IsShown() then
            SubscriptionInterstitialFrame.ClosePanelButton:Click()
        end
    end

    Init=function()end
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Plus_Gossip']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Gossip'], {
                NPC={--禁用NPC
                    ['223594']=true,
                    ['150122']=true,--荣耀堡法师 50005 我必须向黑暗之门报到。
                },
                gossip= true,

                unique= true,--唯一对话
                gossipOption={--gossipID= text
                    --[123201]=2,--跳过，任务
                    [123176]=2,--跳过，去11.0地图任务

                },
                choice={},--PlayerChoiceFrame
                --movie={},--电影
                stopMovie=true,--如果已播放，停止播放
                stopCinematicsInInstance=true,--仅限在副本里

                quest= true,
                questOption={},
                questRewardCheck={},--{任务ID= index}    

                --questPlayTextStopMove=true,

                scale=1,
                --strata='MEDIUM',
                --bgAlpha=0.5,
                --point=nil,

                --not_Gossip_Text_Icon=true,--自定义，对话，文本

                Gossip_Text_Icon_Size=14,

                --Gossip_Text_Icon_cnFont=nil,--仅限，外文, 修该字体

                Dialogs={}
            })

            WoWToolsPlusPlayerDate.GossipMovie= WoWToolsPlusPlayerDate.GossipMovie or {}

--玩家，自定义，对话，文本
            WoWToolsPlusPlayerDate.GossipTextIcon= WoWToolsPlusPlayerDate.GossipTextIcon or {
                [55193]={
                    icon='communities-icon-invitemail',
                    name=(WoWTools_L.OPENMAIL),
                    hex='ffff00ff'
                }
            }

            WoWTools_GossipMixin.addName= '|A:SpecDial_LastPip_BorderGlow:0:0|a'..(WoWTools_L['Module.Dialogue and quests'])

            WoWTools_GossipMixin.addName2= '|A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest:0:0|a'
                ..(WoWTools_L['QUESTS_LABEL+GAMEMENU_OPTIONS'])

--添加控制面板
            WoWTools_PanelMixin:Check_Button({
                 checkName= WoWTools_GossipMixin.addName,
                 GetValue= function() return not Save().disabled end,
                 SetValue= function()
                    Save().disabled = not Save().disabled and true or nil
                    Init()
                 end,
                 buttonText= WoWTools_L.RESET_POSITION,
                 buttonFunc= function()
                     Save().point=nil
                     if _G['WoWToolsGossipButton'] then
                        _G['WoWToolsGossipButton']:set_point()
                     end
                     WoWTools_Print(
                        WoWTools_GossipMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_L.RESET_POSITION
                    )
                 end,
                 tooltip= WoWTools_L['Tip.Gossip.Module']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
                 layout= nil,
                 category= nil,
             })

            if Save().disabled then
                self:SetScript('OnEvent', nil)
            else
                self:RegisterEvent("PLAYER_ENTERING_WORLD")
            end
            self:UnregisterEvent(event)
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        Init()
        self:UnregisterEvent(event)
        self:SetScript('OnEvent', nil)
    end
end)