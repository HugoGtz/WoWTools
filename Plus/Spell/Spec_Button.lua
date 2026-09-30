local function Save()
    return WoWToolsPlusSave['Plus_Spell'].specButton
end


local SpecFrame


local function Init_Spec_Menu(self, root)
    local sub, sub2
    root:CreateTitle(self.name)


--专精
    root:CreateDivider()

    WoWTools_MenuMixin:Set_Specialization(root)
    root:CreateDivider()

--打开选项界面
    sub=WoWTools_MenuMixin:OpenOptions(root, {
        name=WoWTools_SpellMixin.addName,
        category=WoWTools_SpellMixin.Category
    })


--SetParent
    sub2=sub:CreateCheckbox(
        (PlayerSpellsFrame and '' or '|cff828282')
        ..'UIParent',--..(WoWTools_L.PLAYERSPELLS_BUTTON),
    function()
        return Save().isUIParent
    end, function()
        Save().isUIParent= not Save().isUIParent and true or nil
        SpecFrame:Settings()
        SpecFrame:set_point()
        --return MenuResponse.Close
    end)
    sub2:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.Spell.SpecUIParent'])
        local isUIParent= Save().isUIParent
        tooltip:AddLine('SetParent')
        tooltip:AddDoubleLine(' ',  (isUIParent and '|cnGREEN_FONT_COLOR:' or '').. 'UIParent')
        tooltip:AddDoubleLine(' ', (isUIParent and '' or '|cnGREEN_FONT_COLOR:').. 'PlayerSpellsFrame')

        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
    end)



--向上
        WoWTools_MenuMixin:ToTop(self, sub2, {GetValue=function()
            return Save().isToTOP
        end, SetValue=function ()
            Save().isToTOP= not Save().isToTOP and true or nil
            SpecFrame:Settings()

        end})



--自动隐藏


--FrameStrata
        WoWTools_MenuMixin:FrameStrata(self, sub2, function(data)
            return SpecFrame:GetFrameStrata()==data
        end, function(data)
            Save().strata= data
            SpecFrame:set_strata()
        end)

--    sub:CreateDivider()
--缩放
    WoWTools_MenuMixin:Scale(self, sub2, function()
        return Save().scale or 1
    end, function(value)
        Save().scale= value
        SpecFrame:Settings()
    end)

    sub:CreateDivider()
--重新加载UI
    WoWTools_MenuMixin:Reload(sub)
end


local function Create_Spec_Button(index)
    local specID, name, _, texture= C_SpecializationInfo.GetSpecializationInfo(index, false, false, nil, WoWTools_DataMixin.Player.Sex)
    if not specID or specID==-1 then
        return
    end

    SpecFrame.Buttons[index]= CreateFrame('Button', 'WoWToolsPlayerSpellsFrameSpecButton'..index, SpecFrame, 'WoWToolsButtonTemplate', index)


    local btn= SpecFrame.Buttons[index]

    btn:SetSize(32,32)
    btn:SetNormalTexture(texture or 0)
    WoWTools_ButtonMixin:AddMask(btn, false)
    --btn:SetClampedToScreen(true)
    --table.insert(SpecFrame.Buttons, btn)


    btn.specIndex= index
    btn.specID= specID
    btn.icon='|T'..(texture or 0)..':0|t'
    btn.name= WoWTools_TextMixin:CN(name)

    btn.LootIcon= btn:CreateTexture(nil, 'OVERLAY', nil, 7)
    btn.LootIcon:SetSize(14,14)
    btn.LootIcon:SetPoint('TOPLEFT', -2, 2)
    btn.LootIcon:SetAtlas('VignetteLoot')

    btn.RoleIcon= btn:CreateTexture(nil, 'OVERLAY')
    btn.RoleIcon:SetSize(16,16)
    btn.RoleIcon:SetPoint('BOTTOMRIGHT', 2, -1.2)
    btn.RoleIcon:SetAtlas(GetMicroIconForRoleEnum(GetSpecializationRoleEnum(index, false, false)), TextureKitConstants.IgnoreAtlasSize)

    btn.SelectIcon= btn:CreateTexture(nil, 'OVERLAY')
    btn.SelectIcon:SetAllPoints()
    btn.SelectIcon:SetAtlas('ChromieTime-Button-Selection')
    btn.SelectIcon:SetVertexColor(0,1,0)

    function btn:Set_Active()
        if self.isActive then
            WoWTools_LoadUIMixin:SpellBook(2)
        else
            C_SpecializationInfo.SetSpecialization(self.specIndex)
            return true
        end
    end


    btn:RegisterForDrag("RightButton")
    btn:SetScript('OnDragStart', function(_, d)
        if d=='RightButton' and IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(SpecFrame) and SpecFrame:IsMovable() then
            SpecFrame:StartMoving()
        end
    end)
    btn:SetScript("OnDragStop", function()
        local self= SpecFrame

        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().point= {self:GetPoint(1)}
            Save().point[2]= nil
        end
    end)


    btn:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            --botones sueltos en pantalla: Shift+clic para cambiar de especialización (evita clics accidentales)
            if self.isActive or not Save().isUIParent or IsShiftKeyDown() then
                self:Set_Active()
            end
        elseif d=='RightButton' and SpecFrame:IsMovable() and IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(SpecFrame) then
            SetCursor('UI_MOVE_CURSOR')
        else
            MenuUtil.CreateContextMenu(self, Init_Spec_Menu)
        end
    end)


    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        ResetCursor()
        self:set_alpha()
    end)
    btn:SetScript('OnEnter', function(self)
        WoWTools_SetTooltipMixin:Frame(self, GameTooltip, {
            specIndex= self.specIndex,
            tooltip= function(tooltip)
                tooltip:AddLine(' ')
                tooltip:AddDoubleLine(
                    (self.isActive and '|cnGREEN_FONT_COLOR:'
                        or (InCombatLockdown() and '|cff828282')
                        or '|cffffffff'
                    )
                    ..(self.isActive and (WoWTools_L.COVENANT_SANCTUM_UPGRADE_ACTIVE)
                    or (WoWTools_L.SPEC_ACTIVE))
                    ..((not self.isActive and Save().isUIParent) and ' Shift+' or '')
                    ..WoWTools_DataMixin.Icon.left,

                    WoWTools_DataMixin.Icon.right..(WoWTools_L.HUD_EDIT_MODE_MICRO_MENU_LABEL)
                )
                if SpecFrame:IsMovable() then
                    tooltip:AddDoubleLine(' ', 'Alt+'..WoWTools_DataMixin.Icon.right..(WoWTools_L.NPE_MOVE))
                end
            end
        })
        self:set_alpha()
    end)


    function btn:set_alpha()
        self:SetAlpha(
            (self:IsMouseOver() or self.isActive) and 1
            or 0.5
        )
    end

    function btn:set_shown(isInCombat)
        --en PLAYER_REGEN_DISABLED InCombatLockdown() aún es false: usar el parámetro si viene
        if isInCombat==nil then
            isInCombat= InCombatLockdown()
        end
        self:SetShown(
            not Save().isUIParent
            or self.isActive
            or not isInCombat
        )
    end
    function btn:settings()
        local spec= GetSpecialization(nil, false, 1)
        local lootID= GetLootSpecialization()
        local isActive= spec==self.specIndex
        local isLoot= lootID==0 and isActive or self.specID==lootID

        self.isActive= isActive
        self.isLoot= isLoot
        self.lootID= lootID

        self.SelectIcon:SetShown(isActive)

        if isLoot then
            if lootID==0 then
                self.LootIcon:SetVertexColor(0,1,0)
            else
                self.LootIcon:SetVertexColor(1,1,1)
            end
        end
        self.LootIcon:SetShown(isLoot)
        self:set_alpha()
        self:set_shown()
    end

    if Save().isUIParent then
        btn:RegisterEvent('PLAYER_REGEN_ENABLED')
        btn:RegisterEvent('PLAYER_REGEN_DISABLED')
    end
    btn:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
    btn:RegisterEvent('ACTIVE_PLAYER_SPECIALIZATION_CHANGED')

    btn:SetScript('OnEvent',  function(self, event)
        if event=='PLAYER_REGEN_ENABLED'
            or event=='PLAYER_REGEN_DISABLED'
        then
            self:set_shown(event=='PLAYER_REGEN_DISABLED')
        else
            self:settings()
        end
    end)

    btn:settings()
end


--天赋，添加专精按钮
local function Init()
    if not Save().enabled then
        return
    end

    local numSpec= GetNumSpecializations(false, false) or 0
    if numSpec==0 or (not Save().isUIParent and not PlayerSpellsFrame) then--not C_SpecializationInfo.IsInitialized() or
        return
    end

    SpecFrame= CreateFrame('Frame', 'WoWToolsOtherSpecFrame', Save().isUIParent and UIParent or PlayerSpellsFrame)
    SpecFrame:SetSize(10,10)

    SpecFrame.numSpec= numSpec
    SpecFrame.Buttons={}

    for index=1, numSpec do
        Create_Spec_Button(index)
    end

    function SpecFrame:set_shown()
        self:SetShown(
            not C_PetBattles.IsInBattle()
			and not UnitInVehicle('player')
            and not OverrideActionBar:IsShown()
        )
    end

    function SpecFrame:set_event()
        self:UnregisterAllEvents()
        if Save().isUIParent then--Save().hideInCombat and
            self:RegisterEvent('PET_BATTLE_OPENING_DONE')
			self:RegisterEvent('PET_BATTLE_CLOSE')

            self:RegisterEvent("VEHICLE_ANGLE_UPDATE")
            self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
            self:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
            self:RegisterUnitEvent("UNIT_ENTERING_VEHICLE", "player")
            self:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")

			self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:set_shown()
        else
            self:SetShown(true)
        end
    end
    function SpecFrame:Settings()
        local isToTOP= Save().isToTOP
        local isUIParent= Save().isUIParent
        for index, btn in pairs(self.Buttons) do
            btn:ClearAllPoints()
            if isToTOP and isUIParent then
                btn:SetPoint('BOTTOMLEFT', self.Buttons[index-1] or self, 'TOPLEFT', 0, 1)
            else
                btn:SetPoint('TOPLEFT', self.Buttons[index-1] or self, 'TOPRIGHT', 1, 0)
            end
            btn:SetClampedToScreen(isUIParent and true or false)
        end
        self:SetMovable(isUIParent and true or false)
        self:SetScale(Save().scale or 1)
        self:set_event()
    end



    function SpecFrame:set_strata()
        self:SetFrameStrata(Save().strata or 'MEDIUM')
    end

    function SpecFrame:set_point()
        self:ClearAllPoints()

        if Save().isUIParent then
            local p= Save().point
            self:SetParent(UIParent)
            if p and p[1] then
                self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
            else
                self:SetPoint('CENTER', UIParent, -150, 150)
            end
            self:set_strata()

        elseif PlayerSpellsFrame then
            self:SetParent(PlayerSpellsFrame.TalentsFrame)
            self:SetPoint('TOP', PlayerSpellsFrame.TalentsFrame.ApplyButton, 'BOTTOM', -self.numSpec*10-18, 0)

        else
            print(
                WoWTools_SpellMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnGREEN_FONT_COLOR:'
                ..(WoWTools_L.REQUIRES_RELOAD)
            )
        end
    end

    SpecFrame:SetScript('OnEvent', SpecFrame.set_shown)

    SpecFrame:Settings()
    SpecFrame:set_point()


    Init=function()end
end


function WoWTools_SpellMixin:Init_Spec_Button()
    Init()
end