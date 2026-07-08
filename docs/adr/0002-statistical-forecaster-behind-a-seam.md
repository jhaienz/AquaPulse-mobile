# DO forecaster is statistical, behind a swappable seam

The MVP forecasts DO crashes with a deterministic/statistical method (diurnal-curve trend extrapolation), not the LSTM/GBT model the spec (§4.2) ultimately calls for.

Why: telemetry is synthetic in the MVP, so a trained ML model would only learn to invert our own simulator — high effort, proves nothing about real-world accuracy. The statistical baseline gives a genuinely useful "hypoxia in ~Nh" forecast now and is honest about what it does.

The forecaster sits behind a single interface so a real ML model drops in once real sensor data exists, without touching ingestion, store, or dashboard.

This decision is about the **forecaster** specifically. The MVP app scope is the full operator app (all mockup screens), but the only *forecasting* feature is DO crash forecasting (spec §2.1); disease index, anomaly/drift, feed optimizer, federated learning, and actuation are out and bolt onto the same pipeline later.
