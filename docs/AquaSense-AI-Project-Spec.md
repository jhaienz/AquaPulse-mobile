# AquaSense AI — Project Specification

> Predictive LoRaWAN Telemetry and AI Forecasting for Philippine Aquaculture

This document is the build reference for the AquaSense AI platform. It describes what the system does, how it's architected, and what needs to be implemented, so that development (human or AI-assisted) can proceed with a shared understanding of scope.

---

## 1. Overview

AquaSense AI is a low-power, long-range **LoRaWAN telemetry framework** deployed across coastal and inland aquaculture enclosures (ponds, cages, raceways, tanks) that feeds real-time environmental data into a **predictive AI engine**. Instead of operators reacting to a hypoxia event or disease outbreak after the fact, the system forecasts catastrophic ecological crashes and metabolic shifts **hours in advance**, giving farm teams time to run automated, closed-loop interventions or targeted preemptive mitigations.

### Design constraints (why LoRaWAN)
- Enclosures are spread across coastlines/inland clusters with **unreliable grid power and cellular coverage**.
- Margins are thin — feed waste and stock loss directly threaten viability.
- Farm staff are field operators, not data scientists — forecasts must surface as **plain, actionable guidance**, not raw numbers.
- LoRaWAN fits this: multi-kilometer range, years of battery life on solar-assisted nodes, mesh-style repeaters that keep working when a single link drops.

### Objective
Reduce catastrophic stock loss and feed waste through **early, automated intervention** rather than manual monitoring rounds.

### Target users
- Small-to-mid-scale fish/shrimp farm operators and cooperatives
- Local government aquaculture offices (City/Municipal Agriculture Offices)
- BFAR-supported hatcheries

### Deployment context
Coastal bay clusters and inland pond systems with intermittent power/connectivity, where a single technician may be responsible for many enclosures.

---

## 2. Key Features (functional requirements)

| # | Feature | Description |
|---|---|---|
| 2.1 | **DO crash forecasting** | Time-series ML analyzes diurnal telemetry to forecast hypoxic events up to 6 hours ahead; can auto-trigger remote localized aeration. |
| 2.2 | **Disease/outbreak early warning** | Correlates multi-variable water chemistry fluctuations with macro-climate weather data into a dynamic biosecurity risk index. |
| 2.3 | **Anomalous telemetry / sensor drift isolation** | Unsupervised anomaly detection audits incoming packets to distinguish bio-fouling/sensor faults from genuine environmental threats — prevents false alarms. |
| 2.4 | **Dynamic feed optimization** | Cross-references real-time water conditions against historical FCR to estimate biomass demand and auto-adjust feeding schedules. |
| 2.5 | **Preemptive water quality/toxicity mitigation** | Forecasts TAN (ammonia) accumulation from run-off/evaporation trends; can trigger micro-dosed probiotic adjustments via actuators. |

---

## 3. System Architecture (5 layers, edge → cloud)

Data flows from sensor → action in five distinct layers. Each layer should be able to keep functioning locally for a while even if the layer above it is unreachable — **offline resilience is a first-class design goal, not an afterthought.**

1. **Enclosure sensing layer** — per-enclosure probes (DO, pH, temperature, TAN, turbidity, water level) wired to a solar-powered microcontroller + LoRa radio.
2. **LoRaWAN mesh network layer** — nodes transmit to nearest repeater/gateway; multi-hop relays extend coverage without needing cellular at every pond.
3. **Edge gateway / fog processing layer** — Raspberry Pi-class gateway buffers data during outages, translates LoRaWAN → cloud protocols, runs lightweight anomaly detection to filter bad readings before they reach forecasting models.
4. **Cloud platform / predictive AI layer** — time-series DB feeding the DO forecaster, disease risk index engine, anomaly/drift detector, and feed optimizer. Federated learning (e.g. Flower) lets models improve across farms without raw data leaving client premises.
5. **Application / automated action layer** — mobile/web dashboard for operators; confirmed high-confidence events can directly trigger aerators, feeders, or dosing pumps (closed loop).

---

## 4. System Design

### 4.1 Data pipeline (per telemetry cycle)
Sensor read → local buffering/filtering at edge → uplink over LoRaWAN → gateway translation/anomaly check → cloud ingestion → model inference → (if threshold crossed) forecast/alert issued → optional automated actuation → operator acknowledgement logged.

### 4.2 Models to build

| Model | Type | Purpose |
|---|---|---|
| **DO crash forecaster** | Short-horizon time-series (LSTM/GRU or gradient-boosted trees over lag features) | 6-hour-ahead hypoxia probability curve + time-to-threshold, trained on DO/temp/weather covariates |
| **Disease/biosecurity risk index** | Correlation + classification | Scores water-chemistry volatility, rainfall/pressure trends, seasonal outbreak history → 0–100 index |
| **Anomaly/drift detector** | Unsupervised (isolation forest / autoencoder reconstruction error) | Runs at the edge; separates sensor faults from real events before forwarding upstream |
| **Feed optimizer** | Regression | Relates water conditions + historical FCR to biomass demand; scales feeding schedule |
| **Federated learning** | Cross-farm aggregation | Per-farm models train locally, share only model updates with a central aggregator — raw data never leaves the farm |

### 4.3 Data model (high level)

- **Enclosure registry**: enclosure ID, type, location, capacity, stocking density, assigned sensors
- **Telemetry stream**: enclosure ID, timestamp, parameter, value, sensor health flag
- **Event log**: forecast issued, threshold crossed, action triggered, operator acknowledgement, outcome
- **Actuation log**: device ID, command, trigger source (auto/operator), execution status, timestamp

### 4.4 Communication protocol stack

- **Sensor → node**: I2C / analog / one-wire (e.g. DS18B20)
- **Node → gateway**: LoRaWAN (Class A for battery-powered sensor nodes; Class C for actuator nodes needing fast downlink)
- **Gateway → cloud**: MQTT or HTTPS over 4G/LTE, with local store-and-forward buffering during outages
- **Cloud → application**: REST/WebSocket APIs to mobile and web dashboards

---

## 5. Equipment & Indicative Costs (PH market, mid-2026 estimates)

Full BOM with price ranges is in the source document. Rough shape for planning:

- **Per-enclosure sensor node** (DO, pH, TAN, turbidity, temp, level, MCU/LoRa, solar, housing): ~₱9,900 – ₱32,700
- **Per-enclosure actuation** (feeder, aerator control, dosing share): ~₱10,000 – ₱38,000
- **Shared gateway site** (gateway, edge compute, 4G backhaul, 2–3 repeaters): ~₱14,300 – ₱52,200
- **Pilot budget** for a 10–12 enclosure cluster on one gateway: roughly **₱220,000 – ₱850,000**, excluding cloud hosting, depending on sensor grade and actuation coverage.
- **Recommended rollout**: monitoring-only nodes on high-risk enclosures first → add actuation once the forecasting model is validated.

---

## 6. Feasibility Notes

- **Technical**: components (LoRa radios, probes, edge compute, OSS forecasting libs) are all commercially available. Main risk is sensor durability in brackish/bio-fouled water — mitigated via anomaly/drift detection + scheduled recalibration, not "maintenance-free" assumptions.
- **Economic**: per-enclosure hardware cost is small relative to the value of one prevented stock crash. Ongoing cost is dominated by data plans, cloud hosting, and consumables — not hardware refresh.
- **Operational**: dashboard must show plain-language forecasts + recommended actions (not raw sensor dumps) so non-technical field operators can act. Offline/field mode with local caching and sync-on-reconnect is required.
- **Regulatory**: LoRa uses unlicensed 433/868/915 MHz ISM bands (NTC-recognized) — no special spectrum licensing needed for private deployments. Partnership pathways: BFAR hatcheries, LGU Agriculture Offices, academic/hackathon pilots.

---

## 7. Scalability

- **Network**: LoRaWAN star-of-stars lets one gateway serve hundreds of nodes; add gateways/repeaters as clusters grow. Class A duty-cycle limits keep airtime low.
- **Data/compute**: cloud layer scales horizontally — time-series storage/inference partitioned per farm or region. Federated learning means new farms improve the shared model without centralizing raw data or full retraining.
- **Organizational**: multiple operators/farms can coordinate through the same platform via shared response plans — scaling from one pilot pond to a multi-farm cooperative is a data/config change, not an architectural rework.

---

## 8. Build Scope Checklist (for implementation planning)

This is not in the source doc — it's a translation of the above into buildable software components:

- [ ] **Firmware**: sensor-node firmware (ESP32 + LoRa radio) reading DO/pH/temp/TAN/turbidity/level, Class A LoRaWAN uplink, solar power management
- [ ] **Gateway/edge service**: buffering, store-and-forward, LoRaWAN→MQTT/HTTPS translation, lightweight anomaly filtering (Raspberry Pi-class)
- [ ] **Ingestion API**: receives gateway uplinks, writes to time-series store, validates against enclosure registry
- [ ] **Time-series data store**: telemetry stream schema per §4.3
- [ ] **Forecasting services**: DO crash forecaster, disease risk index, anomaly/drift detector, feed optimizer (see §4.2) — each as an independently deployable inference service
- [ ] **Federated learning aggregator**: collects model updates (not raw data) from per-farm edge/cloud deployments
- [ ] **Event/actuation log service**: records forecast → threshold → action → acknowledgement → outcome chain
- [ ] **Actuator control layer**: command dispatch to aerators, feeders, dosing pumps, with auto/manual trigger source tracking
- [ ] **Operator dashboard (web/mobile)**: plain-language forecasts and recommended actions, offline-first with local cache + sync, enclosure registry management
- [ ] **Auth & multi-farm/tenant model**: supports single-pilot-pond → multi-farm cooperative scaling per §7.3

---

*Source: AquaSense AI concept document (Philippine aquaculture LoRaWAN telemetry + predictive AI platform), condensed for development reference.*
