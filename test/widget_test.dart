import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aquapulse/screens/app_shell.dart';
import 'package:aquapulse/theme.dart';
import 'package:aquapulse/models/enclosure.dart';
import 'package:aquapulse/models/species.dart';
import 'package:aquapulse/repositories/fixtures.dart';
import 'package:aquapulse/repositories/repositories.dart';

void main() {
  test('statusFromDo maps DO against the species profile', () {
    final tilapia = profileFor(Species.tilapia); // doMin 3.0, doWarn 4.0
    expect(statusFromDo(7.2, tilapia), EnclosureStatus.normal);
    expect(statusFromDo(3.9, tilapia), EnclosureStatus.warning);
    expect(statusFromDo(2.8, tilapia), EnclosureStatus.critical);
  });

  test('forecast threshold crossing = issuedAt + timeToThreshold', () {
    final f = fixtureForecast('A-1');
    expect(f.thresholdCrossing, f.issuedAt.add(f.timeToThreshold!));
    expect(f.thresholdCrossing!.hour, 20); // 14:32 + 6h
  });

  testWidgets('shell shows 5 tabs and History renders fixture data',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AppShell())),
    );
    await tester.pumpAndSettle();

    for (final label in ['Log', 'History', 'Mesh', 'Map', 'Settings']) {
      expect(find.text(label), findsWidgets);
    }

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Pond A-1'), findsOneWidget);
    expect(find.text('CRITICAL'), findsWidgets); // C-2 at DO 2.8
  });

  test('enclosure repository add grows the list and is findable', () async {
    final repo = FixtureEnclosureRepository();
    final before = (await repo.all()).length;
    await repo.add(const Enclosure(
      id: 'P-99', name: 'Pond 99 — Test', species: Species.shrimp,
      sizeHectares: 1, latitude: 14.5, longitude: 120.9,
    ));
    expect((await repo.all()).length, before + 1);
    expect((await repo.byId('P-99'))?.name, 'Pond 99 — Test');
  });

  testWidgets('Add-Pond sheet adds an enclosure and closes', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AppShell())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();

    expect(find.text('FIELD MODE'), findsOneWidget);
    await tester.tap(find.text('Add Pond'));
    await tester.pumpAndSettle();

    expect(find.text('Add a Pond'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Pond 7 — North Basin');
    await tester.tap(find.text('Tilapia'));
    await tester.pump();
    await tester.ensureVisible(find.text('Add Pond to Farm'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Pond to Farm'));
    await tester.pumpAndSettle();

    expect(find.text('Add a Pond'), findsNothing); // sheet closed
    expect(find.textContaining('Added'), findsOneWidget); // snackbar
  });

  testWidgets('Settings shows toggles and alert acknowledge works', (tester) async {
    tester.view.physicalSize = const Size(500, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AppShell())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Edge AI Processing'), findsOneWidget);
    expect(find.text('ALERTS'), findsOneWidget);
    // C-2 and B-3 alerts start unacknowledged.
    expect(find.text('UNACKNOWLEDGED'), findsNWidgets(2));

    // Tap the C-2 critical alert to acknowledge it.
    await tester.tap(find.textContaining('DO critical'));
    await tester.pumpAndSettle();
    expect(find.text('UNACKNOWLEDGED'), findsNWidgets(1));

    // Filter to Warning hides the (critical) remaining unacked context.
    await tester.tap(find.text('Warning'));
    await tester.pumpAndSettle();
    expect(find.textContaining('DO critical'), findsNothing);
    expect(find.textContaining('pH spike'), findsOneWidget);
  });

  testWidgets('Mesh tab renders and checklist toggles', (tester) async {
    // Tall surface so the whole Mesh tab renders without lazy-scrolling.
    tester.view.physicalSize = const Size(500, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AppShell())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mesh'));
    await tester.pumpAndSettle();

    expect(find.text('92%'), findsOneWidget);
    expect(find.text('MESH HEALTH'), findsOneWidget);
    expect(find.text('Node A-1'), findsOneWidget);
    expect(find.text('Jonas Reyes'), findsOneWidget);
    expect(find.text('247'), findsOneWidget);
    expect(find.text('2/5'), findsOneWidget);

    await tester.tap(find.text('Test emergency pump — B-3'));
    await tester.pumpAndSettle();
    expect(find.text('3/5'), findsOneWidget);
  });

  testWidgets('History shows filter chips and achievements count', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AppShell())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    for (final chip in ['All', 'Today', 'Week']) {
      expect(find.text(chip), findsOneWidget);
    }
    expect(find.text('ACHIEVEMENTS'), findsOneWidget);
    expect(find.text('9 / 12 earned'), findsOneWidget); // 9 earned fixtures
    expect(find.text('DO Defender'), findsOneWidget);
  });

  testWidgets('Log tab shows the Field Log and Forecast card', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AppShell())),
    );
    await tester.pumpAndSettle();

    // Log is the default tab.
    expect(find.text('FIELD LOG'), findsOneWidget);
    expect(find.text('AI FORECAST'), findsOneWidget);
    expect(find.text('Hypoxia likely in 6h'), findsOneWidget);
    expect(find.text('DO Critical'), findsOneWidget);
    expect(find.textContaining('Pre-stage aeration array'), findsWidgets);
  });
}
