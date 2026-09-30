
local function Save()
    return WoWToolsPlusSave['Plus_Gossip']
end

























local function Init_Menu(self, root)
    local sub, sub2, num, num2

    sub=root:CreateCheckbox(
        (WoWTools_L.ENABLE)..'|A:SpecDial_LastPip_BorderGlow:0:0|a',
    function()
        return Save().gossip
    end, function()
        self:set_enable()
        --return MenuResponse.Close
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Gossip.Enable'])
        tooltip:AddLine('Alt+'..(WoWTools_L.DISABLE))
        tooltip:AddLine(WoWTools_L.BOOSTED_CHAR_SPELL_TEMPLOCK)
    end)
    sub=root:CreateCheckbox(
        WoWTools_L['ITEM_UNIQUE+ENABLE_DIALOG'],
    function()
        return  Save().unique
    end, function ()
        Save().unique= not Save().unique and true or false
        WoWTools_GossipMixin:UpdateGossip()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_L['When there is only one option, select it automatically.'], nil, nil,nil, true)
    end)
    local tipSub= sub:CreateCheckbox(
        WoWTools_L['Also in player choices'],
    function()
        return Save().uniqueChoice
    end, function ()
        Save().uniqueChoice= not Save().uniqueChoice and true or nil
    end)
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.Gossip.UniqueChoice'])


    root:CreateDivider()
    num= CountTable(Save().gossipOption or {})

    sub=root:CreateButton(
        '|T0:0|t'
        ..(WoWTools_L['SELF_CAST_AUTO+ENABLE_DIALOG']),
    function()
        return MenuResponse.Open
    end, {rightText=num})
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Gossip.CustomList'])
    WoWTools_MenuMixin:SetRightText(sub)

    for gossipOptionID, text in pairs(Save().gossipOption) do
        sub2=sub:CreateCheckbox(
            text==true and gossipOptionID or text,
        function(data)
            return Save().gossipOption[data.gossipOptionID]
        end, function(data)
            Save().gossipOption[data.gossipOptionID]= not Save().gossipOption[data.gossipOptionID] and data.text or nil
            WoWTools_GossipMixin:UpdateGossip()
        end, {gossipOptionID=gossipOptionID, text=text})
        sub2:SetTooltip(function(tooltip, description)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Gossip.CustomItem'])
            tooltip:AddDoubleLine('gossipOptionID', description.data.gossipOptionID)
        end)
    end

    sub:CreateDivider()
    WoWTools_MenuMixin:ClearAll(sub, function()
        Save().gossipOption={}
    end)
    WoWTools_MenuMixin:SetScrollMode(sub)



    --root:CreateDivider()
    num= CountTable(WoWToolsPlusPlayerDate['GossipTextIcon'] or {})
    num2= CountTable(WoWTools_GossipMixin:Get_GossipData() or {})

    sub=root:CreateCheckbox(
        (WoWTools_L['DIALOG_VOLUME+REPLACE'])
        ..WoWTools_DataMixin.Icon.mid,
        --..((num+num2)==0 and '|cff626262' or '')
        --..(num..'/'..num2),
    function()
        return not Save().not_Gossip_Text_Icon
    end, function()
        Save().not_Gossip_Text_Icon= not Save().not_Gossip_Text_Icon and true or nil
        WoWTools_GossipMixin:Init_Gossip_Data()
        WoWTools_GossipMixin:UpdateGossip()
    end, {rightText=num..'/'..num2, rightColor= (num+num2==0) and DISABLED_FONT_COLOR or nil})
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Gossip.ReplaceText'])
    WoWTools_MenuMixin:SetRightText(sub)

    sub2= sub:CreateButton(
        '|A:mechagon-projects:0:0|a'
        ..(WoWTools_L.CUSTOM),
    function ()
        WoWTools_GossipMixin:Init_Options_Frame(true)
        return MenuResponse.Open
    end, {rightText=num})
    WoWTools_MenuMixin:SetDescription(sub2, WoWTools_L['Tip.Gossip.ReplaceEdit'])
    WoWTools_MenuMixin:SetRightText(sub)

    sub:CreateButton(
        (WoWTools_MoveMixin:GetPoint(nil, 'WoWToolsGossipTextIconOptionsFrame') and '' or '|cff626262')
        ..(WoWTools_L.RESET_POSITION),
    function()
        WoWTools_MoveMixin:ClearPoint(nil, 'WoWToolsGossipTextIconOptionsFrame')
        local frame= _G['WoWToolsGossipTextIconOptionsFrame']
        if frame then
            frame:ClearAllPoints()
            frame:SetPoint('CENTER')
        end
        return MenuResponse.Refresh
    end)


    num= CountTable(WoWTools_GossipMixin:Get_GossipData() or {})
    
    sub:CreateDivider()
    local tipSub= sub:CreateCheckbox(
        (WoWTools_L.DEFAULT),--..(num==0 and ' |cff626262' or ' ')..num,
    function()
        return not Save().notGossipPlayerData
    end, function()
        Save().notGossipPlayerData= not Save().notGossipPlayerData and true or nil
        WoWTools_GossipMixin:Init_Gossip_Data()
        WoWTools_GossipMixin:UpdateGossip()
    end, {rightText=num})
    WoWTools_MenuMixin:SetDescription(tipSub, WoWTools_L['Tip.Gossip.ReplaceDefault'])
    WoWTools_MenuMixin:SetRightText(sub)

    num= CountTable(Save().NPC or {})
    
    sub=root:CreateButton(
        '|T0:0|t'..WoWTools_L['Disable NPC'],--..(num==0 and ' |cff626262' or ' ')..num,
    function()
        return MenuResponse.Open
    end, {rightText=num})
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Gossip.DisableNPC'])
        tooltip:AddLine(WoWTools_L['Gossip/Quests'])
    end)
    WoWTools_MenuMixin:SetRightText(sub)

    for npcID, name in pairs(Save().NPC) do
        sub2=sub:CreateCheckbox(
            WoWTools_TextMixin:CN(nil, {npcID=npcID, isName=true})
            or (name~=true and name)
            or npcID,
        function(data)
            return Save().NPC[data.npc]
        end, function(data)
            Save().NPC[data.npc]= not Save().NPC[data.npc] and data.name or nil
        end, {npc=npcID, name=name})
        sub2:SetTooltip(function(tooltip, description)
            WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Gossip.DisableNPCItem'])
            tooltip:AddDoubleLine('NPC ID', description.data.npc)
        end)
    end

    sub:CreateDivider()
    WoWTools_MenuMixin:ClearAll(sub, function()
        Save().NPC={}
    end)
    WoWTools_MenuMixin:SetScrollMode(sub)

--PlayerChoiceFrame
    num= CountTable(Save().choice or {})
    
    sub=root:CreateButton(
        '|T0:0|t'..(WoWTools_L.CHOOSE),--..(num==0 and ' |cff626262' or ' ')..num,
    function()
        return MenuResponse.Open
    end, {rightText=num})
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Gossip.Choice'])
        tooltip:AddLine('PlayerChoiceFrame')
        tooltip:AddLine('Blizzard_PlayerChoice')
    end)
    WoWTools_MenuMixin:SetRightText(sub)

    for spellID, rarity in pairs(Save().choice) do
        sub2=sub:CreateCheckbox(
            WoWTools_SpellMixin:GetName(spellID)
            ..' '
            ..(WoWTools_ItemMixin.QualityText[rarity] or ''),
        function(data)
            return Save().choice[data.spellID]
        end, function(data)
            Save().choice[data.spellID]= not Save().choice[data.spellID] and data.rarity or nil
        end, {spellID=spellID, rarity=rarity})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end

    sub:CreateDivider()
    WoWTools_MenuMixin:ClearAll(sub, function()
        Save().choice={}
    end)
    WoWTools_MenuMixin:SetScrollMode(sub)


    root:CreateDivider()
    WoWTools_GossipMixin:Init_MoveListMenu(self, root)


    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_GossipMixin.addName})




    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().scale or 1
    end, function(value)
        Save().scale= value
        self:settings()
    end)


    WoWTools_MenuMixin:BgAplha(sub,
    function()--GetValue
        return Save().bgAlpha or 0.5
    end, function(value)--SetValue
        Save().bgAlpha= value
        self:settings()
    end, function()--RestFunc
        Save().bgAlpha= nil
        self:settings()
    end)--onlyRoot


--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        self:settings()
        return MenuResponse.Refresh
    end)


    sub:CreateDivider()
    WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
        Save().point=nil
        self:ClearAllPoints()
        self:set_Point()
    end)
end


















function WoWTools_GossipMixin:Init_Menu_Gossip(frame)
    MenuUtil.CreateContextMenu(frame, function(_, root)
        Init_Menu(_G['WoWToolsGossipButton'], root)
    end)
end