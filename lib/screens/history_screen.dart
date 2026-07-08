import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/achievement.dart';
import '../models/enclosure.dart';
import '../models/telemetry.dart';
import '../repositories/repositories.dart';
import '../theme.dart';

/// How much telemetry history the list shows. Over latest-per-enclosure
/// fixtures the windows overlap; they bite once real time-series data exists.
enum TelemetryFilter { all, today, week }

extension on TelemetryFilter {
  String get label => switch (this) {
        TelemetryFilter.all => 'All',
        TelemetryFilter.today => 'Today',
        TelemetryFilter.week => 'Week',
      };

  bool includes(DateTime t, DateTime ref) => switch (this) {
        TelemetryFilter.all => true,
        TelemetryFilter.today => t.year == ref.year && t.month == ref.month && t.day == ref.day,
        TelemetryFilter.week => t.isAfter(ref.subtract(const Duration(days: 7))),
      };
}

/// History tab — telemetry list (filterable) + achievements grid.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  TelemetryFilter _filter = TelemetryFilter.all;

  @override
  Widget build(BuildContext context) {
    final enclosures = ref.watch(enclosuresProvider);
    final latest = ref.watch(latestTelemetryProvider);
    final achievements = ref.watch(achievementsProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Telemetry',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Row(children: [
                for (final f in TelemetryFilter.values) ...[
                  _FilterChip(
                    label: f.label,
                    selected: _filter == f,
                    onTap: () => setState(() => _filter = f),
                  ),
                  const SizedBox(width: 6),
                ],
              ]),
            ],
          ),
          const SizedBox(height: 14),
          switch ((enclosures, latest)) {
            (AsyncData(value: final list), AsyncData(value: final readings)) =>
              _TelemetryList(list: list, readings: readings, filter: _filter),
            (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
              Text('Error: $error'),
            _ => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
          },
          const SizedBox(height: 24),
          switch (achievements) {
            AsyncData(value: final list) => _Achievements(list),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }
}

class _TelemetryList extends StatelessWidget {
  final List<Enclosure> list;
  final Map<String, TelemetryReading> readings;
  final TelemetryFilter filter;
  const _TelemetryList({required this.list, required this.readings, required this.filter});

  @override
  Widget build(BuildContext context) {
    final ref = readings.values.isEmpty
        ? DateTime.now()
        : readings.values.map((r) => r.timestamp).reduce((a, b) => a.isAfter(b) ? a : b);

    final tiles = <Widget>[];
    for (final e in list) {
      final r = readings[e.id];
      if (r != null && !filter.includes(r.timestamp, ref)) continue;
      final status = r == null ? EnclosureStatus.normal : statusFromDo(r.doMgL, e.profile);
      tiles.add(_TelemetryTile(
        name: e.name.split(' — ').first,
        status: status,
        summary: r == null ? 'No data' : 'DO ${r.doMgL} · pH ${r.ph} · ${r.tempC}°C',
        time: r == null ? '' : _hhmm(r.timestamp),
      ));
    }
    if (tiles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No readings in this window', style: TextStyle(color: AppColors.textSecondary))),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          tiles[i],
        ],
      ],
    );
  }
}

String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class _TelemetryTile extends StatelessWidget {
  final String name;
  final EnclosureStatus status;
  final String summary;
  final String time;

  const _TelemetryTile({
    required this.name,
    required this.status,
    required this.summary,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: status.color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(summary,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace')),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: status.color)),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Achievements extends StatelessWidget {
  final List<Achievement> list;
  const _Achievements(this.list);

  @override
  Widget build(BuildContext context) {
    final earned = list.where((a) => a.earned).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ACHIEVEMENTS',
                style: TextStyle(fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold, color: AppColors.accent)),
            Text('$earned / ${list.length} earned',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
          children: [for (final a in list) _Badge(a)],
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final Achievement a;
  const _Badge(this.a);

  @override
  Widget build(BuildContext context) {
    final color = a.earned ? AppColors.accent : AppColors.textSecondary;
    return Opacity(
      opacity: a.earned ? 1 : 0.4,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: a.earned ? color.withValues(alpha: 0.5) : AppColors.border),
            ),
            child: Icon(a.icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(a.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
