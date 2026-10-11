import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/recipe_model.dart';

class BestSellerSection extends StatelessWidget {
  final List<RecipeModel> items;
  final void Function(RecipeModel recipe, String heroTag) onItemTap;
  final VoidCallback? onViewAllTap;

  const BestSellerSection({
    super.key,
    required this.items,
    required this.onItemTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Best Seller',
              style: AppTextStyles.screenHeading.copyWith(
                fontSize: 19.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            GestureDetector(
              onTap: onViewAllTap,
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: AppTextStyles.orangeLink.copyWith(fontSize: 13.0),
                  ),
                  const SizedBox(width: 2.0),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primaryOrange,
                    size: 18.0,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        SizedBox(
          height: 120.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12.0),
            itemBuilder: (context, index) {
              final recipe = items[index];
              final heroTag = 'recipe_bestseller_${recipe.id}';

              return GestureDetector(
                onTap: () => onItemTap(recipe, heroTag),
                child: Container(
                  width: 86.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: heroTag,
                          child: Image.network(
                            recipe.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFFBF1D5),
                              child: const Icon(Icons.fastfood_outlined, color: AppColors.primaryOrange),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFFFBF1D5),
                                child: const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryOrange,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          right: 4.0,
                          bottom: 6.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              '\$${recipe.price.toStringAsFixed(recipe.price.truncateToDouble() == recipe.price ? 1 : 2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
