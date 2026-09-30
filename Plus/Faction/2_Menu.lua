
local function Save()
    return WoWToolsPlusSave['Plus_Faction']
end











local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

	local sub, sub2, num
	sub=root:CreateCheckbox(
		WoWTools_L.TRACKING,
	function()
		return Save().btn
	end, function()
		Save().btn= not Save().btn and true or nil
		WoWTools_FactionMixin:UpdatList()
		WoWTools_FactionMixin:Init_TrackButton()
		WoWTools_Print(
			WoWTools_FactionMixin.addName..WoWTools_DataMixin.Icon.icon2,
			WoWTools_L.TRACKING,
			WoWTools_TextMixin:GetShowHide(Save().btn)
		)
	end)
	WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Faction.Track'])

	sub2=sub:CreateCheckbox(
		WoWTools_L['SELF_CAST_AUTO+HIDE'],
	function()
		return not Save().notAutoHideTrack
	end, function()
		Save().notAutoHideTrack= not Save().notAutoHideTrack and true or nil
		WoWTools_FactionMixin:Init_TrackButton()
	end)
	sub2:SetTooltip(function(tooltip)
		WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Faction.TrackAutoHide'])
		tooltip:AddLine(WoWTools_L.HIDE)
		tooltip:AddLine(' ')
		tooltip:AddLine(WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
		tooltip:AddLine(WoWTools_L.SHOW_PET_BATTLES_ON_MAP_TEXT)
		tooltip:AddLine(WoWTools_L.AGGRO_WARNING_IN_INSTANCE)
	end)

	sub:CreateDivider()
	WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
		Save().point=nil
		WoWTools_FactionMixin:Init_TrackButton()
		WoWTools_Print(
			WoWTools_FactionMixin.addName..WoWTools_DataMixin.Icon.icon2,
			WoWTools_L.RESET_POSITION
		)
	end)

	local new={}
	for factionID in pairs(Save().factions) do
		table.insert(new, factionID)
	end
	num= #new
	table.sort(new, function(a,b) return a> b end)

	sub=root:CreateCheckbox(
		(Save().btn and '' or '|cff626262')
		..(WoWTools_L.COMBAT_ALLY_START_MISSION),
	function()
		return Save().indicato
	end, function()
		Save().indicato= not Save().indicato and true or nil
		WoWTools_FactionMixin:UpdatList()
	end, {rightText=num})
	WoWTools_MenuMixin:SetRightText(sub)
	WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Faction.TrackSelected'])

	for _, factionID in pairs(new) do
		sub2=sub:CreateCheckbox(
			WoWTools_FactionMixin:GetName(factionID),
		function(data)
			return Save().factions[data.factionID]
		end, function(data)
			Save().factions[data.factionID]= not Save().factions[data.factionID] and true or nil
			WoWTools_FactionMixin:UpdatList()
		end, {factionID=factionID})
		WoWTools_SetTooltipMixin:FactionMenu(sub2)
	end
	WoWTools_MenuMixin:SetScrollMode(sub)

	sub:CreateDivider()
	WoWTools_MenuMixin:ClearAll(sub, function()
		Save().factions={}
		WoWTools_FactionMixin:UpdatList()
	end)


	root:CreateDivider()
	sub=root:CreateCheckbox(
		'|A:voicechat-icon-textchat-silenced:0:0|a'
		..(WoWTools_L.COMBAT_TEXT_SHOW_REPUTATION_TEXT),
	function()
		return Save().factionUpdateTips
	end, function()
		Save().factionUpdateTips= not Save().factionUpdateTips and true or false
		if Save().factionUpdateTips then
			WoWTools_FactionMixin:Check_Chat_MSG()
			WoWTools_Print(
				FACTION_STANDING_INCREASED
			)
			WoWTools_Print(
				FACTION_STANDING_INCREASED_ACCOUNT_WIDE
			)
		end
	end)
	sub:SetTooltip(function(tooltip)
		WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Faction.ChatGain'])
		tooltip:AddLine('|cnGREEN_FONT_COLOR:'..(WoWTools_L.NEED))
		tooltip:AddLine(
			WoWTools_L['HUD_EDIT_MODE_EXPAND_OPTIONS+REPUTATION']
		)
	end)

--Plus
	sub=root:CreateCheckbox(
		'UI Plus',
	function()
	return not Save().notPlus
	end, function()
		Save().notPlus= not Save().notPlus and true or nil
		WoWTools_FactionMixin:Init_Plus()
	end)
	sub:SetTooltip(function (tooltip)
		WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Faction.UIPlus'])
		tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
	end)


	root:CreateDivider()
	sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_FactionMixin.addName})

    WoWTools_MenuMixin:Reload(sub)
end



















local function Init()
    local btn= WoWTools_ButtonMixin:Menu(ReputationFrame, {
		name='WoWToolsFactionMenuButton'
	})


    btn:SetupMenu(Init_Menu)

	btn:SetPoint("RIGHT", CharacterFrameCloseButton, 'LEFT', -2, 0)
    btn:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
    btn:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+2)

	btn:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FactionMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_L.SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
	end)

	btn:SetScript('OnLeave', function()
		GameTooltip:Hide()
	end)
end











function WoWTools_FactionMixin:Init_Button()
    Init()
end
