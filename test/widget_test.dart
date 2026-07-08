import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aquapulse/screens/app_shell.dart';
import 'package:aquapulse/theme.dart';
import 'package:aquapulse/models/enclosure.dart';
import 'package:aquapulse/models/species.dart';

void main() {
  test('statusFromDo maps DO against the species profile', () {
    final tilapia = profileFor(Species.tilapia); // doMin 3.0, doWarn 4.0
    expect(statusFromDo(7.2, tilapia), EnclosureStatus.normal);
    expect(statusFromDo(3.9, tilapia), EnclosureStatus.warning);
    expect(statusFromDo(2.8, tilapia), EnclosureStatus.critical);
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
}
