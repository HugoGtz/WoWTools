

WoWTools_OpenItemMixin={}

local P_Save={
    use={
        [190198]=5,
        [201791]=1,
        [198969]=1,

        [198790]=1,
        [201781]=1,
        [201783]=1,
        [201779]=1,

        [201922]=1,
        [200287]=1,
        [202092]=1,
        [200453]=1,

        [201924]=1,
        [202093]=1,
        [200455]=1,
        [200289]=1,

        [201923]=1,
        [200288]=1,
        [202094]=1,
        [200454]=1,


        [200285]=1,
        [201921]=1,
        [200452]=1,
        [202091]=1,
        [201782]=1,


        [204573]=1,
        [204574]=1,
        [204575]=1,
        [204576]=1,
        [204577]=1,
        [204578]=1,
        [204579]=1,

        [204075]=15,
        [204076]=15,
        [204077]=15,
        [204717]=2,
        [190328]=10,
        [190322]=10,

        --10.2
        [208396]=2,
        --10.2.7
        [87779]=1,

        --11
        [229899]=100,
        [224025]=10,
        [219191]=15,


    },
    no={
        [64402]=true,
        [6948]=true,
        [23247]=true,
        [168416]=true,
        [109076]=true,
        [132119]=true,
        [193902]=true,
        [37863]=true,

        [139590]=true,
        [163604]=true,
        [199900]=true,
        [198083]=true,
        [191294]=true,
        [202087]=true,
        [128353]=true,
        [86143]=true,--pet
        [5512]=true,
        [92675]=true,
        [92741]=true,

        [102464]=true,
        [94233]=true,

        --10.0
        [194510]=true,
        [199197]=true,
        [200613]=true,
        [18149]=true,
        [194701]=true,
        [192749]=true,

        [204439]=true,
        [194743]=true,
        [194730]=true,
        [194519]=true,
        [202620]=true,
        [191529]=true,
        [191526]=true,
        [193915]=true,
        [190320]=true,

        --10.1
        [203708]=true,
        [205982]=true,
        [207057]=true,
        --10.2
        [208066]=true,
        [208067]=true,
        [208047]=true,
        [210014]=true,
        [190324]=true,

        --10.2.7
        [217956]=true,
        [217608]=true,
        [217607]=true,
        [217606]=true,
        [217605]=true,
        [217930]=true,
        [217929]=true,
        [217928]=true,

        [217731]=true,
        [217730]=true,
        [217901]=true,

        [89770]=true,
        [219940]=true,
        [95350]=true,

        --11
        [224185]=true

    },
    pet=true,
    open=true,
    toy=true,
    mount=true,
    mago=true,
    ski=true,
    alt=true,
    --noItemHide= true,--true,
}




if WoWTools_DataMixin.Player.Class=='ROGUE' then
   WoWTools_DataMixin:Load(1804, 'spell')
end
















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then
            WoWToolsPlusSave['Tools_OpenItems']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Tools_OpenItems'], P_Save)
            P_Save= nil

            WoWTools_OpenItemMixin.addName= '|A:BonusLoot-Chest:0:0|a'..(WoWTools_L['Module.Open items'])

            WoWTools_ToolsMixin:CreateButton({
                name='OpenItems',
                tooltip=WoWTools_OpenItemMixin.addName,
            })

            if WoWTools_ToolsMixin:Get_ButtonForName('OpenItems') then
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
            else
                self:SetScript('OnEvent', nil)
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_OpenItemMixin:Init_Button()
        self:UnregisterEvent(event)
    end
end)