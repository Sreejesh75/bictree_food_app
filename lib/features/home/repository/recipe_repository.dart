import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/failures.dart';
import '../../../core/storage/hive_recipe_cache_service.dart';
import '../models/recipe_model.dart';

class RecipePageResult {
  final List<RecipeModel> recipes;
  final int total;
  final int skip;
  final bool hasMore;
  final bool isFromCache;

  const RecipePageResult({
    required this.recipes,
    required this.total,
    required this.skip,
    required this.hasMore,
    this.isFromCache = false,
  });
}

class RecipeRepository {
  final http.Client httpClient;
  final HiveRecipeCacheService cacheService;

  RecipeRepository({
    http.Client? httpClient,
    HiveRecipeCacheService? cacheService,
  })  : httpClient = httpClient ?? http.Client(),
        cacheService = cacheService ?? HiveRecipeCacheService();

  /// Fetch recipes with pagination: ?limit=10&skip=0
  /// On network failure for first page, falls back to Hive cache and marks [isFromCache] = true.
  Future<RecipePageResult> getRecipes({
    int limit = 10,
    int skip = 0,
    String? category,
  }) async {
    Uri url;

    if (category != null && category.isNotEmpty && category != 'All') {
      final catLower = category.toLowerCase();
      if (catLower == 'snacks' || catLower == 'snack') {
        url = Uri.parse('${ApiEndpoints.recipes}/meal-type/snack?limit=$limit&skip=$skip');
      } else if (catLower == 'meal' || catLower == 'meals') {
        url = Uri.parse('${ApiEndpoints.recipes}/meal-type/dinner?limit=$limit&skip=$skip');
      } else if (catLower == 'vegan') {
        url = Uri.parse('${ApiEndpoints.recipes}/tag/vegetarian?limit=$limit&skip=$skip');
      } else if (catLower == 'dessert' || catLower == 'desserts') {
        url = Uri.parse('${ApiEndpoints.recipes}/meal-type/dessert?limit=$limit&skip=$skip');
      } else if (catLower == 'drinks' || catLower == 'drink') {
        url = Uri.parse('${ApiEndpoints.recipes}/meal-type/beverage?limit=$limit&skip=$skip');
      } else {
        url = Uri.parse('${ApiEndpoints.recipes}?limit=$limit&skip=$skip');
      }
    } else {
      url = Uri.parse('${ApiEndpoints.recipes}?limit=$limit&skip=$skip');
    }

    try {
      final response = await httpClient
          .get(
            url,
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (data['recipes'] as List<dynamic>?) ?? [];
        final recipes =
            list.map((e) => RecipeModel.fromJson(e as Map<String, dynamic>)).toList();
        final total = data['total'] is int ? data['total'] as int : recipes.length;
        final currentSkip = data['skip'] is int ? data['skip'] as int : skip;

        // Cache first page items into Hive
        if (skip == 0 && (category == null || category == 'All')) {
          try {
            await cacheService.cacheFirstPageRecipes(recipes);
          } catch (_) {}
        }

        return RecipePageResult(
          recipes: recipes,
          total: total,
          skip: currentSkip,
          hasMore: (currentSkip + recipes.length) < total,
          isFromCache: false,
        );
      } else {
        // HTTP Server error
        if (skip == 0 && (category == null || category == 'All')) {
          final cached = await _getCachedFallback();
          if (cached != null) return cached;
        }
        throw ServerFailure(
          statusCode: response.statusCode,
          message: 'Server returned error status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is Failure && e is! NetworkFailure && e is! TimeoutFailure) {
        rethrow;
      }

      // Check Hive cache for first page fallback
      if (skip == 0 && (category == null || category == 'All')) {
        final cached = await _getCachedFallback();
        if (cached != null) return cached;
      }

      throw mapExceptionToFailure(e);
    }
  }

  Future<RecipePageResult?> _getCachedFallback() async {
    try {
      final cached = await cacheService.getCachedFirstPageRecipes();
      if (cached.isNotEmpty) {
        return RecipePageResult(
          recipes: cached,
          total: cached.length,
          skip: 0,
          hasMore: false,
          isFromCache: true,
        );
      }
    } catch (_) {}
    return null;
  }

  /// Search recipes by name with debounce
  Future<List<RecipeModel>> searchRecipes(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      final res = await getRecipes(limit: 15, skip: 0);
      return res.recipes;
    }

    try {
      final url =
          Uri.parse('${ApiEndpoints.recipeSearch}?q=${Uri.encodeComponent(clean)}');
      final response = await httpClient
          .get(
            url,
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (data['recipes'] as List<dynamic>?) ?? [];
        return list
            .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerFailure(
          statusCode: response.statusCode,
          message: 'Search query could not be completed at this time.',
        );
      }
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }
}
