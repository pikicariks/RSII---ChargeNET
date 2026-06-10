import 'package:chargenet_mobile/app.dart';
import 'package:chargenet_mobile/shell/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Mobile app shows login', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MobileApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create driver account'), findsOneWidget);
  });

  testWidgets('Mobile bottom nav renders tabs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: MobileBottomNav(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Map'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
