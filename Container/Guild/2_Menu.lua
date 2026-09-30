
local function Save()
    return WoWToolsPlusSave['Plus_GuildBank']
end



--GuildBankFrame:UpdateTabs()
--GuildBankFrame:Update()
local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub

    sub=root:CreateCheckbox(
        WoWTools_L['Tab'],
    function()
        return Save().plusTab
    end, function()
        Save().plusTab= not Save().plusTab and true or false
        GuildBankFrame:UpdateTabs()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.GuildBank.PlusTab'])

    sub=root:CreateCheckbox(
        WoWTools_L['Index'],
    function()
        return Save().showIndex
    end, function()
        Save().showIndex= not Save().showIndex and true or false
        WoWTools_GuildBankMixin:Init_Plus()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.GuildBank.PlusIndex'])

    sub=root:CreateCheckbox(
        WoWTools_L['ITEMS+INFO'],
    function()
        return Save().plusItem
    end, function()
        Save().plusItem= not Save().plusItem and true or false
        GuildBankFrame:Update()
    end)
    WoWTools_MenuMixin:SetDescription(sub, WoWTools_L['Tip.GuildBank.PlusItem'])


    sub= root:CreateCheckbox(
        WoWTools_L.HUD_EDIT_MODE_BAGS_LABEL,
    function()
        return Save().autoOpenBags
    end, function()
        Save().autoOpenBags= not Save().autoOpenBags and true or nil
        if Save().autoOpenBags then
            do
                WoWTools_BagMixin:OpenBag(nil, false)
            end
            if not InCombatLockdown() then
                GuildBankFrame:Raise()
            end
        end
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_MenuMixin:AddDescription(tooltip, WoWTools_L['Tip.GuildBank.AutoOpenBags'])
        tooltip:AddLine(WoWTools_L['OPENING+GUILD_BANK'])
        tooltip:AddLine(MicroButtonTooltipText(WoWTools_L.BINDING_NAME_OPENALLBAGS, "OPENALLBAGS")
    )
    end)

    root:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().saveItemSeconds or 0.8
        end, setValue=function(value)
            Save().saveItemSeconds=value
        end,
        name=WoWTools_L.LAG_TOLERANCE,
        minValue=0.2,
        maxValue=3,
        step=0.1,
        bit='%.1f',
        tooltip=function(tooltip)
            tooltip:AddDoubleLine(WoWTools_L.LAG_TOLERANCE,
                (Save().saveItemSeconds or 0.8 )..' '..(WoWTools_L.LOSS_OF_CONTROL_SECONDS)
            )
            tooltip:AddLine(DEPOSIT..', '..WITHDRAW..', '..BAG_CLEANUP_BANK)
        end
    })
    root:CreateSpacer()

    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_GuildBankMixin.addName})
    WoWTools_MenuMixin:Reload(sub)


end



local function Init()
    local btn= WoWTools_ButtonMixin:Menu(GuildBankFrame.CloseButton, {
        name='WoWToolsGuildBankMenuButton',
    })
    btn:SetPoint('RIGHT', GuildBankFrame.CloseButton, 'LEFT', -2, 0)

    btn:SetupMenu(Init_Menu)

    Init=function()end
end




function WoWTools_GuildBankMixin:Init_Menu()
   Init()
end