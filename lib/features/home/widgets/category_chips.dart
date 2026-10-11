import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class CategoryItem {
  final String label;
  final String svgPath;

  const CategoryItem({
    required this.label,
    required this.svgPath,
  });
}

class CategoryChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<CategoryItem> categories = [
    CategoryItem(label: 'All', svgPath: 'assets/svg/All.svg'),
    CategoryItem(label: 'Snacks', svgPath: 'assets/svg/Snacks.svg'),
    CategoryItem(label: 'Meal', svgPath: 'assets/svg/Meals.svg'),
    CategoryItem(label: 'Vegan', svgPath: 'assets/svg/Vegan.svg'),
    CategoryItem(label: 'Dessert', svgPath: 'assets/svg/Desserts.svg'),
    CategoryItem(label: 'Drinks', svgPath: 'assets/svg/Drinks.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14.0),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory.toLowerCase() == cat.label.toLowerCase();

          return GestureDetector(
            onTap: () => onCategorySelected(cat.label),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50.0,
                  height: 75.0,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFE8AA) : const Color(0xFFFEF7E6),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryOrange : const Color(0xFFF3E7C4),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
                  child: SvgPicture.asset(
                    cat.svgPath,
                    width: 32.81,
                    height: 37.0,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  cat.label,
                  style: AppTextStyles.fieldLabel.copyWith(
                    fontSize: 12.0,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.primaryOrange : AppColors.textDark,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
