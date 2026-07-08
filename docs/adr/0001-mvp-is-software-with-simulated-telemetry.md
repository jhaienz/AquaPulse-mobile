# MVP is software-only with simulated telemetry

The MVP builds the cloud + application layers (ingestion, store, forecasting, dashboard) and feeds them from a **Simulator** that generates synthetic telemetry, instead of physical LoRa sensor nodes. Hardware is deferred because we don't have it yet, sensor durability in brackish water is the spec's own #1 risk (§6), and all the differentiating value (forecasting, plain-language alerts) is software.

The simulator plugs in at the gateway→cloud seam (§4.4 MQTT/HTTPS boundary), so real LoRa uplinks can replace it later without touching the cloud or application layers.
