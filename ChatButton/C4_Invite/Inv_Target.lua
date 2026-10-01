
local frame





local function Init()
    frame= CreateFrame('Frame')

    function frame:set_event()
        self:UnregisterAllEvents()
        if WoWTools_InviteMixin:Save().InvTar and select(2, IsInInstance())=='none' then
            self:RegisterEvent('PLAYER_TARGET_CHANGED')
        end
    end

    function frame:InviteTarget()
        if not WoWTools_InviteMixin:Save().InvTar
        or WoWTools_UnitMixin:UnitIsUnit('player','target')~=false
        or not WoWTools_UnitMixin:UnitGUID('target')
        or not WoWTools_InviteMixin:Get_Leader()
        or UnitInAnyGroup('target')
        or WoWTools_UnitMixin:UnitIsAFK('target')
        or not UnitIsConnected('target')
        or not UnitIsPlayer('target')
        or not UnitIsFriend('target', 'player')
        then
            return
        end

        local raid=IsInRaid()
        local co=GetNumGroupMembers()
        if (raid and co==40) or (not raid and co==5 and not WoWTools_InviteMixin:Save().PartyToRaid) then
            return
        end

        local name=GetUnitName('target', true)
        if not name then
            return
        end


        C_PartyInfo.InviteUnit(name)

        local guid=UnitGUID('target')
        if guid then
            WoWTools_InviteMixin.InvPlateGuid[guid]=name
        end
        WoWTools_Print(
            WoWTools_InviteMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_L.TARGET,
            WoWTools_UnitMixin:GetPlayerInfo(nil, guid, name, {reLink=true}),
            ''
        )
    end

    frame:SetScript('OnEvent', frame.InviteTarget)

    frame:set_event()
end



















function WoWTools_InviteMixin:Init_Target()
    Init()
end

function WoWTools_InviteMixin:Inv_Target_Settings()
    if frame then
        frame:set_event()
        frame:InviteTarget()
    end
end