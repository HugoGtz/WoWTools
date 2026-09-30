

function WoWTools_MoveMixin.Events:Blizzard_GuildBankUI()
    self:Setup(GuildBankFrame)
    self:Setup(GuildBankInfoScrollFrame, {frame=GuildBankFrame})
    self:Setup(GuildBankPopupFrame, {frame=GuildBankFrame})
    
end


