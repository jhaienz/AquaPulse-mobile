# Flutter app: Riverpod + repository seam, built against fixtures first

The Flutter app uses Riverpod for state (five tabs share enclosure/telemetry/alert state). Screens read from repository interfaces (`EnclosureRepository`, `TelemetryRepository`, etc.), never from HTTP directly.

We build screens first, so those repositories return hardcoded Dart fixtures initially. Wiring the real Gateway (FastAPI over LAN, ADR-0003) means swapping the repository implementation to an HTTP-backed one — screens and providers stay untouched. Same seam philosophy as the forecaster (ADR-0002).

This is why the app ships with fixture data early: it's the deliberate "screens first" build order, not leftover scaffolding.
