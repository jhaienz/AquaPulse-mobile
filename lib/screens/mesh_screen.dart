import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mesh.dart';
import '../repositories/fixtures.dart';
import '../repositories/repositories.dart';
import '../theme.dart';
import '../widgets/gauge.dart';

/// Mesh tab — network health gauge, node latency grid, aeration checklist,
/// operator profile.
class MeshScreen extends ConsumerStatefulWidget {
  const MeshScreen({super.key});

  @override
  ConsumerState<MeshScreen> createState() => _MeshScreenState();
}

class _MeshScreenState extends ConsumerState<MeshScreen> {
  // Screen-local checklist state. IndexedStack keeps this alive across tab
  // switches; durable-across-restart persistence is Phase 7.
  final List<ChecklistItem> _checklist = List.of(fixtureChecklist);

  void _toggle(int i) => setState(() => _checklist[i] = _checklist[i].toggled());

  @override
  Widget build(BuildContext context) {
    final nodes = ref.watch(meshNodesProvider);
    final health = ref.watch(meshHealthProvider);
    final op = ref.watch(operatorProvider);
    final doneCount = _checklist.where((c) => c.done).length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Center(child: ArcGauge(percent: health, label: 'MESH HEALTH')),
          const SizedBox(height: 16),
          _NodeGrid(nodes),
          const SizedBox(height: 20),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader('AERATION CHECKLIST', '$doneCount/${_checklist.length}'),
                const SizedBox(height: 8),
                for (var i = 0; i < _checklist.length; i++) _ChecklistRow(_checklist[i], () => _toggle(i)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _OperatorCard(op),
        ],
      ),
    );
  }
}

class _NodeGrid extends StatelessWidget {
  final List<MeshNode> nodes;
  const _NodeGrid(this.nodes);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: [for (final n in nodes) _NodeCard(n)],
    );
  }
}

class _NodeCard extends StatelessWidget {
  final MeshNode node;
  const _NodeCard(this.node);

  @override
  Widget build(BuildContext context) {
    final color = node.online ? AppColors.normal : AppColors.critical;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('Node ${node.id}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 4),
          Text(node.online ? '${node.latencyMs}ms' : '—',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final ChecklistItem item;
  final VoidCallback onTap;
  const _ChecklistRow(this.item, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Icon(item.done ? Icons.check_circle : Icons.circle_outlined,
              color: item.done ? AppColors.accent : AppColors.textSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.label,
                style: TextStyle(
                  color: item.done ? AppColors.textSecondary : AppColors.textPrimary,
                  decoration: item.done ? TextDecoration.lineThrough : null,
                )),
          ),
        ]),
      ),
    );
  }
}

class _OperatorCard extends StatelessWidget {
  final Operator op;
  const _OperatorCard(this.op);

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          Row(children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.surfaceAlt,
              child: Text(op.name.split(' ').map((w) => w[0]).take(2).join(),
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(op.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('ID: ${op.id} · ${op.role}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _Stat('${op.entries}', 'Entries'),
            _Stat('${op.badges}', 'Badges'),
            _Stat('${op.streakDays}d', 'Streak'),
          ]),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final String trailing;
  const _SectionHeader(this.label, this.trailing);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold, color: AppColors.accent)),
        Text(trailing, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}
