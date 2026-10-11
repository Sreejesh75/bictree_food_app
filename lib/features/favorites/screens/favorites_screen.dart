import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../cart/bloc/cart_bloc.dart';
import '../../cart/bloc/cart_event.dart';
import '../../cart/screens/cart_screen.dart';
import '../../home/bloc/home_bloc.dart';
import '../../home/bloc/home_event.dart';
import '../../home/bloc/home_state.dart';
import '../../home/models/recipe_model.dart';
import '../../home/screens/recipe_detail_screen.dart';
import '../widgets/favorite_item_card.dart';
import '../widgets/favorites_empty_view.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  void _showClearConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Favorites?'),
        content: const Text('Are you sure you want to remove all saved recipes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HomeBloc>().add(const ClearFavoritesEvent());
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _removeFavoriteWithUndo(BuildContext context, RecipeModel recipe) {
    context.read<HomeBloc>().add(ToggleFavoriteEvent(recipe.id, recipe: recipe));

    UIHelpers.showTimedSnackBar(
      context,
      message: '${recipe.name} removed from favorites',
      actionLabel: 'UNDO',
      progressColor: const Color(0xFFE53935),
      duration: const Duration(seconds: 3),
      onAction: () {
        context.read<HomeBloc>().add(ToggleFavoriteEvent(recipe.id, recipe: recipe));
      },
    );
  }

  void _addToCart(BuildContext context, RecipeModel recipe) {
    context.read<CartBloc>().add(AddToCartEvent(recipe: recipe, quantity: 1));

    UIHelpers.showTimedSnackBar(
      context,
      message: 'Added 1 × ${recipe.name} (\$${recipe.price.toStringAsFixed(1)})',
      icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 20),
      actionLabel: 'View Cart',
      progressColor: AppColors.primaryOrange,
      duration: const Duration(seconds: 3),
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
          'My Favorites',
          style: AppTextStyles.screenHeading.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state.favorites.isEmpty) return const SizedBox.shrink();
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
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.favorites.isEmpty) {
            return FavoritesEmptyView(
              onExploreMenu: () => Navigator.pop(context),
            );
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(18.0),
            children: [
              // Header counter banner
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_rounded, color: Color(0xFFE53935), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${state.favorites.length} Saved ${state.favorites.length == 1 ? 'Dish' : 'Dishes'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Tap to view details',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Favorites List
              ...state.favorites.map((recipe) {
                return FavoriteItemCard(
                  recipe: recipe,
                  onTap: () {
                    final homeBloc = context.read<HomeBloc>();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: homeBloc,
                          child: RecipeDetailScreen(
                            recipe: recipe,
                            heroTag: 'fav_${recipe.id}',
                          ),
                        ),
                      ),
                    );
                  },
                  onToggleFavorite: () => _removeFavoriteWithUndo(context, recipe),
                  onAddToCart: () => _addToCart(context, recipe),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
