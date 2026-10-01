

local P_Save={
    point={},
    SavePoint= true,

    scale={},
    size={},
    disabledSize={
        ['WorldMapFrame']= true
    },

    alpha=0.5,
    disabledAlpha={},

    UIPanelWindows={},
    Esc={['CooldownViewerSettings']=false},
    no={},


    --disablesWorldMapFrameSize= true
}

local Layout
local Init_Panel= WoWTools_Once(function()

    local tooltip= '|cnWARNING_FONT_COLOR:'..(WoWTools_L.REQUIRES_RELOAD)

    WoWTools_PanelMixin:Header(Layout, WoWTools_L.RESET_ALL_BUTTON_TEXT)


    WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_L['Save position'],
        GetValue= function() return WoWTools_MoveMixin:Save().SavePoint end,
        SetValue= function()
            WoWTools_MoveMixin:Save().SavePoint= not WoWTools_MoveMixin:Save().SavePoint and true or nil
        end,
        buttonText= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2),
        buttonFunc= function()
            StaticPopup_Show('WoWTools_RestData',
                WoWTools_MoveMixin.addName,
                nil,
            function()
                WoWTools_MoveMixin:Save().point={}
            end)
        end,
        tooltip= WoWTools_L['Tip.Move.SavePoint']..'|n|n'..'|cnWARNING_FONT_COLOR:'..(WoWTools_L.REQUIRES_RELOAD),
        layout= Layout,
        category= WoWTools_MoveMixin.Category,
    })

    WoWTools_PanelMixin:Check_Slider({
        checkName= WoWTools_L['Fade frame when moving'],
        checkGetValue= function() return not WoWTools_MoveMixin:Save().notMoveAlpha end,
        checkTooltip= WoWTools_L['Frame fades when you start moving']..'|n|n'..'|cnWARNING_FONT_COLOR:'..(WoWTools_L.REQUIRES_RELOAD),
        siderTooltip= WoWTools_L['Tip.Move.AlphaValue'],
        checkSetValue= function()
            WoWTools_MoveMixin:Save().notMoveAlpha= not WoWTools_MoveMixin:Save().notMoveAlpha and true or nil
            WoWTools_Print(WoWTools_DataMixin.Icon.icon2..WoWTools_MoveMixin.addName, WoWTools_L.REQUIRES_RELOAD)
        end,
        sliderGetValue= function() return WoWTools_MoveMixin:Save().alpha or 0.5 end,
        minValue= 0,
        maxValue= 0.9,
        step= 0.1,
        sliderSetValue= function(_, _, value2)
            if value2 then
                WoWTools_MoveMixin:Save().alpha= WoWTools_DataMixin:GetFormatter1to10(value2, 0, 1)
            end
        end,
        layout= Layout,
        category= WoWTools_MoveMixin.Category,
    })


    local index=0
    local function Add_Options(name)
        WoWTools_PanelMixin:OnlyCheck({
            name= name:gsub('Blizzard_', ''),
            tooltip= WoWTools_L['Tip.Move.FrameModule']..'|n|n'..tooltip,
            category= WoWTools_MoveMixin.Category,
            Value= not WoWTools_MoveMixin:Save().no[name],
            GetValue= function() return not WoWTools_MoveMixin:Save().no[name] end,
            SetValue= function()
                WoWTools_MoveMixin:Save().no[name]= not WoWTools_MoveMixin:Save().no[name] and true or nil
            end
        })
    end

    WoWTools_PanelMixin:Header(Layout, WoWTools_L['Advanced: windows loaded on demand'])
    for name in pairs(WoWTools_MoveMixin.Events) do
        index= index+1
        Add_Options(name)
    end

    index=0
    WoWTools_PanelMixin:Header(Layout, WoWTools_L['Advanced: always-loaded windows'])
    for name in pairs(WoWTools_MoveMixin.Frames) do
        index=index+1
        Add_Options(name)
    end
end)












local function Init()
    WoWTools_MoveMixin:Init_AddButton()
    WoWTools_MoveMixin:Init_Class_Power()

    for name, func in pairs(WoWTools_MoveMixin.Events) do
        if C_AddOns.IsAddOnLoaded(name) and func then
            if not WoWTools_MoveMixin:Save().no[name] then
                func(WoWTools_MoveMixin)
            end
            WoWTools_MoveMixin.Events[name]=nil
        end
    end

    for name, func in pairs(WoWTools_MoveMixin.Frames) do
        if _G[name] and not WoWTools_MoveMixin:Save().no[name] then
            func(WoWTools_MoveMixin)
        end
        WoWTools_MoveMixin.Frames[name]= nil
    end

    for name in pairs(UIPanelWindows) do--diccionario por nombre: ipairs no iteraba nunca
        if type(name)=='string'
            and _G[name]
            and type(_G[name])=='table'
            and _G[name].IsProtected
            and not _G[name]:IsProtected()
            and not WoWTools_MoveMixin:Save().no[name]
            and not _G[name]:IsMovable()
            and not _G[name].moveFrameData
            and not _G[name].ResizeButton
        then
            WoWTools_MoveMixin:Setup(_G[name])
        end
    end

    WoWTools_DataMixin:Hook('UpdateUIPanelPositions', function(currentFrame)
        if WoWTools_MoveMixin:Save().SavePoint then
            WoWTools_MoveMixin:SetPoint(currentFrame)
        end
    end)
end










--Despachador propio de ventanas de Blizzard (WoWTools_MoveMixin.Events): se migra en la fase R3
local function Init_Events()
    local frame= CreateFrame('Frame')
    frame:RegisterEvent('ADDON_LOADED')
    frame:SetScript('OnEvent', function(_, _, arg1)
        if WoWTools_MoveMixin.Events[arg1] then
            if not WoWTools_MoveMixin:Save().no[arg1] then
                WoWTools_MoveMixin.Events[arg1](WoWTools_MoveMixin)
            end
            WoWTools_MoveMixin.Events[arg1]=nil
        end
    end)
end




--Página de opciones propia (subcategoría): se crea siempre, también con el módulo desactivado
local function Init_Category()
    WoWTools_MoveMixin:Save().UIPanelWindows= WoWTools_MoveMixin:Save().UIPanelWindows or P_Save.UIPanelWindows
    --Antes: WoWTools_MoveMixin:Save().Esc= WoWTools_MoveMixin:Save() (faltaba .Esc), la tabla se guardaba dentro de sí misma
    if WoWTools_MoveMixin:Save().Esc==WoWTools_MoveMixin:Save() then
        WoWTools_MoveMixin:Save().Esc= nil
    end
    WoWTools_MoveMixin:Save().Esc= WoWTools_MoveMixin:Save().Esc or P_Save.Esc
    WoWTools_MoveMixin:Save().no= WoWTools_MoveMixin:Save().no or {}

    P_Save= nil

    WoWTools_MoveMixin.Category, Layout= WoWTools_PanelMixin:AddSubCategory({
        name=WoWTools_MoveMixin.addName,
        disabled= WoWTools_MoveMixin:Save().disabled,
    })

    WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_L.ENABLE,
        GetValue= function() return not WoWTools_MoveMixin:Save().disabled end,
        SetValue= function()
            WoWTools_MoveMixin:Save().disabled= not WoWTools_MoveMixin:Save().disabled and true or nil
            Init_Panel()
        end,
        buttonText= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_L.RESET),
        buttonFunc= function()
            StaticPopup_Show('WoWTools_RestData',
                WoWTools_MoveMixin.addName,
                nil,
            function()
                WoWToolsPlusSave['Plus_Move']= nil
            end)
        end,
        tooltip= WoWTools_L['Tip.Move.Enable']..'|n|n'..'|cnWARNING_FONT_COLOR:'..(WoWTools_L.REQUIRES_RELOAD),
        layout= Layout,
        category= WoWTools_MoveMixin.Category,
    })

    if WoWTools_MoveMixin:Save().disabled then
        WoWTools_MoveMixin.Events={}
        WoWTools_MoveMixin.Frames={}
    end
end




WoWTools_Module:Register({
    key= 'Plus_Move',
    name= 'Module.Move frames',
    icon= 'Interface\\Cursor\\UI-Cursor-Move',
    group= 'Interface',
    defaults= P_Save,
    tooltip= 'Tip.Move.Enable',
    mixin= WoWTools_MoveMixin,
    panel= false,--tiene su propia subcategoría (Init_Category)
    onLoad= Init_Category,
    onEnable= function()
        Init_Panel()
        Init()
        Init_Events()
    end,
})
