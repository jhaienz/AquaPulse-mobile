import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/alert.dart';
import '../repositories/repositories.dart';
import '../theme.dart';

/// Which alerts the inbox shows.
enum AlertFilter { all, critical, warning }

class _Toggle {
  final String title;
  final String subtitle;
  const _Toggle(this.title, this.subtitle);
}

const _toggleDefs = <String, _Toggle>{
  'edgeAi': _Toggle('Edge AI Processing', 'On-device inference, no cloud'),
  'autoSync': _Toggle('Mesh Auto-Sync', 'Sync when connection available'),
  'nightMode': _Toggle('Night Mode', 'Dim display 22:00 – 06:00'),
  'push': _Toggle('Push Notifications', 'Critical alerts only'),
  'haptics': _Toggle('Haptic Feedback', 'Vibrate on threshold breach'),
};

/// Settings tab — preference toggles + the alerts inbox.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Screen-local prefs (disk persistence is Phase 7).
  final Map<String, bool> _toggles = {
    'edgeAi': true, 'autoSync': true, 'nightMode': false, 'push': true, 'haptics': true,
  };
  AlertFilter _filter = AlertFilter.all;
  final Set<int> _acked = {}; // locally acknowledged alert ids

  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(alertsProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Text('Settings',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              for (final entry in _toggleDefs.entries) ...[
                if (entry.key != _toggleDefs.keys.first)
                  const Divider(height: 1, color: AppColors.border),
                _ToggleRow(
                  def: entry.value,
                  value: _toggles[entry.key]!,
                  onChanged: (v) => setState(() => _toggles[entry.key] = v),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: const [
                Icon(Icons.notifications_outlined, size: 16, color: AppColors.accent),
                SizedBox(width: 6),
                Text('ALERTS',
                    style: TextStyle(fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold, color: AppColors.accent)),
              ]),
              Row(children: [
                for (final f in AlertFilter.values) ...[
                  _FilterChip(
                    label: f.name[0].toUpperCase() + f.name.substring(1),
                    selected: _filter == f,
                    onTap: () => setState(() => _filter = f),
                  ),
                  const SizedBox(width: 6),
                ],
              ]),
            ],
          ),
          const SizedBox(height: 12),
          switch (alerts) {
            AsyncData(value: final list) => _AlertList(
                alerts: list.where(_matchesFilter).toList(),
                acked: _acked,
                onAck: (id) => setState(() => _acked.add(id)),
              ),
            AsyncError(:final error) => Text('Error: $error'),
            _ => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
          },
        ],
      ),
    );
  }

  bool _matchesFilter(Alert a) => switch (_filter) {
        AlertFilter.all => true,
        AlertFilter.critical => a.severity == EnclosureStatus.critical,
        AlertFilter.warning => a.severity == EnclosureStatus.warning,
      };
}

class _ToggleRow extends StatelessWidget {
  final _Toggle def;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.def, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(def.title, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(def.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.accent,
        ),
      ]),
    );
  }
}

class _AlertList extends StatelessWidget {
  final List<Alert> alerts;
  final Set<int> acked;
  final ValueChanged<int> onAck;
  const _AlertList({required this.alerts, required this.acked, required this.onAck});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No alerts', style: TextStyle(color: AppColors.textSecondary))),
      );
    }
    return Column(children: [
      for (var i = 0; i < alerts.length; i++) ...[
        if (i > 0) const SizedBox(height: 8),
        _AlertCard(
          alert: alerts[i],
          acknowledged: alerts[i].acknowledged || acked.contains(alerts[i].id),
          onAck: () => onAck(alerts[i].id),
        ),
      ],
    ]);
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  final bool acknowledged;
  final VoidCallback onAck;
  const _AlertCard({required this.alert, required this.acknowledged, required this.onAck});

  @override
  Widget build(BuildContext context) {
    final color = alert.severity.color;
    final time = '${alert.time.hour.toString().padLeft(2, '0')}:${alert.time.minute.toString().padLeft(2, '0')}';
    return Opacity(
      opacity: acknowledged ? 0.55 : 1,
      child: InkWell(
        onTap: acknowledged ? null : onAck,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: color, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${alert.severity.label} · Pond ${alert.enclosureId}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                  Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 4),
              Text(alert.message, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
              if (!acknowledged) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                  child: Text('UNACKNOWLEDGED',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}
