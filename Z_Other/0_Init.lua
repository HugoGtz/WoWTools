

WoWTools_OtherMixin={
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
        tooltip= (tooltip and tooltip..'|n|n' or '')..(WoWTools_L.REQUIRES_RELOAD),
        layout= self.Layout,
        category= self.Category,
    })

    return enabled, sub
end





--'Otros' no es un módulo: solo guarda opciones sueltas (disabledADD) de otros archivos, sin casilla propia
WoWTools_Module:Register({
    key= 'Other',
    name= 'Module.Other',
    icon= 'QuestNormal',
    group= 'Tools',
    defaults= {disabledADD={}},
    mixin= WoWTools_OtherMixin,
    panel= false,
    onLoad= function()
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

        --Fork: sin página 'Otros'; sus opciones se agrupan por tema en la página principal

        --Opciones sueltas (cada una en su archivo)
        WoWTools_OtherMixin:Init_DELETE()
    end,
})
