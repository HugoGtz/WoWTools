# Plan de arreglos WoWTools (fork HugoGtz)

Informes detallados: `review_A_core.md`, `review_B_plus1.md`, `review_C_plus2.md`, `review_D_chat_tools.md`.

## Fase 0 — Poder ver los errores
- [ ] Z_Other/HelpTip.lua:64 — deja de ocultar `ScriptErrorsFrame`
- [ ] Plus/Gossip/StaticPopupDialogs.lua:22 — no cerrar ADDON_ACTION_FORBIDDEN / no tocar StaticPopupDialogs

## Fase 1 — Pérdida de objetos / oro / molestias a otros jugadores
- [ ] Plus/Mail/A_InBox.lua:59 — borra cartas con objetos sin confirmar
- [ ] Plus/Merchant/SellJunk.lua:168 — vende BoP antiguo aunque autovender esté apagado
- [ ] Plus/AuctionHouse/C_AllAuctionsList.lua:218 — cancelar subasta con doble clic / botón cancela otra
- [ ] Plus/AuctionHouse/A_BrowseResultsFrame.lua:419 — compra con doble clic, oculta StaticPopup1
- [ ] Plus/AuctionHouse/B_Sell_Other.lua:369 — oculta objeto para siempre al borrar precio
- [ ] Plus/Gossip/Quest.lua:571 — autoentrega misiones que cuestan oro/objetos
- [ ] Plus/Gossip/Gossip.lua:784 / :961 — autoselección peligrosa, cierra NPC de solo misiones
- [ ] Plus/Gossip/Gossip_Delves.lua:260 — entra sola a la profundidad
- [ ] ChatButton/C1_HyperLink/z_Welcome.lua:21,30 — susurra "Hi" a todos
- [ ] ChatButton/C5_LFD/Roll.lua:116 — Necesidad en objetos que no sirven
- [ ] ChatButton/C5_LFD/Exit_Instance.lua:111 — expulsión no cancelable
- [ ] Tools/B3_OpenItems/4_Get_Item.lua:144 — liga BoE / mueve a banco
- [ ] Container/Bag/Container_Menu.lua:340 — "desactivar todo" activa todo
- [ ] Z_Other/DELETE.lua — autocompletar DELETE por defecto → off

## Fase 2 — Errores Lua constantes / Midnight 12.0
- [ ] ChatButton/C1_HyperLink/z_Link_Icon.lua:585 — se tragan mensajes secretos/BNet
- [ ] Plus/Faction/z_CHAT_MSG.lua:135 — sobrescribe global de Blizzard, error por reputación
- [ ] Plus/Attributes/Speed_Vehicle.lua:40 — speedtext → speedText
- [ ] Plus/Gossip/1_Init.lua:146 — set_Point → set_point
- [ ] Container/Bag/DeleteItem.lua:359 — falta `or`
- [ ] 1_Mixin/Frame.lua:10,79 — guardas de combate rotas
- [ ] Filtros de chat sin canaccessvalue (10_Emoji, C6_World/Filter, C9_Say)
- [ ] Plus_Move/1_Init.lua:193 — referencia cíclica en SavedVariables
- [ ] Plus_Move/z_Events.lua:827 — CompactRaidFrameManager sin combate
- [ ] Defaults de SavedVariables no se fusionan (varios 0_Init/1_Init)

## Fase 3 — Localización es/en
- [ ] Sistema `Locales/` (enUS, esES, esMX) sustituyendo literales
- [ ] Textos chinos sin alternativa (~15 reales)
- [ ] ~100 literales en inglés
- [ ] ~390 usos de CLUB_FINDER_LOOKING_FOR_CLASS_SPEC como pegamento
- [ ] MK() escala china; Text:sub corta UTF-8; Realm.lua ES/US

## Fase 4 — Lógica media y pulido UI
- Ver secciones Medio/Bajo/UI de cada informe.
