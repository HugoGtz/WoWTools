

WoWTools_OpenItemMixin={}

local P_Save={
    use={
        [190198]=5,
        [201791]=1,
        [198969]=1,

        [198790]=1,
        [201781]=1,
        [201783]=1,
        [201779]=1,

        [201922]=1,
        [200287]=1,
        [202092]=1,
        [200453]=1,

        [201924]=1,
        [202093]=1,
        [200455]=1,
        [200289]=1,

        [201923]=1,
        [200288]=1,
        [202094]=1,
        [200454]=1,


        [200285]=1,
        [201921]=1,
        [200452]=1,
        [202091]=1,
        [201782]=1,


        [204573]=1,
        [204574]=1,
        [204575]=1,
        [204576]=1,
        [204577]=1,
        [204578]=1,
        [204579]=1,

        [204075]=15,
        [204076]=15,
        [204077]=15,
        [204717]=2,
        [190328]=10,
        [190322]=10,

        --10.2
        [208396]=2,
        --10.2.7
        [87779]=1,

        --11
        [229899]=100,
        [224025]=10,
        [219191]=15,


    },
    no={
        [64402]=true,
        [6948]=true,
        [23247]=true,
        [168416]=true,
        [109076]=true,
        [132119]=true,
        [193902]=true,
        [37863]=true,

        [139590]=true,
        [163604]=true,
        [199900]=true,
        [198083]=true,
        [191294]=true,
        [202087]=true,
        [128353]=true,
        [86143]=true,--pet
        [5512]=true,
        [92675]=true,
        [92741]=true,

        [102464]=true,
        [94233]=true,

        --10.0
        [194510]=true,
        [199197]=true,
        [200613]=true,
        [18149]=true,
        [194701]=true,
        [192749]=true,

        [204439]=true,
        [194743]=true,
        [194730]=true,
        [194519]=true,
        [202620]=true,
        [191529]=true,
        [191526]=true,
        [193915]=true,
        [190320]=true,

        --10.1
        [203708]=true,
        [205982]=true,
        [207057]=true,
        --10.2
        [208066]=true,
        [208067]=true,
        [208047]=true,
        [210014]=true,
        [190324]=true,

        --10.2.7
        [217956]=true,
        [217608]=true,
        [217607]=true,
        [217606]=true,
        [217605]=true,
        [217930]=true,
        [217929]=true,
        [217928]=true,

        [217731]=true,
        [217730]=true,
        [217901]=true,

        [89770]=true,
        [219940]=true,
        [95350]=true,

        --11
        [224185]=true

    },
    pet=true,
    open=true,
    toy=true,
    mount=true,
    mago=true,
    ski=true,
    alt=true,
    --noItemHide= true,--true,
}




if WoWTools_DataMixin.Player.Class=='ROGUE' then
   WoWTools_DataMixin:Load(1804, 'spell')
end
















--Qué tipos de objeto usa el botón (mismos campos y textos que su menú)
local function Type_Check(field, text, tooltip)
    return {type='check', key=field, text=text, tooltip=tooltip,
        get= function(save) return save[field] end,
        set= function(save, value) save[field]= value and true or false end,
        apply= function() WoWTools_OpenItemMixin:Get_Item() end,
    }
end

local function Get_Button()
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('OpenItems')
    if btn and btn.settings then
        return btn
    end
end

local Options= {
    {type='section', text='GENERAL'},
    Type_Check('open', 'Openable items', 'Tip.OpenItems.Open'),
    Type_Check('mount', 'Unlearned mounts', 'Tip.OpenItems.Mount'),
    Type_Check('mago', 'Uncollected appearances', 'Tip.OpenItems.Transmog'),
    Type_Check('ski', 'Learnable recipes', 'Tip.OpenItems.Recipe'),
    Type_Check('alt', 'Other usable items', 'Tip.OpenItems.Other'),
    Type_Check('reagent', 'Also check the reagent bag', 'Tip.OpenItems.Reagent'),
    WoWTools_ToolsMixin:KeyOption({tooltip='Tip.OpenItems.Key', apply= function()
        local btn= Get_Button()
        if btn then
            btn:settings()
        end
    end}),

    {type='section', text='Item lists'},
    {type='button', key='lists', text='Item lists', buttonText='EDIT', tooltip='Tip.OpenItems.Lists',
        disabled= function() return not Get_Button() end,
        func= function() WoWTools_OpenItemMixin:Setup_Menu() end,
    },
    {type='button', key='clearNo', text='Clear disabled items', buttonText='CLEAR_ALL', confirm=true,
        tooltip='Tip.OpenItems.NoList',
        func= function(_, save)
            save.no= {}
            WoWTools_OpenItemMixin:Get_Item()
        end,
    },
    {type='button', key='clearUse', text='Clear always-use items', buttonText='CLEAR_ALL', confirm=true,
        tooltip='Tip.OpenItems.UseList',
        func= function(_, save)
            save.use= {}
            WoWTools_OpenItemMixin:Get_Item()
        end,
    },
}


WoWTools_Module:Register({
    options= Options,
    key= 'Tools_OpenItems', name= 'Module.Open items', icon= 'BonusLoot-Chest', group= 'Tools',
    parent= 'WoWTools_ToolsButton', defaults= P_Save, mixin= WoWTools_OpenItemMixin,
    onEnable= function(M)
        WoWTools_ToolsMixin:CreateButton({
            name='OpenItems',
            tooltip=M.addName,
        })

        if WoWTools_ToolsMixin:Get_ButtonForName('OpenItems') then
            WoWTools_ToolsMixin:OnEnterWorld(function()
                M:Init_Button()
            end)
        end
    end,
})
