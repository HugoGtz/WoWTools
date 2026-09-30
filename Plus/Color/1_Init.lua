local P_Save= {
	--disabled=true,
	--hide=true,
	--autoShow=true,--自动显示
	--sacle=1,

	logColor={},--保存，历史记录
	--logMaxColor=10,--设置，最多保存30个颜色
	--selectType2=true,--更多颜色

	saveColor={},--保存4个颜色
	notHideFuori= WoWTools_DataMixin.Player.husandro,--自动隐藏
}


local function Save()
	return WoWToolsPlusSave['Plus_Color']
end





local function Show_ClorFrame()
	if not Save().autoShow then
		return
	end

	WoWTools_ColorMixin:ShowColorFrame(nil, nil, nil, 1)

	print(
		WoWTools_ColorMixin.addName..WoWTools_DataMixin.Icon.icon2,
		'|cnGREEN_FONT_COLOR:'
		..(WoWTools_L['SELF_CAST_AUTO+SHOW'])

	)

end




--原生，去掉，在框架外，会自动关闭
local function Set_Event(self, event)
	if event == "GLOBAL_MOUSE_DOWN" then
		if self:IsShown()
			and not DoesAncestryIncludeAny(self, GetMouseFoci())
			--and not _G['WoWToolsColorPickerFrameButton']:IsMenuOpen()
			and not Save().notHideFuori--自动隐藏
			and not Menu.GetManager():IsAnyMenuOpen()

		then
			if self.cancelFunc then
				self.cancelFunc(self.previousValues)
			end
			self:Hide();
		end
	end
end




local function Init()
	do
		WoWTools_ColorMixin:Init_Menu()
	end
	WoWTools_ColorMixin:Init_EditBox()
	WoWTools_ColorMixin:Init_SelectColor()
	WoWTools_ColorMixin:Init_Log()
	WoWTools_ColorMixin:Init_Other()

	Init=function()end
end





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")



panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then
			WoWToolsPlusSave['Plus_Color']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Color'], P_Save)
			P_Save=nil

			WoWTools_ColorMixin.addName= '|A:colorblind-colorwheel:0:0|a'..(WoWTools_L.COLOR_PICKER)

			--添加控制面板
			WoWTools_PanelMixin:Check_Button({
				checkName= WoWTools_ColorMixin.addName,
				tooltip= WoWTools_L['Tip.Color.Enable']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
				GetValue= function() return not Save().disabled end,
				SetValue= function()
					Save().disabled= not Save().disabled and true or nil
					print(
						WoWTools_ColorMixin.addName..WoWTools_DataMixin.Icon.icon2,
						WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
						WoWTools_L.REQUIRES_RELOAD
					)
				end,
				buttonText='|A:colorblind-colorwheel:0:0|a'..(WoWTools_L.SHOW),
				buttonFunc= function()
					
					WoWTools_ColorMixin:ShowColorFrame(nil, nil, nil, 1)
				end,
			})

			if Save().disabled then
				--WoWTools_ColorMixin:Init_CODE()
				self:SetScript('OnEvent', nil)
				self:UnregisterAllEvents()

			else
				self:RegisterEvent('PLAYER_ENTERING_WORLD')
				ColorPickerFrame:SetScript('OnEvent', Set_Event)--原生，去掉，在框架外，会自动关闭

				ColorPickerFrame:HookScript('OnShow', function()
					Init()
				end)
				self:UnregisterEvent(event)
			end
        end

	elseif event=='PLAYER_ENTERING_WORLD' then
		Show_ClorFrame()
		self:SetScript('OnEvent', nil)
		self:UnregisterEvent(event)
    end
end)