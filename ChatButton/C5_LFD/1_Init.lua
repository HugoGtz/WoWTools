


local function Check_Holiday(dungeonIndex)
    local dungeonID, name = GetLFGRandomDungeonInfo(dungeonIndex)
    if not dungeonID or not name then
        return
    end

    local isAvailableForAll, isAvailableForPlayer = IsLFGDungeonJoinable(dungeonID)
    if not isAvailableForAll or not isAvailableForPlayer then
        return
    end

    local isHoliday, _, _, isTimeWalker = select(14, GetLFGDungeonInfo(dungeonID))
    if not isHoliday and not isTimeWalker then
        return
    end

    local numRewards = select(6, GetLFGDungeonRewards(dungeonID)) or 0
    if numRewards==0 then
        return
    end

    local texturePath
    for rewardIndex=1 , numRewards do
        local _, texture, _, isBonusReward, rewardType= GetLFGDungeonRewardInfo(dungeonID, rewardIndex)
        if texture then
            if rewardType == "currency"
                or rewardType=='item'
                or (isBonusReward and not texturePath)
            then
                texturePath= texture
                break
            end
        end
    end

    if texturePath then
        return dungeonID, name, texturePath
    end
end


local function Set_Holiday()
    local dungeonID, name, texture, atlas
    local group= IsInGroup()

    if group and UnitIsGroupLeader('player') or not group then
        for dungeonIndex=1, GetNumRandomDungeons() do
            dungeonID, name, texture= Check_Holiday(dungeonIndex)
            if dungeonID then
                break
            end
        end
    end

    local categoryType= dungeonID and LE_LFG_CATEGORY_LFD or nil

    WoWTools_LFDMixin:Set_LFDButton_Data(dungeonID, categoryType, WoWTools_TextMixin:CN(name), texture,  atlas)
end


local function Init(btn)
    if not btn then
        return
    end

    btn.IconMask:SetPoint("TOPLEFT", btn, "TOPLEFT", 5, -5)
    btn.IconMask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -7, 7)

    btn.leaveInstance=btn:CreateTexture(nil, 'ARTWORK', nil, 1)
    btn.leaveInstance:SetPoint('BOTTOMLEFT',4, 0)
    btn.leaveInstance:SetSize(12,12)
    btn.leaveInstance:SetAtlas('common-icon-rotateleft')
    btn.leaveInstance:Hide()


    function btn:set_tooltip()
        self:set_owner()
        WoWTools_ChallengeMixin:ActivitiesTooltip()

        if self.name and (self.dungeonID or self.RaidID) then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(self.name..WoWTools_DataMixin.Icon.left)
        end
        GameTooltip:Show()
    end

    function btn:set_OnMouseDown()
        if self.dungeonID then
            --WoWTools_Print(self.dungeonID, self.type)
            if self.type==LE_LFG_CATEGORY_LFD then--1
                WoWTools_DataMixin:Call('LFDQueueFrame_SetType', self.dungeonID)
                WoWTools_DataMixin:Call('LFDQueueFrame_Join')
            elseif self.type==LE_LFG_CATEGORY_RF then--3
                WoWTools_DataMixin:Call('RaidFinderQueueFrame_SetRaid', self.dungeonID)
                WoWTools_DataMixin:Call('RaidFinderQueueFrame_Join')
            elseif self.type==LE_LFG_CATEGORY_SCENARIO then--4

            end
            self:CloseMenu()
            self:set_tooltip()
        else
            return true
        end
    end


    WoWTools_LFDMixin:Init_Menu(btn)
    WoWTools_LFDMixin:Init_Queue_Status()
    WoWTools_LFDMixin:Init_Loot_Plus()
    WoWTools_LFDMixin:Init_Roll_Plus()
    WoWTools_LFDMixin:Init_RolePollPopup()
    WoWTools_LFDMixin:Init_Exit_Instance()
    WoWTools_LFDMixin:Init_Role_CheckInfo()
    WoWTools_LFDMixin:Init_RepopMe()

     EventRegistry:RegisterFrameEventAndCallback("LFG_UPDATE_RANDOM_INFO", Set_Holiday)
    C_Timer.After(2, Set_Holiday)
    Init=function()end
end


local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')

panel:SetScript('OnEvent', function(self, event, arg1)
    if arg1~= 'WoWToolsPlus' then
        return
    end

    WoWToolsPlusSave['ChatButton_LFD']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['ChatButton_LFD'], {
        ReMe=true,
        autoSetRole=true,
        tipsScale=1,
        sec=3,
        wow={
            --['island']=0,
        },
    })

    if not WoWToolsPlusSave['ChatButton_LFD'].sec then
        WoWToolsPlusSave['ChatButton_LFD'].sec= 5
    end


    WoWTools_LFDMixin.addName= '|A:groupfinder-eye-frame:0:0|a'..(WoWTools_L['Module.Group Finder'])

    --WoWTools_ChatMixin:GetButtonForName('LFD')
    Init(
        WoWTools_ChatMixin:CreateButton('LFD', WoWTools_LFDMixin.addName)
    )

    self:UnregisterEvent(event)
    self:SetScript('OnEvent', nil)
end)