

local P_Save={
    point={},
    SavePoint= true,

    scale={},
    size={},
    disabledSize={
        ['WorldMapFrame']= true
    },

    alpha=0.5,
    disabledAlpha={},

    UIPanelWindows={},
    Esc={['CooldownViewerSettings']=false},
    no={},


    --disablesWorldMapFrameSize= true
}

--Nombres de las ventanas (se guardan al cargar: Events/Frames se vacían al aplicarlas)
local EventNames, FrameNames= {}, {}

local function Frame_Option(name)
    return {type='check', key='no:'..name, text=(name:gsub('Blizzard_', '')), tooltip='Tip.Move.FrameModule', reload=true,
        get= function(save) return not (save.no and save.no[name]) end,
        set= function(save, value)
            save.no= save.no or {}
            save.no[name]= not value and true or nil
        end,
    }
end

--Esquema del Centro de control (docs/SETTINGS.md). Antes: subpágina de Blizzard.
local function Get_Options()
    local list= {
        {type='section', text='GENERAL'},
        {type='check', key='savePoint', text='Save position', tooltip='Tip.Move.SavePoint', reload=true,
            get= function(save) return save.SavePoint end,
            set= function(save, value) save.SavePoint= value and true or nil end,
        },
        {type='button', key='clearPoint', text='Clear saved positions', buttonText='SLASH_STOPWATCH_PARAM_STOP2',
            tooltip='Tip.Move.ClearAllPoints', indent=true,
            func= function()
                StaticPopup_Show('WoWTools_RestData', WoWTools_MoveMixin.addName, nil, function()
                    WoWTools_MoveMixin:Save().point={}
                end)
            end,
        },
        {type='check', key='moveAlpha', text='Fade frame when moving', tooltip='Frame fades when you start moving', reload=true,
            get= function(save) return not save.notMoveAlpha end,
            set= function(save, value) save.notMoveAlpha= not value and true or nil end,
        },
        {type='slider', key='alpha', text='HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', tooltip='Tip.Move.AlphaValue',
            min=0, max=0.9, step=0.1, format='%.1f', indent=true,
            disabled= function(save) return save.notMoveAlpha end,
            get= function(save) return save.alpha or 0.5 end,
            set= function(save, value) save.alpha= WoWTools_DataMixin:GetFormatter1to10(value, 0, 1) end,
        },
        {type='note', text='Tip.Move.PerFrame'},

        {type='section', text='Advanced: windows loaded on demand'},
    }
    for _, name in ipairs(EventNames) do
        table.insert(list, Frame_Option(name))
    end
    table.insert(list, {type='section', text='Advanced: always-loaded windows'})
    for _, name in ipairs(FrameNames) do
        table.insert(list, Frame_Option(name))
    end
    table.insert(list, {type='section', text='Advanced'})
    table.insert(list, {type='button', key='reset', text='Reset module settings', buttonText='RESET',
        func= function()
            StaticPopup_Show('WoWTools_RestData', WoWTools_MoveMixin.addName, nil, function()
                WoWToolsPlusSave['Plus_Move']= nil
            end)
        end,
    })
    return list
end

local Options
function WoWTools_MoveMixin:Get_Options()
    Options= Options or Get_Options()
    return Options
end














local function Init()
    WoWTools_MoveMixin:Init_AddButton()
    WoWTools_MoveMixin:Init_Class_Power()

    for name, func in pairs(WoWTools_MoveMixin.Events) do
        if C_AddOns.IsAddOnLoaded(name) and func then
            if not WoWTools_MoveMixin:Save().no[name] then
                func(WoWTools_MoveMixin)
            end
            WoWTools_MoveMixin.Events[name]=nil
        end
    end

    for name, func in pairs(WoWTools_MoveMixin.Frames) do
        if _G[name] and not WoWTools_MoveMixin:Save().no[name] then
            func(WoWTools_MoveMixin)
        end
        WoWTools_MoveMixin.Frames[name]= nil
    end

    for name in pairs(UIPanelWindows) do--diccionario por nombre: ipairs no iteraba nunca
        if type(name)=='string'
            and _G[name]
            and type(_G[name])=='table'
            and _G[name].IsProtected
            and not _G[name]:IsProtected()
            and not WoWTools_MoveMixin:Save().no[name]
            and not _G[name]:IsMovable()
            and not _G[name].moveFrameData
            and not _G[name].ResizeButton
        then
            WoWTools_MoveMixin:Setup(_G[name])
        end
    end

    WoWTools_DataMixin:Hook('UpdateUIPanelPositions', function(currentFrame)
        if WoWTools_MoveMixin:Save().SavePoint then
            WoWTools_MoveMixin:SetPoint(currentFrame)
        end
    end)
end










--Despachador propio de ventanas de Blizzard (WoWTools_MoveMixin.Events): se migra en la fase R3
local function Init_Events()
    local frame= CreateFrame('Frame')
    frame:RegisterEvent('ADDON_LOADED')
    frame:SetScript('OnEvent', function(_, _, arg1)
        if WoWTools_MoveMixin.Events[arg1] then
            if not WoWTools_MoveMixin:Save().no[arg1] then
                WoWTools_MoveMixin.Events[arg1](WoWTools_MoveMixin)
            end
            WoWTools_MoveMixin.Events[arg1]=nil
        end
    end)
end




--Se ejecuta siempre (onLoad), también con el módulo desactivado
local function Init_Category()
    WoWTools_MoveMixin:Save().UIPanelWindows= WoWTools_MoveMixin:Save().UIPanelWindows or P_Save.UIPanelWindows
    --Antes: WoWTools_MoveMixin:Save().Esc= WoWTools_MoveMixin:Save() (faltaba .Esc), la tabla se guardaba dentro de sí misma
    if WoWTools_MoveMixin:Save().Esc==WoWTools_MoveMixin:Save() then
        WoWTools_MoveMixin:Save().Esc= nil
    end
    WoWTools_MoveMixin:Save().Esc= WoWTools_MoveMixin:Save().Esc or P_Save.Esc
    WoWTools_MoveMixin:Save().no= WoWTools_MoveMixin:Save().no or {}

    P_Save= nil

    for name in pairs(WoWTools_MoveMixin.Events) do
        table.insert(EventNames, name)
    end
    for name in pairs(WoWTools_MoveMixin.Frames) do
        table.insert(FrameNames, name)
    end
    table.sort(EventNames)
    table.sort(FrameNames)

    if WoWTools_MoveMixin:Save().disabled then
        WoWTools_MoveMixin.Events={}
        WoWTools_MoveMixin.Frames={}
    end
end




WoWTools_Module:Register({
    key= 'Plus_Move',
    name= 'Module.Move frames',
    icon= 'Interface\\Cursor\\UI-Cursor-Move',
    group= 'Interface',
    defaults= P_Save,
    tooltip= 'Tip.Move.Enable',
    mixin= WoWTools_MoveMixin,
    options= function()
        return WoWTools_MoveMixin:Get_Options()
    end,
    onLoad= Init_Category,
    onEnable= function()
        Init()
        Init_Events()
    end,
})
