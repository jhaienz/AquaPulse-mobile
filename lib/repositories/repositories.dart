import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/achievement.dart';
import '../models/enclosure.dart';
import '../models/field_log.dart';
import '../models/forecast.dart';
import '../models/mesh.dart';
import '../models/telemetry.dart';
import 'fixtures.dart';

/// The seam (ADR-0004). Screens depend on these interfaces, never on HTTP.
/// Phase 0 wires the fixture implementations; a later phase swaps in
/// HTTP-against-Gateway impls without touching screens or providers.

abstract interface class EnclosureRepository {
  Future<List<Enclosure>> all();
  Future<Enclosure?> byId(String id);
  Future<void> add(Enclosure enclosure);
}

abstract interface class TelemetryRepository {
  /// Latest reading per enclosure, keyed by enclosure id.
  Future<Map<String, TelemetryReading>> latest();
}

abstract interface class ForecastRepository {
  Future<Forecast> forEnclosure(String enclosureId);
}

abstract interface class FieldLogRepository {
  Future<FieldLogEntry> latestFor(String enclosureId);
}

abstract interface class AchievementRepository {
  Future<List<Achievement>> all();
}

// --- Fixture implementations ---

class FixtureEnclosureRepository implements EnclosureRepository {
  // Seeded from fixtures, mutable so Add-Pond has somewhere to write.
  // Held by a singleton Provider, so additions persist across reads until the
  // HTTP repo replaces it.
  final List<Enclosure> _items = [...fixtureEnclosures];

  @override
  Future<List<Enclosure>> all() async => List.unmodifiable(_items);

  @override
  Future<Enclosure?> byId(String id) async =>
      _items.where((e) => e.id == id).firstOrNull;

  @override
  Future<void> add(Enclosure enclosure) async => _items.add(enclosure);
}

class FixtureTelemetryRepository implements TelemetryRepository {
  @override
  Future<Map<String, TelemetryReading>> latest() async => fixtureLatest;
}

class FixtureForecastRepository implements ForecastRepository {
  @override
  Future<Forecast> forEnclosure(String enclosureId) async =>
      fixtureForecast(enclosureId);
}

class FixtureFieldLogRepository implements FieldLogRepository {
  @override
  Future<FieldLogEntry> latestFor(String enclosureId) async =>
      fixtureFieldLog(enclosureId);
}

class FixtureAchievementRepository implements AchievementRepository {
  @override
  Future<List<Achievement>> all() async => fixtureAchievements;
}

// --- Providers (swap the override here to go live) ---

final enclosureRepositoryProvider =
    Provider<EnclosureRepository>((_) => FixtureEnclosureRepository());
final telemetryRepositoryProvider =
    Provider<TelemetryRepository>((_) => FixtureTelemetryRepository());
final forecastRepositoryProvider =
    Provider<ForecastRepository>((_) => FixtureForecastRepository());
final fieldLogRepositoryProvider =
    Provider<FieldLogRepository>((_) => FixtureFieldLogRepository());
final achievementRepositoryProvider =
    Provider<AchievementRepository>((_) => FixtureAchievementRepository());

// The enclosure the Log tab is focused on. Read-only for now; becomes a
// Notifier once the operator can switch enclosures (later phase).
final selectedEnclosureIdProvider =
    Provider<String>((_) => fixtureSelectedEnclosureId);

// Convenience async views for screens.
final enclosuresProvider = FutureProvider<List<Enclosure>>(
    (ref) => ref.watch(enclosureRepositoryProvider).all());
final latestTelemetryProvider = FutureProvider<Map<String, TelemetryReading>>(
    (ref) => ref.watch(telemetryRepositoryProvider).latest());
final enclosureByIdProvider = FutureProvider.family<Enclosure?, String>(
    (ref, id) => ref.watch(enclosureRepositoryProvider).byId(id));
final forecastProvider = FutureProvider.family<Forecast, String>(
    (ref, id) => ref.watch(forecastRepositoryProvider).forEnclosure(id));
final fieldLogProvider = FutureProvider.family<FieldLogEntry, String>(
    (ref, id) => ref.watch(fieldLogRepositoryProvider).latestFor(id));
final achievementsProvider = FutureProvider<List<Achievement>>(
    (ref) => ref.watch(achievementRepositoryProvider).all());

// Field Mode sync snapshot (fixture; real sync state is Phase 7).
final fieldSyncProvider = Provider<FieldSyncStatus>((_) => fixtureFieldSync);

// Mesh tab (read-only fixtures).
final meshNodesProvider = Provider<List<MeshNode>>((_) => fixtureMeshNodes);
final meshHealthProvider = Provider<int>((_) => fixtureMeshHealthPercent);
final operatorProvider = Provider<Operator>((_) => fixtureOperator);
