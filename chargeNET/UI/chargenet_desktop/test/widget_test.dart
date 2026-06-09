import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChargeNET desktop app shows login', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ChargeNetApp(platform: ChargeNetPlatform.desktop),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ChargeNET'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create driver account'), findsNothing);
  });
}
