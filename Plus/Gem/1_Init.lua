
local P_Save={
    favorites={},--{itemID=true},
    gemLeft={},
    gemTop={},
    gemRight={},
    disableSpell=true,
    gemLoc= {}--{class={['INVSLOT_LEGS']={1=gemID, 2=gemID, 3=gemID}}
}


WoWTools_GemMixin= {}--para agrupar el módulo en la página principal

local addName
local Frame
local Set_Gem

local SpellsTab={
    433397,
}

for _, spellID in pairs(SpellsTab) do
   WoWTools_DataMixin:Load(spellID, 'spell')
end



local CurTypeGemTab={}



local function set_save_gem(itemEquipLoc, gemLink, index)
    if not itemEquipLoc then
        return
    end
    WoWTools_GemMixin:Save().gemLoc[WoWTools_DataMixin.Player.Class][itemEquipLoc]= WoWTools_GemMixin:Save().gemLoc[WoWTools_DataMixin.Player.Class][itemEquipLoc] or {}
    local gemID
    if gemLink then
        gemID= C_Item.GetItemInfoInstant(gemLink)
        if gemID then
            WoWTools_GemMixin:Save().gemLoc[WoWTools_DataMixin.Player.Class][itemEquipLoc][index]= gemID
        end
    end

    gemID= gemID or WoWTools_GemMixin:Save().gemLoc[WoWTools_DataMixin.Player.Class][itemEquipLoc][index]
    WoWTools_GemMixin:Save().gemLoc[WoWTools_DataMixin.Player.Class][itemEquipLoc][index]= gemID
    return gemID
end


local function Init_Button_Menu(self, root)
    local sub= root:CreateCheckbox(
        '|A:auctionhouse-icon-favorite:0:0|a'
        ..(WoWTools_L.EVENTTRACE_BUTTON_MARKER),
    function()
        return WoWTools_GemMixin:Save().favorites[self.itemID]
    end, function()
        WoWTools_GemMixin:Save().favorites[self.itemID]= not WoWTools_GemMixin:Save().favorites[self.itemID] and true or nil
        self:set_favorite()
        WoWTools_Print(
            addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_GemMixin:Save().favorites[self.itemID] and self.itemID or '',
            WoWTools_L['NEED+REFRESH~2']
        )
        Set_Gem()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Gem.Favorite'])
    root:CreateDivider()

    sub= root:CreateCheckbox(
        '|A:common-icon-rotateright:0:0|a'
        ..(WoWTools_L.HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_LEFT),
    function ()
        return WoWTools_GemMixin:Save().gemLeft[self.itemID]
    end, function ()
        WoWTools_GemMixin:Save().gemLeft[self.itemID]= not WoWTools_GemMixin:Save().gemLeft[self.itemID] and true or nil
        Set_Gem()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Gem.PlaceLeft'])

    sub= root:CreateCheckbox(
        '|A:bags-greenarrow:0:0|a'
        ..(WoWTools_L['HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP~2']),
    function ()
        return WoWTools_GemMixin:Save().gemTop[self.itemID]
    end, function ()
        WoWTools_GemMixin:Save().gemTop[self.itemID]= not WoWTools_GemMixin:Save().gemTop[self.itemID] and true or nil
        Set_Gem()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Gem.PlaceTop'])

    sub= root:CreateCheckbox(
        '|A:common-icon-rotateleft:0:0|a'
        ..(WoWTools_L.HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_RIGHT),
    function ()
        return WoWTools_GemMixin:Save().gemRight[self.itemID]
    end, function ()
        WoWTools_GemMixin:Save().gemRight[self.itemID]= not WoWTools_GemMixin:Save().gemRight[self.itemID] and true or nil
        Set_Gem()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Gem.PlaceRight'])
end


local function creatd_button(index, parent)
    local btn= WoWTools_ButtonMixin:Cbtn(parent or Frame, {frameType='ItemButton'})

    btn.level=WoWTools_LabelMixin:Create(btn)
    btn.level:SetPoint('TOPRIGHT')
    btn.type= WoWTools_LabelMixin:Create(btn)
    btn.type:SetPoint('BOTTOM', btn, 'TOP')
    btn.favorite= btn:CreateTexture(nil, 'OVERLAY', nil, 2)
    btn.favorite:SetSize(17,17)
    btn.favorite:SetAtlas('auctionhouse-icon-favorite')
    btn.favorite:SetPoint('TOPRIGHT',4,4)
    btn.favorite:SetVertexColor(0,1,0)

    btn:Hide()
    function btn:set_event()
        if self:IsShown() then
            self:RegisterEvent('ITEM_LOCKED')
            self:RegisterEvent('ITEM_UNLOCKED')
            self:RegisterEvent('SOCKET_INFO_UPDATE')
        else
            self:UnregisterAllEvents()
        end
    end
    btn:SetScript('OnHide', function(self) self:set_event() end)
    btn:SetScript('OnShow', function(self) self:set_event() end)

    function btn:set_favorite()
        self.favorite:SetShown(WoWTools_GemMixin:Save().favorites[self.itemID])
    end
    function btn:set_alpha()
        local alpha= 1
        local info
        if self.bagID then
            info = C_Container.GetContainerItemInfo(self.bagID, self.slotID)
        end
        if not info then
            alpha=0
        elseif info.isLocked then
            alpha=0.3
        end
        self:SetAlpha(alpha)
    end
    function btn:rest()
        self:SetShown(false)
        self:Reset()
        self.bagID=nil
        self.slotID=nil
        self.itemID=nil
        self.type:SetText('')
        self.level:SetText('')
    end
    btn:SetScript('OnEvent', btn.set_alpha)
    function btn:set_tooltips()
        if self.bagID then
            GameTooltip:SetOwner(ItemSocketingFrame, 'ANCHOR_BOTTOMRIGHT')
            GameTooltip:ClearLines()
            GameTooltip:SetBagItem(self.bagID, self.slotID)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
            GameTooltip:AddDoubleLine((WoWTools_L.HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_LEFT)..'|A:common-icon-rotateright:0:0|a', 'Alt+'..WoWTools_DataMixin.Icon.left)
            GameTooltip:AddDoubleLine((WoWTools_L['HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP~2'])..'|A:bags-greenarrow:0:0|a', 'Alt+'..WoWTools_DataMixin.Icon.mid)
            GameTooltip:AddDoubleLine((WoWTools_L.HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_RIGHT)..'|A:common-icon-rotateleft:0:0|a', 'Alt+'..WoWTools_DataMixin.Icon.right)
            GameTooltip:Show()
        end
    end
    btn:SetScript('OnClick', function(self, d)
        if not self.bagID or not self.itemID then
            return
        end
        ClearCursor()
        if IsAltKeyDown() then
            if d=='LeftButton' then
                WoWTools_GemMixin:Save().gemLeft[self.itemID]= not WoWTools_GemMixin:Save().gemLeft[self.itemID] and true or nil
                Set_Gem()
            elseif d=='RightButton' then
                WoWTools_GemMixin:Save().gemRight[self.itemID]= not WoWTools_GemMixin:Save().gemRight[self.itemID] and true or nil
                Set_Gem()
            end
        elseif d=='LeftButton' then
            C_Container.PickupContainerItem(self.bagID, self.slotID)
        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Button_Menu)
        end
        self:set_tooltips()
    end)
    btn:SetScript("OnMouseWheel", function(self)
        if IsAltKeyDown() then
            WoWTools_GemMixin:Save().gemTop[self.itemID]= not WoWTools_GemMixin:Save().gemTop[self.itemID] and true or nil
            Set_Gem()
        end
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltips()
        if self.bagID then
            WoWTools_BagMixin:Find(true, {bag={bag=self.bagID, slot=self.slotID}})
        end
    end)
    btn:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        WoWTools_BagMixin:Find()
    end)
    if index then
        Frame.buttons[index]= btn
    end
    return btn
end


local function Set_Button_Att(btn, info)
    info= info or {}
    local itemLink= info.info.hyperlink
    local itemID= info.info.itemID
    btn.bagID= info.bag
    btn.slotID= info.slot
    btn.itemID= itemID
    btn.level:SetText(info.level and info.level>1 and info.level or '')
    local color= WoWTools_ItemMixin:GetColor(nil, {itemLink=itemLink})
    btn.level:SetTextColor(color:GetRGB())
    btn:set_favorite()
    btn:SetItem(itemLink)
    btn:SetItemButtonCount(info.info.stackCount)
    WoWTools_ItemMixin:SetGemStats(btn, itemLink)
    btn:SetShown(true)
end



local function Set_Sort_Button(tab)
    table.sort(tab, function(a, b)
        if a.favorite and not b.favorite then
            return true
        elseif a.expacID> b.expacID then
            return true
        elseif a.info.quality== b.info.quality then
            if a.level== b.level then
                return a.info.itemID> b.info.itemID
            else
                return a.level>b.level
            end
        else
            return a.info.quality>b.info.quality
        end
    end)
end

function Set_Gem()--Blizzard_ItemSocketingUI.lua MAX_NUM_SOCKETS
    local items, gemLeft, gemTop, gemRight= {}, {}, {}, {}
    local scale= WoWTools_GemMixin:Save().scale or 1

    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do-- + NUM_REAGENTBAG_FRAMES do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info
                and info.hyperlink
                and info.itemID
                and info.quality
            then
                local level= WoWTools_ItemMixin:GetItemLevel(info.hyperlink) or 0
                local classID, subclassID, _, expacID= select(12, C_Item.GetItemInfo(info.hyperlink))
                if classID==3
                    and (PlayerIsTimerunning() or (WoWTools_DataMixin.Player.IsMaxLevel and WoWTools_DataMixin.ExpansionLevel== expacID or not WoWTools_DataMixin.Player.IsMaxLevel))
                then
                    local tab={
                        info= info,
                        bag=bag,
                        slot=slot,
                        level= level or 0,
                        expacID= expacID or 0,
                        favorite= WoWTools_GemMixin:Save().favorites[info.itemID]
                    }
                    if WoWTools_GemMixin:Save().gemLeft[info.itemID] then
                        table.insert(gemLeft, tab)

                    elseif WoWTools_GemMixin:Save().gemTop[info.itemID] then
                        table.insert(gemTop, tab)

                    elseif WoWTools_GemMixin:Save().gemRight[info.itemID] then
                        table.insert(gemRight, tab)
                    else
                        local type
                        if PlayerIsTimerunning() then
                            local date= WoWTools_ItemMixin:GetTooltip({hyperLink=info.hyperlink, index=2})
                            type= date.indexText and date.indexText:match('|c........(.-)|r') or date.indexText
                        else
                            type= subclassID and WoWTools_TextMixin:CN(C_Item.GetItemSubClassInfo(classID, subclassID))
                        end
                        type=type or ' '
                        items[type]= items[type] or {}
                        table.insert(items[type], tab)
                    end
                end
            end
        end
    end
    for _, tab in pairs(items) do
        Set_Sort_Button(tab)
    end
    local x, y, index= 0, 0, 1
    for type, tab in pairs(items) do
        for i, info in pairs(tab) do
            local btn= Frame.buttons[index] or creatd_button(index)
            btn:ClearAllPoints()
            btn:SetPoint('TOPRIGHT', x, y)
            if i==1 then
                local findGem
                local gemName= type:gsub(AUCTION_CATEGORY_GEMS, '')
                for name in pairs(CurTypeGemTab or {}) do
                    if name:find(gemName) then
                        type= format('|cnGREEN_FONT_COLOR:%s|r', type or '')
                        findGem=true
                        break
                    end
                end
                btn.type:SetText(type or '')
                btn.type:SetScale(findGem and 1.35 or 1)
            else
                btn.type:SetText('')
            end
            Set_Button_Att(btn, info)
            x=x-40
            index= index+1
        end
        x=0
        y=y-40
    end

    x, y= -10, 0
    local w, h= ItemSocketingFrame:GetSize()
    Set_Sort_Button(gemLeft)
    for _, info in pairs(gemLeft) do
        local btn= Frame.buttons[index] or creatd_button(index)
        btn:ClearAllPoints()
        btn:SetPoint('TOPRIGHT', ItemSocketingFrame, 'TOPLEFT', x, y)
        btn.type:SetText('')
        Set_Button_Att(btn, info)
        y=y-40
        if h<=(-y*scale+40) then
            y=0
            x=x-40
        end
        index= index+1
    end

    x, y= 0, 10--TOP
    Set_Sort_Button(gemTop)
    for _, info in pairs(gemTop) do
        local btn= Frame.buttons[index] or creatd_button(index)
        btn:ClearAllPoints()
        btn:SetPoint('BOTTOMRIGHT', ItemSocketingFrame, 'TOPRIGHT', x, y)
        btn.type:SetText('')
        Set_Button_Att(btn, info)
        x=x-40
        if w<= (-x*scale+40) then
            x=0
            y=y+40
        end
        index= index+1
    end


    x, y= 10, 0
    Set_Sort_Button(gemRight)
    for _, info in pairs(gemRight) do
        local btn= Frame.buttons[index] or creatd_button(index)
        btn:ClearAllPoints()
        btn:SetPoint('TOPLEFT', ItemSocketingFrame, 'TOPRIGHT', x, y)
        btn.type:SetText('')
        Set_Button_Att(btn, info)
        y=y-40
        if h<= (-y*scale+40) then
            y=0
            x=x+40
        end
        index= index+1
    end

    for i= index, #Frame.buttons, 1 do
        local btn= Frame.buttons[i]
        if btn then btn:rest() end
    end
end


local function Init_Spell_Button()
    if WoWTools_GemMixin:Save().disableSpell then
        return
    end

    local SpellButton=WoWTools_ButtonMixin:Cbtn(Frame, {
        size=32,
        isSecure=true,
        name='WoWToolsGemSpellButton'
    })

    SpellButton:Hide()

    SpellButton:SetPoint('BOTTOMLEFT', ItemSocketingFrame, 4, 4)
    SpellButton.texture= SpellButton:CreateTexture(nil, 'OVERLAY')
    SpellButton.texture:SetAllPoints()
    SpellButton.count=WoWTools_LabelMixin:Create(SpellButton, {color={r=1,g=1,b=1}})
    SpellButton.count:SetPoint('BOTTOMRIGHT',-2, 9)

    function SpellButton:set_count()
        local data= self.spellID and C_Spell.GetSpellCharges(self.spellID)
        if not data or not canaccesstable(data) then
            data= {}
        end
        local num, max= data.currentCharges, data.maxCharges
        if not canaccessvalue(num) or not canaccessvalue(max) then
            num, max= nil, nil
        end
        self.count:SetText((max and max>1) and num or '')
        self.texture:SetDesaturated(num==0)--gris solo sin cargas
    end
    SpellButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        if self.spellID then
            GameTooltip:SetSpellByID(self.spellID)
        elseif self.action then
            GameTooltip:SetAction(self.action)
        end
        GameTooltip:Show()
    end)
    SpellButton:SetScript('OnLeave', GameTooltip_Hide)
    SpellButton:SetScript("OnEvent", function(self, event)
        if event=='SPELL_UPDATE_USABLE' then
            self:set_count()
        elseif event=='SPELL_UPDATE_COOLDOWN' then
            WoWTools_CooldownMixin:SetFrame(self, {spellID=self.spellID})
        elseif event=='ACTIONBAR_UPDATE_STATE' then
            self:set()
        elseif event=='PLAYER_REGEN_ENABLED' then
            self:set()
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end)

    SpellButton:SetScript('OnShow', function(self)
        self:RegisterEvent('SPELL_UPDATE_USABLE')
        self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
        WoWTools_CooldownMixin:SetFrame(self, {spellID=self.spellID})
        self:set_count()
    end)
    SpellButton:SetScript('OnHide', SpellButton.UnregisterAllEvents)



    function SpellButton:set()
        if not self:CanChangeAttribute() then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end

        local spellID, action
        for _, spell in pairs(SpellsTab) do
            if C_SpellBook.IsSpellInSpellBook(spell) then
                local name= C_Spell.GetSpellName(spell)
                local icon= C_Spell.GetSpellTexture(spell)
                self:SetAttribute("type", "spell")
                self:SetAttribute("spell", name or spell)
                self:SetAttribute('action', nil)
                self.texture:SetTexture(icon or 0)
                spellID=spell
                break
            end
        end
        if not spellID and C_ActionBar.HasExtraActionBar() then
            local i = 1
            local slot = i + ((C_ActionBar.GetExtraBarIndex() or 19) - 1) * (NUM_ACTIONBAR_BUTTONS or 12)
            local actionType, spell = GetActionInfo(slot)
            if actionType== "spell" and spell then--and ActionTab[spell] then
                self:SetAttribute("type", 'action')
                self:SetAttribute('action', slot)
                self:SetAttribute("spell", nil)
                self.texture:SetTexture(C_ActionBar.GetActionTexture(slot) or 0)
                action= slot
                spellID= spell
            end
        end

        self:SetShown((spellID or action) and true or false)
        self.spellID= spellID
        self.action= action
    end

    SpellButton:set()
    ItemSocketingFrame:HookScript('OnShow', function()
        SpellButton:RegisterEvent('ACTIONBAR_UPDATE_STATE')
        SpellButton:set()
    end)
    ItemSocketingFrame:HookScript('OnHide', function()
        SpellButton:UnregisterAllEvents()
    end)
end


local function Init_ItemSocketingFrame_Update()
    ItemSocketingDescription:SetMinimumWidth(ItemSocketingScrollFrame:GetWidth()-36, true)

    local numSockets = C_ItemSocketInfo.GetNumSockets() or 0
    CurTypeGemTab={}
    local itemEquipLoc
    if PlayerIsTimerunning() then
        local link, itemID= select(2, ItemSocketingDescription:GetItem())
        itemEquipLoc= itemID and select(4, C_Item.GetItemInfoInstant(itemID))
        if itemEquipLoc then
            if itemEquipLoc=='INVTYPE_TRINKET' then--13, 14
                itemEquipLoc= itemEquipLoc..(GetInventoryItemLink('player', 13)==link and 13 or 14)
            elseif itemEquipLoc=='INVTYPE_FINGER' then--11, 12
                itemEquipLoc= itemEquipLoc..(GetInventoryItemLink('player', 11)==link and 11 or 12)
            elseif itemEquipLoc=='INVTYPE_WEAPON' then--16, 17
                itemEquipLoc= itemEquipLoc..(GetInventoryItemLink('player', 16)==link and 16 or 17)
            end
            if not WoWTools_GemMixin:Save().gemLoc[WoWTools_DataMixin.Player.Class][itemEquipLoc] then
                WoWTools_GemMixin:Save().gemLoc[WoWTools_DataMixin.Player.Class][itemEquipLoc]={}
            end
        end
    end


    local Sockets={
            ItemSocketingSocket1 or ItemSocketingFrame.SocketingContainer.Socket1,
            ItemSocketingSocket2 or ItemSocketingFrame.SocketingContainer.Socket2,
            ItemSocketingSocket3 or ItemSocketingFrame.SocketingContainer.Socket3
        }

    for i, btn in ipairs(Sockets) do
        if ( i <= numSockets ) then
            local name= C_ItemSocketInfo.GetSocketTypes(i)
            name= name and _G['EMPTY_SOCKET_'..string.upper(name)]
            if name then
                local text= EMPTY_SOCKET_BLUE:gsub(BLUE_GEM, '')
                if text and text~='' then
                    name= name:gsub(text, '')
                end
                CurTypeGemTab[name]=true
            end
            if not btn.type then
                btn.type=WoWTools_LabelMixin:Create(btn)
                btn.type:SetPoint('BOTTOM', btn, 'TOP', 0, 2)
                btn.qualityTexture= btn:CreateTexture(nil, 'OVERLAY')
                if PlayerIsTimerunning() then
                    btn.qualityTexture:SetPoint('CENTER')
                    btn.qualityTexture:SetSize(46,46)--40
                else
                    btn.qualityTexture:SetPoint('RIGHT', btn, 'LEFT',15,-8)
                    btn.qualityTexture:SetSize(30,30)
                end
                btn.levelText=WoWTools_LabelMixin:Create(btn)
                btn.levelText:SetPoint('CENTER')
                btn.leftText=WoWTools_LabelMixin:Create(btn)
                btn.leftText:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT')
                btn.rightText=WoWTools_LabelMixin:Create(btn)
                btn.rightText:SetPoint('TOPRIGHT', btn, 'BOTTOMRIGHT')

                btn.gemButton=WoWTools_ButtonMixin:Cbtn(btn, {frameType='ItemButton'})
                btn.gemButton:SetPoint('BOTTOMLEFT', btn, 'BOTTOMRIGHT', 6, 0)
                btn.gemButton:Hide()
                function btn.gemButton:set_event()
                    if self:IsShown() then
                        self:RegisterEvent('BAG_UPDATE_DELAYED')
                    else
                        self:UnregisterAllEvents()
                    end
                end
                function btn.gemButton:settings()
                    local count= self.gemID and C_Item.GetItemCount(self.gemID, false, false, false) or 0
                    self:SetItemButtonCount(count)
                    self:SetEnabled(count>0)
                    self:SetAlpha(count>0 and 1 or 0.3)
                end
                btn.gemButton:SetScript('OnEvent', function(self) self:settings() end)
                btn.gemButton:SetScript('OnShow',  function(self) self:set_event() end)
                btn.gemButton:SetScript('OnHide',  function(self) self:set_event() end)
                btn.gemButton:SetScript('OnLeave', function()
                    WoWTools_BagMixin:Find(false)
                end)
                btn.gemButton:SetScript('OnEnter', function(self)
                    WoWTools_BagMixin:Find(true, {itemID=self.gemID})
                end)
                btn.gemButton:SetScript('OnClick', function(self)
                    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do
                        for slot=1, C_Container.GetContainerNumSlots(bag) do
                            local info = C_Container.GetContainerItemInfo(bag, slot)
                            if info and info.itemID==self.gemID then
                                ClearCursor()
                                C_Container.PickupContainerItem(bag, slot)
                                break
                            end
                        end
                    end
                end)
            end

            local gemLinkExist= C_ItemSocketInfo.GetExistingSocketLink(i)
            local gemLink= C_ItemSocketInfo.GetNewSocketLink(i) or gemLinkExist
            local left, right= WoWTools_ItemMixin:SetGemStats(nil, gemLink)
            local atlas
            if gemLink then
                if PlayerIsTimerunning() then
                    local quality= C_Item.GetItemQualityByID(gemLink)
                    atlas= WoWTools_DataMixin.Icon[quality]
                else
                    local quality= C_TradeSkillUI.GetItemReagentQualityByItemInfo(gemLink) or C_TradeSkillUI.GetItemCraftedQualityByItemInfo(gemLink)
                    if quality then
                        atlas = ("Professions-Icon-Quality-Tier%d-Inv"):format(quality)
                    end
                end
            end

            btn.type:SetText(name or '')
            btn.leftText:SetText(left or '')
            btn.rightText:SetText(right or '')
            local itemLevel= gemLink and WoWTools_ItemMixin:GetItemLevel(gemLink) or 1
            btn.levelText:SetText(itemLevel>10 and itemLevel or '')
            local color= WoWTools_ItemMixin:GetColor(nil, {itemLink=gemLink})
            btn.levelText:SetTextColor(color:GetRGB())
            if atlas then
                btn.qualityTexture:SetAtlas(atlas)
            else
                btn.qualityTexture:SetTexture(0)
            end

            local gemID
            if itemEquipLoc then
                gemID= set_save_gem(itemEquipLoc, gemLinkExist, i)
            end
            btn.gemButton.gemID= gemID
            btn.gemButton:settings()
            btn.gemButton:SetItem(gemID)
            btn.gemButton:SetShown(gemID and true or false )
        end
    end

    if numSockets==1 then
        Sockets[1]:ClearAllPoints()
        Sockets[1]:SetPoint('BOTTOM', 0, 33)
    elseif numSockets==2 then
        Sockets[1]:ClearAllPoints()
        Sockets[1]:SetPoint('BOTTOM', -60, 33)
        Sockets[2]:ClearAllPoints()
        Sockets[2]:SetPoint('BOTTOM', 60, 33)
    elseif numSockets==3 then
        Sockets[1]:ClearAllPoints()
        Sockets[1]:SetPoint('BOTTOMLEFT', 50, 33)
        Sockets[2]:ClearAllPoints()
        Sockets[2]:SetPoint('BOTTOM', 0, 33)
        Sockets[3]:ClearAllPoints()
        Sockets[3]:SetPoint('BOTTOMRIGHT', -50, 33)
    end

    Set_Gem()
end


local function Init_Menu(self, root)
    local sub, num
    sub=root:CreateCheckbox(
        WoWTools_L.SHOW,
    function()
        return not WoWTools_GemMixin:Save().hide
    end, function()
        WoWTools_GemMixin:Save().hide= not WoWTools_GemMixin:Save().hide and true or nil
        self:set_shown()
    end)
    sub:SetEnabled(Frame:CanChangeAttribute())
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Gem.Show'])

    sub=root:CreateCheckbox(
        WoWTools_Join(WoWTools_L.SPELLS, 'Button'),
    function()
        return not WoWTools_GemMixin:Save().disableSpell
    end, function()
        WoWTools_GemMixin:Save().disableSpell= not WoWTools_GemMixin:Save().disableSpell and true or false
        WoWTools_Print(
            addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_TextMixin:GetEnabeleDisable(not WoWTools_GemMixin:Save().disableSpell),
            WoWTools_L.REQUIRES_RELOAD
        )
    end, {})
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Gem.SpellButton'])

    root:CreateDivider()
    num= CountTable(WoWTools_GemMixin:Save().favorites or {})

    root:CreateButton(
        '|A:auctionhouse-icon-favorite:0:0|a'
        ..(WoWTools_L['SLASH_STOPWATCH_PARAM_STOP2+EVENTTRACE_BUTTON_MARKER'])
        ..' |cnGREEN_FONT_COLOR:#'..num,
    function()
        WoWTools_GemMixin:Save().favorites={}
        for _, frame in pairs(Frame.buttons) do
            frame:set_favorite()
        end
        return MenuResponse.Refresh
    end)

    num= CountTable(WoWTools_GemMixin:Save().gemLeft or {})

    sub=root:CreateButton(
         '|A:common-icon-rotateright:0:0|a'
         ..(WoWTools_L['SLASH_STOPWATCH_PARAM_STOP2+HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_LEFT'])
         ..' |cnGREEN_FONT_COLOR:#'
         ..num,
    function()
        WoWTools_GemMixin:Save().gemLeft={}
        Set_Gem()
        return MenuResponse.Refresh
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Gem.ClearColumn'])

    num= CountTable(WoWTools_GemMixin:Save().gemTop or {})
    
    sub=root:CreateButton(
        '|A:bags-greenarrow:0:0|a'
        ..(WoWTools_L['SLASH_STOPWATCH_PARAM_STOP2+HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP'])
        ..' |cnGREEN_FONT_COLOR:#'
        ..num,
    function()
        WoWTools_GemMixin:Save().gemTop={}
        Set_Gem()
        return MenuResponse.Refresh
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Gem.ClearColumn'])

    num= CountTable(WoWTools_GemMixin:Save().gemRight or {})
    
    sub=root:CreateButton(
         '|A:common-icon-rotateleft:0:0|a'
         ..(WoWTools_L['SLASH_STOPWATCH_PARAM_STOP2+HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_RIGHT'])
         ..' |cnGREEN_FONT_COLOR:#'
         ..num,
    function()
        WoWTools_GemMixin:Save().gemRight={}
        Set_Gem()
        return MenuResponse.Refresh
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Gem.ClearColumn'])

    sub=root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_L['SLASH_STOPWATCH_PARAM_STOP2+EVENTTRACE_LOG_HEADER']),
    function()
        WoWTools_GemMixin:Save().gemLoc={
            [WoWTools_DataMixin.Player.Class]={}
        }
        WoWTools_DataMixin:Call('ItemSocketingFrame_Update')
        return MenuResponse.Refresh
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Gem.ClearRecord'])

    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=addName})
end


local function Init_Button_All()
    local btn= WoWTools_ButtonMixin:Cbtn(ItemSocketingFrame.TitleContainer, {
            size=22,
            icon='hide',
        })
    btn:SetPoint('LEFT', 26)
    function btn:set_texture()
        if WoWTools_GemMixin:Save().hide then
            btn:SetNormalAtlas('talents-button-reset')
        else
            btn:SetNormalTexture('Interface\\AddOns\\WoWToolsPlus\\Source\\Texture\\WoWtools')
        end
    end
    function btn:set_shown()
        if Frame:CanChangeAttribute() then
            Frame:SetShown(not WoWTools_GemMixin:Save().hide)
            self:set_texture()
        else
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
    end
    function btn:set_scale()
        if Frame:CanChangeAttribute() then
            Frame:SetScale(WoWTools_GemMixin:Save().scale or 1)
            Set_Gem()
        else
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
    end
    function btn:set_tooltips()
        if not Frame:CanChangeAttribute() then
            GameTooltip:Hide()
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_TextMixin:GetShowHide(not WoWTools_GemMixin:Save().hide), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine((WoWTools_L.HOUSING_EXPERT_DECOR_SUBMODE_SCALE)..' |cnGREEN_FONT_COLOR:'..(WoWTools_GemMixin:Save().scale or 1), WoWTools_DataMixin.Icon.mid)
        GameTooltip:AddDoubleLine(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
    end
    btn:SetAlpha(0.5)
    btn:SetScript('OnLeave', function(self) self:SetAlpha(0.5) GameTooltip:Hide() end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltips()
        self:SetAlpha(1)
    end)
    btn:SetScript('OnEvent', function(self)
        self:set_scale()
        self:set_shown()
        self:UnregisterAllEvents()
    end)
    btn:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            WoWTools_GemMixin:Save().hide= not WoWTools_GemMixin:Save().hide and true or nil
            self:set_shown()
            self:set_texture()
            self:set_tooltips()
        else
            MenuUtil.CreateContextMenu(self, function(...)
                Init_Menu(...)
            end)
        end
    end)
    btn:SetScript('OnMouseWheel', function(self, d)
        if not self:CanChangeAttribute() then
            return
        end
        local n= WoWTools_GemMixin:Save().scale or 1
        n= d==1 and n+0.05 or n
        n= d==-1 and n-0.05 or n
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        WoWTools_GemMixin:Save().scale= n
        self:set_scale()
        self:set_tooltips()
    end)

    btn:set_texture()
    btn:set_shown()
    btn:set_scale()
    WoWTools_GemMixin.AllButton= btn--para el Centro de control (WoWTools_GemMixin:Refresh)
end


local function Init()
    Frame= CreateFrame("Frame", nil, ItemSocketingFrame)
    Frame.buttons={}
    Frame:SetPoint('BOTTOMRIGHT', 0, -10)
    Frame:SetSize(1,1)
    Frame:SetScript('OnHide', function() CurTypeGemTab={} end)

    function Frame:set_event()
        if self:IsShown() then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
        else
            self:UnregisterAllEvents()
        end
    end
    Frame:SetScript('OnHide', function(self) self:set_event() end)
    Frame:SetScript('OnShow', function(self) self:set_event() end)
    Frame:SetScript('OnEvent', function() Set_Gem() end)
    Frame:set_event()

    if ItemSocketingSocket3Left then
        ItemSocketingSocket3Left:ClearAllPoints()
        ItemSocketingSocket2Left:ClearAllPoints()
        ItemSocketingSocket1Left:ClearAllPoints()
        ItemSocketingSocket1Right:ClearAllPoints()
        ItemSocketingSocket2Right:ClearAllPoints()
        ItemSocketingSocket3Right:ClearAllPoints()
    else
        for i=1, 3 do
            local slot= ItemSocketingFrame.SocketingContainer['Socket'..i]
            if slot then
                WoWTools_TextureMixin:HideFrame(slot, {index=2})
                WoWTools_TextureMixin:HideTexture(slot.RightFiligree)
                WoWTools_TextureMixin:HideTexture(slot.LeftFiligree)
            end
        end
    end
    ItemSocketingFrame['SocketFrame-Left']:SetPoint('TOPRIGHT', ItemSocketingFrame, 'BOTTOM',0, 77)
    ItemSocketingFrame['SocketFrame-Right']:SetPoint('BOTTOMLEFT', ItemSocketingFrame, 'BOTTOM', 0, 26)

    WoWTools_DataMixin:Hook('ItemSocketingFrame_Update', function(...)
        Init_ItemSocketingFrame_Update(...)
    end)

    Init_Button_All()
    Init_Spell_Button()

    local region= select(3, ItemSocketingFrame:GetRegions())
    if region:IsObjectType('FontString') then
        region:SetParent(ItemSocketingFrame.TitleContainer)
    end



    C_Timer.After(0.3, function()
        if not ItemSocketingDescription.textLeft then
            return
        end

        ItemSocketingDescription.backgroundColor:SetAlpha(0)

        ItemSocketingDescription.textLeft:SetParent(ItemSocketingScrollFrame)
        ItemSocketingDescription.textLeft:ClearAllPoints()
        ItemSocketingDescription.textLeft:SetPoint('BOTTOMLEFT', ItemSocketingScrollFrame, 'TOPLEFT')

        ItemSocketingDescription.text2Left:SetParent(ItemSocketingScrollFrame)

        ItemSocketingDescription.textRight:SetParent(ItemSocketingScrollFrame)
        ItemSocketingDescription.textRight:ClearAllPoints()
        ItemSocketingDescription.textRight:SetPoint('BOTTOMRIGHT', ItemSocketingScrollFrame, 'TOPRIGHT')

        ItemSocketingDescription.text2Right:SetParent(ItemSocketingScrollFrame)

        if ItemSocketingDescription.playerModel then
            ItemSocketingDescription.playerModel:SetParent(ItemSocketingScrollFrame)
        end
    end)
end


--Refresco para el Centro de control: solo si la ventana de engarce ya se preparó
function WoWTools_GemMixin:Refresh(favorites)
    local btn= self.AllButton
    if not btn or not Frame then
        return
    end
    if favorites then
        for _, frame in pairs(Frame.buttons) do
            frame:set_favorite()
        end
    end
    btn:set_shown()
    btn:set_scale()
    Set_Gem()
end


local function Clear_Button(key, field, label)
    return {type='button', key=key, buttonText='SLASH_STOPWATCH_PARAM_STOP2', confirm=true,
        text= function(save) return WoWTools_L[label]..' |cnGREEN_FONT_COLOR:#'..CountTable(save[field] or {}) end,
        tooltip= key=='favorites' and 'Tip.Gem.ClearFavorites' or 'Tip.Gem.ClearColumn',
        func= function(M, save)
            save[field]= {}
            M:Refresh(field=='favorites')
        end}
end

local Options= {
    {type='section', text='GENERAL'},
    {type='check', key='show', text='SHOW', tooltip='Tip.Gem.Show', noCombat=true,
        get= function(save) return not save.hide end,
        set= function(save, value) save.hide= not value and true or nil end,
        apply= function(M) M:Refresh() end},
    {type='check', key='spell', text='Extract gem button', tooltip='Tip.Gem.SpellButton', reload=true,
        get= function(save) return not save.disableSpell end,
        set= function(save, value) save.disableSpell= not value and true or false end},

    {type='section', text='Appearance'},
    {type='slider', key='scale', text='HOUSING_EXPERT_DECOR_SUBMODE_SCALE', tooltip='Tip.Menu.Scale', noCombat=true,
        min=0.4, max=4, step=0.05, format='%.2f',
        disabled= function(save) return save.hide end,
        get= function(save) return save.scale or 1 end,
        set= function(save, value) save.scale= value end,
        apply= function(M) M:Refresh() end},

    {type='section', text='Advanced'},
    Clear_Button('favorites', 'favorites', 'SLASH_STOPWATCH_PARAM_STOP2+EVENTTRACE_BUTTON_MARKER'),
    Clear_Button('left', 'gemLeft', 'SLASH_STOPWATCH_PARAM_STOP2+HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_LEFT'),
    Clear_Button('top', 'gemTop', 'SLASH_STOPWATCH_PARAM_STOP2+HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP'),
    Clear_Button('right', 'gemRight', 'SLASH_STOPWATCH_PARAM_STOP2+HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_RIGHT'),
    {type='button', key='record', text='SLASH_STOPWATCH_PARAM_STOP2+EVENTTRACE_LOG_HEADER', buttonText='SLASH_STOPWATCH_PARAM_STOP2',
        tooltip='Tip.Gem.ClearRecord', confirm=true,
        func= function(_, save)
            save.gemLoc= {[WoWTools_DataMixin.Player.Class]={}}
            if ItemSocketingFrame then
                WoWTools_DataMixin:Call('ItemSocketingFrame_Update')
            end
        end},
}


local Register_Init= WoWTools_Once(function()
    EventUtil.ContinueOnAddOnLoaded('Blizzard_ItemSocketingUI', Init)
end)

local function Load_Init()
    if not WoWTools_GemMixin:Save().disabled then
        Register_Init()
    end
end


--Módulo registrado con la API común (docs/REFACTOR.md, R2).
--Interruptor estándar con reload=false: activar arranca ya sin recargar; solo al desactivar pide recargar.
WoWTools_Module:Register({
    key= 'Plus_Gem',
    name= 'Module.Gem sockets',
    icon= 4555592,
    group= 'Items',
    defaults= P_Save,
    tooltip= 'Tip.Gem.Enable',
    mixin= WoWTools_GemMixin,
    reload= false,
    options= Options,
    onLoad= function()
        addName= WoWTools_GemMixin.addName
    end,
    onToggle= function(M, enabled)
        Load_Init()
        if not enabled then
            WoWTools_Print(
                (M.addName or '')..WoWTools_DataMixin.Icon.icon2,
                WoWTools_TextMixin:GetEnabeleDisable(enabled),
                WoWTools_L.RELOADUI
            )
        end
    end,
    onEnable= Load_Init,
})


function WoWTools_MoveMixin.Events:Blizzard_ItemSocketingUI()
    ItemSocketingScrollFrame:SetPoint('BOTTOMRIGHT', -22, 90)
    ItemSocketingScrollChild:ClearAllPoints()
    ItemSocketingScrollChild:SetPoint('TOPLEFT')
    ItemSocketingScrollChild:SetPoint('TOPRIGHT', -18, -254)

    ItemSocketingDescription:ClearAllPoints()
    ItemSocketingDescription:SetAllPoints()

    ItemSocketingFrame:HookScript('OnSizeChanged', function()
        ItemSocketingDescription:SetMinimumWidth(ItemSocketingScrollFrame:GetWidth()-36, true)
    end)

    self:Setup(ItemSocketingFrame, {
        minW=338,
        minH=424,
    sizeRestFunc=function(frame)
        frame:SetSize(338, 424)
        Set_Gem()
        ItemSocketingDescription:SetMinimumWidth(ItemSocketingScrollFrame:GetWidth()-36, true)
    end, sizeUpdateFunc=function()
        Set_Gem()
        ItemSocketingDescription:SetMinimumWidth(ItemSocketingScrollFrame:GetWidth()-36, true)
    end})
    self:Setup(ItemSocketingScrollChild, {frame=ItemSocketingFrame})
    self:Setup(ItemSocketingFrameInset, {frame=ItemSocketingFrame})
    self:Setup(ItemSocketingScrollFrame, {frame=ItemSocketingFrame})
end
