


--背包 Bg FlatPanelBackgroundTemplate


--小，背包
--NUM_CONTAINER_FRAMES 11.2版本是 6， 以前是13
--NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS+1 do--13 NUM_CONTAINER_FRAMES = 13
--or i== NUM_TOTAL_BAG_FRAMES+2 then
function WoWTools_MoveMixin.Frames:ContainerFrame1()
    if C_AddOns.IsAddOnLoaded('Blizzmove') then
        WoWTools_Print(self.addName..WoWTools_DataMixin.Icon.icon2,
            format(WoWTools_L.ALREADY_BOUND, 'Blizzmove'),
            'ContainerFrame1', WoWTools_TextMixin:GetEnabeleDisable(false)
        )
        return
    end

    for i=1, NUM_CONTAINER_FRAMES do
        local frame= _G['ContainerFrame'..i]
        if frame then
            if i==1 then
                self:Setup(frame, {
                    restPointFunc=function()
                        if not InCombatLockdown() then
                            WoWTools_DataMixin:Call('UpdateContainerFrameAnchors')
                        end
                    end,
                })
            else
                self:Setup(frame, {notSave=true})
            end
        end
    end

    WoWTools_DataMixin:Hook('UpdateContainerFrameAnchors', function()--ContainerFrame.lua
        for _, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
            self:Set_SizeScale(frame)
            if frame==ContainerFrameCombinedBags or frame==ContainerFrame1 then--位置
                self:SetPoint(frame)--设置, 移动, 位置
            end
        end
    end)

--BagsBar
    self:MoveAlpha(BagsBar)



 --背包
    self:Setup(ContainerFrameCombinedBags)
end
