import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/recipe_model.dart';

class RecipeDetailInfoCapsules extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailInfoCapsules({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildCapsule(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFFB300),
            label: '${recipe.rating}',
            sublabel: '(${recipe.reviewCount} revs)',
          ),
          const SizedBox(width: 10),
          _buildCapsule(
            icon: Icons.timer_outlined,
            iconColor: AppColors.primaryOrange,
            label: '${recipe.prepTimeMinutes + recipe.cookTimeMinutes} mins',
            sublabel: 'Cook time',
          ),
          const SizedBox(width: 10),
          _buildCapsule(
            icon: Icons.people_outline_rounded,
            iconColor: const Color(0xFF2E7D32),
            label: '${recipe.servings} Servings',
            sublabel: 'Portion',
          ),
          const SizedBox(width: 10),
          _buildCapsule(
            icon: Icons.local_fire_department_outlined,
            iconColor: const Color(0xFFD32F2F),
            label: '${recipe.caloriesPerServing} kcal',
            sublabel: 'Calories',
          ),
          const SizedBox(width: 10),
          _buildCapsule(
            icon: Icons.bolt_rounded,
            iconColor: const Color(0xFF7B1FA2),
            label: recipe.difficulty,
            sublabel: 'Difficulty',
          ),
        ],
      ),
    );
  }

  Widget _buildCapsule({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String sublabel,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                sublabel,
                style: const TextStyle(fontSize: 10, color: Color(0xFF8A8A8E)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
