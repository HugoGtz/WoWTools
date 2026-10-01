


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


local Init_Once= WoWTools_Once(function(btn)

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
end)

--La comprobación queda fuera del "una sola vez" (sin botón no se marca como hecho)
local function Init(btn)
    if not btn then
        return
    end
    Init_Once(btn)
end


--Marco de información de colas (Queue_Status.lua)
local function Refresh_QueueFrame()
    local btn= _G['WoWToolsChatToolsLFDTooltipButton']
    if btn and btn.settings then
        btn:settings()
    end
end

local function Seconds(value)
    return format('%d %s', value, WoWTools_L.LOSS_OF_CONTROL_SECONDS)
end

local function Strata_Values()
    local list= {}
    for _, strata in ipairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
        table.insert(list, {value=strata, text=strata})
    end
    return list
end

local function Hide_Queue(save)
    return save.hideQueueStatus
end

--Solo en vivo si el módulo ya arrancó y tiene su botón (si no, se aplicará al arrancar)
local function Live(func)
    return function(M, ...)
        if M.started and WoWTools_ChatMixin:GetButtonForName('LFD') then
            func(M, ...)
        end
    end
end

local Options= {
    {type='section', text='GENERAL'},
    {type='check', key='queueInfo', text='SOCIAL_QUEUE_TOOLTIP_HEADER+INFO', tooltip='Tip.LFD.QueueInfo',
        get= function(save) return not save.hideQueueStatus end,
        set= function(save, value) save.hideQueueStatus= not value and true or nil end,
        apply= Live(function(M) M:Set_Queue_Status() end),
    },
    {type='check', key='hideLocked', text='Hide locked instances', tooltip='Tip.LFD.HideLocked',
        get= function(save) return save.hideDontEnterMenu end,
        set= function(save, value) save.hideDontEnterMenu= value and true or nil end,
    },
    {type='check', key='lootPlus', text='Loot Plus', tooltip='Tip.LFD.LootPlus',
        get= function(save) return not save.disabledLootPlus end,
        set= function(save, value) save.disabledLootPlus= not value and true or nil end,
    },

    {type='section', text='Automations'},
    {type='check', key='roleCheck', text='Auto-accept role checks', tooltip='Tip.LFD.RoleCheck', automation=true, reload=true,
        get= function(save) return save.autoSetPvPRole end,
        set= function(save, value) save.autoSetPvPRole= value and true or nil end,
        apply= Live(function(M) M:Init_RolePollPopup() end),
    },
    {type='check', key='autoRole', text='Set roles from specialization', tooltip='Tip.LFD.AutoRole', automation=true, indent=true,
        disabled= function(save) return not save.autoSetPvPRole end,
        get= function(save) return save.autoSetRole end,
        set= function(save, value) save.autoSetRole= value and true or false end,
        apply= Live(function(M) M:Init_RolePollPopup() end),
    },
    {type='slider', key='sec', text='Auto confirm', tooltip='Tip.LFD.AutoConfirmSec', automation=true,
        min=1, max=20, step=1, format=Seconds,
        get= function(save) return save.sec or 5 end,
        set= function(save, value) save.sec= math.floor(value+0.5) end,
    },
    {type='check', key='leaveInstance', text='LEAVE+INSTANCE', tooltip='Tip.LFD.LeaveInstance', automation=true,
        get= function(save) return save.leaveInstance end,
        set= function(save, value) save.leaveInstance= value and true or nil end,
        apply= Live(function(M) M:Init_Exit_Instance() end),
    },
    {type='check', key='reMe', text='Release, Resurrect', tooltip='Tip.LFD.ReleaseRes', automation=true,
        get= function(save) return save.ReMe end,
        set= function(save, value) save.ReMe= value and true or false end,
        apply= Live(function(M) M:Init_RepopMe() end),
    },
    {type='check', key='reMeAll', text='Also outside battlegrounds', tooltip='Tip.LFD.ReleaseResAll', automation=true, indent=true,
        disabled= function(save) return not save.ReMe end,
        get= function(save) return save.ReMe_AllZone end,
        set= function(save, value) save.ReMe_AllZone= value and true or false end,
        apply= Live(function(M) M:Init_RepopMe() end),
    },
    {type='check', key='autoRoll', text='Roll on loot automatically', tooltip='Tip.LFD.AutoRoll', automation=true,
        get= function(save) return save.autoROLL end,
        set= function(save, value) save.autoROLL= value and true or nil end,
    },
    {type='check', key='confirmBoP', text='Confirm Bind on Pickup rolls', tooltip='Tip.LFD.ConfirmBoP', automation=true,
        get= function(save) return save.autoConfirmLootRoll end,
        set= function(save, value) save.autoConfirmLootRoll= value and true or nil end,
    },

    {type='section', text='Appearance'},
    {type='slider', key='tipsScale', text='SCALE', tooltip='Tip.Menu.Scale', min=0.4, max=4, step=0.1, format='%.1f',
        disabled= Hide_Queue,
        get= function(save) return save.tipsScale or 1 end,
        set= function(save, value) save.tipsScale= value end,
        apply= Refresh_QueueFrame,
    },
    {type='slider', key='tipsAlpha', text='BACKGROUND+HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY', tooltip='Tip.Menu.BgAlpha',
        min=0, max=1, step=0.1, format='%.1f',
        disabled= Hide_Queue,
        get= function(save) return save.tipsAlpha or 0.5 end,
        set= function(save, value) save.tipsAlpha= value end,
        apply= Refresh_QueueFrame,
    },
    {type='dropdown', key='strata', text='Strata', tooltip='Tip.Menu.Strata',
        values= Strata_Values,
        disabled= Hide_Queue,
        get= function(save) return save.queueStatusStrata or 'MEDIUM' end,
        set= function(save, value) save.queueStatusStrata= value end,
        apply= Refresh_QueueFrame,
    },
    {type='button', key='resetPoint', text='RESET_POSITION', buttonText='RESET',
        disabled= function(save) return not save.tipsFramePoint end,
        func= function(_, save)
            save.tipsFramePoint= nil
            Refresh_QueueFrame()
        end,
    },

    {type='section', text='Advanced'},
    {type='button', key='clearComplete', text='INSTANCE+COMPLETE', buttonText='CLEAR_ALL', tooltip='Tip.LFD.ClearComplete',
        confirm='CLEAR_ALL',
        disabled= function(save) return not next(save.wow or {}) end,
        func= function(_, save)
            save.wow= {}
        end,
    },
}




WoWTools_Module:Register({
    key= 'ChatButton_LFD', name= 'Module.Group Finder', icon= 'groupfinder-eye-frame',
    parent= 'ChatButton', mixin= WoWTools_LFDMixin,
    options= Options,
    defaults= {
        ReMe=true,
        autoSetRole=true,
        tipsScale=1,
        sec=3,
        wow={
            --['island']=0,
        },
    },
    onEnable= function(_, save)
        if not save.sec then
            save.sec= 5
        end

        --WoWTools_ChatMixin:GetButtonForName('LFD')
        Init(
            WoWTools_ChatMixin:CreateButton('LFD', WoWTools_LFDMixin.addName)
        )
    end,
})
