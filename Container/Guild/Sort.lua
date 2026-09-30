local function Save()
    return WoWToolsPlusSave['Plus_GuildBank']
end
local MAX_GUILDBANK_SLOTS_PER_TAB= 98


local StopRun, IsInRun

local function Init_Sort()
    if IsInRun then--禁用，按钮移动事件
        StopRun=true--停止，已运行
        return
    end

    local currentIndex = GetCurrentGuildBankTab() or 0 -- 当前 Tab
    local numOut= WoWTools_GuildBankMixin:GetNumWithdrawals(currentIndex)
    if not numOut or numOut==0 then
        return
    end

    IsInRun= true

    local saveItemSeconds= (Save().saveItemSeconds or 0.8)+0.2


    local find, itemLink, itemQuality, itemTexture, classID, subclassID, _
    local isRightToLeft= Save().sortRightToLeft

    local items = {}

    for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
        itemLink = GetGuildBankItemLink(currentIndex, slot)
        if itemLink then
            --GetItemInfoInstant es síncrono (GetItemInfo da nil sin caché y el sort comparaba nil)
            _, _, _, _, itemTexture, classID, subclassID= C_Item.GetItemInfoInstant(itemLink)
            itemQuality= select(3, C_Item.GetItemInfo(itemLink))
            table.insert(items, {
                slot = slot,
                link = itemLink,
                icon= itemTexture or 0,
                rarity = itemQuality or 0,
                type = classID or 0,
                subType = subclassID or 0,
            })
        end
    end

    if #items==0 then
        StopRun= nil
        IsInRun= nil
        return
    end

    table.sort(items, function(a, b)
        if a.type == b.type then
            if a.subType == b.subType then
                if a.rarity == b.rarity then
                    if a.icon ~= b.icon then
                        return a.icon < b.icon
                    end
                    return a.slot < b.slot
                else
                    return a.rarity > b.rarity
                end
            else
                return a.subType < b.subType
            end
        else
            return a.type < b.type
        end
    end)

    for indexSlot, item in pairs(items) do
        item.indexSlot= isRightToLeft and MAX_GUILDBANK_SLOTS_PER_TAB-indexSlot+1 or indexSlot
    end


    local function sortItems()
        if
            IsModifierKeyDown()
            or not GuildBankFrame:IsShown()
            or GuildBankFrame.mode ~= "bank"
            or StopRun
            or GetCurrentGuildBankTab()~= currentIndex
        then
            StopRun= nil
            IsInRun= nil
            print(
                WoWTools_GuildBankMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnWARNING_FONT_COLOR:'..(WoWTools_L.STABLE_FILTER_BUTTON_LABEL)..'|r',
                    WoWTools_L.INTERRUPT
                )
            return
        end

        find=false
        for _, item in pairs(items) do
            if item.slot ~= item.indexSlot and GetGuildBankItemLink(currentIndex, item.indexSlot)~=item.link then
                PickupGuildBankItem(currentIndex, item.slot)
                PickupGuildBankItem(currentIndex, item.indexSlot)
                --El objeto que ocupaba indexSlot pasa al hueco antiguo
                for _, other in pairs(items) do
                    if other~=item and other.slot==item.indexSlot then
                        other.slot= item.slot
                        break
                    end
                end
                item.slot= item.indexSlot
                find=true
                break
            end
        end

        if not find then
            IsInRun= nil
            print(
                WoWTools_GuildBankMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnGREEN_FONT_COLOR:'..(WoWTools_L.STABLE_FILTER_BUTTON_LABEL)..'|r',
                WoWTools_L.COMPLETE
            )
            return
        end

        C_Timer.After(saveItemSeconds, function()
            sortItems()
        end)
    end

    sortItems()
end


local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local atlas, access= WoWTools_GuildBankMixin:Get_Access()
    if atlas then
        root:CreateTitle(atlas..access)
        return
    end

    local sub=root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_L.BAG_CLEANUP_BANK),
    function()
        Init_Sort()
        return MenuResponse.Open
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.GuildBank.Sort'])

    root:CreateDivider()

    sub=root:CreateCheckbox(
        WoWTools_L['Reverse Clean Up Bank'],
    function()
        return Save().sortRightToLeft
    end, function()
        Save().sortRightToLeft= not Save().sortRightToLeft and true or false
         if IsInRun then--禁用，按钮移动事件
            StopRun=true--停止，已运行
        end
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.GuildBank.SortReverse'])

end




--REVERSE_CLEAN_UP_BAGS_TEXT = "反向整理背包";
--G_CLEANUP_BANK = "整理银行";
--..(BAG_CLEANUP_BANK)
local function Init()
    local btn= WoWTools_ButtonMixin:Cbtn(GuildBankFrame, {atlas='bags-button-autosort-up'})
    btn:SetPoint('TOPRIGHT', -15, -28)-- -15 -36
    btn:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')

        GameTooltip_SetTitle(GameTooltip,
            '|A:bags-button-autosort-up:0:0|a'
            ..(WoWTools_L.BAG_CLEANUP_BANK)
            ..WoWTools_DataMixin.Icon.left
            ..'|cnGREEN_FONT_COLOR:'
            ..(Save().saveItemSeconds or 0.8)
        )
        GameTooltip:AddLine(
            '|A:dressingroom-button-appearancelist-up:0:0|a'
            ..(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL)
            ..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:Show()
    end)
    --btn:SetupMenu(Init_Menu)
    btn:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            Init_Sort()
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)



    GuildItemSearchBox:ClearAllPoints()
    GuildItemSearchBox:SetPoint('RIGHT', btn, 'LEFT', -8, 0)


    Init=function()end
end


function WoWTools_GuildBankMixin:Init_Sort()
    Init()
end