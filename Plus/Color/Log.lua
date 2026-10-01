
local function Save()
	return WoWToolsPlusSave['Plus_Color'] or {}
end









local Textures={}
local SIZE= WoWTools_Style.Size.icon.small--16

--Historial a la izquierda del selector, en un panel propio con el estilo común.
--Como mucho 10 filas; con más colores el panel se ensancha (mínimo 5 por fila).
local function Set_SaveLogList()
	local logColor= Save().logColor
	local n= math.min(#logColor, Save().logMaxColor or 10)

	local panel= WoWTools_ColorMixin:Get_Panel('log', WoWTools_L['Color.History'])
	if not panel.isSetPoint then
		panel:SetPoint('TOPRIGHT', ColorPickerFrame, 'TOPLEFT', -WoWTools_Style.Size.pad, 0)
		panel.isSetPoint= true
	end

	local perRow= math.max(5, math.ceil(n/10))

	for i=1, n, 1 do
		local icon= Textures[i]
		local col= logColor[i]
		if not Textures[i] then
			icon= WoWTools_ColorMixin:Create_Texture(col.r, col.g, col.b, col.a, nil, panel, SIZE)
			icon.tooltip= (WoWTools_L.EVENTTRACE_LOG_HEADER)..' '..i
			table.insert(Textures, icon)
		end
		WoWTools_ColorMixin:Set_Cell(icon, panel, (i-1)%perRow, math.floor((i-1)/perRow), SIZE)
		icon.r, icon.g, icon.b, icon.a= col.r, col.g, col.b, col.a
		icon:SetColorTexture(col.r, col.g, col.b , 1)
		icon:SetShown(true)
	end

	for i=n+1, #Textures, 1 do
		Textures[i]:SetShown(false)
	end

	WoWTools_ColorMixin:Set_PanelSize(panel, math.min(n, perRow), math.ceil(n/perRow), SIZE)
	panel:SetShown(n>0)
end











local function Init()
	Save().logColor= Save().logColor or {}
	Save().saveColor= Save().saveColor or {}

	ColorPickerFrame.Content.ColorSwatchCurrent:HookScript("OnMouseDown", function(self) self:SetAlpha(0.3) end)
	ColorPickerFrame.Content.ColorSwatchCurrent:HookScript("OnMouseUp", function(self) self:SetAlpha(0.5) end)
	ColorPickerFrame.Content.ColorSwatchCurrent:HookScript('OnLeave', function(self)
		GameTooltip:Hide()
		self:SetAlpha(1)
	end)
	ColorPickerFrame.Content.ColorSwatchCurrent:HookScript('OnEnter', function(self)
		GameTooltip:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
		GameTooltip:AddLine(WoWTools_L['REFORGE_CURRENT+COLOR'])
		GameTooltip:Show()
		self:SetAlpha(0.5)
	end)

	ColorPickerFrame.Content.ColorSwatchOriginal:HookScript("OnMouseDown", function(self) self:SetAlpha(0.3) end)
	ColorPickerFrame.Content.ColorSwatchOriginal:HookScript("OnMouseUp", function(self) self:SetAlpha(0.5) end)
	ColorPickerFrame.Content.ColorSwatchOriginal:HookScript('OnLeave', function(self)
		GameTooltip:Hide()
		self:SetAlpha(1)
	end)
	ColorPickerFrame.Content.ColorSwatchOriginal:HookScript('OnEnter', function(self)
		local r,g,b,a= ColorPickerFrame:GetPreviousValues()
		GameTooltip:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(WoWTools_L.BATTLEGROUND_MATCHMAKING_VALUE, WoWTools_DataMixin.Icon.left)
		if r and g and b then
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(
				format(
					'r='..tonumber(format('%.2f', r))
					..'  g='..tonumber(format('%.2f', g))
					..'  b='..tonumber(format('%.2f', b))
				),
            	a and tonumber(format('%.2f', a)) or 1
			)
		end
		GameTooltip:Show()
		self:SetAlpha(0.5)
	end)
	ColorPickerFrame.Content.ColorSwatchOriginal:HookScript('OnMouseDown', function()
		local r,g,b,a= ColorPickerFrame:GetPreviousValues()
		if r and g and b then
			ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
			if ColorPickerFrame.hasOpacity then
				ColorPickerFrame.Content.ColorPicker:SetColorAlpha(a or 1)
			end
		end
	end)
	WoWTools_DataMixin:Hook(ColorPickerFrame, 'SetupColorPickerAndShow', Set_SaveLogList)
	Set_SaveLogList()


	ColorPickerFrame.Footer.OkayButton:HookScript('OnClick', function()
		local logNum= Save().logMaxColor or 10
		if logNum==0 then
			Save().logColor={}
			return
		end
		local r, g, b, a= WoWTools_ColorMixin:Get_ColorFrameRGBA()
		for _, col in pairs(Save().logColor) do
			if col.r==r and col.g==g and col.b==b and col.a== a then
				return
			end
		end
		local num= #Save().logColor
		do
			for i= num, logNum, -1 do
				table.remove(Save().logColor, i)
			end
		end

		table.insert(Save().logColor, 1, {r=r, g=g, b=b, a=a})
	end)


	for index, color in pairs(
		{
			{NORMAL_FONT_COLOR:GetRGBA()},
			{HIGHLIGHT_FONT_COLOR:GetRGBA()},
			{WARNING_FONT_COLOR:GetRGBA()},
			{DISABLED_FONT_COLOR:GetRGBA()},
		}
	) do
		local c= Save().saveColor[index] or color
		local r,g,b,a= c[1] or 1, c[2] or 1, c[3] or 1, c[4] or 1
		local icon= WoWTools_ColorMixin:Create_Texture(r,g,b,a)
		local s= icon:GetWidth()
		if index==1 then
			icon:SetPoint('TOPLEFT', ColorPickerFrame.Content.ColorSwatchOriginal, 'BOTTOMLEFT', 0, 0)
		elseif index==2 then
			icon:SetPoint('TOPLEFT', ColorPickerFrame.Content.ColorSwatchOriginal, 'BOTTOMLEFT', 0, -s)
		elseif index==3 then
			icon:SetPoint('TOPLEFT', ColorPickerFrame.Content.ColorSwatchOriginal, 'BOTTOMLEFT', s, 0)
		else
			icon:SetPoint('TOPLEFT', ColorPickerFrame.Content.ColorSwatchOriginal, 'BOTTOMLEFT', s, -s)
		end
		icon.index= index
		icon.tooltip= function(self)
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(
				(WoWTools_L['SAVE+COLOR'])..' '..self.index,
				(WoWTools_L.REPLACE)..WoWTools_DataMixin.Icon.right
			)
		end
		icon.notClick='RightButton'
		icon.Color= {r=color[1], g=color[2], b=color[3], a=color[4]}
		icon:HookScript('OnMouseDown', function(self, d)
			if d~='RightButton' then
				return
			end
				MenuUtil.CreateContextMenu(self:GetParent(), function(_, root)

					local function set_tooltip(tooltip, desc)
						tooltip:AddDoubleLine(
							'r'..tonumber(format('%.2f',desc.data.r))
							..'  g'..tonumber(format('%.2f',desc.data.g))
							..'  b'..tonumber(format('%.2f',desc.data.b)),

							'a'..(desc.data.a and tonumber(format('%.2f',desc.data.a) or 1))
						)
					end

					local function add_icon(button, desc)
						local t = button:AttachTexture()
						t:SetSize(20, 20);
						t:SetPoint("RIGHT")
						t:SetColorTexture(desc.data.r, desc.data.g, desc.data.b, 1)
						return 20 + button.fontString:GetUnboundedStringWidth(), 20
					end

					local function settings(data)
						Save().saveColor[self.index]= {data.r, data.g, data.b, data.a}
						self.r, self.g, self.b, self.a= data.r, data.g, data.b, data.a
						self:SetColorTexture(data.r, data.g, data.b)
					end

					local sub
					local col= select(5, WoWTools_ColorMixin:Get_ColorFrameRGBA())
					sub= root:CreateButton(
						WoWTools_L.REFORGE_CURRENT,
					function (data)
						settings(data)
						return MenuResponse.Open
					end, {r=self.r, g=self.g, b=self.b, a=self.a or 1})
					sub:AddInitializer(add_icon)
					sub:SetTooltip(set_tooltip)
					sub= root:CreateButton(
						WoWTools_L.CHOOSE,
					function(data)
						settings(data)
						return MenuResponse.Open
					end, col)
					sub:AddInitializer(add_icon)
					sub:SetTooltip(function(tooltip, desc)
						WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Color.SlotChoose'])
						set_tooltip(tooltip, desc)
					end)
					sub= root:CreateButton(
						WoWTools_L.DEFAULT,
					function (data)
						settings(data)
						return MenuResponse.Open
					end, self.Color)
					sub:AddInitializer(add_icon)
					sub:SetTooltip(function(tooltip, desc)
						WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Color.SlotDefault'])
						set_tooltip(tooltip, desc)
					end)
					root:CreateDivider()

				end)


		end)
	end
end













function WoWTools_ColorMixin:Init_Log()
	Init()
end


function WoWTools_ColorMixin:Set_SaveLogList()
	Set_SaveLogList()
end