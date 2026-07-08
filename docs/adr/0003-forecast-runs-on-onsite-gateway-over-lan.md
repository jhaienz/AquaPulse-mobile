# Forecast runs on the on-site gateway over LAN, not internet cloud

The FastAPI backend — store + forecaster + API — runs on a Raspberry Pi-class **Gateway** on the farm's local LAN. The Flutter app talks to it over farm wifi. It does not depend on reaching an internet server.

Why: the deployment premise is LoRaWAN with low/no internet (spec §3, §6). A cloud round-trip per forecast would fail exactly when it's needed. Running inference on the on-site gateway keeps forecasting alive during an internet outage, and keeps the forecaster in Python where the future ML model lives (ADR-0002).

The mockup's "Edge AI Processing — on-device inference, no cloud" toggle refers to **this** gateway, not literal on-phone inference. "No cloud" = no internet dependency, not no server. The phone additionally caches the last forecast (**Field Mode**) so viewing survives even a gateway outage. Cross-farm sync and federated learning (spec §3 layer 4) are the only genuinely internet-needing features, and they are out of the MVP.
