import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bictree_food_app/core/widgets/curved_bottom_nav_bar.dart';

void main() {
  testWidgets('CurvedBottomNavBar renders 5 Figma SVG icons and handles tap', (
    tester,
  ) async {
    int tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CurvedBottomNavBar(
            selectedIndex: 0,
            onItemTapped: (index) {
              tappedIndex = index;
            },
          ),
        ),
      ),
    );

    expect(find.byType(SvgPicture), findsNWidgets(5));

    await tester.tap(find.byType(SvgPicture).at(1));
    await tester.pumpAndSettle();

    expect(tappedIndex, 1);
  });
}
