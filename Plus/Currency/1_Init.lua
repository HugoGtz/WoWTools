


local function Init_Menu(self, root)
	if not self:IsMouseOver() then
		return
	end

	local sub


	sub=root:CreateCheckbox(
		WoWTools_L.TRACKING,
	function()
		return not WoWTools_CurrencyMixin:Save().Hide
	end, function()
		WoWTools_CurrencyMixin:Save().Hide= not WoWTools_CurrencyMixin:Save().Hide and true or nil
		WoWTools_CurrencyMixin:Init_TrackButton()
	end)
	WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Currency.Track'])



	WoWTools_MenuMixin:RestPoint(self, sub, WoWTools_CurrencyMixin:Save().point, function()
		WoWTools_CurrencyMixin:Save().point=nil
		WoWTools_CurrencyMixin:Init_TrackButton()
	end)

	root:CreateDivider()
	sub=root:CreateCheckbox(
		'|A:communities-icon-chat:0:0|a'..(WoWTools_L['CAPPED~2']),
	function ()
		return not WoWTools_CurrencyMixin:Save().hideCurrencyMax
	end, function ()
		WoWTools_CurrencyMixin:Save().hideCurrencyMax= not WoWTools_CurrencyMixin:Save().hideCurrencyMax and true or nil
		WoWTools_CurrencyMixin:Init_MaxTooltip()
	end)
	sub:SetTooltip(function (tooltip)
		WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Currency.CapWarning'])
		tooltip:AddLine('CURRENCY_DISPLAY_UPDATE')
		tooltip:AddLine(WoWTools_L.SPELL_FAILED_CUSTOM_ERROR_248)
	end)

	--format(LFG_LIST_CROSS_FACTION, WoWTools_Join(REFORGE_CURRENT, GAME_VERSION_LABEL)),


--Plus
	sub=root:CreateCheckbox(
		'Plus',
	function()
		return not WoWTools_CurrencyMixin:Save().notPlus
	end, function()
		WoWTools_CurrencyMixin:Save().notPlus= not WoWTools_CurrencyMixin:Save().notPlus and true or nil
		WoWTools_CurrencyMixin:Init_Plus()
	end)
	sub:SetTooltip(function (tooltip)
		WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Currency.Plus'])
		GameTooltip_AddInstructionLine(tooltip, WoWTools_L.REQUIRES_RELOAD)
	end)


	root:CreateDivider()
    sub= WoWTools_MenuMixin:OpenOptions(root, {name= WoWTools_CurrencyMixin.addName})
	WoWTools_MenuMixin:Reload(sub)
end


local Init= WoWTools_Once(function()
	local btn= CreateFrame('DropdownButton', 'WoWToolsPlusCurrencyMenuButton', TokenFrame, 'WoWToolsMenuTemplate')
	btn:SetupMenu(Init_Menu)
	btn.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_L.SLASH_TEXTTOSPEECH_MENU)..WoWTools_DataMixin.Icon.left
	btn:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
	btn:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)
	btn:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT', -2, 0)


	WoWTools_CurrencyMixin:Init_Plus()
	WoWTools_CurrencyMixin:Init_TrackButton()
	WoWTools_CurrencyMixin:Init_Currency_Transfer()



end)


--Centro de control: opciones del módulo (las mismas que los menús)
local StrataValues= {}
for _, strata in ipairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
	table.insert(StrataValues, {value=strata, text=strata})
end

local function Refresh(what)
	return function(M)
		M:Refresh_TrackButton(what)
	end
end

local function TrackHidden(save)
	return save.Hide
end

local function Get_Options()
	return {
		{type='section', text='GENERAL'},
		{type='check', key='plus', text='Improve Currency window', tooltip='Tip.Currency.Plus', reload=true,
			get= function(save) return not save.notPlus end,
			set= function(save, value) save.notPlus= not value and true or nil end,
			apply= function(M)
				if M.started and TokenFrame then
					M:Init_Plus()
				end
			end},

		{type='section', text='Automations'},
		{type='check', key='capWarning', text='CAPPED~2', tooltip='Tip.Currency.CapWarning', automation=true,
			get= function(save) return not save.hideCurrencyMax end,
			set= function(save, value) save.hideCurrencyMax= not value and true or nil end,
			apply= function(M)
				if M.started then
					M:Init_MaxTooltip()
				end
			end},

		{type='section', text='TRACKING'},
		{type='check', key='track', text='Show tracking button', tooltip='Tip.Currency.Track', noCombat=true,
			get= function(save) return not save.Hide end,
			set= function(save, value) save.Hide= not value and true or nil end,
			apply= Refresh('init')},
		{type='check', key='str', text='Show list', tooltip='Tip.Currency.ShowList', indent=true, noCombat=true,
			disabled= TrackHidden,
			get= function(save) return save.str end,
			set= function(save, value) save.str= value and true or false end,
			apply= Refresh('shown')},
		{type='check', key='autoHide', text='SELF_CAST_AUTO+HIDE', tooltip='Tip.Currency.AutoHide', indent=true, noCombat=true,
			disabled= TrackHidden,
			get= function(save) return not save.notAutoHideTrack end,
			set= function(save, value) save.notAutoHideTrack= not value and true or nil end,
			apply= Refresh()},
		{type='check', key='indicato', text='COMBAT_ALLY_START_MISSION+TOKENS', tooltip='Tip.Currency.OnlySelected', indent=true, noCombat=true,
			disabled= TrackHidden,
			get= function(save) return save.indicato end,
			set= function(save, value) save.indicato= value and true or nil end,
			apply= Refresh('tokens')},
		{type='button', key='addToken', text='Track a currency by ID', buttonText='ADD', tooltip='Tip.Currency.AddByID', indent=true,
			func= function(M, save)
				StaticPopup_Show('WoWTools_Currency', nil, nil, {
					GetValue= function() end,
					CheckValue= function(button1, currencyID)
						button1:SetText(save.tokens[currencyID] and WoWTools_L.UPDATE or WoWTools_L.ADD)
					end,
					SetValue= function(currencyID)
						save.tokens[currencyID]= true
						M:Refresh_TrackButton()
					end,
				})
			end},
		{type='button', key='clearTokens', text='Clear tracked currencies', buttonText='CLEAR_ALL', tooltip='Tip.Menu.ClearAll', indent=true, confirm=true,
			disabled= function(save) return not next(save.tokens or {}) end,
			func= function(M, save)
				save.tokens= {}
				M:Refresh_TrackButton('tokens')
			end},
		{type='check', key='items', text='ITEMS', tooltip='Tip.Currency.TrackItems', indent=true, noCombat=true,
			disabled= TrackHidden,
			get= function(save) return not save.disabledItemTrack end,
			set= function(save, value) save.disabledItemTrack= not value and true or nil end,
			apply= Refresh()},
		{type='check', key='itemButtonUse', text='USE_ITEM', tooltip='Tip.Currency.UseItem', indent=true, reload=true,
			disabled= function(save) return save.Hide or save.disabledItemTrack end,
			get= function(save) return save.itemButtonUse end,
			set= function(save, value) save.itemButtonUse= value and true or nil end},
		{type='button', key='clearItems', text='Clear tracked items', buttonText='CLEAR_ALL', tooltip='Tip.Menu.ClearAll', indent=true, confirm=true,
			disabled= function(save) return not next(save.item or {}) end,
			func= function(M, save)
				save.item= {}
				M:Refresh_TrackButton()
			end},

		{type='section', text='Appearance'},
		{type='check', key='nameShow', text='PROFESSIONS_FLYOUT_SHOW_NAME', tooltip='Tip.Currency.ShowName', noCombat=true,
			disabled= TrackHidden,
			get= function(save) return save.nameShow end,
			set= function(save, value) save.nameShow= value and true or nil end,
			apply= Refresh()},
		{type='check', key='toRight', text='Text on the right', tooltip='Tip.Currency.TextRight', noCombat=true,
			disabled= TrackHidden,
			get= function(save) return save.toRightTrackText end,
			set= function(save, value) save.toRightTrackText= value and true or false end,
			apply= Refresh()},
		{type='check', key='toTop', text='Grow upwards', tooltip='Tip.Currency.GrowUp', noCombat=true,
			disabled= TrackHidden,
			get= function(save) return save.toTopTrack end,
			set= function(save, value) save.toTopTrack= value and true or nil end,
			apply= Refresh()},
		{type='slider', key='scale', text='SCALE', tooltip='Tip.Menu.Scale', min=0.4, max=4, step=0.1, format='%.1f', noCombat=true,
			disabled= TrackHidden,
			get= function(save) return save.scaleTrackButton or 1 end,
			set= function(save, value) save.scaleTrackButton= value end,
			apply= Refresh()},
		{type='slider', key='bgAlpha', text='BACKGROUND+HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', tooltip='Tip.Menu.BgAlpha',
			min=0, max=1, step=0.1, format='%.1f', noCombat=true,
			disabled= TrackHidden,
			get= function(save) return save.trackBgAlpha or 0.5 end,
			set= function(save, value) save.trackBgAlpha= value end,
			apply= Refresh()},
		{type='dropdown', key='strata', text='Strata', tooltip='Tip.Menu.Strata', values= StrataValues, noCombat=true,
			disabled= TrackHidden,
			get= function(save) return save.strata or 'MEDIUM' end,
			set= function(save, value) save.strata= value end,
			apply= Refresh()},
		{type='button', key='resetPoint', text='RESET_POSITION', buttonText='RESET', noCombat=true,
			disabled= function(save) return not save.point end,
			func= function(M, save)
				save.point= nil
				M:Refresh_TrackButton()
			end},
	}
end


--Módulo registrado con la API común (docs/REFACTOR.md, R1)
WoWTools_Module:Register({
	key= 'Currency2',
	name= 'Module.Currencies',
	icon= 'bags-junkcoin',
	group= 'Items',
	defaults= {
		tokens={},
		item={},
		Hide=true,
		str=true,
		toRightTrackText=true,
	},
	tooltip= 'Tip.Currency.Enable',
	mixin= WoWTools_CurrencyMixin,
	options= function()
		return Get_Options()
	end,
	onEnable= function(_, save)
		save.ItemInteractionID= nil
		--WoWTools_CurrencyMixin:Init_ItemInteractionFrame()
		WoWTools_CurrencyMixin:Init_MaxTooltip()
	end,
	blizzard= {Blizzard_TokenUI= function()
		Init()
	end},
})
