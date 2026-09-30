--欢迎加入
local function Save()
    return WoWToolsPlusSave['ChatButton_HyperLink'] or {}
end

--escapar . ( - etc. de la cadena localizada antes de convertir %s en captura
local function ToPattern(fmt)
    local pat= fmt:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', '%%%0')
    pat= pat:gsub('%%%%s', '(.+)')
    return pat
end
local raidMS= ToPattern(ERR_RAID_MEMBER_ADDED_S)--%s加入了团队。
local partyMS= ToPattern(JOINED_PARTY)--%s加入了队伍。
local guildMS= ToPattern(ERR_GUILD_JOIN_S)--加入了公会















local function Init()
    if not (Save().guildWelcome or Save().groupWelcome) then
        return
    end

    EventRegistry:RegisterFrameEventAndCallback("CHAT_MSG_SYSTEM", function(_, text)
        if not canaccessvalue(text) or not text then
            return
        end

        --Paréntesis: antes se saludaba al grupo aunque groupWelcome estuviera desactivado
        local group= Save().groupWelcome and (text:match(raidMS) or text:match(partyMS))
        local guild= Save().guildWelcome and text:match(guildMS)

        if group then
            if UnitIsGroupLeader('player') and (Save().welcomeOnlyHomeGroup and IsInGroup(LE_PARTY_CATEGORY_HOME) or not Save().welcomeOnlyHomeGroup) then
                WoWTools_ChatMixin:Chat(WoWToolsPlusPlayerDate['HyperLinkGroupWelcomeText'] or (WoWTools_DataMixin.Player.IsCN and '{rt1}欢迎{rt1}' or '{rt1}Hi{rt1}'), group, nil)
            end

        elseif guild and IsInGuild() and CanGuildInvite() then--solo quien puede invitar: si no, cada miembro con el addon saludaba (spam en /g)

            C_Timer.After(2, function()
                if C_ChatInfo.InChatMessagingLockdown and C_ChatInfo.InChatMessagingLockdown() then
                    return
                end
                C_ChatInfo.SendChatMessage(
                    (WoWToolsPlusPlayerDate['HyperLinkGuildWelcomeText'] or (WoWTools_DataMixin.Player.IsCN and '欢迎' or EMOTE103_CMD1:gsub('/','')))
                    ..' '
                    .. guild
                    ..' '..GUILD_INVITE_JOIN,

                    "GUILD"
                )
            end)

        end
    end)

    Init=function()end
end












--欢迎加入
function WoWTools_HyperLink:Init_Welcome()
    Init()
end
