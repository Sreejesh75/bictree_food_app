import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bictree_food_app/features/home/bloc/home_bloc.dart';
import 'package:bictree_food_app/features/home/bloc/home_event.dart';
import 'package:bictree_food_app/features/home/bloc/home_state.dart';
import 'package:bictree_food_app/features/home/models/recipe_model.dart';
import 'package:bictree_food_app/features/home/repository/recipe_repository.dart';

class FakeRecipeRepository extends RecipeRepository {
  final List<RecipeModel> mockRecipes = [
    const RecipeModel(
      id: 1,
      name: 'Classic Margherita Pizza',
      ingredients: ['Dough', 'Cheese'],
      instructions: ['Bake'],
      prepTimeMinutes: 10,
      cookTimeMinutes: 15,
      servings: 2,
      difficulty: 'Easy',
      cuisine: 'Italian',
      caloriesPerServing: 300,
      tags: ['Pizza'],
      userId: 1,
      image: 'https://cdn.dummyjson.com/recipe-images/1.webp',
      rating: 4.6,
      reviewCount: 98,
      mealType: ['Dinner'],
      price: 15.0,
    ),
    const RecipeModel(
      id: 2,
      name: 'Vegetarian Stir-Fry',
      ingredients: ['Tofu', 'Vegetables'],
      instructions: ['Stir-fry'],
      prepTimeMinutes: 15,
      cookTimeMinutes: 20,
      servings: 3,
      difficulty: 'Medium',
      cuisine: 'Asian',
      caloriesPerServing: 250,
      tags: ['Vegetarian'],
      userId: 2,
      image: 'https://cdn.dummyjson.com/recipe-images/2.webp',
      rating: 4.9,
      reviewCount: 26,
      mealType: ['Lunch'],
      price: 12.0,
    ),
  ];

  @override
  Future<RecipePageResult> getRecipes({
    int limit = 10,
    int skip = 0,
    String? category,
  }) async {
    return RecipePageResult(
      recipes: mockRecipes,
      total: mockRecipes.length,
      skip: skip,
      hasMore: false,
    );
  }

  @override
  Future<List<RecipeModel>> searchRecipes(String query) async {
    if (query.isEmpty) return mockRecipes;
    return mockRecipes
        .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

void main() {
  group('HomeBloc Tests', () {
    late FakeRecipeRepository fakeRepo;
    late HomeBloc homeBloc;

    setUp(() {
      fakeRepo = FakeRecipeRepository();
      homeBloc = HomeBloc(repository: fakeRepo);
    });

    tearDown(() {
      homeBloc.close();
    });

    test('initial state has HomeStatus.initial', () {
      expect(homeBloc.state.status, HomeStatus.initial);
    });

    blocTest<HomeBloc, HomeState>(
      'emits [loading, success] on FetchInitialRecipesEvent',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const FetchInitialRecipesEvent()),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        predicate<HomeState>((state) {
          return state.status == HomeStatus.success &&
              state.recipes.length == 2 &&
              state.bestSellers.isNotEmpty;
        }),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [loading, success] on SelectCategoryEvent',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const SelectCategoryEvent('Snacks')),
      expect: () => [
        predicate<HomeState>((state) =>
            state.status == HomeStatus.loading && state.selectedCategory == 'Snacks'),
        predicate<HomeState>((state) =>
            state.status == HomeStatus.success && state.selectedCategory == 'Snacks'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'searches recipes on SearchRecipesEvent',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const SearchRecipesEvent('Pizza')),
      expect: () => [
        predicate<HomeState>((state) =>
            state.status == HomeStatus.loading && state.searchQuery == 'Pizza'),
        predicate<HomeState>((state) =>
            state.status == HomeStatus.success &&
            state.recipes.length == 1 &&
            state.recipes.first.name.contains('Pizza')),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'sorts recipes by price on SortRecipesEvent',
      build: () => homeBloc,
      seed: () => HomeState(
        status: HomeStatus.success,
        recipes: fakeRepo.mockRecipes,
      ),
      act: (bloc) => bloc.add(const SortRecipesEvent(SortOption.priceLowToHigh)),
      expect: () => [
        predicate<HomeState>((state) {
          return state.selectedSort == SortOption.priceLowToHigh &&
              state.recipes.first.price <= state.recipes.last.price;
        }),
      ],
    );
  });
}
