

WoWTools_InviteMixin={
    InvPlateGuid={},
}


function WoWTools_InviteMixin:Get_Leader()
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player') or not IsInGroup()
end



























--####
--####
local Init= WoWTools_Once(function(btn)
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
        self.summonTips:SetShown(WoWTools_InviteMixin:Save().Summon)
        self.invTips:SetShown(WoWTools_InviteMixin:Save().Channel and WoWTools_InviteMixin:Save().ChannelText or WoWTools_InviteMixin:Save().InvTar)
    end

    function btn:set_tooltip()
        self:set_owner()
        GameTooltip:AddDoubleLine(WoWTools_InviteMixin.addName, WoWTools_DataMixin.Icon.left)
        if WoWTools_InviteMixin:Save().InvTar then
            GameTooltip:AddLine(WoWTools_L['INVITE+TARGET'])
        end
        if WoWTools_InviteMixin:Save().Channel and WoWTools_InviteMixin:Save().ChannelText then
            GameTooltip:AddLine((WoWTools_L.CHANNEL)..'|cnGREEN_FONT_COLOR: '..Save().ChannelText)
        end
        GameTooltip:Show()
    end

    WoWTools_InviteMixin:Setup_Menu(btn)

    function btn:set_OnMouseDown()
        WoWTools_InviteMixin:Inv_All_Unit()
    end

    btn:settings()
end)















WoWTools_Module:Register({
    key= 'ChatButton_Invite', name= 'Module.Invites', icon= 'communities-icon-addgroupplus',
    parent= 'ChatButton', mixin= WoWTools_InviteMixin,
    defaults= {
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
    },
    onEnable= function()
        if WoWTools_ChatMixin:CreateButton('Invite', WoWTools_InviteMixin.addName) then
            --el resto arranca en el primer PLAYER_ENTERING_WORLD (como antes)
            WoWTools_ChatMixin:OnEnterWorld(function()
                WoWTools_InviteMixin:Init_Chanell()
                WoWTools_InviteMixin:Init_Focus()
                WoWTools_InviteMixin:Init_Summon()
                WoWTools_InviteMixin:Init_Resting()
                WoWTools_InviteMixin:Init_Target()
                WoWTools_InviteMixin:Init_StaticPopup()
            end)
            Init(WoWTools_ChatMixin:GetButtonForName('Invite'))
        end
    end,
})
