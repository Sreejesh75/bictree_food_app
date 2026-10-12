import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/curved_bottom_nav_bar.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/models/auth_user.dart';
import '../../cart/bloc/cart_bloc.dart';
import '../../cart/bloc/cart_event.dart';
import '../../cart/bloc/cart_state.dart';
import '../../cart/screens/cart_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../models/recipe_model.dart';
import '../repository/recipe_repository.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/best_seller_section.dart';
import '../widgets/category_chips.dart';
import '../widgets/home_header.dart';
import '../../../core/router/app_router.dart';
import '../../auth/screens/login_screen.dart';
import '../widgets/friendly_empty_view.dart';
import '../widgets/friendly_error_view.dart';
import '../widgets/offline_banner.dart';
import '../widgets/order_history_sheet.dart';
import '../widgets/profile_sheet.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_shimmer.dart';
import '../widgets/sort_bottom_sheet.dart';
import '../widgets/support_concierge_sheet.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthUser user;

  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    try {
      context.read<HomeBloc>();
      return _HomeView(user: user);
    } catch (_) {
      return BlocProvider<HomeBloc>(
        create: (context) => HomeBloc(
          repository: RecipeRepository(),
        )..add(const FetchInitialRecipesEvent()),
        child: _HomeView(user: user),
      );
    }
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

  String _getUserKey(AuthUser user) {
    if (user.username.isNotEmpty) return user.username.toLowerCase();
    if (user.id > 0) return 'user_${user.id}';
    if (user.email.isNotEmpty) return user.email.toLowerCase();
    return 'default_user';
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    final userKey = _getUserKey(widget.user);
    context.read<CartBloc>().add(LoadCartEvent(userId: userKey));
    context.read<HomeBloc>().add(LoadFavoritesForUserEvent(userKey));
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
    if (GoRouter.maybeOf(context) != null) {
      context.push(
        AppRoutes.recipeDetail,
        extra: {'recipe': recipe, 'heroTag': heroTag},
      );
    } else {
      final homeBloc = context.read<HomeBloc>();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: homeBloc,
            child: RecipeDetailScreen(
              recipe: recipe,
              heroTag: heroTag,
            ),
          ),
        ),
      );
    }
  }

  void _openCart() {
    if (GoRouter.maybeOf(context) != null) {
      context.push(AppRoutes.cart).then((_) {
        if (mounted) setState(() => _bottomNavIndex = 0);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CartScreen(),
        ),
      ).then((_) {
        if (mounted) setState(() => _bottomNavIndex = 0);
      });
    }
  }

  void _openFavorites() {
    if (GoRouter.maybeOf(context) != null) {
      context.push(AppRoutes.favorites).then((_) {
        if (mounted) setState(() => _bottomNavIndex = 0);
      });
    } else {
      final homeBloc = context.read<HomeBloc>();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: homeBloc,
            child: const FavoritesScreen(),
          ),
        ),
      ).then((_) {
        if (mounted) setState(() => _bottomNavIndex = 0);
      });
    }
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

  void _openProfile() {
    ProfileSheet.show(context, user: widget.user);
  }

  void _openOrderHistory() {
    OrderHistorySheet.show(context).then((_) {
      if (mounted) setState(() => _bottomNavIndex = 0);
    });
  }

  void _openSupportConcierge() {
    SupportConciergeSheet.show(context).then((_) {
      if (mounted) setState(() => _bottomNavIndex = 0);
    });
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
        _openFavorites();
        break;
      case 3:
        _openOrderHistory();
        break;
      case 4:
        _openSupportConcierge();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.headerYellow,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is UnauthenticatedState) {
            if (GoRouter.maybeOf(context) != null) {
              context.go(AppRoutes.login);
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        },

        child: RefreshIndicator(
          color: AppColors.primaryOrange,
          onRefresh: () async {
            context.read<HomeBloc>().add(const RefreshRecipesEvent());
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Section (scrolls smoothly with page content)
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
                      onProfileTap: _openProfile,
                    );
                  },
                ),

                // Main Content Card with rounded top corners
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 160,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.radiusXL),
                    ),
                  ),
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state.status == HomeStatus.loading && state.recipes.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 20.0),
                          child: RecipeShimmer(),
                        );
                      }

                      if (state.status == HomeStatus.error && state.recipes.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 40.0),
                          child: FriendlyErrorView(
                            failure: state.failure,
                            errorMessage: state.errorMessage,
                            onRetry: () {
                              context.read<HomeBloc>().add(const FetchInitialRecipesEvent());
                            },
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Visible Offline Banner when offline & showing cached items
                            if (state.isOffline) ...[
                              OfflineBanner(
                                cachedItemsCount: state.recipes.length,
                                onRetry: () {
                                  context.read<HomeBloc>().add(const RefreshRecipesEvent());
                                },
                              ),
                              const SizedBox(height: 8.0),
                            ],

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
                              FriendlyEmptyView(
                                searchQuery: state.searchQuery,
                                category: state.selectedCategory,
                                onClearSearch: () {
                                  context.read<HomeBloc>().add(const SearchRecipesEvent(''));
                                  context.read<HomeBloc>().add(const SelectCategoryEvent('All'));
                                },
                                onSuggestionTap: (suggestion) {
                                  context.read<HomeBloc>().add(SearchRecipesEvent(suggestion));
                                },
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
                            const SizedBox(height: 80.0),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CurvedBottomNavBar(
        selectedIndex: _bottomNavIndex,
        onItemTapped: _onBottomNavTapped,
      ),
    );
  }
}
