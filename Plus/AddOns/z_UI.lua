
--插件，管理









--插件
function WoWTools_MoveMixin.Events:Blizzard_AddOnList()
    AddonList.ScrollBox:ClearAllPoints()
    AddonList.ScrollBox:SetPoint('LEFT', 7, 0)
    AddonList.ScrollBox:SetPoint('TOP', AddonList.Performance, 'BOTTOM')
    AddonList.ScrollBox:SetPoint('BOTTOMRIGHT', -22,32)



    WoWTools_MoveMixin:Setup(AddonList, {
        minW=430, minH=120,
    sizeRestFunc=function(frame)
        frame:SetSize(500, 480)
    end})

end
