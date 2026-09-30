
function WoWTools_MoveMixin.Events:Blizzard_PlayerSpells()
    HeroTalentsSelectionDialog.p_point={PlayerSpellsFrame:GetPoint(1)}
    HeroTalentsSelectionDialog.p_point[2]= nil
    HeroTalentsSelectionDialog:HookScript('OnShow', function(frame)
        if not InCombatLockdown() then
            PlayerSpellsFrame:ClearAllPoints()
            PlayerSpellsFrame:SetPoint(frame.p_point[1], UIParent, frame.p_point[3], frame.p_point[4], frame.p_point[5])
        end

    end)
    HeroTalentsSelectionDialog:HookScript('OnHide', function()
        self:SetPoint(PlayerSpellsFrame)
    end)
    --self:Setup(HeroTalentsSelectionDialog)



    PlayerSpellsFrame:HookScript('OnShow', function(frame)
        self:Set_Frame_Scale(frame)
    end)
    self:Setup(PlayerSpellsFrame)

    for specContentFrame in PlayerSpellsFrame.SpecFrame.SpecContentFramePool:EnumerateActive() do
        self:Setup(specContentFrame, {frame=PlayerSpellsFrame})
    end

    self:Setup(PlayerSpellsFrame.TalentsFrame, {frame=PlayerSpellsFrame})
    self:Setup(PlayerSpellsFrame.TalentsFrame.ButtonsParent, {frame=PlayerSpellsFrame})

    self:Setup(PlayerSpellsFrame.SpellBookFrame, {frame=PlayerSpellsFrame})
end

