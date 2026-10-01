WoWTools_TextMixin={}




function WoWTools_TextMixin:ShowText(data, headerText, tab)
    if not canaccesstable(data) then
        WoWTools_Print(WoWTools_DataMixin.Icon.icon2..'|cnWARNING_FONT_COLOR:'..(WoWTools_L.EVENTTRACE_SHOW_SECRET_VALUES))
        return
    end
    tab= tab or {}

    headerText= tostring(headerText)
    headerText= (headerText=='' or headerText=='nil') and WoWTools_DataMixin.addName or headerText

    local onHide= tab.onHide
    local clear= tab.notClear

    local frame= _G['WoWToolsShowTextEditBoxFrame']
    if not frame then
        frame= WoWTools_FrameMixin:Create(nil, {name='WoWToolsShowTextEditBoxFrame'})
        frame.ScrollBox=WoWTools_EditBoxMixin:CreateFrame(frame, {isLink=true})
        frame.ScrollBox:SetPoint('TOPLEFT', 11, -32)
        frame.ScrollBox:SetPoint('BOTTOMRIGHT', -6, 12)

        frame:SetScript('OnHide', function(f)
            if f.onHide then
                do
                    f.onHide(f.ScrollBox:GetText())
                end
                f.onHide=nil
            end
            f.ScrollBox:SetText('')
            f.Header:Setup('')
        end)
        frame:SetFrameStrata('HIGH')
    end

    frame:Show()
    frame:Raise()

    frame.Header:Setup(headerText or '' )
    frame.onHide= onHide

    local edit=  frame.ScrollBox.editBox

    if clear then
        edit:SetText('')
    end

    local function add_text(value)
        if issecretvalue(value)
            or (type(value)=='string' and value:find('(:?|?)|K(.-)|k'))
        then
            edit:Insert('***'..format(WoWTools_L.EVENTTRACE_SECRET_FMT, '***'))
        elseif type(value)=='string' then
            edit:Insert(value)
        else
            edit:Insert(tostring(value))
        end
        edit:Insert('\n')
    end

    if type(data)~='table' then
        add_text(data)
    else
        for _, value in pairs(data) do
            add_text(value)
        end
    end
end
--frame.ScrollBox.editBox:SetCursorPosition(1)
--frame.ScrollBox.ScrollBar:ScrollToEnd()


--Convierte un texto de formato de Blizzard (%s, %d, %1$s...) en un patrón Lua de búsqueda.
--Escapa todos los caracteres mágicos, incluidos %, ] y $ (antes "100%" daba un patrón inválido).
function WoWTools_TextMixin:Magic(text)
    if type(text)~='string' then
        return text
    end
    local specs= {}
    text= text:gsub('%%%%', '\3')--"%%" literal
    text= text:gsub('%%%d*%$?[sd]', function(spec)
        specs[#specs+1]= spec:sub(-1)=='d' and '(%d+)' or '(.-)'
        return '\1'..#specs..'\2'
    end)
    text= text:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', '%%%0')
    text= text:gsub('\1(%d+)\2', function(index)
        return specs[tonumber(index)]
    end)
    return (text:gsub('\3', '%%%%'))
end



function WoWTools_TextMixin:Vstr(text)
    if type(text)~='string' then
        return text
    end

    text= self:CN(text)
    if (select(2, text:gsub("[^\128-\193]", "")) == #text) then
        return text:gsub(".", "%1|n")
    else
        return text:gsub("([%z\1-\127\194-\244][\128-\191]*)", "%1|n")
    end
end




function WoWTools_TextMixin:CN(text, tab)--{gossipOptionID=, questID=}
    return text
end


function WoWTools_TextMixin:sub(text, size, letterSize, lower)
    if not canaccessvalue(text)
        or type(text)~='string'
        or text==''
        or not size
        or size==0
    then
        return text
    end

    text= self:CN(text)

    if not text:find("[\228-\233][\128-\191][\128-\191]") then
        --Cortar por caracteres UTF-8, no por bytes: antes partía letras con acento (á, ñ...)
        local n, out= letterSize or size, {}
        for char in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
            if n<=0 then
                break
            end
            out[#out+1]= char
            n= n-1
        end
        text= table.concat(out)
        return lower and strlower(text) or text
    else
        local i, output = 1, ''
        while (size > 0) do
            local byte = text:byte(i)
            if not byte then
              return output
            end
            if byte < 128 then--ASCII byte
              output = output .. text:sub(i, i)
              size = size - 1
            elseif byte < 192 then--Continuation bytes
              output = output .. text:sub(i, i)
            elseif byte < 244 then--Start bytes
              output = output .. text:sub(i, i)
              size = size - 1
            end
            i = i + 1
        end
        while (true) do
            local byte = text:byte(i)
            if byte and byte >= 128 and byte < 192 then
                output = output .. text:sub(i, i)
            else
                break
            end
            i = i + 1
        end
        return lower and strlower(output) or output
    end
end


function WoWTools_TextMixin:GetShowHide(sh, all)
    if all then
        if sh then
            return WoWTools_L['Show/Hide (Hide gray)']
        elseif sh==false then
            return WoWTools_L['Show/Hide (Show gray)']
        else
            return WoWTools_L['Show/Hide']
        end
    elseif sh then
		return WoWTools_L.SHOW
	else
		return DISABLED_FONT_COLOR:WrapTextInColorCode(WoWTools_L.HIDE)
	end
end

function WoWTools_TextMixin:GetEnabeleDisable(ed, all)
    if all then
        if ed==nil then
            return WoWTools_L['Enable/Disable']
        elseif ed==true then
            return WoWTools_L['Enable/Disable (Disable gray)']
        else
            return WoWTools_L['Enable/Disable (Enable gray)']
        end
    else
        if ed then
            return WoWTools_L.ENABLE
        else
            return DISABLED_FONT_COLOR:WrapTextInColorCode(WoWTools_L.DISABLE)
        end
    end
end

function WoWTools_TextMixin:GetYesNo(yesno)
    if yesno then
        return WoWTools_L.YES
    else
        return DISABLED_FONT_COLOR:WrapTextInColorCode(WoWTools_L.NO)
    end
end

function WoWTools_TextMixin:CanText(text)
    if issecretvalue(text)
        or (text and
            text:find('(:?|?)|K(.-)|k')
        )
    then
        return format(WoWTools_L.EVENTTRACE_SECRET_FMT, '')
    end
end
