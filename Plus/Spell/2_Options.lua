local function Save()
    return WoWToolsPlusSave['Plus_Spell']
end
local Layout




local function Init()
    if not C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_Settings' then
                Init()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
        return
    end



    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_L.ENABLE,
        tooltip= WoWTools_L['Tip.Spell.Enable'],
        GetValue= function() return not Save().disabled end,
        category= WoWTools_SpellMixin.Category,
        func= function()
            Save().disabled= not Save().disabled and true or nil
            WoWTools_Print(
                WoWTools_DataMixin.Icon.icon2..WoWTools_SpellMixin.addName,
                WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                WoWTools_L.REQUIRES_RELOAD
            )
        end
    })

    WoWTools_PanelMixin:Header(Layout, WoWTools_L['Extras'])

    WoWTools_PanelMixin:OnlyCheck({
        name= '|A:common-icon-backarrow:0:0|a'..(WoWTools_L['Spell flyout']),
        tooltip= WoWTools_L['Tip.Spell.Flyout'],
        GetValue= function() return Save().flyoutText end,
        category= WoWTools_SpellMixin.Category,
        SetValue= function()
            Save().flyoutText= not Save().flyoutText and true or false
            WoWTools_SpellMixin:Init_Spell_Flyout()
            if not Save().flyoutText then
                WoWTools_Print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(Save().flyoutText),
                    WoWTools_L.REQUIRES_RELOAD
                )
            end
        end
    })


    WoWTools_PanelMixin:OnlyCheck({
        name= '|A:UI-HUD-ActionBar-Interrupt:0:0|a'..(WoWTools_L['ACTIONBARS_LABEL+COLOR']),
        tooltip= WoWTools_L['Tip.Spell.RangeColor'],
        GetValue= function() return Save().actionButtonRangeColor end,
        category= WoWTools_SpellMixin.Category,
        SetValue= function()
            Save().actionButtonRangeColor= not Save().actionButtonRangeColor and true or false
            WoWTools_SpellMixin:Init_ActionButton_UpdateRange()
            if not Save().actionButtonRangeColor then
                WoWTools_Print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(Save().actionButtonRangeColor),
                    WoWTools_L.REQUIRES_RELOAD
                )
            end
        end
    })


    WoWTools_PanelMixin:OnlyCheck({
        name= '|A:talents-node-choiceflyout-circle-greenglow:0:0|a'..(WoWTools_L['Specialization button']),
        tooltip= WoWTools_L['Tip.Spell.SpecButton'],
        GetValue= function() return Save().specButton.enabled end,
        category= WoWTools_SpellMixin.Category,
        SetValue= function()
            Save().specButton.enabled= not Save().specButton.enabled and true or false
            WoWTools_SpellMixin:Init_Spec_Button()
            if not Save().specButton.enabled then
                WoWTools_Print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(Save().specButton.enabled),
                    WoWTools_L.REQUIRES_RELOAD
                )
            end
        end
    })


    WoWTools_PanelMixin:OnlyCheck({
        name= '|A:talents-button-undo:0:0|a'..(WoWTools_L.TALENT),
        tooltip= WoWTools_L['Tip.Spell.Talents'],
        GetValue= function() return Save().talentsFramePlus end,
        category= WoWTools_SpellMixin.Category,
        SetValue= function()
            Save().talentsFramePlus= not Save().talentsFramePlus and true or false
            WoWTools_SpellMixin:Init_TalentsFrame()
            if not Save().talentsFramePlus then
                WoWTools_Print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(Save().talentsFramePlus),
                    WoWTools_L.REQUIRES_RELOAD
                )
            end
        end
    })


    WoWTools_PanelMixin:OnlyCheck({
        name= '|A:spellbook-item-iconframe:0:0|a'..(WoWTools_L.SPELLBOOK),
        tooltip= WoWTools_L['Tip.Spell.SpellBook'],
        GetValue= function() return Save().spellBookPlus end,
        category= WoWTools_SpellMixin.Category,
        SetValue= function()
            Save().spellBookPlus= not Save().spellBookPlus and true or false
            WoWTools_SpellMixin:Init_SpellBookFrame()
            if not Save().spellBookPlus then
                WoWTools_Print(
                    WoWTools_DataMixin.Icon.icon2,
                    WoWTools_TextMixin:GetEnabeleDisable(Save().spellBookPlus),
                    WoWTools_L.REQUIRES_RELOAD
                )
            end
        end
    })


    Init=function()end
end


function WoWTools_SpellMixin:Init_Options()
    if not Layout then
        WoWTools_SpellMixin.Category, Layout= WoWTools_PanelMixin:AddSubCategory({
            name=WoWTools_SpellMixin.addName,
            disabled=Save().disabled
        })
    end

    Init()
end
