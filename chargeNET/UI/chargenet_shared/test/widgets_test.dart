import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CnButton renders primary label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ChargeNetTheme.mobile(),
        home: const Scaffold(
          body: CnButton(label: 'Sign in', onPressed: _noop),
        ),
      ),
    );

    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('Widget gallery shows all badge variants', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ChargeNetTheme.mobile(),
        home: const WidgetGalleryScreen(),
      ),
    );

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Charging'), findsOneWidget);
    expect(find.text('Widget gallery'), findsOneWidget);
  });
}

void _noop() {}
