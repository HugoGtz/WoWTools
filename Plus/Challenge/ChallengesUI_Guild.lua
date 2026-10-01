

local Frame


local function Set_Text()
    local data= C_ChallengeMode.GetGuildLeaders()
    local text= WoWTools_L.GUILD_CHALLENGE_LABEL


    if not data or not data.mapChallengeModeID then
        Frame.Text:SetText(text)
        Frame.Background:SetAtlas('ChallengeMode-guild-background')
        return
    end


    local name, _, _, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(data.mapChallengeModeID)
    if backgroundTexture and backgroundTexture>0 then
        Frame.Background:SetTexture(texture, false)
    else
        Frame.Background:SetAtlas('ChallengeMode-guild-background')
    end

    if name then
        text= text..'|n|n'
            ..(data.keystoneLevel and '< |cffffffff'..data.keystoneLevel..'|r >' or '')
            ..' '
            ..WoWTools_TextMixin:CN(name)
            ..format('|T%d:0|t', texture or 0)
    end

    if data.isYou then
        text= text
            ..'|n|n'
            ..WoWTools_ColorMixin:SetStringColor(WoWTools_L.COMBATLOG_FILTER_STRING_ME)
            ..WoWTools_DataMixin.Icon.Player
    elseif data.name then
        local color= WoWTools_UnitMixin:GetColor(nil, nil, data.classFilename)
        local icon= WoWTools_UnitMixin:GetClassIcon(nil, nil, data.classFilename)
        text= text..'|n|n'
            ..color:GenerateHexColorMarkup()
            ..data.name
            ..(icon or '')
            ..'|r'
    end

    for i=1, #data.members do
        local member= data.members[i]
        if member.name and member.name~=data.name then
            local color= WoWTools_UnitMixin:GetColor(nil, nil, member.classFileName)

            local icon= WoWTools_UnitMixin:GetClassIcon(nil, nil, member.classFileName)
            text= text..'|n'
                ..color:GenerateHexColorMarkup()
                ..member.name
                ..(icon or '')
                ..'|r'
        end
    end
    Frame.Text:SetText(text)
end


local function Init()
    if not IsInGuild() or WoWTools_ChallengeMixin:Save().hideGuild then
        return
    end

    Frame= CreateFrame('Frame', nil, ChallengesFrame)
    Frame:SetFrameStrata('HIGH')
    Frame:SetFrameLevel(3)
    Frame:SetSize(1,1)
    Frame:Hide()

    Frame.Text= WoWTools_LabelMixin:Create(Frame, {
        color=true,
        justifyH= 'RIGHT',
    })
    Frame.Text:SetPoint('TOPRIGHT')

    WoWTools_TextureMixin:CreateBG(Frame, {
        point=function(texture)
            texture:SetPoint('TOPLEFT', Frame.Text, 0, 4)
            texture:SetPoint('BOTTOMRIGHT', Frame.Text, 4, -6)
        end
    })

    function Frame:Settings()
        self:SetPoint('TOPRIGHT', ChallengesFrame, WoWTools_ChallengeMixin:Save().guildX or -15, WoWTools_ChallengeMixin:Save().guildY or -32)
        self:SetScale(WoWTools_ChallengeMixin:Save().guildScale or 1)
        self.Background:SetAlpha(WoWTools_ChallengeMixin:Save().guildBgAlpha or 0.5)
        self:SetShown(not WoWTools_ChallengeMixin:Save().hideGuild and IsInGuild())
     end

     Frame:SetScript('OnShow', function(self)
        Set_Text()
        self:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')
        self:RegisterEvent('GUILD_CHALLENGE_UPDATED')
        self:RegisterEvent('GUILD_CHALLENGE_COMPLETED')
    end)
    Frame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self.Text:SetText('')
    end)
    Frame:SetScript('OnEvent', function()
        Set_Text()
    end)

    Frame:Settings()

    Init=function()
        Frame:SetShown(false)
        Frame:Settings()
    end
end


function WoWTools_ChallengeMixin:ChallengesUI_Guild()
    Init()
end