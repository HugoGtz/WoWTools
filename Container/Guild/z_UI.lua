function WoWTools_TextureMixin.Events:Blizzard_GuildBankUI()
    GuildBankFrame.Emblem.Left:Hide()
    GuildBankFrame.Emblem.Right:Hide()


    self:SetButton(GuildBankFrame.CloseButton, {all=true})

    for i=1, 4 do
        self:SetTabButton(_G['GuildBankFrameTab'..i])
    end

    GuildBankFrame.BlackBG:ClearAllPoints()
    GuildBankFrame.BlackBG:SetAllPoints()

    self:HideTexture(GuildBankFrame.TitleBg)
    self:HideTexture(GuildBankFrame.RedMarbleBG)
    GuildBankFrame.MoneyFrameBG:DisableDrawLayer('BACKGROUND')



    self:HideTexture(GuildBankFrameBottomOuter)
    self:HideTexture(GuildBankFrameTopOuter)
    self:HideTexture(GuildBankFrameLeftOuter)
    self:HideTexture(GuildBankFrameRightOuter)

    self:HideTexture(GuildBankFrameBottomLeftOuter)
    self:HideTexture(GuildBankFrameBottomRightOuter)
    self:HideTexture(GuildBankFrameTopLeftOuter)
    self:HideTexture(GuildBankFrameTopRightOuter)

    self:HideTexture(GuildBankFrameLeftInner)
    self:HideTexture(GuildBankFrameRightInner)
    self:HideTexture(GuildBankFrameTopInner)
    self:HideTexture(GuildBankFrameBottomInner)

    self:HideTexture(GuildBankFrameBottomLeftInner)
    self:HideTexture(GuildBankFrameBottomRightInner)
    self:HideTexture(GuildBankFrameTopLeftInner)
    self:HideTexture(GuildBankFrameTopRightInner)

    self:HideTexture(GuildBankFrame.TabLimitBG)
    self:HideTexture(GuildBankFrame.TabLimitBGLeft)
    self:HideTexture(GuildBankFrame.TabLimitBGRight)
    self:SetEditBox(GuildItemSearchBox)

    self:HideTexture(GuildBankFrame.TabTitleBG)
    self:HideTexture(GuildBankFrame.TabTitleBGLeft)
    self:HideTexture(GuildBankFrame.TabTitleBGRight)

--按钮，列，背景
    for i=1, 7 do
        local frame= GuildBankFrame['Column'..i]
        if frame then
            self:HideTexture(frame.Background)
        end
    end



    self:SetScrollBar(GuildBankFrame.Log)
    self:SetScrollBar(GuildBankInfoScrollFrame)
    self:SetUIButton(GuildBankInfoSaveButton)

--右边 Tab
    for index, tab in pairs(GuildBankFrame.BankTabs) do
        self:SetFrame(_G['GuildBankTab'..index], {alpha=0})
        self:SetAlphaColor(tab.Button.NormalTexture, nil, true, 0)
        WoWTools_ButtonMixin:AddMask(tab.Button, true, tab.Button.IconTexture)
    end



    self:Init_BGMenu_Frame(GuildBankFrame, {
        enabled=true,
        alpha=1,
        isNewButton=true,
        newButtonPoint=function(btn)
            btn:SetPoint('RIGHT', GuildBankFrame.CloseButton, 'LEFT', -23, 0)
        end,
        settings=function(_, texture, alpha)
            GuildBankFrame.BlackBG:SetAlpha(texture and 0 or alpha or 1)
        end
    })
end


function WoWTools_MoveMixin.Events:Blizzard_GuildBankUI()
    self:Setup(GuildBankFrame)
    self:Setup(GuildBankInfoScrollFrame, {frame=GuildBankFrame})
    self:Setup(GuildBankPopupFrame, {frame=GuildBankFrame})
    
end


