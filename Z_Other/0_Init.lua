

WoWTools_OtherMixin={
    Save=function()
       return WoWToolsPlusSave['Other'] or {}
    end,
    OpenOption=function()end
}

function WoWTools_OtherMixin:OpenOption(root, name, name2)
    return WoWTools_MenuMixin:OpenOptions(root, {
        category= self.Category,
        layout= self.Layout,
        name= name or self.addName,
        name2= name2
    })
end

function WoWTools_OtherMixin:AddOption(name, addName, tooltip)

    local enabled= not self:Save().disabledADD[name]

    local sub= WoWTools_PanelMixin:OnlyCheck({
        name= addName,
        Value= enabled,
        GetValue=function()
            return not self:Save().disabledADD[name]
        end,
        SetValue= function()
            self:Save().disabledADD[name]= not self:Save().disabledADD[name] and true or nil
        end,
        tooltip= (tooltip and tooltip..'|n|n' or '')..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD),
        layout= self.Layout,
        category= self.Category,
    })

    return enabled, sub
end





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1~= 'WoWToolsPlus' then
        return
    end

    WoWToolsPlusSave['Other']=  WoWToolsPlusSave['Other'] or {disabledADD={}}

--旧数据
    if WoWToolsPlusSave['Other_ClassMenuColor'] and WoWToolsPlusSave['Other_ClassMenuColor'].disabled then
        WoWTools_OtherMixin:Save().disabledADD.ClassMenuColor= true
        WoWToolsPlusSave['Other_ClassMenuColor'].disabled= nil
    end
    if WoWToolsPlusSave['Other_DELETE'] and WoWToolsPlusSave['Other_DELETE'].disabled then
        WoWTools_OtherMixin:Save().disabledADD.DELETE= true
        WoWToolsPlusSave['Other_DELETE'].disabled= nil
    end
    if WoWToolsPlusSave['Other_MoneyFrame'] and WoWToolsPlusSave['Other_MoneyFrame'].disabled then
        WoWTools_OtherMixin:Save().disabledADD.MoneyFrame= true
        WoWToolsPlusSave['Other_MoneyFrame'].disabled= nil
    end

    --Fork: autocompletar "DELETE" pasa a estar desactivado por defecto (se puede volver a activar en opciones)
    if not WoWTools_OtherMixin:Save().forkDeleteOptIn then
        WoWTools_OtherMixin:Save().disabledADD.DELETE= true
        WoWTools_OtherMixin:Save().forkDeleteOptIn= true
    end


    WoWTools_OtherMixin.addName= '|A:QuestNormal:0:0|a'..(WoWTools_DataMixin.onlyChinese and '其它' or OTHER)

    WoWTools_OtherMixin.Category, WoWTools_OtherMixin.Layout= WoWTools_PanelMixin:AddSubCategory({
        name= WoWTools_OtherMixin.addName
    })


    self:SetScript('OnEvent', nil)
    self:UnregisterEvent(event)
end)