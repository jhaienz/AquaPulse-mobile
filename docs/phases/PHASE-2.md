# Phase 2 — History Tab ✅

Telemetry list gains filters, and the gamification layer lands.

## Shipped

- **Filter chips** — All / Today / Week, screen-local state (`ConsumerStatefulWidget`, no global provider needed). `TelemetryFilter.includes()` windows readings by timestamp.
- **Telemetry list** — restructured into a scrollable section: per-enclosure DO/pH/temp, status pill (green/amber/red from the species profile), timestamp. Empty-window message when a filter excludes everything.
- **Achievements grid** (`lib/models/achievement.dart`) — 4-wide badge grid, earned vs. locked styling (opacity + color), "9 / 12 earned" header. 12 fixture badges.
- **Seam** — `AchievementRepository` + fixture impl + `achievementsProvider`.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — 5 passing (added: History renders filter chips + "9 / 12 earned" + a badge label).

## Known limitation (deliberate)

Over latest-per-enclosure fixtures the Today/Week windows overlap All (every reading is "today"). The filter is real and will bite once the backend serves time-series history — no fake multi-day data manufactured just to demo it.

## Next

Phase 3 — Map + Add-Pond: enclosure map, Field Mode sync banner, Add-Pond form with species select + seeded Species Profile table.
