

local P_Save={
    --disabledMove=true,--禁用移动
    point={},--移动
    SavePoint= true,--保存窗口,位置 (antes solo para el autor: los paneles volvían a su sitio sin explicación)
    --moveToScreenFuori=WoWTools_DataMixin.Player.husandro,--可以移到屏幕外

    --disabledZoom=true,--禁用缩放
    scale={},--缩放 (antes 0.85 por defecto en ZoneAbilityFrame, UIWidgetPowerBarContainerFrame y BankFrame)
    size={},
    disabledSize={
        ['WorldMapFrame']= not WoWTools_DataMixin.Player.husandro
    },

    --notMoveAlpha=true,--是否设置，移动时，设置透明度
    alpha=0.5,
    disabledAlpha={},

    UIPanelWindows={},
    Esc={['CooldownViewerSettings']=false},--1=移除, 2=添加
    no={},--禁用


    --disablesWorldMapFrameSize= not WoWTools_DataMixin.Player.husandro
}

local Layout
local function Save()
    return WoWToolsPlusSave['Plus_Move']
end




local function Init_Panel()

    local tooltip= '|cnWARNING_FONT_COLOR:'..(WoWTools_L.REQUIRES_RELOAD)

    WoWTools_PanelMixin:Header(Layout, WoWTools_L.RESET_ALL_BUTTON_TEXT)


    WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_L['Save position'],
        GetValue= function() return Save().SavePoint end,
        SetValue= function()
            Save().SavePoint= not Save().SavePoint and true or nil
        end,
        buttonText= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2),
        buttonFunc= function()
            StaticPopup_Show('WoWTools_RestData',
                WoWTools_MoveMixin.addName,
                nil,
            function()
                Save().point={}
            end)
        end,
        tooltip= WoWTools_L['Tip.Move.SavePoint']..'|n|n'..'|cnWARNING_FONT_COLOR:'..(WoWTools_L.REQUIRES_RELOAD),
        layout= Layout,
        category= WoWTools_MoveMixin.Category,
    })

    WoWTools_PanelMixin:Check_Slider({
        checkName= WoWTools_L['Fade frame when moving'],
        checkGetValue= function() return not Save().notMoveAlpha end,
        checkTooltip= WoWTools_L['Frame fades when you start moving']..'|n|n'..'|cnWARNING_FONT_COLOR:'..(WoWTools_L.REQUIRES_RELOAD),
        siderTooltip= WoWTools_L['Tip.Move.AlphaValue'],
        checkSetValue= function()
            Save().notMoveAlpha= not Save().notMoveAlpha and true or nil
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_MoveMixin.addName, WoWTools_L.REQUIRES_RELOAD)
        end,
        sliderGetValue= function() return Save().alpha or 0.5 end,
        minValue= 0,
        maxValue= 0.9,
        step= 0.1,
        sliderSetValue= function(_, _, value2)
            if value2 then
                Save().alpha= WoWTools_DataMixin:GetFormatter1to10(value2, 0, 1)
            end
        end,
        layout= Layout,
        category= WoWTools_MoveMixin.Category,
    })


    local index=0
    local function Add_Options(name)
        WoWTools_PanelMixin:OnlyCheck({
            name= HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(index..') ')..name:gsub('Blizzard_', ''),
            tooltip= WoWTools_L['Tip.Move.FrameModule']..'|n|n'..tooltip,
            category= WoWTools_MoveMixin.Category,
            Value= not Save().no[name],
            GetValue= function() return not Save().no[name] end,
            SetValue= function()
                Save().no[name]= not Save().no[name] and true or nil
            end
        })
    end

    WoWTools_PanelMixin:Header(Layout, 'Event')
    for name in pairs(WoWTools_MoveMixin.Events) do
        index= index+1
        Add_Options(name)
    end

    index=0
    WoWTools_PanelMixin:Header(Layout, 'Frame')
    for name in pairs(WoWTools_MoveMixin.Frames) do
        index=index+1
        Add_Options(name)
    end

    Init_Panel=function()end
end












local function Init()
    WoWTools_MoveMixin:Init_AddButton()--添加，移动/缩放，按钮
    WoWTools_MoveMixin:Init_Class_Power()--职业，能量条

    for name, func in pairs(WoWTools_MoveMixin.Events) do
        if C_AddOns.IsAddOnLoaded(name) and func then
            if not Save().no[name] then
                func(WoWTools_MoveMixin)
            end
            WoWTools_MoveMixin.Events[name]=nil
        end
    end

    for name, func in pairs(WoWTools_MoveMixin.Frames) do
        if _G[name] and not Save().no[name] then
            func(WoWTools_MoveMixin)
        elseif WoWTools_DataMixin.Player.husandro then
            print(WoWTools_MoveMixin.addName, 'Frames[|cnWARNING_FONT_COLOR:'..name..'|r]', '没有发现')
        end
        WoWTools_MoveMixin.Frames[name]= nil
    end

    for name in pairs(UIPanelWindows) do--diccionario por nombre: ipairs no iteraba nunca
        if type(name)=='string'
            and _G[name]
            and type(_G[name])=='table'
            and _G[name].IsProtected
            and not _G[name]:IsProtected()
            and not Save().no[name]
            and not _G[name]:IsMovable()
            and not _G[name].moveFrameData
            and not _G[name].ResizeButton
        then
            WoWTools_MoveMixin:Setup(_G[name])
            if WoWTools_DataMixin.Player.husandro then
                print(WoWTools_MoveMixin.addName, '没有添加', name)
            end
        end
    end

    WoWTools_DataMixin:Hook('UpdateUIPanelPositions', function(currentFrame)
        if Save().SavePoint then
            WoWTools_MoveMixin:SetPoint(currentFrame)
        end
    end)

    Init=function()end
end










local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Plus_Move']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Move'], P_Save)

            Save().UIPanelWindows= Save().UIPanelWindows or P_Save.UIPanelWindows
            --Antes: Save().Esc= Save() (faltaba .Esc), la tabla se guardaba dentro de sí misma
            if Save().Esc==Save() then
                Save().Esc= nil
            end
            Save().Esc= Save().Esc or P_Save.Esc
            Save().no= Save().no or {}

            P_Save= nil


            WoWTools_MoveMixin.addName= '|TInterface\\Cursor\\UI-Cursor-Move:0|t'..(WoWTools_L.NPE_MOVE)

            WoWTools_MoveMixin.Category, Layout= WoWTools_PanelMixin:AddSubCategory({
                name=WoWTools_MoveMixin.addName,
                disabled= Save().disabled,
            })

            WoWTools_PanelMixin:Check_Button({
                checkName= WoWTools_L.ENABLE,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
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

            if Save().disabled then
                WoWTools_MoveMixin.Events={}
                WoWTools_MoveMixin.Frames={}
                self:UnregisterEvent('ADDON_LOADED')
                self:SetScript('OnEvent', nil)
            else
                do
                    Init_Panel()
                end
                Init()
                --self:RegisterEvent('PLAYER_ENTERING_WORLD')
            end

        elseif WoWToolsPlusSave then

            if WoWTools_MoveMixin.Events[arg1] then
                if not Save().no[arg1] then
                    WoWTools_MoveMixin.Events[arg1](WoWTools_MoveMixin)
                end
                WoWTools_MoveMixin.Events[arg1]=nil
            end
        end

    --elseif event=='PLAYER_ENTERING_WORLD' then
        --Init()
        --self:UnregisterEvent(event)
    end
end)