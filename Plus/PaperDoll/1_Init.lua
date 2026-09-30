local function Save()
    return WoWToolsPlusSave['Plus_PaperDoll']
end


local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub

    sub=root:CreateCheckbox(
        WoWTools_L.TRADESKILL_FILTER_SLOTS,
    function()
        return not Save().hide
    end, function()
        Save().hide= not Save().hide and true or nil
        WoWTools_PaperDollMixin:Init_Item_PoaperDll()
    end, {rightText= Save().statFontSize or 12})
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.PaperDoll.Slots'])
    WoWTools_MenuMixin:SetRightText(sub)

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        name= WoWTools_L.FONT_SIZE,
        getValue=function()
            return Save().statFontSize or 12
        end, setValue=function(value)
            Save().statFontSize= value
            WoWTools_PaperDollMixin:Init_Item_PoaperDll()
        end,
        minValue=8,
        maxValue=18,
        step=1,
        --bit--='%.1f'
        --tooltip--function, string, table
    })
    sub:CreateSpacer()




    local equipNum= #C_EquipmentSet.GetEquipmentSetIDs()
    sub=root:CreateCheckbox(
        (equipNum>0 and '' or DISABLED_FONT_COLOR:GenerateHexColorMarkup())
        ..WoWTools_PaperDollMixin.addName2,
    function()
        return not Save().EquipSet.disabled
    end, function()
        Save().EquipSet.disabled= not Save().EquipSet.disabled and true or nil
        WoWTools_PaperDollMixin:Init_EquipSetButton()
    end, {rightText=equipNum})
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.PaperDoll.EquipSetButton'])
    WoWTools_MenuMixin:SetRightText(sub)

    WoWTools_MenuMixin:RestPoint(self, sub, Save().EquipSet.point, function()
        Save().EquipSet.point=nil
        WoWTools_PaperDollMixin:Init_EquipSetButton()
        return MenuResponse.Open
    end)


    sub=root:CreateCheckbox(
        WoWTools_PaperDollMixin.addName2..' Plus',
    function()
        return not Save().notEquipSetPLus
    end, function()
        Save().notEquipSetPLus= not Save().notEquipSetPLus and true or nil
        WoWTools_PaperDollMixin:Init_EquipSetPlus()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.PaperDoll.EquipSetPlus'])

    
    if WoWTools_DataMixin.Player.Ver>=120005 then
        root:CreateDivider()
        sub=root:CreateCheckbox(
            WoWTools_L.STAT_CATEGORY_ATTRIBUTES,
        function()
            return not Save().notStatusPlus
        end, function ()
            Save().notStatusPlus= not Save().notStatusPlus and true or nil
            WoWTools_PaperDollMixin:Init_Status()
        end)
        sub:SetTooltip(function(tooltip)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.PaperDoll.Stats'])
            GameTooltip_AddErrorLine(tooltip, WoWTools_L.REQUIRES_RELOAD)
        end)
    end

    sub=root:CreateCheckbox(
        WoWTools_L['Attribute decimals'],
    function()
        return not Save().notStatusPlusFunc
    end, function ()
        Save().notStatusPlusFunc= not Save().notStatusPlusFunc and true or nil
        WoWTools_PaperDollMixin:Init_Status_Bit()
    end, {rightText= Save().itemLevelBit or -1})
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.PaperDoll.StatDecimals'])
        tooltip:AddLine((WoWTools_L.SPELL_HASTE)..': |cffffffff9037|r|cnGREEN_FONT_COLOR:[+13%]|r  13|cffff00ff.69|r%')
        tooltip:AddLine(' ')
        GameTooltip_AddErrorLine(tooltip, WoWTools_L.REQUIRES_RELOAD)
    end)
    WoWTools_MenuMixin:SetRightText(sub)


    local bitColor=  Save().notStatusPlusFunc and '|cff626262' or ''
    for i=-1, 4 do
        local tipSub= sub:CreateRadio(
            bitColor
            ..(i==-1 and (WoWTools_L.NONE)
             or ((WoWTools_L['Decimals '])..i)),
        function(data)
            return Save().itemLevelBit==data.bit
        end, function(data)
            Save().itemLevelBit= data.bit
            WoWTools_PaperDollMixin:UpdateStats()
            return MenuResponse.Refresh
        end, {bit=i})
        WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.PaperDoll.DecimalsCount'])
    end



    root:CreateDivider()
    local tipSub= root:CreateCheckbox(
        WoWTools_L.VAS_REALM_LABEL,
    function()
        return not Save().notRealm
    end, function()
        Save().notRealm= not Save().notRealm and true or nil
        WoWTools_PaperDollMixin:Init_Reaml()
    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.PaperDoll.Realm'])



    local tipSub= root:CreateCheckbox(
        WoWTools_L.LEVEL,
    function()
        return not Save().notLevel
    end, function()
        Save().notLevel= not Save().notLevel and true or nil
        WoWTools_PaperDollMixin:Init_SetLevel()

    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.PaperDoll.Level'])

    root:CreateDivider()
    sub=root:CreateCheckbox(
        WoWTools_L['Flyout'],
    function()
        return not Save().notFlyout
    end, function()
        Save().notFlyout= not Save().notFlyout and true or false
        WoWTools_PaperDollMixin:Init_EquipmentFlyout()
    end, {rightText=Save().flyoutScale or 1})
    WoWTools_MenuMixin:SetRightText(sub)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.PaperDoll.Flyout'])
        tooltip:AddLine('EquipmentFlyoutFrame')
    end)

    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return Save().flyoutScale or 1
    end, function(value)
        Save().flyoutScale= value
        WoWTools_PaperDollMixin:Init_EquipmentFlyout()
    end, function()
        Save().flyoutScale= nil
        WoWTools_PaperDollMixin:Init_EquipmentFlyout()
    end)

    sub=root:CreateCheckbox(
        'Tab',
    function()
        return not Save().notTabPlus
    end, function()
        Save().notTabPlus= not Save().notTabPlus and true or nil
        WoWTools_PaperDollMixin:Init_TabPlus()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.PaperDoll.Tabs'])
        tooltip:AddLine(WoWTools_L.PAPERDOLL_SIDEBAR_STATS)
        tooltip:AddLine(WoWTools_L.PAPERDOLL_SIDEBAR_TITLES)
        tooltip:AddLine(WoWTools_L.GEARSETS_TITLE)
    end)

    root:CreateDivider()
    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_PaperDollMixin.addName})

--reload
    WoWTools_MenuMixin:Reload(sub)
end


local function Init()
    local menu= CreateFrame('DropdownButton', 'WoWToolsPaperDollMenuButton', PaperDollFrame, 'WoWToolsMenuTemplate')
    menu:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT')
    menu:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)
    menu:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
    menu:SetupMenu(Init_Menu)


    WoWTools_PaperDollMixin:Init_EquipSetPlus()

    if WoWTools_PaperDollMixin.Init_Status then
        WoWTools_PaperDollMixin:Init_Status()
    end
    WoWTools_PaperDollMixin:Init_Status_Bit()

    WoWTools_PaperDollMixin:Init_Reaml()
    WoWTools_PaperDollMixin:Init_SetLevel()

    WoWTools_PaperDollMixin:Init_EquipmentFlyout()
    WoWTools_PaperDollMixin:Init_TabPlus()

    WoWTools_PaperDollMixin:Init_InspectUI()

    WoWTools_PaperDollMixin:Init_Item_PoaperDll()


    Init=function()end
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Plus_PaperDoll']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_PaperDoll'], {
                StatusPlus_OnEnter_show_menu=true,
                itemLevelBit= 1,
                itemSlotScale=1,

                EquipSet={
                    disabled= true,
                },

            })

            if not Save().EquipSet then
                Save().EquipSet= {
                    disabled= Save().equipment,
                    point= Save().Equipment,
                    toRight= Save().EquipmentH,
                    scale= Save().equipmentFrameScale,
                    strata= Save().trackButtonStrata,

                    itemLevel= Save().trackButtonShowItemLeve,
                    itemLevelScale= Save().trackButtonTextScale,
                }
                Save().equipment= nil
                Save().Equipment= nil
                Save().EquipmentH= nil
                Save().equipmentFrameScale=nil
                Save().trackButtonStrata= nil

                Save().trackButtonTextScale= nil
                Save().trackButtonShowItemLeve= nil
            end

            if WoWTools_DataMixin.Player.Ver>=120005 and Save().PAPERDOLL_STATCATEGORIES then
                Save().PAPERDOLL_STATCATEGORIES= nil
                Save().notStatusPlus=nil
            end

            WoWTools_PaperDollMixin.addName= (WoWTools_DataMixin.Player.Sex==Enum.UnitSex.Female and '|A:charactercreate-gendericon-female-selected:0:0|a' or '|A:charactercreate-gendericon-male-selected:0:0|a')
                                        ..(WoWTools_L.CHARACTER)

            WoWTools_PaperDollMixin.addName2= '|A:bags-icon-equipment:0:0|a'..(WoWTools_L.EQUIPMENT_MANAGER)

            --WoWTools_PaperDollMixin.addName3= '|A:loottoast-arrow-orange:0:0|a'..(STAT_CATEGORY_ATTRIBUTES)

            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_PaperDollMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    WoWTools_Print(
                        WoWTools_DataMixin.Icon.icon2..WoWTools_PaperDollMixin.addName,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_L.REQUIRES_RELOAD
                    )
                end,
                tooltip= WoWTools_L['Tip.PaperDoll.Module']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
            })

            if Save().disabled then
                self:SetScript('OnEvent', nil)
            else
                Init()
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                self:RegisterEvent('SOCKET_INFO_UPDATE')
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_PaperDollMixin:Init_EquipSetButton()

        self:UnregisterEvent(event)

    elseif event=='SOCKET_INFO_UPDATE' then
        if PaperDollItemsFrame:IsShown() then
            WoWTools_PaperDollMixin:UpdateStats()
        end
    end
end)