import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';
import '../repository/recipe_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static const String _favStorageKey = 'bictree_persisted_favorites_v1';
  final RecipeRepository repository;

  HomeBloc({required this.repository}) : super(const HomeState()) {
    on<FetchInitialRecipesEvent>(_onFetchInitial);
    on<RefreshRecipesEvent>(_onRefresh);
    on<FetchMoreRecipesEvent>(_onFetchMore);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<SearchRecipesEvent>(_onSearch);
    on<SortRecipesEvent>(_onSort);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<ClearFavoritesEvent>(_onClearFavorites);
  }

  List<RecipeModel> _applySort(List<RecipeModel> items, SortOption option) {
    final list = List<RecipeModel>.from(items);
    switch (option) {
      case SortOption.ratingHighToLow:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.caloriesLowToHigh:
        list.sort((a, b) => a.caloriesPerServing.compareTo(b.caloriesPerServing));
        break;
    }
    return list;
  }

  Future<List<RecipeModel>> _loadFavoritesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_favStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        return decoded
            .map((item) => RecipeModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveFavoritesToStorage(List<RecipeModel> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(favorites.map((r) => r.toJson()).toList());
      await prefs.setString(_favStorageKey, encoded);
    } catch (_) {}
  }

  Future<void> _onFetchInitial(
    FetchInitialRecipesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));
    try {
      final savedFavorites = await _loadFavoritesFromStorage();
      final result = await repository.getRecipes(
        limit: 10,
        skip: 0,
        category: state.selectedCategory == 'All' ? null : state.selectedCategory,
      );

      final recipesWithFavs = result.recipes.map((r) {
        final isFav = savedFavorites.any((fav) => fav.id == r.id);
        return r.copyWith(isFavorite: isFav);
      }).toList();

      final best = List<RecipeModel>.from(recipesWithFavs)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      final bestSellers = best.take(4).toList();

      final sorted = _applySort(recipesWithFavs, state.selectedSort);

      emit(state.copyWith(
        status: HomeStatus.success,
        recipes: sorted,
        bestSellers: bestSellers,
        favorites: savedFavorites,
        currentSkip: 0,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onRefresh(
    RefreshRecipesEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final savedFavorites = await _loadFavoritesFromStorage();
      final result = await repository.getRecipes(
        limit: 10,
        skip: 0,
        category: state.selectedCategory == 'All' ? null : state.selectedCategory,
      );

      final recipesWithFavs = result.recipes.map((r) {
        final isFav = savedFavorites.any((fav) => fav.id == r.id);
        return r.copyWith(isFavorite: isFav);
      }).toList();

      final best = List<RecipeModel>.from(recipesWithFavs)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      final bestSellers = best.take(4).toList();

      final sorted = _applySort(recipesWithFavs, state.selectedSort);

      emit(state.copyWith(
        status: HomeStatus.success,
        recipes: sorted,
        bestSellers: bestSellers,
        favorites: savedFavorites,
        currentSkip: 0,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onFetchMore(
    FetchMoreRecipesEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore || state.searchQuery.isNotEmpty) return;

    emit(state.copyWith(isLoadingMore: true));
    try {
      final nextSkip = state.currentSkip + 10;
      final result = await repository.getRecipes(
        limit: 10,
        skip: nextSkip,
        category: state.selectedCategory == 'All' ? null : state.selectedCategory,
      );

      final recipesWithFavs = result.recipes.map((r) {
        final isFav = state.favorites.any((fav) => fav.id == r.id);
        return r.copyWith(isFavorite: isFav);
      }).toList();

      final combined = List<RecipeModel>.from(state.recipes)..addAll(recipesWithFavs);
      final sorted = _applySort(combined, state.selectedSort);

      emit(state.copyWith(
        recipes: sorted,
        currentSkip: nextSkip,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onSelectCategory(
    SelectCategoryEvent event,
    Emitter<HomeState> emit,
  ) async {
    final String newCategory =
        event.category == 'All' ? 'All' : (state.selectedCategory == event.category ? 'All' : event.category);

    emit(state.copyWith(
      selectedCategory: newCategory,
      status: HomeStatus.loading,
      searchQuery: '',
    ));

    try {
      final result = await repository.getRecipes(
        limit: 10,
        skip: 0,
        category: newCategory == 'All' ? null : newCategory,
      );

      final recipesWithFavs = result.recipes.map((r) {
        final isFav = state.favorites.any((fav) => fav.id == r.id);
        return r.copyWith(isFavorite: isFav);
      }).toList();

      final best = List<RecipeModel>.from(recipesWithFavs)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      final bestSellers = best.take(4).toList();

      final sorted = _applySort(recipesWithFavs, state.selectedSort);

      emit(state.copyWith(
        status: HomeStatus.success,
        recipes: sorted,
        bestSellers: bestSellers,
        currentSkip: 0,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSearch(
    SearchRecipesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query, status: HomeStatus.loading));

    try {
      final result = await repository.searchRecipes(event.query);
      final recipesWithFavs = result.map((r) {
        final isFav = state.favorites.any((fav) => fav.id == r.id);
        return r.copyWith(isFavorite: isFav);
      }).toList();

      final sorted = _applySort(recipesWithFavs, state.selectedSort);

      emit(state.copyWith(
        status: HomeStatus.success,
        recipes: sorted,
        currentSkip: 0,
        hasMore: false,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onSort(
    SortRecipesEvent event,
    Emitter<HomeState> emit,
  ) {
    final sorted = _applySort(state.recipes, event.sortOption);
    emit(state.copyWith(
      selectedSort: event.sortOption,
      recipes: sorted,
    ));
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<HomeState> emit,
  ) async {
    RecipeModel? target = event.recipe;
    for (final r in state.recipes) {
      if (r.id == event.recipeId) {
        target ??= r;
        break;
      }
    }
    target ??= state.bestSellers.cast<RecipeModel?>().firstWhere(
          (r) => r?.id == event.recipeId,
          orElse: () => null,
        );
    target ??= state.favorites.cast<RecipeModel?>().firstWhere(
          (r) => r?.id == event.recipeId,
          orElse: () => null,
        );

    final updatedRecipes = state.recipes.map((r) {
      if (r.id == event.recipeId) {
        return r.copyWith(isFavorite: !r.isFavorite);
      }
      return r;
    }).toList();

    final updatedBestSellers = state.bestSellers.map((r) {
      if (r.id == event.recipeId) {
        return r.copyWith(isFavorite: !r.isFavorite);
      }
      return r;
    }).toList();

    final updatedFavorites = List<RecipeModel>.from(state.favorites);
    final favIndex = updatedFavorites.indexWhere((r) => r.id == event.recipeId);

    if (favIndex >= 0) {
      updatedFavorites.removeAt(favIndex);
    } else if (target != null) {
      updatedFavorites.add(target.copyWith(isFavorite: true));
    }

    emit(state.copyWith(
      recipes: updatedRecipes,
      bestSellers: updatedBestSellers,
      favorites: updatedFavorites,
    ));

    await _saveFavoritesToStorage(updatedFavorites);
  }

  Future<void> _onClearFavorites(
    ClearFavoritesEvent event,
    Emitter<HomeState> emit,
  ) async {
    final updatedRecipes = state.recipes.map((r) => r.copyWith(isFavorite: false)).toList();
    final updatedBestSellers = state.bestSellers.map((r) => r.copyWith(isFavorite: false)).toList();

    emit(state.copyWith(
      recipes: updatedRecipes,
      bestSellers: updatedBestSellers,
      favorites: const [],
    ));

    await _saveFavoritesToStorage(const []);
  }
}
