--Opciones del cursor (GCD junto al ratón) para el Centro de control (esquema de docs/SETTINGS.md).
--Antes era una subpágina de Blizzard con marcos propios; ahora todo está en el esquema `options` (1_Init.lua).

local function Save()
    return WoWTools_CursorMixin:Save()
end

--Color de la animación: ninguno (blanco), el de la clase o el elegido
function WoWTools_CursorMixin:Set_Color()
    if Save().notUseColor then
        self.Color= CreateColor(1,1,1,1)
    elseif Save().usrClassColor or not Save().color then
        self.Color= PlayerUtil.GetClassColor()
    else
        local col= Save().color
        self.Color= CreateColor(col.r or 1, col.g or 1, col.b or 1, col.a or 1)
    end
end

local function Refresh()
    WoWTools_CursorMixin:Set_Color()
    WoWTools_CursorMixin:GCD_Settings(true)
end

local function GCD_Off(save)
    return save.disabledGCD
end

local function Color_Mode(save)
    if save.notUseColor then
        return 'none'
    elseif save.usrClassColor or not save.color then
        return 'class'
    end
    return 'custom'
end

--Lista de texturas: 0 = aleatoria
local function Texture_Values(save)
    local values= {{value=0, text='Random icon'}}
    for index, texture in ipairs(save.GCDTexture or {}) do
        local icon= select(3, WoWTools_TextureMixin:IsAtlas(texture, 20)) or ''
        values[#values+1]= {value=index, text= icon..' '..index}
    end
    return values
end

function WoWTools_CursorMixin:Get_Options()
    return {
        {type='section', text='GENERAL'},
        {type='check', key='gcd', text= function() return WoWTools_L.ENABLE..' GCD' end, tooltip='Tip.Cursor.EnableGCD',
            get= function(save) return not save.disabledGCD end,
            set= function(save, value) save.disabledGCD= not value and true or nil end,
            apply= Refresh,
        },

        {type='section', text='Appearance'},
        {type='slider', key='size', text='HUD_EDIT_MODE_SETTING_BAGS_SIZE', min=8, max=256, step=1, disabled=GCD_Off,
            get= function(save) return save.gcdSize or 15 end,
            set= function(save, value) save.gcdSize= math.floor(value) end,
            apply= Refresh,
        },
        {type='slider', key='alpha', text='HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', min=0.1, max=1, step=0.1, format='%.1f', disabled=GCD_Off,
            get= function(save) return save.gcdAlpha or 1 end,
            set= function(save, value) save.gcdAlpha= tonumber(format('%.1f', value)) end,
            apply= Refresh,
        },
        {type='slider', key='x', text='X', min=-100, max=100, step=1, disabled=GCD_Off,
            get= function(save) return save.gcdX or 0 end,
            set= function(save, value) save.gcdX= math.floor(value) end,
            apply= Refresh,
        },
        {type='slider', key='y', text='Y', min=-100, max=100, step=1, disabled=GCD_Off,
            get= function(save) return save.gcdY or 0 end,
            set= function(save, value) save.gcdY= math.floor(value) end,
            apply= Refresh,
        },
        {type='check', key='reverse', text='HUD_EDIT_MODE_SETTING_BAGS_DIRECTION', tooltip='Tip.Cursor.GCDReverse', disabled=GCD_Off,
            get= function(save) return save.gcdReverse end,
            set= function(save, value) save.gcdReverse= value and true or false end,
            apply= Refresh,
        },
        {type='check', key='bling', text='Flash when finished', tooltip='Tip.Cursor.GCDDrawBling', disabled=GCD_Off,
            get= function(save) return save.gcdDrawBling end,
            set= function(save, value) save.gcdDrawBling= value and true or false end,
            apply= Refresh,
        },
        {type='dropdown', key='colorMode', text='COLOR', tooltip='Tip.Cursor.ColorMode', disabled=GCD_Off,
            values= {
                {value='class', text='CLASS_COLORS'},
                {value='custom', text='CUSTOM'},
                {value='none', text='NONE'},
            },
            get= Color_Mode,
            set= function(save, value)
                save.notUseColor= value=='none' and true or nil
                save.usrClassColor= value=='class'
                if value=='custom' and not save.color then
                    save.color= {r=0, g=1, b=0, a=1}
                end
            end,
            apply= Refresh,
        },
        {type='color', key='color', text='Custom color', hasAlpha=true, indent=true,
            disabled= function(save) return save.disabledGCD or Color_Mode(save)~='custom' end,
            get= function(save) local c= save.color or {} return c.r or 1, c.g or 1, c.b or 1, c.a or 1 end,
            set= function(save, r, g, b, a) save.color= {r=r, g=g, b=b, a=a} end,
            apply= Refresh,
        },
        {type='dropdown', key='texture', text='TEXTURES_SUBHEADER', tooltip='Tip.Cursor.TextureList', disabled=GCD_Off,
            values= Texture_Values,
            get= function(save)
                if save.randomTexture then
                    return 0
                end
                return save.gcdTextureIndex or 1
            end,
            set= function(save, value)
                if value==0 then
                    save.randomTexture= true
                else
                    save.gcdTextureIndex= value
                    save.randomTexture= false
                end
            end,
            apply= Refresh,
        },
        {type='input', key='addTexture', text='Add texture', tooltip='Tip.Cursor.AddTexture', placeholder='Interface\\...', indent=true,
            disabled=GCD_Off,
            get= function() return '' end,
            set= function(save, text)
                text= text and text:gsub('^%s+', ''):gsub('%s+$', '')
                if text and text~='' then
                    save.GCDTexture= save.GCDTexture or {}
                    table.insert(save.GCDTexture, text)
                end
            end,
        },
        {type='button', key='removeTexture', text='Remove selected texture', buttonText='REMOVE', confirm=true, indent=true,
            tooltip='Tip.Cursor.RemoveTexture',
            disabled= function(save) return save.disabledGCD or save.randomTexture or #(save.GCDTexture or {})<=1 end,
            func= function(_, save)
                local index= save.gcdTextureIndex or 1
                local texture= save.GCDTexture[index]
                table.remove(save.GCDTexture, index)
                save.gcdTextureIndex= 1
                Refresh()
                WoWTools_Print(WoWTools_CursorMixin.addName..WoWTools_DataMixin.Icon.icon2, WoWTools_L.REMOVE, texture)
            end,
        },

        {type='section', text='Advanced'},
        {type='button', key='reset', text='Reset module settings', buttonText='RESET', confirm=true,
            func= function()
                WoWToolsPlusSave['Plus_Cursor']=nil
                WoWTools_DataMixin:Reload()
            end,
        },
    }
end
