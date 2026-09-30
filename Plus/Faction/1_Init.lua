
local P_Save={
	factions={},
	btnstr=true,
	scaleTrackButton=1,
	toRightTrackText=true,

	factionUpdateTips=true,
	--notPlus=true,

	hideRenownFrame={},
	--MajorFactionRenownFrame_Button_Scale
}

local function Save()
	return WoWToolsPlusSave['Plus_Faction']
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
		if arg1== 'WoWToolsPlus' then

			WoWToolsPlusSave['Plus_Faction']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Faction'], P_Save)
			Save().hideRenownFrame= Save().hideRenownFrame or {}
			P_Save=nil


			WoWTools_FactionMixin.addName= format('|A:%s:0:0|a%s', WoWTools_DataMixin.Icon[WoWTools_DataMixin.Player.Faction] or 'ParagonReputation_Glow', WoWTools_L['Module.Reputation'])

			WoWTools_PanelMixin:OnlyCheck({
				name= WoWTools_FactionMixin.addName,
				tooltip= WoWTools_L['Tip.Faction.Enable']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
				GetValue= function() return not Save().disabled end,
				SetValue= function()
					Save().disabled= not Save().disabled and true or nil
					WoWTools_Print(
						WoWTools_FactionMixin.addName..WoWTools_DataMixin.Icon.icon2,
						WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
						WoWTools_L.REQUIRES_RELOAD
					)
				end
			})

			if not Save().disabled then
				self:RegisterEvent('PLAYER_ENTERING_WORLD')

				if C_AddOns.IsAddOnLoaded('Blizzard_MajorFactions') then
					WoWTools_FactionMixin:Init_MajorFactionRenownFrame()
				end
				if C_AddOns.IsAddOnLoaded('Blizzard_CovenantRenown') then
					WoWTools_FactionMixin:Init_CovenantRenown(CovenantRenownFrame)
				end
			else
				self:SetScript('OnEvent', nil)
			end

		elseif arg1=='Blizzard_MajorFactions' and WoWToolsPlusSave then
			WoWTools_FactionMixin:Init_MajorFactionRenownFrame()
			if C_AddOns.IsAddOnLoaded('Blizzard_CovenantRenown') then
				self:UnregisterEvent(event)
			end

		elseif arg1=='Blizzard_CovenantRenown' and WoWToolsPlusSave then
			WoWTools_FactionMixin:Init_CovenantRenown(CovenantRenownFrame)
			if C_AddOns.IsAddOnLoaded('Blizzard_MajorFactions') then
				self:UnregisterEvent(event)
			end
		end

    elseif event == 'PLAYER_ENTERING_WORLD' then
		WoWTools_FactionMixin:Init_Button()
		WoWTools_FactionMixin:Init_Plus()
		WoWTools_FactionMixin:Init_Chat_MSG()
		WoWTools_FactionMixin:Init_TrackButton()
		self:UnregisterEvent(event)
    end
end)