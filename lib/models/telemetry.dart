/// A timestamped water-quality snapshot for one enclosure.
/// (MVP groups the core params into one reading; per-parameter streams come
/// with the real ingestion layer.)
class TelemetryReading {
  final String enclosureId;
  final DateTime timestamp;
  final double doMgL; // dissolved oxygen
  final double ph;
  final double tempC;
  final bool sensorHealthy; // false = suspected drift/fault

  const TelemetryReading({
    required this.enclosureId,
    required this.timestamp,
    required this.doMgL,
    required this.ph,
    required this.tempC,
    this.sensorHealthy = true,
  });
}
