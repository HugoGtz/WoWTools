WoWTools_UseItemsMixin={}

local P_Tabs={
    item={
        194885,
        40768,
        114943,
        168667,

        49040,
        144341,

        128353,
        167075,
        168222,
        184504, 184501, 184503, 184502, 184500, 64457,
        221966,
        198156,
        172924,
        168807,
        168808,
        151652,
        112059,
        87215,
        48933,
        30542,
        151016,
        136849, 52251,
        139590,
        87216,
        85500,
        37863,
        200613,
        253629,
    },
    spell={
        436854,
        83958,
        69046,
        50977,
        193753,
        556,
        18960,
        126892,
    },
    equip={
        65274,65360, 63206, 63207, 63352, 63353,
        103678,
        142469,
        144391, 144392,
    },
    flyout={
    },
}


local function Save()
    return WoWToolsPlusPlayerDate['Tools_UseItems']
end


function WoWTools_UseItemsMixin:Find_Type(type, ID)
    for index, ID2 in pairs(Save()[type] or {}) do
        if ID2==ID then
            return index
        end
    end
end



function WoWTools_UseItemsMixin:Init_Menu(root)
    local sub, sub2, num
    for text, type in pairs({
        [WoWTools_L.ITEMS]='item',
        [WoWTools_L.SPELLS]='spell',
        [WoWTools_L.EQUIPSET_EQUIP]='equip'
    }) do
        num= #Save()[type]

        sub=root:CreateButton(
            text,
        function(data)
            if data.type=='item' then
                WoWTools_LoadUIMixin:Journal(3)
            elseif data.type=='spell' then
                PlayerSpellsUtil.OpenToSpellBookTab()
            else
                WoWTools_LoadUIMixin:OpenPaperDoll(1, 1)
            end
            return MenuResponse.Open
        end, {type=type, rightText= num})
        WoWTools_MenuMixin:SetRightText(sub)


        for index, ID in pairs(Save()[type]) do
            local name= (type=='item' or type=='equip')
                and WoWTools_ItemMixin:GetName(ID)
                or WoWTools_SpellMixin:GetName(ID)
                or ID

            local isToy, spellID, itemID
            if type=='item' then
                isToy= C_ToyBox.GetToyInfo(ID)
                itemID=ID
                WoWTools_DataMixin:Load(itemID, 'item')

            elseif type=='equip' then
                itemID=ID
                WoWTools_DataMixin:Load(itemID, 'item')

            else
                spellID=ID
                WoWTools_DataMixin:Load(spellID, 'spell')
            end

            local isSpell= spellID and C_SpellBook.IsSpellInSpellBook(spellID)

            sub2=sub:CreateButton(
                (isSpell and '|cnWARNING_FONT_COLOR:' or '')
                ..name,
            function(data)
                if data.isToy then
                    WoWTools_LoadUIMixin:Journal(3, {toyItemID=data.itemID})
                elseif data.spellID and C_SpellBook.IsSpellInSpellBook(data.spellID) then
                    WoWTools_LoadUIMixin:SpellBook(3, data.spellID)
                else
                    StaticPopup_Show('WoWTools_OK',
                        (WoWTools_L.REMOVE)..'|n|n'..data.name..'|n',
                        nil,
                        {SetValue=function()
                            table.remove(Save()[data.type], data.index)
                        end}
                    )
                end
                return MenuResponse.Open
            end, {index=index, type=type, isToy=isToy, spellID=spellID, itemID=itemID, name=name, rightText=index, rightColor=DISABLED_FONT_COLOR})
--tooltip
            sub2:SetTooltip(function(tooltip, desc)
                WoWTools_SetTooltipMixin:Setup(tooltip, desc.data)
                WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.UseItems.Entry'])
            end)
            WoWTools_MenuMixin:SetRightText(sub2)
        end

        if num>0 then
            sub:CreateDivider()
        end

        if num>1 then
            WoWTools_MenuMixin:ClearAll(sub, function()
                Save()[type]={}
                WoWTools_Print(WoWTools_DataMixin.Icon.icon2..WoWTools_UseItemsMixin.addName, WoWTools_L.REQUIRES_RELOAD)
            end)
        end
        
        sub2=sub:CreateButton(
            (WoWTools_L.RESET),
        function(data)
            StaticPopup_Show('WoWTools_OK',
                (WoWTools_L.RESET)..'|n|n'..data.text..'|n',
                nil,
                {SetValue=function()
                   Save()[data.type]= P_Tabs[data.type]
                   WoWTools_Print(WoWTools_DataMixin.Icon.icon2..WoWTools_UseItemsMixin.addName, data.text, WoWTools_L.REQUIRES_RELOAD)
                end}
            )
        end, {type=type, text=text, rightText=#P_Tabs[type], rightColor=HIGHLIGHT_FONT_COLOR})
        WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.UseItems.ResetList'])

        WoWTools_MenuMixin:SetRightText(sub2)
        WoWTools_MenuMixin:SetScrollMode(sub)
    end

    root:CreateDivider()
    sub=WoWTools_ToolsMixin:OpenMenu(root, WoWTools_UseItemsMixin.addName)

    sub:CreateButton(
        WoWTools_L.RESET_ALL_BUTTON_TEXT,
    function()
        StaticPopup_Show('WoWTools_OK',
            (WoWTools_L.RESET_ALL_BUTTON_TEXT)..'|n|n'..(WoWTools_L['RELOADUI~3']),
            nil,
            {SetValue=function()
                WoWToolsPlusPlayerDate['Tools_UseItems']= nil
                WoWTools_DataMixin:Reload()
                WoWTools_Print(WoWTools_DataMixin.Icon.icon2..WoWTools_UseItemsMixin.addName, WoWTools_L.REQUIRES_RELOAD)
            end}
        )
    end)
    sub:CreateDivider()

    WoWTools_MenuMixin:Reload(sub)
end















local Init= WoWTools_Once(function()
    StaticPopupDialogs['WoWToolsUseItemsADD']={
        text= WoWTools_UseItemsMixin.addName..'|n|n%s: %s',
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1= WoWTools_L.ADD,
        button2= WoWTools_L.CANCEL,
        button3= WoWTools_L.REMOVE,
        OnShow = function(self, data)
            local find=WoWTools_UseItemsMixin:Find_Type(data.type, data.ID)
            data.index=find
            local b1= self.button1 or self:GetButton1()
            local b3= self:GetButton3()
            b1:SetEnabled(not find)
            b3:SetEnabled(find)
        end,
        OnAccept = function(_, data)
            table.insert(Save()[data.type], data.ID)
            WoWTools_Print(WoWTools_ToolsMixin.addName, WoWTools_UseItemsMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_L.ADD)..'|r', WoWTools_L.COMPLETE, data.name, WoWTools_L.REQUIRES_RELOAD)
        end,
        OnAlt = function(_, data)
            table.remove(Save()[data.type], data.index)
            WoWTools_Print(WoWTools_ToolsMixin.addName, WoWTools_UseItemsMixin.addName, '|cnWARNING_FONT_COLOR:'..(WoWTools_L.REMOVE)..'|r', WoWTools_L.COMPLETE, data.name, WoWTools_L.REQUIRES_RELOAD)
        end,
    }


    local btn=WoWTools_ButtonMixin:Cbtn(WoWTools_ToolsMixin:Get_MainButton().Frame, {
        atlas='Soulbinds_Tree_Conduit_Icon_Utility',
        size=22,
        name='WoWToolsToolsUseItemsAddMainButton'
    })
    btn:SetPoint('TOPLEFT', WoWTools_ToolsMixin:Get_MainButton(), 'TOPRIGHT')

    btn:SetScript('OnMouseDown',function(self, d)
        local infoType, itemID, itemLink ,spellID= GetCursorInfo()
        if infoType == "item" and itemID and itemLink then
            local itemEquipLoc= select(4, C_Item.GetItemInfoInstant(itemLink))
            local slot= WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)
            local type = slot and 'equip' or 'item'
            local text = slot and (WoWTools_L.EQUIPSET_EQUIP) or (WoWTools_L.ITEMS)
            local icon = select(5, C_Item.GetItemInfoInstant(itemLink))
            StaticPopup_Show('WoWToolsUseItemsADD', text , (icon and '|T'..icon..':0|t' or '')..itemLink, {type=type, name=itemLink, ID=itemID})
            ClearCursor()

        elseif infoType =='spell' and spellID then
            local spellLink=C_Spell.GetSpellLink(spellID) or ((WoWTools_L.SPELLS)..' ID: '..spellID)
            local icon=C_Spell.GetSpellTexture(spellID)
            StaticPopup_Show('WoWToolsUseItemsADD',  WoWTools_L.SPELLS , (icon and '|T'..icon..':0|t' or '')..spellLink, {type='spell', name=spellLink, ID=spellID})
            ClearCursor()

        else
            MenuUtil.CreateContextMenu(self, WoWTools_UseItemsMixin.Init_Menu)
        end
    end)
    btn:SetScript('OnEnter',function (self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_ToolsMixin.addName, WoWTools_UseItemsMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_L['Drag: add'])
        GameTooltip:AddLine('|cnGREEN_FONT_COLOR:'..(WoWTools_L.SPELLS..', '..WoWTools_L.ITEMS..', '..WoWTools_L.EQUIPSET_EQUIP))
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_L.SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
        self:SetAlpha(1.0)
    end)
    btn:SetScript('OnLeave', function (self)
        self:SetAlpha(0.3)
        GameTooltip:Hide()
    end)

    C_Timer.After(8, function()
        btn:SetAlpha(0.3)
    end)

    WoWTools_UseItemsMixin:Init_PlayerSpells()
    WoWTools_UseItemsMixin:Init_UI_Toy()
end)










WoWTools_Module:Register({
    key= 'Tools_UseItems', name= 'Module.Use items', icon= 'soulbinds_tree_conduit_icon_utility', group= 'Tools',
    parent= 'WoWTools_ToolsButton', tooltip= 'Tip.UseItems.Enable', mixin= WoWTools_UseItemsMixin,
    --siempre: su casilla en la página de Herramientas
    onLoad= function(M)
        WoWToolsPlusPlayerDate['Tools_UseItems']= WoWToolsPlusPlayerDate['Tools_UseItems'] or P_Tabs

        WoWTools_ToolsMixin:Set_AddList(function(category)
            WoWTools_PanelMixin:OnlyCheck({
            category= category,
            name= M.addName,
            tooltip= WoWTools_L['Tip.UseItems.Enable']..'|n|n'..M.addName..'|n'..(WoWTools_L.REQUIRES_RELOAD),
            GetValue= function() return not Save().disabled end,
            SetValue= function()
                Save().disabled= not Save().disabled and true or nil
            end})
        end)
    end,
    onEnable= function()
        if WoWTools_ToolsMixin:Get_MainButton() then
            WoWTools_ToolsMixin:OnEnterWorld(function()
                Init()
                WoWTools_UseItemsMixin:Init_All_Buttons()
            end)

            for _, ID in pairs(Save().item) do
               WoWTools_DataMixin:Load(ID, 'item')
            end
            for _, ID in pairs(Save().spell) do
               WoWTools_DataMixin:Load(ID, 'spell')
            end
            for _, ID in pairs(Save().equip) do
               WoWTools_DataMixin:Load(ID, 'item')
            end
        end
    end,
})

--Sus ajustes (incluido disabled) son por personaje: viven en WoWToolsPlusPlayerDate, no en WoWToolsPlusSave.
--Así M:Save()/M:IsEnabled() de la API miran la misma tabla que el resto del módulo.
function WoWTools_UseItemsMixin:Save()
    return Save() or {}
end
