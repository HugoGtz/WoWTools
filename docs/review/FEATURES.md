# Auditoría de funciones: qué sobra

Análisis con el grafo de CodeGraphContext (15.950 llamadas entre 4.936 funciones), búsqueda de referencias
y las descripciones de cada opción (tooltips). Nada se ha borrado todavía.

## 1. Código muerto (quitar sin riesgo)

| Qué | Tamaño | Veredicto |
|---|---|---|
| Archivos que el .toc no carga (`.bak/`, `ChatButton/C3_Marker_bak/`, 4 sueltos en Target, Challenge, Unit, Plus_Tooltip) | 19 archivos, 4.409 líneas | **Quitar** |
| Bloques comentados `--[[ ... ]]` | 6.017 líneas | **Quitar** (quedan en el historial de git) |
| Funciones sin ninguna referencia | ~40 (p. ej. `IsRussianLetters`, `RGB_to_HSV`, `e.Is_Chinese_Text`, varias de `ItemLocation`) | **Quitar** |
| Código solo para el autor (`WoWTools_DataMixin.Player.husandro`: prints de depuración, `SetConsoleKey("F9")`, `Plus/Challenge/z_Is_HuSandro.lua`, `Is_Sandro` en Mail) | 197 referencias | **Quitar** |

## 2. Módulos y funciones de poco valor fuera de China

| Módulo | Motivo | Veredicto |
|---|---|---|
| Chat → Canal de mundo | Pensado para el canal «大脚世界频道» del addon chino BigFoot; en EU/US no existe esa convención | **Quitar** |
| Chat → Emojis | Sustituye `{Angel}` por iconos solo en tu pantalla; los demás ven el texto salvo que usen el mismo addon | **Quitar** o dejar desactivado |
| Integración con WoWTools_Chinese / Scanner | Solo para la traducción china del cliente | Mantener inerte (no carga si no está) |

## 3. Nicho u obsoleto

| Función | Motivo | Veredicto |
|---|---|---|
| Otros → Semillas latentes | Contenido de Dragonflight 10.2 (Sueño Esmeralda) | **Quitar** |
| Herramientas → Daisy | Botón para una sola mascota concreta | **Quitar** |
| Herramientas → Elixir de Tragonublo | Botón para un único consumible de broma | **Quitar** |
| Otros → Carnero de la Fiesta de la Cerveza | Evento de temporada, dos semanas al año | Mantener (desactivado por defecto) |
| Otros → Inspector de marcos (/fstack) | Herramienta de desarrollo | Mantener solo si desarrollas; si no, **quitar** |
| Chat → Bienvenida al grupo/hermandad | Envía mensajes automáticos a otros jugadores | Mantener desactivado (ya lo está) |

## 4. Redundante con Blizzard (verificar en juego)

| Función | Qué ya trae el juego | Veredicto |
|---|---|---|
| Otros → Ocultar tutoriales | Opción «Tutoriales» en Opciones → Juego | Poco valor; mantener |
| Selector de color | El selector de Blizzard ya tiene campo hexadecimal | Parcialmente redundante; mantener si usas historial/paletas |
| Minimapa → recoger iconos de addons | Compartimento de addons de Blizzard (desde 10.1) | Parcialmente redundante |
| Mover marcos | El modo edición mueve muchos marcos, pero no ventanas como bolsas, correo, subasta… | **Mantener** (hace lo que el modo edición no hace) |
| Chat → Información de combate | Midnight trae medidor de daño propio y muchos datos de combate son secretos | Revisar en juego; probable **quitar** |

## 5. Riesgo de taint / roto por Midnight

| Función | Motivo | Veredicto |
|---|---|---|
| Texturas (8.000 líneas) | Tiñe cientos de marcos de Blizzard; mucha superficie de taint y se rompe con cada cambio de UI | Cosmético: mantener desactivable, **no ampliar** |
| Otros → Menú de clase | Engancha `MenuUtil.SetElementText` en TODOS los menús del juego por un color | **Quitar** o limitar a menús propios |
| Reemplazos de funciones de Blizzard (`PaperDollFrame_SetAttackSpeed`, `InspectGuildFrame_Update`, `FCF_GetNextOpenChatWindowIndex`, `LFDQueueFrameSpecificList_InitButton`) | Sustituyen funciones globales: riesgo de «acción bloqueada» | Pasar a hooks o quitar |
| Objetivo (indicadores sobre placas de nombre), Marcos de unidad, Atributos, cursor GCD | Datos de unidad/combate secretos en 12.0 | Ya protegidos en fases 2-4; verificar en juego |

## 6. Núcleo que vale la pena (mantener)
Tooltips, Información de objetos, Bolsas, Banco, Banco de hermandad, Mercader, Correo, Casa de subastas,
Mapa del mundo, Míticas+, Guía de aventuras, Personaje, Colecciones, Reputación, Monedas, Profesiones,
Engarce de gemas, Macros, Vivienda, Rastreador de objetivos, Micromenú, Lista de amigos, Batallas de
mascotas, Establo de cazador, Eventos festivos, Minimapa, Gestor de addons, Logros, Desguazadora,
Diálogos y misiones, Herramientas (monturas, piedras de hogar, juguetes, comida, abrir objetos, portales),
Copiar chat, Tiradas, Invitaciones, Susurros, Herramienta de marcas.
