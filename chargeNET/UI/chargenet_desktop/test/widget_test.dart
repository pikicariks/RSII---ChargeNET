import 'package:chargenet_shared/chargenet_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChargeNET desktop shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ChargeNetApp(platform: ChargeNetPlatform.desktop),
      ),
    );

    expect(find.text('ChargeNET'), findsOneWidget);
    expect(find.text('Desktop'), findsOneWidget);
  });
}
