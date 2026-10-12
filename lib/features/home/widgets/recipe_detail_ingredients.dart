import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class RecipeDetailIngredients extends StatelessWidget {
  final List<String> ingredients;

  const RecipeDetailIngredients({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ingredients',
              style: AppTextStyles.screenHeading.copyWith(fontSize: 17),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3D2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${ingredients.length} items',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ingredients
              .map(
                (ing) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3D2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ing,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
