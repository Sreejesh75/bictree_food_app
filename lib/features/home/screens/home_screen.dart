import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/curved_bottom_nav_bar.dart';
import '../../../core/widgets/custom_primary_button.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/models/auth_user.dart';
import '../../cart/bloc/cart_bloc.dart';
import '../../cart/bloc/cart_state.dart';
import '../../cart/screens/cart_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../models/recipe_model.dart';
import '../repository/recipe_repository.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/best_seller_section.dart';
import '../widgets/category_chips.dart';
import '../widgets/home_header.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_shimmer.dart';
import '../widgets/sort_bottom_sheet.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthUser user;

  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (context) => HomeBloc(
        repository: RecipeRepository(),
      )..add(const FetchInitialRecipesEvent()),
      child: _HomeView(user: user),
    );
  }
}

class _HomeView extends StatefulWidget {
  final AuthUser user;

  const _HomeView({required this.user});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final ScrollController _scrollController = ScrollController();
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      context.read<HomeBloc>().add(const FetchMoreRecipesEvent());
    }
  }

  void _openRecipeDetail(RecipeModel recipe, String heroTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailScreen(
          recipe: recipe,
          heroTag: heroTag,
        ),
      ),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CartScreen(),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    final currentSort = context.read<HomeBloc>().state.selectedSort;
    SortBottomSheet.show(
      context,
      currentSort: currentSort,
      onSortSelected: (sortOption) {
        context.read<HomeBloc>().add(SortRecipesEvent(sortOption));
      },
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(widget.user.fullName, style: AppTextStyles.fieldLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${widget.user.email}', style: AppTextStyles.bodySubtitle),
            const SizedBox(height: 4),
            Text('Username: @${widget.user.username}', style: AppTextStyles.bodySubtitle),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutRequestedEvent());
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
    });

    switch (index) {
      case 0:
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        break;
      case 1:
        _openCart();
        break;
      case 2:
        UIHelpers.showSnackBar(context, message: 'Tap on any heart icon to add favorite dishes');
        break;
      case 3:
        _showProfileDialog(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
            BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                return HomeHeader(
                  user: widget.user,
                  cartCount: cartState.totalItemCount,
                  onSearchChanged: (query) {
                    context.read<HomeBloc>().add(SearchRecipesEvent(query));
                  },
                  onFilterTap: () => _showSortSheet(context),
                  onCartTap: _openCart,
                  onNotificationTap: () => UIHelpers.showSnackBar(
                    context,
                    message: 'No new notifications',
                  ),
                  onProfileTap: () => _showProfileDialog(context),
                );
              },
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusXL),
                  ),
                ),
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state.status == HomeStatus.loading && state.recipes.isEmpty) {
                      return const SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 20.0),
                        child: RecipeShimmer(),
                      );
                    }

                    if (state.status == HomeStatus.error && state.recipes.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.wifi_off_rounded,
                                size: 56,
                                color: Color(0xFFD24B1B),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                state.errorMessage ?? 'Unable to connect to food catalog',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.inputText.copyWith(fontSize: 14.5),
                              ),
                              const SizedBox(height: 18),
                              CustomPrimaryButton(
                                text: 'Try Again',
                                width: 140,
                                height: 42,
                                onPressed: () {
                                  context.read<HomeBloc>().add(const FetchInitialRecipesEvent());
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primaryOrange,
                      onRefresh: () async {
                        context.read<HomeBloc>().add(const RefreshRecipesEvent());
                        await Future.delayed(const Duration(milliseconds: 600));
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CategoryChips(
                              selectedCategory: state.selectedCategory,
                              onCategorySelected: (cat) {
                                context.read<HomeBloc>().add(SelectCategoryEvent(cat));
                              },
                            ),
                            const SizedBox(height: 22.0),

                            if (state.bestSellers.isNotEmpty && state.searchQuery.isEmpty) ...[
                              BestSellerSection(
                                items: state.bestSellers,
                                onItemTap: (recipe, heroTag) => _openRecipeDetail(recipe, heroTag),
                                onViewAllTap: () {
                                  UIHelpers.showSnackBar(
                                    context,
                                    message: 'All Best Sellers shown below in catalog',
                                  );
                                },
                              ),
                              const SizedBox(height: 22.0),
                            ],

                            if (state.searchQuery.isEmpty && state.selectedCategory == 'All') ...[
                              BannerCarousel(
                                onBannerTap: () {
                                  UIHelpers.showSnackBar(
                                    context,
                                    message: 'Special 30% discount applied! Use coupon BICTREE30 in Cart',
                                  );
                                },
                              ),
                              const SizedBox(height: 24.0),
                            ],

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  state.searchQuery.isNotEmpty
                                      ? 'Search Results (${state.recipes.length})'
                                      : state.selectedCategory != 'All'
                                          ? '${state.selectedCategory} Dishes'
                                          : 'Recommend',
                                  style: AppTextStyles.screenHeading.copyWith(
                                    fontSize: 19.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (state.searchQuery.isEmpty)
                                  GestureDetector(
                                    onTap: () => _showSortSheet(context),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.sort_rounded,
                                          size: 16,
                                          color: AppColors.primaryOrange,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Sort',
                                          style: TextStyle(
                                            color: AppColors.primaryOrange,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14.0),

                            if (state.recipes.isEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                alignment: Alignment.center,
                                child: Text(
                                  'No recipes found for "${state.searchQuery}".',
                                  style: AppTextStyles.bodySubtitle.copyWith(fontSize: 14),
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.recipes.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14.0,
                                  mainAxisSpacing: 14.0,
                                  childAspectRatio: 0.88,
                                ),
                                itemBuilder: (context, index) {
                                  final recipe = state.recipes[index];
                                  final heroTag = 'recipe_grid_${recipe.id}';

                                  return RecipeCard(
                                    recipe: recipe,
                                    heroTag: heroTag,
                                    onTap: () => _openRecipeDetail(recipe, heroTag),
                                    onFavoriteTap: () {
                                      context.read<HomeBloc>().add(ToggleFavoriteEvent(recipe.id));
                                    },
                                  );
                                },
                              ),

                            if (state.isLoadingMore)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.primaryOrange,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            CurvedBottomNavBar(
              selectedIndex: _bottomNavIndex,
              onItemTapped: _onBottomNavTapped,
            ),
          ],
        ),
    );
  }
}
