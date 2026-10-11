import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_primary_button.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  bool _couponApplied = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    if (code == 'BICTREE30' || code == 'FOOD30') {
      setState(() {
        _couponApplied = true;
      });
      UIHelpers.showSnackBar(context, message: '🎉 30% discount applied successfully!');
    } else {
      UIHelpers.showSnackBar(context, message: 'Invalid coupon code. Try BICTREE30', isError: true);
    }
  }

  void _showCheckoutDialog(BuildContext context, double total) {
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
                style: AppTextStyles.bodySubtitle.copyWith(fontSize: 13.5, height: 1.4),
              ),
              const SizedBox(height: 22),
              CustomPrimaryButton(
                text: 'Back to Home',
                onPressed: () {
                  context.read<CartBloc>().add(const ClearCartEvent());
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textDark,
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          'Food Cart',
          style: AppTextStyles.screenHeading.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  context.read<CartBloc>().add(const ClearCartEvent());
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: Color(0xFFE85826),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF3D2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 52,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your cart is empty',
                      style: AppTextStyles.screenHeading.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Looks like you haven\'t added any mouth-watering dishes to your cart yet.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySubtitle.copyWith(fontSize: 13.5),
                    ),
                    const SizedBox(height: 24),
                    CustomPrimaryButton(
                      text: 'Explore Menu',
                      width: 170,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            );
          }

          final discount = _couponApplied ? state.subtotal * 0.30 : 0.0;
          final finalTotal = (state.total - discount).clamp(0.0, double.infinity);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(18.0),
                  children: [
                    // Items List
                    ...state.items.map((cartItem) {
                      final recipe = cartItem.recipe;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14.0),
                        padding: const EdgeInsets.all(12.0),
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
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                recipe.image,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 72,
                                  height: 72,
                                  color: const Color(0xFFFBF1D5),
                                  child: const Icon(Icons.fastfood, color: AppColors.primaryOrange),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.fieldLabel.copyWith(fontSize: 14.5),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '\$${recipe.price.toStringAsFixed(1)} each',
                                    style: AppTextStyles.bodySubtitle.copyWith(fontSize: 12),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${cartItem.totalPrice.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      color: AppColors.primaryOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Stepper [-] QTY [+]
                            Container(
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F7),
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      context.read<CartBloc>().add(
                                            UpdateCartQuantityEvent(
                                              recipeId: recipe.id,
                                              quantity: cartItem.quantity - 1,
                                            ),
                                          );
                                    },
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.remove, size: 14, color: AppColors.textDark),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      '${cartItem.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.read<CartBloc>().add(
                                            UpdateCartQuantityEvent(
                                              recipeId: recipe.id,
                                              quantity: cartItem.quantity + 1,
                                            ),
                                          );
                                    },
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add, size: 14, color: AppColors.textDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),

                    // Promo Code Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _couponApplied ? const Color(0xFF4CAF50) : const Color(0xFFEBEBEB),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 20,
                            color: _couponApplied ? const Color(0xFF4CAF50) : AppColors.primaryOrange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              enabled: !_couponApplied,
                              decoration: InputDecoration(
                                hintText: _couponApplied ? 'BICTREE30 Applied (30% OFF)' : 'Promo Code (Try BICTREE30)',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: _couponApplied ? const Color(0xFF2E7D32) : Colors.grey[400],
                                  fontWeight: _couponApplied ? FontWeight.w600 : FontWeight.normal,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _couponApplied
                                ? () {
                                    setState(() {
                                      _couponApplied = false;
                                      _couponController.clear();
                                    });
                                  }
                                : _applyCoupon,
                            child: Text(
                              _couponApplied ? 'Remove' : 'Apply',
                              style: TextStyle(
                                color: _couponApplied ? Colors.red : AppColors.primaryOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Bill Summary Card
                    Container(
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
                          if (_couponApplied)
                            _buildSummaryRow(
                              'Discount (30%)',
                              '-\$${discount.toStringAsFixed(2)}',
                              textColor: const Color(0xFF2E7D32),
                            ),
                          _buildSummaryRow(
                            'Delivery Fee',
                            state.deliveryFee == 0 ? 'FREE' : '\$${state.deliveryFee.toStringAsFixed(2)}',
                            textColor: state.deliveryFee == 0 ? const Color(0xFF2E7D32) : null,
                          ),
                          _buildSummaryRow('Estimated Tax (5%)', '\$${state.tax.toStringAsFixed(2)}'),
                          const Divider(height: 20, color: Color(0xFFEEEEEE)),
                          _buildSummaryRow(
                            'Total',
                            '\$${finalTotal.toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Bottom Checkout Dock
              Container(
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
                  onPressed: () => _showCheckoutDialog(context, finalTotal),
                ),
              ),
            ],
          );
        },
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
