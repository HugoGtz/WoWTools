local function Save()
    return WoWToolsPlusSave['Tools_Mounts']
end
local function SaveLog()
    return WoWToolsPlusPlayerDate['Tools_Mounts']
end










local function Set_Menu_Index(root)
    root:AddInitializer(function(btn, desc)
        local index= desc.data.index
        local num= desc.data.num
        if not num and not index then
            return
        end

        local font = btn:AttachFontString()
        local offset = desc:HasElements() and -20 or 0
        font:SetPoint("RIGHT", offset, 0)
        font:SetJustifyH("RIGHT")
        font:SetTextToFit(num or index)

        if num then
            if (desc.data.spellID and not C_Spell.DoesSpellExist(desc.data.spellID))
                or (desc.data.itemID and C_Item.GetItemCount(desc.data.itemID, false, false, false, false)==0)
            then
                font:SetTextColor(WARNING_FONT_COLOR:GetRGB())
            elseif num==0 then
                font:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
            else
                font:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
            end
        else
            font:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
        end
    end)
end




local TypeTips={
    Ground='Tip.Mount.Ground',
    Aquatic='Tip.Mount.Aquatic',
    Flying='Tip.Mount.Flying',
    Dragonriding='Tip.Mount.Dragonriding',
    Alt='Tip.Mount.Modifier',
    Ctrl='Tip.Mount.Modifier',
    Shift='Tip.Mount.Modifier',
    Floor='Tip.Mount.Floor',
    Spell='Tip.Mount.Spell',
    Item='Tip.Mount.Item',
}

local function Set_Menu_Tooltip(tooltip, desc)
    local mountType= desc.data.type
    local mountID= desc.data.mountID
    local spellID= desc.data.spellID
    local itemID= desc.data.itemID

    if not desc.data.index and TypeTips[mountType] then
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L[TypeTips[mountType]])
    end

    if mountID then
        local isUsable, useError = C_MountJournal.GetMountUsabilityByID(mountID, true)
        if useError then
            GameTooltip_AddErrorLine(tooltip, WoWTools_TextMixin:CN(useError))
        elseif isUsable then
            GameTooltip_AddNormalLine(tooltip, WoWTools_DataMixin.Icon.left..(WoWTools_L.SUMMON))
        end
    elseif spellID then
        tooltip:SetSpellByID(spellID)
    elseif itemID then
        tooltip:SetItemByID(itemID)
    end

    if mountType=='Floor' then
        for uiMapID in pairs(SaveLog().Floor[spellID] or {}) do
            local mapInfo = C_Map.GetMapInfo(uiMapID)
            tooltip:AddDoubleLine(uiMapID, mapInfo and WoWTools_TextMixin:CN(mapInfo.name))
        end
    end
end







local function ClearAll_Menu(root, mountType)

    root:CreateDivider()

    local name= WoWTools_L.CLEAR_ALL

    root:CreateButton(
        name,
    function()
        StaticPopup_Show('WoWTools_OK',
        name..'\n\n'..(WoWTools_MountMixin.TypeName[mountType] or mountType),
        nil,
        {SetValue=function()
           WoWToolsPlusPlayerDate['Tools_Mounts'][mountType]={}

            WoWTools_ToolsMixin:Get_ButtonForName('Mount'):settings()
            WoWTools_Print(
                WoWTools_MountMixin.addName..WoWTools_DataMixin.Icon.icon2,
                name,
                (WoWTools_MountMixin.TypeName[mountType] or mountType)
            )
        end})
        return MenuResponse.Open
    end)

    WoWTools_MenuMixin:SetScrollMode(root)
end















local function Set_Mount_Sub_Options(root, data)--icon,col,mountID,spellID,itemID
    local icon= data.icon or ''
    local col= data.col or ''
    local id= data.itemID or data.spellID
    local mountID= data.mountID
    local mountType= data.type
    local sub

    if mountID then
        root:CreateButton(
            icon..col..(WoWTools_L.SUMMON),
        function()
            C_MountJournal.SummonByID(mountID)
            return MenuResponse.Refresh
        end)
        root:CreateDivider()
    end


    root:CreateButton(
        (mountID and '|A:QuestLegendary:0:0|a' or icon)
        ..(WoWTools_L.EDIT)
        ..(mountID and '' or WoWTools_DataMixin.Icon.left),
    function()
        WoWTools_MountMixin:Set_Item_Spell_Edit(data)
        return MenuResponse.Open
    end)

    if mountID then
        WoWTools_MenuMixin:OpenJournal(root, {
            name=WoWTools_L.SETTINGS,
            index=1,
            moutID=mountID,
        })
    else
        WoWTools_MenuMixin:OpenSpellBook(root)
    end

    root:CreateDivider()
    sub= root:CreateCheckbox(
        WoWTools_L.SETTINGS,
    function()
        return SaveLog()[mountType][id]
    end, function()
        SaveLog()[mountType][id]= not SaveLog()[mountType][id] and true or nil
        WoWTools_ToolsMixin:Get_ButtonForName('Mount'):settings()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Mount.InList'])
        tooltip:AddLine(WoWTools_L['Add/Remove'])
    end)
end








local function Set_Mount_Menu(root, mountType, spellID, num, index)
    local mountID= spellID and C_MountJournal.GetMountFromSpell(spellID)

    local sub, icon, isUsable, _, isCollected, col, name, mountName
    if mountID then
        mountName, _, icon, _, isUsable, _, _, _, _, _, isCollected =C_MountJournal.GetMountInfoByID(mountID)
        if not isCollected then
            col= '|cff626262'
        elseif not isUsable then
            col= '|cnWARNING_FONT_COLOR:'
        end
    end
    col= col or ''

    icon= '|T'..(icon or (spellID and C_Spell.GetSpellTexture(spellID)) or 0)..':0|t'

    if index then
        if mountName then
            name= icon..WoWTools_TextMixin:CN(mountName)
        elseif spellID then
            name= WoWTools_SpellMixin:GetName(spellID)
        end
    end

    name= name or (icon..(WoWTools_MountMixin.TypeName[mountType] or mountType))

    sub=root:CreateButton(
        col..name,
        function(d)
            C_MountJournal.SummonByID(d.mountID or 0)
            return MenuResponse.Refresh
        end,
        {spellID=spellID, mountID=mountID, type=mountType, num=num, index=index}
    )

    sub:SetTooltip(Set_Menu_Tooltip)
    Set_Menu_Index(sub)

    if index then
        Set_Mount_Sub_Options(sub, {
            icon=icon,
            col=col,
            mountID=mountID,
            spellID=spellID,
            type=mountType,
        })
    end

    return sub
end
















local function Init_Menu_Mount(root, mountType)
    local tab2= WoWTools_MountMixin:Get_MountTab(mountType)

    WoWTools_DataMixin:Load(tab2[1], 'spell')

    local sub= Set_Mount_Menu(
        root,
        mountType,
        tab2[1],
        WoWTools_MountMixin:Get_Table_Num(mountType),
        nil
    )


    local index=0
    for spellID in pairs(SaveLog()[mountType] or {}) do

        WoWTools_DataMixin:Load(spellID, 'spell')

        index= index +1
        Set_Mount_Menu(
            sub,
            mountType,
            spellID,
            nil,
            index
        )
    end

    ClearAll_Menu(sub, mountType)
end









local function Init_Menu_ShiftAltCtrl(root, mountType)
    local tab2=WoWTools_MountMixin:Get_MountTab(mountType) or {}
    WoWTools_DataMixin:Load(tab2[1], 'spell')

    local sub= Set_Mount_Menu(
        root,
        mountType,
        tab2[1],
        WoWTools_MountMixin:Get_Table_Num(mountType),
        nil
    )

    sub:CreateTitle(
        WoWTools_L['Only 1 spell']
    )

    local index=0
    for spellID in pairs(SaveLog()[mountType] or {}) do
       WoWTools_DataMixin:Load(spellID, 'spell')
        index= index +1
        Set_Mount_Menu(sub, mountType, spellID, nil, index)
    end

    ClearAll_Menu(sub, mountType)
    return sub, index
end















local function Init_Menu_Spell(_, sub)
    local sub2, icon, col
    local index=0
    for spellID in pairs(SaveLog().Spell or {}) do
        WoWTools_DataMixin:Load(spellID, 'spell')
        index= index+1

        icon='|T'..(C_Spell.GetSpellTexture(spellID) or 0)..':0|t'

        sub2=sub:CreateButton(
            WoWTools_SpellMixin:GetName(spellID),
        function(data)
            WoWTools_MountMixin:Set_Item_Spell_Edit(data)
            return MenuResponse.Open
        end, {spellID=spellID, type='Spell', index=index})

        sub2:SetTooltip(Set_Menu_Tooltip)
        Set_Menu_Index(sub2)

        Set_Mount_Sub_Options(sub2, {
            icon=icon,
            col=col,
            type='Spell',
            mountID=nil,
            spellID=spellID,
            itemID=nil,
        })

    end

    ClearAll_Menu(sub, 'Spell')

    sub2=sub:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_L.RESET),
    function()
        StaticPopup_Show('WoWTools_OK',
            (WoWTools_L.SPELLS)
            ..'|n|n'
            ..(WoWTools_L.RESET),
        nil,
        {SetValue=function()
            SaveLog().Spell= WoWTools_MountMixin:P_Mouts_Tab().Spell or {}
            WoWTools_ToolsMixin:Get_ButtonForName('Mount'):settings()
        end})
        return MenuResponse.Open
    end)
end













local function Init_Menu_Item(_, sub)
    local sub2, icon
    local index= 0
    for itemID in pairs(SaveLog().Item or {}) do
       WoWTools_DataMixin:Load(itemID, 'item')

        index= index+1

        icon='|T'..(select(5, C_Item.GetItemInfoInstant(itemID)) or 0)..':0|t'

        local name= WoWTools_ItemMixin:GetName(itemID)

        sub2=sub:CreateButton(
            name,
        function(data)
            WoWTools_MountMixin:Set_Item_Spell_Edit(data)
            return MenuResponse.Open
        end,{itemID=itemID, name=name, type='Item', index=index})

        sub2:SetTooltip(Set_Menu_Tooltip)
        Set_Menu_Index(sub2)

        Set_Mount_Sub_Options(sub2, {
            icon=icon,
            col=nil,
            type='Item',
            mountID=nil,
            spellID=nil,
            itemID=itemID,
        })
    end

    ClearAll_Menu(sub, 'Item')

    sub2=sub:CreateTitle(
        WoWTools_L['DRAG_MODEL+ITEMS']
    )
    sub2:SetTooltip(function (tooltip)
        tooltip:AddDoubleLine(WoWTools_L.ADD)
    end)
end









local function Init_Menu(self, root)
    local sub, sub2, sub3, num

    for _, mountType in pairs({
        'Ground',
        'Aquatic',
        'Flying',
        'Dragonriding',
        '-',
        'Alt',
        'Ctrl',
        'Shift',
        '-',
        'Floor',
        --'-',
        'Spell',
        'Item',
    }) do

        num= nil
        if mountType=='-' then
            root:CreateDivider()

        elseif mountType=='Spell' or mountType=='Item' then

            local icon
            local itemID, spellID
            if mountType=='Spell' then
                if self.spellID then
                    spellID= self.spellID
                    WoWTools_DataMixin:Load(spellID, 'spell')

                    icon= C_Spell.GetSpellTexture(spellID)
                end
            elseif mountType=='Item' then
                if self.itemID then
                    WoWTools_DataMixin:Load(self.itemID, 'item')
                    itemID=self.itemID
                    icon=select(5, C_Item.GetItemInfoInstant(self.itemID))
                end
            end

            icon= icon or 0
            num= WoWTools_MountMixin:Get_Table_Num(mountType)

            local name= WoWTools_MountMixin.TypeName[mountType] or mountType

            if itemID then
                name= WoWTools_ItemMixin:GetColor(nil, {itemID=itemID, text=name})
            elseif spellID then
                name= '|cff3fc7eb'..name..'|r'
            else
                name= HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(name)
            end

            sub=root:CreateButton(
                '|T'..icon..':0|t'
                ..name,
            function()
                return MenuResponse.Open
            end, {itemID=itemID, spellID=spellID, type=mountType, num=num})

            sub:SetTooltip(Set_Menu_Tooltip)
            Set_Menu_Index(sub)

            if mountType=='Spell' then
                Init_Menu_Spell(self, sub)
            else
                Init_Menu_Item(self, sub)
            end

            Set_Menu_Index(sub)


        elseif mountType=='Shift' or mountType=='Alt' or mountType=='Ctrl' then
            Init_Menu_ShiftAltCtrl(root, mountType)

        else
            Init_Menu_Mount(root, mountType)
        end
    end

    root:CreateDivider()
    sub=root:CreateButton(
        '|T413588:0|t'
        ..(Save().KEY or (WoWTools_L.MOUNT)),
    function()
        C_MountJournal.SummonByID(0)
        return MenuResponse.Refresh
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_L['Summon random favorite mount'], nil,nil,nil)
    end)

    sub:CreateSpacer()
    WoWTools_KeyMixin:SetMenu(self, sub, {
        icon='|A:NPE_ArrowDown:0:0|a',
        name= WoWTools_MountMixin.addName,
        key=Save().KEY,
        GetKey=function(key)
            Save().KEY=key
            WoWTools_KeyMixin:Setup(self)
        end,
        OnAlt=function()
            Save().KEY=nil
            WoWTools_KeyMixin:Setup(self)
        end,
    })

    WoWTools_MenuMixin:RestData(sub,
        WoWTools_MountMixin.addName..'|n|cnGREEN_FONT_COLOR:'
        ..(WoWTools_L.RELOADUI)..'|r',
        function()
            WoWToolsPlusSave['Tools_Mounts']= nil
            WoWToolsPlusPlayerDate['Tools_Mounts']= nil
            WoWTools_DataMixin:Reload()
        end
    )

    sub:CreateDivider()
    WoWTools_MenuMixin:OpenDragonriding(sub)

    WoWTools_MenuMixin:OpenJournal(sub, {
        index=1,
        icon='|A:hud-microbutton-Mounts-Up:0:0|a'}
    )

    WoWTools_ToolsMixin:OpenMenu(sub, WoWTools_MountMixin.addName)
end























function WoWTools_MountMixin:Init_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end

function WoWTools_MountMixin:Init_Menu_Spell(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu_Spell)
end

function WoWTools_MountMixin:Init_Menu_Item(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu_Item)
end

function WoWTools_MountMixin:Set_Mount_Sub_Options(...)
    Set_Mount_Sub_Options(...)
end