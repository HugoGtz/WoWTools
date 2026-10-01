# Mejoras de WoWToolsPlus: funcionalidad, simplificación y rendimiento

Revisión hecha a partir de las ~700 descripciones de opciones (que salen del código), el grafo de CodeGraphContext
y los addons que usa el personaje principal (Baganator/Syndicator, SexyMap, Leatrix, Details, Plater, Raider.IO,
DBM, WeakAuras, Bartender4, AstralKeys, MDT, MRT…). Complementa a `docs/REFACTOR.md`.

## 1. Quitar todavía (sobra o es para desarrolladores)

| Qué | Por qué |
|---|---|
| **Ventana "Objetos de la banda guerrera"** (`0_Data/z_WoWItemList.lua`, 2.500 líneas; contiene la función más compleja del addon) | Syndicator/Baganator ya buscan objetos y oro en todos tus personajes |
| **Herramientas de desarrollo del botón de hipervínculos**: rastreo de eventos (/etrace mejorado y volcado de eventos al chat), /fstack, aviso y prueba de CVars | Solo sirven para programar addons |
| **Aviso de amigos de Battle.net conectados** (Lista de amigos) | El juego ya avisa cuando un amigo se conecta |
| **/guildinfo automático al conectar** (Hermandad) | Mensaje en el chat en cada inicio de sesión |
| **Bocadillos de chat** en los botones de Grupo y Susurros | Es una opción del juego (Opciones → Social) |
| **Enviar tus atributos al chat** (Atributos) | Truco poco útil |
| **Nivel de objeto en las ranuras del personaje** (Personaje) | Lo hacen SimpleItemLevel / trueItemLevel |
| **Fondos con imagen para las ventanas del addon** (restos de Texturas) | Cosmético; basta con la opacidad |
| **Textos obsoletos**: Cursor habla de la "estela", Grupo de la "rueda del ratón", Reputación/Monedas de "duelos de mascotas" | Funciones ya quitadas |

## 2. Simplificar

- **Tres "seguidores" en pantalla que son casi iguales** (Reputación, Monedas, Eventos festivos): mismo botón móvil
  con lista y las mismas opciones (crecer hacia arriba, texto a la derecha, mostrar nombre, ocultar en combate).
  → Un único componente compartido (también reduce código en el refactor).
- **Dos listas de renombre** (Guía de aventuras y Reputación). → Dejar una.
- **Barra de botones del chat con 8 botones** (Hipervínculos, Tiradas, Invitar, Grupo, Buscador, Hermandad, Susurros,
  Emotes). → Mantener solo los que usas (Invitar y Buscador, que tienen lo que quieres conservar) y que el resto sea opcional.
- **~700 opciones**: muchas son micro-ajustes de posición o de aspecto. → Valores por defecto razonables y menos casillas
  (agrupar las de diseño en un submenú "Apariencia").
- **Acciones automáticas repartidas por todo el addon** (aceptar invitaciones, invocaciones, roles, tiradas, salir de
  instancia, liberar espíritu…). → Una sola página **"Automatizaciones"** con todas, para ver de un vistazo qué hace solo el addon.

## 3. Mejorar funcionalidad

| Mejora | Detalle |
|---|---|
| **Tiempo de espera configurable** para aceptar invitaciones e invocaciones | Hoy son 3 s fijos; reutilizar el deslizador que ya existe para la comprobación de rol |
| **Abrir las opciones desde el compartimento de addons** (botón de la esquina del minimapa de Blizzard) y con `/wtp` | Al quitar el módulo Minimapa ya no hay acceso rápido |
| **Portales de Míticas+**: en el tooltip, si lo tienes y cuánto le queda de reutilización; aviso de qué portales te faltan | La información ya está, solo falta mostrarla |
| **Exportar / importar la configuración** (texto para copiar) | Para pasarla a otro PC o a otra cuenta |
| **Avisos de monedas al límite** como aviso en pantalla, no en el chat | El chat ahora está silenciado por defecto |
| **Limitar el tamaño de los datos guardados** (historial de susurros ya limitado; faltan otros registros por personaje) | Que el archivo de ajustes no crezca sin fin |

## 4. Optimizar (rendimiento)

Medido en el código:

| Problema | Cantidad | Solución |
|---|---|---|
| Funciones `OnUpdate` (se ejecutan en cada fotograma) | 49, solo 14 con límite de frecuencia | Limitar a 0,1-0,2 s o sustituir por eventos y temporizadores |
| Escaneos de bolsas en cada `BAG_UPDATE` (Comida, Abrir objetos, Usar objetos, Monedas, Míticas+, Personaje…) | 41 manejadores | **Un único escaneo compartido** tras `BAG_UPDATE_DELAYED`, del que leen todos |
| Cada módulo con su propio marco de eventos | 48 | Un solo despachador (forma parte de R1 del refactor) |
| Módulos de ventanas de Blizzard que se preparan al entrar al juego | varios | Prepararlos solo al abrir esa ventana (campo `blizzard` de R1) |

Para medirlo antes y después: el perfilador de addons del juego (`C_AddOnProfiler`) da el uso de CPU por addon;
un comando `/wtp perf` puede mostrarlo.

## Orden propuesto

1. **Quitar** lo de la sección 1 (rápido y reduce código antes del refactor).
2. **Refactor R1** (API de módulos) incluyendo el despachador único y el escaneo de bolsas compartido.
3. **Simplificar** (sección 2) a medida que se migran los módulos en R2.
4. **Mejoras de funcionalidad** (sección 3), empezando por el tiempo de espera configurable y el acceso a opciones.

## 5. Visual: estilo "minimalista oscuro"

Elegido por el usuario. Mismo aspecto para todo lo que dibuja el addon (barras, menús propios, seguidores, Míticas+).

### Reglas del estilo (`WoWTools_Style`, archivo `1_Mixin/Style.lua`)

| Elemento | Regla |
|---|---|
| Fondo de panel | Negro plano al 70 % (cabeceras al 85 %), sin texturas de Blizzard |
| Borde | 1 px, blanco al 10 %; color de acento al 60 % al pasar el ratón o si está activo |
| Color de acento | Color de tu clase (opción: personalizado) |
| Texto | Fuentes de Blizzard (`GameFontHighlight`/`GameFontNormal`) que respetan la escala de la interfaz; sombra de 1 px en lugar de contorno grueso |
| Iconos | Recorte 8 % y máscara redondeada (como las barras de acción), tamaño fijo por contexto (16 / 20 / 32) |
| Espaciado | Rejilla de 4 px; filas de 20 px |
| Botones | Planos: icono o texto, sin los botones rojos de Blizzard en las ventanas propias |
| Estados | Pasar el ratón: fila iluminada con el acento al 15 %; desactivado: 40 % de opacidad |

Funciones del estilo: `Style:Panel(frame)`, `Style:Header(frame, title)`, `Style:Row(button)`, `Style:Icon(texture)`,
`Style:Button(button)`, `Style:Text(fontString, size)`.

### Dónde se aplica

1. ✅ **Fuente forzada**: quitar el 12 px con contorno grueso de `1_Mixin/Label.lua` y usar `Style:Text`.
2. ✅ **Barras flotantes**: barra del chat y de Herramientas con `Style:IconButton` y botones de especialización (la activa con el borde de acento).
3. **Seguidores** (Reputación, Monedas, Eventos festivos): un único componente con el estilo (ver sección 2).
4. **Míticas+**: información compacta por mazmorra (nivel y puntuación); el detalle, al pasar el ratón; paneles laterales
   con `Style:Panel` y sin solaparse con Raider.IO.
5. **Panel de opciones**: nombres sin iconos pegados al texto.

Se hace junto al refactor: cada módulo que se migra a la API nueva (R2) se pasa al estilo común.
