import 'package:flutter/material.dart';
import '../theme.dart';

/// Phase-0 stand-in for tabs not yet built. Replaced screen-by-screen
/// through phases 1–5 (see docs/PLAN.md).
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String phase;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.phase,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(phase, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
