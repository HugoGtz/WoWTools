local function Save()
    return WoWToolsPlusSave['Plus_Attributes'] or {}
end


local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub
    sub=root:CreateButton(
        '|A:characterundelete-RestoreButton:0:0|a'..(WoWTools_L['RESET+STATUS_TEXT_VALUE']),
    function()
        WoWTools_AttributesMixin:Frame_Init(true)
        WoWTools_Print(
            WoWTools_AttributesMixin.addName..WoWTools_DataMixin.Icon.icon2,
            '|cnGREEN_FONT_COLOR:',
            WoWTools_L['RESET+STATUS_TEXT_VALUE']
        )
        return MenuResponse.Open
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Attributes.Reset'])

    root:CreateDivider()
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.Icon.mid..(WoWTools_L.SHOW),
    function()
        return self.frame:IsShown()
    end, function()
        Save().hide= not Save().hide and true or nil
        self:set_Show_Hide()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.Attributes.Show'])

    root:CreateDivider()
    WoWTools_MenuMixin:Set_Specialization(root)


    root:CreateDivider()

    sub=WoWTools_AttributesMixin:Open_Options(root)


    WoWTools_MenuMixin:BgAplha(sub,
    function()--GetValue
        return Save().bgAlpha or 0.5
    end, function(value)--SetValue
        Save().bgAlpha=value
        WoWTools_AttributesMixin:Frame_Init(true)
    end, function()--RestFunc
        Save().bgAlpha= 0.5
        WoWTools_AttributesMixin:Frame_Init(true)
    end)--onlyRoot

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        self:set_strata()
    end)


    sub:CreateDivider()
    WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
        Save().point=nil
        self:set_Point()
        return MenuResponse.Open
    end)
end


function WoWTools_AttributesMixin:Init_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end