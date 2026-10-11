import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../bloc/cart_state.dart';

class CartSummaryCard extends StatelessWidget {
  final CartState state;
  final bool couponApplied;
  final double discount;
  final double finalTotal;

  const CartSummaryCard({
    super.key,
    required this.state,
    required this.couponApplied,
    required this.discount,
    required this.finalTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppTextStyles.fieldLabel.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal', '\$${state.subtotal.toStringAsFixed(2)}'),
          if (couponApplied)
            _buildSummaryRow(
              'Discount (30%)',
              '-\$${discount.toStringAsFixed(2)}',
              textColor: const Color(0xFF2E7D32),
            ),
          _buildSummaryRow(
            'Delivery Fee',
            state.hasFreeDelivery ? 'FREE' : '\$${state.deliveryFee.toStringAsFixed(2)}',
            textColor: state.hasFreeDelivery ? const Color(0xFF2E7D32) : null,
          ),
          _buildSummaryRow(
            'Estimated Tax & Fees (5%)',
            '\$${state.tax.toStringAsFixed(2)}',
          ),
          const Divider(height: 20, color: Color(0xFFEEEEEE)),
          _buildSummaryRow(
            'Total',
            '\$${finalTotal.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String title,
    String value, {
    Color? textColor,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13.5,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColors.textDark : const Color(0xFF6E6E73),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 17 : 13.5,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: textColor ?? (isTotal ? AppColors.primaryOrange : AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
