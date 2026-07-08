import '../models/enclosure.dart';
import '../models/forecast.dart';
import '../models/species.dart';
import '../models/telemetry.dart';

/// Hardcoded sample data for the "screens first" phase (ADR-0004).
/// Mirrors the figma: ponds A-1, B-3, C-2, A-2, D-1, B-1 with mixed status.
/// Replaced by HTTP-from-Gateway later; screens never notice.

final _now = DateTime(2026, 7, 6, 14, 32);

const fixtureEnclosures = <Enclosure>[
  Enclosure(id: 'A-1', name: 'Pond A-1 — North Basin', species: Species.tilapia, sizeHectares: 0.8, latitude: 14.5595, longitude: 120.9842),
  Enclosure(id: 'B-3', name: 'Pond B-3 — West Bank', species: Species.bangus, sizeHectares: 1.2, latitude: 14.5601, longitude: 120.9850),
  Enclosure(id: 'C-2', name: 'Pond C-2 — Inlet Gate', species: Species.shrimp, sizeHectares: 0.5, latitude: 14.5588, longitude: 120.9861),
  Enclosure(id: 'A-2', name: 'Pond A-2 — South Basin', species: Species.tilapia, sizeHectares: 0.9, latitude: 14.5590, longitude: 120.9838),
  Enclosure(id: 'D-1', name: 'Pond D-1 — East Pen', species: Species.milkfish, sizeHectares: 1.5, latitude: 14.5583, longitude: 120.9845),
  Enclosure(id: 'B-1', name: 'Pond B-1 — Reservoir', species: Species.crab, sizeHectares: 0.6, latitude: 14.5605, longitude: 120.9855),
];

/// Latest reading per enclosure — DO values chosen to span normal/warning/critical.
final Map<String, TelemetryReading> fixtureLatest = {
  'A-1': TelemetryReading(enclosureId: 'A-1', timestamp: _now, doMgL: 7.2, ph: 7.8, tempC: 26.4),
  'B-3': TelemetryReading(enclosureId: 'B-3', timestamp: _now.subtract(const Duration(minutes: 17)), doMgL: 4.1, ph: 8.2, tempC: 28.9),
  'C-2': TelemetryReading(enclosureId: 'C-2', timestamp: _now.subtract(const Duration(minutes: 34)), doMgL: 2.8, ph: 8.6, tempC: 31.2),
  'A-2': TelemetryReading(enclosureId: 'A-2', timestamp: _now.subtract(const Duration(minutes: 51)), doMgL: 6.9, ph: 7.5, tempC: 27.1),
  'D-1': TelemetryReading(enclosureId: 'D-1', timestamp: _now.subtract(const Duration(minutes: 70)), doMgL: 5.4, ph: 7.9, tempC: 27.8),
  'B-1': TelemetryReading(enclosureId: 'B-1', timestamp: _now.subtract(const Duration(minutes: 88)), doMgL: 3.9, ph: 8.3, tempC: 29.6),
};

/// One sample forecast for A-1 (matches the mockup's hero card shape).
Forecast fixtureForecast(String enclosureId) {
  final threshold = profileFor(Species.tilapia).doWarn; // 4.0
  final start = _now.subtract(const Duration(hours: 6));
  final observed = [7.6, 7.4, 7.0, 6.5, 6.0, 5.6, 5.2];
  final projected = [4.9, 4.4, 4.0, 3.6];
  final curve = <ForecastPoint>[
    for (var i = 0; i < observed.length; i++)
      ForecastPoint(time: start.add(Duration(hours: i)), doMgL: observed[i], projected: false),
    for (var i = 0; i < projected.length; i++)
      ForecastPoint(time: _now.add(Duration(hours: i * 2)), doMgL: projected[i], projected: true),
  ];
  return Forecast(
    enclosureId: enclosureId,
    issuedAt: _now,
    crashLikely: true,
    timeToThreshold: const Duration(hours: 6),
    thresholdMgL: threshold,
    doRatePerHour: -0.43,
    headline: 'Hypoxia likely in 6h',
    recommendedAction: 'Pre-stage aeration array',
    curve: curve,
  );
}
