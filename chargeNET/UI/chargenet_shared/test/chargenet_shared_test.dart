import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mobile theme uses emerald primary', () {
    final theme = ChargeNetTheme.mobile();
    expect(theme.colorScheme.primary, ChargeNetColors.primary);
    expect(theme.scaffoldBackgroundColor, ChargeNetColors.background);
  });

  test('desktop theme uses emerald primary', () {
    final theme = ChargeNetTheme.desktop();
    expect(theme.colorScheme.primary, ChargeNetColors.primary);
  });

  testWidgets('ChargeNetShell renders branding', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ChargeNetTheme.mobile(),
        home: const ChargeNetShell(platform: ChargeNetPlatform.mobile),
      ),
    );

    expect(find.text('ChargeNET'), findsOneWidget);
    expect(find.text('Mobile'), findsOneWidget);
    expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
  });
}
