import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../cart/bloc/cart_bloc.dart';
import '../../cart/bloc/cart_event.dart';
import '../../cart/screens/cart_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../models/recipe_model.dart';
import '../widgets/recipe_detail_bottom_bar.dart';
import '../widgets/recipe_detail_info_capsules.dart';
import '../widgets/recipe_detail_ingredients.dart';
import '../widgets/recipe_detail_instructions.dart';
import '../../../core/router/app_router.dart';

class RecipeDetailScreen extends StatefulWidget {
  final RecipeModel recipe;
  final String heroTag;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.heroTag,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int _quantity = 1;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.recipe.isFavorite;
  }

  void _incrementQuantity() {
    setState(() => _quantity++);
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    try {
      context.read<HomeBloc>().add(
            ToggleFavoriteEvent(widget.recipe.id, recipe: widget.recipe),
          );
    } catch (_) {}
  }

  void _addToCart() {
    context.read<CartBloc>().add(
          AddToCartEvent(
            recipe: widget.recipe,
            quantity: _quantity,
          ),
        );

    final totalPrice = (widget.recipe.price * _quantity).toStringAsFixed(1);
    UIHelpers.showTimedSnackBar(
      context,
      message: 'Added $_quantity × ${widget.recipe.name} (\$$totalPrice)',
      icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 20),
      actionLabel: 'View Cart',
      duration: const Duration(seconds: 3),
      progressColor: AppColors.primaryOrange,
      onAction: () {
        if (GoRouter.maybeOf(context) != null) {
          context.push(AppRoutes.cart);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          );
        }
      },

    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.recipe.price * _quantity;
    final formattedPrice = totalPrice.toStringAsFixed(1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroImage(),
                  const SizedBox(height: 20),
                  _buildTitleAndPrice(),
                  const SizedBox(height: 18),
                  RecipeDetailInfoCapsules(recipe: widget.recipe),
                  const SizedBox(height: 22),
                  RecipeDetailIngredients(ingredients: widget.recipe.ingredients),
                  const SizedBox(height: 24),
                  RecipeDetailInstructions(instructions: widget.recipe.instructions),
                ],
              ),
            ),
          ),
          RecipeDetailBottomBar(
            quantity: _quantity,
            formattedPrice: formattedPrice,
            onIncrement: _incrementQuantity,
            onDecrement: _decrementQuantity,
            onAddToCart: _addToCart,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
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
                  blurRadius: 8,
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
        'Food Details',
        style: AppTextStyles.screenHeading.copyWith(fontSize: 18),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: _toggleFavorite,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: const Color(0xFFE85826),
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Hero(
      tag: widget.heroTag,
      child: Container(
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: Image.network(
            widget.recipe.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFFBF1D5),
              child: const Icon(
                Icons.fastfood_rounded,
                size: 64,
                color: AppColors.primaryOrange,
              ),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: const Color(0xFFFBF1D5),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primaryOrange,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndPrice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.recipe.name,
                style: AppTextStyles.screenHeading.copyWith(
                  fontSize: 22,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.recipe.cuisine} • ${widget.recipe.mealType.join(", ")}',
                style: AppTextStyles.bodySubtitle.copyWith(
                  fontSize: 13,
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryOrange.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            '\$${widget.recipe.price.toStringAsFixed(1)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
