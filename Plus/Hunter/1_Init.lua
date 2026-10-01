
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

local On_Show= WoWTools_Once(function()
    WoWTools_HunterMixin:Init_StableFrame_Plus()
    WoWTools_HunterMixin:Init_Menu()
    WoWTools_HunterMixin:Set_StableFrame_List()
    WoWTools_HunterMixin:Init_UI()
end)











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
end

WoWTools_Module:Register({
    key= 'Plus_StableFrame', name= 'Module.Hunter stable', icon= 'groupfinder-icon-class-hunter', group= 'Character',
    defaults= P_Save, tooltip= 'Tip.Hunter.Enable', mixin= WoWTools_HunterMixin,
    onEnable= Init,
    options= function()
        local function Refresh_List()
            if _G['WoWToolsHunterPlusMenuButton'] then--el establo ya se abrió
                WoWTools_HunterMixin:Set_StableFrame_List()
            end
        end
        local function NoList(save)
            return not save.show_All_List
        end
        return {
            {type='section', text='GENERAL'},
            {type='check', key='show_All_List', text='Show all pets list', tooltip='Tip.Hunter.AllList',
                get= function(save) return save.show_All_List end,
                set= function(save, value) save.show_All_List= value and true or nil end,
                apply= Refresh_List},
            {type='check', key='sortDown', text='PERKS_PROGRAM_ASCENDING', tooltip='Tip.Hunter.SortAscending', indent=true,
                disabled= NoList,
                get= function(save) return not save.sortDown end,
                set= function(save, value) save.sortDown= not value and true or nil end},
            {type='check', key='HideTips', text='HUD_EDIT_MODE_HUD_TOOLTIP_LABEL', tooltip='Tip.Hunter.Tooltips',
                get= function(save) return not save.HideTips end,
                set= function(save, value) save.HideTips= not value and true or nil end},

            {type='section', text='Appearance'},
            {type='slider', key='all_List_Size', text='HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE', min=8, max=72, step=1,
                disabled= NoList,
                get= function(save) return save.all_List_Size or 28 end,
                set= function(save, value) save.all_List_Size= value end,
                apply= function()
                    local frame= _G['WoWTools_StableFrameAllList']
                    if frame then
                        frame:Settings()
                    end
                end},
        }
    end,
    events= {PET_STABLE_SHOW= function()
        On_Show()
        return true
    end},
})
