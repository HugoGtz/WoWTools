WoWTools_ItemMixin={
    Events={},
    Frames={},
    QualityText={},

    Save=function()
        return WoWToolsPlusSave['Plus_ItemInfo'] or {}
    end,

    SaveNo=function()
        return WoWToolsPlusSave['Plus_ItemInfo'].No or {}
    end,

    SaveSize=function()
        return WoWToolsPlusSave['Plus_ItemInfo'].Size or {}
    end
}

function WoWTools_ItemMixin:SetOptions(frame, root, tab)
    if not frame:IsMouseOver() then
        return
    end

    local name= tab.name
    local tips= tab.toolip
    local size= tab.size or 10

    local call
    if tab.call then
        call= type(tab.call)=='function' and tab.call or _G[tab.call]
    end
    call= call or function()end


    local sub=root:CreateCheckbox(
        self.addName,
    function()
        return not self:SaveNo()[name]
    end, function()
        self:SaveNo()[name]= not self:SaveNo()[name] and true or nil
        call()
    end, {rightText= self:SaveSize()[name] or size})
    WoWTools_MenuMixin:SetRightText(sub)

    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Item.FrameInfo'])
        if not tab.call or tips then
            tooltip:AddLine(
                tips
                or (WoWTools_L['NEED+REFRESH'])
            )
        end
    end)

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    name= WoWTools_L.FONT_SIZE,
    getValue=function()
        return self:SaveSize()[name] or size
    end, setValue=function(value)
        self:SaveSize()[name]= value
        call()
    end,
    minValue=6,
    maxValue=18,
    step=1,
    })
    sub:CreateSpacer()


    local sub2= sub:CreateButton(
        WoWTools_L.RESET,
    function()
        self:SaveSize()[name]= nil
        call()
        return MenuResponse.Refresh
    end)

    for i=8, 14, 2 do
        sub2:CreateCheckbox(
            (i==size and '|cnGREEN_FONT_COLOR:' or '')
            ..i,
        function(value)
            return value== (self:SaveSize()[name] or size)
        end,function(value)
            self:SaveSize()[name]= value
            call()
        end, i)
    end

    sub2:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(sub2, {name=self.addName, name2=name, category=self.Category})
end


local itemLevelStr= ITEM_LEVEL:gsub('%%d', '%(%%d%+%)')


function WoWTools_ItemMixin:SetGemStats(frame, itemLink)
    local leftText, bottomLeftText
    if itemLink then
        local dateInfo
        if PlayerIsTimerunning() then
            dateInfo= self:GetTooltip({itemLink=itemLink, index=3})
        else
            dateInfo= self:GetTooltip({itemLink=itemLink, text={'(%+.+)', }})
        end
        local text= dateInfo.text['(%+.+)'] or dateInfo.indexText

        if text then
            text= string.lower(text)

            for name, name2 in pairs(WoWTools_DataMixin.StausText) do
                if text:find(string.lower(name)) then
                    if not leftText then
                        leftText= '|cffffffff'..name2..'|r'
                    elseif not bottomLeftText then
                        bottomLeftText='|cffffffff'..name2..'|r'
                    end
                end
            end
            if text:find(('%+(.+)')) then
                leftText= leftText or WoWTools_TextMixin:sub(text:gsub('%+', ''), 1, 3, true)
            end
        end
    end

    if frame and frame:IsVisible() then
        if leftText and not frame.leftText then
            frame.leftText= WoWTools_LabelMixin:Create(frame, {size=10})
            frame.leftText:SetPoint('LEFT')
        end
        if frame.leftText then
            frame.leftText:SetText(leftText or '')
        end
        if bottomLeftText and not frame.bottomLeftText then
            frame.bottomLeftText= WoWTools_LabelMixin:Create(frame, {size=10})
            frame.bottomLeftText:SetPoint('BOTTOMLEFT')
        end
        if frame.bottomLeftText then
            frame.bottomLeftText:SetText(bottomLeftText or '')
        end
    end

    return leftText, bottomLeftText
end


--value zPanel.lua  WoWTools_DataMixin.StausText 
--[ITEM_MOD_HASTE_RATING_SHORT]= WoWTools_TextMixin:sub(ITEM_MOD_HASTE_RATING_SHORT, 1, 2, true),
local StatTab={
    {value='ITEM_MOD_CRIT_RATING_SHORT', index=1},
    {value='ITEM_MOD_HASTE_RATING_SHORT', index=1},
    {value='ITEM_MOD_MASTERY_RATING_SHORT', index=1},
    {value='ITEM_MOD_VERSATILITY', index=1},

    {value='ITEM_MOD_CR_AVOIDANCE_SHORT', index=2},
    {value='ITEM_MOD_CR_LIFESTEAL_SHORT', index=2},
    {value='ITEM_MOD_CR_SPEED_SHORT', index=2},
    {value='ITEM_MOD_PARRY_RATING_SHORT', index=2},
}




function WoWTools_ItemMixin:GetItemStats(itemLink)
    local info= itemLink and C_Item.GetItemStats(itemLink) or {}

    if TableIsEmpty(info) then
        return info
    end

    local num, tab= 0, {}
    for _, stat in pairs(StatTab) do
        local value= info[stat.value]
        local name= _G[stat.value]
        if type(value)=='number' and value>0 and name then

            local text= WoWTools_DataMixin.StausText[name]

            table.insert(tab, {text=text, value=value, index=stat.index})

            num= num+1
            if num==4 then
                break
            end
        end
    end



    table.sort(tab, function(a,b)
        if a.index== b.index then
            return a.value> b.value
        else
            return a.index< b.index
        end
    end)

    local new= {}
    for _, stat in pairs(tab) do
        table.insert(new, stat.text)
    end

    return new
end


function WoWTools_ItemMixin:SetItemStats(frame, link, setting)
    if not frame then
        return
    end
    local setID, itemLevel
    setting= setting or {}

    local hideSet= setting.hideSet
    local point= setting.point or frame
    local hideLevel= setting.hideLevel
    local itemID= setting.itemID
    local hideStats= setting.hideStats
    local size= setting.size or 12

    local bag= setting.bag--{bag=0, slot=0}
    local equipSlot= setting.equipSlot
    local itemLocation= setting.itemLocation

    link= link or (itemID and select(2, C_Item.GetItemInfo(itemID)))
    local itemLevelColor= HIGHLIGHT_FONT_COLOR

    if link then
        local itemID2, _, _, _, _, classID= C_Item.GetItemInfoInstant(link)
        if (classID==2 or classID==4) and not C_Item.IsCosmeticItem(itemID2) then
            itemID= itemID or itemID2
        else
            link=nil
            itemID= nil
        end
    end

    if link then
        if not hideSet then
            setID= select(16 , C_Item.GetItemInfo(link))
            if setID and not frame.setIDItem then
                frame.setIDItem= frame:CreateTexture()
                frame.setIDItem:SetAtlas('UI-HUD-MicroMenu-Highlightalert')
                frame.setIDItem:SetAllPoints(point)
            end
        end

        if not hideLevel then
                --if quality==7 then

            itemLevel= self:GetItemLevel(link)
            if itemLevel and itemLevel>13 then
                if not C_Item.IsEquippableItem(link) or self:IsEquipType(itemLocation, bag, equipSlot)==false then
                    itemLevelColor= DISABLED_FONT_COLOR
                else
                    local avgItemLevel= select(2, GetAverageItemLevel())
                    if avgItemLevel then
                        local lv = itemLevel- avgItemLevel
                        if lv <= -6  then
                            itemLevelColor= WARNING_FONT_COLOR
                        elseif lv>=7 then
                            itemLevelColor= GREEN_FONT_COLOR
                        end
                    end
                end
            else
                itemLevel=nil
            end
        end
        if not frame.itemLevel and itemLevel then
            frame.itemLevel= frame:CreateFontString(nil, 'OVERLAY', 'WoWToolsFont2', nil, 1)
            frame.itemLevel:SetJustifyH('CENTER')
            frame.itemLevel:SetPoint('CENTER', point)
        end
    end

    if frame.setIDItem then frame.setIDItem:SetShown(setID) end

    if frame.itemLevel then
        frame.itemLevel:SetText(itemLevel or '')
        frame.itemLevel:SetFontHeight(size)
        frame.itemLevel:SetTextColor(itemLevelColor:GetRGB())
    end

    local tab= not hideStats and self:GetItemStats(link) or {}
    for index=1 ,4 do
        local lable=frame['statText'..index]
        if tab[index] then
            if not lable then
                frame['statText'..index]= frame:CreateFontString(nil, 'OVERLAY', 'WoWToolsFont', nil, 1) -- WoWTools_LabelMixin:Create(frame, {justifyH= (index==2 or index==4) and 'RIGHT'})
                lable= frame['statText'..index]

                if (index==2 or index==4) then
                    lable:SetJustifyH('RIGHT')
                end

                if index==1 then
                    lable:SetPoint('BOTTOMLEFT', point, 'BOTTOMLEFT', -4, 0)
                elseif index==2 then
                    lable:SetPoint('BOTTOMRIGHT', point, 'BOTTOMRIGHT', 4, 0)
                elseif index==3 then
                    lable:SetPoint('TOPLEFT', point, 'TOPLEFT', -4, 0)
                else
                    lable:SetPoint('TOPRIGHT', point, 'TOPRIGHT',4, 0)
                end
                frame['statText'..index]=lable
            end
            lable:SetText(tab[index])
            lable:SetFontHeight(size)

        elseif lable then
            lable:SetText('')
        end
    end
end


local ColorRed={
    ['ffff2020']=1,
    ['fefe1f1f']=1,
}

local AccountTab={
    [ITEM_ACCOUNTBOUND]=1,
    [ITEM_BNETACCOUNTBOUND]=1,
    [ITEM_BIND_TO_BNETACCOUNT]=1,
    [ITEM_BIND_TO_ACCOUNT]=1,
    [ITEM_BIND_TO_ACCOUNT_UNTIL_EQUIP]=1,
    [ITEM_ACCOUNTBOUND_UNTIL_EQUIP]=1,
}


function WoWTools_ItemMixin:GetTooltip(tab)
    local tooltipData

    local bag= tab.bag--bag, slot
    local guidBank= tab.guidBank--tab, slot
    local merchant= tab.merchant--slot
    local inventory= tab.inventory
    local itemLink= tab.hyperLink or tab.itemLink
    local itemKey= tab.itemKey

    local itemID= tab.itemID
    local quality= tab.quality

    local index= tab.index

    local text= tab.text
    local onlyText= tab.onlyText

    local wow= tab.wow
    local onlyWoW= tab.onlyWoW

    local red= tab.red
    local onlyRed= tab.onlyRed

    if bag then
        tooltipData= C_TooltipInfo.GetBagItem(bag.bag or -1, bag.slot or -1)

    elseif guidBank then-- guidBank then
        tooltipData= C_TooltipInfo.GetGuildBankItem(guidBank.tab or -1, guidBank.slot or -1)

    elseif merchant then
        if merchant.buyBack then
            tooltipData= C_TooltipInfo.GetBuybackItem(merchant.slot or -1)
        else
            tooltipData= C_TooltipInfo.GetMerchantItem(merchant.slot or -1)--slot
        end

    elseif inventory then
        tooltipData= C_TooltipInfo.GetInventoryItem('player', inventory)

    elseif itemLink then
        tooltipData=  C_TooltipInfo.GetHyperlink(itemLink)

    elseif itemID then
        if C_Heirloom.IsItemHeirloom(itemID) then
            tooltipData= C_TooltipInfo.GetHeirloomByItemID(itemID)
        else
            tooltipData= C_TooltipInfo.GetItemByID(itemID, quality)
        end

    elseif itemKey then
        tooltipData= C_TooltipInfo.GetItemKey(itemKey.itemID, itemKey.itemLevel, itemKey.itemSuffix, itemKey.requiredLevel)
    end

    local data={
        red=false,
        wow=false,
        text={},
        indexText=nil,
    }
    if not tooltipData or not tooltipData.lines then
        return data

    elseif index then
        if tooltipData.lines[index] then
            data.indexText= tooltipData.lines[index].leftText
        end
        return data
    end

    local numText= text and #text or 0
    local findText= numText>0 or wow
    local numFind=0
    for _, line in ipairs(tooltipData.lines) do
        if red and not data.red then
            local leftHex=line.leftColor and line.leftColor:GenerateHexColor()
            local rightHex=line.rightColor and line.rightColor:GenerateHexColor()
            if ColorRed[leftHex] then-- or hex=='fefe7f3f' then
                data.red= line.leftText
            elseif ColorRed[rightHex] then--== 'ffff2020' or rightHex=='fefe1f1f' then
                data.red= line.rightText
            end
            if onlyRed and data.red then
                break
            end
        end

        if line.leftText and findText then
            if text then
                for _, t in pairs(text) do
                    if t and (line.leftText:find(t) or line.leftText==t) then
                        data.text[t]= line.leftText:match(t) or line.leftText
                        numFind= numFind +1
                        if onlyText and numFind==numText then
                            break
                        end
                    end
                end
            end
            if wow and not data.wow and AccountTab[line.leftText] then
                data.wow= WoWTools_DataMixin.Icon.wow2 --'|A:questlog-questtypeicon-account:0:0|a'
                if onlyWoW then
                    break
                end
            end
        end
    end
    return data
end


--GetButtonOverlayQualityColor {itemID, itemLocation}
--ColorManager.GetColorDataForItemQuality
function WoWTools_ItemMixin:GetColor(quality, tab)
    tab= tab or {}

    local itemID= tab.itemLink or tab.itemID or tab.itemName
    local itemLocation= tab.itemLocation
    local text= tab.text
    local texture= tab.texture
    --local texture= tab.texture

    quality= quality
        or (itemID and C_Item.GetItemQualityByID(itemID))
        or (itemLocation and C_Item.GetItemQuality(itemLocation))
        or 1
    --local color= ITEM_QUALITY_COLORS[quality] or ITEM_QUALITY_COLORS[Enum.ItemQuality.Common]
    local color= C_ColorOverrides.GetColorForQuality(quality)
        or C_ColorOverrides.GetColorForQuality(Enum.ItemQuality.Common)
        or HIGHLIGHT_FONT_COLOR

    if text then
        return color:WrapTextInColorCode(tab.text)

    elseif texture then
        if texture:GetAtlas() or texture:GetTexture() then
            texture:SetVertexColor(color:GetRGB())
        else
            texture:SetColorTexture(color:GetRGB())
        end

    --else
        --return color.r, color.g, color.b, color:GenerateHexColcorMarkup(), color, quality
    end
    return color
end




--ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()
function WoWTools_ItemMixin:GetLink(itemID)
    local link
    if itemID then
        link= select(2, C_Item.GetItemInfo(itemID))
        if not link then
           WoWTools_DataMixin:Load(itemID, 'item')
            local name= WoWTools_TextMixin:CN(nil, {itemID=itemID, isName=true})
            link= '|Hitem:'..itemID..'::::::::::::::::::|h['..(name or itemID)..']|h'
            if not name then
                link= self:GetColor(nil, {itemID=itemID, text=link})
            end
        end
    end
    return link
end



function WoWTools_ItemMixin:GetItemID(itemLink)
    local itemID
    if itemLink then
        itemID= C_Item.GetItemInfoInstant(itemLink) or C_Item.GetItemIDForItemInfo(itemLink)
        if not itemID then
            itemID = itemLink:match("|H.-:(%d+).-|h")
            if itemID then
                itemID= tonumber(itemID)
            end
        end
    end
    return itemID
end


  --ItemEventListener:AddCancelableCallback(ID, function()
function WoWTools_ItemMixin:LoadItem(label, itemID, notCount)
    if not label or not itemID then
        return
    end

    ItemEventListener:AddCancelableCallback(itemID, function()
        local name= label:IsVisible() and self:GetName(itemID, nil, nil, {notCount=notCount})
        if name then
            label:SetText(name)
        end
    end)
end


function WoWTools_ItemMixin:GetName(itemID, itemLink, itemLocation, tab)
    --tab= tab or {}

    local notCount, label
    if tab then
        notCount= tab.notCount
        label= tab.label
    end

    if not itemID then
        itemID= itemLink and self:GetItemID(itemLink)
    end

    if itemLocation then
        itemID= itemID or itemLocation:GetItemID()
        itemLink= itemLink or itemLocation:GetItemLink()
    end

    local icon, _
    if itemID then
        itemID, _, _, _, icon = C_Item.GetItemInfoInstant(itemID)
    end

    if not itemID then
        return itemID or itemLink or itemLocation
    end

    WoWTools_DataMixin:Load(itemID, 'item')

    local col, name, desc, cool

    if C_ToyBox.GetToyInfo(itemID) then
        if not PlayerHasToy(itemID) then
            col='|cnWARNING_FONT_COLOR:'
            desc= '|A:Islands-QuestBangDisable:0:0|a'--..(WoWTools_L.NOT_COLLECTED)
        else
            cool= WoWTools_CooldownMixin:GetText(nil, itemID)
        end
    else
        if not notCount then
            local countText= self:GetCount(itemID, {notZero=true})--C_Item.GetItemCount(itemID, true, false, true, true) or 0
            if not countText then
                col='|cff626262'
            else
                cool= WoWTools_CooldownMixin:GetText(nil, itemID)
            end
            if countText then
                desc= ' '..countText..' '
            end
        end
    end

    name= C_Item.GetItemNameByID(itemID)
    name= WoWTools_TextMixin:CN(name, {itemID=itemID,itemLink=itemLink, isName=true})

    if not name and label then
        self:LoadItem(label, itemID, notCount)
    end

    if name then
        if not name:find('|c') then
            local color= self:GetColor(nil, {itemID=itemID, itemLink=itemLink})
            name= color:WrapTextInColorCode(name)
        end
        name= '|T'..(icon or 0)..':0|t'..name

    else
         name= name or ('itemID '..itemID)
    end

    if desc and col then
        desc= col..desc..'|r'
    end

    return name..(desc or '')..(cool or ''), col
end


function WoWTools_ItemMixin:GetItemLevel(itemLink)
    if itemLink then
        local dataInfo= self:GetTooltip({itemLink=itemLink, text={itemLevelStr}, onlyText=true})
        local itemLevel= dataInfo.text[itemLevelStr]
        return itemLevel and tonumber(itemLevel) or C_Item.GetDetailedItemLevelInfo(itemLink)
    end
end


local itemSlotName={--InventorySlotId
    [1]= 'HEADSLOT',
    [2]= 'NECKSLOT',
    [3]= 'SHOULDERSLOT',
    [4]= 'SHIRTSLOT',
    [5]= 'CHESTSLOT',
    [6]= 'WAISTSLOT',
    [7]= 'LEGSSLOT',
    [8]= 'FEETSLOT',
    [9]= 'WRISTSLOT',
    [10]= 'HANDSSLOT',
    [11]= 'FINGER0SLOT',
    [12]= 'FINGER1SLOT',
    [13]= 'TRINKET0SLOT',
    [14]= 'TRINKET1SLOT',
    [15]= 'BACKSLOT',
    [16]= 'MAINHANDSLOT',
    [17]= 'SECONDARYHANDSLOT',
    [19]= 'TABARDSLOT',
}
local itemSlotTable={
    ['INVTYPE_HEAD']=1,
    ['INVTYPE_NECK']=2,
    ['INVTYPE_SHOULDER']=3,
    ['INVTYPE_BODY']=4,
    ['INVTYPE_ROBE']=5,
    ['INVTYPE_CHEST']=5,
    ['INVTYPE_WAIST']=6,
    ['INVTYPE_LEGS']=7,
    ['INVTYPE_FEET']=8,
    ['INVTYPE_WRIST']=9,
    ['INVTYPE_HAND']=10,
    ['INVTYPE_FINGER']={11,12},
    ['INVTYPE_TRINKET']={13,14},
    ['INVTYPE_CLOAK']=15,
    ['INVTYPE_SHIELD']=17,
    ['INVTYPE_RANGED']=16,
    ['INVTYPE_2HWEAPON']=16,
    ['INVTYPE_RANGEDRIGHT']=16,
    ['INVTYPE_WEAPON']={16,17},
    ['INVTYPE_WEAPONMAINHAND']=16,
    ['INVTYPE_WEAPONOFFHAND']=16,
    ['INVTYPE_THROWN']=16,
    ['INVTYPE_HOLDABLE']=17,
    ['INVTYPE_TABARD']=19,
    ['INVTYPE_PROFESSION_TOOL']={20,23},
    ['INVTYPE_PROFESSION_GEAR']={21, 22, 24, 25},
}

function WoWTools_ItemMixin:GetEquipSlotIcon(slotID)
    local invSlotName= itemSlotName[slotID]
    local texture= invSlotName and select(2, GetInventorySlotInfo(invSlotName))
    if texture then
        return format('|T%s:0:0|t', texture), texture
    end
end

--local invTypeNum = C_Item.GetItemInventoryTypeByID(itemID)
--local invType = C_Item.GetItemInventorySlotKey(invTypeNum)
function WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)
    local slot= itemSlotTable[itemEquipLoc]
    if slot then
        if type(slot)=='table' then
            return slot[1], slot[2], slot[3], slot[4]
        else
            return slot
        end
    end
end

function WoWTools_ItemMixin:GetEquipSlotName(slotID)
    local slotName= itemSlotName[slotID]
    if slotName then
        local name= WoWTools_TextMixin:CN(_G[slotName])
        if name then
            if slotID==11 or slotID==13 then
                name= WoWTools_Join(name, '1')
            elseif slotID==12 or slotID==14 then
                name= WoWTools_Join(name, '2')
            end
            return name, slotName
        end
    end
end


function WoWTools_ItemMixin:GetDecorItemCount(itemID, entryInfo, showZero)

    entryInfo= entryInfo or (itemID and C_HousingCatalog.GetCatalogEntryInfoByItem(itemID, true)) or {}

    if not entryInfo.showQuantity then
        return
    end

    local numPlaced = entryInfo.numPlaced
    local quantity= entryInfo.quantity
    local remainingRedeemable= entryInfo.remainingRedeemable

    if not numPlaced
        or not quantity
        or not remainingRedeemable
    then
        return
    end

    --local stored = entryInfo.quantity + entryInfo.remainingRedeemable;
	--local total = entryInfo.numPlaced + stored
    local total= numPlaced+ quantity+ remainingRedeemable

    if total>0 or showZero then
        return
            (numPlaced>0 and '|cffffffff' or '|cff626262')..numPlaced..'|A:house-decor-budget-icon:0:0|a|r'
            ..(quantity>0 and '|cffffffff' or '|cff626262')..quantity..'|A:house-chest-icon:0:0|a|r'
            ..(remainingRedeemable>0 and '|cffffffff' or '|cff626262')..remainingRedeemable..'|A:Levelup-Icon-Bag:0:0|a'
    end
    --return DISABLED_FONT_COLOR:WrapTextInColorCode('0')..'|A:house-chest-icon:0:0|a'
end


function WoWTools_ItemMixin:GetCount(itemID, tab)
    tab= tab or {}

    itemID= itemID
        or (tab.itemKey and tab.itemKey.itemID)

    local showZero= not tab.notZero

    local text
    if not itemID then
        return text, 0, 0, 0, 0, 0

    end



    local wow= self:GetWoWCount(itemID)

    local bag= C_Item.GetItemCount(itemID, false, false, false, false) or 0
    local bank= C_Item.GetItemCount(itemID, true, false, true, false) or 0--bank
    local net= C_Item.GetItemCount(itemID, false, false, false, true) or 0
    bank= bank- bag
    net= net-bag


    if showZero or wow>0 then
        text= (wow==0 and '|cff626262' or '|cff00ccff')..WoWTools_DataMixin:MK(wow, 3)..'|r|A:glues-characterSelect-iconShop-hover:0:0|a'
    end
    if showZero or net>0 then
        text= (text and text..' ' or '')
            ..(net==0 and '|cff626262' or '|cff00ccff')..WoWTools_DataMixin:MK(net, 3)..'|r|A:questlog-questtypeicon-account:0:0|a'--..CreateAtlasMarkup("questlog-questtypeicon-account", 18, 18)--|A:questlog-questtypeicon-account:0:0|a'
    end
    if showZero or bank>0 then
        text= (text and text..' ' or '')
            ..(bank==0 and '|cff626262' or '|cffffffff')..WoWTools_DataMixin:MK(bank, 3)..'|r|A:Banker:0:0|a'
    end
    if showZero or bag>0 then
        text= (text and text..' ' or '')
            ..(bag==0 and '|cff626262' or '|cffffffff')..WoWTools_DataMixin:MK(bag, 3)..(bag==1 and C_Item.IsEquippedItem(itemID) and '|A:charactercreate-icon-customize-body-selected:0:0|a' or '|r|A:bag-main:0:0|a')
    end

    return
        text,--1
        bag,--2
        bank,--3
        net,--4
        wow--5
end


function WoWTools_ItemMixin:GetWoWCount(itemID, checkGUID, checkRegion)
    local all,numPlayer=0,0
    if not itemID then
        return 0, 0
    end

    checkGUID= checkGUID or WoWTools_DataMixin.Player.GUID
    checkRegion= checkRegion or WoWTools_DataMixin.Player.Region

    for guid, info in pairs(WoWToolsPlus_WoWDate) do
        if info.battleTag==WoWTools_DataMixin.Player.BattleTag
            and guid~=checkGUID
            and info.region==checkRegion
        then
            if C_Item.IsItemKeystoneByID(itemID) and info.Keystone.link then--Keystone
                all=all +1
                numPlayer=numPlayer +1
            else
                local tab=info.Item[itemID]
                if tab and tab.bag and tab.bank then
                    all=all + tab.bag+ tab.bank
                    numPlayer=numPlayer +1
                end
            end
        end
    end
    return all, numPlayer
end


function WoWTools_ItemMixin:IsEquipType(itemLocation, bag, equipmentSlotIndex)
    if not itemLocation then
        if bag then
            itemLocation= ItemLocation:CreateFromBagAndSlot(bag.bag or -1, bag.slot or -1)

        elseif equipmentSlotIndex then
            itemLocation= ItemLocation:CreateFromEquipmentSlot(equipmentSlotIndex)
        end
    end

    local item = itemLocation and itemLocation:IsValid() and Item:CreateFromItemLocation(itemLocation)

    if not item then
        return
    end

    local itemID, itemType, itemSubType, _, _, itemClassID, itemSubclassID =  C_Item.GetItemInfoInstant(item:GetItemID())
    if itemID then
        local isArmor = (itemClassID == Enum.ItemClass.Armor) and (itemSubclassID ~= Enum.ItemArmorSubclass.Shield);
        if isArmor then
            return IsItemPreferredArmorType(item:GetItemLocation()) and true or false
        end
    end
end



