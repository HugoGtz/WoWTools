

WoWTools_InviteMixin={
    InvPlateGuid={},
}


local function Save()
    return WoWToolsPlusSave['ChatButton_Invite'] or {}
end


function WoWTools_InviteMixin:Get_Leader()
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player') or not IsInGroup()
end



























--####
--####
local function Init(btn)
    btn.texture:SetAtlas('communities-icon-addgroupplus')

    btn.summonTips= btn:CreateTexture(nil,'OVERLAY')
    btn.summonTips:SetPoint('BOTTOMLEFT', 0, 3)
    btn.summonTips:SetSize(16,16)
    btn.summonTips:SetAtlas('Raid-Icon-SummonPending')

    btn.invTips= btn:CreateTexture(nil,'OVERLAY')
    btn.invTips:SetPoint('BOTTOMRIGHT', -2, 0)
    btn.invTips:SetSize(16,16)
    btn.invTips:SetAtlas('poi-traveldirections-arrow2')

    function btn:settings()
        self.summonTips:SetShown(Save().Summon)
        self.invTips:SetShown(Save().Channel and Save().ChannelText or Save().InvTar)
    end

    function btn:set_tooltip()
        self:set_owner()
        GameTooltip:AddDoubleLine(WoWTools_InviteMixin.addName, WoWTools_DataMixin.Icon.left)
        if Save().InvTar then
            GameTooltip:AddLine(WoWTools_L['INVITE+TARGET'])
        end
        if Save().Channel and Save().ChannelText then
            GameTooltip:AddLine((WoWTools_L.CHANNEL)..'|cnGREEN_FONT_COLOR: '..Save().ChannelText)
        end
        GameTooltip:Show()
    end

    WoWTools_InviteMixin:Setup_Menu(btn)

    function btn:set_OnMouseDown()
        WoWTools_InviteMixin:Inv_All_Unit()
    end

    btn:settings()









    Init=function()end
end















local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')

panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['ChatButton_Invite']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['ChatButton_Invite'], {
                InvNoFriend={},
                FriendAceInvite=true,
                InvNoFriendNum=0,
                restingTips=true,
                ChannelText=WoWTools_DataMixin.Player.IsCN and '1' or 'inv',

                Summon= nil,
                notSummonChat=nil,
                SummonChat=nil,--decir gracias al grupo (opcional)
                SummonThxText=nil,
                SummonThxInRaid=nil,

                setFrameFun= true,
                focusKey= 'Shift',
            })

            WoWTools_InviteMixin.addName= '|A:communities-icon-addgroupplus:0:0|a'..(WoWTools_L['Module.Invites'])

            if WoWTools_ChatMixin:CreateButton('Invite', WoWTools_InviteMixin.addName) then
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                Init(WoWTools_ChatMixin:GetButtonForName('Invite'))
            else
                self:SetScript('OnEvent', nil)
            end

            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_InviteMixin:Init_Chanell()
        WoWTools_InviteMixin:Init_Focus()
        WoWTools_InviteMixin:Init_Summon()
        WoWTools_InviteMixin:Init_Resting()
        WoWTools_InviteMixin:Init_Target()
        WoWTools_InviteMixin:Init_StaticPopup()

        self:UnregisterEvent(event)
    end
end)