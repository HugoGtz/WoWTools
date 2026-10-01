local function Init()
    --No se modifican los StaticPopupDialogs de Blizzard (taint); solo se rellena el texto de confirmación
    hooksecurefunc('ConfirmationEditBoxMatches', function(editBox, expectedText)
        if expectedText and not ConfirmationStringMatches(editBox:GetText(), expectedText) then
            editBox:SetText(expectedText)
            editBox:ClearFocus()
        end
    end)
end


--Opción suelta de 'Otros' (disabledADD.DELETE): se llama desde 0_Init.lua (onLoad), grupo Interfaz en el panel
function WoWTools_OtherMixin:Init_DELETE()
    if WoWTools_OtherMixin:AddOption(
        'DELETE',
        '|A:XMarksTheSpot:0:0|a'..WoWTools_L['Auto-fill confirmation words'],
        WoWTools_L['Tip.DELETE.Option']..'|n|n'
        ..(WoWTools_L.DELETE_ITEM_CONFIRM_STRING)..', '
        ..(WoWTools_L.UNLEARN_SKILL_CONFIRMATION)..', '
        ..(WoWTools_L.SHADOWLANDS_EXPERIENCE_THREADS_OF_FATE_CONFIRMATION_STRING)..', '
        ..(WoWTools_L.HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING)
        ..'|n|n'..format(WoWTools_L['DELETE_GOOD_ITEM_FMT'], '%s', DELETE_ITEM_CONFIRM_STRING):gsub('\n\n', '\n')
    ) then
        Init()
    end
end
