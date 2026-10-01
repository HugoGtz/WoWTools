
WoWTools_SliderMixin={}

function WoWTools_SliderMixin:CSlider(frame, tab)
    local slider= CreateFrame("Slider", nil, frame, 'OptionsSliderTemplate')--UISliderTemplateWithLabels
    slider:SetSize(tab.w or 200, tab.h or 18)
    slider:SetMinMaxValues(tab.min, tab.max)
    if tab.value then
        slider:SetValue(tab.value)
    end
    slider.Low:SetText(tab.text or tab.min)
    slider.High:SetText('')
    slider.Text:SetText(tab.value)

    slider.Low:ClearAllPoints()
    slider.Low:SetPoint('LEFT')
    slider.Text:ClearAllPoints()
    slider.Text:SetPoint('RIGHT')

    local setp= tab.setp or 1
    slider:SetValueStep(setp)
    slider:SetObeyStepOnDrag(true)--al arrastrar, respetar el paso (antes devolvía decimales)
    slider:SetScript('OnValueChanged', tab.func)
    slider:EnableMouseWheel(true)
    slider.max= tab.max
    slider.min= tab.min
    slider:SetScript('OnMouseWheel', function(f, d)
        local setp= f:GetValueStep() or 1
        local value= f:GetValue()
        if d== 1 then--rueda arriba = más, como en la UI de Blizzard
            value= value+ setp
        elseif d==-1 then
            value= value- setp
        end
        value= value> f.max and f.max or value
        value= value< f.min and f.min or value
        f:SetValue(value)
    end)
    if tab.color then
        slider.Low:SetTextColor(1,0,1)
        slider.High:SetTextColor(1,0,1)
        slider.Text:SetTextColor(1,0,1)
        slider.NineSlice.BottomEdge:SetVertexColor(1,0,1)
        slider.NineSlice.TopEdge:SetVertexColor(1,0,1)
        slider.NineSlice.RightEdge:SetVertexColor(1,0,1)
        slider.NineSlice.LeftEdge:SetVertexColor(1,0,1)
        slider.NineSlice.TopRightCorner:SetVertexColor(1,0,1)
        slider.NineSlice.TopLeftCorner:SetVertexColor(1,0,1)
        slider.NineSlice.BottomRightCorner:SetVertexColor(1,0,1)
        slider.NineSlice.BottomLeftCorner:SetVertexColor(1,0,1)
    end
    slider:SetScript('OnLeave', GameTooltip_Hide)
    local tips= tab.tips or tab.tip
    if type(tips)=='function' then
        slider:SetScript('OnEnter', tips)
    else
        slider:SetScript('OnEnter', function(f)
            GameTooltip:SetOwner(f, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(tab.text)
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine('|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a'..(WoWTools_L.MINIMUM)..': '..tab.min)
            GameTooltip:AddLine('|A:bags-greenarrow:0:0|a'..(WoWTools_L.MAXIMUM)..': '..tab.max)
            GameTooltip:AddLine((WoWTools_L['Step'])..': '..setp)
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine('|A:common-icon-rotateright:0:0|a'..(WoWTools_L.ITEM_UPGRADE_CURRENT)..f:GetValue())
            GameTooltip:Show()
        end)
    end
    return slider
end
