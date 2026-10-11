import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/recipe_model.dart';
import '../repository/recipe_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final RecipeRepository repository;

  HomeBloc({required this.repository}) : super(const HomeState()) {
    on<FetchInitialRecipesEvent>(_onFetchInitial);
    on<RefreshRecipesEvent>(_onRefresh);
    on<FetchMoreRecipesEvent>(_onFetchMore);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<SearchRecipesEvent>(_onSearch);
    on<SortRecipesEvent>(_onSort);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
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

  Future<void> _onFetchInitial(
    FetchInitialRecipesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));
    try {
      final result = await repository.getRecipes(
        limit: 10,
        skip: 0,
        category: state.selectedCategory == 'All' ? null : state.selectedCategory,
      );

      // Best sellers are top-rated recipes from initial batch
      final best = List<RecipeModel>.from(result.recipes)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      final bestSellers = best.take(4).toList();

      final sorted = _applySort(result.recipes, state.selectedSort);

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

  Future<void> _onRefresh(
    RefreshRecipesEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final result = await repository.getRecipes(
        limit: 10,
        skip: 0,
        category: state.selectedCategory == 'All' ? null : state.selectedCategory,
      );

      final best = List<RecipeModel>.from(result.recipes)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      final bestSellers = best.take(4).toList();

      final sorted = _applySort(result.recipes, state.selectedSort);

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

      final combined = List<RecipeModel>.from(state.recipes)..addAll(result.recipes);
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

      final best = List<RecipeModel>.from(result.recipes)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      final bestSellers = best.take(4).toList();

      final sorted = _applySort(result.recipes, state.selectedSort);

      emit(state.copyWith(
        status: HomeStatus.success,
        recipes: sorted,
        bestSellers: bestSellers,
        currentSkip: 0,
        hasMore: result.hasMore,
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
    final query = event.query.trim();
    emit(state.copyWith(searchQuery: query, status: HomeStatus.loading));

    try {
      final results = await repository.searchRecipes(query);
      final sorted = _applySort(results, state.selectedSort);

      emit(state.copyWith(
        status: HomeStatus.success,
        recipes: sorted,
        hasMore: false,
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

  void _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<HomeState> emit,
  ) {
    final updatedList = state.recipes.map((r) {
      if (r.id == event.recipeId) {
        return r.copyWith(isFavorite: !r.isFavorite);
      }
      return r;
    }).toList();

    emit(state.copyWith(recipes: updatedList));
  }
}
