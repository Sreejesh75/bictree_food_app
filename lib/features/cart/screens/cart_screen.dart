import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_primary_button.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../models/cart_item.dart';

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

  void _removeItemWithUndo(BuildContext context, CartItem cartItem, int index) {
    context.read<CartBloc>().add(RemoveFromCartEvent(cartItem.recipe.id));

    UIHelpers.showTimedSnackBar(
      context,
      message: '${cartItem.recipe.name} removed from cart',
      actionLabel: 'UNDO',
      progressColor: AppColors.primaryOrange,
      duration: const Duration(seconds: 3),
      onAction: () {
        context.read<CartBloc>().add(
              RestoreCartItemEvent(
                item: cartItem,
                index: index,
              ),
            );
      },
    );
  }

  void _showClearConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Cart?'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CartBloc>().add(const ClearCartEvent());
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
                border: Border.all(color: const Color(0xFFEEEEEE)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textDark,
                size: 16,
              ),
            ),
          ),
        ),
        title: Text(
          'My Cart',
          style: AppTextStyles.screenHeading.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _showClearConfirmDialog(context),
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
            return _buildEmptyCartView(context);
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
                    // Delivery threshold banner
                    _buildDeliveryThresholdBanner(state),
                    const SizedBox(height: 14),

                    // Items List with Swipe to Delete
                    ...state.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final cartItem = entry.value;
                      final recipe = cartItem.recipe;

                      return Dismissible(
                        key: ValueKey('cart_item_${recipe.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 14.0),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.centerRight,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                              SizedBox(width: 6),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onDismissed: (_) => _removeItemWithUndo(context, cartItem, index),
                        child: Container(
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
                                        if (cartItem.quantity > 1) {
                                          context.read<CartBloc>().add(
                                                UpdateCartQuantityEvent(
                                                  recipeId: recipe.id,
                                                  quantity: cartItem.quantity - 1,
                                                ),
                                              );
                                        } else {
                                          _removeItemWithUndo(context, cartItem, index);
                                        }
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          cartItem.quantity > 1 ? Icons.remove : Icons.delete_outline,
                                          size: 14,
                                          color: cartItem.quantity > 1 ? AppColors.textDark : Colors.red,
                                        ),
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

                    // Bill Summary Card with live tax, fees, delivery, subtotal, and total
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
                            state.hasFreeDelivery ? 'FREE' : '\$${state.deliveryFee.toStringAsFixed(2)}',
                            textColor: state.hasFreeDelivery ? const Color(0xFF2E7D32) : null,
                          ),
                          _buildSummaryRow('Estimated Tax & Fees (5%)', '\$${state.tax.toStringAsFixed(2)}'),
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

  Widget _buildDeliveryThresholdBanner(CartState state) {
    if (state.hasFreeDelivery) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFA5D6A7)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '🎉 You have unlocked FREE Delivery!',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final progress = (state.subtotal / 50.0).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, color: AppColors.primaryOrange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Add \$${state.amountToFreeDelivery.toStringAsFixed(2)} more for FREE Delivery!',
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFFFECB3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCartView(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Layered Aura Illustration Card with Floating Food Badges
          Center(
            child: SizedBox(
              width: 240,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer subtle radial aura
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFE082).withValues(alpha: 0.35),
                          const Color(0xFFFFF8E7).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),

                  // Middle warm halo
                  Container(
                    width: 136,
                    height: 136,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFF3D2).withValues(alpha: 0.75),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withValues(alpha: 0.08),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  // Core warm glowing circle
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFFDF7),
                          Color(0xFFFFE8B0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withValues(alpha: 0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 46,
                      color: AppColors.primaryOrange,
                    ),
                  ),

                  // Floating accent badge top-left: 🍕 Pizza
                  Positioned(
                    top: 14,
                    left: 6,
                    child: _buildFloatingBadge('🍕', 'Tasty Bites'),
                  ),

                  // Floating accent badge top-right: ⭐ 4.9
                  Positioned(
                    top: 20,
                    right: 4,
                    child: _buildFloatingBadge('⭐', '4.9 Rated'),
                  ),

                  // Floating accent badge bottom-right: 🥗 Fresh
                  Positioned(
                    bottom: 16,
                    right: 14,
                    child: _buildFloatingBadge('🥗', '100% Fresh'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Friendly pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD4B8)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('😋', style: TextStyle(fontSize: 13)),
                SizedBox(width: 6),
                Text(
                  'Hungry for something good?',
                  style: TextStyle(
                    color: Color(0xFFD24B1B),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Screen Heading
          Text(
            'Your cart is empty',
            style: AppTextStyles.screenHeading.copyWith(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle description
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              'Looks like you haven\'t added any mouth-watering dishes to your cart yet.\nExplore our curated chef specials and satisfy your cravings!',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySubtitle.copyWith(
                fontSize: 13.5,
                height: 1.5,
                color: const Color(0xFF6E6E73),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Premium "Explore Menu" CTA Button (no wrapping, glorious gradient & shadow)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant_menu_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Explore Menu',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Popular choices divider
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFEBEBEB), thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'POPULAR CHOICES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFEBEBEB), thickness: 1)),
            ],
          ),

          const SizedBox(height: 16),

          // Category Shortcut Pills
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildCategoryShortcut(context, '🍕 Snacks'),
              _buildCategoryShortcut(context, '🍲 Meals'),
              _buildCategoryShortcut(context, '🥤 Drinks'),
              _buildCategoryShortcut(context, '🍰 Desserts'),
            ],
          ),

          const SizedBox(height: 30),

          // 3 Trust & Perk Badges
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPerkItem(Icons.bolt_rounded, '30 Mins', 'Fast Delivery'),
                _buildPerkDivider(),
                _buildPerkItem(Icons.verified_outlined, '100% Fresh', 'Chef Curated'),
                _buildPerkDivider(),
                _buildPerkItem(Icons.local_shipping_outlined, 'Free \$50+', 'Free Delivery'),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFloatingBadge(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryShortcut(BuildContext context, String label) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E5EA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildPerkItem(IconData icon, String title, String subtitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF4EB),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryOrange, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10.5,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPerkDivider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFEEEEEE),
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
