
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

--Módulo registrado con la API común (docs/REFACTOR.md, R1)
WoWTools_Module:Register({
	key= 'Plus_Faction',
	name= 'Module.Reputation',
	icon= WoWTools_DataMixin.Icon[WoWTools_DataMixin.Player.Faction] or 'ParagonReputation_Glow',
	group= 'Character',
	defaults= P_Save,
	tooltip= 'Tip.Faction.Enable',
	mixin= WoWTools_FactionMixin,
	blizzard= {
		Blizzard_MajorFactions= function()
			WoWTools_FactionMixin:Init_MajorFactionRenownFrame()
		end,
		Blizzard_CovenantRenown= function()
			WoWTools_FactionMixin:Init_CovenantRenown(CovenantRenownFrame)
		end,
	},
	events= {PLAYER_ENTERING_WORLD= function()
		WoWTools_FactionMixin:Init_Button()
		WoWTools_FactionMixin:Init_Plus()
		WoWTools_FactionMixin:Init_Chat_MSG()
		WoWTools_FactionMixin:Init_TrackButton()
		return true
	end},
})
