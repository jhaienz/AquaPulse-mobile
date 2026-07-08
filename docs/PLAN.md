# AquaSense AI — Phase Plan

MVP build plan. Decisions behind each phase live in `docs/adr/`; vocabulary in `CONTEXT.md`. Screens first (Flutter against fixtures), then wire the FastAPI Gateway behind the repository seam (ADR-0004).

Status: `[ ]` todo · `[~]` in progress · `[x]` done

---

## Phase 0 — App shell  `[x]`

Foundation every screen sits in.

- [x] Flutter project + git init
- [x] Theme tokens (figma dark palette: navy/teal base; green=normal, amber=warning, red=critical)
- [x] 5-tab bottom nav (Log · History · Mesh · Map · Settings) via `IndexedStack`
- [x] Riverpod wired
- [x] Repository interfaces (`EnclosureRepository`, `TelemetryRepository`, `ForecastRepository`) + fixture implementations
- [x] Placeholder screen per tab (History wired to fixtures as seam proof)

## Phase 1 — Log tab  `[x]`

The headline. Field Log + hero Forecast card.

- [x] Field Log entry (note, photo placeholder, status tags: DO/pH/Turbidity/Temp)
- [x] Forecast card — "Hypoxia likely in Nh", DO trend chart (history solid + forecast dashed), threshold line, recommended-action button
- [x] Forecast reads Species Profile threshold (ADR-0005), served via fixtures for now
- Photo capture + live actuation deferred (snackbar stubs); real clock in header deferred

## Phase 2 — History tab  `[x]`

- [x] Telemetry list — per-enclosure DO/pH/temp + status pill + timestamp, All/Today/Week filter
- [x] Achievements grid (badges, earned count) — model from mockup
- Filter windows overlap over latest-only fixtures; bite once real time-series exists

## Phase 3 — Map + Add-Pond  `[ ]`

Enclosure registry — forecasts need enclosures to attach to.

- [ ] Map — spatial enclosure layout, status colors, DO/Ammonia filter, Field Mode sync banner
- [ ] Add-Pond form — name, **Species** select (Tilapia/Bangus/Shrimp/Crab/Milkfish), size (ha), GPS, notes
- [ ] Seeded Species Profile table (ADR-0005)

## Phase 4 — Mesh tab  `[ ]`

- [ ] Mesh health gauge + node latency/status list
- [ ] Aeration checklist (checkable, persisted locally)
- [ ] Operator profile + stats (entries/badges/streak)

## Phase 5 — Settings  `[ ]`

- [ ] Toggles (Edge AI, Mesh Auto-Sync, Night Mode, Push, Haptics)
- [ ] Alerts inbox — critical/warning, acknowledged/unacknowledged

## Phase 6 — Backend (FastAPI on Gateway)  `[ ]`

- [ ] FastAPI service: enclosure registry, telemetry store, forecast endpoint
- [ ] Simulator — synthetic diurnal DO/temp telemetry, injectable crashes
- [ ] Statistical DO-crash forecaster behind the seam (ADR-0002)
- [ ] Swap Flutter fixture repositories → HTTP-against-Gateway

## Phase 7 — Field Mode  `[ ]`

- [ ] Local cache (on-device DB) — last telemetry + last forecast
- [ ] Sync-on-reconnect, queued operator actions
- [ ] "Cached · N records · sync Nm ago" status wired to real sync state

---

Out of MVP (spec features that bolt on later): disease risk index, anomaly/drift detector, feed optimizer, federated learning, closed-loop actuation, multi-farm tenancy, real ML forecaster, real LoRa hardware.
