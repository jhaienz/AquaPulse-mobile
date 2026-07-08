# Phase 4 — Mesh Tab ✅

Network health, node status, maintenance checklist, operator profile.

## Shipped

- **Mesh health gauge** (`lib/widgets/gauge.dart`) — `CustomPaint` 270° arc, value arc colored green/amber/red by health (92% → green), center percentage + label.
- **Node grid** — 3-wide cards, per-node latency (`12ms`) and online/offline dot; offline node (D-1) shows `—` in red, matching the mockup.
- **Aeration checklist** — tappable rows, check + strikethrough, live `done/total` counter. Screen-local state (`ConsumerStatefulWidget`); `IndexedStack` keeps toggles across tab switches. Durable-across-restart persistence is Phase 7.
- **Operator card** — avatar initials, name/ID/role, and Entries / Badges / Streak stat tiles.
- **Models + seam** — `MeshNode`, `ChecklistItem` (with `toggled()`), `Operator`; read-only providers for nodes/health/operator.
- Wired `MeshScreen` into the shell.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — 8 passing (added: Mesh renders gauge/nodes/operator + **checklist toggle moves 2/5 → 3/5**). Test uses a tall surface so the full scroll body renders.

## Next

Phase 5 — Settings: preference toggles + the alerts inbox (acknowledged/unacknowledged).
