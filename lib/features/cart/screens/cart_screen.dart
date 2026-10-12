import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../models/cart_item.dart';
import '../widgets/cart_checkout_dock.dart';
import '../widgets/cart_delivery_banner.dart';
import '../widgets/cart_dialogs.dart';
import '../widgets/cart_empty_view.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_promo_section.dart';
import '../widgets/cart_summary_card.dart';

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
      setState(() => _couponApplied = true);
      UIHelpers.showSnackBar(
        context,
        message: '🎉 30% discount applied successfully!',
      );
    } else {
      UIHelpers.showSnackBar(
        context,
        message: 'Invalid coupon code. Try BICTREE30',
        isError: true,
      );
    }
  }

  void _removeCoupon() {
    setState(() {
      _couponApplied = false;
      _couponController.clear();
    });
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
          RestoreCartItemEvent(item: cartItem, index: index),
        );
      },
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
                onPressed: () {
                  CartDialogs.showClearConfirm(
                    context,
                    onClear: () =>
                        context.read<CartBloc>().add(const ClearCartEvent()),
                  );
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
            return const CartEmptyView();
          }

          final discount = _couponApplied ? state.subtotal * 0.30 : 0.0;
          final finalTotal = (state.total - discount).clamp(
            0.0,
            double.infinity,
          );

          return Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(18.0),
                  children: [
                    CartDeliveryBanner(state: state),
                    const SizedBox(height: 14),
                    ...state.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final cartItem = entry.value;

                      return CartItemTile(
                        cartItem: cartItem,
                        onIncrement: () {
                          context.read<CartBloc>().add(
                            UpdateCartQuantityEvent(
                              recipeId: cartItem.recipe.id,
                              quantity: cartItem.quantity + 1,
                            ),
                          );
                        },
                        onDecrement: () {
                          if (cartItem.quantity > 1) {
                            context.read<CartBloc>().add(
                              UpdateCartQuantityEvent(
                                recipeId: cartItem.recipe.id,
                                quantity: cartItem.quantity - 1,
                              ),
                            );
                          } else {
                            _removeItemWithUndo(context, cartItem, index);
                          }
                        },
                        onDismissed: () =>
                            _removeItemWithUndo(context, cartItem, index),
                      );
                    }),
                    const SizedBox(height: 12),
                    CartPromoSection(
                      controller: _couponController,
                      isApplied: _couponApplied,
                      onApply: _applyCoupon,
                      onRemove: _removeCoupon,
                    ),
                    const SizedBox(height: 18),
                    CartSummaryCard(
                      state: state,
                      couponApplied: _couponApplied,
                      discount: discount,
                      finalTotal: finalTotal,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              CartCheckoutDock(
                finalTotal: finalTotal,
                onCheckout: () {
                  CartDialogs.showOrderSuccess(
                    context,
                    total: finalTotal,
                    onHome: () {
                      context.read<CartBloc>().add(const ClearCartEvent());
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
