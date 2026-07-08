import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enclosure.dart';
import '../models/telemetry.dart';
import '../repositories/fixtures.dart';
import '../repositories/repositories.dart';
import '../theme.dart';
import '../widgets/add_pond_sheet.dart';

/// Map tab — a schematic mesh of enclosures (not a real geo map; that would
/// need an online tile source, which fights the offline premise). Nodes are
/// placed by normalized lat/long; mesh lines connect nearby nodes.
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enclosures = ref.watch(enclosuresProvider);
    final latest = ref.watch(latestTelemetryProvider);
    final sync = ref.watch(fieldSyncProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          switch ((enclosures, latest)) {
            (AsyncData(value: final list), AsyncData(value: final readings)) =>
              _MeshMap(list: list, readings: readings),
            (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
              Text('Error: $error'),
            _ => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
          },
          const SizedBox(height: 12),
          const _Legend(),
          const SizedBox(height: 16),
          Row(children: const [
            Text('Showing:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            SizedBox(width: 10),
            _ShowingPill('DO', selected: true),
            SizedBox(width: 8),
            _ShowingPill('Ammonia'),
          ]),
          const SizedBox(height: 16),
          _FieldModeCard(sync),
        ],
      ),
    );
  }
}

class _MeshMap extends StatelessWidget {
  final List<Enclosure> list;
  final Map<String, TelemetryReading> readings;
  const _MeshMap({required this.list, required this.readings});

  EnclosureStatus _status(Enclosure e) {
    final r = readings[e.id];
    return r == null ? EnclosureStatus.normal : statusFromDo(r.doMgL, e.profile);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: LayoutBuilder(builder: (context, constraints) {
        const nodeW = 62.0, nodeH = 44.0;
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final positions = _layout(list, size, nodeW, nodeH);

        return Stack(children: [
          Positioned.fill(
            child: CustomPaint(painter: _MeshPainter(positions.values.toList())),
          ),
          for (final e in list)
            Positioned(
              left: positions[e.id]!.dx - nodeW / 2,
              top: positions[e.id]!.dy - nodeH / 2,
              child: _Node(id: e.id, status: _status(e)),
            ),
          const Positioned(
            left: 0, bottom: 4,
            child: Text('— 50m', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ),
          Positioned(
            right: 0, top: 0,
            child: Column(children: [
              _MapIconButton(Icons.navigation_outlined),
              const SizedBox(height: 8),
              _MapIconButton(Icons.filter_alt_outlined),
            ]),
          ),
          Positioned(
            left: 0, right: 0, bottom: 28,
            child: Center(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                onPressed: () => AddPondSheet.show(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Pond'),
              ),
            ),
          ),
        ]);
      }),
    );
  }

  /// Normalize lat/long into the box with inset padding. Falls back to a
  /// horizontal spread when coords coincide (avoids divide-by-zero / overlap).
  static Map<String, Offset> _layout(List<Enclosure> list, Size size, double nodeW, double nodeH) {
    final insetX = nodeW / 2 + 8, insetY = nodeH / 2 + 8;
    final w = size.width - insetX * 2, h = size.height - insetY * 2 - 40; // leave room for button
    final lats = list.map((e) => e.latitude);
    final lngs = list.map((e) => e.longitude);
    final latMin = lats.reduce((a, b) => a < b ? a : b), latMax = lats.reduce((a, b) => a > b ? a : b);
    final lngMin = lngs.reduce((a, b) => a < b ? a : b), lngMax = lngs.reduce((a, b) => a > b ? a : b);

    final out = <String, Offset>{};
    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      final fx = (lngMax - lngMin).abs() < 1e-9 ? (i + 0.5) / list.length : (e.longitude - lngMin) / (lngMax - lngMin);
      final fy = (latMax - latMin).abs() < 1e-9 ? 0.5 : (e.latitude - latMin) / (latMax - latMin);
      out[e.id] = Offset(insetX + fx * w, insetY + (1 - fy) * h); // invert y so north is up
    }
    return out;
  }
}

class _MeshPainter extends CustomPainter {
  final List<Offset> nodes;
  _MeshPainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    // Connect node pairs within a threshold — organic mesh look.
    const threshold = 170.0;
    for (var i = 0; i < nodes.length; i++) {
      for (var j = i + 1; j < nodes.length; j++) {
        if ((nodes[i] - nodes[j]).distance <= threshold) {
          canvas.drawLine(nodes[i], nodes[j], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MeshPainter old) => old.nodes != nodes;
}

class _Node extends StatelessWidget {
  final String id;
  final EnclosureStatus status;
  const _Node({required this.id, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 44,
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: status.color, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: status.color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(id, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  const _MapIconButton(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: AppColors.accent),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget dot(String label, Color c) => Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]);
    return Row(children: [
      dot('Normal', AppColors.normal),
      const SizedBox(width: 20),
      dot('Warning', AppColors.warning),
      const SizedBox(width: 20),
      dot('Critical', AppColors.critical),
    ]);
  }
}

class _ShowingPill extends StatelessWidget {
  final String label;
  final bool selected;
  const _ShowingPill(this.label, {this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? AppColors.accent : Colors.transparent),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 12, color: selected ? AppColors.accent : AppColors.textSecondary)),
    );
  }
}

class _FieldModeCard extends StatelessWidget {
  final FieldSyncStatus sync;
  const _FieldModeCard(this.sync);

  @override
  Widget build(BuildContext context) {
    final pct = (sync.syncedFraction * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: const [
                Icon(Icons.wifi_off, size: 15, color: AppColors.warning),
                SizedBox(width: 6),
                Text('FIELD MODE',
                    style: TextStyle(fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ]),
              Text('sync ${sync.lastSyncMinutesAgo}m ago', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Cached · ${sync.cachedEnclosures} ponds · ${sync.cachedRecords} records',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: sync.syncedFraction,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceAlt,
                  valueColor: const AlwaysStoppedAnimation(AppColors.warning),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('$pct%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 8),
          const Text('Will sync automatically when connection restored',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
