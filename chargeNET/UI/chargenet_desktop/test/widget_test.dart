import 'package:chargenet_desktop/app.dart';
import 'package:chargenet_desktop/router/routes.dart';
import 'package:chargenet_desktop/shell/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Desktop app shows login', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DesktopApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create driver account'), findsNothing);
  });

  testWidgets('Admin sidebar renders nav items', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: AdminSidebar(currentPath: AdminRoutes.dashboard),
          ),
        ),
      ),
    );

    expect(find.text('ChargeNet Admin'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Stations'), findsOneWidget);
    expect(find.text('Service Orders'), findsOneWidget);
  });
}
