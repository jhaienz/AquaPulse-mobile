# Phase 0 — App Shell ✅

Foundation the whole Flutter app sits in. Screens-first build (ADR-0004): UI against fixtures now, swap to the FastAPI Gateway later behind the repository seam.

## Shipped

- **Flutter project** (`aquapulse`, org `com.aquasense`, platforms android/ios/web), git initialized.
- **Theme tokens** (`lib/theme.dart`) — figma dark palette (navy/teal) + status colors (green=normal, amber=warning, red=critical) + `EnclosureStatus` enum.
- **Domain models** (`lib/models/`):
  - `Enclosure` — code term always `Enclosure`, UI shows "Pond".
  - `Species` + seeded `SpeciesProfile` table — safe ranges per species (ADR-0005); single source for status coloring and forecast threshold.
  - `TelemetryReading`, `Forecast` (+ `ForecastPoint` for the trend chart).
  - `statusFromDo()` — derives status from a DO reading against the species profile.
- **Repository seam** (`lib/repositories/`) — `EnclosureRepository`, `TelemetryRepository`, `ForecastRepository` interfaces + fixture implementations + Riverpod providers. Going live = swap one provider override.
- **Navigation shell** (`lib/screens/`) — 5-tab bottom nav via `IndexedStack` (Log · History · Mesh · Map · Settings), 4 placeholders, **History wired to fixtures** as end-to-end seam proof (6 ponds, real per-species status).

## Verification

- `flutter analyze` — no issues.
- `flutter test` — 2 passing: `statusFromDo` unit test (normal/warning/critical vs Tilapia profile) + widget test (shell renders 5 tabs, History shows fixture data with correct CRITICAL status for C-2 at DO 2.8).

## Decisions in play

ADR-0001 (software MVP), 0002 (statistical forecaster seam), 0003 (Gateway over LAN), 0004 (Flutter+Riverpod+fixtures), 0005 (species-driven thresholds).

## Next

Phase 1 — Log tab: Field Log + hero Forecast card with DO trend chart.
