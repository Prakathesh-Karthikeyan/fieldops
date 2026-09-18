import 'package:flutter_test/flutter_test.dart';

import 'package:fieldops/main.dart';

void main() {
  testWidgets('App boots to login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FieldOpsApp());

    // Trigger the splash screen's 2-second delayed navigation.
    await tester.pump(const Duration(seconds: 2));

    // Let the page-transition animation finish settling on LoginScreen.
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
  });
}