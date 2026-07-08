# Phase 3 — Map + Add-Pond ✅

The enclosure registry, and the first path that writes state.

## Shipped

- **Mesh map** (`lib/screens/map_screen.dart`) — enclosures as status-colored nodes placed by normalized lat/long; `CustomPaint` draws mesh lines between nearby nodes. Legend (Normal/Warning/Critical), "Showing: DO / Ammonia" pills, 50m scale, nav/filter icon buttons.
- **Field Mode panel** — cached ponds + record count, "sync Nm ago", synced-fraction progress bar, "will sync when connection restored." Fixture data (`FieldSyncStatus`); real sync is Phase 7.
- **Add-Pond sheet** (`lib/widgets/add_pond_sheet.dart`) — bottom-sheet form: name, single-select **Species** chips, size (ha), GPS (loosely parsed), notes, plus the "sensors linked via Mesh" hint. Validates name + species.
- **First mutation** — `EnclosureRepository.add()`; fixture impl is now a mutable list seeded from fixtures. Submit writes then `ref.invalidate(enclosuresProvider)`, so Map/History/Log all refresh. New enclosures show "No data" until a sensor is linked — consistent with the form's own hint.
- Wired `MapScreen` into the shell.

## Design note

No real geo-map widget: those need an online tile source (Google/Mapbox/OSM), which contradicts the offline LoRaWAN premise (ADR-0003), plus an API key. The mockup is a stylized schematic anyway, so a node graph is both lazier and more faithful.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — 7 passing (added: repository `add()` grows+finds; **full Add-Pond sheet flow** — fill name, pick species, submit, sheet closes, snackbar confirms).

## Next

Phase 4 — Mesh tab: mesh-health gauge, node latency list, aeration checklist, operator profile.
