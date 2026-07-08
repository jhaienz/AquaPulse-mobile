/// Stock species. Chosen at Add-Pond; every Enclosure has exactly one.
enum Species { tilapia, bangus, shrimp, crab, milkfish }

extension SpeciesLabel on Species {
  String get label => switch (this) {
        Species.tilapia => 'Tilapia',
        Species.bangus => 'Bangus',
        Species.shrimp => 'Shrimp',
        Species.crab => 'Crab',
        Species.milkfish => 'Milkfish',
      };
}

/// Seeded safe-range table for a species (ADR-0005). Single source of truth
/// for status coloring AND the DO-crash forecast threshold.
///
/// Values are indicative literature ranges for MVP demo — a calibration knob,
/// not settled science. Tune once real ponds/sensors exist.
class SpeciesProfile {
  final Species species;
  final double doMin; // mg/L — below this = hypoxic (DO crash threshold)
  final double doWarn; // mg/L — below this = warning
  final double phMin;
  final double phMax;
  final double tempMin; // °C
  final double tempMax; // °C
  final double tanMax; // mg/L total ammonia nitrogen

  const SpeciesProfile({
    required this.species,
    required this.doMin,
    required this.doWarn,
    required this.phMin,
    required this.phMax,
    required this.tempMin,
    required this.tempMax,
    required this.tanMax,
  });
}

/// Seeded profiles. Indicative values — see note above.
const Map<Species, SpeciesProfile> speciesProfiles = {
  Species.tilapia: SpeciesProfile(
    species: Species.tilapia,
    doMin: 3.0, doWarn: 4.0, phMin: 6.5, phMax: 9.0,
    tempMin: 24, tempMax: 32, tanMax: 1.0,
  ),
  Species.bangus: SpeciesProfile(
    species: Species.bangus,
    doMin: 3.5, doWarn: 4.5, phMin: 7.0, phMax: 9.0,
    tempMin: 25, tempMax: 32, tanMax: 0.9,
  ),
  Species.shrimp: SpeciesProfile(
    species: Species.shrimp,
    doMin: 3.5, doWarn: 5.0, phMin: 7.5, phMax: 8.5,
    tempMin: 26, tempMax: 32, tanMax: 0.5,
  ),
  Species.crab: SpeciesProfile(
    species: Species.crab,
    doMin: 3.0, doWarn: 4.0, phMin: 7.5, phMax: 8.5,
    tempMin: 25, tempMax: 32, tanMax: 0.7,
  ),
  Species.milkfish: SpeciesProfile(
    species: Species.milkfish,
    doMin: 3.5, doWarn: 4.5, phMin: 7.0, phMax: 9.0,
    tempMin: 25, tempMax: 33, tanMax: 0.9,
  ),
};

SpeciesProfile profileFor(Species s) => speciesProfiles[s]!;
