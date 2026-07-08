import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enclosure.dart';
import '../models/field_log.dart';
import '../models/forecast.dart';
import '../repositories/repositories.dart';
import '../theme.dart';
import '../widgets/forecast_chart.dart';

String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// Log tab — the headline screen: operator Field Log + the hero Forecast card.
class LogScreen extends ConsumerWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(selectedEnclosureIdProvider);
    final enclosure = ref.watch(enclosureByIdProvider(id));
    final log = ref.watch(fieldLogProvider(id));
    final forecast = ref.watch(forecastProvider(id));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _Header(enclosure: enclosure.asData?.value),
          const SizedBox(height: 16),
          switch (log) {
            AsyncData(value: final e) => _FieldLogCard(e),
            AsyncError(:final error) => Text('Field log error: $error'),
            _ => const _CardSkeleton(height: 220),
          },
          const SizedBox(height: 16),
          switch (forecast) {
            AsyncData(value: final f) => _ForecastCard(f),
            AsyncError(:final error) => Text('Forecast error: $error'),
            _ => const _CardSkeleton(height: 260),
          },
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Enclosure? enclosure;
  const _Header({this.enclosure});

  @override
  Widget build(BuildContext context) {
    final now = DateTime(2026, 7, 6); // fixture "today"; real clock in a later phase
    final date = '${_weekdays[now.weekday - 1]}, ${_months[now.month - 1]} ${now.day}';
    final pond = enclosure == null ? '' : ' · ${enclosure!.name.split(' — ').first}';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AquaSense AI',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('$date$pond', style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: AppColors.surfaceAlt, shape: BoxShape.circle),
          child: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 20),
        ),
      ],
    );
  }
}

class _FieldLogCard extends StatelessWidget {
  final FieldLogEntry entry;
  const _FieldLogCard(this.entry);

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            label: 'FIELD LOG',
            trailing: '${_hhmm(entry.timestamp)} · ${entry.enclosureId}',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(entry.note,
                style: const TextStyle(color: AppColors.textPrimary, height: 1.4)),
          ),
          const SizedBox(height: 12),
          Row(children: [
            if (entry.hasPhoto)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo, color: AppColors.textSecondary),
              ),
            const SizedBox(width: 10),
            _AddPhotoButton(),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in entry.tags) _TagChip(t),
            _TagChip(const FieldTag('+ Tag', EnclosureStatus.normal), outline: true),
          ]),
        ],
      ),
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo capture lands in a later phase')),
      ),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: AppColors.textSecondary, size: 18),
            SizedBox(height: 2),
            Text('Add', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final FieldTag tag;
  final bool outline;
  const _TagChip(this.tag, {this.outline = false});

  @override
  Widget build(BuildContext context) {
    final color = tag.severity.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : color.withValues(alpha: 0.15),
        border: Border.all(color: outline ? AppColors.border : color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(tag.label,
          style: TextStyle(
              fontSize: 12,
              color: outline ? AppColors.textSecondary : color,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final Forecast f;
  const _ForecastCard(this.f);

  @override
  Widget build(BuildContext context) {
    final crossing = f.thresholdCrossing;
    final subtitle = crossing == null
        ? 'DO stable — no crash forecast'
        : 'DO at ${f.doRatePerHour.toStringAsFixed(2)} mg/L·h⁻¹ — '
            'below ${f.thresholdMgL.toStringAsFixed(1)} threshold by ${_hhmm(crossing)}';

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.critical, size: 18),
            const SizedBox(width: 6),
            Text('AI FORECAST',
                style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                    color: AppColors.critical.withValues(alpha: 0.9))),
          ]),
          const SizedBox(height: 10),
          Text(f.headline,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          ForecastChart(f),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.critical,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Actuation ("${f.recommendedAction}") is a later phase')),
              ),
              icon: const Icon(Icons.air, size: 18),
              label: Text(f.recommendedAction,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('Recommend: ${f.recommendationDetail}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

// --- shared bits ---

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

class _CardHeader extends StatelessWidget {
  final String label;
  final String trailing;
  const _CardHeader({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
                color: AppColors.accent)),
        Text(trailing, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  final double height;
  const _CardSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
