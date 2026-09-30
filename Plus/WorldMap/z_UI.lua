

--WorldMapFrame:IsSidePanelShown()
--WoWTools_DataMixin:Hook(WorldMapFrame.SidePanelToggle, 'Refresh', Save_Size)
function WoWTools_MoveMixin.Events:Blizzard_WorldMap()


    local name= WorldMapFrame:GetName()

    local minimizedWidth= WorldMapFrame.minimizedWidth or 702
    local minimizedHeight= WorldMapFrame.minimizedHeight or 534
    local questLogWidth= WorldMapFrame.questLogWidth or 333


    local function Settings(size)
        if not WorldMapFrame:CanChangeAttribute()
            or not WorldMapFrame:IsShown()
            or not self:GetSize(name)
        then
            return
        end
        local isMax= WorldMapFrame:IsMaximized()
        if isMax then
            WorldMapFrame.minimizedWidth= minimizedWidth
            WorldMapFrame.minimizedHeight= minimizedHeight
            if self:Save().size[name] then
                WorldMapFrame:UpdateMaximizedSize()
            end
            WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:Maximize()

        elseif size and size[1] then
            local w= size[1] - (self:Save().WorldFrameIsSidePanelShown and questLogWidth or 0)-- +2
            WorldMapFrame.minimizedWidth= w
            WorldMapFrame.minimizedHeight= size[2] or minimizedHeight
            WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:Minimize()
        end
    end

    local function Set_Size(frame)
         if not WorldMapFrame:CanChangeAttribute() or not WorldMapFrame:IsShown() then
            return
        end
        local s= self:Save().size[name]
        local w= s and s[1]
        local h= s and s[2]
        if w and h then
            local isSidePanelShown= WorldMapFrame:IsSidePanelShown()
            local WorldFrameIsSidePanelShown= self:Save().WorldFrameIsSidePanelShown

            if WorldFrameIsSidePanelShown and not isSidePanelShown then
                frame:SetSize(w - questLogWidth, h)

            elseif not WorldFrameIsSidePanelShown or isSidePanelShown then
                frame:SetSize(w + questLogWidth, h)

            else
                frame:SetSize(w, h)
            end
            Settings(s)
        end
    end



    local OwnerID
    WoWTools_DataMixin:Hook(WorldMapFrame, 'Minimize', function(frame)
        if not frame:IsShown() then
            return
        elseif self:GetSize(name) then
            if frame:CanChangeAttribute() then
                Set_Size(frame)
            elseif not OwnerID then
                OwnerID=EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
                    Set_Size(frame)
                    OwnerID= nil
                    EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
                end)
            end
        end

        local scale= self:Save().scale[name]
        if scale then
            frame:SetScale(scale)
        end
        frame.ResizeButton:SetShown(true)
    end)

    WoWTools_DataMixin:Hook(WorldMapFrame, 'Maximize', function(frame)
        if not WorldMapFrame:IsShown() then
            return
        end
        Settings()
        if self:Save().scale[name] then
            frame:SetScale(1)
        end
        frame.ResizeButton:SetShown(false)
    end)

    self:Setup(WorldMapFrame, {
        minW=questLogWidth,--*2+37,
        minH=questLogWidth-37-8,
    sizeTooltip=function(tooltip)
        if self:GetSize(name) then
            GameTooltip_AddErrorLine(tooltip,
                WoWTools_L['Showing the map in combat causes an error']
            )
            GameTooltip:AddLine(WoWTools_L.REQUIRES_RELOAD)
        end
    end,
    sizeUpdateFunc= function(frame)--WorldMapMixin:UpdateMaximizedSize()
        Settings({frame:GetSize()})
    end,
    sizeStopFunc=function(frame)
         if not frame:IsMaximized() then
            self:Save().size[name]= {frame:GetSize()}
            self:Save().WorldFrameIsSidePanelShown= frame:IsSidePanelShown()
        end
    end,
    sizeRestFunc= function(frame)
        frame.minimizedWidth= minimizedWidth
        frame.minimizedHeight= minimizedHeight
        frame:SetSize(minimizedWidth+ questLogWidth, minimizedHeight)
        frame.BorderFrame.MaximizeMinimizeFrame:Minimize()
    end,
    --addMenu=addMenu
    })



   QuestMapDetailsScrollFrame:SetPoint('BOTTOM', 0, 72)

    QuestMapFrame.DetailsFrame:SetPoint('BOTTOM')
    QuestMapDetailsScrollFrame.Contents:SetPoint('BOTTOMLEFT')

    QuestMapFrame.DetailsFrame.Bg:SetPoint('BOTTOM', 0, 23)
    QuestMapFrame.DetailsFrame.SealMaterialBG:SetPoint('BOTTOM', 0, 23)

    WorldMapFrame.ScrollContainer.Child.TiledBackground:ClearAllPoints()
    WorldMapFrame.ScrollContainer.Child.TiledBackground:SetAllPoints()

    QuestMapFrame.QuestsFrame.DetailsFrame:GetFrameLevel(501)
    QuestMapFrame.QuestsFrame.DetailsFrame:GetFrameStrata('HIGH')


    QuestScrollFrame.Background:SetPoint('BOTTOM', 0, 123)
    QuestScrollFrame.Background:SetAllPoints()

    --self:Setup(WorldMapFrame)--, {addMenu=addMenu})




    self:Setup(QuestScrollFrame, {frame=WorldMapFrame})
    self:Setup(MapQuestInfoRewardsFrame, {frame=WorldMapFrame})
    self:Setup(QuestMapFrame, {frame=WorldMapFrame})
    self:Setup(QuestMapFrame.DetailsFrame, {frame=WorldMapFrame})
    self:Setup(QuestMapDetailsScrollFrame, {frame=WorldMapFrame})

    QuestMapFrame.QuestsFrame.CampaignOverview.Header:SetFrameLevel(QuestMapFrame.QuestsFrame.CampaignOverview.BorderFrame:GetFrameLevel()+1)
    self:Setup(QuestMapFrame.QuestsFrame.CampaignOverview.BorderFrame, {frame=WorldMapFrame})
end