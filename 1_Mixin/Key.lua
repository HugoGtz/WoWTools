WoWTools_KeyMixin={}

local Frame=CreateFrame('Frame')
Frame.buttons={}

function Frame:set_event()
    self:RegisterEvent('PLAYER_REGEN_ENABLED')
end

Frame:SetScript("OnEvent", function(self)
    do
        for btn, info in pairs(self.buttons) do
            WoWTools_KeyMixin:Setup(btn, info.isDisabled)
        end
    end
    self.buttons={}
    self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end)


function WoWTools_KeyMixin:Init(btn, GetValue, notSetup)
    if not btn then
        return
    end
    btn.GetKEY= GetValue or btn.GetKey or btn.GetKEY
    btn.KEYstring= btn:CreateFontString(nil, 'ARTWORK', 'ChatFontNormal')
    btn.KEYstring:SetPoint('TOPRIGHT')

    btn.KEYtexture=btn:CreateTexture(nil,'OVERLAY')
    btn.KEYtexture:SetPoint('BOTTOM', btn.border, -1, -3)
    btn.KEYtexture:SetAtlas('NPE_ArrowDown')
    btn.KEYtexture:SetVertexColor(0,1,0)
    btn.KEYtexture:SetDesaturated(true)
    btn.KEYtexture:SetSize(30, 15)
    btn.KEYtexture:Hide()

    function btn:get_key_text()
        local key=self:GetKEY()
        if key then
            return (WoWTools_KeyMixin:IsKeyValid(self) and '|cnGREEN_FONT_COLOR:' or '|cff828282')
            ..(WoWTools_L.SETTINGS_KEYBINDINGS_LABEL)
            ..'|A:NPE_Icon:0:0|a'..(key or '')
            ..'|r'
        end
    end

    if not notSetup then
        self:Setup(btn)
    end
end



function WoWTools_KeyMixin:IsKeyValid(btn)
    local key=btn:GetKEY()
    local action= key and GetBindingAction(key, true)
    if action and action==('CLICK '..btn:GetName()..':LeftButton') then
        return key
    end
end

function WoWTools_KeyMixin:SetTexture(btn, key)
    key=key or btn:GetKEY()
    if self:IsKeyValid(btn) then
        if #key==1 then
            btn.KEYstring:SetText(key)
            btn.KEYtexture:SetShown(false)
        else
            btn.KEYstring:SetText('')
            btn.KEYtexture:SetShown(true)
        end
    else
        btn.KEYstring:SetText('')
        btn.KEYtexture:SetShown(false)
    end
end




function WoWTools_KeyMixin:Setup(btn, isDisabled)
    --if PlayerIsInCombat() then
    if not btn:CanChangeAttribute() then
        Frame.buttons[btn]={isDisabled=isDisabled}
        Frame:set_event()
        return
    end

    local key=btn:GetKEY()
    if key and not isDisabled then
        SetOverrideBindingClick(btn, true, key, btn:GetName(), 'LeftButton')
    else
        ClearOverrideBindings(btn)
    end
    self:SetTexture(btn)
end


function WoWTools_KeyMixin:SetMenu(frame, root, tab)
    local sub=root:CreateButton(
        (WoWTools_L['SETTINGS+SETTINGS_KEYBINDINGS_LABEL'])
        ..(tab.key and ' ['..tab.key..']' or ''),
    function(data)
        StaticPopup_Show('WoWTools_EditText',
            (data.name and data.name..' ' or '')
            ..(WoWTools_L.SETTINGS_KEYBINDINGS_LABEL)
            ..'|n|n"|cnGREEN_FONT_COLOR:Q|r", "|cnGREEN_FONT_COLOR:ALT-Q|r","|cnGREEN_FONT_COLOR:BUTTON5|r"|n"|cnGREEN_FONT_COLOR:ALT-CTRL-SHIFT-Q|r"',
            nil,
            {
                text=data.key,
                key=data.key,
                OnShow=function(s, tab2)
                    local edit= s.editBox or s:GetEditBox()
                    if not tab2.key then
                        edit:SetText('BUTTON5')
                    end
                end,
                SetValue=function(s, tab2)
                    local edit= s.editBox or s:GetEditBox()
                    local text= edit:GetText()
                    text=text:gsub(' ','')
                    text=text:gsub('%[','')
                    text=text:gsub(']','')
                    text=text:upper()
                    tab2.GetKey(text)
                    WoWTools_Print(WoWTools_DataMixin.addName, data.name, text)
                end,
                OnAlt=data.OnAlt,
                GetKey=data.GetKey,
            }
        )
    end, tab)
    sub:SetEnabled(not WoWTools_FrameMixin:IsLocked(frame))

    sub:SetTooltip(function(tooltip, desc)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Key.SetKey'])
        tooltip:AddDoubleLine(WoWTools_L.SETTINGS, desc.data.name)
        tooltip:AddDoubleLine(
            WoWTools_L.SETTINGS_KEYBINDINGS_LABEL,
            desc.data.key
        )
        tooltip:AddLine(frame:get_key_text())
    end)

    --sub:SetEnabled(not PlayerIsInCombat())
    return sub
end


function WoWTools_KeyMixin:SetButtonKey(frame, set, key, click)
    if set then
        SetOverrideBindingClick(frame, true, key, frame:GetName(), click or 'LeftButton')
    else
        ClearOverrideBindings(frame)
    end
end


--NPE_ArrowDown
--NPE_ArrowUp
--CreateAtlasMarkup(atlasName, width, height, offsetX, offsetY, rVertexColor, gVertexColor, bVertexColor)
--CreateTextureMarkup(file, fileWidth, fileHeight, width, height, left, right, top, bottom, xOffset, yOffset)
--poi-door-arrow-down
--poi-door-arrow-up
--[KEY_BUTTON1]='|A:newplayertutorial-icon-mouse-leftbutton:0:0|a',
--[KEY_BUTTON2]='|A:newplayertutorial-icon-mouse-rightbutton:0:0|a',
--[SHIFT_KEY]= 's',
local KeyTabs={
    [KEY_BUTTON3]='|A:newplayertutorial-icon-mouse-middlebutton:0:0|a',
    [KEY_MOUSEWHEELUP]='|A:poi-door-arrow-up:0:0:-3:0|a',
    [KEY_MOUSEWHEELDOWN]='|A:poi-door-arrow-down:0:0:-3:0|a',
    [KEY_BUTTON10:gsub(10, '')]= "|A:newplayertutorial-icon-mouse-middlebutton:0:0|a",
}


function WoWTools_KeyMixin:GetHotKeyText(keyText, action)
    local text= keyText or (action and GetBindingKeyForAction(action, false, false))
    if not text or text=='' or text==RANGE_INDICATOR then
        return
    end

    for t, a in pairs(KeyTabs) do
        text= text:gsub(t, a)
    end

    if text~=keyText then
        return text
    end
end