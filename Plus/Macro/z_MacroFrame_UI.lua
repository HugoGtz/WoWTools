local function Save()
    return WoWToolsPlusSave['Plus_Macro2']
end




function WoWTools_MoveMixin.Events:Blizzard_MacroUI()
    if Save().disabled then
        self:Setup(MacroFrame)
    end
end






local ScrollFrame








local function bgPoint(icon)
    local value= not Save().disabled and Save().toRightLeft or 3
    icon:ClearAllPoints()
    if value==1 then
        icon:SetPoint('TOPRIGHT', 3, 3)
        icon:SetPoint('BOTTOMRIGHT', 3, -3)
        icon:SetPoint('LEFT', MacroFrame.MacroSelector, -3, 0)
    elseif value==2 then
        icon:SetPoint('TOPLEFT', -3, 3)
        icon:SetPoint('BOTTOMLEFT', -3, -3)
        icon:SetPoint('RIGHT', MacroFrame.MacroSelector, 3, 0)
    else
        icon:SetPoint('TOPLEFT', 3, -3)
        icon:SetPoint('BOTTOMRIGHT',-3, 3)
    end
end














local function Init()
    MacroFrameEnterMacroText:SetText('')
    MacroFrameEnterMacroText:Hide()
    MacroFrameText.Instructions= WoWTools_LabelMixin:Create(MacroFrameText, {layer='BORDER', color={r=0.35, g=0.35, b=0.35}})
    MacroFrameText.Instructions:SetPoint('TOPLEFT')
    MacroFrameText.Instructions:SetText(WoWTools_L.ENTER_MACRO_LABEL)
    MacroFrameText:HookScript('OnTextChanged', function(s)
        s.Instructions:SetShown(s:GetText() == "")
    end)
    MacroFrameCharLimitText:SetParent(MacroFrameScrollFrame)
    MacroFrameCharLimitText:ClearAllPoints()
    MacroFrameCharLimitText:SetPoint('BOTTOMRIGHT', MacroFrameScrollFrame)
    MacroFrameCharLimitText:SetTextColor(0.93, 0.82, 0)
    MacroFrameCharLimitText:SetAlpha(0.75)
    MacroFrameText:HookScript('OnTextChanged', function(self)
        local num=self:GetNumLetters() or 0
        MacroFrameCharLimitText:SetFormattedText((num==255 and '|cff626262' or '')..num..'/255')
    end)

    MacroFrameTextBackground.NineSlice:HookScript('OnMouseDown', function(_, d)
        if d=='LeftButton' then
            MacroFrameText:SetFocus()
        end
    end)

    MacroFrameTab2.Text:SetTextColor(PlayerUtil.GetClassColor():GetRGB())


    MacroSaveButton.saveTip= MacroSaveButton:CreateTexture(nil, 'OVERLAY')
    MacroSaveButton.saveTip:SetPoint('LEFT')
    MacroSaveButton.saveTip:SetSize(18, 18)
    MacroSaveButton.saveTip:SetAtlas('auctionhouse-icon-favorite')
    MacroSaveButton.saveTip:Hide()
    local function set_saveTip()
        local show= false
        local index= WoWTools_MacroMixin:GetSelectIndex()
        if index then
            show= select(3, GetMacroInfo(index))~= MacroFrameText:GetText()
        end
        MacroSaveButton.saveTip:SetShown(show)
    end
    MacroFrameText:HookScript('OnTextChanged', set_saveTip)
    MacroSaveButton:HookScript('OnClick', set_saveTip)


    MacroFrameTab1.label= MacroFrameTab1:CreateFontString(nil, 'OVERLAY', 'GameFontWhite')
    MacroFrameTab1.label:SetPoint('BOTTOM', MacroFrameTab1.Text, 'TOP', 0, 8)
    MacroFrameTab1.label:SetAlpha(0.7)

    MacroFrameTab2.label= MacroFrameTab2:CreateFontString(nil, 'OVERLAY', 'GameFontNormal') --WoWTools_LabelMixin:Create(MacroFrameTab2)
    WoWTools_ColorMixin:SetLabelColor(MacroFrameTab2.label)
    MacroFrameTab2.label:SetPoint('BOTTOM', MacroFrameTab2.Text, 'TOP', 0, 8)
    MacroFrameTab2.label:SetAlpha(0.7)
    WoWTools_DataMixin:Hook(MacroFrame, 'Update', function()
    	local numAccountMacros, numCharacterMacros
        numAccountMacros, numCharacterMacros = GetNumMacros()
        numAccountMacros= numAccountMacros or 0
        numAccountMacros= numAccountMacros==MAX_ACCOUNT_MACROS and '|cff626262'..numAccountMacros or numAccountMacros

        numCharacterMacros= numCharacterMacros or 0
        numCharacterMacros= numCharacterMacros==MAX_CHARACTER_MACROS and '|cff626262'..numCharacterMacros or numCharacterMacros

        MacroFrameTab1.label:SetText(numAccountMacros..'/'..MAX_ACCOUNT_MACROS)
        MacroFrameTab2.label:SetText(numCharacterMacros..'/'..MAX_CHARACTER_MACROS)
    end)


    local regions= {MacroFrame:GetRegions()}
    for index, frame in pairs(regions) do
        if frame:IsObjectType('FontString') and frame:GetText()==CREATE_MACROS then
            frame:SetParent(MacroFrame.TitleContainer)

        elseif frame==MacroHorizontalBarLeft then
            frame:SetTexture(0)
            frame:Hide()
            local f= regions[index+1]
            if f and f:IsObjectType('Texture') then
                f:SetTexture(0)
                f:Hide()
            end
        end
    end


    MacroFrameSelectedMacroButton:ClearAllPoints()
    MacroFrameSelectedMacroButton:SetPoint('BOTTOMLEFT', MacroFrameScrollFrame, 'TOPLEFT', 6, 12)
    local region= MacroFrameSelectedMacroButton:GetRegions()
    if region and region:IsObjectType('Texture') then
        region:Hide()
    end

    MacroFrameSelectedMacroName:ClearAllPoints()
    MacroFrameSelectedMacroName:SetPoint('TOPLEFT', MacroFrameSelectedMacroButton, 'TOPRIGHT', 4, 4)
    MacroFrameSelectedMacroName:SetFontObject('GameFontNormal')

    MacroEditButton:ClearAllPoints()
    MacroEditButton:SetPoint('BOTTOMLEFT', MacroFrameSelectedMacroButton, 'BOTTOMRIGHT', 2, -2)
    MacroEditButton:SetSize(60,22)--170 22
    MacroEditButton:SetText(WoWTools_L.EDIT)

    --MacroCancelButton:ClearAllPoints()
    --MacroCancelButton:SetPoint('')
    MacroSaveButton:ClearAllPoints()
    MacroSaveButton:SetPoint('BOTTOM', MacroCancelButton, 'TOP', 0, 2)

--EditBox
    MacroFrameText:ClearAllPoints()
    MacroFrameText:SetAllPoints(MacroFrameScrollFrame)

    MacroFrameTextBackground:ClearAllPoints()
    MacroFrameTextBackground:SetPoint('TOPLEFT',MacroFrameScrollFrame, -4, 4)
    MacroFrameTextBackground:SetPoint('BOTTOMRIGHT', MacroFrameScrollFrame, 4,-4)

    MacroFrameSelectedMacroBackground:SetTexture(0)
    --MacroFrameSelectedMacroBackground:SetPoint('CENTER', MacroFrameSelectedMacroButton)

    WoWTools_MoveMixin:Setup(MacroFrame, {
        minW=260, minH=250,
    sizeRestFunc=function(f)
        f:SetSize(338, 424)
    end})


    Init=function()end
end













local function Init_Scroll()
    ScrollFrame= CreateFrame("Frame", nil, MacroFrame)


    ScrollFrame:RegisterEvent("UPDATE_MACROS")
    ScrollFrame:SetScript("OnEvent", function(self)
        self.tempScrollPer = MacroFrame.MacroSelector.ScrollBox.scrollPercentage
    end)


    WoWTools_DataMixin:Hook(MacroFrame, "SelectMacro", function(self)
        if ScrollFrame.tempScrollPer and not InCombatLockdown() then
            self.MacroSelector.ScrollBox:SetScrollPercentage(ScrollFrame.tempScrollPer)
        end
        ScrollFrame.tempScrollPer = nil
    end)



    ScrollFrame:SetScript('OnShow', function(self)
        self:RegisterEvent("UPDATE_MACROS")
        C_Timer.After(0.1, function()
            local index= self.selectionIndex
            if index and not InCombatLockdown() then
                if index>MAX_ACCOUNT_MACROS then
                    index= index-MAX_ACCOUNT_MACROS
                    WoWTools_DataMixin:Call(MacroFrame.ChangeTab, MacroFrame, 2)
                end

                MacroFrame:SelectMacro(index)
                MacroFrame.MacroSelector.ScrollBox:SetScrollPercentage(self.tempScrollPer2)

            end
            self.selectionIndex=nil
            self.tempScrollPer2=nil
        end)
    end)



    ScrollFrame:SetScript('OnHide', function(self)
        self:UnregisterEvent("UPDATE_MACROS")
        self.selectionIndex= WoWTools_MacroMixin:GetSelectIndex()

        self.tempScrollPer2=  MacroFrame.MacroSelector.ScrollBox.scrollPercentage
    end)

    Init_Scroll=function()end
end










function WoWTools_MacroMixin:Init_Set_UI()
    Init()
    Init_Scroll()
end

function WoWTools_MacroMixin:Init_Set_BG()
    local icon= MacroFrame[WoWTools_TextureMixin:Get_BGName()]
    if icon then
        bgPoint(icon)
    end
end