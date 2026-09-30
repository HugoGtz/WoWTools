WoWTools_GossipMixin= {}
function WoWTools_GossipMixin:UpdateGossip()
    if GossipFrame:IsShown() then
        GossipFrame:Update()
    end
end



local function Save()
    return WoWToolsPlusSave['Plus_Gossip']
end





















local function Init()
    WoWTools_GossipMixin:Init_Gossip_Data()
    WoWTools_GossipMixin:Init_WoW_MoveList()

    do
        WoWTools_GossipMixin:Init_Gossip()
    end

    WoWTools_GossipMixin:Init_Quest()
    WoWTools_GossipMixin:Init_QuestInfo_Display()

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
                NPC={
                    ['223594']=true,
                    ['150122']=true,
                },
                gossip= true,

                unique= true,
                gossipOption={--gossipID= text
                    [123176]=2,

                },
                choice={},--PlayerChoiceFrame
                stopMovie=true,
                stopCinematicsInInstance=true,

                quest= true,
                questOption={},
                questRewardCheck={},

                --questPlayTextStopMove=true,

                scale=1,
                --strata='MEDIUM',
                --bgAlpha=0.5,
                --point=nil,


                Gossip_Text_Icon_Size=14,


                Dialogs={}
            })

            WoWToolsPlusPlayerDate.GossipMovie= WoWToolsPlusPlayerDate.GossipMovie or {}

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