# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository State

**Greenfield — no code yet.** This repo currently contains only:

- `docs/AquaSense-AI-Project-Spec.md` — the build reference and single source of truth for scope, architecture, and requirements. Read it before implementing anything.
- `mockup/` — UI mockup screenshots for the operator dashboard.

There are no build, lint, or test commands yet. When the first code lands, update this file with the actual commands.

Note: this directory is not a git repository. Initialize git before starting implementation work.

## What This Project Is

AquaSense AI (repo: aquapulse) — a LoRaWAN telemetry + predictive AI platform for Philippine aquaculture. Sensor nodes on fish/shrimp enclosures report water quality (DO, pH, temp, TAN, turbidity, level); ML models forecast hypoxia events and disease risk hours ahead and can trigger automated interventions (aerators, feeders, dosing pumps).

## Architecture (from spec §3–4)

Five layers, edge → cloud, each designed to keep working locally when the layer above is unreachable — **offline resilience is a first-class requirement**:

1. **Sensing** — solar-powered ESP32 + LoRa nodes per enclosure
2. **LoRaWAN mesh** — Class A uplinks (sensors), Class C (actuators)
3. **Edge gateway** — Raspberry Pi-class; store-and-forward buffering, LoRaWAN→MQTT/HTTPS translation, edge anomaly filtering
4. **Cloud/AI** — time-series DB + four inference services (DO crash forecaster, disease risk index, anomaly/drift detector, feed optimizer), each independently deployable; federated learning across farms (raw data never leaves the farm)
5. **Application** — operator dashboard (web/mobile, offline-first with sync-on-reconnect) + closed-loop actuation

Planned components are enumerated in spec §8 (Build Scope Checklist). Data model in §4.3: enclosure registry, telemetry stream, event log, actuation log.

## Design Constraints That Shape Code Decisions

- Target users are field operators, not data scientists — dashboard output must be plain-language forecasts and recommended actions, never raw sensor dumps.
- Deployment sites have intermittent power and connectivity — every layer needs local buffering/caching; never assume a live link.
- The anomaly/drift detector exists to separate sensor faults (bio-fouling, drift) from real environmental events — false-alarm prevention is core to the product, not an add-on.
- Multi-tenant from the start: single pilot pond → multi-farm cooperative must be a config change, not a rework (spec §7).
