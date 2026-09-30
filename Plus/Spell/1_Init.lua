
local function Save()
    return WoWToolsPlusSave['Plus_Spell']
end





local function Init()
    if not C_AddOns.IsAddOnLoaded('Blizzard_PlayerSpells') then
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_PlayerSpells' then
                Init()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
        return
    end

    WoWTools_SpellMixin:Init_TalentsFrame()
    WoWTools_SpellMixin:Init_SpellBookFrame()
    WoWTools_SpellMixin:Init_Spec_Button()

    local reload= CreateFrame('Button', 'WoWToolsSpellBookReloadButton', PlayerSpellsFrame.TitleContainer, 'WoWToolsButtonTemplate')
    reload:SetPoint('LEFT', 28, -3)
    reload:SetNormalAtlas('common-icon-exit')
    reload.tooltip=WoWTools_DataMixin.Icon.icon2..(WoWTools_L['RELOADUI~2'])
    reload:SetScript('OnClick', function() WoWTools_DataMixin:Reload() end)
    WoWTools_TextureMixin:SetButton(reload, 0.5)


    Init=function()end
end









local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWToolsPlus' then

            WoWToolsPlusSave['Other_SpellFrame']=nil
            WoWToolsPlusSave['Other_SpellFlyout']=nil

            WoWToolsPlusSave['Plus_Spell']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Spell'], {
                specButton={
                scale= 1,
                --isToTOP=true
                --point={}
                --strata='MEDIUM'
                hideInCombat=true,
                enabled=true,
                },

                bg={
                    texture={},
                    show=true,
                    --icon='',
                },
                setUITexture=true,

                flyoutText=true,
                actionButtonRangeColor=true,

                spellBookPlus=true,
                talentsFramePlus=true,
            })


            if not Save().bg then
                Save().bg={texture={},show=true}
            end

            WoWTools_SpellMixin.addName= '|A:UI-HUD-MicroMenu-SpellbookAbilities-Mouseover:0:0|a'
                ..(WoWTools_L.SPELLS)

            if Save().disabled then
                self:SetScript('OnEvent', nil)
            else
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                Init()
            end
            self:UnregisterEvent(event)

        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_SpellMixin:Init_Options()
        WoWTools_SpellMixin:Init_Spec_Button()
        WoWTools_SpellMixin:Init_Spell_Flyout()
        WoWTools_SpellMixin:Init_ActionButton_UpdateRange()
        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)