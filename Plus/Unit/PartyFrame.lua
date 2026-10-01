local function Is_InEditMode()
    if EditModeManagerFrame then
        return EditModeManagerFrame:IsEditModeActive()-- EditModeManagerFrame:ArePartyFramesForcedShown()
    end
end


local function Create_frame(partyFrame)
    local frame= CreateFrame("Frame", nil, partyFrame)

    frame.faction=frame:CreateTexture('WoWToolsPlus'..partyFrame.unit..'FactionTexture', 'ARTWORK')
    frame.faction:SetSize(14,14)
    frame.faction:SetPoint('TOPLEFT', partyFrame.Portrait)

    function frame:settings()
        local atlas
        if Is_InEditMode() then
            atlas= WoWTools_DataMixin.Icon[WoWTools_DataMixin.Player.Faction]
        else
            local faction= UnitFactionGroup(self:GetParent().unit)
            if faction~= WoWTools_DataMixin.Player.Faction then
                atlas= WoWTools_DataMixin.Icon[faction]
            end
        end
        if atlas then
            self.faction:SetAtlas(atlas)
        else
            self.faction:SetTexture(0)
        end
    end

    function frame:set_event()
        self:RegisterUnitEvent('UNIT_FACTION', self:GetParent().unit)
        self:settings()
    end

    frame:SetScript('OnEvent', frame.settings)

    frame:SetScript('OnHide', function(self)
        self:UnregisterEvent('UNIT_FACTION')
        self.faction:SetTexture(0)
    end)

    frame:SetScript('OnShow', frame.set_event)

    if partyFrame:IsVisible() then
        frame:set_event()
    end
end


local function Create_combatFrame(frame)
    frame.combatFrame= CreateFrame('Frame', nil, frame)

    local combatFrame= frame.combatFrame

    if frame.PartyMemberOverlay then
        --combatFrame:SetPoint('TOPLEFT', frame, 'TOPRIGHT',-6, -4)
        combatFrame:SetPoint('LEFT', frame.PartyMemberOverlay.RoleIcon, 'RIGHT')
        combatFrame:SetSize(frame.PartyMemberOverlay.RoleIcon:GetSize())
        combatFrame:SetFrameStrata('HIGH')
    else
        --.PartyMemberOverlay.RoleIcon
        combatFrame:SetPoint('TOPLEFT', 4, -17)
        combatFrame:SetSize(12, 12)-- frame.roleIcon:GetSize() 17
    end

    combatFrame.texture= combatFrame:CreateTexture(nil, 'BORDER')
    combatFrame.texture:SetAllPoints()
    combatFrame.texture:SetAtlas('UI-HUD-UnitFrame-Player-CombatIcon')
    combatFrame.texture:SetVertexColor(1, 0, 0)
    combatFrame.texture:Hide()


    function combatFrame:Init()
        self.unit= self:GetParent().unit
    end

    combatFrame:SetScript('OnShow', combatFrame.Init)
    combatFrame:Init()

    combatFrame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3) + elapsed
        if self.elapsed>0.3 then
            self.elapsed=0
            self.texture:SetShown(UnitAffectingCombat(self.unit) or Is_InEditMode())
        end
    end)
end


local function Create_positionFrame(frame)

    local Frame= CreateFrame("Frame", nil, frame)
    Frame:SetPoint('LEFT', frame.PartyMemberOverlay.LeaderIcon, 'RIGHT')
    Frame:SetSize(1,1)
    Frame.map= CreateFrame('Frame', nil, Frame)
    Frame.map.Text= Frame.map:CreateFontString(nil, 'BORDER', 'WoWToolsFont')--  WoWTools_LabelMixin:Create(Frame.map)
    Frame.map.Text:SetFontHeight(10)
    Frame.map.Text:SetPoint('LEFT', Frame)
    Frame.map:Hide()
    Frame.xy= CreateFrame('Frame', nil, Frame)
    Frame.xy:SetSize(1,1)
    Frame.xy:SetPoint('RIGHT', frame.Portrait, 'LEFT')
    Frame.xy:Hide()
    Frame.xy.unit= frame.unit
    WoWTools_UnitMixin:SetRangeFrame(Frame.xy, 10)




    Frame.map:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3) + elapsed
        if self.elapsed<=0.3 then
            return
        end
        self.elapsed=0

        local text
        text= ''

        local info= C_PlayerInfo.GetPlayerMythicPlusRatingSummary(self.unit)
        if info and info.currentSeasonScore and info.currentSeasonScore>0 then
            text= WoWTools_ChallengeMixin:KeystoneScorsoColor(info.currentSeasonScore, true)
        end

        local mapID= C_Map.GetBestMapForUnit(self.unit)
        local mapInfo= mapID and C_Map.GetMapInfo(mapID)
        if mapInfo and mapInfo.name then
            local mapID2= C_Map.GetBestMapForUnit('player')
            text= text.. '|A:'..(mapID2== mapID and 'common-icon-checkmark' or 'poi-islands-table')..':0:0|a'
            text= text..WoWTools_TextMixin:CN(mapInfo.name)
        end

        local distanceSquared, checkedDistance = UnitDistanceSquared(self.unit)
        if canaccessvalue(distanceSquared) and distanceSquared and checkedDistance then
            text= text..' '..WoWTools_DataMixin:MK(math.sqrt(distanceSquared), 0)--la API devuelve el cuadrado
        end

        self.Text:SetText(text)
    end)



    function Frame:set_shown()
        local isInInstance= select(2, IsInInstance())~='none'
        local isInEditMode= Is_InEditMode()

        self.map:SetShown(isInEditMode or not isInInstance)
        self.xy:SetShown(isInEditMode or isInInstance)
    end

    function Frame:Init()
        local unit= self:GetParent().unit
        self.unit= unit
        self.map.unit= unit

        local color= WoWTools_UnitMixin:GetColor(unit)
        self.map.Text:SetTextColor(color:GetRGB())

        self:RegisterEvent('PLAYER_ENTERING_WORLD')
        self:set_shown()
    end

    Frame:SetScript('OnEvent',  function(self)
        self:set_shown()
    end)

    Frame:SetScript('OnHide', function(self)
        self.map.elapsed=nil
        self.map.unit=nil
        self.map.Text:SetText('')

        self.unit=nil
        self:UnregisterAllEvents()
    end)

    if frame:IsShown() then
        Frame:Init()
    end

    Frame:SetScript('OnShow', function(self)
        self:Init()
    end)

end


local function Rest_AllDeadData()
     WoWTools_UnitMixin:Save().PartyDeadData={}
     for i=1, MAX_PARTY_MEMBERS+1 do
        if _G['CompactPartyFrameMember'..i] then
            local frame= _G['CompactPartyFrameMember'..i].deadFrame
            if frame and frame:IsVisible() then
                frame:UnregisterAllEvents()
                frame:Init()
            end
        end
        if PartyFrame['MemberFrame'..i] then
            local frame= PartyFrame['MemberFrame'..i].deadFrame
            if frame and frame:IsVisible() then
                frame:UnregisterAllEvents()
                frame:Init()
            end
        end
    end
end


local function Create_deadFrame(frame)
    frame.deadFrame= CreateFrame('Frame', nil, frame)
    local deadFrame= frame.deadFrame

    deadFrame:SetSize(1,1)

    deadFrame.Text= deadFrame:CreateFontString(nil, 'BORDER', 'WoWToolsFont2') --WoWTools_LabelMixin:Create(deadFrame, {mouse=true, color={r=1,g=1,b=1}})
    deadFrame.Text:EnableMouse(true)

    if frame.PartyMemberOverlay then
        deadFrame:SetPoint('TOPRIGHT', frame.Portrait, 2, -4)
        deadFrame.Text:SetPoint("RIGHT")
    else
        deadFrame:SetPoint('TOPLEFT', 16, -17)
        deadFrame.Text:SetPoint("TOPLEFT")
        deadFrame.Text:SetFontHeight(10)
    end



    deadFrame.Text:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    deadFrame.Text:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(self:GetParent().unit, 1,1,1)
        GameTooltip:AddLine(
            WoWTools_DataMixin.Icon.icon2..(WoWTools_L.DEAD)
            ..': |cffffffff'..self:GetText()..'|r '
           ..(WoWTools_L.VOICEMACRO_LABEL_CHARGE1)
        )
        GameTooltip:AddLine(
            (WoWTools_L.RESET_ALL_BUTTON_TEXT)
            ..WoWTools_DataMixin.Icon.left
        )
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    deadFrame.Text:SetScript('OnMouseDown', function(self)
        Rest_AllDeadData()
        self:SetAlpha(0.3)
    end)
    deadFrame.Text:SetScript('OnMouseUp', function(self)
        self:SetAlpha(0.5)
    end)

    function deadFrame:GetName()
        local name= GetUnitName(self.unit, true)
        if not issecretvalue(name) then
            return name
        end
    end

    function deadFrame:settings()
        local name= self:GetName()
        local text
        if name then
            text= WoWTools_UnitMixin:Save().PartyDeadData[name] or 0
        end
        self.Text:SetText(text or '')
    end



    deadFrame:SetScript('OnEvent', function(self, event)
        if event=='CHALLENGE_MODE_START' then
            self.deadBool=nil
            local name= self:GetName()
            if name then
                WoWTools_UnitMixin:Save().PartyDeadData[name]= nil
            end

        else
            if UnitIsDeadOrGhost(self.unit) then
                if not self.deadBool then
                    self.deadBool=true

                    local name= self:GetName()
                    if name then
                        WoWTools_UnitMixin:Save().PartyDeadData[name]= (WoWTools_UnitMixin:Save().PartyDeadData[name] or 0)+1
                    end
                    self:settings()
                end
            else
                self.deadBool= nil
            end
        end
    end)

    deadFrame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
    end)

    function deadFrame:Init()
        local unit= self:GetParent().unit
        self.unit= unit
        self:RegisterEvent('CHALLENGE_MODE_START')
        self:RegisterUnitEvent('UNIT_FLAGS', unit)
        self:RegisterUnitEvent('UNIT_HEALTH', unit)
        self:RegisterUnitEvent('INCOMING_RESURRECT_CHANGED', unit)
        local color= WoWTools_UnitMixin:GetColor(unit)
        self.Text:SetTextColor(color:GetRGB())
        self:settings()
    end

    deadFrame:SetScript('OnShow', deadFrame.Init)

end


local function Init()--PartyFrame.lua
    if WoWTools_UnitMixin:Save().hidePartyFrame then
        return
    end

    EventRegistry:RegisterFrameEventAndCallback("GROUP_LEFT", function()
        WoWTools_UnitMixin:Save().PartyDeadData= {}
    end)

    PartyFrame.Background:SetWidth(124)--144

    --local showPartyFrames = PartyFrame:ShouldShow();
    for i=1, MAX_PARTY_MEMBERS+1 do
        local name= 'MemberFrame'..i
        local frame= PartyFrame[name]
        if frame then
            WoWTools_UnitMixin:CreateUnitButton(frame, {
                name= name,
                point=function(btn, f)
                    btn:SetPoint('LEFT', f, 'RIGHT', -3, 4)
                end,
                isTarget=true,
            })

            frame.Name:SetPoint('RIGHT')
            frame.Name:SetFontObject('WoWToolsFont')

            for _, label in pairs({
                frame.ManaBar.TextString,
                frame.ManaBar.RightText,
                frame.ManaBar.LeftText,

                frame.HealthBarContainer.RightText,
                frame.HealthBarContainer.LeftText,
                frame.HealthBarContainer.CenterText,
                frame.Name,
            }) do
                if label then
                    label:SetFontHeight(10)
                end
            end
            --frame.PortraitMask:SetAlpha(0)
            --frame.Texture:SetAlpha(0)
            Create_frame(frame)
            Create_combatFrame(frame, false)

            Create_positionFrame(frame)
            Create_deadFrame(frame)



            WoWTools_DataMixin:Hook(frame, 'UpdateAssignedRoles', function(self)
                self.PartyMemberOverlay.RoleIcon:SetAlpha(UnitGroupRolesAssigned(self.unit)== 'DAMAGER' and 0 or 1)
            end)

            frame.Texture:SetAlpha(0.5)
            WoWTools_DataMixin:Hook(frame, 'UpdateMember', function(self)

                frame.deadFrame:UnregisterAllEvents()
                frame.deadFrame:Init()
                frame.combatFrame:Init()
            end)
        end




        frame= _G['CompactPartyFrameMember'..i]
        if frame then
            Create_combatFrame(frame)
            Create_deadFrame(frame)
        end
    end

    --hooksecurefunc(CompactPartyFrame, 'RefreshMembers', function()

    WoWTools_DataMixin:Hook(CompactPartyFrame,'UpdateVisibility', function(self)
        if not self:IsShown() then
            return
        end

        for i=1, MAX_PARTY_MEMBERS+1 do
            local frame= _G['CompactPartyFrameMember'..i]
            if frame and frame.deadFrame then
                frame.deadFrame:UnregisterAllEvents()
                frame.deadFrame:Init()
                frame.combatFrame:Init()
            end
        end
    end)

    Init=function()end
end


function WoWTools_UnitMixin:Init_PartyFrame()
    Init()
end