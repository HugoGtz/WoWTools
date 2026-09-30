




--####
--####
local function Init()
    WoWTools_DataMixin:Hook(TargetFrame, 'CheckClassification', function(frame)
        local color= WoWTools_UnitMixin:GetColor(frame.unit)
        local r,g,b= color:GetRGB()
        frame.TargetFrameContainer.FrameTexture:SetVertexColor(r, g, b)
        frame.TargetFrameContainer.BossPortraitFrameTexture:SetVertexColor(r, g, b)
        frame.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
        frame.healthbar:SetStatusBarColor(r,g,b)
    end)

    --TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:SetPoint('RIGHT')
    --TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:SetShadowOffset(2, -2)
    --<Anchor point="TOPLEFT" relativeKey="$parent.ReputationColor" relativePoint="TOPRIGHT" x="-106" y="-1"/>

    WoWTools_DataMixin:Hook(TargetFrame,'CheckLevel', function(self)
        local levelText = self.TargetFrameContent.TargetFrameContentMain.LevelText
        if levelText then
            local color= WoWTools_UnitMixin:GetColor(self.unit)
            levelText:SetTextColor(color:GetRGB())
        end
    end)

    local rangeFrame= CreateFrame('Frame', nil, TargetFrame)
    rangeFrame:SetSize(1,1)
    rangeFrame:SetPoint('RIGHT', TargetFrame, 'LEFT', 22, 6)
    rangeFrame.unit= 'target'
    WoWTools_UnitMixin:SetRangeFrame(rangeFrame)


    --WoWTools_TextureMixin:SetFrame(TargetFrame.TargetFrameContent.TargetFrameContentContextual.NumericalThreat, {index=1})

    TargetFrame.TargetFrameContent.TargetFrameContentContextual.PvpIcon:SetScale(0.6)
        TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigePortrait:SetScale(0.6)
    TargetFrame.TargetFrameContent.TargetFrameContentContextual.PrestigeBadge:SetScale(0.6)

    Init=function()end
end













function WoWTools_UnitMixin:Init_TargetFrame()
    Init()
end