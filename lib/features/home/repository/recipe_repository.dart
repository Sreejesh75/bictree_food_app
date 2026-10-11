import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../models/recipe_model.dart';

class RecipePageResult {
  final List<RecipeModel> recipes;
  final int total;
  final int skip;
  final bool hasMore;

  const RecipePageResult({
    required this.recipes,
    required this.total,
    required this.skip,
    required this.hasMore,
  });
}

class RecipeRepository {
  final http.Client httpClient;

  RecipeRepository({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  /// Fetch recipes with pagination: ?limit=10&skip=0
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

    final response = await httpClient.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (data['recipes'] as List<dynamic>?) ?? [];
      final recipes = list.map((e) => RecipeModel.fromJson(e as Map<String, dynamic>)).toList();
      final total = data['total'] is int ? data['total'] as int : recipes.length;
      final currentSkip = data['skip'] is int ? data['skip'] as int : skip;

      return RecipePageResult(
        recipes: recipes,
        total: total,
        skip: currentSkip,
        hasMore: (currentSkip + recipes.length) < total,
      );
    } else {
      throw Exception('Failed to load recipes (Status code: ${response.statusCode})');
    }
  }

  /// Search recipes by name with debounce
  Future<List<RecipeModel>> searchRecipes(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      final res = await getRecipes(limit: 15, skip: 0);
      return res.recipes;
    }

    final url = Uri.parse('${ApiEndpoints.recipeSearch}?q=${Uri.encodeComponent(clean)}');
    final response = await httpClient.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (data['recipes'] as List<dynamic>?) ?? [];
      return list.map((e) => RecipeModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Search failed. Please try again.');
    }
  }
}
