import '../theme.dart';

/// An alert raised when a reading crosses a threshold. Severity reuses the
/// enclosure status colors (only warning/critical are ever alerts).
class Alert {
  final int id;
  final String enclosureId;
  final EnclosureStatus severity; // warning | critical
  final String message;
  final DateTime time;
  final bool acknowledged;

  const Alert({
    required this.id,
    required this.enclosureId,
    required this.severity,
    required this.message,
    required this.time,
    this.acknowledged = false,
  });
}
