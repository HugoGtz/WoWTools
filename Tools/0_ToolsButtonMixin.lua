


WoWTools_ToolsMixin={}--addName y Save() los pone WoWTools_Module (Tools/1_Init.lua)

local Name= 'WoWToolsToolsButton'

local MainButton

local SetID=0

local AddList={}

local AllButtons={}--{'HEARTHSTONE', 'USETOY'}
local LeftButtons1={}
local LeftButtons2={}
local RightButtons={}
local BottomButtons={}
local LeftNewLineButton--antes global por falta de local
local function Set_BG(frame)
    --if frame and frame.Background then
        frame.Background:SetColorTexture(0, 0, 0, WoWTools_ToolsMixin:Save().bgAlpha or 0)
    --end
end

local function Set_Left1Point(frame)
    frame:SetPoint('BOTTOMRIGHT', MainButton.Frame, 'TOPRIGHT', 0, 30)
end
local function Set_Left2Point(frame)
    frame:SetPoint('BOTTOMRIGHT', MainButton.LeftFrame1, 'BOTTOMLEFT')
end
local function Set_RightPoint(frame)
    frame:SetPoint('BOTTOMLEFT', MainButton, 'TOPRIGHT')
end
local function Set_BottomPoint(frame)
    frame:SetPoint('BOTTOMRIGHT', MainButton, 'TOPRIGHT')
end

local function Get_ParentFrame(tab)
    if tab.parentFrame then
        return tab.parentFrame

    elseif WoWTools_ToolsMixin:Save().BottomPoint[tab.name]
        or tab.isMoveButton
    then
        return MainButton
    else
        return MainButton.Frame
    end
end


local function Set_ButtonPoint(btn, tab)
    btn.IsShownFrameEnterButton=nil
    local name= tab.name

    if tab.isLeftOnlyLine then
        if tab.isLeftOnlyLine() then
            local num= #LeftButtons2
            if num==0 then
                Set_Left2Point(btn)
                MainButton.LeftFrame2:SetWidth(30)
            else
                btn:SetPoint('BOTTOM', _G[Name..LeftButtons2[num]], 'TOP')
            end
            MainButton.LeftFrame2:SetPoint('TOP', btn)
            Set_BG(MainButton.LeftFrame2)
            table.insert(LeftButtons2, name)
        else
            local num= #RightButtons
            if num==0 then
                Set_RightPoint(btn)
                MainButton.RightFrame:SetWidth(30)
            else
                btn:SetPoint('BOTTOM', _G[Name..RightButtons[num]], 'TOP')
            end
            MainButton.RightFrame:SetPoint('TOP', btn)
            Set_BG(MainButton.RightFrame)
            table.insert(RightButtons, name)
        end
    else

--BOOTOM
        if WoWTools_ToolsMixin:Save().BottomPoint[name] or tab.isMoveButton then
            local num=#BottomButtons
            if num==0 then
                btn.IsShownFrameEnterButton=true
                Set_BottomPoint(btn)
                MainButton.BottomFrame:SetHeight(30)
            else
                btn:SetPoint('RIGHT', _G[Name..BottomButtons[num]], 'LEFT')
            end
            Set_BG(MainButton.BottomFrame)
            if not tab.isMoveButton then
                MainButton.BottomFrame:SetPoint('TOPLEFT', btn)
                table.insert(BottomButtons, name)
            end
        else
            local num=#LeftButtons1
            if num==0 then
                LeftNewLineButton=name
                Set_Left1Point(btn)
                MainButton.LeftFrame1:SetPoint('TOP', btn)
                MainButton.LeftFrame1:SetPoint('LEFT', btn)
            else
                local numLine= WoWTools_ToolsMixin:Save().lineNum or 10
                if select(2, math.modf(num / numLine))==0 then
                    btn:SetPoint('RIGHT', _G[Name..LeftNewLineButton], 'LEFT')
                    MainButton.LeftFrame1:SetPoint('LEFT', btn)
                    LeftNewLineButton=name
                else
                    btn:SetPoint('BOTTOM', _G[Name..LeftButtons1[num]], 'TOP')
                    if num== (numLine-1) then
                        MainButton.LeftFrame1:SetPoint('TOP', btn)
                    end

                end
            end
            Set_BG(MainButton.LeftFrame1)
            table.insert(LeftButtons1, name)
        end
    end
end


function WoWTools_ToolsMixin:CreateButton(tab)
    tab= tab or {}
    local name =tab.name

    if not tab.disabledOptions then
        table.insert(AddList, tab)
    end
    if not MainButton or WoWTools_ToolsMixin:Save().disabledADD[name] then
        return
    end


    SetID= SetID +1
    local btn= WoWTools_ButtonMixin:Cbtn(Get_ParentFrame(tab), {
        name=Name..name,
        isType2=true,
        isSecure=true,
        size=30,
        setID=SetID,
        --isMenu=tab.isMenu
    })

    btn.IconMask:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
    btn.IconMask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -5, 5)

    function btn:set_border_alpha()
        self.border:SetAlpha(WoWTools_ToolsMixin:Save().borderAlpha or 0.3)
    end

    function btn:GetData()
        return self.ToolsData
    end
    function btn:SetData(data)
        self.ToolsData=data
    end
    btn:SetData(tab)

    WoWTools_Style:IconButton(btn)

    Set_ButtonPoint(btn, tab)

    table.insert(AllButtons, name)

    return btn
end


function WoWTools_ToolsMixin:Init()
    if WoWTools_ToolsMixin:Save().disabled then
        return
    end

    MainButton= CreateFrame('Button', 'WoWToolsMainToolsButton', UIParent, 'WoWToolsButtonTemplate')

    MainButton.Frame= CreateFrame('Frame', nil, MainButton)
    MainButton.Frame:SetAllPoints()
    MainButton.Frame:SetShown(WoWTools_ToolsMixin:Save().show)
    MainButton.IsShownFrameEnterButton=true




    local bgSet= {isAllPoint=true, isColor=true, alpha= WoWTools_ToolsMixin:Save().bgAlpha}
    MainButton.LeftFrame1= CreateFrame('Frame', nil , MainButton.Frame)
    WoWTools_TextureMixin:CreateBG(MainButton.LeftFrame1, bgSet)

    MainButton.LeftFrame2= CreateFrame('Frame', nil, MainButton.Frame)
    WoWTools_TextureMixin:CreateBG(MainButton.LeftFrame2, bgSet)

    MainButton.RightFrame= CreateFrame('Frame', nil, MainButton.Frame)
    WoWTools_TextureMixin:CreateBG(MainButton.RightFrame, bgSet)

    MainButton.BottomFrame= CreateFrame('Frame', nil, MainButton)
    WoWTools_TextureMixin:CreateBG(MainButton.BottomFrame, bgSet)

    Set_Left1Point(MainButton.LeftFrame1)
    Set_Left2Point(MainButton.LeftFrame2)
    Set_RightPoint(MainButton.RightFrame)
    Set_BottomPoint(MainButton.BottomFrame)



    return MainButton
end


function WoWTools_ToolsMixin:ShowBackground()
    Set_BG(MainButton.LeftFrame1)
    Set_BG(MainButton.LeftFrame2)
    Set_BG(MainButton.RightFrame)
    Set_BG(MainButton.BottomFrame)
end


function WoWTools_ToolsMixin:RestAllPoint()
    if not MainButton:CanChangeAttribute() then
        return
    end
    LeftNewLineButton=nil
    local buttons={}
    do
        for _, name in pairs(LeftButtons1) do
            _G[Name..name]:ClearAllPoints()
            table.insert(buttons, name)
        end
        for _, name in pairs(LeftButtons2) do
            _G[Name..name]:ClearAllPoints()
            table.insert(buttons, name)
        end
        for _, name in pairs(RightButtons) do
            _G[Name..name]:ClearAllPoints()
            table.insert(buttons, name)
        end
        for _, name in pairs(BottomButtons) do
            _G[Name..name]:ClearAllPoints()
            table.insert(buttons, name)
        end

        LeftButtons1={}
        LeftButtons2={}
        RightButtons={}
        BottomButtons={}

        LeftNewLineButton=nil

        Set_Left1Point(MainButton.LeftFrame1)
        Set_Left2Point(MainButton.LeftFrame2)
        Set_RightPoint(MainButton.RightFrame)
        Set_BottomPoint(MainButton.BottomFrame)
    end


    table.sort(buttons, function(a, b)
        return _G[Name..a]:GetID() < _G[Name..b]:GetID()
    end)

    do
        for _, name in pairs(buttons) do
            local btn= _G[Name..name]
            local tab= btn:GetData()
            btn:SetParent(Get_ParentFrame(tab))
            Set_ButtonPoint(btn, tab)
        end
    end

end


function WoWTools_ToolsMixin:EnterShowFrame(btn)
    if btn.IsShownFrameEnterButton and WoWTools_ToolsMixin:Save().isEnterShow and not MainButton.Frame:IsShown() then
        MainButton:set_shown()
    end
end




--Entrada de menú que abre la página del módulo en el Centro de control (name: addName del módulo)
function WoWTools_ToolsMixin:OpenMenu(root, name, showText)
    return WoWTools_MenuMixin:OpenOptions(root, {
        name=name or self.addName,
        name2=showText,
    })
end

--"Ajustes..." al final de un menú principal: abre la página del módulo M en el Centro de control
function WoWTools_ToolsMixin:SettingsMenu(root, M)
    root:CreateDivider()
    return WoWTools_MenuMixin:OpenOptions(root, {
        name= (M or self).addName,
        name2= WoWTools_L['Settings...'],
    })
end




--Piezas comunes del esquema de opciones (docs/SETTINGS.md) de las herramientas

--Valores del desplegable de capa (strata)
local StrataValues
function WoWTools_ToolsMixin:StrataValues()
    if not StrataValues then
        StrataValues= {}
        for index, strata in ipairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
            table.insert(StrataValues, {value=strata, text=strata..' ('..index..')'})
        end
    end
    return StrataValues
end

--Campo de texto para el atajo de teclado de un botón (save.KEY por defecto).
--tab: {field=campo de save (KEY), key=id de la opción, apply=function(M, save) end, tooltip=, disabled=, indent=}
function WoWTools_ToolsMixin:KeyOption(tab)
    local field= tab.field or 'KEY'
    return {type='input', key=tab.key or 'key', text=tab.text or 'SETTINGS_KEYBINDINGS_LABEL',
        tooltip= tab.tooltip or 'Tip.Tools.KeyInput', placeholder='BUTTON5', maxLetters=32,
        noCombat=true, disabled=tab.disabled, indent=tab.indent,
        get= function(save) return save[field] or '' end,
        set= function(save, text)
            text= (text or ''):gsub(' ', ''):gsub('%[', ''):gsub(']', ''):upper()
            save[field]= text~='' and text or nil
        end,
        apply= tab.apply,
    }
end

--Opciones de la barra para los botones de las herramientas (WoWTools_ToolsMixin:CreateButton):
--mostrar el botón (save.disabledADD, requiere /reload) y su fila (save.BottomPoint).
--skip: nombres que ya se activan desde la lista de submódulos (no se repite su casilla)
function WoWTools_ToolsMixin:ButtonOptions(skip)
    local list= {}
    for _, data in ipairs(AddList) do
        if not data.isPlayerSetupOptions and data.name then
            local name= data.name
            local function Label()
                return data.tooltip or name
            end
            local hasCheck= not (skip and skip[name])
            if hasCheck then
                table.insert(list, {type='check', key='add_'..name, text=Label, reload=true,
                    tooltip= data.isMoveButton and 'Tip.Tools.AddButton' or 'Tip.Tools.AddButtonPoint',
                    get= function(save) return not save.disabledADD[name] end,
                    set= function(save, value) save.disabledADD[name]= not value and true or nil end,
                })
            end
            if not data.isMoveButton then
                table.insert(list, {type='dropdown', key='row_'..name, indent=hasCheck, noCombat=true,
                    text= hasCheck and 'Toolbar row' or Label,
                    tooltip='Tip.Tools.Row',
                    values= {
                        {value=1, text='|A:bags-greenarrow:0:0|a'..WoWTools_L['Top row']},
                        {value=2, text='|A:Bags-padlock-authenticator:0:0|a'..WoWTools_L['Bottom row']},
                    },
                    disabled= function(save) return save.disabledADD[name] end,
                    get= function(save) return save.BottomPoint[name] and 2 or 1 end,
                    set= function(save, value) save.BottomPoint[name]= value==2 and true or nil end,
                    apply= function()
                        if MainButton then
                            WoWTools_ToolsMixin:RestAllPoint()
                        end
                    end,
                })
            end
        end
    end
    return list
end


function WoWTools_ToolsMixin:Set_AddList(option)
    table.insert(AddList, {isPlayerSetupOptions=true, option=option})
end
function WoWTools_ToolsMixin:Get_AddList()
    return AddList
end
function WoWTools_ToolsMixin:Clear_AddList()
    AddList={}
end
function WoWTools_ToolsMixin:Get_All_Buttons()
    return AllButtons, Name
end
function WoWTools_ToolsMixin:Get_MainButton()
    return MainButton
end
function WoWTools_ToolsMixin:Get_ButtonForName(name)
    return _G[Name..name]
end

--Ejecuta func una sola vez en el primer PLAYER_ENTERING_WORLD.
--Un marco por llamada (y no el despachador común de WoWTools_Module, que no garantiza orden)
--para que los botones se sigan creando en el mismo orden que antes
function WoWTools_ToolsMixin:OnEnterWorld(func)
    local frame= CreateFrame('Frame')
    frame:RegisterEvent('PLAYER_ENTERING_WORLD')
    frame:SetScript('OnEvent', function(f, event)
        f:UnregisterEvent(event)
        f:SetScript('OnEvent', nil)
        func()
    end)
end
