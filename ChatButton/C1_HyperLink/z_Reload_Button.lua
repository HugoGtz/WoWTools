local function Create_Texture_Tips(btn, data)--atlas, coord)
    if not btn then
        return
    end
    if data and not btn.Texture then
        btn.Texture= btn:CreateTexture(nil, 'BORDER')
        btn.Texture:SetSize(26, 26)--200, 36
        btn.Texture:SetPoint('RIGHT', btn, 'LEFT', 6,0)
    end
    if btn.Texture then
        if data and data[1] then
            btn.Texture:SetAtlas(data[1])
        else
            btn.Texture:SetTexture(nil)
        end
        if data and data[2] then
            btn.Texture:SetTexCoord(1,0,1,0)
        end
    end

    local font= btn:GetFontString()
    local r, g, b
    if data and data[3] then
        r, g, b= data[3][1], data[3][2], data[3][3]
    elseif data then
        r, g, b= 1, 1, 1
    end
    font:SetTextColor(r or 1, g or 0.82, b or 0)
end







local Init_Once--se crea abajo

--La comprobación va fuera del "una sola vez": se vuelve a mirar en cada llamada
local function Init()
    if WoWTools_HyperLink:Save().not_Add_Reload_Button then
        return
    end
    Init_Once()
end

Init_Once= WoWTools_Once(function()

   local dataButton={--layoutIndex
        [WoWTools_TextMixin:CN(GAMEMENU_OPTIONS)]= {'mechagon-projects', false},
        [WoWTools_TextMixin:CN(HUD_EDIT_MODE_MENU)]= {'UI-HUD-Minimap-CraftingOrder-Up', false},
        [WoWTools_TextMixin:CN(MACROS)]= {'NPE_Icon', false},

        [WoWTools_TextMixin:CN(ADDONS)]= {'dressingroom-button-appearancelist-up', false},
        [WoWTools_TextMixin:CN(LOG_OUT)]= {'perks-warning-large', false, {0,0.8,1}},
        [WoWTools_TextMixin:CN(EXIT_GAME)]= {'Ping_Chat_Warning', false, {0,0.8,1}},
        [WoWTools_TextMixin:CN(RETURN_TO_GAME)]= {'poi-traveldirections-arrow', true, {0,1,0}},
    }


    local frame= SettingsPanel.AddOnsTab
    if frame then--common-icon-exit
        frame.reload= CreateFrame('Button', nil, frame, 'GameMenuButtonTemplate')
        frame.reload:SetText(WoWTools_L.RELOADUI)
        frame.reload:SetScript('OnLeave', GameTooltip_Hide)
        frame.reload:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_HyperLink.addName)
            GameTooltip:AddDoubleLine(WoWTools_L.RELOADUI, '|cnGREEN_FONT_COLOR:'..SLASH_RELOAD1)
            GameTooltip:Show()
        end)
        frame.reload:SetScript('OnClick', function() WoWTools_DataMixin:Reload() end)
        Create_Texture_Tips(frame.reload, 'BattleBar-SwapPetIcon')
        WoWTools_TextureMixin:SetUIButton(frame.reload)
    end



    SettingsPanel.AddOnsTab.reload:SetPoint('RIGHT', SettingsPanel.ApplyButton, 'LEFT', -15,0)
    WoWTools_LabelMixin:Create(nil, {changeFont= SettingsPanel.OutputText, size=14})
    SettingsPanel.OutputText:ClearAllPoints()
    SettingsPanel.OutputText:SetPoint('BOTTOMLEFT', 20, 18)




--Blizzard_GameMenu/Standard/GameMenuFrame.lua
    WoWTools_DataMixin:Hook(GameMenuFrame, 'InitButtons', function(self)

        for btn in self.buttonPool:EnumerateActive() do
            local data= dataButton[btn:GetText()]
            Create_Texture_Tips(btn, data)
        end

        self:AddSection()

        local btn = self:AddButton(
            WoWTools_L.RELOADUI,
        function()
            WoWTools_DataMixin:Reload()
        end)
        WoWTools_TextureMixin:SetUIButton(btn)

        Create_Texture_Tips(btn, {'BattleBar-SwapPetIcon', false, {1,1,1}})
    end)
end)







function WoWTools_HyperLink:Init_Reload()
    Init()
end