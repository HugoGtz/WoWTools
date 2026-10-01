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




local function Menu_Button()
	return _G['WoWToolsColorPickerFrameButton']
end

local function Refresh()
	local btn= Menu_Button()
	if btn then
		btn:Settings()
	end
end

--Esquema del Centro de control (docs/SETTINGS.md): los mismos ajustes que el menú del selector de color
local Options= {
	{type='section', text='GENERAL'},
	{type='check', key='show', text='SHOW', tooltip='Tip.Color.Show',
		get= function(save) return not save.hide end,
		set= function(save, value) save.hide= not value and true or nil end,
		apply= Refresh,
	},
	{type='check', key='moreColors', text='More colors', tooltip='Tip.Color.MoreColors', reload=true,
		get= function(save) return save.selectType2 end,
		set= function(save, value) save.selectType2= value and true or nil end,
	},
	{type='slider', key='logMax', text='Colors in history', tooltip='Tip.Color.LogMax', min=0, max=200, step=1,
		get= function(save) return save.logMaxColor or 10 end,
		set= function(save, value) save.logMaxColor= math.floor(value) end,
		apply= function()
			if Menu_Button() then
				WoWTools_ColorMixin:Set_SaveLogList()
			end
		end,
	},
	{type='button', key='clearLog', text='SLASH_STOPWATCH_PARAM_STOP2+EVENTTRACE_LOG_HEADER', buttonText='CLEAR_ALL', tooltip='Tip.Color.ClearLog',
		confirm=true, indent=true,
		func= function(_, save)
			save.logColor= {}
			if Menu_Button() then
				WoWTools_ColorMixin:Set_SaveLogList()
			end
		end,
	},

	{type='section', text='Automations'},
	{type='check', key='autoHide', text='SELF_CAST_AUTO+HIDE', tooltip='Tip.Color.AutoHide', automation=true,
		get= function(save) return not save.notHideFuori end,
		set= function(save, value) save.notHideFuori= not value and true or nil end,
		apply= Refresh,
	},
	{type='check', key='autoShow', text='SELF_CAST_AUTO+SHOW', tooltip='Tip.Color.AutoShow', automation=true,
		get= function(save) return save.autoShow end,
		set= function(save, value) save.autoShow= value and true or nil end,
	},

	{type='section', text='Appearance'},
	{type='slider', key='scale', text='HOUSING_EXPERT_DECOR_SUBMODE_SCALE', tooltip='Tip.Menu.Scale', min=0.4, max=4, step=0.1, format='%.1f',
		get= function(save) return save.scale or 1 end,
		set= function(save, value) save.scale= tonumber(format('%.1f', value)) or 1 end,
		apply= Refresh,
	},
}


--Módulo registrado con la API común (docs/REFACTOR.md, R1): arranque, ajustes, casilla del panel y grupo
WoWTools_Module:Register({
	key= 'Plus_Color',
	name= 'Module.Color picker',
	icon= 'colorblind-colorwheel',
	group= 'Interface',
	defaults= P_Save,
	tooltip= 'Tip.Color.Enable',
	mixin= WoWTools_ColorMixin,
	options= Options,
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
