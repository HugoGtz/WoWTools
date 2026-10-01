local P_Save= {
	--disabled=true,
	--hide=true,
	--sacle=1,

	logColor={},

	saveColor={},
}


local function Save()
	return WoWTools_ColorMixin:Save()
end





local function Show_ClorFrame()
	if not Save().autoShow then
		return
	end

	WoWTools_ColorMixin:ShowColorFrame(nil, nil, nil, 1)

	WoWTools_Print(
		WoWTools_ColorMixin.addName..WoWTools_DataMixin.Icon.icon2,
		'|cnGREEN_FONT_COLOR:'
		..(WoWTools_L['SELF_CAST_AUTO+SHOW'])

	)

end




local function Set_Event(self, event)
	if event == "GLOBAL_MOUSE_DOWN" then
		if self:IsShown()
			and not DoesAncestryIncludeAny(self, GetMouseFoci())
			--and not _G['WoWToolsColorPickerFrameButton']:IsMenuOpen()
			and not Save().notHideFuori
			and not Menu.GetManager():IsAnyMenuOpen()

		then
			if self.cancelFunc then
				self.cancelFunc(self.previousValues)
			end
			self:Hide();
		end
	end
end




--Módulo registrado con la API común (docs/REFACTOR.md, R1): arranque, ajustes, casilla del panel y grupo
WoWTools_Module:Register({
	key= 'Plus_Color',
	name= 'Module.Color picker',
	icon= 'colorblind-colorwheel',
	group= 'Interface',
	defaults= P_Save,
	tooltip= 'Tip.Color.Enable',
	mixin= WoWTools_ColorMixin,
	button= {text= 'SHOW', func= function()
		WoWTools_ColorMixin:ShowColorFrame(nil, nil, nil, 1)
	end},
	onEnable= function()
		ColorPickerFrame:SetScript('OnEvent', Set_Event)
		ColorPickerFrame:HookScript('OnShow', WoWTools_Once(function()
			WoWTools_ColorMixin:Init_Menu()
			WoWTools_ColorMixin:Init_EditBox()
			WoWTools_ColorMixin:Init_SelectColor()
			WoWTools_ColorMixin:Init_Log()
			WoWTools_ColorMixin:Init_Other()
		end))
	end,
	onLogin= Show_ClorFrame,
})
