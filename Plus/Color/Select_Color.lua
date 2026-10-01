--Paletas rápidas alrededor del selector de colores.
--Estilo común (WoWTools_Style): cada grupo de muestras va en un panel propio oscuro con cabecera,
--las muestras son iconos con máscara redondeada y al pasar el ratón se marca con el color de acento.

local Style= WoWTools_Style
local GAP= Style.Size.gap--separación entre muestras
local PAD= Style.Size.pad
local TOP= Style.Size.header + PAD--el contenido empieza debajo de la cabecera

local SIZE_CLASS= Style.Size.icon.normal--20 (antes 23)
local SIZE_COLOR= Style.Size.icon.small--16

local Panels={}





local function Set_Color(r, g, b, a)--, textCode)
    if r and g and b then
        ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
        ColorPickerFrame.Content.ColorPicker:SetColorAlpha(a or 1)
    end
end




--Panel propio del addon (hijo del marco de mejoras: se oculta y escala con él)
local function Get_Panel(name, title)
    local panel= Panels[name]
    if not panel then
        panel= CreateFrame('Frame', nil, _G['WoWToolsColorPickerFrameButton'].frame)
        panel:EnableMouse(true)--un clic en el hueco entre muestras no cuenta como "fuera del selector"
        Style:Panel(panel)
        Style:Header(panel, title)
        Panels[name]= panel
    end
    return panel
end


--Tamaño del panel a partir de la rejilla de su contenido
local function Set_PanelSize(panel, cols, rows, size)
    cols, rows= math.max(cols, 1), math.max(rows, 1)
    panel:SetSize(
        PAD*2 + cols*(size+GAP) - GAP,
        TOP + PAD + rows*(size+GAP) - GAP
    )
end


--Coloca la muestra en la celda (col, row) del panel, empezando en 0
local function Set_Cell(texture, panel, col, row, size)
    texture:ClearAllPoints()
    texture:SetPoint('TOPLEFT', panel, 'TOPLEFT', PAD + col*(size+GAP), -(TOP + row*(size+GAP)))
end




local function Create_Texture(r,g,b,a, atlas, parent, iconSize)
	local texture= (parent or _G['WoWToolsColorPickerFrameButton'].frame):CreateTexture(nil, 'ARTWORK')
	texture:SetSize(iconSize or SIZE_COLOR, iconSize or SIZE_COLOR)
	texture:EnableMouse(true)

    a=a or 1
	texture.r, texture.g, texture.b, texture.a= r, g, b, a

	texture:SetScript('OnMouseDown', function(self, d)
        if d~=self.notClick then
		    Set_Color(self.r, self.g, self.b, 1)--, self.textCode)
        end
		self:SetAlpha(0.1)
	end)

	texture:SetScript('OnMouseUp', function(self)
        self:SetAlpha(0.7)
    end)
	texture:SetScript('OnEnter', function(self)
		local col= '|c'..WoWTools_ColorMixin:RGBtoHEX(self.r or 1, self.g or 1, self.b or 1, self.a or 1)
		GameTooltip:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT")
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(col..WoWTools_DataMixin.addName, col..WoWTools_ColorMixin.addName)

		GameTooltip:AddDoubleLine(
            '|cffff4800r|r|cffffffff=|r'..tonumber(format('%.2f',self.r))
            ..'  |cff00ff00g|r|cffffffff=|r'..tonumber(format('%.2f',self.g))
            ..'  |cff0000ffb|r|cffffffff=|r'..tonumber(format('%.2f',self.b)),

            'a'..(self.a and tonumber(format('%.2f',self.a) or 1))
            ..(self.a and self.a<1 and '|cnGREEN_FONT_COLOR: / 1|r' or '')
        )
        if self.textCode then
            GameTooltip:AddLine(self.textCode)
        end
        if self.tooltip then
            if type(self.tooltip)=='function' then
                self.tooltip(self)
            else
                GameTooltip:AddLine(' ')
                GameTooltip:AddLine(self.tooltip)
            end
		end
		GameTooltip:Show()
		self:SetAlpha(0.7)
        Style:Outline(self)
	end)
	texture:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
        Style:Outline(nil)
    end)

	if atlas then
		texture:SetAtlas(atlas)
	else
        texture:SetColorTexture(r, g, b)
	end

    Style:Icon(texture)--máscara redondeada (con atlas no recorta)
	return texture
end






--Panel derecho: clases, calidades de objeto y colores compartidos de Blizzard (columnas)
local function Init_Right(colorTab)
    local panel= Get_Panel('right', WoWTools_L['Color.Palettes'])
    panel:SetPoint('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', PAD, 0)

    local x= 0--ancho ocupado hasta ahora
    local maxH= 0

    --Coloca una lista de colores en columnas de "perCol" filas, a partir de x
    local function Add_Group(list, size, perCol)
        local n= 0
        for _, info in ipairs(list) do
            local texture= Create_Texture(info.r, info.g, info.b, info.a, info.atlas, panel, size)
            texture.tooltip= info.tooltip
            if info.quality then
                texture.quality= info.quality
                texture:SetScript('OnShow', function(self)
                    WoWTools_ItemMixin:GetColor(self.quality, {texture=self})
                end)
            end
            texture:ClearAllPoints()
            texture:SetPoint('TOPLEFT', panel, 'TOPLEFT',
                PAD + x + math.floor(n/perCol)*(size+GAP),
                -(TOP + (n%perCol)*(size+GAP))
            )
            n= n+1
        end
        if n>0 then
            local cols= math.ceil(n/perCol)
            local rows= math.min(n, perCol)
            x= x + cols*(size+GAP)
            maxH= math.max(maxH, rows*(size+GAP))
        end
    end

--Clases
    local list={}
    for index = 1, GetNumClasses() do
        if (index == 10) and (GetClassicExpansionLevel() <= LE_EXPANSION_CATACLYSM) then
            -- We have an annoying gap between warlock and druid
            index = 11
        end
        local classFile = select(2, GetClassInfo(index))
        if classFile then
            local r, g, b= GetClassColor(classFile)
            if r and g and b then
                colorTab[r..g..b..'1']= true
                table.insert(list, {
                    r=r, g=g, b=b, a=1,
                    atlas= WoWTools_UnitMixin:GetClassIcon(nil, nil, classFile, {reAtlas=true}),
                    tooltip= RAID_CLASS_COLORS[classFile] and 'RAID_CLASS_COLORS["'..classFile..'"]' or nil,
                })
            end
        end
    end
    Add_Group(list, SIZE_CLASS, 7)

--Calidades
    list={}
    for index = 0, Enum.ItemQualityMeta.NumValues - 1 do
        local color= WoWTools_ItemMixin:GetColor(index)
        local r,g,b= color:GetRGB()
        colorTab[r..g..b..1]= true
        table.insert(list, {
            r=r, g=g, b=b, a=1,
            tooltip= (WoWTools_ItemMixin.QualityText[index] or '')..'|nITEM_QUALITY' ..index.. '_DESC',
            quality= index,
        })
    end
    Add_Group(list, SIZE_COLOR, 10)

--SharedColorConstants.lua
    list={}
    local function Add_Table(tab, tabName, isIndex)
        for name, c in pairs(tab or {}) do
            if not isIndex or type(name)~='number' then
                local text= c.r..c.g..c.b.. (c.a or 1)
                if not colorTab[text] then
                    colorTab[text]= true
                    table.insert(list, {
                        r=c.r, g=c.g, b=c.b, a=c.a,
                        tooltip= tabName..(isIndex~=nil and '["'..name..'"]' or '['..name..']'),
                    })
                end
            end
        end
    end
    Add_Table(MATERIAL_TEXT_COLOR_TABLE, 'MATERIAL_TEXT_COLOR_TABLE', false)
    Add_Table(MATERIAL_TITLETEXT_COLOR_TABLE, 'MATERIAL_TITLETEXT_COLOR_TABLE', false)
    Add_Table(COVENANT_COLORS, 'COVENANT_COLORS', true)
    Add_Table(PLAYER_FACTION_COLORS, 'PLAYER_FACTION_COLORS', nil)
    Add_Group(list, SIZE_COLOR, 10)

    panel:SetSize(PAD*2 + x - GAP, TOP + PAD + maxH - GAP)
end




--Panel superior: colores de la interfaz (C_UIColor) y, opcional, la paleta extra 6x6x6
local function Init_Top(colorTab)
    local panel= Get_Panel('top', WoWTools_L['Color.UIColors'])
    panel:SetPoint('BOTTOM', ColorPickerFrame.Header, 'TOP', 0, PAD)

    local size= SIZE_COLOR
    local row= 0
    local maxCols= 0

--Paleta extra (Más colores): 216 colores, 24 por fila
	if WoWTools_ColorMixin:Save().selectType2 then
        local n= 0
		for r=0, 1, 0.2 do
			for g=0, 1, 0.2 do
				for b=0, 1, 0.2 do
					local texture= Create_Texture(r, g, b, nil, nil, panel, size)
                    Set_Cell(texture, panel, n%24, row + math.floor(n/24), size)
                    n= n+1
				end
			end
		end
        row= row + math.ceil(n/24)
        maxCols= 24
	end

--Color.lua: hasta 6 filas de 20
    local DBColors = C_UIColor.GetColors() or {}
    table.sort(DBColors, function(a,b)
        return a.color.r> b.color.r
    end)
    local n= 0
    for _, dbColor in ipairs(DBColors) do
        local text= dbColor.color.r.. dbColor.color.g.. dbColor.color.b.. (dbColor.color.a or 1)
        if not colorTab[text] then
            colorTab[text]= true
            local texture= Create_Texture(dbColor.color.r, dbColor.color.g, dbColor.color.b, dbColor.color.a, nil, panel, size)
            texture.textCode= dbColor.baseTag
            Set_Cell(texture, panel, n%20, row + math.floor(n/20), size)
            n= n+1
            if n>=120 then
                break
            end
        end
    end
    if n>0 then
        row= row + math.ceil(n/20)
        maxCols= math.max(maxCols, math.min(n, 20))
    end

    Set_PanelSize(panel, maxCols, row, size)
    panel:SetShown(row>0)
end




local function Init()
    local colorTab={}
    Init_Right(colorTab)
    Init_Top(colorTab)
    colorTab=nil
    Init=function()end
end













function WoWTools_ColorMixin:Init_SelectColor()
    Init()
end




--parent e iconSize son opcionales (por defecto: marco de mejoras y 16 px)
function WoWTools_ColorMixin:Create_Texture(...)
    return Create_Texture(...)
end


--Panel con el estilo común: name= 'right' | 'top' | 'log' (se crea la primera vez)
function WoWTools_ColorMixin:Get_Panel(name, title)
    return Get_Panel(name, title)
end


function WoWTools_ColorMixin:Set_PanelSize(...)
    Set_PanelSize(...)
end

function WoWTools_ColorMixin:Set_Cell(...)
    Set_Cell(...)
end
