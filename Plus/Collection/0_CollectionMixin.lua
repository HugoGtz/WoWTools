WoWTools_CollectionMixin={}



function WoWTools_CollectionMixin:Refresh_TransmogItems()
    if TransmogFrame and not WoWTools_FrameMixin:IsLocked(TransmogFrame) then
        if TransmogFrame.WardrobeCollection.TabContent.ItemsFrame:IsVisible() then
            TransmogFrame.WardrobeCollection.TabContent.ItemsFrame:Refresh()

        elseif TransmogFrame.WardrobeCollection.TabContent.SetsFrame:IsVisible() then
            TransmogFrame.WardrobeCollection.TabContent.SetsFrame:RefreshCollectionEntries()

        elseif TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame:IsVisible() then
            TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame:RefreshCollectionEntries()
        end
    end
end



function WoWTools_CollectionMixin:Mount(mountID, itemID)
    mountID= mountID or (itemID and C_MountJournal.GetMountFromItem(itemID))
    if mountID then
        if select(11, C_MountJournal.GetMountInfoByID(mountID)) then
            return '|cnGREEN_FONT_COLOR:'..(WoWTools_L.COLLECTED)..'|r', true, '|A:CovenantSanctum-Renown-Checkmark-Large:0:0|a'
        else
            return '|cnWARNING_FONT_COLOR:'..(WoWTools_L.NOT_COLLECTED)..'|r', false, '|A:QuestNormal:0:0|a'
        end
    end
end

function WoWTools_CollectionMixin:Toy(itemID)
    if C_ToyBox.GetToyInfo(itemID) then
        if PlayerHasToy(itemID) then
            return '|cnGREEN_FONT_COLOR:'..(WoWTools_L.COLLECTED)..'|r', true, '|A:CovenantSanctum-Renown-Checkmark-Large:0:0|a'
        else
            return '|cnWARNING_FONT_COLOR:'..(WoWTools_L.NOT_COLLECTED)..'|r', false, '|A:QuestNormal:0:0|a'
        end
    end
end


function WoWTools_CollectionMixin:Item(itemIDOrLink, sourceID, isIcon, onlyBool)
    sourceID= sourceID or (itemIDOrLink and select(2, C_TransmogCollection.GetItemInfo(itemIDOrLink)))

    local sourceInfo = sourceID and C_TransmogCollection.GetSourceInfo(sourceID)

    local isCollected=nil
    local isSelf

    if sourceInfo then
        isCollected= sourceInfo.isCollected
        isSelf= select(2, C_TransmogCollection.PlayerCanCollectSource(sourceID))

    elseif itemIDOrLink and C_Item.IsCosmeticItem(itemIDOrLink) then
        isCollected= C_TransmogCollection.PlayerHasTransmogByItemInfo(itemIDOrLink)
    end

    if isCollected==nil then
        return
    end


    local text
    if not onlyBool then
        if isCollected==true then
            if isIcon then
                if isSelf then
                    text='|A:common-icon-checkmark:0:0|a'
                else
                    text= '|A:Adventures-Checkmark:0:0|a'
                end
            else
                text= '|cnGREEN_FONT_COLOR:'..(WoWTools_L.COLLECTED)..'|r'
            end
        else
            if isIcon then
                if isSelf then
                    text='|T132288:0|t'
                else
                    text= '|A:transmog-icon-hidden:0:0|a'
                end
            else
                text= '|cnWARNING_FONT_COLOR:'..(WoWTools_L.NOT_COLLECTED)..'|r'
            end
        end
    end
    return text, isCollected, isSelf
end


function WoWTools_CollectionMixin:SetID(setID, itemLinkOrID, isLoot)
    local numCollected, numAll=0,0

    setID= setID or (itemLinkOrID and  C_Item.GetItemLearnTransmogSet(itemLinkOrID))

    if setID then
        if isLoot then
            for _, data in pairs(C_LootJournal.GetItemSetItems(setID) or {}) do
                if data.itemID then
                    numAll=numAll+1
                    if C_TransmogCollection.PlayerHasTransmogByItemInfo(data.itemID) then
                        numCollected=numCollected + 1
                    end
                end
            end
        else
            for _, v in pairs(C_TransmogSets.GetSetPrimaryAppearances(setID) or {}) do
                numAll=numAll+1
                if v.collected then
                    numCollected=numCollected + 1
                end
            end
        end
    end

    if numAll==0 then
        return
    elseif numCollected==numAll then
        return '|A:AlliedRace-UnlockingFrame-Checkmark:12:12|a',
               numCollected,
               numAll,
               true
               --'|cnGREEN_FONT_COLOR:'..(COLLECTED)..'|r',


    elseif numCollected==0 then
        return '|cff626262'..numAll..'|r',
                numCollected,
                numAll,
                false
                --'|cff626262'..numCollected..'|r/'..numAll--, '|cnWARNING_FONT_COLOR:'..(NOT_COLLECTED)..'|r'
    else
        return numAll-numCollected,
            numCollected,
            numAll,
            false
            --'|cffffffff'..numCollected..'|r/'..numAll--, '|cnYELLOW_FONT_COLOR:'..numCollected..'/'..numAll..' '..(NOT_COLLECTED)..'|r'
    end
end


function WoWTools_CollectionMixin:GetPet9Item(itemID, find)
    if itemID==11406 or itemID==11944 or itemID==25402 then
        if find then
            return true
        else
            return '|T3856129:0|t'..(C_PetJournal.GetNumCollectedInfo(3106) or 0)
                ..' = '
                ..'|T134357:0|t'..C_Item.GetItemCount(11406, true)
                ..'|T132540:0|t'..C_Item.GetItemCount(11944, true)
                ..'|T133053:0|t'..C_Item.GetItemCount(25402, true)
        end

    elseif itemID==3300 or itemID==3670 or itemID==6150 then
        if find then
            return true
        else
            return '|T3856129:0|t'..(C_PetJournal.GetNumCollectedInfo(3105) or 0)
                    ..' = '
                    ..'|T132936:0|t'..C_Item.GetItemCount(3300, true)
                    ..'|T133718:0|t'..C_Item.GetItemCount(3670, true)
                    ..'|T133676:0|t'..C_Item.GetItemCount(6150, true)
        end

    elseif itemID==36812 or itemID==62072 or itemID==67410 then
        if find then
            return true
        else
            return '|T3856131:0|t'..(C_PetJournal.GetNumCollectedInfo(3104) or 0)
                    ..' = '
                    ..'|T134063:0|t'..C_Item.GetItemCount(36812, true)
                    ..'|T135148:0|t'..C_Item.GetItemCount(62072, true)
                    ..'|T135239:0|t'..C_Item.GetItemCount(67410, true)
        end
    end
end