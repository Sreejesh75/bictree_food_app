import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_primary_button.dart';
import '../../cart/bloc/cart_bloc.dart';
import '../../cart/bloc/cart_event.dart';
import '../../cart/screens/cart_screen.dart';
import '../models/recipe_model.dart';
import '../screens/recipe_detail_screen.dart';

class RecipeDetailsSheet extends StatefulWidget {
  final RecipeModel recipe;
  final String heroTag;

  const RecipeDetailsSheet({
    super.key,
    required this.recipe,
    this.heroTag = '',
  });

  static Future<void> show(
    BuildContext context,
    RecipeModel recipe, {
    String heroTag = '',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => RecipeDetailsSheet(
        recipe: recipe,
        heroTag: heroTag.isEmpty ? 'recipe_sheet_${recipe.id}' : heroTag,
      ),
    );
  }

  @override
  State<RecipeDetailsSheet> createState() => _RecipeDetailsSheetState();
}

class _RecipeDetailsSheetState extends State<RecipeDetailsSheet> {
  int _quantity = 1;

  void _increment() {
    setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  void _addToCart() {
    context.read<CartBloc>().add(
          AddToCartEvent(
            recipe: widget.recipe,
            quantity: _quantity,
          ),
        );
    Navigator.pop(context);
    final totalPrice = (widget.recipe.price * _quantity).toStringAsFixed(1);
    UIHelpers.showTimedSnackBar(
      context,
      message: 'Added $_quantity × ${widget.recipe.name} (\$$totalPrice)',
      icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 20),
      actionLabel: 'View Cart',
      duration: const Duration(seconds: 3),
      progressColor: AppColors.primaryOrange,
      onAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = (widget.recipe.price * _quantity).toStringAsFixed(1);

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollSheetController) => SingleChildScrollView(
        controller: scrollSheetController,
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                widget.recipe.image,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: const Color(0xFFFBF1D5),
                  child: const Icon(Icons.fastfood, size: 50, color: AppColors.primaryOrange),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.recipe.name,
                    style: AppTextStyles.screenHeading.copyWith(fontSize: 20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '\$${widget.recipe.price.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 18),
                const SizedBox(width: 4),
                Text(
                  '${widget.recipe.rating} (${widget.recipe.reviewCount} reviews)',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.timer_outlined, color: AppColors.primaryOrange, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${widget.recipe.prepTimeMinutes + widget.recipe.cookTimeMinutes} mins',
                  style: const TextStyle(color: Color(0xFF8A8A8E), fontSize: 13),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(
                          recipe: widget.recipe,
                          heroTag: widget.heroTag,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Full Details →',
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ingredients',
              style: AppTextStyles.fieldLabel.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.recipe.ingredients
                  .map(
                    (ing) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3D2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        ing,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Quantity Selector [-] QTY [+]
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _decrement,
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _quantity > 1 ? Colors.white : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: _quantity > 1 ? AppColors.textDark : Colors.grey[400],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _increment,
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomPrimaryButton(
                    text: 'Add to Cart • \$$totalPrice',
                    height: 48,
                    onPressed: _addToCart,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
