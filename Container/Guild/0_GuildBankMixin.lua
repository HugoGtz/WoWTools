WoWTools_GuildBankMixin={}


function WoWTools_GuildBankMixin:Get_Access(tabID)
    tabID = tabID or GetCurrentGuildBankTab()

    if not tabID
        or GuildBankFrame.noViewableTabs
        or GuildBankFrame.mode ~= "bank"
        or GetNumGuildBankTabs()<tabID
    then
        return '', 'Disabled'
    end

    local _, _, isViewable, canDeposit, numWithdrawals= GetGuildBankTabInfo(tabID)
    if not isViewable then
        return '', 'NotViewable'
    end

    local atlas, access
    if ( not canDeposit and numWithdrawals == 0 ) then
        access = WoWTools_L.GUILDBANK_TAB_LOCKED;
        atlas= '|A:Monuments-Lock:0:0|a'

    elseif ( not canDeposit ) then
        access = WoWTools_L.GUILDBANK_TAB_WITHDRAW_ONLY;
        atlas= '|A:Cursor_OpenHand_32:0:0|a'

    elseif ( numWithdrawals == 0 ) then
        access = WoWTools_L.GUILDBANK_TAB_DEPOSIT_ONLY;
        atlas= '|A:Banker:0:0|a'

    else
        access = WoWTools_L.GUILDBANK_TAB_FULL_ACCESS
    end

    return atlas, access
end



function WoWTools_GuildBankMixin:GetFree(tabID)
    tabID = tabID or GetCurrentGuildBankTab()
    local numFreeSlots = 0
    local items={}
    for slotID = 1, 98 do
        local itemLink= GetGuildBankItemLink(tabID, slotID)
        if not itemLink then
            numFreeSlots = numFreeSlots + 1
        else
            table.insert(items, {slotID=slotID, itemLink=itemLink})
        end
    end
    return numFreeSlots, items
end



function WoWTools_GuildBankMixin:GetNumWithdrawals(tabID)

    tabID= tabID or GetCurrentGuildBankTab()

    local _, _, isViewable, canDeposit, numWithdrawals, remainingWithdrawals= GetGuildBankTabInfo(tabID)

    if not isViewable then
        return
    end

    local numOut
    local numIn= true

    if
        (canDeposit and numWithdrawals==0)
        or not canDeposit
        or numWithdrawals==0
    then
        numIn= false
    end

    if remainingWithdrawals and remainingWithdrawals > 0 then
        numOut= remainingWithdrawals

    elseif remainingWithdrawals==0 then
        numOut=false

    else
        numOut=true
    end

    return numOut, numIn
end
