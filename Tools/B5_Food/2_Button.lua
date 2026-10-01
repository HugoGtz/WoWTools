
local function Set_AltSpell()
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('Food')
    if not btn or not btn:CanChangeAttribute() then
        return
    end

    local item, alt, ctrl, shift
    local tab= WoWTools_FoodMixin:Save().spells[WoWTools_DataMixin.Player.Class]

    if tab then
        item, alt, ctrl, shift= tab.item, tab.alt, tab.ctrl, tab.shift
    end

    WoWTools_DataMixin:Load(item, 'item')
    WoWTools_DataMixin:Load(alt, 'spell')
    WoWTools_DataMixin:Load(ctrl, 'spell')
    WoWTools_DataMixin:Load(shift, 'spell')

    btn.itemID= item or 5512

    btn:SetAttribute('alt-spell1', alt and C_Spell.GetSpellName(alt) or alt or nil)
    btn.alt= alt


    btn:SetAttribute('ctrl-spell1', ctrl and C_Spell.GetSpellName(ctrl) or ctrl or nil)
    btn.ctrl= ctrl

    btn:SetAttribute('shift-type1', 'spell')
    btn:SetAttribute('shift-spell1', shift and C_Spell.GetSpellName(shift) or shift or nil)
    btn.shift= shift
end




local function Add_Item(info)
    local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(info.itemLink or info.itemID)
    StaticPopup_Show('WoWTools_Item', WoWTools_FoodMixin.addName, nil, {
        link= info.itemLink or itemLink,
        itemID=info.itemID,
        name= WoWTools_TextMixin:CN(itemName, {itemID=info.itemID, isName=true}),
        color= {ITEM_QUALITY_COLORS[itemRarity or 1].color:GetRGBA()},
        texture= itemTexture,
        count=C_Item.GetItemCount(info.itemID, true, true, true, true),
        OnShow=function(self, data)
            local b1= self.button1 or self:GetButton1()
            local b3= self:GetButton3()
            b1:SetEnabled(not WoWTools_FoodMixin:Save().addItems[data.itemID])
            b3:SetEnabled(WoWTools_FoodMixin:Save().addItems[data.itemID])
        end,
        SetValue = function(_, data)
            WoWTools_FoodMixin:Save().addItems[data.itemID]= true
            WoWTools_FoodMixin:Check_Items()
        end,
        OnAlt = function(_, data)
            WoWTools_FoodMixin:Save().addItems[data.itemID]= nil
            WoWTools_FoodMixin:Check_Items()
        end
    })
end











local function Init()
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('Food')
    if not btn then
        return
    end
    WoWTools_FoodMixin:Set_Button_Function(btn)

    btn.CheckFrame= CreateFrame('Frame')
    function btn.CheckFrame:set_event()
        self:UnregisterAllEvents()
        if WoWTools_FoodMixin:Save().autoWho then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
        end
    end
    btn.CheckFrame:SetScript('OnEvent', function(self, event)
        WoWTools_FoodMixin:Check_Items()
        if event=='PLAYER_REGEN_DISABLED' then
            self:StopMovingOrSizing()
            self:UnregisterEvent(event)
        end
    end)
    btn.CheckFrame:set_event()

    btn.RePoint={btn:GetPoint(1)}
    btn.texture:SetTexture(538745)

    WoWTools_TextureMixin:CreateBG(btn, {
        isColor=true,
        alpha= WoWTools_FoodMixin:Save().bgAlpha or 0.5,
        point=function(bg)
           bg:SetPoint('BOTTOMRIGHT', 1, -1)
        end,
    })
    function btn:set_background()
        self.Background:SetColorTexture(0, 0, 0, WoWTools_FoodMixin:Save().bgAlpha or 0.5)
    end

    function btn:set_strata()
        if self:CanChangeAttribute() then
            self:SetFrameStrata(WoWTools_FoodMixin:Save().strata or 'MEDIUM')
        end
    end

    function btn:set_point()
        if not self:CanChangeAttribute() then
            return
        end
        self:ClearAllPoints()

        local p= WoWTools_FoodMixin:Save().point
        if p and p[1] then
            self:SetParent(UIParent)
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])

        else
            self:SetParent()
            self:SetPoint(self.RePoint[1], self.RePoint[2], self.RePoint[3], self.RePoint[4], self.RePoint[5])
        end
    end

    function btn:set_scale()
        if self:CanChangeAttribute() then
            self:SetScale(WoWTools_FoodMixin:Save().scale or 1)
        end
    end


    function btn:get_tooltip_item()
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" and itemID and itemLink and self.itemID~=itemID then
            return itemID, itemLink
        end
    end


    btn:RegisterForDrag("RightButton")
    btn:SetMovable(true)
    btn:SetClampedToScreen(true)
    btn:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(self) then
            self:StartMoving()
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
        end
    end)
    btn:SetScript("OnDragStop", function(self)
        ResetCursor()
        if not WoWTools_FrameMixin:IsLocked(self) then
            self:StopMovingOrSizing()
        end
        if WoWTools_FrameMixin:IsInSchermo(self) then
            WoWTools_FoodMixin:Save().point={self:GetPoint(1)}
            WoWTools_FoodMixin:Save().point[2]=nil
        end
        if self:CanChangeAttribute() then
            self:SetParent(UIParent)
        end
        self:UnregisterEvent('PLAYER_REGEN_DISABLED')
    end)
    btn:SetScript("OnMouseDown", function(self, d)
        local itemID, itemLink = self:get_tooltip_item()
        if itemID and itemLink then
            Add_Item({itemID=itemID, itemLink=itemLink})
            ClearCursor()
            return
        end

        if d=='RightButton' then
            if not IsModifierKeyDown() then
                WoWTools_FoodMixin:Init_Menu(self)
                self:set_tooltip()
            elseif IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(self) then
                SetCursor('UI_MOVE_CURSOR')
            end
        end
    end)


    btn:SetScript("OnMouseUp", ResetCursor)
    btn:SetScript('OnMouseWheel',function(self, d)
        if not IsModifierKeyDown() then
            if not self:CanChangeAttribute() then
                WoWTools_Print(WoWTools_FoodMixin.addName..WoWTools_DataMixin.Icon.icon2, '|cnWARNING_FONT_COLOR:'..(WoWTools_L.HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
            else
                WoWTools_FoodMixin:Check_Items(true)
            end
        end
    end)





    function btn:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:ClearLines()
        local itemID, itemLink = self:get_tooltip_item()
        if itemID and itemLink then
            GameTooltip:AddDoubleLine(WoWTools_ItemMixin:GetName(itemID), WoWTools_L['ADD+CUSTOM'])
        else
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_FoodMixin.addName)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_L.SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
            GameTooltip:AddDoubleLine(WoWTools_L.NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
            GameTooltip:AddDoubleLine((self:CanChangeAttribute() and '' or '|cff626262')..(WoWTools_L.WHO), WoWTools_DataMixin.Icon.mid)

            GameTooltip:AddLine(' ')
            if self.alt then
                GameTooltip:AddDoubleLine(WoWTools_SpellMixin:GetName(self.alt), 'Alt+'..WoWTools_DataMixin.Icon.left)
            end
            if self.ctrl then
                GameTooltip:AddDoubleLine(WoWTools_SpellMixin:GetName(self.ctrl), 'Ctrl+'..WoWTools_DataMixin.Icon.left)
            end
            if self.shift then
                GameTooltip:AddDoubleLine(WoWTools_SpellMixin:GetName(self.shift), 'Shift+'..WoWTools_DataMixin.Icon.left)
            end
            if self.alt or self.ctrl or self.shift then
                GameTooltip:AddLine(' ')
            end
            GameTooltip:AddDoubleLine(
                (WoWTools_FoodMixin:Save().onlyMaxExpansion and '|cnGREEN_FONT_COLOR:' or '|cff626262')
                ..(WoWTools_L['Only current version items']),
                WoWTools_TextMixin:GetEnabeleDisable(WoWTools_FoodMixin:Save().onlyMaxExpansion)
            )
        end
        GameTooltip:Show()
    end

    btn:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        WoWTools_BagMixin:Find()
        self:set_alpha()
        self:set_count()
        self:set_cool()
        self:set_desaturated()
        self:SetScript('OnUpdate', nil)
        --self.elapsed=nil
    end)


    btn:SetScript("OnEnter",function(self)
        if self.alt or self.ctrl or self.shift then
            local e= 1
            self:SetScript('OnUpdate', function(s, elapsed)
                e= (e or 1) + elapsed
                if e>=1 then
                    e=0
                    s:set_tooltip()
                end
            end)
        else
            self:set_tooltip()
        end
        self:settings()
        if self:CanChangeAttribute() then
            self:set_attribute()
        end
        WoWTools_BagMixin:Find(true, {itemID= self.itemID})
    end)


    btn:SetAttribute('type1', 'item')
    btn:SetAttribute('alt-type1', 'spell')
    btn:SetAttribute('ctrl-type1', 'spell')
    btn:SetAttribute('shift-type1', 'spell')


    if WoWTools_FoodMixin:Save().point then
        btn:set_point()
    end
    btn:set_strata()
    btn:set_scale()
    --btn:set_background()


    Set_AltSpell()
    btn:settings()
    btn:set_attribute()

    Init=function()
        Set_AltSpell()
    end
end



function WoWTools_FoodMixin:Init_Button()
    Init()
end

