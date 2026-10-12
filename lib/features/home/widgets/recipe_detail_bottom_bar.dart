import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_primary_button.dart';

class RecipeDetailBottomBar extends StatelessWidget {
  final int quantity;
  final String formattedPrice;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onAddToCart;

  const RecipeDetailBottomBar({
    super.key,
    required this.quantity,
    required this.formattedPrice,
    required this.onIncrement,
    required this.onDecrement,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.0,
        14.0,
        20.0,
        MediaQuery.of(context).padding.bottom + 14.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onDecrement,
                  child: Container(
                    width: 38,
                    height: 38,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: quantity > 1 ? Colors.white : Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow: quantity > 1
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.remove_rounded,
                      size: 18,
                      color: quantity > 1
                          ? AppColors.textDark
                          : Colors.grey[400],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onIncrement,
                  child: Container(
                    width: 38,
                    height: 38,
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: CustomPrimaryButton(
              text: 'Add to Cart • \$$formattedPrice',
              height: 50,
              onPressed: onAddToCart,
            ),
          ),
        ],
      ),
    );
  }
}
