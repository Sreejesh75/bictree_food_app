import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bictree_food_app/core/widgets/timed_snack_bar.dart';

void main() {
  testWidgets(
    'TimedSnackBarContent renders message, action, and animates line countdown',
    (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimedSnackBarContent(
              message: 'Added 1 × Veggie Bowl',
              actionLabel: 'View Cart',
              duration: const Duration(seconds: 3),
              onAction: () {
                actionTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Added 1 × Veggie Bowl'), findsOneWidget);
      expect(find.text('View Cart'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      LinearProgressIndicator indicator = tester.widget(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 1.0);

      await tester.pump(const Duration(milliseconds: 1500));
      indicator = tester.widget(find.byType(LinearProgressIndicator));
      expect(indicator.value, closeTo(0.5, 0.05));

      await tester.tap(find.text('View Cart'));
      expect(actionTapped, isTrue);

      await tester.pump(const Duration(milliseconds: 1500));
      indicator = tester.widget(find.byType(LinearProgressIndicator));
      expect(indicator.value, 0.0);
    },
  );
}
