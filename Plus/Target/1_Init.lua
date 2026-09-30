WoWTools_TargetMixin={}


local P_Save= {
    target= true,
    --targetTextureNewTab={},
    targetTextureName='common-icon-rotateright',

    targetColor= {r=1,g=1,b=1,a=1},
    targetInCombat=true,
    targetInCombatColor={r=1, g=0, b=0, a=1},
    w=40,
    h=20,
    x=0,
    y=0,
    scale=1.5,
    elapsed=0.5,
    TargetFramePoint='LEFT',--'TOP', 'HEALTHBAR','LEFT'

    creature= true,
    creatureFontSize=10,

    unitIsMe=true,
    unitIsMeTextrue= 'auctionhouse-icon-favorite',
    unitIsMeSize=12,
    unitIsMePoint='TOPLEFT',
    unitIsMeParent='healthBar',--name
    unitIsMeX=0,
    unitIsMeY=-2,
    unitIsMeColor={r=1,g=1,b=1,a=1},

    quest= true,
    questShowPlayerClass=true,
}







function WoWTools_TargetMixin:Set_All_Init()
    if WoWToolsPlusSave['Plus_Target'].disabled then
        return
    end



    WoWTools_TargetMixin:Init_targetFrame()
    
    WoWTools_TargetMixin:Init_questFrame()
    --WoWTools_TargetMixin:Init_isMeFrame()
    --WoWTools_TargetMixin:Init_numFrame()
end












local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)  
    if arg1~= 'WoWToolsPlus' then
        return
    end

    WoWToolsPlusSave['Plus_Target']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Plus_Target'], P_Save)
    P_Save= nil

    WoWToolsPlusPlayerDate['TargetTexture']= WoWToolsPlusPlayerDate['TargetTexture'] or {}

    WoWTools_TargetMixin.addName= '|A:common-icon-rotateright:0:0|a'..(WoWTools_L['Module.Target'])

    WoWTools_TargetMixin:Set_All_Init()

    WoWTools_TargetMixin:Init_Options()
    self:SetScript('OnEvent', nil)
    self:UnregisterEvent(event)
end)