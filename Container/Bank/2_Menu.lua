local function Save()
    return WoWToolsPlusSave['Plus_Bank2']
end


local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    elseif not C_Bank.AreAnyBankTypesViewable() then
        root:CreateTitle(
            '|cnWARNING_FONT_COLOR:'
            ..(WoWTools_L.ERR_BANK_NOT_ACCESSIBLE))
        root:CreateDivider()
    end
    local sub, sub2

--Plus 必需重新载加，因为hook Mixin
    sub= root:CreateButton(
        'Plus',
    function()
        return MenuResponse.Open
    end)

--标签
    sub2=sub:CreateCheckbox(
        WoWTools_L['Tab'],
    function()
        return Save().plusTab
    end, function()
        Save().plusTab= not Save().plusTab and true or false
        WoWTools_BankMixin:Init_BankPlus()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
    end)

--索引
    sub2=sub:CreateCheckbox(WoWTools_L['Index'], function()
        return Save().plusIndex
    end, function()
        Save().plusIndex= not Save().plusIndex and true or false--显示，索引
        WoWTools_BankMixin:Init_BankPlus()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
    end)

--物品信息
    sub2=sub:CreateCheckbox(WoWTools_L['ITEMS+INFO'], function()
        return Save().plusItem
    end, function()
        Save().plusItem= not Save().plusItem and true or false--显示，索引
        WoWTools_BankMixin:Init_BankPlus()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
    end)

    sub:CreateDivider()
    WoWTools_MenuMixin:CVar(sub, 'bankAutoDepositReagents', nil, WoWTools_L.BANK_DEPOSIT_INCLUDE_REAGENTS_CHECKBOX_LABEL, function(show)
        if BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:IsVisible() then
            BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:SetChecked(show)
        end
    end)
    WoWTools_MenuMixin:CVar(sub, 'bankConfirmTabCleanUp', nil, WoWTools_L.BANK_CONFIRM_CLEANUP_PROMPT)

    sub2= sub:CreateCheckbox(
        WoWTools_L['DISABLE+STABLE_FILTER_BUTTON_LABEL'],
    function()
        return C_Container.GetBankAutosortDisabled()
    end, function()
        C_Container.SetBankAutosortDisabled(not C_Container.GetBankAutosortDisabled() and true or false)
        return MenuResponse.Close
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('C_Container.SetBankAutosortDisabled')
    end)




--转化为联合的大包
    root:CreateSpacer()
    sub=root:CreateCheckbox(
        '|cnWARNING_FONT_COLOR:'
        ..(WoWTools_L.BAG_COMMAND_CONVERT_TO_COMBINED),
    function()
        return Save().allBank
    end, function()
        Save().allBank= not Save().allBank and true or nil
        local isInit= BankPanel.tabNames
        do
            WoWTools_BankMixin:Init_AllBank()
        end
        if not isInit then
            BankPanel:RefreshBankPanel()
        end
    end)
    sub:SetTooltip(function(tooltip)
        GameTooltip_AddErrorLine(tooltip,
            WoWTools_DataMixin.onlyChinese and '“物品信息” 同时打，会卡' or (WoWTools_Join(ITEMS, INFO)..': '..(TICKET_TYPE3 or 'Bug'))
        )
        tooltip:AddLine(' ')
        GameTooltip_AddErrorLine(tooltip,
            'Bug: '..(WoWTools_L.CONFIRM_BUY_CHARACTER_BANK_TAB)
        )
        tooltip:AddLine(' ')
        GameTooltip_AddInstructionLine(tooltip, WoWTools_L.REQUIRES_RELOAD)
    end)



--行数
    --root:CreateDivider()
    sub:CreateSpacer()
    sub2=WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().num
        end, setValue=function(value)
            Save().num=value
            WoWTools_BankMixin:Init_AllBank()
        end,
        name=WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS,
        minValue=4,
        maxValue=32,
        step=1,
        bit=nil,
    })
    sub2:SetEnabled(Save().allBank)

--间隔
    sub:CreateSpacer()
    sub:CreateSpacer()
    sub2=WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().line
        end, setValue=function(value)
            Save().line=value
            WoWTools_BankMixin:Init_AllBank()
        end,
        name=WoWTools_L['Interval'],
        minValue=0,
        maxValue=32,
        step=1,
        bit=nil,
    })
    sub2:SetEnabled(Save().allBank)









    root:CreateDivider()
--重新加载UI
    sub=WoWTools_MenuMixin:Reload(root)
--打开选项界面
    WoWTools_MenuMixin:OpenOptions(sub, {name=WoWTools_BankMixin.addName})
end

















local function Init()
    local btn= WoWTools_ButtonMixin:Menu(BankFrameCloseButton, {name='WoWToolsPlusBankMenuButton'})
    btn:SetPoint('RIGHT', BankFrameCloseButton, 'LEFT', -2,0)

    function btn:Open_Bag()
        WoWTools_BagMixin:OpenBag(nil, true)
        C_Timer.After(0.3, function() BankFrame:Raise() end)
    end
    btn:SetupMenu(Init_Menu)


    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL)
        GameTooltip:Show()
    end)




    --[[
    sub=root:CreateCheckbox(
        WoWTools_L['SAVE+ITEMS'],
    function()
        return Save().saveWoWData
    end, function()
        Save().saveWoWData= not Save().saveWoWData and true or nil
        BankPanel:Clean()
    end)
    WoWTools_DataMixin:OpenWoWItemListMenu(self, sub)
    ]]
    Init=function()end
end


function WoWTools_BankMixin:Init_BankMenu()
    Init()
end