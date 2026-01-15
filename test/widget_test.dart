// Gym App Widget Tests

import 'package:flutter_test/flutter_test.dart';

import 'package:gym/main.dart';

void main() {
  testWidgets('Gym app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FitHerApp());

    // Verify that the app loads without errors
    expect(find.byType(MainScreen), findsOneWidget);
  });
}
