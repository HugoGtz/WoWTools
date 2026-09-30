
--容器，背包
function WoWTools_ItemMixin.Frames:ContainerFrame1()


    Menu.ModifyMenu("MENU_CONTAINER_FRAME", function(frame, root)
        self:SetOptions(frame, root, {
            name='ContainerFrame1',
            call='ContainerFrame_UpdateAll'
        })
    end)
    Menu.ModifyMenu("MENU_CONTAINER_FRAME_COMBINED", function(frame, root)
        self:SetOptions(frame, root, {
            name='ContainerFrame1',
            call='ContainerFrame_UpdateAll'
        })
    end)

    --UpdateCooldown salta en cada hueco con cada BAG_UPDATE_COOLDOWN/SPELL_UPDATE_COOLDOWN:
    --no volver a escanear el mismo objeto en menos de 2 s
    WoWTools_DataMixin:Hook(ContainerFrameItemButtonMixin, 'UpdateCooldown', function(btn)
        local bagID, slotID= btn:GetBagID(), btn:GetID()
        local isNo= self:SaveNo().ContainerFrame1
        local size= self:SaveSize().ContainerFrame1
        local link= bagID and slotID and C_Container.GetContainerItemLink(bagID, slotID)
        local key= tostring(link)..':'..tostring(isNo)..':'..tostring(size)
        local now= GetTime()
        if btn.wowtoolsInfoKey==key and btn.wowtoolsInfoTime and now-btn.wowtoolsInfoTime<2 then
            return
        end
        btn.wowtoolsInfoKey= key
        btn.wowtoolsInfoTime= now
        WoWTools_ItemMixin:SetupInfo(btn, not isNo and {bag={bag=bagID, slot=slotID}, size=size} or nil)
    end)
end

