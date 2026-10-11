import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../bloc/home_event.dart';

class SortBottomSheet extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption> onSortSelected;

  const SortBottomSheet({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required SortOption currentSort,
    required ValueChanged<SortOption> onSortSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (_) => SortBottomSheet(
        currentSort: currentSort,
        onSortSelected: onSortSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22.0, 16.0, 22.0, 22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18.0),

            Text(
              'Sort Dishes By',
              style: AppTextStyles.screenHeading.copyWith(fontSize: 18.0),
            ),
            const SizedBox(height: 14.0),

            _buildSortOption(
              context,
              title: 'Top Rated',
              subtitle: 'Highest user rating first',
              icon: Icons.star_rounded,
              value: SortOption.ratingHighToLow,
            ),
            _buildSortOption(
              context,
              title: 'Price: Low to High',
              subtitle: 'Most budget-friendly dishes first',
              icon: Icons.arrow_upward_rounded,
              value: SortOption.priceLowToHigh,
            ),
            _buildSortOption(
              context,
              title: 'Price: High to Low',
              subtitle: 'Premium and special dishes first',
              icon: Icons.arrow_downward_rounded,
              value: SortOption.priceHighToLow,
            ),
            _buildSortOption(
              context,
              title: 'Calories: Low to High',
              subtitle: 'Light and diet-friendly options',
              icon: Icons.local_fire_department_rounded,
              value: SortOption.caloriesLowToHigh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required SortOption value,
  }) {
    final isSelected = currentSort == value;

    return InkWell(
      onTap: () {
        onSortSelected(value);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
        margin: const EdgeInsets.only(bottom: 6.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF6EE) : Colors.transparent,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryOrange : const Color(0xFF8A8A8E),
              size: 22,
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? AppColors.primaryOrange : AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF8A8A8E),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryOrange,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
