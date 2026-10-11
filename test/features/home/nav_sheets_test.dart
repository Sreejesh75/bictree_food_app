import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bictree_food_app/features/home/widgets/order_history_sheet.dart';
import 'package:bictree_food_app/features/home/widgets/support_concierge_sheet.dart';

void main() {
  group('Navigation Bar Bottom Sheets Tests', () {
    testWidgets('1. OrderHistorySheet renders preview badge, features, and waitlist button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => OrderHistorySheet.show(context),
                child: const Text('Open History'),
              ),
            ),
          ),
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open History'));
      await tester.pumpAndSettle();

      // Check contents
      expect(find.text('Order History & Live Tracking'), findsOneWidget);
      expect(find.text('✨ FEATURE PREVIEW'), findsOneWidget);
      expect(find.text('COMING SOON'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.text('Live GPS Telemetry'), findsOneWidget);
      expect(find.text('Digital PDF Receipts'), findsOneWidget);
      expect(find.text('1-Tap Quick Reorder'), findsOneWidget);

      // Tap Notify Me
      final notifyBtn = find.text('Notify Me When Available');
      expect(notifyBtn, findsOneWidget);
      await tester.ensureVisible(notifyBtn);
      await tester.tap(notifyBtn);
      await tester.pumpAndSettle();

      // Check button state updated
      expect(find.text('Waitlist Active • We Will Notify You'), findsOneWidget);

      // Tap top back button to dismiss sheet
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(OrderHistorySheet), findsNothing);
    });

    testWidgets('2. SupportConciergeSheet renders 24/7 VIP badge, contact options, and expands FAQ',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => SupportConciergeSheet.show(context),
                child: const Text('Open Support'),
              ),
            ),
          ),
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open Support'));
      await tester.pumpAndSettle();

      // Check contents
      expect(find.text('Customer Care & Concierge'), findsOneWidget);
      expect(find.text('🎧 24/7 VIP CONCIERGE'), findsOneWidget);
      expect(find.text('COMING SOON'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.text('Live Concierge Chat'), findsOneWidget);
      expect(find.text('Toll-Free Hotline'), findsOneWidget);
      expect(find.text('VIP Email Assistance'), findsOneWidget);

      // Tap FAQ to expand
      final faqQuestion = find.text('How can I track or modify an active order?');
      expect(faqQuestion, findsOneWidget);
      await tester.ensureVisible(faqQuestion);
      await tester.tap(faqQuestion);
      await tester.pumpAndSettle();

      // Check FAQ answer revealed
      expect(find.textContaining('You can view real-time delivery estimates'), findsOneWidget);

      // Tap top back button to dismiss sheet
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(SupportConciergeSheet), findsNothing);
    });
  });
}
