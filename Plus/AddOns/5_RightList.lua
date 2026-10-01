
local Buttons={}
local RightFrame
local Name= 'WoWToolsAddOnsRightListButton'

local function Is_Load(nameORindex)
    return C_AddOns.IsAddOnLoaded(nameORindex) or select(2, C_AddOns.IsAddOnLoadable(nameORindex))=='DEMAND_LOADED'
end


local function Set_OnEnter_Tooltip(self, tooltip)
    tooltip:AddLine(self.name)
    WoWTools_AddOnsMixin:Show_Select_Tooltip(
        tooltip,
        WoWTools_AddOnsMixin:Save().buttons[self.name] or {}
    )
end


local function Init_Button_Menu(self, root)
    if not self:IsVisible() then
        return
    end

    local sub

    sub=root:CreateCheckbox(
        (WoWTools_L['LOAD_ADDON~2']),
    function(data)
        return WoWTools_AddOnsMixin:Save().load_Button_Name==data.name
    end, function()
        do
            local tab= WoWTools_AddOnsMixin:Save().buttons[self.name]
            local character= WoWTools_AddOnsMixin:GetIsPlayer()--solo el personaje seleccionado en AddonList
            for i=1, C_AddOns.GetNumAddOns() do
                local name= C_AddOns.GetAddOnName(i)
                local value=tab[name]
                local vType= type(value)
                if vType=='boolean' or vType=='number' or value==WoWTools_DataMixin.Player.GUID then
                    C_AddOns.EnableAddOn(i, character)
                else
                    C_AddOns.DisableAddOn(i, character)
                end
            end
        end
        WoWTools_AddOnsMixin:Save().load_Button_Name= self.name
        WoWTools_DataMixin:Reload()
    end, {name=self.name})
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.AddOns.LoadProfile'])
        Set_OnEnter_Tooltip(self, tooltip)
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine(WoWTools_L.RELOADUI, '/reload')
    end)

    root:CreateDivider()
    local player, allTab= select(2, WoWTools_AddOnsMixin:Get_AddListInfo())
    sub=root:CreateButton(
        '|A:ShipMission_ShipFollower-Lock-Rare:0:0|a'
        ..(WoWTools_L.REPLACE)
        ..' '..player,
    function(data)

        StaticPopup_Show('WoWTools_OK',
            '|A:ShipMission_ShipFollower-Lock-Rare:0:0|a'..(WoWTools_L.REPLACE)
            ..'|n'..data.name,
            nil,
            {SetValue=function()
                WoWTools_AddOnsMixin:Save().buttons[data.name]= allTab
                WoWTools_DataMixin:Call('AddonList_Update')
            end}
        )


    end, {name=self.name})
    sub:SetTooltip(function(tooltip, description)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.AddOns.ReplaceProfile'])
        WoWTools_AddOnsMixin:Show_Select_Tooltip(tooltip, description.data.tab)
    end)

    root:CreateButton(
        '|A:QuestLegendaryTurnin:0:0|a'
        ..(WoWTools_L.EQUIPMENT_SET_EDIT),
    function(data)
        local name= data.name:match('|t(.+)') or data.name
        local texture= data.name:match('|T(%d+):0|t')
        if texture then
            texture= tonumber(texture)
        end
        WoWTools_TextureMixin:GetNewIcon(self, {
            text= name,
            texture= texture,
            SetValue=function(newIcon, newText)
                local new=WoWTools_AddOnsMixin:Save().buttons[data.name]
                if new then
                    for n in pairs(WoWTools_AddOnsMixin:Save().buttons) do
                        if data.name==n then
                            WoWTools_AddOnsMixin:Save().buttons[n]= nil
                            WoWTools_AddOnsMixin:Save().buttons['|T'..(newIcon or 0)..':0|t'..newText]= new
                            WoWTools_DataMixin:Call('AddonList_Update')
                            return
                        end
                    end
                end
            end
        })
    end, {name=self.name})

    root:CreateButton(
        '|A:XMarksTheSpot:0:0|a'..(WoWTools_L.DELETE),
    function(data)
        StaticPopup_Show('WoWTools_OK',
            '|A:XMarksTheSpot:0:0|a'..(WoWTools_L.DELETE)
            ..'|n'..data.name,
            nil,
            {SetValue=function()
                WoWTools_AddOnsMixin:Save().buttons[self.name]=nil
                WoWTools_DataMixin:Call('AddonList_Update')
            end}
        )
    end, {name=self.name})



    root:CreateTitle(self.name)
end


local function Create_Button(index)
    local btn= WoWTools_ButtonMixin:Menu(RightFrame, {
        name=Name..index,
        icon='hide'
    })

    btn:SetHighlightAtlas('auctionhouse-nav-button-secondary-select')
    btn.Text= WoWTools_LabelMixin:Create(btn, {size=14})
    btn.Text:SetPoint('LEFT', 2, 1)

    btn.loadTexture= btn:CreateTexture()
    btn.loadTexture:SetPoint('LEFT', btn, 'RIGHT')
    btn.loadTexture:SetSize(12,12)
    btn.loadTexture:SetAtlas('AnimaChannel-Bar-Necrolord-Gem')

    function btn:set_settings()
        local load, all= 0, 0
        for name in pairs(WoWTools_AddOnsMixin:Save().buttons[self.name] or {}) do
            if C_AddOns.DoesAddOnExist(name) then
                if Is_Load(name) then
                    load= load +1
                end
                all= all+1
            else
                WoWTools_AddOnsMixin:Save().buttons[self.name][name]=nil
            end
        end
        self.Text:SetFormattedText(
            '%s %s%d|r/%s%d|r',
            self.name,
            load==0 and '|cff626262' or '|cnGREEN_FONT_COLOR:',
            load,
            load==all and '|cnGREEN_FONT_COLOR:' or '',
            all
        )
        self.isLoadAll= self.numAllLoad==all and load==all
        self:SetWidth(self.Text:GetWidth()+4)
        self:SetHeight(self.Text:GetHeight()+6)
        self:SetButtonState(self.isLoadAll and 'PUSHED' or 'NORMAL')
        self.loadTexture:SetShown(WoWTools_AddOnsMixin:Save().load_Button_Name==self.name)
    end

    btn:SetupMenu(Init_Button_Menu)

    btn:SetScript('OnEnter', function(self)
        WoWTools_AddOnsMixin:Update_Usage()

        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        Set_OnEnter_Tooltip(self, GameTooltip)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine((WoWTools_L.SLASH_TEXTTOSPEECH_MENU)..WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)

    btn:SetScript('OnLeave', function(self)
        self:set_settings()
        GameTooltip:Hide()
    end)

    if index==1 then
        btn:SetPoint('TOPLEFT', RightFrame)
    else
        btn:SetPoint('TOPLEFT', _G[Name..(index-1)], 'BOTTOMLEFT')
    end

    table.insert(Buttons, index)

    return btn
end


local function Set_Right_Buttons()
    if not RightFrame:IsShown() then
        return
    end

    local load, need, player= 0, 0, 0
    for i=1, C_AddOns.GetNumAddOns() do

        if select(2, C_AddOns.IsAddOnLoadable(i, WoWTools_DataMixin.Player.GUID))=='DEMAND_LOADED' then
            need= need+1
        elseif C_AddOns.IsAddOnLoaded(i) then
            load= load+1
        end

        local stat= C_AddOns.GetAddOnEnableState(i, WoWTools_DataMixin.Player.GUID)
        if stat>Enum.AddOnEnableState.None then
            player= player +1
        end
    end

    _G['WoWToolsAddonsNewButton'].Text:SetText(WoWTools_DataMixin.Icon.Player..player)
    _G['WoWToolsAddonsNewButton'].Text3:SetFormattedText('|cnGREEN_FONT_COLOR:%d|r + |cffff00ff%d|r', load,  need)

    local index=1
    local w=0
    for name in pairs(WoWTools_AddOnsMixin:Save().buttons) do
        local btn= _G[Name..index] or Create_Button(index)
        btn.name= name
        btn.numAllLoad= load+ need
        btn:set_settings()
        btn:SetShown(true)

        w= math.max(btn:GetWidth(), w)
        RightFrame.Background:SetPoint('BOTTOM', btn)

        index= index+1
    end

    RightFrame.Background:SetWidth(w)

    for i= index, #Buttons do
        local btn= _G[Name..i]
        btn:SetShown(false)
        btn.name= nil
        btn.numAllLoad= nil
    end
end


local function Init()
    if WoWTools_AddOnsMixin:Save().hideRightList then
        return
    end

    RightFrame= CreateFrame("Frame", 'WoWToolsAddOnsRightFrame',  AddonListCloseButton)

    do
        WoWTools_AddOnsMixin:Init_NewButton_Button()
    end

    RightFrame:SetSize(1,1)
    RightFrame:SetPoint('TOPLEFT', AddonList, 'TOPRIGHT', 2, 0)

    RightFrame.Background= RightFrame:CreateTexture(nil, 'BACKGROUND')
    RightFrame.Background:SetPoint('TOPLEFT', RightFrame)

    function RightFrame:settings()
        local show= not WoWTools_AddOnsMixin:Save().hideRightList
        self:SetScale(WoWTools_AddOnsMixin:Save().rightListScale or 1)
        self:SetShown(show)
        _G['WoWToolsAddonsNewButton']:SetShown(show)
        self.Background:SetColorTexture(0, 0, 0, WoWTools_AddOnsMixin:Save().bgAlpha or 0.5)
    end

    RightFrame:settings()
    Set_Right_Buttons()

    WoWTools_DataMixin:Hook('AddonList_Update', function()
        Set_Right_Buttons()
    end)

    Init=function()
        RightFrame:settings()
        Set_Right_Buttons()
    end
end


function WoWTools_AddOnsMixin:Init_Right_Buttons()
    Init()
end
