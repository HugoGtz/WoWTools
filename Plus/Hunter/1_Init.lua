
if WoWTools_DataMixin.Player.Class~='HUNTER' then
    return
end

local P_Save={
    -- modelScale=0.65,

    --line=15,

    --10.2.7
    sortType='specialization',
    all_List_Size=28
}

local function Save()
    return WoWToolsPlusSave['Plus_StableFrame']
end

local function On_Show()
    WoWTools_HunterMixin:Init_StableFrame_Plus()
    WoWTools_HunterMixin:Init_Menu()
    WoWTools_HunterMixin:Set_StableFrame_List()
    WoWTools_HunterMixin:Init_UI()
    On_Show=function()end
end











local function Init()
    Menu.ModifyMenu("MENU_MINIMAP_TRACKING", function(self, root)
        if not self:IsMouseOver() then
            return
        end
        local sub= root:CreateCheckbox(
            WoWTools_L.STABLE_STABLED_PET_LIST_LABEL
            ..WoWTools_DataMixin.Icon.icon2,
        function()
            return StableFrame and StableFrame:IsShown()
        end, function()
            do
                if not StableFrame then
                    C_AddOns.LoadAddOn('Blizzard_StableUI')
                end
                if not UIPanelWindows['StableFrame'] then
                    WoWTools_DataMixin:Call('StableFrame', 'OnLoad', StableFrame)
                end
                On_Show()
            end
            StableFrame:SetShown(not StableFrame:IsShown())
        end)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(
                WoWTools_DataMixin.Icon.icon2
                ..(WoWTools_L.SHOW)
                ..WoWTools_HunterMixin.addName
            )
        end)
        sub:AddInitializer(function(button)
            local rightTexture = button:AttachTexture()
            rightTexture:SetSize(20, 20)
            rightTexture:SetPoint("RIGHT")
            rightTexture:SetAtlas('tenacity-icon-small')
            local fontString = button.fontString
            fontString:SetPoint("RIGHT", rightTexture, "LEFT")
        end)
    end)


    Init=function()end
end

local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Plus_StableFrame']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_StableFrame'], P_Save)
            P_Save= nil

            WoWTools_HunterMixin.addName= '|A:groupfinder-icon-class-hunter:0:0|a'..(WoWTools_L['Module.Hunter stable'])

                WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_HunterMixin.addName,
                tooltip= WoWTools_L['Tip.Hunter.Enable'],
                GetValue=function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled = not Save().disabled and true or nil
                    WoWTools_Print(
                        WoWTools_HunterMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_L['REQUIRES_RELOAD~2']
                    )
                end
            })

            if not Save().disabled then
                self:RegisterEvent('PET_STABLE_SHOW')
                Init()
            else
                self:SetScript('OnEvent', nil)
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PET_STABLE_SHOW' then
        On_Show()
        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)