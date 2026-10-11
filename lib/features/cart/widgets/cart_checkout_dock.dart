import 'package:flutter/material.dart';
import '../../../core/widgets/custom_primary_button.dart';

class CartCheckoutDock extends StatelessWidget {
  final double finalTotal;
  final VoidCallback onCheckout;

  const CartCheckoutDock({
    super.key,
    required this.finalTotal,
    required this.onCheckout,
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
      child: CustomPrimaryButton(
        text: 'Place Order • \$${finalTotal.toStringAsFixed(2)}',
        height: 50,
        onPressed: onCheckout,
      ),
    );
  }
}
