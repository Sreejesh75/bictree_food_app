import 'package:equatable/equatable.dart';
import '../models/recipe_model.dart';

enum SortOption {
  ratingHighToLow,
  priceLowToHigh,
  priceHighToLow,
  caloriesLowToHigh,
}

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class FetchInitialRecipesEvent extends HomeEvent {
  const FetchInitialRecipesEvent();
}

class RefreshRecipesEvent extends HomeEvent {
  const RefreshRecipesEvent();
}

class FetchMoreRecipesEvent extends HomeEvent {
  const FetchMoreRecipesEvent();
}

class SelectCategoryEvent extends HomeEvent {
  final String category;

  const SelectCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchRecipesEvent extends HomeEvent {
  final String query;

  const SearchRecipesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SortRecipesEvent extends HomeEvent {
  final SortOption sortOption;

  const SortRecipesEvent(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}

class ToggleFavoriteEvent extends HomeEvent {
  final int recipeId;
  final RecipeModel? recipe;

  const ToggleFavoriteEvent(this.recipeId, {this.recipe});

  @override
  List<Object?> get props => [recipeId, recipe];
}

class ClearFavoritesEvent extends HomeEvent {
  const ClearFavoritesEvent();
}
