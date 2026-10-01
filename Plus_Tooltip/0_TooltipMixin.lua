WoWTools_TooltipMixin={
    WoWHead= 'https://www.wowhead.com/',
    Events={},
    Frames={},
    addName= '|A:newplayertutorial-drag-cursor:0:0|a'..WoWTools_L['Module.Tooltips'],
    iconSize=0,
    Save= function()
        return WoWToolsPlusSave['Plus_Tootips'] or WoWTools_TooltipMixin.Defaults
    end,
    --Fork: el módulo de tooltips (hooks en todos los tooltips del juego) se ha quitado porque choca con
    --Raider.IO. Se conservan las funciones que otros módulos llaman para sus propios tooltips.
    Defaults= {modelSize=100, modelX=0, modelY=-24, modelFacing=-0.3},
}



function WoWTools_TooltipMixin:Show(tooltip)
    tooltip= tooltip or GameTooltip
    tooltip:Show()
    --WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', tooltip)
end





function WoWTools_TooltipMixin:IsInCombatDisabled(tooltip)
    return
        not tooltip
        or WoWTools_FrameMixin:IsLocked(tooltip)
        or (self:Save().isInCombatDisabled and InCombatLockdown())
end

function WoWTools_TooltipMixin:OpenOption(root, name2)
    return WoWTools_MenuMixin:OpenOptions(root, {category=self.Category, name=self.addName, nam2=name2})
end

