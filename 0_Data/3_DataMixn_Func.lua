--CanAccessObject(ChatFrame1)

function WoWTools_DataMixin:Call(func, ...)
    if type(func)=='string' then
        if _G[func] then
            securecallfunction(_G[func], ...)
            return
        end
    elseif func then
        securecallfunction(func, ...)
        return
    end
end
--CanAccessObject(obj)
--Rellena en los ajustes guardados las claves que faltan (tablas, números, textos) con los valores por defecto.
--No toca los booleanos: muchas opciones se desactivan guardando nil y se volverían a activar.
--Evita errores nil cuando una versión nueva añade opciones y el jugador tiene ajustes de una versión anterior.
function WoWTools_DataMixin:SetDefaults(save, defaults)
    if type(save)~='table' then
        return defaults
    end
    if type(defaults)=='table' and save~=defaults then
        for key, value in pairs(defaults) do
            if save[key]==nil and type(value)~='boolean' then
                save[key]= value
            end
        end
    end
    return save
end


--hooksecurefunc seguro: si la función o el método de Blizzard ya no existe (p. ej. retirado en 12.0),
--no se engancha nada en vez de dar error. Antes, con un global inexistente se pasaba el nombre como texto.
function WoWTools_DataMixin:Hook(obj, ...)
    if type(obj)=='string' then
        if type(_G[obj])=='function' then
            hooksecurefunc(obj, ...)
        end
        return
    end

    if type(obj)~='table' then
        return
    end
    if obj.IsForbidden and obj:IsForbidden() then--un objeto prohibido no se engancha
        return
    end
    local method= ...
    if type(method)=='string' and type(obj[method])~='function' then
        return
    end
    hooksecurefunc(obj, ...)
end


function WoWTools_DataMixin:Load(id, typeString)
    if not id or not typeString then
        return
    end

    if typeString=='quest' then
        if not HaveQuestData(id) then
            C_QuestLog.RequestLoadQuestByID(id)
        end
        if not HaveQuestRewardData(id) then
            C_TaskQuest.RequestPreloadRewardData(id)
        end

    elseif typeString=='spell' then
        local spellID= id
        if type(id)=='string' then
            spellID= (C_Spell.GetSpellInfo(id) or {}).spellID
        end
        if spellID and not C_Spell.IsSpellDataCached(spellID) then
            C_Spell.RequestLoadSpellData(spellID)
        end

    elseif typeString=='item' then
        if not C_Item.IsItemDataCachedByID(id) then
            C_Item.RequestLoadItemDataByID(id)
        end

    elseif typeString=='itemLocation' then
        if not C_Item.IsItemDataCached(id) then
            C_Item.RequestLoadItemData(id)
        end

    elseif typeString=='challengeMap' then
        C_ChallengeMode.RequestLeaders(id)

    elseif typeString=='club' then
        return C_ClubFinder.RequestPostingInformationFromClubId(id)
    end
end


local itemLoadTab={
        134020,
        5512,
        8529,
        226373,
        38682,
        5512,
        87399,
    }
local spellLoadTab={
    113509,
    818,
    179244,
    179245,
    33388,
    33391,
    34090,
    34091,
    90265,
    783,
    436854,
    404468,
    80451,
    431280,

}


for _, itemID in pairs(itemLoadTab) do
   WoWTools_DataMixin:Load(itemID, 'item')
end
for _, spellID in pairs(spellLoadTab) do
   WoWTools_DataMixin:Load(spellID, 'spell')
end


function WoWTools_DataMixin:MK(number, bit)
    if not number then
        return
    end


    bit = bit or 1

    local t= ''
    if number>=1e9 then--escala k, M, B
        number= number/1e9
        t='B'
    elseif number>=1e6 then
        number= number/1e6
        t='M'
    elseif number>=1e3 then
        number= number/1e3
        t='k'-- '|cffffffffk|r'
    end
    if bit==0 then
        number= math.modf(number)
        number= number==0 and 0 or number
        return number..t--format('%i', number)..text
    else
        local num, point= math.modf(number)
        if point==0 then
            return num..t
        else---0.5/10^bit
            local n= format('%0.'..bit..'f', number)
            while n:find('0$') do
                n= n:gsub('0$', '')
            end
            return n..t
        end
    end
end


function WoWTools_DataMixin:GetExpansionText(expacID, questID)
    if not expacID and questID then
        expacID= GetQuestExpansion(questID)
    end

    local text= expacID and WoWTools_TextMixin:CN(_G['EXPANSION_NAME'..expacID])
    if text then
        text= (WoWTools_TextureMixin:GetWoWLog(expacID) or '')..text..' '..(expacID+1)
        if WoWTools_DataMixin.ExpansionLevel > expacID then
            text= DISABLED_FONT_COLOR:WrapTextInColorCode(text)
        end
        return text
    end
end


function WoWTools_DataMixin:Reload()
    --if not (PlayerIsInCombat() and e.IsEncouter_Start) or select(2, IsInInstance())=='none' then
    --if not issecure() then
    self:Call(C_UI.Reload)
            --C_UI.Reload()
end


function WoWTools_DataMixin:Get_CVar_Tooltips(info)
    return (info.msg and info.msg..'|n' or '')..info.name..'|n'
    ..(info.value and C_CVar.GetCVar(info.name)== info.value and format('|A:%s:0:0|a', 'common-icon-checkmark') or '')
    ..(info.value and (WoWTools_L.SETTINGS)..info.value..' ' or '')
    ..'('..(WoWTools_L.REFORGE_CURRENT)..'|cnGREEN_FONT_COLOR:'..format('%.1f', tonumber(C_CVar.GetCVar(info.name)) or 0)..'|r |r'
    ..(WoWTools_L.DEFAULT)..'|cffff00ff'..format('%.1f', tonumber(C_CVar.GetCVarDefault(info.name)) or 0)..')|r'
end


function WoWTools_DataMixin:PlaySound(soundKitID, setPlayerSound)
    if not C_CVar.GetCVarBool('Sound_EnableAllSound') or C_CVar.GetCVar('Sound_MasterVolume')=='0' or (not setPlayerSound and not WoWTools_DataMixin.IsSetPlayerSound) then
        return
    end
    local channel

    if C_CVar.GetCVarBool('Sound_EnableDialog') and C_CVar.GetCVar("Sound_DialogVolume")~='0' then
        channel= 'Dialog'
    elseif C_CVar.GetCVarBool('Sound_EnableAmbience') and C_CVar.GetCVar("Sound_AmbienceVolume")~='0' then
        channel= 'Ambience'
    elseif C_CVar.GetCVarBool('Sound_EnableSFX') and C_CVar.GetCVar("Sound_SFXVolume")~='0' then
        channel= 'SFX'
    elseif C_CVar.GetCVarBool('Sound_EnableMusic') and C_CVar.GetCVar("Sound_MusicVolume")~='0' then
        channel= 'Music'
    else
        channel= 'Master'
    end
    local success, voHandle= PlaySound(soundKitID or SOUNDKIT.GS_CHARACTER_SELECTION_ENTER_WORLD, channel)--SOUNDKIT.READY_CHECK SOUNDKIT.LFG_ROLE_CHECK SOUNDKIT.LFG_ROLE_CHECK SOUNDKIT.IG_PLAYER_INVITE
    return success, voHandle
end

--TextToSpeech_Speak(questDescription, ttsVoices)
function WoWTools_DataMixin:PlayText(text)
    if not text or text=='' then
        return
    end

    local volume = C_TTSSettings.GetSpeechVolume() or 0
    volume= volume==0 and 50 or volume

    local neverQueue= false
    local allowOverlappedSpeech= false
    local voice= {voiceID=C_TTSSettings.GetVoiceOptionID(Enum.TtsVoiceType.Standard) or 0}
    TextToSpeech_Speak(text, voice, neverQueue, allowOverlappedSpeech)
end



function WoWTools_DataMixin:GetFormatter1to10(value, minValue, maxValue)
    if value and minValue and maxValue then
        return RoundToSignificantDigits(((value-minValue)/(maxValue-minValue) * (maxValue- minValue)) + minValue, maxValue)
    end
    return value
end


--WoWTools_DataMixin:StaticPopup_FindVisible('PARTY_INVITE')
function WoWTools_DataMixin:StaticPopup_FindVisible(which)
    local info = StaticPopupDialogs[which];
	if info then
        for index = 1, 4, 1 do--STATICPOPUP_NUMDIALOGS
            local frame = _G["StaticPopup"..index]--StaticPopup_GetDialog(index)
            if frame and frame:IsShown() and (frame.which == which) then-- and (not info.multiple or (frame.data == data)) ) then
                return frame, frame.timeleft--StaticPopup1
            end
        end
    end
end


