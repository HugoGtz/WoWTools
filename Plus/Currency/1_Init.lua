


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
	onEnable= function(_, save)
		save.ItemInteractionID= nil
		--WoWTools_CurrencyMixin:Init_ItemInteractionFrame()
		WoWTools_CurrencyMixin:Init_MaxTooltip()
	end,
	blizzard= {Blizzard_TokenUI= function()
		Init()
	end},
})
