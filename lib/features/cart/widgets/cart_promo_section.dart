import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CartPromoSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isApplied;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const CartPromoSection({
    super.key,
    required this.controller,
    required this.isApplied,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApplied ? const Color(0xFF4CAF50) : const Color(0xFFEBEBEB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 20,
            color: isApplied ? const Color(0xFF4CAF50) : AppColors.primaryOrange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isApplied,
              decoration: InputDecoration(
                hintText: isApplied
                    ? 'BICTREE30 Applied (30% OFF)'
                    : 'Promo Code (Try BICTREE30)',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isApplied ? const Color(0xFF2E7D32) : Colors.grey[400],
                  fontWeight: isApplied ? FontWeight.w600 : FontWeight.normal,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          TextButton(
            onPressed: isApplied ? onRemove : onApply,
            child: Text(
              isApplied ? 'Remove' : 'Apply',
              style: TextStyle(
                color: isApplied ? Colors.red : AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
