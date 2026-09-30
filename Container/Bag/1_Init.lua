
local function Save()
    return WoWToolsPlusSave['Plus_Container'] or {}
end






local function Init()
    WoWTools_DataMixin:CreateWoWItemListButton(ContainerFrameCombinedBags.CloseButton, {
        name='WoWToolsCombinedBagsWoWButton',
        type='Item',
        point=function(btn)
            btn:SetPoint('RIGHT', ContainerFrameCombinedBags.CloseButton, 'LEFT')
        end
    })

    WoWTools_BagMixin:Init_Container_Menu()--背包，菜单，增强
    WoWTools_BagMixin:Init_DeleteItem()

    Init=function()end
end






local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            if _G['ElvUI_ContainerFrame'] then
                self:UnregisterEvent(event)
                return
            end

            WoWToolsPlusSave['Plus_Container']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Container'], {
                delete={item={}},
                cvar={SortBagsRightToLeft=true},
            })

            Save().delete= Save().delete or {item={}}
            Save().cvar= Save().cvar or {}

            WoWTools_BagMixin.addName= '|A:bag-main:0:0|a'..(WoWTools_L['Module.Bags'])

--添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_BagMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil

                    if Save().disabled then
                        WoWTools_Print(
                            WoWTools_BagMixin.addName..WoWTools_DataMixin.Icon.icon2,
                            WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                            WoWTools_L.REQUIRES_RELOAD
                        )
                    else
                         Init()
                    end
                end,
                tooltip= WoWTools_L['Tip.Bag.Option'],
                layout= WoWTools_OtherMixin.Layout,
                category= WoWTools_OtherMixin.Category,
            })

            if not Save().disabled then
                self:RegisterEvent("PLAYER_ENTERING_WORLD")
            else
                self:SetScript('OnEvent', nil)
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        Init()
        self:UnregisterEvent(event)
    end
end)