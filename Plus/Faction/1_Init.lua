
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

--Centro de control: opciones del módulo (las mismas que los menús)
local StrataValues= {}
for _, strata in ipairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
	table.insert(StrataValues, {value=strata, text=strata})
end

local function Refresh_Track(M)
	M:Refresh_TrackButton()
end

local function Refresh_Renown(M)
	M:Refresh_RenownFrame()
end

local function TrackHidden(save)
	return not save.btn
end

local function Get_Options()
	return {
		{type='section', text='GENERAL'},
		{type='check', key='plus', text='Improve Reputation window', tooltip='Tip.Faction.UIPlus', reload=true,
			get= function(save) return not save.notPlus end,
			set= function(save, value) save.notPlus= not value and true or nil end,
			apply= function(M)
				if M.started and ReputationFrame then
					M:Init_Plus()
				end
			end},
		{type='check', key='chat', text='COMBAT_TEXT_SHOW_REPUTATION_TEXT', tooltip='Tip.Faction.ChatGain',
			get= function(save) return save.factionUpdateTips end,
			set= function(save, value) save.factionUpdateTips= value and true or false end,
			apply= function(M, save)
				if M.started and save.factionUpdateTips then
					M:Check_Chat_MSG()
				end
			end},

		{type='section', text='TRACKING'},
		{type='check', key='track', text='Show tracking button', tooltip='Tip.Faction.Track',
			get= function(save) return save.btn end,
			set= function(save, value) save.btn= value and true or nil end,
			apply= function(M)
				if M.started then
					M:UpdatList()
					M:Init_TrackButton()
				end
			end},
		{type='check', key='btnstr', text='Show list', tooltip='Tip.Faction.TrackShowList', indent=true,
			disabled= TrackHidden,
			get= function(save) return save.btnstr end,
			set= function(save, value) save.btnstr= value and true or false end,
			apply= Refresh_Track},
		{type='check', key='autoHide', text='SELF_CAST_AUTO+HIDE', tooltip='Tip.Faction.TrackAutoHide', indent=true,
			disabled= TrackHidden,
			get= function(save) return not save.notAutoHideTrack end,
			set= function(save, value) save.notAutoHideTrack= not value and true or nil end,
			apply= Refresh_Track},
		{type='check', key='onlyMajor', text='Renown only', tooltip='Tip.Faction.TrackRenownOnly', indent=true,
			disabled= TrackHidden,
			get= function(save) return save.onlyMajor end,
			set= function(save, value) save.onlyMajor= value and true or nil end,
			apply= Refresh_Track},
		{type='check', key='indicato', text='COMBAT_ALLY_START_MISSION', tooltip='Tip.Faction.TrackSelected', indent=true,
			disabled= TrackHidden,
			get= function(save) return save.indicato end,
			set= function(save, value) save.indicato= value and true or nil end,
			apply= function(M)
				M:UpdatList()
				M:Refresh_TrackButton()
			end},
		{type='button', key='clearFactions', text='Clear tracked factions', buttonText='CLEAR_ALL', tooltip='Tip.Menu.ClearAll', indent=true, confirm=true,
			disabled= function(save) return not next(save.factions or {}) end,
			func= function(M, save)
				save.factions= {}
				M:UpdatList()
				M:Refresh_TrackButton()
			end},

		{type='section', text='Appearance'},
		{type='check', key='showName', text='PROFESSIONS_FLYOUT_SHOW_NAME', tooltip='Tip.Faction.TrackShowName',
			disabled= TrackHidden,
			get= function(save) return not save.onlyIcon end,
			set= function(save, value) save.onlyIcon= not value and true or nil end,
			apply= Refresh_Track},
		{type='check', key='toRight', text='Text on the right', tooltip='Tip.Faction.TrackTextRight',
			disabled= TrackHidden,
			get= function(save) return save.toRightTrackText end,
			set= function(save, value) save.toRightTrackText= value and true or false end,
			apply= Refresh_Track},
		{type='check', key='toTop', text='Grow upwards', tooltip='Tip.Faction.TrackGrowUp',
			disabled= TrackHidden,
			get= function(save) return save.toTopTrack end,
			set= function(save, value) save.toTopTrack= value and true or nil end,
			apply= Refresh_Track},
		{type='slider', key='scale', text='SCALE', tooltip='Tip.Menu.Scale', min=0.4, max=4, step=0.1, format='%.1f',
			disabled= TrackHidden,
			get= function(save) return save.scaleTrackButton or 1 end,
			set= function(save, value) save.scaleTrackButton= value end,
			apply= Refresh_Track},
		{type='slider', key='bgAlpha', text='BACKGROUND+HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', tooltip='Tip.Menu.BgAlpha',
			min=0, max=1, step=0.1, format='%.1f',
			disabled= TrackHidden,
			get= function(save) return save.trackBgAlpha or 0.5 end,
			set= function(save, value) save.trackBgAlpha= value end,
			apply= Refresh_Track},
		{type='dropdown', key='strata', text='Strata', tooltip='Tip.Menu.Strata', values= StrataValues,
			disabled= TrackHidden,
			get= function(save) return save.strata or 'MEDIUM' end,
			set= function(save, value) save.strata= value end,
			apply= Refresh_Track},
		{type='button', key='resetPoint', text='RESET_POSITION', buttonText='RESET',
			disabled= function(save) return not save.point end,
			func= function(M, save)
				save.point= nil
				M:Refresh_TrackButton()
				M:Print(WoWTools_L.RESET_POSITION)
			end},

		{type='section', text='Renown window'},
		{type='check', key='renownList', text='Show faction list', tooltip='Tip.Faction.RenownList',
			get= function(save) return not save.hide_MajorFactionRenownFrame_Button end,
			set= function(save, value) save.hide_MajorFactionRenownFrame_Button= not value and true or nil end,
			apply= Refresh_Renown},
		{type='check', key='renownUnlocked', text='Unlocked only', tooltip='Tip.Faction.RenownUnlockedOnly', indent=true,
			disabled= function(save) return save.hide_MajorFactionRenownFrame_Button end,
			get= function(save) return save.onlyUnlockRenownFrame end,
			set= function(save, value) save.onlyUnlockRenownFrame= value and true or nil end,
			apply= Refresh_Renown},
		{type='slider', key='renownScale', text='SCALE', tooltip='Tip.Menu.Scale', min=0.4, max=4, step=0.1, format='%.1f', indent=true,
			disabled= function(save) return save.hide_MajorFactionRenownFrame_Button end,
			get= function(save) return save.MajorFactionRenownFrame_Button_Scale or 1 end,
			set= function(save, value) save.MajorFactionRenownFrame_Button_Scale= value~=1 and value or nil end,
			apply= Refresh_Renown},
		{type='note', text='Tip.Faction.RenownHideNote'},
	}
end


--Módulo registrado con la API común (docs/REFACTOR.md, R1)
WoWTools_Module:Register({
	key= 'Plus_Faction',
	name= 'Module.Reputation',
	icon= WoWTools_DataMixin.Icon[WoWTools_DataMixin.Player.Faction] or 'ParagonReputation_Glow',
	group= 'Character',
	defaults= P_Save,
	tooltip= 'Tip.Faction.Enable',
	mixin= WoWTools_FactionMixin,
	options= function()
		return Get_Options()
	end,
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
