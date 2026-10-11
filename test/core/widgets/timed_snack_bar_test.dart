import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bictree_food_app/core/widgets/timed_snack_bar.dart';

void main() {
  testWidgets('TimedSnackBarContent renders message, action, and animates line countdown',
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

    // Initial state: message and action button visible
    expect(find.text('Added 1 × Veggie Bowl'), findsOneWidget);
    expect(find.text('View Cart'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Progress starts full
    LinearProgressIndicator indicator = tester.widget(find.byType(LinearProgressIndicator));
    expect(indicator.value, 1.0);

    // Advance 1.5 seconds (halfway)
    await tester.pump(const Duration(milliseconds: 1500));
    indicator = tester.widget(find.byType(LinearProgressIndicator));
    expect(indicator.value, closeTo(0.5, 0.05));

    // Tap action
    await tester.tap(find.text('View Cart'));
    expect(actionTapped, isTrue);

    // Finish 3 second animation
    await tester.pump(const Duration(milliseconds: 1500));
    indicator = tester.widget(find.byType(LinearProgressIndicator));
    expect(indicator.value, 0.0);
  });
}
