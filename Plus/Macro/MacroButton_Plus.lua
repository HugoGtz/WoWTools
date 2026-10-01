



local function Delete_Macro(self)
    local index= MacroFrame:GetSelectedIndex()

    if InCombatLockdown()
        or not MacroDeleteButton:IsEnabled()
        or not index or index~=self.selectionIndex
    then
        return
    end


    index= MacroFrame:GetMacroDataIndex(index)

    local name, icon, body = GetMacroInfo(index)

    WoWTools_DataMixin:Call(MacroFrame.DeleteMacro, MacroFrame)

    if name then
        WoWTools_Print(
            WoWTools_MacroMixin.addName..WoWTools_DataMixin.Icon.icon2,
            '|cnWARNING_FONT_COLOR:'..(WoWTools_L.DELETE),
            '|r', WoWTools_MacroMixin:GetName(name, icon)
        )
        if body and body~='' then
            WoWTools_Print(
                body
            )
        end
    end
end










local function Init_Menu(self, root)
    if WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

    do
        if self.selectionIndex and self.selectionIndex~=MacroFrame:GetSelectedIndex() then
            MacroFrame:SelectMacro(self.selectionIndex)
            MacroPopupFrame:Hide()
        end
    end

    local sub
    local index= WoWTools_MacroMixin:GetSelectIndex()
    local isSelect= self:GetSelectorFrame():IsSelected(self.selectionIndex)--self.selectionIndex and self.selectionIndex==MacroFrame:GetSelectedIndex()

    WoWTools_MacroMixin:Save_Macro_Menu(self, root)

    sub=root:CreateButton(
        '|A:QuestLegendary:0:0|a'..(WoWTools_L.EDIT),
    function()
        if not InCombatLockdown() then
            WoWTools_DataMixin:Call(MacroEditButton_OnClick, MacroFrame, self)
        end
        return MenuResponse.Open
    end, {index=index})
    sub:SetEnabled(isSelect)
    WoWTools_MacroMixin:SetMenuTooltip(sub)

    root:CreateDivider()
    sub=root:CreateButton(
        '|A:XMarksTheSpot:0:0|a'
        ..(isSelect and '|cnWARNING_FONT_COLOR:' or '')..(WoWTools_L.DELETE),
    function()
        Delete_Macro(self)
    end, {index=index})
    sub:SetEnabled(isSelect)
    WoWTools_MacroMixin:SetMenuTooltip(sub)

    root:CreateDivider()
    sub=root:CreateButton(
        '|A:communities-chat-icon-plus:0:0|a'..(WoWTools_L.NEW),
    function()
        WoWTools_MacroMixin:CreateMacroNew()
        return MenuResponse.Open
    end)
    sub:SetEnabled(WoWTools_MacroMixin:IsCanCreateNewMacro())
end













local function Set_OnLoad(btn)
    if btn.OnDoubleClick then
        return
    end

    function btn:set_on_enter()
        WoWTools_MacroMixin:SetTooltips(self)
    end
    btn:HookScript('OnEnter', btn.set_on_enter)
    btn:HookScript('OnLeave', GameTooltip_Hide)

    local texture2= btn:GetRegions()
    texture2:SetAlpha(0.3)
    btn.Name:SetWidth(48)
    btn.SelectedTexture:ClearAllPoints()
    btn.SelectedTexture:SetPoint('CENTER')
    btn.SelectedTexture:SetSize(44,44)
    btn.SelectedTexture:SetVertexColor(0,1,1)

    btn:SetScript('OnDoubleClick', function(self)
       if IsAltKeyDown() then
            Delete_Macro(self)
       end
    end)

    btn:HookScript('OnMouseDown', function(frame, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(frame, Init_Menu)
            frame:set_on_enter()
        end
    end)

    btn.indexLable= WoWTools_LabelMixin:Create(btn, {color={r=0.62,g=0.62,b=0.62, a=0.3}, layer='BACKGROUND'})
    btn.indexLable:SetPoint('CENTER')--'LEFT', -6, 0)
    --btn.indexLable:SetAlpha(0.3)
    function btn:set_index_label()
        self.indexLable:SetText(self.selectionIndex or '')
    end
end










local function Init()
    WoWTools_DataMixin:Hook(MacroButtonMixin, 'OnLoad', function(...)
        Set_OnLoad(...)
    end)

    WoWTools_DataMixin:Hook(MacroFrame.MacroSelector, 'setupCallback', function(self, _, name)--Blizzard_MacroUI.lua
        if name ~= nil then
            self.Name:SetText(WoWTools_TextMixin:sub(name, 2, 4))
        end
    end)

    WoWTools_DataMixin:Hook(MacroFrame.MacroSelector.ScrollBox, 'Update', function(self)
        if not self:HasView() then
            return
        end
        for _, btn in pairs(self:GetFrames()or {}) do
            if btn.indexLable then
                btn:set_index_label()
            end
        end
    end)
end







function WoWTools_MacroMixin:Init_MacroButton_Plus()
    Init()
end