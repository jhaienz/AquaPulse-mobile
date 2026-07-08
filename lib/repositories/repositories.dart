import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enclosure.dart';
import '../models/forecast.dart';
import '../models/telemetry.dart';
import 'fixtures.dart';

/// The seam (ADR-0004). Screens depend on these interfaces, never on HTTP.
/// Phase 0 wires the fixture implementations; a later phase swaps in
/// HTTP-against-Gateway impls without touching screens or providers.

abstract interface class EnclosureRepository {
  Future<List<Enclosure>> all();
  Future<Enclosure?> byId(String id);
}

abstract interface class TelemetryRepository {
  /// Latest reading per enclosure, keyed by enclosure id.
  Future<Map<String, TelemetryReading>> latest();
}

abstract interface class ForecastRepository {
  Future<Forecast> forEnclosure(String enclosureId);
}

// --- Fixture implementations ---

class FixtureEnclosureRepository implements EnclosureRepository {
  @override
  Future<List<Enclosure>> all() async => fixtureEnclosures;

  @override
  Future<Enclosure?> byId(String id) async =>
      fixtureEnclosures.where((e) => e.id == id).firstOrNull;
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

// --- Providers (swap the override here to go live) ---

final enclosureRepositoryProvider =
    Provider<EnclosureRepository>((_) => FixtureEnclosureRepository());
final telemetryRepositoryProvider =
    Provider<TelemetryRepository>((_) => FixtureTelemetryRepository());
final forecastRepositoryProvider =
    Provider<ForecastRepository>((_) => FixtureForecastRepository());

// Convenience async views for screens.
final enclosuresProvider = FutureProvider<List<Enclosure>>(
    (ref) => ref.watch(enclosureRepositoryProvider).all());
final latestTelemetryProvider = FutureProvider<Map<String, TelemetryReading>>(
    (ref) => ref.watch(telemetryRepositoryProvider).latest());
