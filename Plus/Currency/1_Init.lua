


local function Save()
	return WoWToolsPlusSave['Currency2']
end


local function Init_Menu(self, root)
	if not self:IsMouseOver() then
		return
	end

	local sub


	sub=root:CreateCheckbox(
		WoWTools_L.TRACKING,
	function()
		return not Save().Hide
	end, function()
		Save().Hide= not Save().Hide and true or nil
		WoWTools_CurrencyMixin:Init_TrackButton()
	end)
	WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Currency.Track'])



	WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
		Save().point=nil
		WoWTools_CurrencyMixin:Init_TrackButton()
	end)

	root:CreateDivider()
	sub=root:CreateCheckbox(
		'|A:communities-icon-chat:0:0|a'..(WoWTools_L['CAPPED~2']),
	function ()
		return not Save().hideCurrencyMax
	end, function ()
		Save().hideCurrencyMax= not Save().hideCurrencyMax and true or nil
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
		return not Save().notPlus
	end, function()
		Save().notPlus= not Save().notPlus and true or nil
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


local function Init()
	local btn= CreateFrame('DropdownButton', 'WoWToolsPlusCurrencyMenuButton', TokenFrame, 'WoWToolsMenuTemplate')
	btn:SetupMenu(Init_Menu)
	btn.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_L.SLASH_TEXTTOSPEECH_MENU)..WoWTools_DataMixin.Icon.left
	btn:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
	btn:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)
	btn:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT', -2, 0)


	WoWTools_CurrencyMixin:Init_Plus()
	WoWTools_CurrencyMixin:Init_TrackButton()
	WoWTools_CurrencyMixin:Init_Currency_Transfer()



	Init=function()end
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

			WoWToolsPlusSave['Currency2']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Currency2'], {
				tokens={},
				item={},
				Hide=true,
				str=true,
				toRightTrackText=true,
			})

			Save().ItemInteractionID= nil

			WoWTools_CurrencyMixin.addName= '|A:bags-junkcoin:0:0|a'..(WoWTools_L['Module.Currencies'])

			WoWTools_PanelMixin:OnlyCheck({
				name= WoWTools_CurrencyMixin.addName,
				tooltip= WoWTools_L['Tip.Currency.Enable'],
				GetValue= function() return not Save().disabled end,
				SetValue= function()
					Save().disabled= not Save().disabled and true or nil

					WoWTools_Print(
						WoWTools_CurrencyMixin.addName..WoWTools_DataMixin.Icon.icon2,
						WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
						WoWTools_L.REQUIRES_RELOAD
					)
				end
			})

			--WoWTools_CurrencyMixin:Init_ItemInteractionFrame()


			if Save().disabled then
				self:UnregisterAllEvents()
				self:SetScript('OnEvent', nil)

			else

				WoWTools_CurrencyMixin:Init_MaxTooltip()

				if C_AddOns.IsAddOnLoaded('Blizzard_TokenUI') then
					Init()
					self:UnregisterAllEvents()
					self:SetScript('OnEvent', nil)
				end
			end

		elseif arg1=='Blizzard_TokenUI' and Save() then
			Init()
			self:UnregisterAllEvents()
			self:SetScript('OnEvent', nil)
		end
    end
end)