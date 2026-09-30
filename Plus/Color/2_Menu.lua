
local function Save()
	return WoWToolsPlusSave['Plus_Color'] or {}
end




local function Init_Menu(self, root)
	if not self:IsMouseOver() then
        return
    end
	
	local sub
	sub=root:CreateCheckbox(
		WoWTools_L.SHOW,
	function()
		return self.frame:IsShown()
	end, function()
		Save().hide= not Save().hide and true or nil
		self:Settings()
	end)
	WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Color.Show'])

	root:CreateDivider()
	WoWTools_MenuMixin:Scale(self, root, function()
		return Save().scale or 1
	end, function(value)
		Save().scale= value
		self:Settings()
	end)

	sub=root:CreateButton(
		'|A:bags-button-autosort-up:0:0|a'
		..(WoWTools_L['SLASH_STOPWATCH_PARAM_STOP2+EVENTTRACE_LOG_HEADER']),
	function()
		Save().logColor={}
		WoWTools_ColorMixin:Set_SaveLogList()
		return MenuResponse.Close
	end, {rightText= #Save().logColor})
	sub:SetTooltip(function(tooltip)
		WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Color.ClearLog'])
		tooltip:AddLine(
			format((WoWTools_L['Save up to %d colors']), Save().logMaxColor or 10)
		)
	end)
	WoWTools_MenuMixin:SetRightText(sub)

	sub:CreateSpacer()
	WoWTools_MenuMixin:CreateSlider(sub, {
		getValue=function()
			return Save().logMaxColor or 10
		end, setValue=function(value)
			Save().logMaxColor=value
			WoWTools_ColorMixin:Set_SaveLogList()
		end,
		name=WoWTools_L.AUCTION_HOUSE_QUANTITY_LABEL,
		minValue=0,
		maxValue=200,
		step=1,
		--bit='%.2f',
		tooltip=function(tooltip)
			tooltip:AddLine(WoWTools_L.SAVE)
		end
	})
	sub:CreateSpacer()

	sub=root:CreateCheckbox(
		WoWTools_L['More colors'],
	function()
		return Save().selectType2
	end, function()
		Save().selectType2 = not Save().selectType2 and true or nil
	end)
	sub:SetTooltip(function(tooltip)
		WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Color.MoreColors'])
		tooltip:AddLine( WoWTools_L.REQUIRES_RELOAD)
	end)

	WoWTools_MenuMixin:Reload(sub)


	sub=root:CreateCheckbox(
		'|A:newplayertutorial-drag-cursor:0:0|a'
		..(WoWTools_L['SELF_CAST_AUTO+HIDE']),
	function()
		return not Save().notHideFuori
	end, function()
		Save().notHideFuori= not Save().notHideFuori and true or nil
		self:Settings()
	end)
	sub:SetTooltip(function(tooltip)
		WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Color.AutoHide'])
		tooltip:AddLine(WoWTools_L['Click outside the color picker: auto-hide'])
	end)


	root:CreateDivider()
	sub=root:CreateCheckbox(
		WoWTools_L['SELF_CAST_AUTO+SHOW'],
	function()
		return Save().autoShow
	end, function()
		Save().autoShow= not Save().autoShow and true or nil
	end)
	sub:SetTooltip(function(tooltip)
		WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Color.AutoShow'])
		tooltip:AddLine(WoWTools_L.SHOW)
		tooltip:AddLine(WoWTools_L['LOG_IN+GAME'])
	end)


	root:CreateDivider()
	WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_ColorMixin.addName})
end












local function Init()
	local btn=WoWTools_ButtonMixin:Menu(ColorPickerFrame, {
		name='WoWToolsColorPickerFrameButton',
		icon='hide',
	})
	btn:SetPoint("TOPLEFT", ColorPickerFrame.Border, 7, -7)

	function btn:set_alpha()
		self:GetNormalTexture():SetAlpha(self:IsMouseOver() and 1 or 0.3)
	end

	function btn:set_tooltip()
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_ColorMixin.addName)
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(
			WoWTools_TextMixin:GetShowHide(self.frame:IsShown()),
			(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL)..WoWTools_DataMixin.Icon.left
		)
        GameTooltip:Show()
	end

	btn:SetScript('OnLeave', function(self)
		GameTooltip:Hide()
		self:set_alpha()
	end)
	btn:SetScript('OnEnter', function(self)
		self:set_tooltip()
		self:set_alpha()
	end)

	btn.frame=CreateFrame("Frame", nil, btn)
	btn.frame:SetPoint('BOTTOMRIGHT')
	btn.frame:SetSize(1,1)

	btn.autoHideTexture= btn:CreateTexture(nil, 'BORDER')
	btn.autoHideTexture:SetSize(23,23)
	btn.autoHideTexture:SetPoint('LEFT', ColorPickerFrame.Footer.CancelButton, 'RIGHT', 0, -1)
	btn.autoHideTexture:SetAtlas('newplayertutorial-drag-cursor')
	btn.autoHideTexture:EnableMouse(true)
	btn.autoHideTexture:SetScript('OnLeave', function(self) self:SetAlpha(1) GameTooltip:Hide() end)	
	btn.autoHideTexture:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
		GameTooltip_SetTitle(GameTooltip,
			WoWTools_DataMixin.Icon.icon2
			..(WoWTools_L['SELF_CAST_AUTO+HIDE'])
		)
		GameTooltip:AddLine(WoWTools_L['Click outside the color picker: auto-hide'])
		GameTooltip:Show()
		self:SetAlpha(0.3)
	end)
	btn.autoHideTexture:SetScript('OnMouseDown', function(self)
		local p= self:GetParent()
		p:SetMenuOpen(not p:IsMenuOpen())
	end)

	function btn:Settings()
		local hide= Save().hide
		if hide then
			self:SetNormalTexture('Interface\\AddOns\\WoWToolsPlus\\Source\\Texture\\WoWtools')
		else
			self:SetNormalAtlas('ui-questtrackerbutton-filter')
		end
		self.frame:SetShown(not hide)
		self.frame:SetScale(Save().scale or 1)
		ColorPickerFrame.Content.ColorPicker:SetColorRGB(ColorPickerFrame:GetColorRGB())
		self.autoHideTexture:SetShown(not Save().notHideFuori)
	end

	btn:SetupMenu(Init_Menu)
	btn:Settings()
	btn:set_alpha()
end








function WoWTools_ColorMixin:Init_Menu()
	Init()
end