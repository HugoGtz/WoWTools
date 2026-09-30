
--CVarCallbackRegistry:GetCVarValueBool("colorblindMode") --开启色盲模式界面
WoWTools_ColorMixin={}


function WoWTools_ColorMixin:SetLabelColor(lable)
    if lable and lable.SetTextColor then
        lable:SetTextColor(PlayerUtil.GetClassColor():GetRGB())
    end
end

function WoWTools_ColorMixin:SetStringColor(text)
    if text then
        return PlayerUtil.GetClassColor():WrapTextInColorCode(text)
    else
        return ''
    end
end



local function set_Frame_Color(frame, r, g, b, setA, hex)
    if frame then
        local Type= frame:GetObjectType()
        if Type=='FontString' then
            frame:SetTextColor(r, g, b,setA)
        elseif Type=='Texture' then
            frame:SetColorTexture(r, g, b,setA)
        end
        frame.r, frame.g, frame.b, frame.a, frame.hex= r, g, b, setA, '|c'..hex
    end
end




--RGB转HEX
function WoWTools_ColorMixin:RGBtoHEX(r, g, b, a, frame)
    if r and g and b then

        r= math.max(math.min(r, 1), 0)
        g= math.max(math.min(g, 1), 0)
        b= math.max(math.min(b, 1), 0)

        a= math.max(math.min(a or 1, 1), 0)

        local hex=format("%02x%02x%02x%02x", a*255, r*255, g*255, b*255)

        set_Frame_Color(frame, r, g, b, a, hex)

        return hex
    end
end


--( ) . % + - * ? [ ^ $ 
--HEX转RGB -- ColorUtil.lua
local function ExtractColorValueFromHex(str, index)
    local t= str:sub(index, index + 1)
    if t then
	    return tonumber(t, 16) / 255
    end
end


function WoWTools_ColorMixin:HEXtoRGB(text, frame)
    if not text then
        return
    end
    text= tostring(text)
    text= text:gsub(' ','')
	if text=='' then
        return
    end

    text= text:match('|c(.+)') or text
    text= text:gsub('#', '')
    local len= #text

    local r,g,b,a
    if len>8 then
        text=string.sub(text,1,8)
        len=8

    elseif len==7 then
        text=text..'f'
        len=8

    elseif len<6 then
        while len < 6 do
            text = text..'f'
            len = len + 1;
            if len == 6 then
                break
            end
        end
    end

    if len == 8 then
        a= ExtractColorValueFromHex(text, 1)
        r= ExtractColorValueFromHex(text, 3)
        g= ExtractColorValueFromHex(text, 5)
        b= ExtractColorValueFromHex(text, 7)

    elseif len==6 then--#COLOR_FORMAT_RGB
        a= 1
        r= ExtractColorValueFromHex(text, 1)
        g= ExtractColorValueFromHex(text, 3)
        b= ExtractColorValueFromHex(text, 5)
    end
    if r and g and b then
        set_Frame_Color(frame, r, g, b, a or 1, (len~=8 and 'ff' or '')..text)
        return r,g,b, a or 1
    end
end




--取得, ColorFrame, 颜色
function WoWTools_ColorMixin:Get_ColorFrameRGBA()
    local r,g,b= ColorPickerFrame:GetColorRGB()
    local a= ColorPickerFrame.hasOpacity and ColorPickerFrame:GetColorAlpha() or 1
    r= r and tonumber(format('%.2f', r)) or 1
    g= g and tonumber(format('%.2f', g)) or 1
    b= b and tonumber(format('%.2f', b)) or 1
    a= a~=1 and tonumber(format('%.2f', a)) or a
	return r, g, b, a, {r=r, g=g, b=b, a=a}
end


--ColorPickerFrame.lua
function WoWTools_ColorMixin:ShowColorFrame(valueR, valueG, valueB, valueA, swatchFunc, cancelFunc)
    if not valueR or not valueG or valueB then
        valueR, valueG, valueB= PlayerUtil.GetClassColor():GetRGB()
    end

    ColorPickerFrame:SetupColorPickerAndShow({
        r=valueR,
        g=valueG,
        b=valueB,
        hasOpacity= valueA and true or false,
        swatchFunc= swatchFunc or function()end,
        cancelFunc= cancelFunc or function()end,
        opacity= valueA or 1,
    })
end


