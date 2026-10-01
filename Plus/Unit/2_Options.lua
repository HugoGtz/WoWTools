local Category, Layout



local function Init_Category()
    Category, Layout= WoWTools_PanelMixin:AddSubCategory({
        name=WoWTools_UnitMixin.addName,
        disabled=WoWTools_UnitMixin:Save().disabled
    })

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L.ENABLE,
        tooltip= WoWTools_L['Tip.Unit.Module']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
        GetValue= function() return not WoWTools_UnitMixin:Save().disabled end,
        func= function()
            WoWTools_UnitMixin:Save().disabled= not WoWTools_UnitMixin:Save().disabled and true or nil
            WoWTools_Print(
                WoWTools_DataMixin.Icon.icon2..WoWTools_UnitMixin.addName,
                WoWTools_TextMixin:GetEnabeleDisable(not WoWTools_UnitMixin:Save().disabled),
                WoWTools_L.REQUIRES_RELOAD
            )
            if not WoWTools_UnitMixin:Save().disabled then
                WoWTools_UnitMixin:Init_Options()
            end
        end,
        category= Category,
    })

    Init_Category= function()end
end


local function Init()
    if not C_AddOns.IsAddOnLoaded('Blizzard_Settings') or WoWTools_UnitMixin:Save().disabled then
        return
    end

    WoWTools_PanelMixin:Header(Layout, WoWTools_L['Frames to enhance'])


    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L.HUD_EDIT_MODE_PLAYER_FRAME_LABEL,
        tooltip= WoWTools_L['Tip.Unit.PlayerFrame']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
        GetValue= function() return not WoWTools_UnitMixin:Save().hidePlayerFrame end,
        func= function()
            WoWTools_UnitMixin:Save().hidePlayerFrame= not WoWTools_UnitMixin:Save().hidePlayerFrame and true or nil
            if WoWTools_UnitMixin:Save().hidePlayerFrame then
                WoWTools_Print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(false),
                    WoWTools_L.REQUIRES_RELOAD
                )
            else
                WoWTools_UnitMixin:Init_PlayerFrame()
            end
        end,
        category= Category,
    })



    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L.HUD_EDIT_MODE_TARGET_FRAME_LABEL,
        tooltip= WoWTools_L['Tip.Unit.TargetFrame']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
        GetValue= function() return not WoWTools_UnitMixin:Save().hideTargetFrame end,
        func= function()
            WoWTools_UnitMixin:Save().hideTargetFrame= not WoWTools_UnitMixin:Save().hideTargetFrame and true or nil
            if WoWTools_UnitMixin:Save().hideTargetFrame then
                WoWTools_Print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(false),
                    WoWTools_L.REQUIRES_RELOAD
                )
            else
                WoWTools_UnitMixin:Init_TargetFrame()
            end
        end,
        category= Category,
    })


    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L.HUD_EDIT_MODE_PARTY_FRAMES_LABEL,
        tooltip= WoWTools_L['Tip.Unit.PartyFrame']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
        GetValue= function() return not WoWTools_UnitMixin:Save().hidePartyFrame end,
        func= function()
            WoWTools_UnitMixin:Save().hidePartyFrame= not WoWTools_UnitMixin:Save().hidePartyFrame and true or nil
            if WoWTools_UnitMixin:Save().hidePartyFrame then
                WoWTools_Print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(false),
                    WoWTools_L.REQUIRES_RELOAD
                )
            else
                WoWTools_UnitMixin:Init_PartyFrame()--antes llamaba también a Init_PartyFrame_Compact, que no existe (error)
            end
        end,
        category= Category,
    })


    WoWTools_PanelMixin:OnlyCheck({
        name= (WoWTools_L.HUD_EDIT_MODE_BOSS_FRAMES_LABEL),
        tooltip= WoWTools_L['Tip.Unit.BossFrame']..'|n|n'..WoWTools_L.REQUIRES_RELOAD,
        GetValue= function() return not WoWTools_UnitMixin:Save().hideBossFrame end,
        SetValue= function()
            WoWTools_UnitMixin:Save().hideBossFrame= not WoWTools_UnitMixin:Save().hideBossFrame and true or nil
            if WoWTools_UnitMixin:Save().hideBossFrame then
                WoWTools_Print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(false),
                    WoWTools_L.REQUIRES_RELOAD
                )
            else
                WoWTools_UnitMixin:Init_BossFrame()
            end
        end,
        category= Category,
    })




    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L['CLASS+EMBLEM_SYMBOL'],
        tooltip=WoWTools_L['Tip.Unit.ClassTexture']..'|n|n'..WoWTools_L['Color, icon'] ,
        GetValue= function() return not WoWTools_UnitMixin:Save().hideClassColor end,
        func= function()
            WoWTools_UnitMixin:Save().hideClassColor= not WoWTools_UnitMixin:Save().hideClassColor and true or nil
            if WoWTools_UnitMixin:Save().hideClassColor then
                WoWTools_Print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(false),
                    WoWTools_L.REQUIRES_RELOAD
                )
            else
                WoWTools_UnitMixin:Init_ClassTexture()
            end
        end,
        category= Category,
    })




   Init=function()end
end

function WoWTools_UnitMixin:Init_Options()
    Init_Category()
    Init()
end