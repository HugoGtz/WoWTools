

local function Get_SlotLevel(slot)
    local level
    for _, slotID in ipairs(slot) do
        local itemLink= GetInventoryItemLink('player', slotID)
        if itemLink then
            local itemLevel= WoWTools_ItemMixin:GetItemLevel(itemLink) or 0
            if itemLevel>1 then
                level= (not level or itemLevel<level) and itemLevel or level
            end
        end
    end
    return level or 0
end


local function Set_Equip(self, tooltip, itemID, itemLink, itemLevel, itemEquipLoc, bindType, color)
    local textLeft, text2Left
    itemLevel= itemLink and WoWTools_ItemMixin:GetItemLevel(itemLink) or itemLevel
    local portrait
    if itemLevel and itemLevel>1 then
        local slot= {WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)}
        if slot[1] then
            local slotTexture= select(2, WoWTools_ItemMixin:GetEquipSlotIcon(slot[1]))
            if slotTexture then
                portrait=slotTexture
            end
            tooltip:AddDoubleLine(
                (WoWTools_TextMixin:CN(_G[itemEquipLoc]) or '')..' |cffffffff'..(itemEquipLoc or ''),
                ( WoWTools_L.TRADESKILL_FILTER_SLOTS)..' |cffffffff'..slot[1]
            )

            local slotItemLevel= Get_SlotLevel(slot)

            local text
            if slotItemLevel>0 then
                local num=itemLevel-slotItemLevel
                if num>0 then
                    text=itemLevel..'|A:bags-greenarrow:0:0|a'..'|cnGREEN_FONT_COLOR:+'..num..'|r'
                elseif num<0 then
                    text=itemLevel..'|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a'..'|cnWARNING_FONT_COLOR:'..num..'|r'
                end
            else
                text=itemLevel..'|A:bags-greenarrow:0:0|a'
            end

            text= color:WrapTextInColorCode(text or itemLevel)

            textLeft=text
        end
    end

    local appearanceID, sourceID = C_TransmogCollection.GetItemInfo(itemLink or itemID)
    local visualID
    if sourceID then
        local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
        if sourceInfo then
            visualID=sourceInfo.visualID
            text2Left=sourceInfo.isCollected and '|cnGREEN_FONT_COLOR:'..(WoWTools_L.COLLECTED)..'|r' or '|cnWARNING_FONT_COLOR:'..(WoWTools_L.NOT_COLLECTED)..'|r'
        end
    end
    self:Set_Item_Model(tooltip, {itemID=itemID, sourceID=sourceID, appearanceID=appearanceID, visualID=visualID})

    if bindType==Enum.ItemBind.OnEquip or bindType==Enum.ItemBind.OnUse then
        portrait='Professions_Specialization_Lock_Glow'
    end

    local specTable = itemLink and C_Item.GetItemSpecInfo(itemLink)
    if specTable and #specTable>0 then
        
        local other=''
        local otherTab={}

        for _, specID in pairs(specTable) do
            local icon2, _, classFile=select(4, GetSpecializationInfoByID(specID))
            if classFile and icon2 and not otherTab[classFile] then
                other= other..(WoWTools_UnitMixin:GetClassIcon(nil, nil, classFile) or '')
                otherTab[classFile]= true
            end
        end

        tooltip:AddLine(other, nil, nil, nil, true)
    end

    return textLeft, text2Left, portrait
end


local StatsValue= {
    ['ITEM_MOD_VERSATILITY']= CR_VERSATILITY_DAMAGE_DONE,

    ['ITEM_MOD_HASTE_RATING_SHORT']= CR_HASTE_MELEE,
    ['ITEM_MOD_MASTERY_RATING_SHORT']= CR_MASTERY,
    ['ITEM_MOD_CRIT_RATING_SHORT']= CR_CRIT_MELEE,

    ['ITEM_MOD_CR_AVOIDANCE_SHORT']= CR_AVOIDANCE,
    ['ITEM_MOD_CR_LIFESTEAL_SHORT']= CR_LIFESTEAL,
    ['ITEM_MOD_CR_SPEED_SHORT']= CR_SPEED,
    ['ITEM_MOD_BLOCK_RATING_SHORT']= CR_BLOCK,
    ['ITEM_MOD_PARRY_RATING_SHORT'] = CR_PARRY,
}


local function Set_ItemStatus(tooltip, itemLink)
    local stats= C_Item.GetItemStats(itemLink)
    if not stats then
        return
    end

    local find
    for stat, va in pairs(stats) do
        local value= nil
        if StatsValue[stat] then
            value= GetCombatRatingBonusForCombatRatingValue(StatsValue[stat], va)
            if value then
                value= format('%.2f%%', value)
            end
        end
        stats[stat]= value
        find= find or value
    end
    if not find then
        return
    end

    local name= tooltip:GetName() or 'GameTooltip'

    for i=5, tooltip:NumLines() or 0, 1 do
        local line= _G[name..'TextLeft'..i]
        local text= line and line:GetText()
        if canaccessvalue(text) and text then
            for stat, value in pairs(stats) do
                local t= WoWTools_TextMixin:CN(_G[stat])
                if text:find('^%+.+ '..t) then
                    line:SetText(text.. ' '..value)
                    stats[stat]= nil
                    break
                end
            end
        end
    end
end


local function Set_keystonee(tooltip, itemLink)
    local textLeft, text2Left, text2Right

    local new={}

    for guid, info in pairs(WoWToolsPlus_WoWDate or {}) do
        if info.Keystone.link then
            if guid==WoWTools_DataMixin.Player.GUID then
                text2Right= WoWTools_TextMixin:CN(info.Keystone.link, {itemLink=info.Keystone.link, isName=true})
            else
                table.insert(new, {
                    guid=guid,
                    faction=info.faction,

                    score= info.Keystone.score or 0,
                    weekNum= info.Keystone.weekNum or 0,
                    weekLevel= info.Keystone.weekLevel or 0,

                    weekMythicPlus= info.Keystone.weekMythicPlus,
                    link= info.Keystone.link
                })
            end
        end
    end

    local num= #new
    table.sort(new, function(a, b)
        if a.score==b.score then
            if b.weekNum==a.weekNum then
                return b.weekLevel>a.weekLevel
            else
                return b.weekNum>a.weekNum
            end
        else
            return b.score>a.score
        end
    end)

    for index, info in pairs(new) do
        tooltip:AddDoubleLine(
            (info.weekNum==0 and '|cff6262620|r' or info.weekNum or '')
            ..(info.weekMythicPlus and '|cnGREEN_FONT_COLOR:('..info.weekMythicPlus..') ' or '')
            ..WoWTools_UnitMixin:GetPlayerInfo(nil, info.guid, nil, {faction=info.faction, reName=true, reRealm=true})
            ..WoWTools_ChallengeMixin:KeystoneScorsoColor(info.score, false, nil)..(WoWTools_ChallengeMixin:KeystoneScorsoColor(info.score,true)),

            WoWTools_HyperLink:CN_Link(info.link, {isName=true})
        )
        if index>2 and not IsShiftKeyDown() then
            if num>index then
                tooltip:AddLine('|cnGREEN_FONT_COLOR:<|A:NPE_Icon:0:0|aShift+ '..(WoWTools_L.CHARACTER)..' '..num..'>')
            end
            break
        end
    end


    local text=WoWTools_ChallengeMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.Activities)


    local score= WoWTools_ChallengeMixin:KeystoneScorsoColor(C_ChallengeMode.GetOverallDungeonScore(), true)
    if text or score then
        textLeft=(text and '|cnGREEN_FONT_COLOR:'..text..'|r ' or '')..(score or '')
    end

    local info = C_MythicPlus.GetRunHistory(false, true) or {}

    num= 0
    local completedNum=0
    for _, runs  in pairs(info) do
        if runs and runs.level then
            num= num+ 1
            if runs.completed then
                completedNum= completedNum +1
            end
        end
    end
    if num>0 then
        text2Left=num..'|cnGREEN_FONT_COLOR:('..completedNum..')|r'
    end

--Affix
    local affix= WoWTools_HyperLink:GetKeyAffix(itemLink)
    if affix then
        tooltip:AddLine(affix)
    end
    return textLeft, text2Left, text2Right
end


local function Set_Item_Num(tooltip, itemID)
    local bagAll,bankAll,numPlayer=0,0,0
    local new={}
    local tab
    for guid, info in pairs(WoWToolsPlus_WoWDate or {}) do
        tab=info.Item[itemID]
        if tab and guid~=WoWTools_DataMixin.Player.GUID and (tab.bag>0 or tab.bank>0)  then
            table.insert(new, {
                guid= guid,
                faction= info.faction,
                bag= tab.bag,
                bank= tab.bank,
                num= tab.bag+tab.bank,
            })

            bagAll=bagAll +tab.bag
            bankAll=bankAll +tab.bank
            numPlayer=numPlayer +1
        end
    end

    if numPlayer>0 then
        tooltip:AddLine(' ')

        table.sort(new, function(n1, n2) return n1.num> n2.num end)

        for index, info in pairs(new) do
            local color= WoWTools_UnitMixin:GetColor(nil, info.guid)
            local hex= color:GenerateHexColorMarkup()

            tooltip:AddDoubleLine(
                WoWTools_UnitMixin:GetPlayerInfo(nil, info.guid, nil, {faction=info.faction, reName=true, reRealm=true}),

                (info.bank==0 and '|cff626262' or hex)..WoWTools_DataMixin:MK(info.bank, 3)..'|r|A:Banker:0:0|a '
                ..(info.bag==0 and '|cff626262' or hex)..WoWTools_DataMixin:MK(info.bag, 3)..'|r|A:bag-main:0:0|a'
            )

            if index>2 and not IsShiftKeyDown() then
                if numPlayer>index then
                    tooltip:AddLine('|cnGREEN_FONT_COLOR:<|A:NPE_Icon:0:0|aShift+ '..(WoWTools_L.CHARACTER)..' '..numPlayer..'>')
                end
                break
            end
        end

    end

end


function WoWTools_TooltipMixin:Set_Item(tooltip, itemLink, itemID)
    if self:IsInCombatDisabled(tooltip)
        or not canaccessvalue(itemLink)
        or not canaccessvalue(itemID)
        or not (itemLink or itemID)
    then
        return
    end


    local itemName, _, itemQuality, itemLevel, _, itemType, itemSubType, _, itemEquipLoc, itemTexture, _, classID, subclassID, bindType, expacID, setID =  C_Item.GetItemInfo(itemLink or itemID)
    itemID= itemID or WoWTools_ItemMixin:GetItemID(itemLink)

    if not itemID then
        return
    end


    local color= WoWTools_ItemMixin:GetColor(itemQuality)

    tooltip:AddLine(' ')

    local text2Left, textLeft, textRight, text2Right

    if expacID or setID then
        tooltip:AddDoubleLine(
            WoWTools_DataMixin:GetExpansionText(expacID, nil) or '  ',
            setID and 'setID'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..setID
        )
    end

    local spellName, spellID = C_Item.GetItemSpell(itemID)
    if spellName and spellID then
        local spellTexture= C_Spell.GetSpellTexture(spellID)
        tooltip:AddDoubleLine(
            spellTexture and spellTexture~=itemTexture  and '|T'..spellTexture..':'..self.iconSize..'|t|cffffffff'..spellTexture or ' ',

            (itemName~=spellName and '|cff71d5ff['..WoWTools_TextMixin:CN(spellName, {spellID=spellID, isName=true})..']|r' or '')
            ..NORMAL_FONT_COLOR:WrapTextInColorCode(WoWTools_L.SPELLS)..'|T'..(spellTexture or itemTexture or 0)..':0|t|cffffffff'..spellID
        )
    end

    itemTexture= itemTexture or select(5, C_Item.GetItemInfoInstant(itemID or itemLink))

    tooltip:AddDoubleLine(
        itemTexture and '|T'..itemTexture..':'..self.iconSize..'|t|cffffffff'..itemTexture or ' ',

        NORMAL_FONT_COLOR:WrapTextInColorCode(WoWTools_L.PROFESSIONS_COLUMN_HEADER_ITEM)..'|cffffffff'
        ..WoWTools_DataMixin.Icon.icon2
        ..itemID
    )

    if classID or subclassID then
        tooltip:AddDoubleLine(
            classID and NORMAL_FONT_COLOR:WrapTextInColorCode((WoWTools_TextMixin:CN(itemType) or 'itemType'))..' |cffffffff'..classID or ' ',
            subclassID and NORMAL_FONT_COLOR:WrapTextInColorCode((WoWTools_TextMixin:CN(itemSubType) or 'itemSubType'))..' |cffffffff'..subclassID
        )
    end

    local transmogSetID= C_Item.GetItemLearnTransmogSet(itemID)

    local portrait
    if C_Item.IsDecorItem(itemLink or itemID) then

        local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByItem(itemLink or itemID, true)
        if entryInfo then
            portrait= self:Set_HouseItem(tooltip, entryInfo)
            textLeft= WoWTools_ItemMixin:GetDecorItemCount(itemID)
            if entryInfo.quality then
                color= WoWTools_ItemMixin:GetColor(entryInfo.quality)
            end
        end

    elseif transmogSetID then
        local collect, numAll = select(2, WoWTools_CollectionMixin:SetID(transmogSetID))
        if numAll then
            if collect==numAll then
                textLeft= format('|cnGREEN_FONT_COLOR:%s|r',  WoWTools_L.COLLECTED)
            elseif collect>0 then
                textLeft= '|cnWARNING_FONT_COLOR:'..collect..'/'..numAll
            else
                textLeft= format('|cnWARNING_FONT_COLOR:%s|r',  WoWTools_L.NOT_COLLECTED)
            end
        end
        tooltip:AddLine('transmogSetID|cffffffff'..WoWTools_DataMixin.Icon.icon2..transmogSetID)
    elseif classID==2 or classID==4 then
        textLeft, text2Left, portrait= Set_Equip(self, tooltip, itemID, itemLink, itemLevel, itemEquipLoc, bindType, color)
        if not PlayerIsTimerunning() then
            Set_ItemStatus(tooltip, itemLink)
        end
    elseif itemID==6948 then
        textLeft= WoWTools_TextMixin:CN(GetBindLocation())

    elseif C_ToyBox.GetToyInfo(itemID) then
        text2Left= PlayerHasToy(itemID) and '|cnGREEN_FONT_COLOR:'..(WoWTools_L.COLLECTED)..'|r' or '|cnWARNING_FONT_COLOR:'..(WoWTools_L.NOT_COLLECTED)..'|r'

    elseif itemID==122284 then
        C_WowTokenPublic.UpdateMarketPrice()
        local price= C_WowTokenPublic.GetCurrentMarketPrice()
        if price and price>0 then
            textLeft='|T1120721:0|t'
                ..(WoWTools_DataMixin:MK(price/10000, 4))
                ..'|A:auctionhouse-icon-coin-gold:0:0|a' --C_CurrencyInfo.GetCoinTextureString(price)
        end


    else
        local mountID = C_MountJournal.GetMountFromItem(itemID)
        local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
        if mountID then
            self:Set_Mount(tooltip, mountID, 'item')
        elseif speciesID then
            self:Set_Pet(tooltip, speciesID)
        end
    end

    if itemQuality==0 and(classID==2 or classID==15) then
        local petText= WoWTools_CollectionMixin:GetPet9Item(itemID)
        if petText then
            tooltip:AddLine(petText)
        end
    end


    tooltip.Portrait:settings(portrait or itemTexture)

    if C_Item.IsItemKeystoneByID(itemID) then
        textLeft, text2Left, text2Right= Set_keystonee(tooltip, itemLink)
    else
        Set_Item_Num(tooltip, itemID)
    end

    textRight= textRight or WoWTools_ItemMixin:GetCount(itemID)

    tooltip:Set_TopLabel(textLeft, text2Left, textRight, text2Right)

    tooltip:Set_BG_Color(color, 0.15)
    self:Set_Web_Link(tooltip, {type='item', id=itemID, name=itemName, col=color:GenerateHexColorMarkup(), isPetUI=false})

    WoWTools_TooltipMixin:Show(tooltip)
    --tooltip:Show()
end