import 'package:flutter/material.dart';

/// An operator achievement badge (gamification, figma History tab).
/// Engagement layer — independent of the forecasting pipeline.
class Achievement {
  final String label;
  final IconData icon;
  final bool earned;
  const Achievement(this.label, this.icon, {this.earned = false});
}
