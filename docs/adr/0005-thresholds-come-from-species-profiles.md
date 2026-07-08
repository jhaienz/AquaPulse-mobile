# Water-quality thresholds are species-driven, not global

Safe ranges (DO min, pH, temp, TAN) come from a seeded **Species Profile** table keyed by species (Tilapia, Bangus, Shrimp, Crab, Milkfish), not from global constants. Each enclosure picks a species at Add-Pond; status coloring (normal/warning/critical) and the DO-crash forecast threshold both read that enclosure's species profile.

Why: different stock tolerate different water. A single global "DO < 4.0" (as the mockup happens to show for one pond) would be wrong across species. Reading one source — the species profile — keeps status logic and the forecaster consistent and makes the ranges a single tunable knob.

MVP seeds literature values in config and is not user-editable. Per-enclosure overrides are a clean later addition.
