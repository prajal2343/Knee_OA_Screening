import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_app/main.dart';

void main() {
  testWidgets(
    'Knee OA Screening app starts correctly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const KneeOAScreeningApp(),
      );

      expect(
        find.text('Welcome to Knee OA Screening'),
        findsOneWidget,
      );

      expect(
        find.text('Start New Screening'),
        findsOneWidget,
      );
    },
  );
}