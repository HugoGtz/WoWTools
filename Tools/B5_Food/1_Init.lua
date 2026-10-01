
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


















WoWTools_Module:Register({
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
            option=function(category, layout, initializer)
                WoWTools_PanelMixin:OnlyButton({
                    category=category,
                    layout=layout,
                    tooltip=M.addName,
                    buttonText= WoWTools_L['RESET_POSITION~2'],
                    SetValue= function()
                        local btn= WoWTools_ToolsMixin:Get_ButtonForName('Food')
                        M:Save().point=nil
                        if btn and not WoWTools_FrameMixin:IsLocked(btn) then
                            btn:set_point()
                        end
                    end
                }, initializer)
            end
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
