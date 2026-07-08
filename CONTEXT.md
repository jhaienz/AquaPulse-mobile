# AquaSense AI

Domain glossary for the AquaSense AI aquaculture telemetry + forecasting platform. Definitions only — no implementation. See `docs/AquaSense-AI-Project-Spec.md` for the full product vision.

## Language

**Enclosure**:
A single farmed body of water (pond, cage, raceway, or tank) that is monitored as one unit. The atomic thing telemetry and forecasts attach to. **In code and the domain model this is always `Enclosure`; the UI displays the label "Pond"** because that's the operators' word (mockup + figma). One-way label mapping at the presentation layer only.
_Avoid_: Pond in code (UI-label only), tank, cage, site

**Telemetry**:
A timestamped water-quality reading from one enclosure for one parameter (DO, pH, temp, TAN, turbidity, level), carrying a sensor-health flag.
_Avoid_: Data point, measurement, sample

**Simulator**:
The MVP stand-in for real hardware. Generates synthetic telemetry with realistic diurnal patterns in place of physical LoRa sensor nodes. Plugs in at the gateway→cloud seam.
_Avoid_: Mock, fake, stub

**DO**:
Dissolved oxygen. The headline water-quality parameter; a crash (hypoxia) kills stock. The primary thing the MVP forecasts.
_Avoid_: Oxygen, O2

**DO Crash**:
A hypoxic event — DO falling below the safe threshold for stock survival. The event the MVP forecasts hours ahead.
_Avoid_: Hypoxia (use in prose, but "DO crash" is the canonical term), fish kill

**Forecast**:
A prediction that a DO crash will (or won't) occur within the horizon, expressed as time-to-threshold plus a plain-language recommended action. Distinct from a live reading.
_Avoid_: Prediction, alert (an alert is what a forecast becomes once it crosses a threshold)

**Gateway**:
The on-site Raspberry Pi-class box running the FastAPI backend on the local farm LAN. Holds the telemetry store, runs the forecaster, serves the app. Reachable by the phone over farm wifi even when the internet is down. In the MVP, the Simulator runs here too.
_Avoid_: Server, cloud, backend (the gateway IS the backend, but call it "gateway" for the on-site box)

**Edge AI**:
Inference running on the on-site Gateway, not on an internet server and not literally on the phone. The mockup's "on-device inference, no cloud" toggle refers to this — "no cloud" means no *internet* dependency, not no server.
_Avoid_: On-device (misleading — it's on the gateway, not the phone), cloud AI

**Field Mode**:
The app operating against its local cache when the Gateway is unreachable — showing last-known telemetry and the last Forecast, queuing operator actions, syncing when the connection returns.
_Avoid_: Offline mode, airplane mode

**Species**:
The stock in an enclosure (Tilapia, Bangus, Shrimp, Crab, Milkfish). Chosen at Add-Pond. Every enclosure has exactly one.
_Avoid_: Stock type, fish type

**Species Profile**:
The seeded safe-range table for a species — DO min, pH range, temp range, TAN max. The single source of truth for both status coloring (normal/warning/critical) and the DO-crash forecast threshold. Fixed config in the MVP, not user-editable; values are a tunable calibration knob, not magic constants.
_Avoid_: Threshold config, limits
