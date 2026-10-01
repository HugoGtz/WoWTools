-- Configuración de luacheck para WoWToolsPlus (addon de WoW, Lua 5.1).
-- Objetivo: detectar fallos reales (globales creadas sin querer, negaciones
-- mal escritas, errores de sintaxis) sin el ruido de la API de WoW.
std = "lua51"
max_line_length = false
exclude_files = {"Source/Libs/**", ".git/**", "docs/**"}

-- Globales definidas en el nivel superior de un archivo (Mixins, funciones de plantillas XML...)
allow_defined_top = true

ignore = {
    "113",  -- leer una global: la API de WoW tiene miles
    "131",  -- global definida y no usada en Lua (la usan las plantillas XML o /comandos)
    "112",  -- modificar un campo de una tabla global de Blizzard
    "21.",  -- variables y argumentos sin usar
    "23.", "24.", -- variables asignadas que no se leen
    "31.", "32.", "33.", -- valores sin usar / variables que empiezan en nil (estilo del addon)
    "221",  -- variable local que nunca recibe valor (se usa como nil a propósito)
    "4..",  -- variables que ocultan a otras con el mismo nombre
    "54.",  -- bloques vacíos
    "6..",  -- espacios e indentación
}

-- Globales que el addon escribe a propósito dentro de funciones
globals = {
    -- ajustes guardados (y los nombres antiguos, solo para migrarlos)
    "WoWToolsPlusSave", "WoWToolsPlus_WoWDate", "WoWToolsPlusPlayerDate",
    "WoWToolsSave", "WoWTools_WoWDate", "WoWToolsPlayerDate",
    -- comandos de chat
    "SlashCmdList",
    -- valores de Blizzard que el addon ajusta
    "INBOXITEMS_TO_DISPLAY", "PAPERDOLL_STATCATEGORIES", "PVE_FRAME_BASE_WIDTH",
    "MountJournal_FullUpdate", "InspectGuildFrame_Update",
    -- módulos que exponen funciones para otros
    "WoWTools_GemMixin",
}
