


local P_Mouts_Tab={
    Item={
        [174464]=true,
        [168035]=true,
    },
    Spell={
        [2645]=true,
        [111400]=true,
        [2983]=true,
        [190784]=true,
        [48265]=true,
        [186257]=true,
        [6544]=true,
        [358267]= true,
        [1953]=true,
        [109132]=true,
        [121536]=true,
        [189110]=true,
        [195072]=true,
    },
    Floor={},--{[spellID]={uiMapID1=true, uiMapID2=true, ...}
    Ground={
        [256123]=true,
    },
    Flying={
        [163024]=true,
    },
    Aquatic={
        [98718]=true,
    },
    Dragonriding={
        [368896]=true,
    },
    Shift={
        [359379]=true,
        [376912]=true,
        [342680]=true,
        [30174]=true,
        [98718]=true,
        [64731]=true,
    },
    Alt={
        [264058]=true,
        [122708]=true,
        [61425]=true,
    },
    Ctrl={
        [256123]=true,
     },
}


local P_Save={
    mountShowTime=3,
    showFlightModeButton=true,
    --toFrame=nil,
}



WoWTools_MountMixin={
    MountType={
        'Ground',
        'Aquatic',
        'Flying',
        'Dragonriding',

        'Alt',
        'Ctrl',
        'Shift',

        'Floor',
    },
    TypeName={
        Ground= MOUNT_JOURNAL_FILTER_GROUND,
        Aquatic= MOUNT_JOURNAL_FILTER_AQUATIC,
        Flying= MOUNT_JOURNAL_FILTER_FLYING,
        Dragonriding= MOUNT_JOURNAL_FILTER_DRAGONRIDING,

        Alt= 'Alt',
        Ctrl= 'Ctrl',
        Shift= 'Shift',
        Floor= FLOOR,

        Spell= SPELLS,
        Item= ITEMS,
    }
}

function WoWTools_MountMixin:Get_Table_Num(mountType)
    return CountTable(WoWToolsPlusPlayerDate['Tools_Mounts'][mountType] or {})
end

function WoWTools_MountMixin:P_Mouts_Tab()
    return P_Mouts_Tab
end


local function Save()
    return WoWToolsPlusSave['Tools_Mounts']
end




local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWToolsPlus' then
            WoWTools_MountMixin.addName= '|TInterface\\Icons\\MountJournalPortrait:0|t'..(WoWTools_L['Module.Mounts'])

            WoWToolsPlusSave['Tools_Mounts']= WoWTools_DataMixin:SetDefaults(WoWToolsPlusSave['Tools_Mounts'], P_Save)
            P_Save= nil

            if Save().Mounts then
                WoWToolsPlusPlayerDate['Tools_Mounts']={
                    Item= Save().Mounts[ITEMS] or P_Mouts_Tab.Item or {},--antes .Items (errata)
                    Spell= Save().Mounts[SPELLS] or P_Mouts_Tab.Spell or {},
                    Floor= Save().Mounts[FLOOR] or P_Mouts_Tab.Floor or {},
                    Ground= Save().Mounts[MOUNT_JOURNAL_FILTER_GROUND] or P_Mouts_Tab.Ground or {},
                    Flying= Save().Mounts[MOUNT_JOURNAL_FILTER_FLYING] or P_Mouts_Tab.Flying or {},
                    Aquatic= Save().Mounts[MOUNT_JOURNAL_FILTER_AQUATIC] or P_Mouts_Tab.Aquatic or {},
                    Dragonriding= Save().Mounts[MOUNT_JOURNAL_FILTER_DRAGONRIDING] or P_Mouts_Tab.Dragonriding or {},
                    Shift= Save().Mounts.Shift or P_Mouts_Tab.Shift or {},
                    Alt= Save().Mounts.Alt or P_Mouts_Tab.Alt or {},
                    Ctrl= Save().Mounts.Ctrl or P_Mouts_Tab.Ctrl or {},
                }
                Save().Mounts= nil
            else
                WoWToolsPlusPlayerDate['Tools_Mounts']= WoWToolsPlusPlayerDate['Tools_Mounts'] or P_Mouts_Tab
            end

            WoWTools_ToolsMixin:CreateButton({
                name='Mount',
                tooltip=WoWTools_MountMixin.addName,
            })

            if WoWTools_ToolsMixin:Get_ButtonForName('Mount') then

                self:RegisterEvent('PLAYER_ENTERING_WORLD')

                WoWTools_MountMixin.faction= WoWTools_DataMixin.Player.Faction=='Horde' and 0 or (WoWTools_DataMixin.Player.Faction=='Alliance' and 1)

                for name, tab in pairs(WoWToolsPlusPlayerDate['Tools_Mounts']) do
                    for ID in pairs(tab) do
                        WoWTools_DataMixin:Load(ID,  name=='Item' and 'item' or 'spell')
                    end
                end

                WoWTools_MountMixin:Init_MountJournal()
                WoWTools_MountMixin:Init_UI_SpellBook_Menu()

            else
                self:SetScript('OnEvent', nil)
            end

            self:UnregisterEvent(event)
        end

    elseif event== 'PLAYER_ENTERING_WORLD'  then
        WoWTools_MountMixin:Init_Button()
        self:UnregisterEvent(event)
        self:SetScript('OnEvent', nil)
    end
end)
