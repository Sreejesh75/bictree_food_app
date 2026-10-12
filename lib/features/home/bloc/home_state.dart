import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../models/recipe_model.dart';
import 'home_event.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<RecipeModel> recipes;
  final List<RecipeModel> bestSellers;
  final List<RecipeModel> favorites;
  final String selectedCategory;
  final String searchQuery;
  final SortOption selectedSort;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentSkip;
  final String? errorMessage;
  final bool isOffline;
  final Failure? failure;
  final bool isFromCache;

  const HomeState({
    this.status = HomeStatus.initial,
    this.recipes = const [],
    this.bestSellers = const [],
    this.favorites = const [],
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.selectedSort = SortOption.ratingHighToLow,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentSkip = 0,
    this.errorMessage,
    this.isOffline = false,
    this.failure,
    this.isFromCache = false,
  });

  int get totalFavoritesCount => favorites.length;

  HomeState copyWith({
    HomeStatus? status,
    List<RecipeModel>? recipes,
    List<RecipeModel>? bestSellers,
    List<RecipeModel>? favorites,
    String? selectedCategory,
    String? searchQuery,
    SortOption? selectedSort,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentSkip,
    String? errorMessage,
    bool? isOffline,
    Failure? failure,
    bool? isFromCache,
  }) {
    return HomeState(
      status: status ?? this.status,
      recipes: recipes ?? this.recipes,
      bestSellers: bestSellers ?? this.bestSellers,
      favorites: favorites ?? this.favorites,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSort: selectedSort ?? this.selectedSort,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentSkip: currentSkip ?? this.currentSkip,
      errorMessage: errorMessage ?? this.errorMessage,
      isOffline: isOffline ?? this.isOffline,
      failure: failure ?? this.failure,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
        status,
        recipes,
        bestSellers,
        favorites,
        selectedCategory,
        searchQuery,
        selectedSort,
        isLoadingMore,
        hasMore,
        currentSkip,
        errorMessage,
        isOffline,
        failure,
        isFromCache,
      ];
}
