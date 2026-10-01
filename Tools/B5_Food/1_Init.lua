
WoWTools_FoodMixin={}




local ClassSpells={--{item=5512, alt=nil, shift=nil, ctrl=nil}
    WARRIOR= {shift=6673},
    PALADIN= {},--qs
    HUNTER= {},--lr
    ROGUE= {},--dz
    PRIEST= {shift=21562,},
    DEATHKNIGHT= {},--dk
    SHAMAN= {shift=462854},
    MAGE= {item=113509, shift=1459, alt=190336},
    WARLOCK= {alt=29893, shift=698, ctrl=6201},
    MONK= {},--ws
    DRUID= {shift=1126},
    DEMONHUNTER= {},--dh
    EVOKER= {shift=364342},
}


local P_Save={
    noUseItems={},
    borderAlpha= 0,
    bgAlpha=0.5,
    olnyUsaItem=true,
    numLine=12,
    class={
        [0]={
            [1]=true,
            [2]=true,
            [3]=true,
            [5]=true,
            --[7]=false,
        },
        [15]={
            [4]=true,
        }
    },
    addItems={
        [113509]=true,
        [80610]=true,
        [65499]=true,
        [43523]=true,
        [43518]=true,
        [5512]=true,
    },
    DisableClassID={
        [1]=true,
        [3]=true,
        [5]=true,
        [6]=true,
        [7]=true,
        [8]=true,
        [9]=true,
        [10]=true,
        [11]=true,
        [12]=true,
        [13]=true,
        [14]=true,
        [16]=true,
        [18]=true,
        [17]=true,
        [19]=true,
        [20]=true,
    },
    spells=ClassSpells,
}



local PaneIDs={
    [113509]=1,
    [80610]=1,
    [65499]=1,
    [43523]=1,
    [43518]=1,
    [5512]=1,
}








function WoWTools_FoodMixin:Get_Item_Valid(itemID)
    local save= WoWTools_FoodMixin:Save()
    if itemID
        and itemID~= WoWTools_ToolsMixin:Get_ButtonForName('Food').itemID
        and not save.noUseItems[itemID]
        and (PaneIDs[itemID] or not save.addItems[itemID])
        and (save.olnyUsaItem and C_Item.GetItemSpell(itemID) or not save.olnyUsaItem)
    then
        local classID, subClassID, _, expacID = select(12, C_Item.GetItemInfo(itemID))
        if save.class[classID]
            and save.class[classID][subClassID]
            and (PlayerIsTimerunning()
                    or (save.onlyMaxExpansion
                        and (PaneIDs[itemID] or WoWTools_DataMixin.ExpansionLevel==expacID)
                        or not save.onlyMaxExpansion
                    )
                )
        then
            return classID, subClassID
        end
    end
end


















--Botón ya preparado (Init_Button): sus funciones set_* existen
local function Get_Button()
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('Food')
    if btn and btn.set_scale then
        return btn
    end
end

local function Check_Items()
    if Get_Button() then
        WoWTools_FoodMixin:Check_Items()
    end
end

--Filtro de búsqueda: mismo campo que su casilla del menú
local function Filter_Check(field, text, tooltip, off)
    return {type='check', key=field, text=text, tooltip=tooltip,
        get= function(save) return save[field] end,
        set= function(save, value) save[field]= value and true or off end,
        apply= Check_Items,
    }
end

local Options= {
    {type='section', text='GENERAL'},
    Filter_Check('olnyUsaItem', 'Usable only', 'Tip.Food.UsableOnly', false),
    {type='check', key='onlyMaxExpansion', text='Only current version items', tooltip='Tip.Food.OnlyCurrentExp',
        hidden= function() return PlayerIsTimerunning() end,
        get= function(save) return save.onlyMaxExpansion end,
        set= function(save, value) save.onlyMaxExpansion= value and true or nil end,
        apply= Check_Items,
    },
    {type='check', key='addItemsShowAll', text='Always show custom items', tooltip='Tip.Food.CustomShowAll',
        get= function(save) return save.addItemsShowAll end,
        set= function(save, value) save.addItemsShowAll= value and true or nil end,
        apply= Check_Items,
    },
    {type='button', key='lists', text='Categories and item lists', buttonText='EDIT', tooltip='Tip.Food.Lists',
        disabled= function() return not Get_Button() end,
        func= function()
            local btn= Get_Button()
            if btn and btn:CanChangeAttribute() then
                WoWTools_FoodMixin:Init_Menu(btn)
            end
        end,
    },
    {type='button', key='search', text='Search bags now', buttonText='SEARCH', tooltip='Tip.Food.Search', noCombat=true,
        disabled= function() return not Get_Button() end,
        func= function()
            if Get_Button() then
                WoWTools_FoodMixin:Check_Items(true)
            end
        end,
    },

    {type='section', text='Automations'},
    {type='check', key='autoLogin', text='On login: search', tooltip='Tip.Food.AutoLogin', automation=true,
        get= function(save) return save.autoLogin end,
        set= function(save, value) save.autoLogin= value and true or nil end,
        apply= function(_, save) if save.autoLogin then Check_Items() end end,
    },
    {type='check', key='autoWho', text='Search when bags change', tooltip='Tip.Food.AutoWho', automation=true,
        desc='High CPU',
        get= function(save) return save.autoWho end,
        set= function(save, value) save.autoWho= value and true or nil end,
        apply= function(_, save)
            local btn= Get_Button()
            if btn then
                if save.autoWho then
                    WoWTools_FoodMixin:Check_Items()
                end
                if btn.CheckFrame then
                    btn.CheckFrame:set_event()
                end
            end
        end,
    },

    {type='section', text='Appearance'},
    {type='slider', key='scale', text='HOUSING_EXPERT_DECOR_SUBMODE_SCALE', tooltip='Tip.Menu.Scale',
        min=0.4, max=4, step=0.05, format='%.2f', noCombat=true,
        get= function(save) return save.scale or 1 end,
        set= function(save, value) save.scale= value end,
        apply= function() local btn= Get_Button() if btn then btn:set_scale() end end,
    },
    {type='slider', key='bgAlpha', text='BACKGROUND+HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', tooltip='Tip.Menu.BgAlpha',
        min=0, max=1, step=0.1, format='%.1f',
        get= function(save) return save.bgAlpha or 0 end,
        set= function(save, value) save.bgAlpha= value end,
        apply= function() local btn= Get_Button() if btn then btn:set_background() end end,
    },
    {type='slider', key='borderAlpha', text='Border opacity', tooltip='Tip.Food.BorderAlpha',
        min=0, max=1, step=0.1, format='%.1f',
        get= function(save) return save.borderAlpha or 0 end,
        set= function(save, value) save.borderAlpha= value end,
        apply= Check_Items,
    },
    {type='slider', key='numLine', text='Buttons per row', tooltip='Tip.Food.NumLine',
        min=1, max=60, step=1,
        get= function(save) return save.numLine or 12 end,
        set= function(save, value) save.numLine= value end,
        apply= Check_Items,
    },
    {type='dropdown', key='strata', text='Strata', tooltip='Tip.Menu.Strata', noCombat=true,
        values= function() return WoWTools_ToolsMixin:StrataValues() end,
        get= function(save) return save.strata or 'MEDIUM' end,
        set= function(save, value) save.strata= value end,
        apply= function() local btn= Get_Button() if btn then btn:set_strata() end end,
    },
    {type='button', key='resetPoint', text='RESET_POSITION', buttonText='RESET', noCombat=true,
        tooltip='Tip.Food.ResetPoint',
        func= function(_, save)
            save.point=nil
            local btn= Get_Button()
            if btn and not WoWTools_FrameMixin:IsLocked(btn) then
                btn:set_point()
            end
        end,
    },
}


WoWTools_Module:Register({
    options= Options,
    key= 'Tools_Foods', name= 'Module.Food', icon= 'Food', group= 'Tools',
    parent= 'WoWTools_ToolsButton', defaults= P_Save, mixin= WoWTools_FoodMixin,
    onEnable= function(M, save)
        save.spells= save.spells or ClassSpells

        local class= save.spells[WoWTools_DataMixin.Player.Class]

        if not class then
            save.spells[WoWTools_DataMixin.Player.Class]= {}
        else
           WoWTools_DataMixin:Load(class.item, 'item')
           WoWTools_DataMixin:Load(class.alt, 'spell')
           WoWTools_DataMixin:Load(class.shift, 'spell')
           WoWTools_DataMixin:Load(class.ctrl, 'spell')
        end

        WoWTools_ToolsMixin:CreateButton({
            name='Food',
            tooltip=M.addName,
            isMoveButton=true,
        })

        if WoWTools_ToolsMixin:Get_ButtonForName('Food') then
            WoWTools_ToolsMixin:OnEnterWorld(function()
                M:Init_Button()
            end)
            M:Init_Button()

            if save.autoLogin or save.autoWho  then
                WoWTools_Module:RegisterEvent(M, 'BAG_UPDATE_DELAYED', function()
                    M:Check_Items()
                    return true
                end)
            end
        end
    end,
})
