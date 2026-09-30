

--好友召募
function WoWTools_MoveMixin.Events:Blizzard_RecruitAFriend()
    RecruitAFriendFrame.RecruitList.ScrollBox:SetPoint('BOTTOMRIGHT', -20,0)
    RecruitAFriendFrame.RewardClaiming.Background:SetPoint('LEFT')
    RecruitAFriendFrame.RewardClaiming.Background:SetPoint('RIGHT')
    --RecruitAFriendFrame.RewardClaiming.NextRewardName:SetPoint('RIGHT', -13, 0)
    --RecruitAFriendFrame.RewardClaiming.NextRewardName.Text:SetPoint('RIGHT')
    WoWTools_MoveMixin:Setup(RecruitAFriendRewardsFrame)
    WoWTools_MoveMixin:Setup(RecruitAFriendFrame.RewardClaiming.Inset, {frame=FriendsFrame})
end

--function WoWTools_MoveMixin.Events:Blizzard_RaidFrame()


--团队信息， 副本击杀信息
function WoWTools_MoveMixin.Events:Blizzard_RaidFrame()
    RaidInfoFrame.ScrollBox:SetPoint('BOTTOMRIGHT',-35, 38)
    RaidInfoDetailFooter:SetPoint('RIGHT', -12, 0)
    RaidInfoInstanceLabel:SetWidth(200)
    RaidInfoIDLabel:ClearAllPoints()
    RaidInfoIDLabel:SetPoint('TOPRIGHT', -13, -31)
    RaidInfoInstanceLabel:ClearAllPoints()
    RaidInfoInstanceLabel:SetPoint('TOPLEFT', 13, -31)
    RaidInfoInstanceLabel:SetPoint('BOTTOMRIGHT', RaidInfoIDLabel, 'BOTTOMLEFT', 1,0)

    local function RaidInfoFrame_Set_point()
        RaidInfoFrame:ClearAllPoints()
        RaidInfoFrame:SetPoint("TOPLEFT", RaidFrame, "TOPRIGHT", 0 ,-28)
    end
    WoWTools_MoveMixin:Setup(RaidInfoFrame, {
        minW=345,
        minH=128,
        notMoveAlpha=true,
        sizeRestFunc=function(frame)
            frame:SetSize(345, 250)
            RaidInfoFrame_Set_point()
        end, restPointFunc=function()
            RaidInfoFrame_Set_point()
        end
    })
end




function WoWTools_MoveMixin.Events:Blizzard_FriendsFrame()--好友列表
    local function Set_RaidFrame_Button_size()
        local w= FriendsFrame:GetWidth()/2-8
        for i=1, 8 do
            local frame= _G['RaidGroup'..i]
            if frame and frame:CanChangeAttribute() then
                frame:SetWidth(w)
                for _, r in pairs({frame:GetRegions()}) do
                    if r:IsObjectType('Texture') then
                        r:SetWidth(w+4)
                    end
                end
            end
            for b=1, 5 do
                local btn2= _G['RaidGroup'..i..'Slot'..b]
                if btn2 and btn2:CanChangeAttribute()  then
                    btn2:SetWidth(w)
                end
            end
        end
        for i=1, 40 do
            local btn2= _G['RaidGroupButton'..i]
            if btn2 and btn2:CanChangeAttribute()  then
                btn2:SetWidth(w)
            end
            local name= _G['RaidGroupButton'..i..'Name']
            if name then--11+23+50 
                name:SetWidth(w-114)
            end
        end
    end

    FriendsListFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -24, 30)

--团队
    RaidFrame:HookScript('OnShow', function(...) Set_RaidFrame_Button_size(...) end)

    WoWTools_DataMixin:Hook(FriendsListButtonMixin, 'OnLoad', function(btn)
        btn.name:SetPoint('RIGHT', btn.gameIcon, 'LEFT', -2, 0)
        btn.info:SetPoint('RIGHT', btn.gameIcon, 'LEFT', -2, 0)
    end)


    WoWTools_MoveMixin:Setup(FriendsFrame, {
        sizeUpdateFunc=function()
            if RaidFrame and RaidFrame:IsVisible() and not WoWTools_FrameMixin:IsLocked(RaidFrame) then
                Set_RaidFrame_Button_size()
                WoWTools_DataMixin:Call('RaidGroupFrame_Update')
            end
        end,
        sizeRestFunc=function(frame)
            frame:SetSize(385, 424)
            if RaidFrame and RaidFrame:IsVisible() and RaidFrame:CanChangeAttribute() then
                Set_RaidFrame_Button_size()
                WoWTools_DataMixin:Call('RaidGroupFrame_Update')
            end
        end
    })


--好友的好友，列表

    FriendsFriendsFrame.ScrollFrameBorder:SetPoint('BOTTOMRIGHT', -25, 55)
    WoWTools_DataMixin:Hook('FriendsFriends_InitButton', function(btn)
        if not btn:GetScript('OnDoubleClick') then
            btn.name:SetPoint('RIGHT', -6, 0)
            btn:SetScript('OnDoubleClick', function()
                WoWTools_DataMixin:Call(FriendsFriendsFrame.SendRequest, FriendsFriendsFrame)
            end)
        end
    end)


    WoWTools_MoveMixin:Setup(FriendsFriendsFrame, {
        minW=295,
        minH=157,
    sizeRestFunc=function(frame)
        frame:SetSize(314, 345)
    end})

--好友 屏蔽列表
    --FriendsFrame.IgnoreListWindow.CloseButton:SetFrameStrata(FriendsFrame.IgnoreListWindow.TitleContainer:GetFrameStrata())
    --FriendsFrame.IgnoreListWindow.CloseButton:SetFrameLevel(FriendsFrame.IgnoreListWindow.TitleContainer:GetFrameLevel()+1)
    FriendsFrame.IgnoreListWindow:ClearAllPoints()
    FriendsFrame.IgnoreListWindow:SetPoint('TOPLEFT', FriendsFrame, 'TOPRIGHT')
    FriendsFrame.IgnoreListWindow:SetPoint('BOTTOMLEFT', FriendsFrame, 'BOTTOMRIGHT')
    self:Setup(FriendsFrame.IgnoreListWindow, {frame=FriendsFrame})

    --WoWTools_TextureMixin:SetButton(FriendsFrame.IgnoreListWindow.ResizeButton)
--通告
    self:Setup(FriendsFrameBattlenetFrame.BroadcastFrame, {frame=FriendsFrame})
end


--好友列表


