import 'package:flutter/material.dart';

import '../theme.dart';
import 'history_screen.dart';
import 'log_screen.dart';
import 'placeholder_screen.dart';

/// Root shell: 5 fixed tabs via IndexedStack (no go_router — YAGNI).
/// Tab order matches the figma bottom nav: Log · History · Mesh · Map · Settings.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    LogScreen(),
    HistoryScreen(),
    PlaceholderScreen(title: 'Mesh', phase: 'Phase 4 — node health + checklist', icon: Icons.sensors),
    PlaceholderScreen(title: 'Map', phase: 'Phase 3 — enclosure map + Add-Pond', icon: Icons.location_on_outlined),
    PlaceholderScreen(title: 'Settings', phase: 'Phase 5 — toggles + alerts', icon: Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description, color: AppColors.accent), label: 'Log'),
          NavigationDestination(icon: Icon(Icons.show_chart), selectedIcon: Icon(Icons.show_chart, color: AppColors.accent), label: 'History'),
          NavigationDestination(icon: Icon(Icons.sensors), selectedIcon: Icon(Icons.sensors, color: AppColors.accent), label: 'Mesh'),
          NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on, color: AppColors.accent), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings, color: AppColors.accent), label: 'Settings'),
        ],
      ),
    );
  }
}
