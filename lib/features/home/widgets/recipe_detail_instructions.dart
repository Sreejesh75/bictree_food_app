import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class RecipeDetailInstructions extends StatelessWidget {
  final List<String> instructions;

  const RecipeDetailInstructions({super.key, required this.instructions});

  @override
  Widget build(BuildContext context) {
    if (instructions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instructions',
          style: AppTextStyles.screenHeading.copyWith(fontSize: 17),
        ),
        const SizedBox(height: 12),
        ...instructions.asMap().entries.map((entry) {
          final stepNum = entry.key + 1;
          final instruction = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3D2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$stepNum',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    instruction,
                    style: AppTextStyles.bodySubtitle.copyWith(
                      fontSize: 13.5,
                      color: const Color(0xFF333333),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
