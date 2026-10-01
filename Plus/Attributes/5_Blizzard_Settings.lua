--Opciones de Atributos para el Centro de control (esquema de docs/SETTINGS.md).
--Antes era una subpágina de Blizzard con marcos propios; ahora todo está en el esquema `options` (0_Init.lua).

local function Button()
    return _G['WoWToolsAttributesMainButton']
end

--Vuelve a dibujar el panel (solo si el botón existe: con el módulo desactivado no se crea)
local function Refresh()
    if Button() then
        WoWTools_AttributesMixin:Frame_Init(true)
    end
end

local function Refresh_Show()
    local btn= Button()
    if btn then
        btn:set_Show_Hide()
    end
end

local function Tab(save, name)
    save.tab= save.tab or {}
    save.tab[name]= save.tab[name] or {name=name}
    return save.tab[name]
end

local StatList= {
    {name='STATUS', text='Primary stat'},
    {name='CRITCHANCE', text='STAT_CRITICAL_STRIKE'},
    {name='HASTE', text='STAT_HASTE'},
    {name='MASTERY', text='STAT_MASTERY'},
    {name='VERSATILITY', text='STAT_VERSATILITY'},
    {name='LIFESTEAL', text='STAT_LIFESTEAL'},
    {name='AVOIDANCE', text='STAT_AVOIDANCE'},
    {name='ARMOR', text='STAT_ARMOR', tank=true},
    {name='DODGE', text='STAT_DODGE', tank=true},
    {name='PARRY', text='STAT_PARRY', tank=true},
    {name='BLOCK', text='STAT_BLOCK', tank=true},
    {name='STAGGER', text='STAT_STAGGER', tank=true},
    {name='SPEED', text='STAT_MOVEMENT_SPEED'},
}

local StrataValues= {}
for _, strata in ipairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
    table.insert(StrataValues, {value=strata, text=strata})
end

local function Hex_Get(hex, r, g, b)
    local r2, g2, b2, a2= WoWTools_ColorMixin:HEXtoRGB(hex)
    return r2 or r, g2 or g, b2 or b, a2 or 1
end

local function Hex_Set(r, g, b, a)
    local hex= WoWTools_ColorMixin:RGBtoHEX(r, g, b, a)
    return hex and '|c'..hex
end

local function Stat_Hidden(info)
    return function(save)
        return Tab(save, info.name).hide
    end
end

local function Get_Options()
    local list= {
        {type='section', text='GENERAL'},
        {type='check', key='show', text='SHOW', tooltip='Tip.Attributes.Show',
            get= function(save) return not save.hide end,
            set= function(save, value) save.hide= not value and true or nil end,
            apply= Refresh_Show,
        },
        {type='check', key='onlyDPS', text='Hide secondary stats when tanking', tooltip='Tip.Attributes.OnlyDPS',
            get= function(save) return save.onlyDPS end,
            set= function(save, value) save.onlyDPS= value and true or false end,
            apply= Refresh,
        },
        {type='button', key='resetValues', text='RESET+STATUS_TEXT_VALUE', buttonText='RESET', tooltip='Tip.Attributes.Reset',
            func= Refresh,
        },

        {type='section', text='Automations'},
        {type='check', key='hideInPetBattle', text='SELF_CAST_AUTO+HIDE', tooltip='Tip.Attributes.AutoHide', automation=true,
            get= function(save) return save.hideInPetBattle end,
            set= function(save, value) save.hideInPetBattle= value and true or false end,
            apply= function()
                local btn= Button()
                if btn then
                    btn:set_event()
                    btn:settings()
                end
            end,
        },

        {type='section', text='Shown stats'},
    }

    for _, info in ipairs(StatList) do
        table.insert(list, {type='check', key='stat'..info.name, text=info.text,
            tooltip= info.tank and 'Tip.Attributes.TankStat' or 'Tip.Attributes.Stat',
            get= function(save) return not Tab(save, info.name).hide end,
            set= function(save, value) Tab(save, info.name).hide= not value and true or nil end,
            apply= Refresh,
        })
        if info.name=='STATUS' then
            table.insert(list, {type='check', key='statusBar', text='Bar', tooltip='Tip.Attributes.StatusBar', indent=true,
                disabled= Stat_Hidden(info),
                get= function(save) return Tab(save, 'STATUS').bar end,
                set= function(save, value) Tab(save, 'STATUS').bar= value and true or false end,
                apply= Refresh,
            })
            table.insert(list, {type='slider', key='statusBit', text='Decimals', min=0, max=3, step=1, indent=true,
                disabled= Stat_Hidden(info),
                get= function(save) return Tab(save, 'STATUS').bit or 3 end,
                set= function(save, value) Tab(save, 'STATUS').bit= math.floor(value) end,
                apply= Refresh,
            })
        elseif info.name=='VERSATILITY' then
            table.insert(list, {type='check', key='versOnlyDefense', text='Defense only', tooltip='Tip.Attributes.VersDefense', indent=true,
                disabled= Stat_Hidden(info),
                get= function(save) return Tab(save, 'VERSATILITY').onlyDefense end,
                set= function(save, value) Tab(save, 'VERSATILITY').onlyDefense= value and true or nil end,
                apply= Refresh,
            })
            table.insert(list, {type='check', key='versBoth', text='Damage and defense', tooltip='Tip.Attributes.VersBoth', indent=true,
                disabled= function(save) return Tab(save, 'VERSATILITY').hide or Tab(save, 'VERSATILITY').onlyDefense end,
                get= function(save) return Tab(save, 'VERSATILITY').damageAndDefense end,
                set= function(save, value) Tab(save, 'VERSATILITY').damageAndDefense= value and true or nil end,
                apply= Refresh,
            })
        end
    end

    table.insert(list, {type='section', text='Stat colors'})
    for _, info in ipairs(StatList) do
        if info.name~='STATUS' then--el atributo principal usa el color de la clase
            table.insert(list, {type='color', key='color'..info.name, text=info.text, hasAlpha=true,
                tooltip='Tip.Attributes.StatColor',
                get= function(save)
                    local t= Tab(save, info.name)
                    return t.r or 1, t.g or 0.82, t.b or 0, t.a or 1
                end,
                set= function(save, r, g, b, a)
                    local t= Tab(save, info.name)
                    t.r, t.g, t.b, t.a= r, g, b, a
                end,
                apply= function()
                    local btn= Button()
                    local frame= btn and btn[info.name]
                    if frame then
                        local t= Tab(WoWTools_AttributesMixin:Save(), info.name)
                        if frame.label then
                            frame.label:SetTextColor(t.r, t.g, t.b, t.a)
                        end
                        if frame.bar then
                            frame.bar:SetStatusBarColor(t.r, t.g, t.b, t.a)
                        end
                    end
                    Refresh()
                end,
            })
        end
    end

    local more= {
        {type='section', text='Values'},
        {type='check', key='notText', text='Show values', tooltip='Tip.Attributes.ShowValues',
            get= function(save) return not save.notText end,
            set= function(save, value) save.notText= not value and true or nil end,
            apply= Refresh,
        },
        {type='color', key='textColor', text='Value color', hasAlpha=true, indent=true,
            disabled= function(save) return save.notText end,
            get= function(save) local c= save.textColor or {} return c.r or 1, c.g or 1, c.b or 1, c.a or 1 end,
            set= function(save, r, g, b, a) save.textColor= {r=r, g=g, b=b, a=a} end,
            apply= Refresh,
        },
        {type='check', key='useNumber', text='Show as numbers', tooltip='Tip.Attributes.UseNumber',
            get= function(save) return save.useNumber end,
            set= function(save, value) save.useNumber= value and true or nil end,
            apply= Refresh,
        },
        {type='slider', key='bit', text='Decimals', tooltip='Tip.Attributes.Decimals', min=0, max=3, step=1,
            get= function(save) return save.bit or 0 end,
            set= function(save, value) save.bit= math.floor(value) end,
            apply= Refresh,
        },
        {type='check', key='setMaxMinValue', text='Show changes', tooltip='Tip.Attributes.Changes',
            get= function(save) return save.setMaxMinValue end,
            set= function(save, value) save.setMaxMinValue= value and true or false end,
            apply= Refresh,
        },
        {type='color', key='greenColor', text='Increase color', indent=true,
            disabled= function(save) return not save.setMaxMinValue end,
            get= function(save) return Hex_Get(save.greenColor, 0, 1, 0) end,
            set= function(save, r, g, b, a) save.greenColor= Hex_Set(r, g, b, a) or '|cff00ff00' end,
            apply= Refresh,
        },
        {type='color', key='redColor', text='Decrease color', indent=true,
            disabled= function(save) return not save.setMaxMinValue end,
            get= function(save) return Hex_Get(save.redColor, 1, 0, 0) end,
            set= function(save, r, g, b, a) save.redColor= Hex_Set(r, g, b, a) or '|cffff4800' end,
            apply= Refresh,
        },
        {type='check', key='toLeft', text='Values on the left', tooltip='Tip.Attributes.ToLeft',
            get= function(save) return save.toLeft end,
            set= function(save, value) save.toLeft= value and true or nil end,
            apply= Refresh,
        },
        {type='slider', key='gsubText', text='Shorten names', tooltip='Tip.Attributes.Shorten', min=0, max=20, step=1,
            get= function(save) return save.gsubText or 0 end,
            set= function(save, value) value= math.floor(value) save.gsubText= value>0 and value or nil end,
            apply= Refresh,
        },
        {type='dropdown', key='textCase', text='Text case', tooltip='Tip.Attributes.TextCase',
            values= {
                {value='none', text='NONE'},
                {value='upper', text='Uppercase'},
                {value='lower', text='Lowercase'},
            },
            get= function(save) return save.strupper and 'upper' or save.strlower and 'lower' or 'none' end,
            set= function(save, value)
                save.strupper= value=='upper' and true or nil
                save.strlower= value=='lower' and true or nil
            end,
            apply= Refresh,
        },

        {type='section', text='Bars'},
        {type='check', key='bar', text='Show bars', tooltip='Tip.Attributes.Bars',
            get= function(save) return save.bar end,
            set= function(save, value) save.bar= value and true or false end,
            apply= Refresh,
        },
        {type='check', key='barTexture2', text='Alternative bar texture', indent=true,
            disabled= function(save) return not save.bar end,
            get= function(save) return save.barTexture2 end,
            set= function(save, value) save.barTexture2= value and true or false end,
            apply= Refresh,
        },
        {type='slider', key='barWidth', text='WIDE', tooltip='Tip.Attributes.BarWidth', min=-119, max=250, step=1, indent=true,
            disabled= function(save) return not save.bar end,
            get= function(save) return save.barWidth or 0 end,
            set= function(save, value) save.barWidth= math.floor(value) end,
            apply= Refresh,
        },
        {type='slider', key='barX', text='X', min=-250, max=250, step=1, indent=true,
            disabled= function(save) return not save.bar end,
            get= function(save) return save.barX or 0 end,
            set= function(save, value) save.barX= math.floor(value) end,
            apply= Refresh,
        },
        {type='check', key='barToLeft', text='Bars on the left', indent=true,
            disabled= function(save) return not save.bar end,
            get= function(save) return save.barToLeft end,
            set= function(save, value) save.barToLeft= value and true or nil end,
            apply= Refresh,
        },

        {type='section', text='Appearance'},
        {type='slider', key='scale', text='HOUSING_EXPERT_DECOR_SUBMODE_SCALE', min=0.3, max=4, step=0.1, format='%.1f',
            get= function(save) return save.scale or 1 end,
            set= function(save, value) save.scale= tonumber(format('%.1f', value)) or 1 end,
            apply= function(_, save)
                local btn= Button()
                if btn then
                    btn.frame:SetScale(save.scale)
                end
            end,
        },
        {type='slider', key='vertical', text='Vertical spacing', min=-5, max=10, step=0.1, format='%.1f',
            get= function(save) return save.vertical or 0 end,
            set= function(save, value) save.vertical= tonumber(format('%.1f', value)) end,
            apply= Refresh,
        },
        {type='slider', key='horizontal', text='Horizontal spacing', min=-0.1, max=40, step=0.1, format='%.1f',
            get= function(save) return save.horizontal or 0 end,
            set= function(save, value) save.horizontal= tonumber(format('%.1f', value)) end,
            apply= Refresh,
        },
        {type='color', key='shadow', text='Shadow', tooltip='Tip.Attributes.Shadow', hasAlpha=true,
            get= function(save) local c= save.font or {} return c.r or 0, c.g or 0, c.b or 0, c.a or 1 end,
            set= function(save, r, g, b, a)
                save.font= save.font or {x=0, y=0}
                save.font.r, save.font.g, save.font.b, save.font.a= r, g, b, a
            end,
            apply= Refresh,
        },
        {type='slider', key='shadowX', text= function() return WoWTools_L['Shadow']..' X' end, min=-5, max=5, step=1, indent=true,
            get= function(save) return save.font and save.font.x or 0 end,
            set= function(save, value) save.font= save.font or {r=0, g=0, b=0, a=1} save.font.x= math.floor(value) end,
            apply= Refresh,
        },
        {type='slider', key='shadowY', text= function() return WoWTools_L['Shadow']..' Y' end, min=-5, max=5, step=1, indent=true,
            get= function(save) return save.font and save.font.y or 0 end,
            set= function(save, value) save.font= save.font or {r=0, g=0, b=0, a=1} save.font.y= math.floor(value) end,
            apply= Refresh,
        },
        {type='slider', key='bgAlpha', text='BACKGROUND+HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', tooltip='Tip.Menu.BgAlpha',
            min=0, max=1, step=0.1, format='%.1f',
            get= function(save) return save.bgAlpha or 0.5 end,
            set= function(save, value) save.bgAlpha= tonumber(format('%.1f', value)) end,
            apply= Refresh,
        },
        {type='dropdown', key='strata', text='Strata', tooltip='Tip.Menu.Strata', values=StrataValues,
            get= function(save) return save.strata or 'MEDIUM' end,
            set= function(save, value) save.strata= value end,
            apply= function()
                local btn= Button()
                if btn then
                    btn:set_strata()
                end
            end,
        },
        {type='slider', key='buttonAlpha', text='Specialization alpha', tooltip='Tip.Attributes.ButtonAlpha', min=0, max=1, step=0.1, format='%.1f',
            get= function(save) return save.buttonAlpha or 0.3 end,
            set= function(save, value) save.buttonAlpha= tonumber(format('%.1f', value)) end,
            apply= Refresh_Show,
        },
        {type='slider', key='buttonScale', text='SPECIALIZATION+HOUSING_EXPERT_DECOR_SUBMODE_SCALE', min=0.4, max=4, step=0.1, format='%.1f',
            get= function(save) return save.buttonScale or 1 end,
            set= function(save, value) save.buttonScale= math.min(4, math.max(0.4, tonumber(format('%.1f', value)) or 1)) end,
            apply= Refresh_Show,
        },
        {type='button', key='resetPoint', text='RESET_POSITION', buttonText='RESET',
            disabled= function(save) return not save.point end,
            func= function(_, save)
                save.point= nil
                local btn= Button()
                if btn then
                    btn:set_Point()
                end
            end,
        },

        {type='section', text='Advanced'},
        {type='button', key='reset', text='Reset module settings', buttonText='RESET', confirm=true,
            func= function()
                WoWToolsPlusSave['Plus_Attributes']=nil
                WoWTools_DataMixin:Reload()
            end,
        },
    }
    for _, opt in ipairs(more) do
        table.insert(list, opt)
    end
    return list
end

local Options
function WoWTools_AttributesMixin:Get_Options()
    Options= Options or Get_Options()
    return Options
end

--Entrada "Ajustes..." del menú: abre su página del Centro de control (sus submenús: fondo, capa, posición)
function WoWTools_AttributesMixin:Open_Options(root)
    return WoWTools_MenuMixin:OpenOptions(root, {
        name= WoWTools_AttributesMixin.addName,
        name2= WoWTools_L['Settings...'],
    })
end
