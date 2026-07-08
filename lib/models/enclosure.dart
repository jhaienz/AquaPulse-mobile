import '../theme.dart';
import 'species.dart';

/// A single farmed body of water monitored as one unit.
/// Code term is always `Enclosure`; the UI labels it "Pond" (ADR: naming).
class Enclosure {
  final String id; // e.g. "A-1"
  final String name; // operator-facing, e.g. "Pond A-1 — North Basin"
  final Species species;
  final double sizeHectares;
  final double latitude;
  final double longitude;
  final String notes;

  const Enclosure({
    required this.id,
    required this.name,
    required this.species,
    required this.sizeHectares,
    required this.latitude,
    required this.longitude,
    this.notes = '',
  });

  SpeciesProfile get profile => profileFor(species);
}

/// Status derived from a DO reading against the enclosure's species profile.
/// Kept here so status logic reads one source (the profile), per ADR-0005.
EnclosureStatus statusFromDo(double doValue, SpeciesProfile p) {
  if (doValue < p.doMin) return EnclosureStatus.critical;
  if (doValue < p.doWarn) return EnclosureStatus.warning;
  return EnclosureStatus.normal;
}
