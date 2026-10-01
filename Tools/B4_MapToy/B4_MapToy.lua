
local SpellID= 431280

local Tab={

    {itemID=187869, achievements={14663, 14303, 14304, 14305, 14306}},

    {itemID=187875, achievements={10665,10666, 10667, 10668, 10669, 11543}},

    {itemID=187900, achievements={12558, 12556, 13776, 12557, 12559, 13712, 12560, 12561}},

    {itemID=187895, achievements={8938, 8939, 8940, 8941, 8937, 8942, 10260}},

    {itemID=187896, achievements={6977, 6975, 6976, 6979, 6351, 6978, 6969}},

    {itemID=187897, achievements={4864, 4863, 4866, 4865, 4825}},

    {itemID=187898, achievements={1267, 1264, 1268, 1269, 1265, 1266, 1263, 1457, 1270}},

    {itemID=187899, achievements={865, 862, 866, 843, 864, 867, 863}},

}

if WoWTools_DataMixin.Player.Faction=='Alliance' then
    --LM
    table.insert(Tab, {itemID=150743, achievements={736, 842, 750, 851, 857, 855, 853, 856, 850, 845, 848, 852, 854, 847, 728, 849, 844, 4996, 846, 861, 860}})
    table.insert(Tab, {itemID=150746, achievements={858, 859, 627, 776, 775, 768, 765, 802, 782, 766, 772, 777, 779, 770, 774, 780, 769, 773, 778, 841, 4995, 761, 771, 781, 868}})

elseif WoWTools_DataMixin.Player.Faction=='Horde' then
    --BL
    table.insert(Tab, {itemID=150744, achievements={736, 842, 750, 851, 857, 855, 853, 856, 850, 845, 848, 852, 854, 847, 728, 849, 844, 4996, 846, 861, 860}})
    table.insert(Tab, {itemID=150745, achievements={858, 859, 627, 776, 775, 768, 765, 802, 782, 766, 772, 777, 779, 770, 774, 780, 769, 773, 778, 841, 4995, 761, 771, 781, 868}})
end


local Module= {}--lo completa WoWTools_Module:Register (al final del archivo)



local function Is_Completed(tab)
    WoWTools_DataMixin:Load(tab.itemID, 'item')

    local num= 0
    local isNotChecked
    local new={}
    for _, achievementID in pairs(tab.achievements) do
        local _, name, _, _, _, _, _, _, _, icon, _, _, wasEarnedByMe= GetAchievementInfo(achievementID)
        if name then
            if not wasEarnedByMe then
                num= num+1
            end
        else
            isNotChecked=true
        end
        table.insert(new, {
            achievementID= achievementID,
            name=name,
            icon=icon,
            wasEarnedByMe=wasEarnedByMe
        })
    end

    return {
        itemID= tab.itemID,
        hasToy= C_ToyBox.GetToyInfo(tab.itemID) and PlayerHasToy(tab.itemID) or C_Item.GetItemCount(tab.itemID)>0,
        num=num,
        isNotChecked=isNotChecked,
        data=new,
    }
end












































local function Init_Menu(self, root)
    WoWTools_DataMixin:Load(SpellID, 'spell')

    local sub, sub2
    for _, info in pairs(Tab) do
        local new= Is_Completed(info)

        local col=  new.isNotChecked==nil and new.num==0 and '|cff626262'
                    or (new.hasToy==false and '|cnWARNING_FONT_COLOR:')
                    or ''

        local name= WoWTools_ItemMixin:GetName(new.itemID)

        local num=(new.isNotChecked==nil and
                    (new.num>0 and ' |cnGREEN_FONT_COLOR:')
                    or (new.name==0 and ' |cff626262')
                    or ' '
                )
                ..(new.isNotChecked==nil and new.num or '')


        sub= root:CreateCheckbox(
            col..name..num,
        function(data)
            return data.itemID==self.itemID
        end, function(data)
            self:settings(data.itemID)
        end, {itemID=info.itemID})

        sub:SetTooltip(function(tooltip, desc)
            WoWTools_SetTooltipMixin:Setup(tooltip, desc.data)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.MapToy.Toy'])
        end)


        for index, tab in pairs(new.data) do
            sub2=sub:CreateButton(
                index..') '
                ..(tab.wasEarnedByMe==true and '|cff626262' or '')
                ..'|T'..(tab.icon or 0)..':0|t'
                ..(WoWTools_TextMixin:CN(tab.name) or tab.achievementID)
                ..(tab.wasEarnedByMe==true and '|A:common-icon-checkmark:0:0|a' or ''),
            function(data)
                self:settings(data.itemID)
                return MenuResponse.Open
            end,
            {itemID=tab.itemID, achievementID=tab.achievementID})
            sub2:SetTooltip(function(tooltip, description)
                tooltip:SetAchievementByID(description.data.achievementID)
            end)
        end
    end

    sub= root:CreateCheckbox(
        WoWTools_SpellMixin:GetName(SpellID),
    function()
        return self.spellID==SpellID
    end, function()
        self:settings()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:SetSpellByID(SpellID)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.MapToy.Spell'])
    end)

    local tab=CopyTable(Module:Save().no)
    tab[WoWTools_DataMixin.Player.GUID]= true

    root:CreateDivider()
    sub= WoWTools_ToolsMixin:OpenMenu(root, WoWTools_L.DISABLE)

    sub:CreateTitle(WoWTools_L.DISABLE)

    for guid in pairs(tab) do
        sub2=sub:CreateCheckbox(
            WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=true}),
        function(data)
            return Module:Save().no[data]
        end, function(data)
            Module:Save().no[data]= not Module:Save().no[data] and true or nil
        end, guid)
        WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.MapToy.DisableChar'])
    end

    sub:CreateDivider()


    sub2=sub:CreateCheckbox(
        format('%s = %d %s',
            (WoWTools_L.DISABLE),
            GetMaxLevelForLatestExpansion(),
            WoWTools_L.LEVEL
        ),
    function()
        return Module:Save().maxLevelIsDisabled
    end, function()
        Module:Save().maxLevelIsDisabled= not Module:Save().maxLevelIsDisabled and true or false
    end)
    sub2:SetTooltip(function (tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.MapToy.MaxLevel'])
        tooltip:AddLine(
            WoWTools_L['Disable highest level']
        )
    end)

    sub:CreateButton(
        WoWTools_L.CLEAR_ALL,
    function()
        StaticPopup_Show('WoWTools_OK',
        WoWTools_L.CLEAR_ALL,
        nil,
        {SetValue=function()
            Module:Save().no={}
            Module:Save().maxLevelIsDisabled=nil
        end})
        return MenuResponse.Open
    end)

    WoWTools_MenuMixin:SetScrollMode(sub)
end





















local Init= WoWTools_Once(function()
    local btn= WoWTools_ToolsMixin:Get_ButtonForName('MapToy')
    if not btn then
        return
    end

    function btn:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        if self.itemID then
            GameTooltip:SetItemByID(self.itemID)
            GameTooltip:AddLine(' ')
        elseif self.spellID then
            GameTooltip:SetSpellByID(self.spellID)
            GameTooltip:AddLine(' ')
        end
        GameTooltip:AddDoubleLine(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end

    function btn:set_cool()
        WoWTools_CooldownMixin:SetFrame(self, {
            itemID=self.itemID,
            spellID=self.spellID,
        })
    end

    function btn:set_texture()
        local icon
        if self.itemID then
            icon= select(5, C_Item.GetItemInfoInstant(self.itemID))
        elseif self.spellID then
            icon= C_Spell.GetSpellTexture(self.spellID)
        end

        if icon and icon>0 then
            self.texture:SetTexture(icon)
        else
            self.texture:SetAtlas('Taxi_Frame_Yellow')
        end
    end

    function btn:settings(itemID)
        if not self:CanChangeAttribute() then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end

        local spellName= nil
        local spellID
        if itemID then
            self:SetAttribute("type1", "toy")
        else
            self:SetAttribute("type1", "spell")
            spellID= SpellID
            spellName= C_Spell.GetSpellName(spellID) or SpellID
        end
        self:SetAttribute('toy1', itemID)
        self:SetAttribute('spell1', spellName or SpellID)

        self.itemID=itemID
        self.spellID=spellID


        self:set_texture()
        self:set_cool()
    end




    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetScript('OnUpdate',nil)
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_cool()
        self:set_tooltips()
    end)

    btn:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)

    btn:settings()
    btn:set_texture()
end)











WoWTools_Module:Register({
    key= 'Tools_MapToy', name= 'ADVENTURE_MAP_TITLE', icon= 'Taxi_Frame_Yellow', group= 'Tools',
    parent= 'WoWTools_ToolsButton', tooltip= 'Tip.MapToy.Enable', mixin= Module,
    defaults= {
        no={
            --[guid]=true
        },
        maxLevelIsDisabled=true,
    },
    --siempre: su casilla en la página de Herramientas
    onLoad= function(M, save)
        save.autoAddDisabled= nil

        WoWTools_ToolsMixin:Set_AddList(function(category, layout)
             WoWTools_PanelMixin:Check_Button({
                 checkName= M.addName,
                 GetValue= function() return not M:Save().disabled end,
                 SetValue= function()
                     M:Save().disabled = not M:Save().disabled and true or nil
                 end,
                 buttonText= WoWTools_L.SLASH_STOPWATCH_PARAM_STOP2,
                 buttonFunc= function()
                    StaticPopup_Show('WoWTools_OK',
                    M.addName,
                    nil,
                    {SetValue=function()
                        M:Save().no={}
                        M:Save().maxLevelIsDisabled=true
                    end})
                 end,
                 tooltip= WoWTools_L['Tip.MapToy.Enable'],
                 layout= layout,
                 category= category,
             })
         end)
    end,
    onEnable= function(M, save)
        if not save.no[WoWTools_DataMixin.Player.GUID]
            and not (save.maxLevelIsDisabled and WoWTools_DataMixin.Player.IsMaxLevel)
         then
            WoWTools_ToolsMixin:CreateButton({
                name='MapToy',
                tooltip=M.addName,
                disabledOptions=true
            })
        end

        if WoWTools_ToolsMixin:Get_ButtonForName('MapToy') then
            WoWTools_ToolsMixin:OnEnterWorld(function()
                Init()
            end)

            for _, info in pairs(Tab) do
                WoWTools_DataMixin:Load(info.itemID, 'item')
                for _, achievementID in pairs(info.achievements) do
                    GetAchievementCategory(achievementID)
                end
            end
            WoWTools_DataMixin:Load(SpellID, 'spell')
        end
    end,
})
