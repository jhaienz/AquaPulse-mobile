import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enclosure.dart';
import '../repositories/repositories.dart';
import '../theme.dart';

/// Telemetry list (figma "History" tab). Phase-0 version proves the
/// repository seam: real fixture data, real status logic. Achievements grid
/// and filters land in Phase 2.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enclosures = ref.watch(enclosuresProvider);
    final latest = ref.watch(latestTelemetryProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Telemetry',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Expanded(
              child: switch ((enclosures, latest)) {
                (AsyncData(value: final list), AsyncData(value: final readings)) =>
                  ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final e = list[i];
                      final r = readings[e.id];
                      final status = r == null
                          ? EnclosureStatus.normal
                          : statusFromDo(r.doMgL, e.profile);
                      return _TelemetryTile(
                        name: e.name.split(' — ').first,
                        status: status,
                        summary: r == null
                            ? 'No data'
                            : 'DO ${r.doMgL} · pH ${r.ph} · ${r.tempC}°C',
                        time: r == null
                            ? ''
                            : '${r.timestamp.hour.toString().padLeft(2, '0')}:${r.timestamp.minute.toString().padLeft(2, '0')}',
                      );
                    },
                  ),
                (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
                  Center(child: Text('Error: $error')),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(summary,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace')),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(status.label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: status.color)),
              const SizedBox(height: 2),
              Text(time,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
