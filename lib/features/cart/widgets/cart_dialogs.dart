import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_primary_button.dart';

class CartDialogs {
  CartDialogs._();

  static void showClearConfirm(
    BuildContext context, {
    required VoidCallback onClear,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Cart?'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onClear();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void showOrderSuccess(
    BuildContext context, {
    required double total,
    required VoidCallback onHome,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 44,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Order Placed! 🎉',
                style: AppTextStyles.screenHeading.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                'Your delicious food is being prepared and will be delivered shortly.\nTotal Paid: \$${total.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySubtitle.copyWith(
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              CustomPrimaryButton(
                text: 'Back to Home',
                onPressed: () {
                  Navigator.pop(dialogContext);
                  onHome();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
