# Phase 5 — Settings ✅

Preference toggles + the alerts inbox. Completes the screens-first frontend — all five tabs are now real.

## Shipped

- **Preference toggles** (`lib/screens/settings_screen.dart`) — Edge AI Processing, Mesh Auto-Sync, Night Mode, Push Notifications, Haptic Feedback, each with title + subtitle from the mockup, in a single grouped card. Screen-local state (disk persistence is Phase 7).
- **Alerts inbox** — severity-colored cards (left border), "CRITICAL/WARNING · Pond X", message, time, and an UNACKNOWLEDGED badge. All / Critical / Warning filter. **Tap an unacknowledged alert to acknowledge it** (fades + drops the badge), tracked locally over the fixture-provided list.
- **Seam** — `AlertRepository` + fixture impl + `alertsProvider`.
- **Cleanup** — deleted `placeholder_screen.dart`; every tab now has a real screen.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — 9 passing (added: Settings renders toggles + inbox, **acknowledge drops UNACKNOWLEDGED count 2 → 1**, Warning filter hides critical alerts).

## Frontend status

Screens-first UI (Phases 0–5) complete: Log, History, Mesh, Map, Settings — all reading the repository seam, backed by fixtures. Next phase brings the backend and flips the seam from fixtures to HTTP.

## Next

Phase 6 — Backend: FastAPI on the Gateway, telemetry simulator, statistical DO-crash forecaster (ADR-0002), and swapping the Flutter fixture repositories for HTTP implementations.
