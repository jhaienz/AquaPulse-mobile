/// A LoRa node's link state on the mesh (figma Mesh tab).
class MeshNode {
  final String id; // e.g. "A-1"
  final int? latencyMs; // null when offline
  bool get online => latencyMs != null;
  const MeshNode(this.id, this.latencyMs);
}

/// An item on the aeration/maintenance checklist. `done` is toggled by the
/// operator; persistence across restarts is Phase 7 (local cache).
class ChecklistItem {
  final String label;
  final bool done;
  const ChecklistItem(this.label, {this.done = false});

  ChecklistItem toggled() => ChecklistItem(label, done: !done);
}

/// The signed-in field operator and their running stats.
class Operator {
  final String name;
  final String id; // e.g. "AQ-2847"
  final String role;
  final int entries;
  final int badges;
  final int streakDays;
  const Operator({
    required this.name,
    required this.id,
    required this.role,
    required this.entries,
    required this.badges,
    required this.streakDays,
  });
}
