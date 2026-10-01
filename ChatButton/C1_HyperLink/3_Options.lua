--Opciones del módulo en el Centro de control (antes: subpágina de Blizzard con dos cuadros de texto).
--Palabras clave a colorear (WoWToolsPlusPlayerDate['HyperLinkColorText']) y sustitución de nombres
--de canal (Save().channels): se editan como texto en una línea y se analizan igual que antes.

local function Ready()--el botón existe (módulo activado y arrancado)
    return WoWTools_ChatMixin:GetButtonForName('HyperLink')
end


--Palabras clave separadas por espacios
function WoWTools_HyperLink:GetKeywordsText()
    local list= {}
    for k in pairs(WoWToolsPlusPlayerDate['HyperLinkColorText'] or {}) do
        if type(k)=='string' then
            table.insert(list, k)
        end
    end
    table.sort(list)
    return table.concat(list, ' ')
end

function WoWTools_HyperLink:SetKeywordsText(text)
    WoWToolsPlusPlayerDate['HyperLinkColorText']={}
    local n=0
    text= (text or '')..' '
    text= text:gsub('\n', ' ')
    text:gsub('.- ', function(t)
        t=t:gsub(' ','')
        if t and t~='' then
            t=WoWTools_TextMixin:Magic(t)
            WoWToolsPlusPlayerDate['HyperLinkColorText'][t]=true
            n=n+1
        end
    end)
    WoWTools_Print(
        WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
        WoWTools_DataMixin.Language.key,
        WoWTools_L.COLOR,
        '|cnGREEN_FONT_COLOR:#'..n..(WoWTools_L.COMPLETE)..'|r'
    )
end


--Sustituciones "palabra=sustituto" separadas por espacios
function WoWTools_HyperLink:GetChannelsText()
    local list= {}
    for k, v in pairs(self:Save().channels or {}) do
        table.insert(list, k..'='..v)
    end
    table.sort(list)
    return table.concat(list, ' ')
end

function WoWTools_HyperLink:SetChannelsText(text)
    self:Save().channels={}
    local n=0
    text= (text or '')..' '
    text= text:gsub('\n', ' ')
    text= text:gsub('  ', '')
    text:gsub('.-=.- ', function(t)
        local name,name2=t:match('(.-)=(.-) ')
        if name and name2 and name~='' and name2~='' then
            name=WoWTools_TextMixin:Magic(name)
            self:Save().channels[name]=name2
            n=n+1
        end
    end)
    WoWTools_Print(
        WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
        '|cnGREEN_FONT_COLOR:'..n..'|r',
        WoWTools_L['Channel name replacement']
    )
end




local function NoLinkIcon(save)
    return not save.linkIcon
end

local function NoKeyColor(save)
    return not save.linkIcon or save.disabledKeyColor
end


function WoWTools_HyperLink:GetOptions()
    return {
        {type='section', text='GENERAL'},
        {type='check', key='linkIcon', text='COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK+EMBLEM_SYMBOL', tooltip='Tip.HyperLink.LinkIcon',
            get= function(save) return save.linkIcon end,
            set= function(save, value) save.linkIcon= value and true or false end,
            apply= function() if Ready() then WoWTools_HyperLink:Init_Link_Icon() end end,
        },
        {type='note', kind='warning', text='RESTRICT_CHAT_CONFIG_DISABLE',
            hidden= function() return not (C_SocialRestrictions and C_SocialRestrictions.IsChatDisabled()) end,
        },
        {type='check', key='playerInfo', text='PLAYER_MESSAGES', tooltip='Tip.HyperLink.PlayerInfo', indent=true,
            disabled= NoLinkIcon,
            get= function(save) return not save.notShowPlayerInfo end,
            set= function(save, value) save.notShowPlayerInfo= not value and true or nil end,
        },
        {type='check', key='itemCount', text='ITEMS+AUCTION_HOUSE_QUANTITY_LABEL', tooltip='Tip.HyperLink.ItemCount', indent=true,
            disabled= NoLinkIcon,
            get= function(save) return not save.notShowItemCount end,
            set= function(save, value) save.notShowItemCount= not value and true or nil end,
        },
        {type='check', key='mapPin', text='MAP_PIN', tooltip='Tip.HyperLink.MapPin', indent=true,
            disabled= NoLinkIcon,
            get= function(save) return not save.notShowMapPin end,
            set= function(save, value) save.notShowMapPin= not value and true or nil end,
        },
        {type='check', key='keyColor', text='Highlight keywords', tooltip='Tip.HyperLink.KeyColor', indent=true,
            disabled= NoLinkIcon,
            get= function(save) return not save.disabledKeyColor end,
            set= function(save, value) save.disabledKeyColor= not value and true or nil end,
        },
        {type='input', key='keywords', text='Set keywords', tooltip='Tip.HyperLink.Keywords', indent=true, width=260,
            disabled= NoKeyColor,
            get= function() return WoWTools_HyperLink:GetKeywordsText() end,
            set= function(_, text) WoWTools_HyperLink:SetKeywordsText(text) end,
        },
        {type='input', key='channels', text='Channel name replacement', tooltip='Tip.HyperLink.Channels', indent=true, width=260,
            placeholder='General=G',
            disabled= NoKeyColor,
            get= function() return WoWTools_HyperLink:GetChannelsText() end,
            set= function(_, text) WoWTools_HyperLink:SetChannelsText(text) end,
        },

        {type='section', text='Automations'},
        {type='check', key='eventSound', text='EVENTS_LABEL+SOUND', tooltip='Tip.HyperLink.EventSound', automation=true,
            get= function(save) return save.setPlayerSound end,
            set= function(save, value) save.setPlayerSound= value and true or nil end,
            apply= function(_, save)
                if save.setPlayerSound then
                    WoWTools_DataMixin:PlaySound()
                end
                if Ready() then
                    WoWTools_HyperLink:Init_Event_Sound()
                end
            end,
        },

        {type='section', text='Appearance'},
        {type='slider', key='iconSize', text='HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE', tooltip='Tip.HyperLink.IconSize',
            min=0, max=32, step=1,
            disabled= NoLinkIcon,
            get= function(save) return save.iconSize or 0 end,
            set= function(save, value) save.iconSize= value end,
            apply= function() WoWTools_HyperLink:Link_Icon_Settings() end,
        },

        {type='section', text='Advanced'},
        {type='check', key='reloadButton', text='Add Reload UI button', tooltip='Tip.HyperLink.ReloadButton', reload=true,
            get= function(save) return not save.not_Add_Reload_Button end,
            set= function(save, value) save.not_Add_Reload_Button= not value and true or nil end,
        },
        {type='button', key='social', text='RESTRICT_CHAT_CONFIG_DISABLE', buttonText='OPTIONS', tooltip='Tip.HyperLink.ChatDisabled',
            func= function()
                if not WoWTools_FrameMixin:IsLocked(SettingsPanel) then
                    Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID, RESTRICT_CHAT_CONFIG_DISABLE)--ItemRef.lua
                end
            end,
        },
    }
end
