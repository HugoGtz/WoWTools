
WoWTools_BankMixin={}



local function Save()
    return WoWToolsPlusSave['Plus_Bank2']
end


local IsOpend
local function Init()
    WoWTools_BankMixin:Init_AllBank()
    WoWTools_BankMixin:Init_BankPlus()
    WoWTools_BankMixin:Init_BankMenu()
    WoWTools_BankMixin:Init_Out_Plus()
    WoWTools_BankMixin:Init_In_Plus()
    WoWTools_BankMixin:Init_Money_Plus()

    IsOpend=true
    Init=function()end
end



local function Init_Open_Menu()
    Menu.ModifyMenu("MENU_MINIMAP_TRACKING", function(self, root)
        if not self:IsMouseOver() then
            return
        end
        local sub= root:CreateCheckbox(
            (IsOpend and '' or '|cff606060')
            ..(WoWTools_L.BANK)
            ..WoWTools_DataMixin.Icon.icon2,
        function()
            return BankFrame and BankFrame:IsShown()
        end, function()
            if IsOpend then
                BankFrame:SetShown(not BankFrame:IsShown())
            end
        end)
        sub:SetTooltip(function(tooltip)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Bank.ShowBank'])
            tooltip:AddLine(
                WoWTools_DataMixin.Icon.icon2
                ..(WoWTools_L.SHOW)
                ..WoWTools_BankMixin.addName
            )
        end)
        sub:AddInitializer(function(button)
            local rightTexture = button:AttachTexture()
            rightTexture:SetSize(20, 20)
            rightTexture:SetPoint("RIGHT")
            rightTexture:SetAtlas('Banker')
            local fontString = button.fontString
            fontString:SetPoint("RIGHT", rightTexture, "LEFT")
        end)
    end)

    Init_Open_Menu=function()end
end





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Plus_Bank2']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Bank2'], {
                line=2,
                num=20,
                accountNum=10,--WoWTools_DataMixin.Player.husandro and 10 or 15,

                plusTab=true,
                plusIndex=true,
                plusItem=true,

                autoSaveMoney= WoWTools_DataMixin.Player.husandro and 500,--大于当前值，自动存放多余的金到银行去
                autoOutMoney= WoWTools_DataMixin.Player.husandro and 500,
                filterSaveMoney={},--[guid]=true
                allBank=WoWTools_DataMixin.Player.husandro,--整合银行

                saveWoWData=WoWTools_DataMixin.Player.husandro,
            })

            Save().filterSaveMoney=  Save().filterSaveMoney or {}
            WoWToolsPlusSave['Plus_Bank']= nil

            WoWTools_BankMixin.addName= '|A:Banker:0:0|a'..(WoWTools_L['Module.Bank'])

            if _G['ElvUI_BankContainerFrame'] then
                self:SetScript('OnEvent', nil)
                self:UnregisterEvent(event)
                return
            end

--添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_BankMixin.addName,
                GetValue=function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    if not Save().disabled then--al desactivar no instalar los hooks (hace falta /reload)
                        Init()
                    end
                end,
                tooltip= WoWTools_L['Tip.Bank.Option']..'|n|n|cnWARNING_FONT_COLOR:'..(WoWTools_L.RELOADUI)
            })

            if Save().disabled then
                self:SetScript('OnEvent', nil)
            else
                self:RegisterEvent('BANKFRAME_OPENED')
                Init_Open_Menu()
            end
            self:UnregisterEvent(event)
        end

    elseif event=='BANKFRAME_OPENED' then
        Init()
        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)


