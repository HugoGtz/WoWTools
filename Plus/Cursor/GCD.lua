local function Save()
    return WoWToolsPlusSave['Plus_Cursor']
end

local GCDFrame


local function set_GCD_Texture()
    local index= Save().randomTexture and random(1, #Save().GCDTexture) or Save().gcdTextureIndex
    GCDFrame.cooldown:SetSwipeTexture(Save().GCDTexture[index] or WoWTools_CursorMixin.DefaultGCDTexture)
end


local gcdSize, gcdX, gcdY
local function Set_Point()
    local x, y = GetCursorPosition()
    GCDFrame:SetPoint("BOTTOMLEFT", x-gcdSize+gcdX,  y-gcdSize+gcdY)
end















local function GCD_Settings(isTest)
    if Save().disabledGCD then
        if GCDFrame then
            GCDFrame:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
            GCDFrame:SetShown(false)
        end
        return
    end

    gcdSize, gcdX, gcdY= Save().gcdSize, Save().gcdX, Save().gcdY

    GCDFrame:SetSize(gcdSize*2, gcdSize*2)

    set_GCD_Texture()

    GCDFrame.cooldown:SetSwipeColor(WoWTools_CursorMixin.Color:GetRGBA())

    if Save().randomTexture then
        GCDFrame:SetScript('OnHide', function()
            set_GCD_Texture()
        end)
    else
        GCDFrame:SetScript('OnHide', nil)
    end

    GCDFrame:RegisterEvent('SPELL_UPDATE_COOLDOWN')
    GCDFrame:SetAlpha(Save().gcdAlpha)

    GCDFrame.cooldown:SetReverse(Save().gcdReverse)
    GCDFrame.cooldown:SetDrawBling(Save().gcdDrawBling)

    if isTest then
        GCDFrame:SetShown(false)
        GCDFrame.cooldown:Clear()
        GCDFrame.cooldown:SetCooldown(GetTime(), 1.171)
        GCDFrame:SetShown(true)
    end
end












local function Init()
    if Save().disabledGCD then
        return
    end

    GCDFrame= CreateFrame('Frame', 'WoWToolsGCDFrame')
    GCDFrame:SetFrameStrata("TOOLTIP")

    GCDFrame.cooldown= CreateFrame("Cooldown", nil, GCDFrame, 'CooldownFrameTemplate')
    GCDFrame.cooldown:SetHideCountdownNumbers(true)
    GCDFrame.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
    GCDFrame.cooldown:SetDrawEdge(true)
    GCDFrame.cooldown:SetUseCircularEdge(true)
    GCDFrame:Hide()

    GCDFrame:SetScript('OnEvent', function(self)
        local data= C_Spell.GetSpellCooldown(61304)

        if not data or not canaccesstable(data) or not canaccessvalue(data.startTime) or not canaccessvalue(data.duration) then--valores secretos en combate (12.0)
            self:SetShown(false)
            return
        end

        if data.isEnabled and data.startTime and data.startTime > 0 and data.duration and data.duration > 0 then
            self.cooldown:SetCooldown(data.startTime, data.duration, data.modRate)
            self:SetShown(true)
        else
            self:SetShown(false)
        end
    end)

    GCDFrame:SetScript('OnShow', function()
        Set_Point()
    end)

    GCDFrame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed = (self.elapsed or 0.01) + elapsed
        if self.elapsed>0.01 then
            self.elapsed=0
            Set_Point()
        end
    end)

    GCD_Settings()

    Init=function(isTest2)
        GCD_Settings(isTest2)
    end
end













function WoWTools_CursorMixin:GCD_Settings(isTest)
    Init(isTest)
end
