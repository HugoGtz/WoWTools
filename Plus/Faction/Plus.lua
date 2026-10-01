local function Create_Frame(btn)
	
	--btn.Content.ReputationBar.BarText:ClearAllPoints()

	btn.Content.AccountWideIcon:SetScale(0.6)
	btn.barText2= btn.Content.ReputationBar:CreateFontString(nil, 'OVERLAY', 'WoWToolsFont2')
	btn.barText2:SetPoint('CENTER')
	btn.barText2:SetJustifyH('CENTER')

	btn:HookScript('OnLeave', function(self)
		self.Content.ReputationBar.BarText:SetAlpha(0)
		self.barText2:SetAlpha(1)
	end)
	btn:HookScript('OnEnter', function(self)
		self.Content.ReputationBar.BarText:SetAlpha(1)
		self.barText2:SetAlpha(0)
	end)


	local h=btn:GetHeight() or 20
	btn.texture= btn.Content.ReputationBar:CreateTexture(nil, 'OVERLAY')
	btn.texture:SetPoint('RIGHT', btn.Content.Name, 'RIGHT',6,0)
	btn.texture:SetSize(h, h)
	btn.levelText= btn.Content.ReputationBar:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')--WoWTools_LabelMixin:Create(btn.Content.ReputationBar, {size=10})
	--btn.levelText:SetFontHeight(10)
	btn.levelText:SetPoint('LEFT')

--check
	btn.check= CreateFrame('CheckButton', nil, btn.Content, "InterfaceOptionsCheckButtonTemplate")
	btn.check:SetPoint('LEFT',-12,0)
	function btn.check:get_info()
		return self:GetParent():GetParent().elementData or {}
	end
	btn.check:SetScript('OnClick', function(self)
		local factionID= self:GetParent():GetParent().elementData.factionID
		WoWTools_FactionMixin:Save().factions[factionID]= not WoWTools_FactionMixin:Save().factions[factionID] and true or nil
		WoWTools_FactionMixin:UpdatList()
	end)
	btn.check:SetScript('OnEnter', function(self)
		local data= self:GetParent():GetParent().elementData

		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FactionMixin.addName)
		GameTooltip:AddDoubleLine(WoWTools_L.TRACKING, WoWTools_L.COMBAT_ALLY_START_MISSION)
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(WoWTools_TextMixin:CN(data.name), data.factionID, 0,1,0,0,1,0)
		GameTooltip:Show()
		self:SetAlpha(1)
	end)
	btn.check:SetScript('OnLeave', function(self)
		GameTooltip:Hide()
		self:SetAlpha(0.4)
	end)
	btn.check:SetSize(18,22)
	btn.check:SetAlpha(0.3)
	btn.check:SetCheckedTexture('orderhalltalents-done-glow')
	WoWTools_TextureMixin:SetCheckBox(btn.check)

	function btn:clear_all()
		self.Content.Name:SetTextColor(1,1,1)
		--self.Content.watchedIcon:SetShown(false)
		self.completed:SetText('')
		self.levelText:SetText('')
		self.texture:SetTexture(0)
		self.check:SetShown(false)
	end
end


local function Init()
	if WoWTools_FactionMixin:Save().notPlus then
		return
	end

	WoWTools_DataMixin:Hook(ReputationEntryMixin, 'OnLoad', function(btn)
		Create_Frame(btn)
	end)



	WoWTools_DataMixin:Hook(ReputationEntryMixin, 'Initialize', function(btn)--factionRow, elementData)--ReputationFrame.lua
		local data= {}
		if not WoWTools_FactionMixin:Save().notPlus then
			data= WoWTools_FactionMixin:GetInfo(btn.factionID)
		end

		btn.Content.ReputationBar.BarText:SetAlpha(0)
		
		if not btn.barText2 then
			Create_Frame(btn)
		end

		local text
		if data.isCapped then
			text= data.valueText
		elseif data.factionStandingtext then
			text= data.factionStandingtext..(data.valueText and ' '..data.valueText or '')
		end

		text= text or (WoWTools_TextMixin:CN(btn.Content.ReputationBar.BarText:GetText()))
		btn.barText2:SetText(text or '')
		--btn.Content.ReputationBar.BarText:SetAlpha(text and 0 or 1)


		if data.color then
			btn.Content.Name:SetTextColor(data.color:GetRGB())
			--btn.Content.ReputationBar.UpdateBarColor= function()end
			btn.Content.ReputationBar:SetStatusBarColor(data.color:GetRGB());
		else
			--btn.UpdateBarColor= 
		end

		if data.atlas then
			btn.texture:SetAtlas(data.atlas)
		else
			btn.texture:SetTexture(data.texture or 0)
		end

		btn.check:SetShown(WoWTools_FactionMixin:Save().btn and WoWTools_FactionMixin:Save().indicato)
		btn.check:SetChecked(WoWTools_FactionMixin:Save().factions[data.factionID])
	end)


	WoWTools_DataMixin:Hook(ReputationEntryMixin, 'RefreshAccountWideIcon', function(self)
		local showAccountWideIcon = C_Reputation.IsAccountWideReputation(self.factionID)
		self.Content.AccountWideIcon:SetShown(showAccountWideIcon)
	end)



	WoWTools_DataMixin:Hook(ReputationSubHeaderMixin, 'RefreshAccountWideIcon', function(self)
		local showAccountWideIcon = C_Reputation.IsAccountWideReputation(self.factionID)
		self.Content.AccountWideIcon:SetShown(showAccountWideIcon)
	end)
	WoWTools_DataMixin:Hook(ReputationSubHeaderMixin, 'OnLoad', function(self)
		self.Content.AccountWideIcon:SetScale(0.6)
	end)


	local down= CreateFrame('Button', 'WoWToolsFactionListExpandButton', _G['WoWToolsFactionMenuButton'], 'WoWToolsButtonTemplate')
	down:SetNormalAtlas('NPE_ArrowDown')
	down.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_L.HUD_EDIT_MODE_EXPAND_OPTIONS)
	down:SetPoint("RIGHT", ReputationFrame.filterDropdown, 'LEFT',-2,0)
	down:SetScript("OnClick", function()
		for index=C_Reputation.GetNumFactions(), 1, -1 do
			local data= C_Reputation.GetFactionDataByIndex(index)
			if data and data.isHeader and data.isCollapsed then
				C_Reputation.ExpandFactionHeader(index)
			end
		end
		for index=C_Reputation.GetNumFactions(), 1, -1 do
			local data= C_Reputation.GetFactionDataByIndex(index)
			if data and data.isHeader and data.isCollapsed then
				C_Reputation.ExpandFactionHeader(index)
			end
		end
	end)


	local up=CreateFrame('Button', 'WoWToolsFactionListCollapsedButton', down, 'WoWToolsButtonTemplate')
	up:SetNormalAtlas('NPE_ArrowUp')
	up.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_L.HUD_EDIT_MODE_COLLAPSE_OPTIONS)
	up:SetPoint("RIGHT", down, 'LEFT', -2, 0)
	up:SetScript("OnClick", function()
		for index=C_Reputation.GetNumFactions(), 1, -1 do
			local data= C_Reputation.GetFactionDataByIndex(index)
			if data and data.isHeader and not data.isCollapsed then
				C_Reputation.CollapseFactionHeader(index)
			end
		end
	end)


	local editBox
	local function Init_Search(self)
		local numList= C_Reputation.GetNumFactions() or 0
		if numList==0 then
			return
		end

		local factionID, name, data
		local factionList={}

		factionID =math.max(editBox:GetNumber() or 0)
		factionID= factionID>0 and factionID or nil

		name= editBox:GetText() or ''
		name= name~='' and name or nil

		if name or factionID then
			for index= 1, numList do
				data= C_Reputation.GetFactionDataByIndex(index)
				if data then
					if factionID and data.factionID==factionID then
						data.factionIndex = index
						tinsert(factionList, data)
						break
					elseif data.name and name then
						local cn= WoWTools_TextMixin:CN(data.name)
						cn= cn~=data.name and cn:upper() or nil

						local p_name= data.name:upper()
						name= name:upper()

						if cn and cn==name or p_name== name then
							data.factionIndex = index
							tinsert(factionList, data)
							break

						elseif cn and cn:find(name) or p_name:find(name) then
							data.factionIndex = index
							tinsert(factionList, data)
						end
					end
				end
			end
		end

		self.ScrollBox:SetDataProvider(CreateDataProvider(factionList), ScrollBoxConstants.RetainScrollPosition);
		self.ReputationDetailFrame:Refresh()
	end

	editBox= WoWTools_EditBoxMixin:Create(up, {
		name='WoWTools_PlusFactionSearchBox',
		Template='SearchBoxTemplate'
	})


	editBox:SetPoint('RIGHT', up, 'LEFT', -6, 0)
	editBox:SetPoint('BOTTOMLEFT', CharacterFramePortrait, 'BOTTOMRIGHT')

	editBox:SetScript('OnTextChanged', function(self)
		local show= self:GetText() ~= ""
		self.Instructions:SetShown(not show)
		local hasfocus= self:HasFocus()
		--self:SetAlpha((show or hasfocus) and 1 or 0.3)

		if hasfocus then
			Init_Search(ReputationFrame)
		end

	end)

	editBox:SetScript('OnEnterPressed', function()
		Init_Search(ReputationFrame)
	end)

	editBox:SetScript('OnEditFocusGained', function(self)
		ReputationFrame.Update= Init_Search
		--self:SetAlpha(1)
		if self:GetText()~='' then
			Init_Search(ReputationFrame)
		end
		self.clearButton:SetShown(true)
	end)

	editBox:SetScript('OnEditFocusLost', function(self)
		if self.clearButton:IsShown() and self:GetText()=='' then
			self.clearButton:Click()
		end
	end)

	editBox.clearButton:SetScript('OnClick', function(self)
		ReputationFrame.Update= ReputationFrameMixin.Update
		ReputationFrame:Update()
		local p= self:GetParent()
		p:SetText('')
		p:ClearFocus()
		--p:SetAlpha(0.3)
		self:Hide()
	end)

	editBox:SetScript('OnEscapePressed', function(self)
		self:ClearFocus()
	end)


	Init=function()
		WoWTools_FactionMixin:UpdatList()
	end
end


function WoWTools_FactionMixin:Init_Plus()
   Init()
end