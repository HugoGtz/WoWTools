


WoWTools_ToolsMixin={

    --Save={disabledADD={}, lineNum=10, isHideBackground=nil},   
    addName='|A:Professions-Crafting-Orders-Icon:0:0|a'..WoWTools_L['Module.Tools'],
}

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
local function Save()
    return WoWToolsPlusSave['WoWTools_ToolsButton']
end


local function Set_BG(frame)
    --if frame and frame.Background then
        frame.Background:SetColorTexture(0, 0, 0, Save().bgAlpha or 0)
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

    elseif Save().BottomPoint[tab.name]
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
        if Save().BottomPoint[name] or tab.isMoveButton then
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
                local numLine= Save().lineNum or 10
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
    if not MainButton or Save().disabledADD[name] then
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
        self.border:SetAlpha(Save().borderAlpha or 0.3)
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
    if Save().disabled then
        return
    end

    MainButton= CreateFrame('Button', 'WoWToolsMainToolsButton', UIParent, 'WoWToolsButtonTemplate')

    MainButton.Frame= CreateFrame('Frame', nil, MainButton)
    MainButton.Frame:SetAllPoints()
    MainButton.Frame:SetShown(Save().show)
    MainButton.IsShownFrameEnterButton=true




    local bgSet= {isAllPoint=true, isColor=true, alpha= Save().bgAlpha}
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
    if btn.IsShownFrameEnterButton and Save().isEnterShow and not MainButton.Frame:IsShown() then
        MainButton:set_shown()
    end
end




function WoWTools_ToolsMixin:OpenMenu(root, name, showText)
    return WoWTools_MenuMixin:OpenOptions(root, {
        name=name or self.addName,
        name2=showText,
        category= self.Category
    })
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
