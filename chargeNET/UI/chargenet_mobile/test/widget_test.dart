import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChargeNET mobile shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ChargeNetApp(platform: ChargeNetPlatform.mobile),
      ),
    );

    expect(find.text('ChargeNET'), findsOneWidget);
    expect(find.text('Mobile'), findsOneWidget);
  });
}
