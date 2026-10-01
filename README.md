# WoWToolsPlus

Fork de [WoWTools](https://github.com/husandro/WoWTools) (de husandro) para World of Warcraft: Midnight,
centrado en jugadores de habla hispana e inglesa.

*English below.*

## Qué cambia respecto al original

- **Interfaz en español e inglés**: todos los textos pasan por un sistema de traducción central
  (`0_Data/0_Locale.lua`); frases en español natural en lugar de palabras sueltas pegadas.
- **Errores corregidos**: acciones automáticas que podían hacer perder objetos u oro (correo, mercader,
  subasta, misiones), errores Lua constantes y compatibilidad con Midnight 12.0 (valores secretos,
  funciones retiradas).
- **Nada automático sin permiso**: sin mensajes enviados a otros jugadores por su cuenta; las acciones con
  riesgo son opcionales y vienen desactivadas.
- **Panel de opciones ordenado**: módulos agrupados por tema y una descripción en cada opción.
- **Más ligero**: sin módulos de nicho, sin revestido de ventanas de Blizzard y sin código de depuración.
- Los mensajes del addon en el chat son opcionales (Opciones → WoWToolsPlus → General).

## Instalación

1. Descarga o clona el repositorio.
2. Copia la carpeta en `World of Warcraft/_retail_/Interface/AddOns/` con el nombre **`WoWToolsPlus`**.
3. No lo actives junto al WoWTools original: usan el mismo código interno. Los ajustes sí están separados.

## Comandos

- `/wtportal`: muestra el portal encontrado para cada mazmorra de Míticas+.

## Créditos y licencia

Basado en WoWTools de **husandro** (licencia MIT). Este fork mantiene la misma licencia: ver [LICENSE](LICENSE).

---

## English

Fork of [WoWTools](https://github.com/husandro/WoWTools) by husandro for World of Warcraft: Midnight,
focused on Spanish and English players.

- Full Spanish/English interface through a central translation system.
- Bug fixes: risky auto-actions (mail, merchant, auction house, quests), constant Lua errors and
  Midnight 12.0 compatibility.
- Nothing automatic without your consent: no messages sent to other players on their own; risky actions
  are opt-in.
- Organized options panel with a description on every option.
- Lighter: niche modules, Blizzard window reskinning and debug code removed.

**Install:** copy the folder into `Interface/AddOns/` as **`WoWToolsPlus`**. Do not enable it together with
the original WoWTools.

**Credits:** based on WoWTools by **husandro**, MIT license (see [LICENSE](LICENSE)).
