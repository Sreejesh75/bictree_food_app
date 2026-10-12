import 'package:flutter_test/flutter_test.dart';
import 'package:bictree_food_app/features/home/domain/entities/recipe_model.dart';
import 'package:bictree_food_app/features/home/domain/entities/recipe_page_result.dart';
import 'package:bictree_food_app/features/home/data/datasources/recipe_remote_data_source.dart';
import 'package:bictree_food_app/features/home/data/datasources/recipe_local_data_source.dart';
import 'package:bictree_food_app/features/home/data/repositories/recipe_repository_impl.dart';
import 'package:bictree_food_app/core/errors/failures.dart';

class FakeRemoteDataSource implements RecipeRemoteDataSource {
  bool shouldThrow = false;
  String? lastCategory;

  final sampleData = {
    'recipes': [
      {
        'id': 1,
        'name': 'Classic Margherita Pizza',
        'ingredients': ['Pizza dough', 'Tomato sauce', 'Fresh mozzarella'],
        'instructions': ['Roll dough', 'Bake at 450°F'],
        'prepTimeMinutes': 15,
        'cookTimeMinutes': 12,
        'servings': 4,
        'difficulty': 'Easy',
        'cuisine': 'Italian',
        'caloriesPerServing': 270,
        'tags': ['Pizza', 'Italian'],
        'userId': 45,
        'image': 'https://cdn.dummyjson.com/recipe-images/1.webp',
        'rating': 4.9,
        'reviewCount': 98,
        'mealType': ['Dinner'],
        'price': 24.50,
      },
      {
        'id': 2,
        'name': 'Vegetarian Stir-Fry',
        'ingredients': ['Tofu', 'Broccoli', 'Soy sauce'],
        'instructions': ['Chop veggies', 'Stir fry in wok'],
        'prepTimeMinutes': 10,
        'cookTimeMinutes': 10,
        'servings': 2,
        'difficulty': 'Easy',
        'cuisine': 'Asian',
        'caloriesPerServing': 180,
        'tags': ['Vegetarian', 'Asian'],
        'userId': 12,
        'image': 'https://cdn.dummyjson.com/recipe-images/2.webp',
        'rating': 4.7,
        'reviewCount': 42,
        'mealType': ['Lunch'],
        'price': 18.00,
      }
    ],
    'total': 50,
    'skip': 0,
    'limit': 2,
  };

  @override
  Future<Map<String, dynamic>> fetchRecipes({
    required int limit,
    required int skip,
    String? category,
  }) async {
    lastCategory = category;
    if (shouldThrow) {
      throw const NetworkFailure(message: 'Network offline');
    }

    return sampleData;
  }

  @override
  Future<List<RecipeModel>> searchRecipes(String query) async {
    if (shouldThrow) {
      throw ServerFailure(statusCode: 500, message: 'Search failed');
    }
    final list = sampleData['recipes'] as List<dynamic>;
    return list
        .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
        .where((r) => r.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

class FakeLocalDataSource implements RecipeLocalDataSource {
  List<RecipeModel> cached = [];

  @override
  Future<List<RecipeModel>> getCachedRecipes() async => cached;

  @override
  Future<void> cacheRecipes(List<RecipeModel> recipes) async {
    cached = recipes;
  }
}

void main() {
  group('RecipeRepository Unit Tests', () {
    late FakeRemoteDataSource remoteDataSource;
    late FakeLocalDataSource localDataSource;
    late RecipeRepository repository;

    setUp(() {
      remoteDataSource = FakeRemoteDataSource();
      localDataSource = FakeLocalDataSource();
      repository = RecipeRepository(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
      );
    });

    test('1. getRecipes successfully fetches and parses recipes from remote data source', () async {
      final result = await repository.getRecipes(limit: 10, skip: 0);

      expect(result, isA<RecipePageResult>());
      expect(result.recipes.length, equals(2));
      expect(result.recipes.first.name, equals('Classic Margherita Pizza'));
      expect(result.total, equals(50));
      expect(result.hasMore, isTrue);
      expect(result.isFromCache, isFalse);
    });

    test('2. getRecipes caches recipes to local data source on initial fetch (skip = 0)', () async {
      await repository.getRecipes(limit: 10, skip: 0);

      expect(localDataSource.cached.length, equals(2));
      expect(localDataSource.cached.first.id, equals(1));
    });

    test('3. getRecipes falls back to cached recipes when remote data source fails', () async {
      // First populate cache
      localDataSource.cached = [
        const RecipeModel(
          id: 99,
          name: 'Cached Offline Salad',
          ingredients: ['Lettuce'],
          instructions: ['Mix'],
          prepTimeMinutes: 5,
          cookTimeMinutes: 0,
          servings: 1,
          difficulty: 'Easy',
          cuisine: 'Healthy',
          caloriesPerServing: 90,
          tags: ['Salad'],
          userId: 1,
          image: '',
          rating: 4.5,
          reviewCount: 10,
          mealType: ['Lunch'],
          price: 12.0,
        ),
      ];

      // Simulate remote network failure
      remoteDataSource.shouldThrow = true;

      final fallbackResult = await repository.getRecipes(limit: 10, skip: 0);

      expect(fallbackResult.isFromCache, isTrue);
      expect(fallbackResult.recipes.length, equals(1));
      expect(fallbackResult.recipes.first.name, equals('Cached Offline Salad'));
    });

    test('4. searchRecipes filters recipes matching query term', () async {
      final results = await repository.searchRecipes('Pizza');

      expect(results.length, equals(1));
      expect(results.first.name, contains('Pizza'));
    });
  });
}
