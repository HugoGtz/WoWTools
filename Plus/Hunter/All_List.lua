
if WoWTools_DataMixin.Player.Class~='HUNTER' then
    return
end


local AllListFrame
local MAX_SUMMONABLE_HUNTER_PETS = Constants.PetConsts_PostCata.MAX_SUMMONABLE_HUNTER_PETS or 5
local EXTRA_PET_STABLE_SLOT_LUA_INDEX = (Constants.PetConsts_PostCata.EXTRA_PET_STABLE_SLOT or 5) + 1;
local NUM_PET_SLOTS_HUNTER = Constants.PetConsts_PostCata.NUM_PET_SLOTS_HUNTER or 205


local function Save()
    return WoWToolsPlusSave['Plus_StableFrame']
end






local function sort_value(value)
    if type(value)=='number' or type(value)=='string' then
        return value
    end
    return 0
end

--compara números como números y textos por orden alfabético (UTF-8)
local function sort_compare(a, b)
    if type(a)==type(b) then
        if type(a)=='string' then
            if strcmputf8i then
                return strcmputf8i(a, b) < 0
            end
            return a:lower() < b:lower()
        end
        return a < b
    end
    return type(a)=='number'
end




local Is_In_Search
local function sort_pets_list(sortType)
    if Is_In_Search or InCombatLockdown() then
        return
    end

    local tab= {}
    for _, btn in pairs(AllListFrame.Buttons) do
        if btn.petData and btn.petData.slotID then
            local info = C_StableInfo.GetStablePetInfo(btn.petData.slotID)
            if info and info.slotID then
                table.insert(tab, {
                    slotID= info.slotID,
                    petNumber= info.petNumber,
                    value= sort_value(info[sortType=='creatureID' and 'CreatureID' or sortType]),
                })
            end
        end
    end
    if #tab==0 then
        return
    end

    table.sort(tab, function(a, b)
        if a.value==b.value then
            return a.slotID < b.slotID
        end
        return sort_compare(a.value, b.value)
    end)

    --posición actual de cada mascota; SetPetSlot intercambia las mascotas de los dos huecos
    local petBySlot, slotByPet= {}, {}
    for _, info in pairs(tab) do
        petBySlot[info.slotID]= info.petNumber
        slotByPet[info.petNumber]= info.slotID
    end

    local sortDown= Save().sortDown
    local index= 0
    Is_In_Search= true

    local function Step()
        if InCombatLockdown() or not StableFrame:IsShown() then
            Is_In_Search=nil
            return
        end
        while index < #tab do
            index= index+1
            local petNumber= tab[index].petNumber
            local target= sortDown and (NUM_PET_SLOTS_HUNTER - index + 1) or (index + MAX_SUMMONABLE_HUNTER_PETS)
            local from= slotByPet[petNumber]
            if from and from~=target then
                local other= petBySlot[target]
                C_StableInfo.SetPetSlot(from, target)
                petBySlot[target]= petNumber
                slotByPet[petNumber]= target
                petBySlot[from]= other
                if other then
                    slotByPet[other]= from
                end
                --un movimiento cada vez, para no saturar al servidor
                C_Timer.After(0.2, Step)
                return
            end
        end
        Is_In_Search=nil
    end
    Step()
end










local function set_button_size(btn)
    local n= Save().all_List_Size or 28
    AllListFrame.s= n
    btn:SetSize(n, n)
    btn.Icon:SetSize(n, n)
    local s= n*0.5
    btn.BackgroundMask:SetSize(s, s)
    local w= n+ ((85-72)/72)*n--0.287
    local h= n+ ((100-72)/72)*n--0.515
    btn.Highlight:SetSize(w, h)
end








local function created_button(index)
    local btn= CreateFrame('Button', nil, AllListFrame, 'StableActivePetButtonTemplate', index)
    btn:HookScript('OnEnter', function(self)
        if self.petData then
            WoWTools_HunterMixin:Set_Tooltips(self, self.petData)
            GameTooltip:Show()
        end
    end)

    btn.Border:SetTexture(nil)
    btn.Border:ClearAllPoints()
    btn.Border:Hide()
    btn.Text= WoWTools_LabelMixin:Create(btn,{size=10, color={r=1,g=1,b=1,a=0.2}, layer='BACKGROUND'})
    btn.Text:SetPoint('CENTER', btn.Background)
    btn.Text:SetText(index)
    btn.Icon:SetDrawLayer('BORDER')
    WoWTools_DataMixin:Hook(btn, 'SetPet', function(self)
        self.Icon:SetTexCoord(0, 1, 0, 1);
    end)
    return btn
end










--初始，宠物列表
local function Init()
    if not Save().show_All_List then
        return
    end

    AllListFrame= CreateFrame('Frame', 'WoWTools_StableFrameAllList', StableFrame)
    AllListFrame:SetPoint('TOPLEFT', StableFrame, 'TOPRIGHT', StableFrame.Topper:IsShown() and 0 or 12,0)
    AllListFrame:SetSize(1,1)
    AllListFrame:Hide()


    AllListFrame.Buttons={}
    AllListFrame.s= Save().all_List_Size or 28
    WoWTools_TextureMixin:CreateBG(AllListFrame, {alpha=0.5, isColor=true})

    for i= EXTRA_PET_STABLE_SLOT_LUA_INDEX, NUM_PET_SLOTS_HUNTER do
        local btn= created_button(i)
        AllListFrame.Buttons[i]= btn
    end

    function AllListFrame:set_point()
        if not self:IsShown() then return end

        local x, y = 0, 0
        local btnY
        local s= StableFrame:GetHeight()
        for _, btn in pairs(self.Buttons) do
            btn:ClearAllPoints()
            btn:SetPoint('TOPLEFT', x, y)
            y= y-self.s
            if -y> s then
                btnY=btn
                y=0
                x=x+ self.s
            end
        end
        AllListFrame.Background:ClearAllPoints()
        AllListFrame.Background:SetPoint('TOPLEFT', AllListFrame.Buttons[EXTRA_PET_STABLE_SLOT_LUA_INDEX])
        AllListFrame.Background:SetPoint('BOTTOM', btnY)
        AllListFrame.Background:SetPoint('RIGHT', AllListFrame.Buttons[NUM_PET_SLOTS_HUNTER])
    end



    function AllListFrame:Refresh()
        local show= self:IsShown()
        for _, btn in pairs(AllListFrame.Buttons) do
            btn:SetPet(show and C_StableInfo.GetStablePetInfo(btn:GetID()) or nil)
        end
        self.btn6:settings()
    end

    WoWTools_DataMixin:Hook(StableFrame, 'Refresh', function()
        if AllListFrame:IsShown() then
            AllListFrame:Refresh()
        end
    end)
    AllListFrame:SetScript('OnHide', AllListFrame.Refresh)
    AllListFrame:SetScript('OnShow', function(self)
        self:Refresh()
        self:set_point()
    end)

    StableFrame:HookScript('OnSizeChanged', function()
        if AllListFrame:IsShown() then
            AllListFrame:Refresh()
        end
    end)


    StableFrame:HookScript('OnSizeChanged', function()
        AllListFrame:set_point()
    end)


    --第6个，提示，如果，没有专精支持，它会禁用，所有，建立一个
    AllListFrame.btn6= created_button(MAX_SUMMONABLE_HUNTER_PETS)
    AllListFrame.btn6:SetPoint('BOTTOM', AllListFrame.Buttons[EXTRA_PET_STABLE_SLOT_LUA_INDEX],'TOP')
    function AllListFrame.btn6:settings()
        local show= self:GetParent():IsShown() and not StableFrame.ActivePetList.BeastMasterSecondaryPetButton:IsEnabled()
        self:SetPet(show and C_StableInfo.GetStablePetInfo(self:GetID()) or nil)
        self:SetShown(show)
    end


    function AllListFrame:Settings()
        self:SetShown(Save().show_All_List)
        self.s= Save().all_List_Size
        for _, btn2 in pairs(self.Buttons) do
            set_button_size(btn2)
        end
        self:set_point()
    end

    AllListFrame:Settings()

    Init=function()
        AllListFrame:Settings()
    end
end












function WoWTools_HunterMixin:Set_StableFrame_List()
    Init()
end

function WoWTools_HunterMixin:sort_pets_list(type)
    sort_pets_list(type)
end