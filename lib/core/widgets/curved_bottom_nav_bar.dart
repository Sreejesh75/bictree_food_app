import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

class CurvedBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onItemTapped;

  const CurvedBottomNavBar({
    super.key,
    this.selectedIndex = 0,
    this.onItemTapped,
  });

  static const List<String> _svgIcons = [
    'assets/svg/home.svg',
    'assets/svg/cart_2.svg',
    'assets/svg/fav.svg',
    'assets/svg/history.svg',
    'assets/svg/support.svg',
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.bottomNavBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30.0),
        ),
      ),
      padding: EdgeInsets.only(
        top: 20.0,
        bottom: bottomPadding > 0 ? bottomPadding + 6.0 : 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_svgIcons.length, (index) {
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => onItemTapped?.call(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isSelected ? 1.0 : 0.85,
              child: SizedBox(
                width: 25.0,
                height: 22.0,
                child: SvgPicture.asset(
                  _svgIcons[index],
                  width: 25.0,
                  height: 22.0,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
