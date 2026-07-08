import '../theme.dart';

/// A per-parameter status tag on a field-log entry (e.g. "DO Critical").
class FieldTag {
  final String label;
  final EnclosureStatus severity;
  const FieldTag(this.label, this.severity);
}

/// An operator's field-log entry for an enclosure: a plain-language note,
/// optional photo, and status tags. Operator-authored observations that sit
/// alongside the machine forecast.
class FieldLogEntry {
  final String enclosureId;
  final DateTime timestamp;
  final String note;
  final List<FieldTag> tags;
  final bool hasPhoto; // MVP: fixture flag; real photo capture is a later phase

  const FieldLogEntry({
    required this.enclosureId,
    required this.timestamp,
    required this.note,
    required this.tags,
    this.hasPhoto = false,
  });
}
