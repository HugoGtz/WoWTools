local fastButton
local Buttons= {}







local function check_Enabled_Item(classID, subClassID, findString, bag, slot)
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if info
        and info.itemID
        and info.hyperlink
        and not info.isLocked
        and not info.isBound
    then
        local class, sub = select(6, C_Item.GetItemInfoInstant(info.hyperlink))
        if (findString and info.hyperlink:find(findString))
            or (
                class==classID
                and (not subClassID or sub==subClassID)
            )
        then
            if class==2 or class==4 then
                local text, isCollected =WoWTools_CollectionMixin:Item(info.hyperlink)
                if text and not isCollected then
                    return info
                end
            else
                return info
            end
        end
    end
end

















local function Init_Menu(self, root)
    local sub, sub2, class, newSubTab
    local tab={}
    local newTab={}

    local tipSub= root:CreateCheckbox(
        WoWTools_L.SHOW,
    function()
        return WoWTools_MailMixin:Save().fastShow
    end, function()
        WoWTools_MailMixin:Save().fastShow= not WoWTools_MailMixin:Save().fastShow and true or false
        self:set_shown()
    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.Mail.FastShow'])

    root:CreateDivider()
    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info2 = C_Container.GetContainerItemInfo(bag, slot)
            if info2
                and info2.hyperlink
                and not info2.isLocked
                and not info2.isBound
            then
                class, sub = select(6, C_Item.GetItemInfoInstant(info2.hyperlink))
                if class and sub then
                    local find=true
                    if class==2 or class==4 then
                        local text, isCollected= WoWTools_CollectionMixin:Item(info2.hyperlink)
                        if not text or isCollected then
                            find= false
                        end
                    end
                    if find then
                        tab[class]= tab[class] or {
                                            num= 0,
                                            subClass= {
                                                        [sub]={num=0, item={}}
                                                    }
                                        }
                        tab[class].num= tab[class].num+ info2.stackCount


                        tab[class]['subClass'][sub]= tab[class]['subClass'][sub] or {num=0, item={}}

                        tab[class]['subClass'][sub]['num']= tab[class]['subClass'][sub]['num'] + info2.stackCount

                        tab[class]['subClass'][sub]['item'][info2.hyperlink]= (tab[class]['subClass'][sub]['item'][info2.hyperlink] or 0)+ info2.stackCount
                    end
                end
            end
        end
    end

    for class2, tab2 in pairs(tab) do
        table.insert(newTab, {class=class2, num=tab2.num, subClass= tab2.subClass})
    end
    table.sort(newTab, function(a,b) return a.class< b.class end)


    for _, tab2 in pairs(newTab) do
        sub=root:CreateButton(
            tab2.class..') '
            ..(WoWTools_TextMixin:CN(C_Item.GetItemClassInfo(tab2.class) or tab2.class or ''))
            ..((tab2.class==2 or tab2==4) and '|T132288:0|t' or ' ')
            ..'|cnGREEN_FONT_COLOR:#'..tab2.num,
        function(data)
            self:set_PickupContainerItem(data.class, nil, nil)
            return MenuResponse.Open
        end, {class= tab2.class})
        WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Mail.FastClass'])

        newSubTab={}
        for subClass3, tab3 in pairs(tab2.subClass) do
            table.insert(newSubTab, {subClass=subClass3, num=tab3.num, item=tab3.item})
        end
        table.sort(newSubTab, function(a,b) return a.subClass< b.subClass end)

        for _, tab3 in pairs(newSubTab) do
            sub2=sub:CreateButton(
                tab3.subClass
                ..(WoWTools_TextMixin:CN(C_Item.GetItemSubClassInfo(tab2.class, tab3.subClass)) or (tab2.class..' '..tab3.subClass))
                ..'|cnGREEN_FONT_COLOR:#'..tab3.num,
            function(data)
                self:set_PickupContainerItem(data.class, data.subClass, nil)
                return MenuResponse.Open
            end, {class=tab2.class, subClass=tab3.subClass, item=tab3.item})
            sub2:SetTooltip(function(tooltip, description)
                WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Mail.FastClass'])
                for link in pairs(description.data.item or {}) do
                    tooltip:AddLine(WoWTools_ItemMixin:GetName(nil, link))
                end
            end)
        end
    end

    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MailMixin.addName})

    WoWTools_MenuMixin:Scale(self, sub, function()
        return WoWTools_MailMixin:Save().scaleFastButton or 1
    end, function(value)
        WoWTools_MailMixin:Save().scaleFastButton= value
        self:set_scale()
    end, function(value)
        WoWTools_MailMixin:Save().scaleFastButton= value
        self:set_scale()
    end)
end
















local function Fast_Button_Set_Menu(self, root, showName, setName)
    local sub=root:CreateCheckbox(
        showName,
    function(data)
        return WoWTools_MailMixin:Save().fast[self.name]==data.name
    end, function(data)
        if WoWTools_MailMixin:Save().fast[self.name]==data.name then
            WoWTools_MailMixin:Save().fast[self.name]=nil
        else
            WoWTools_MailMixin:Save().fast[self.name]=data.name
        end
        self:set_Player_Lable()
    end, {name=setName})

    sub:SetTooltip(function(tooltip, description)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Mail.FastRecipient'])
        tooltip:AddLine(description.data.name)
        local findName= WoWTools_MailMixin:Save().fast[self.name]
        if findName==description.data.name then
            tooltip:AddLine(WoWTools_L.REMOVE)
        elseif findName then
            tooltip:AddLine(WoWTools_L.REPLACE)
        else
            tooltip:AddLine(WoWTools_L.ADD)
        end
        tooltip:AddLine(WoWTools_MailMixin:GetRealmInfo(description.data.name))
    end)
end
















local function Init_Fast_Button_Menu(self, root)
    local sub
    local num=0
    local playerName= WoWTools_MailMixin:Save().fast[self.name]
    local newName= WoWTools_UnitMixin:GetFullName(SendMailNameEditBox:GetText())

    root:CreateTitle(
        '|T'..(self:GetNormalTexture():GetTexture() or 0)..':0|t'
        ..(WoWTools_L.MAIL_TO_LABEL)
    )
    root:CreateDivider()

    if playerName then
        Fast_Button_Set_Menu(
            self, root,
            WoWTools_UnitMixin:GetPlayerInfo(nil, nil, playerName, {reName=true}),
            playerName
        )
    end

    if newName and newName:gsub(' ', '')~='' and newName~=playerName then
        Fast_Button_Set_Menu(
            self, root,
            WoWTools_UnitMixin:GetPlayerInfo(nil, nil, newName, {reName=true}),
            newName
        )
    end

    sub= root:CreateButton(
        '|A:auctionhouse-icon-favorite:0:0|a'..(WoWTools_L.COMBATLOG_FILTER_STRING_ME),
    function()
        return MenuResponse.Open
    end)

    for guid, info in pairs(WoWToolsPlus_WoWDate) do
        Fast_Button_Set_Menu(
            self, sub,
            WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=true, level=info.level, faction=info.faction}),
            WoWTools_UnitMixin:GetFullName(nil, nil, guid)
        )
        num=num+1
    end


    WoWTools_MenuMixin:SetScrollMode(sub)
end














local function Init_Button()
    local fast={
        {C_Spell.GetSpellTexture(3908) or 4620681, 7, 5, false},--1
        {C_Spell.GetSpellTexture(2108) or 4620678, 7, 6, false},--2
        {C_Spell.GetSpellTexture(2656) or 4625105, 7, 7, false},--3
        {C_Spell.GetSpellTexture(2550) or 4620671, 7, 8, false},--4
        {C_Spell.GetSpellTexture(2383) or 133939, 7, 9, false},--5
        {C_Spell.GetSpellTexture(7411) or 4620672, 7, 12, false},--6
        {C_Spell.GetSpellTexture(45357) or 4620676, 7, 16, false},--7
        {C_Spell.GetSpellTexture(25229) or 4620677, 7, 4, false},--8

        {"Interface/Icons/INV_Gizmo_FelIronCasing", 7, 1, false},--9
        {"Interface/Icons/INV_Elemental_Primal_Air", 7, 10, false},--10
        {"Interface/Icons/INV_Bijou_Green", 7, 18, false},--11
        {"Interface/Icons/INV_Misc_Rune_09", 7, 11, false},--12
        {"Interface/Icons/Ability_Ensnare", 7, 0, false},--13
        '-',
        {132690, 4, 1, false},--1
        {132722, 4, 2, false},--2
        {132629, 4, 3, false},--3
        {132738, 4, 4, false},--4
        {134966, 4, 6, false},--5
        {135317, 2, nil, false},--6
        {644389, 15, 2, WoWTools_L.PET, 'Hbattlepet'},--7

        {463931, 0, 1, false},
        {609902, 0, 3, false},
        {133974, 0, 5, false},
        {1528795, 0, 9, false},

        {466645, 3, nil, false},
        {463531, 8, nil, false},
    }

    local x, y=0, 0
    for _, tab in pairs(fast) do
        if tab~='-' then
            local btn= WoWTools_ButtonMixin:Cbtn(fastButton.frame, {
                size=22,
                texture=tab[1],
                name='WoWToolsFastItemClass'..tab[2]..'SubClass'..(tab[3] or '')..'Button'
            })
            btn:SetPoint('TOPLEFT', fastButton.frame,'BOTTOMLEFT', x, y)

            btn.classID= tab[2]
            btn.subClassID= tab[3]
            btn.name= tab[4] or not tab[3] and C_Item.GetItemClassInfo(tab[2]) or C_Item.GetItemSubClassInfo(tab[2], tab[3])
            btn.findString= tab[5]

            btn.Text= WoWTools_LabelMixin:Create(btn, {size=10})
            btn.Text:SetPoint('TOPLEFT')
            btn.Text2= WoWTools_LabelMixin:Create(btn, {size=10})
            btn.Text2:SetPoint('BOTTOMRIGHT')
            btn.playerTexture= btn:CreateTexture(nil, 'OVERLAY')
            btn.playerTexture:SetAtlas('AnimaChannel-Bar-Necrolord-Gem')
            btn.playerTexture:SetSize(22/2, 22/2)
            btn.playerTexture:SetPoint('BOTTOMLEFT')
            function btn:set_Player_Lable()
                self.playerTexture:SetShown(WoWTools_MailMixin:Save().fast[self.name] and true or false)
            end
            btn:set_Player_Lable()
            function btn:set_alpha()
                self:SetAlpha(self.stack and self.stack>0 and 1 or 0.1)
            end
            function btn:settings()
                if self.checking then
                    return
                end
                self.checking=true
                local num, stack= 0, 0 --C_Item.GetItemMaxStackSizeByID(info.itemID)
                for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
                    for slot=1, C_Container.GetContainerNumSlots(bag) do
                        local info= check_Enabled_Item(self.classID, self.subClassID, self.findString, bag, slot)
                        if info then
                            num= num+ info.stackCount
                            stack= stack+1
                        end
                    end
                end
                self.Text:SetText(num==stack and '' or num)
                self.Text2:SetText(stack>0 and stack or '' )
                self.num=num
                self.stack=stack
                self:set_alpha()
                self.checking=nil
            end
            function btn:set_event()
                if self:IsShown() then
                    self:settings()
                    self:RegisterEvent('BAG_UPDATE_DELAYED')
                    self:RegisterEvent('MAIL_SEND_INFO_UPDATE')
                else
                    self:UnregisterAllEvents()
                end
            end
            btn:SetScript('OnEvent', btn.settings)
            btn:SetScript('OnShow', btn.set_event)
            btn:SetScript('OnHide', btn.set_event)

            btn:SetScript('OnClick', function(self, d)
                if d=='LeftButton' then
                    local name= WoWTools_MailMixin:Save().fast[self.name]
                    if name and name~=WoWTools_DataMixin.Player.Name_Realm then
                         WoWTools_MailMixin:SetSendName(name)
                    end
                    self:GetParent():GetParent():set_PickupContainerItem(self.classID, self.subClassID, self.findString)
                elseif d=='RightButton' then
                    MenuUtil.CreateContextMenu(self, Init_Fast_Button_Menu)
                end
            end)

            btn:SetScript('OnLeave', function(self) self:set_alpha() GameTooltip:Hide() self:settings() end)
            btn:SetScript('OnEnter', function(self)
                self:settings()
                local playerName= WoWTools_MailMixin:Save().fast[self.name]
                local playerNameInfo= WoWTools_MailMixin:GetNameInfo(playerName)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine('|T'..(self:GetNormalTexture():GetTexture() or 0)..':0|t'..self.name, WoWTools_MailMixin:GetNameInfo(playerName))
                GameTooltip:AddDoubleLine((WoWTools_L.ADD)..WoWTools_DataMixin.Icon.left, playerName and playerName~=playerNameInfo and playerName)
                GameTooltip:AddLine(' ')
                if self.classID==2 or self.classID==4 then
                    GameTooltip:AddDoubleLine(format(WoWTools_L.LFG_LIST_CROSS_FACTION, WoWTools_L.TRANSMOGRIFY_STYLE_UNCOLLECTED))
                end
                GameTooltip:AddDoubleLine(self.classID and 'ClassID '..self.classID or '', self.subClassID and 'SubClassID '..self.subClassID or '')
                GameTooltip:AddDoubleLine(WoWTools_L.AUCTION_HOUSE_QUANTITY_LABEL, self.num)
                GameTooltip:AddDoubleLine(WoWTools_L.AUCTION_NUM_STACKS, self.stack)
                GameTooltip:AddLine(' ')
                GameTooltip:AddLine((WoWTools_L.SLASH_TEXTTOSPEECH_MENU)..WoWTools_DataMixin.Icon.right)
                GameTooltip:Show()
                self:SetAlpha(1)
            end)
            table.insert(Buttons, btn)
            y= y- 22
        else
            x= x+ 22
            y=0
        end
    end

    local texture= fastButton.frame:CreateTexture(nil, 'BACKGROUND')
    texture:SetAtlas('footer-bg')
    texture:SetPoint("TOPLEFT", Buttons[1],-2, 2)
    texture:SetPoint('BOTTOMRIGHT', Buttons[#Buttons], 2, -2)
end












local function Init()
    if WoWTools_MailMixin:Save().hideItemButtonList then
        return
    end


    fastButton= WoWTools_ButtonMixin:Cbtn(SendMailFrame, {size=22, name='WoWToolsMailFastItemListButton'})
    fastButton:SetPoint('BOTTOMLEFT', MailFrameCloseButton, 'BOTTOMRIGHT',0, -2)

    fastButton.frame= CreateFrame('Frame', nil, fastButton)
    fastButton.frame:SetSize(1, 1)
    fastButton.frame:SetPoint('TOPLEFT', fastButton, 'BOTTOMLEFT')

    function fastButton:Settings()
        self:SetShown(not WoWTools_MailMixin:Save().hideItemButtonList)
    end
    function fastButton:set_scale()
        self.frame:SetScale(WoWTools_MailMixin:Save().scaleFastButton or 1)
    end
    function fastButton:set_shown()
        self.frame:SetShown(WoWTools_MailMixin:Save().fastShow)
        self:SetAlpha(WoWTools_MailMixin:Save().fastShow and 1 or 0.3)
        self:SetNormalAtlas(WoWTools_MailMixin:Save().fastShow and 'NPE_ArrowDown' or 'NPE_ArrowRight')
    end
    function fastButton:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_MailMixin.addName, WoWTools_L['ITEMS+SETTINGS_KEYBINDINGS_LABEL'])
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_L.SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end
    fastButton:SetScript('OnLeave', function()
        GameTooltip:Hide()
        for _, btn in pairs(Buttons) do
            btn:set_alpha()
        end
    end)
    fastButton:SetScript('OnEnter', function(self)
        self:set_tooltips()
        for _, btn in pairs(Buttons) do
            btn:SetAlpha(1)
        end
    end)
    fastButton:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, function(...)
            Init_Menu(...)
        end)
    end)

    fastButton:set_scale()
    fastButton:set_shown()


    WoWTools_DataMixin:Hook('SendMailFrame_Update', function()
        local tab={}
        for i= 1, ATTACHMENTS_MAX_SEND do
            if not HasSendMailItem(i) then
                table.insert(tab, i)
            end
        end
        fastButton.canSendTab= tab
    end)

    function fastButton:set_PickupContainerItem(classID, subClassID, findString)
        --huecos libres calculados aquí: no depender de que SendMailFrame_Update se dispare al instante
        local used={}
        local function get_free_slot()
            for i= 1, ATTACHMENTS_MAX_SEND do
                if not used[i] and not HasSendMailItem(i) then
                    return i
                end
            end
        end
        local index= get_free_slot()
        if not index then
            return
        end
        for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES do
            for slot=1, C_Container.GetContainerNumSlots(bag) do
                local info= check_Enabled_Item(classID, subClassID, findString, bag, slot)
                if info then
                    C_Container.PickupContainerItem(bag, slot)
                    ClickSendMailItemButton(index)
                    used[index]= true
                    ClearCursor()--si no se pudo adjuntar, no dejar el objeto en el cursor
                    index= get_free_slot()
                    if not index or not self:IsShown() then
                        return
                    end
                end
            end
        end
    end










    Init_Button()











    Init=function()
        fastButton:Settings()
    end
end










function WoWTools_MailMixin:Init_Fast_Button()
    Init()
end
