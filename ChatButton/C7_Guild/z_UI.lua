
function WoWTools_TooltipMixin.Events:Blizzard_Communities()
    WoWTools_DataMixin:Hook(CommunitiesAvatarButtonMixin, 'Init', function(btn)
        if not btn.Name then
            btn.Name= WoWTools_LabelMixin:Create(btn, {mouse=true})
            btn.Name:SetPoint('BOTTOM')
            btn.Name:SetScript('OnLeave', function(b)
                b:SetAlpha(1)
                GameTooltip:Hide()
            end)
            btn.Name:SetScript('OnEnter', function(b)
                GameTooltip:SetOwner(b, 'ANCHOR_LEFT')
                GameTooltip_SetTitle(GameTooltip, WoWTools_DataMixin.Icon.icon2..'avatarId')
                GameTooltip:Show()
                b:SetAlpha(0.5)
            end)
        end
        btn.Name:SetText(btn.avatarId or '')
    end)
end









function WoWTools_MoveMixin.Events:Blizzard_Communities()


    local function set_size(frame)
        frame= frame:GetParent()
        if WoWTools_FrameMixin:IsLocked(frame) or not frame.ResizeButton then
            return
        end

        local size, scale
        local displayMode = frame:GetDisplayMode();
        if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
            frame.ResizeButton.minWidth= 290
            frame.ResizeButton.minHeight= 115
            size= self:Save().size['CommunitiesFrameMINIMIZED']
            scale= self:Save().scale['CommunitiesFrameMINIMIZED']
        else
            size= self:Save().size['CommunitiesFrameNormal']
            scale= self:Save().scale['CommunitiesFrameNormal']
            frame.ResizeButton.minWidth= 562--814
            frame.ResizeButton.minHeight= 228--426
        end

        if size then
            frame:SetSize(size[1], size[2])
        end
        if scale then
            frame:SetScale(scale)
        end
    end




    --WoWTools_DataMixin:Hook(ClubFinderCommunitiesCardMixin, 'Init', function(b)
    local function Init_Update(frame)
        if not frame:HasView() or WoWTools_FrameMixin:IsLocked(frame) then
            return
        end
        for _, btn in pairs(frame:GetFrames() or {}) do
            btn.Name:ClearAllPoints()
            btn.Name:SetPoint('TOPLEFT', btn.LogoBorder, 'TOPRIGHT', 12,0)
            btn.Description:ClearAllPoints()
            btn.Description:SetPoint('LEFT', btn.LogoBorder, 'RIGHT', 12,0)
            btn.Description:SetPoint('RIGHT', btn.RequestJoin, 'LEFT', -26,0)
            btn.Background:SetPoint('RIGHT', -12,0)
            local cardInfo= btn.cardInfo-- or {}-- clubFinderGUID, isCrossFaction, clubId, 

            if not btn.corssFactionTexture and cardInfo.isCrossFaction then
                btn.corssFactionTexture= btn:CreateTexture(nil, 'OVERLAY')
                btn.corssFactionTexture:SetSize(18,18)
                btn.corssFactionTexture:SetAtlas('CrossedFlags')
                btn.corssFactionTexture:SetPoint('LEFT', btn.MemberIcon, 'RIGHT', 4, 0)
            end
            if btn.corssFactionTexture then
                btn.corssFactionTexture:SetShown(true)--not cardInfo.isCrossFaction)
            end
            local autoAccept
            local clubStatus= cardInfo.clubFinderGUID and C_ClubFinder.GetPlayerClubApplicationStatus(cardInfo.clubFinderGUID)
            btn:SetAlpha(btn.RequestJoin:IsShown() and 1 or 0.3)
            if clubStatus then
                autoAccept= clubStatus== Enum.PlayerClubRequestStatus.AutoApproved--2
            end
            if not btn.autoAcceptTexture and autoAccept then
                btn.autoAcceptTexture= btn:CreateTexture(nil, 'OVERLAY')
                btn.autoAcceptTexture:SetSize(18,18)
                btn.autoAcceptTexture:SetAtlas('common-icon-checkmark')
                btn.autoAcceptTexture:SetPoint('LEFT', btn.MemberIcon, 'RIGHT', 24, 0)
            end
            if btn.autoAcceptTexture then
                btn.autoAcceptTexture:SetShown(autoAccept)
            end
        end
    end


    local sub


    WoWTools_DataMixin:Hook(CommunitiesFrame.MaxMinButtonFrame, 'Minimize', set_size)--maximizedCallback
    WoWTools_DataMixin:Hook(CommunitiesFrame.MaxMinButtonFrame, 'Maximize', set_size)

    CommunitiesFrame.GuildBenefitsFrame.Perks:SetPoint('TOPRIGHT', CommunitiesFrame.GuildBenefitsFrame, 'TOP', -17, 0)
    CommunitiesFrame.GuildBenefitsFrame.Rewards:SetPoint('LEFT', CommunitiesFrame.GuildBenefitsFrame.Perks, 'RIGHT', 15, 0)
    CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar:SetPoint('TOPRIGHT', CommunitiesFrame.GuildBenefitsFrame.Perks, 'BOTTOMRIGHT')

    CommunitiesFrame.GuildBenefitsFrame.Perks:GetRegions():SetPoint('BOTTOMRIGHT', 14, 0)--bg
    CommunitiesFrame.GuildBenefitsFrame.Rewards:GetRegions():SetPoint('BOTTOMRIGHT', 14, 0)

    WoWTools_DataMixin:Hook(ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ScrollBox, 'Update', Init_Update)
    


    CommunitiesFrameGuildDetailsFrameInfo:SetWidth(272)



    CommunitiesFrameGuildDetailsFrameInfo.Header1:SetPoint('RIGHT', 14,0)
    CommunitiesFrameGuildDetailsFrameInfoChallenge1:SetPoint('RIGHT')
    CommunitiesFrameGuildDetailsFrameInfoChallenge2:SetPoint('RIGHT')
    CommunitiesFrameGuildDetailsFrameInfoChallenge3:SetPoint('RIGHT')
    CommunitiesFrameGuildDetailsFrameInfoChallenge4:SetPoint('RIGHT')
    CommunitiesFrameGuildDetailsFrameInfo.BG:SetPoint('RIGHT', 14, 0)

    CommunitiesFrameGuildDetailsFrameInfo.Header2:SetPoint('RIGHT', 14,0)

    CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame:SetPoint('BOTTOMLEFT', CommunitiesFrameGuildDetailsFrameInfoBar2Left, 'TOPLEFT', 14, 0)
    CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame:SetPoint('RIGHT')

    CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame:SetPoint('RIGHT')
    sub= CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame:GetChildren()
    if sub and sub.Details then
        sub:SetPoint('RIGHT', CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame)
        sub.Details:SetPoint('RIGHT', CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame, 0, 4)
    end

    CommunitiesFrameGuildDetailsFrameNews:SetPoint('LEFT', CommunitiesFrameGuildDetailsFrameInfo, 'RIGHT', 15, 0)
    CommunitiesFrameGuildDetailsFrameNews.ScrollBox:SetPoint('BOTTOMRIGHT')
    CommunitiesFrameGuildDetailsFrameNews.Header:SetPoint('RIGHT', -14, 0)
    --CommunitiesFrameGuildDetailsFrameNews.SetFiltersButton:SetPoint('RIGHT', CommunitiesFrameGuildDetailsFrameNews.Header, -2, 0)




    CommunitiesGuildTextEditFrame.Container.ScrollFrame.EditBox:SetPoint('RIGHT')
    CommunitiesGuildTextEditFrame.Container.ScrollFrame.EditBox:SetPoint('BOTTOM')
    WoWTools_EditBoxMixin:Setup(CommunitiesGuildTextEditFrame.Container.ScrollFrame.EditBox, {isMaxLetter=true})
    WoWTools_DataMixin:Hook('CommunitiesGuildTextEditFrame_SetType', function(frame)
        self:Set_SizeScale(frame)
        frame.Container.ScrollFrame.EditBox:SetScript("OnEnterPressed", nil)
    end)


    local function CommunitiesMode_IsMini()
        return CommunitiesFrame:GetDisplayMode()==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED
    end
    local function CommunitiesMode_GetName()
        return CommunitiesMode_IsMini() and 'CommunitiesFrameMINIMIZED' or 'CommunitiesFrameNormal'
    end

    self:Setup(CommunitiesFrame, {
        scaleStopFunc= function(frame)
            self:Save().scale[CommunitiesMode_GetName()]= frame:GetScale()
        end,
        scaleRestFunc=function()
            self:Save().scale['CommunitiesFrameMINIMIZED']= nil
            self:Save().scale['CommunitiesFrameNormal']= nil
        end,
        sizeStopFunc=function(frame)
            self:Save().size[CommunitiesMode_GetName()]=  {frame:GetSize()}
        end,
        sizeRestFunc=function(frame)
            self:Save().size['CommunitiesFrameMINIMIZED']=nil
            self:Save().size['CommunitiesFrameNormal']= nil
            if CommunitiesMode_IsMini() then
                frame:SetSize(322, 406)
            else
                frame:SetSize(814, 426)
            end
        end,
        sizeRestTooltipColorFunc=function()
            if self:Save().size[CommunitiesMode_GetName()] then
                return ''
            else
                return '|cff626262'
            end
        end,
    })


    self:Setup(CommunitiesTicketManagerDialog)

    self:Setup(CommunitiesGuildNewsFiltersFrame)


    self:Setup(CommunitiesFrame.GuildMemberDetailFrame, {frame=CommunitiesFrame})
    WoWTools_DataMixin:Hook(CommunitiesFrame.GuildMemberDetailFrame, 'DisplayMember', function(frame)
        frame:SetHeight(frame:GetHeight()+15)
    end)
    CommunitiesFrame.GuildMemberDetailFrame.NoteBackground.PersonalNoteText:SetNonSpaceWrap(true)

    self:Setup(CommunitiesGuildLogFrame, {
    sizeRestFunc=function(frame)
        frame:SetSize(384, 432)
    end})

    self:Setup(CommunitiesGuildTextEditFrame, {
    sizeRestFunc=function(frame)
        frame:SetSize(295, 295)
    end})


    self:Setup(PetitionFrame, {
    sizeRestFunc=function(frame)
        frame:SetSize(338, 424)
    end})
    PetitionFrame.Bg:SetPoint('BOTTOMRIGHT',-32,30)


    CommunitiesFrameCommunitiesList:SetPoint('BOTTOMRIGHT', CommunitiesFrame, 'BOTTOMLEFT', 170, 3)


    self:Setup(TabardFrame, {
    sizeRestFunc=function(frame)
        frame:SetSize(338, 424)
    end})

    TabardFrameCancelButton:ClearAllPoints()
    TabardFrameCancelButton:SetPoint('BOTTOMRIGHT', -20, 8)
    TabardFrameAcceptButton:ClearAllPoints()
    TabardFrameAcceptButton:SetPoint('RIGHT', TabardFrameCancelButton, 'LEFT')
    TabardFrameNameText:ClearAllPoints()
    TabardFrameNameText:SetParent(TabardFrame.TitleContainer)
    TabardFrameNameText:SetPoint('CENTER',TabardFrame.TitleContainer)
    TabardFrameNameText:SetDrawLayer('BORDER', 7)

    TabardFrameCostFrame:ClearAllPoints()
    TabardFrameCostFrame:SetPoint('TOPRIGHT', -8, -60)

    TabardFrameEmblemTopRight:ClearAllPoints()
    TabardFrameEmblemTopRight:SetPoint('BOTTOMRIGHT', 0, 240)

    TabardModel:SetPoint('TOPLEFT', 2, 0)
    TabardModel:SetPoint('TOPRIGHT', -2, 0)
    TabardModel:SetPoint('BOTTOM', TabardFrame, 'BOTTOM', 0, 2)

    TabardModel:HookScript('OnMouseWheel', function(frame, d)--ModelFrameMixin.lua
        local rotationsPerSecond = ROTATIONS_PER_SECOND;
        local elapsedTime= 0.05
        if d==-1 then
            frame.rotation = frame.rotation + (elapsedTime * 2 * PI * rotationsPerSecond);
            if ( frame.rotation > (2 * PI) ) then
                frame.rotation = frame.rotation - (2 * PI);
            end
            frame:SetRotation(frame.rotation);

        else
            frame.rotation = frame.rotation - (elapsedTime * 2 * PI * rotationsPerSecond);
            if ( frame.rotation < 0 ) then
                frame.rotation = frame.rotation + (2 * PI);
            end
            frame:SetRotation(frame.rotation);
        end
    end)


    self:Setup(GuildControlUI, {
    sizeRestFunc=function(frame)
        frame:SetSize(338, 444)
    end})
    GuildControlUIRankBankFrameInset:SetPoint('LEFT', 2, 0)
    GuildControlUIRankBankFrameInset:SetPoint('BOTTOMRIGHT', -2, 2)

end



function WoWTools_MoveMixin.Frames:GuildRegistrarFrame()
    self:Setup(GuildRegistrarFrame)

    WoWTools_EditBoxMixin:Setup(GuildRegistrarFrameEditBox,  {isMaxLetter=true, maxLetterPoint=function(edit, label)
        label:SetPoint('BOTTOMRIGHT', edit, 'TOPRIGHT')
    end})
    WoWTools_EditBoxMixin:Setup(GuildRenameFrame.RenameFlow.NameBox,  {isMaxLetter=true, maxLetterPoint=function(edit, label)
        label:SetPoint('BOTTOMRIGHT', edit, 'TOPRIGHT')
    end})
    local label= WoWTools_LabelMixin:Create(GuildRenameFrame.RenameFlow.NameBox, {color=true, name='WoWToolsGuildRenameFrameRenameMaxLabel'})
    label:SetPoint('LEFT', GuildRenameFrame.RenameFlow.NameBox, 'RIGHT')
    label:SetText(24)
end