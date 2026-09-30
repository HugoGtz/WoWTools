local Layout
local function Save()
    return WoWToolsPlusSave['Plus_Tootips']
end


local function set_Cursor_Tips(self)
    WoWTools_TooltipMixin:Set_Rest_Item(GameTooltip)
    WoWTools_TooltipMixin:Set_Rest_Item(ItemRefTooltip)

    WoWTools_TooltipMixin:Set_PlayerModel(GameTooltip)
    WoWTools_TooltipMixin:Set_PlayerModel(ItemRefTooltip)

    GameTooltip_SetDefaultAnchor(GameTooltip, self or UIParent)
    GameTooltip:SetScale(Save().scale or 1)
    GameTooltip:ClearLines()
    GameTooltip:SetUnit('player')
    GameTooltip:Show()
end


local function Init_Panel()
    local reloadText= '|cnWARNING_FONT_COLOR:'..(WoWTools_L.REQUIRES_RELOAD)

    WoWTools_PanelMixin:Header(Layout, WoWTools_L['Tooltip position'])
    local root


    root= WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L['FOLLOW+MOUSE_LABEL'],
        tooltip= WoWTools_L['Tip.Tooltip.FollowMouse'],
        GetValue= function() return Save().setDefaultAnchor end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().setDefaultAnchor= not Save().setDefaultAnchor and true or false
            if Save().setDefaultAnchor then
                Save().setAnchor=nil
            end
            set_Cursor_Tips()
        end
    })

    WoWTools_PanelMixin:OnlySlider({
        name= 'X',
        GetValue= function() return Save().cursorX or 0 end,
        minValue= -240,
        maxValue= 240,
        setp= 1,
        tooltip= WoWTools_L['Tip.Tooltip.CursorX'],
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().cursorX= WoWTools_DataMixin:GetFormatter1to10(value2, -200, 200)
            set_Cursor_Tips()
        end
    }, root)


    WoWTools_PanelMixin:OnlySlider({
        name= 'Y',
        GetValue= function() return Save().cursorY or 0 end,
        minValue= -240,
        maxValue= 240,
        setp= 1,
        tooltip= WoWTools_L['Tip.Tooltip.CursorY'],
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().cursorY= WoWTools_DataMixin:GetFormatter1to10(value2, -200, 200)
            set_Cursor_Tips()
        end
    }, root)


    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L['HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT~2'],
        tooltip= WoWTools_L['Tip.Tooltip.CursorRight'],
        GetValue= function() return Save().cursorRight end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().cursorRight= not Save().cursorRight and true or nil
            set_Cursor_Tips()
        end
    }, root)


    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L['In combat: default'],
        tooltip= WoWTools_L['Tip.Tooltip.CombatDefaultAnchor'],
        GetValue= function() return Save().inCombatDefaultAnchor end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().inCombatDefaultAnchor= not Save().inCombatDefaultAnchor and true or false
            set_Cursor_Tips()
        end
    }, root)

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L['In combat: disabled'],
        tooltip= WoWTools_L['Tip.Tooltip.CombatDisabled'],
        GetValue= function() return Save().isInCombatDisabled end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().inCombatDefaultAnchor= not Save().isInCombatDisabled and true or nil
        end
    }, root)

    WoWTools_PanelMixin:Header(Layout, WoWTools_L['Tooltip content'])

    root= WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L.MODEL,
        tooltip= WoWTools_L['Tip.Tooltip.Model'],
        GetValue= function() return not Save().hideModel end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().hideModel= not Save().hideModel and true or nil
            set_Cursor_Tips()
        end
    })

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L.HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT,
        tooltip= WoWTools_L['Tip.Tooltip.ModelLeft'],
        GetValue= function() return Save().modelLeft end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().modelLeft= not Save().modelLeft and true or nil
            set_Cursor_Tips()
        end
    }, root)


    WoWTools_PanelMixin:OnlySlider({
        name= WoWTools_L['HUD_EDIT_MODE_SETTING_BAGS_SIZE~2'],
        GetValue= function() return Save().modelSize or 100 end,
        minValue= 40,
        maxValue= 300,
        setp= 1,
        tooltip= WoWTools_L['Tip.Tooltip.ModelSize'],
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().modelSize= WoWTools_DataMixin:GetFormatter1to10(value2, 40, 300)
            set_Cursor_Tips()
        end
    }, root)

    WoWTools_PanelMixin:OnlySlider({
        name= 'X',
        GetValue= function() return Save().modelX or 0 end,
        minValue= -240,
        maxValue= 240,
        setp= 1,
        tooltip= WoWTools_L['Tip.Tooltip.ModelX'],
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().modelX= WoWTools_DataMixin:GetFormatter1to10(value2, -200, 200)
            set_Cursor_Tips()
        end
    }, root)

    WoWTools_PanelMixin:OnlySlider({
        name= 'Y',
        GetValue= function() return Save().modelY or -24 end,
        minValue= -240,
        maxValue= 240,
        setp= 1,
        tooltip= WoWTools_L['Tip.Tooltip.ModelY'],
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().modelY= WoWTools_DataMixin:GetFormatter1to10(value2, -200, 200)
            set_Cursor_Tips()
        end
    }, root)

    WoWTools_PanelMixin:OnlySlider({
        name= WoWTools_L.HUD_EDIT_MODE_SETTING_BAGS_DIRECTION,
        GetValue= function() return Save().modelFacing or -24 end,
        minValue= -1,
        maxValue= 1,
        setp= 0.1,
        tooltip= WoWTools_L['Tip.Tooltip.ModelFacing'],
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().modelFacing= WoWTools_DataMixin:GetFormatter1to10(value2, -1, 1)
            set_Cursor_Tips()
        end
    }, root)

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L['NPC class colors'],
        tooltip= WoWTools_L['Tip.Tooltip.NPCColor'],
        GetValue= function() return not Save().disabledNPCcolor end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().disabledNPCcolor= not Save().disabledNPCcolor and true or nil
        end
    })

    --12.0  可能错误
        WoWTools_PanelMixin:OnlyCheck({
            name= WoWTools_L.HEALTH,
            tooltip= WoWTools_L['Tip.Tooltip.Health']..'|n|n'..reloadText,
            GetValue= function() return not Save().hideHealth end,
            category= WoWTools_TooltipMixin.Category,
            SetValue= function()
                Save().hideHealth= not Save().hideHealth and true or nil
                WoWTools_TooltipMixin:Init_StatusBar()
            end
        })



    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_Join('|A:NPE_Icon:0:0|aCtrl+Shift', WoWTools_L.BROWSER_COPY_LINK),
        tooltip= WoWTools_L['Tip.Tooltip.WebLink']..'|n|n'..'wowhead.com|nraider.io',
        GetValue= function() return Save().ctrl end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().ctrl= not Save().ctrl and true or nil
            set_Cursor_Tips()
        end
    })


    WoWTools_PanelMixin:OnlySlider({
        name= WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
        GetValue= function() return Save().iconSize or 0 end,
        minValue= 0,
        maxValue= 32,
        setp= 1,
        tooltip= WoWTools_L['Tip.Tooltip.IconSize'],
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if value2 then
                Save().iconSize= WoWTools_DataMixin:GetFormatter1to10(value2, 0, 32)
                WoWTools_TooltipMixin.iconSize= Save().iconSize
            end
        end
    })


    WoWTools_PanelMixin:OnlySlider({
        name= WoWTools_L.HOUSING_EXPERT_DECOR_SUBMODE_SCALE,
        GetValue= function() return Save().scale or 1 end,
        minValue=0.2,
        maxValue=4,
        step=0.1,
        tooltip= WoWTools_L['Tip.Tooltip.Scale']..'|n|n'..'|cnWARNING_FONT_COLOR:'..(WoWTools_L.REQUIRES_RELOAD),
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if value2 then
                value2= tonumber(format('%.1f', value2))
                Save().scale= value2
                set_Cursor_Tips()
            end
        end
    })


    WoWTools_PanelMixin:Header(Layout, WARNING_FONT_COLOR:WrapTextInColorCode(WoWTools_L['Replace Blizzard functions (advanced)']))
    WoWTools_PanelMixin:OnlyCheck({
        name= 'SetTooltipMoney',
        tooltip= WoWTools_L['Tip.Tooltip.ReplaceMoney']..'|n|n'..(WoWTools_L['Fix'])..' MoneyFrame_Update '..(WoWTools_L.ERRORS)
                ..'|n'..(WoWTools_L.REQUIRES_RELOAD),
        GetValue= function() return Save().replaceSetTooltipMoney end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().replaceSetTooltipMoney= not Save().replaceSetTooltipMoney and true or nil
        end
    })

    WoWTools_PanelMixin:OnlyCheck({
        name= 'UnitFrame_UpdateTooltip',
        tooltip= WoWTools_L['Tip.Tooltip.ReplaceUnitFrame']..'|n|n'..(WoWTools_L.UNIT_POPUP_RIGHT_CLICK)..': '..WoWTools_TextMixin:GetShowHide(false)
                ..'|n'..(WoWTools_L.REQUIRES_RELOAD),
        GetValue= function() return Save().replaceUnitFrameTooltip end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().replaceUnitFrameTooltip= not Save().replaceUnitFrameTooltip and true or nil
        end
    })




    WoWTools_PanelMixin:Header(Layout, WoWTools_L['Game options (CVar)'])
    root= WoWTools_PanelMixin:OnlyCheck({
        name= '|cnWARNING_FONT_COLOR:'..(WoWTools_L['LOCK+SETTINGS']),
        tooltip= function() return WoWTools_L['Tip.Tooltip.LockCVar']..'|n|n'..(WoWTools_TooltipMixin:Set_CVar(nil, true, true) or '') end,
        GetValue= function() return Save().setCVar end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().setCVar= not Save().setCVar and true or nil
            Save().graphicsViewDistance=nil
        end
    })

    WoWTools_PanelMixin:OnlyButton({
        buttonText= WoWTools_L.SETTINGS,
        tooltip= WoWTools_L['Tip.Tooltip.CVarApply'],
        layout= Layout,
        SetValue= function()
            WoWTools_TooltipMixin:Set_CVar()
            print(WoWTools_L['SETTINGS+COMPLETE'])
        end
    }, root)

    WoWTools_PanelMixin:OnlyButton({
        buttonText= WoWTools_L.DEFAULT,
        tooltip= WoWTools_L['Tip.Tooltip.CVarDefault'],
        layout= Layout,
        SetValue= function()
            WoWTools_TooltipMixin:Set_CVar(true, nil, nil)
            print(WoWTools_L['DEFAULT+COMPLETE'])
        end
    }, root)

    WoWTools_PanelMixin:OnlyMenu({
        SetValue= function(value)
            if not InCombatLockdown() then
                if value==1 then
                    C_CVar.SetCVar("ActionButtonUseKeyDown", '1')
                else
                    C_CVar.SetCVar("ActionButtonUseKeyDown", '0')
                end
            end
        end,
        GetOptions= function()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, WoWTools_L.YES)
            container:Add(2, WoWTools_L['NO~2'])
            return container:GetData()
        end,
        GetValue= function() return C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 1 or 2 end,
        name= WoWTools_L.ACTION_BUTTON_USE_KEY_DOWN,
        tooltip= function()
            return WoWTools_DataMixin:Get_CVar_Tooltips({
                    name='ActionButtonUseKeyDown',
                    msg=WoWTools_L.OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN,
                }) end,
        category= WoWTools_TooltipMixin.Category,
    })


    local index=0
    local function Add_Options(name)
        WoWTools_PanelMixin:OnlyCheck({
            name= name:gsub('Blizzard_', ''),
            tooltip= WoWTools_L['Tip.Tooltip.FrameModule']..'|n|n'..reloadText,
            category= WoWTools_TooltipMixin.Category,
            Value= not Save().no[name],
            GetValue= function() return not Save().no[name] end,
            SetValue= function()
                Save().no[name]= not Save().no[name] and true or nil
            end
        })
    end

    WoWTools_PanelMixin:Header(Layout, WoWTools_L['Advanced: windows loaded on demand'])
    for name in pairs(WoWTools_TooltipMixin.Events) do
        index= index+1
        Add_Options(name)
    end

    index=0
    WoWTools_PanelMixin:Header(Layout, WoWTools_L['Advanced: always-loaded windows'])
    for name in pairs(WoWTools_TooltipMixin.Frames) do
        index= index+1
        Add_Options(name)
    end
    Init_Panel=function()end
end


--初始
local function Init()
    WoWTools_LoadUIMixin:Housing()

    WoWTools_DataMixin:Hook("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
        if Save().setDefaultAnchor
            and not (Save().inCombatDefaultAnchor and InCombatLockdown())
            and not tooltip:IsPreventingSecretValues()
        then
            tooltip:ClearAllPoints()
            tooltip:SetOwner(
                parent,
                Save().cursorRight and 'ANCHOR_CURSOR_RIGHT' or 'ANCHOR_CURSOR_LEFT',
                Save().cursorX or 0,
                Save().cursorY or 0
            )
        end
    end)


    for name in pairs(WoWTools_TooltipMixin.Events)do
        if C_AddOns.IsAddOnLoaded(name) then
            if not Save().no[name] then
                WoWTools_TooltipMixin.Events[name](WoWTools_TooltipMixin)
            end
            WoWTools_TooltipMixin.Events[name]= nil
        end
    end



    EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
        for name in pairs(WoWTools_TooltipMixin.Frames) do
            if _G[name] and not Save().no[name] then
                WoWTools_TooltipMixin.Frames[name](WoWTools_TooltipMixin)
            end
            WoWTools_TooltipMixin.Frames[name]= nil
        end
        EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
    end)



    WoWTools_TooltipMixin:Init_StatusBar()--生命条提示
    WoWTools_TooltipMixin:Init_CVar()

    WoWTools_TooltipMixin:Set_Init_Item(GameTooltip)



    --Reemplazos globales: contaminan código de Blizzard (taint en 12.0), por eso son opcionales (claves nuevas, desactivadas)
    if Save().replaceSetTooltipMoney then
        function SetTooltipMoney(frame, money, _, prefixText, suffixText)
            if not money or not canaccessvalue(money) then
                return
            end
            frame:AddLine(
                (WoWTools_TextMixin:CN(prefixText) or "")
                .. " "
                .. C_CurrencyInfo.GetCoinTextureString(money)
                .. " "
                ..(WoWTools_TextMixin:CN(suffixText) or ""),
                0,1,1
            )
        end
    end
    if Save().replaceUnitFrameTooltip then
        function UnitFrame_UpdateTooltip (self)
            GameTooltip_SetDefaultAnchor(GameTooltip, self);
            if GameTooltip:SetUnit(self.unit, self.hideStatusOnTooltip) then
                self.UpdateTooltip = UnitFrame_UpdateTooltip;
            else
                self.UpdateTooltip = nil;
            end
        end
    end

    Init=function()end
end


--Save().WidgetSetID = Save().WidgetSetID or 0
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Plus_Tootips']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Tootips'], {
                setDefaultAnchor=true,--指定点
                --AnchorPoint={},--指定点，位置
                --cursorRight=nil,--'ANCHOR_CURSOR_RIGHT',

                setCVar=WoWTools_DataMixin.Player.husandro,
                ShowOptionsCVarTips=WoWTools_DataMixin.Player.husandro,--显示选项中的CVar
                inCombatDefaultAnchor=true,
                ctrl= WoWTools_DataMixin.Player.husandro,--取得网页，数据链接

                --模型
                modelSize=100,--大小
                --modelLeft=true,--左边
                modelX= 0,
                modelY= -15,
                modelFacing= -0.3,--方向
                showModelFileID=WoWTools_DataMixin.Player.husandro,--显示，文件ID
                --WidgetSetID=848,--自定义，监视 WidgetSetID
                --disabledNPCcolor=true,--禁用NPC颜色
                --hideHealth=true,----生命条提示
                showItemMK=WoWTools_DataMixin.Player.husandro,
                no={},--禁用
                disabledFix={},
            })


            Save().no= Save().no or {}
            Save().disabledFix= Save().disabledFix or {}
            Save().UNIT_POPUP_RIGHT_CLICK= nil
            WoWTools_TooltipMixin.iconSize= Save().iconSize or 0


            WoWTools_TooltipMixin.Category, Layout= WoWTools_PanelMixin:AddSubCategory({
                name=WoWTools_TooltipMixin.addName,
                disabled= Save().disabled
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
                        WoWTools_TooltipMixin.addName,
                        nil,
                    function()
                        WoWToolsPlusSave['Plus_Tootips']= nil
                    end)
                end,
                tooltip= WoWTools_L['Tip.Tooltip.Enable']..'|n|n'..'|cnWARNING_FONT_COLOR:'..(WoWTools_L.REQUIRES_RELOAD),
                layout= Layout,
                category= WoWTools_TooltipMixin.Category,
            })

            WoWTools_TooltipMixin:Init_WoWHeadText()

            if Save().disabled then
                WoWTools_TooltipMixin.Events= {}
                WoWTools_TooltipMixin.Frames= {}
                self:SetScript('OnEvent', nil)
                self:UnregisterEvent(event)

            else
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                self:RegisterEvent('PLAYER_LEAVING_WORLD')
                self:RegisterEvent('PLAYER_LOGOUT')
                do
                    Init_Panel()
                end
                Init()--初始
            end



        elseif WoWToolsPlusSave then

            if WoWTools_TooltipMixin.Events[arg1] then
                if not Save().no[arg1] then
                    WoWTools_TooltipMixin.Events[arg1](WoWTools_TooltipMixin)
                end
                WoWTools_TooltipMixin.Events[arg1]=nil
            end
        end


    elseif event=='PLAYER_ENTERING_WORLD' then
        if Save().setCVar and Save().graphicsViewDistance and not InCombatLockdown() then
            C_CVar.SetCVar('graphicsViewDistance', Save().graphicsViewDistance)--https://wago.io/ZtSxpza28
            Save().graphicsViewDistance=nil
        end

    elseif event=='PLAYER_LEAVING_WORLD' then
        if Save() and Save().setCVar then
            if not InCombatLockdown() then
                Save().graphicsViewDistance= C_CVar.GetCVar('graphicsViewDistance')
                SetCVar("graphicsViewDistance", 0)
            else
                Save().graphicsViewDistance=nil
            end
        end

    elseif event=='PLAYER_LOGOUT' then--no dejar la distancia de visión a 0 al salir del juego
        if Save() and Save().graphicsViewDistance then
            C_CVar.SetCVar('graphicsViewDistance', Save().graphicsViewDistance)
            Save().graphicsViewDistance=nil
        end
    end
end)
