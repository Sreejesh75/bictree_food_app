import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  Future<Map<String, dynamic>> fetchRecipes({
    required int limit,
    required int skip,
    String? category,
  });

  Future<List<RecipeModel>> searchRecipes(String query);
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final Dio dio;

  RecipeRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? DioClient.createDio();

  @override
  Future<Map<String, dynamic>> fetchRecipes({
    required int limit,
    required int skip,
    String? category,
  }) async {
    String endpoint;

    if (category != null && category.isNotEmpty && category != 'All') {
      final catLower = category.toLowerCase();
      if (catLower == 'snacks' || catLower == 'snack') {
        endpoint =
            '${ApiEndpoints.recipes}/meal-type/snack?limit=$limit&skip=$skip';
      } else if (catLower == 'meal' || catLower == 'meals') {
        endpoint =
            '${ApiEndpoints.recipes}/meal-type/dinner?limit=$limit&skip=$skip';
      } else if (catLower == 'vegan') {
        endpoint =
            '${ApiEndpoints.recipes}/tag/vegetarian?limit=$limit&skip=$skip';
      } else if (catLower == 'dessert' || catLower == 'desserts') {
        endpoint =
            '${ApiEndpoints.recipes}/meal-type/dessert?limit=$limit&skip=$skip';
      } else if (catLower == 'drinks' || catLower == 'drink') {
        endpoint =
            '${ApiEndpoints.recipes}/meal-type/beverage?limit=$limit&skip=$skip';
      } else {
        endpoint = '${ApiEndpoints.recipes}?limit=$limit&skip=$skip';
      }
    } else {
      endpoint = '${ApiEndpoints.recipes}?limit=$limit&skip=$skip';
    }

    final response = await dio.get(endpoint);

    if (response.statusCode == 200) {
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data.toString()) as Map<String, dynamic>;
      return data;
    } else {
      throw Exception('Server returned ${response.statusCode}');
    }
  }

  @override
  Future<List<RecipeModel>> searchRecipes(String query) async {
    final endpoint =
        '${ApiEndpoints.recipeSearch}?q=${Uri.encodeComponent(query)}';
    final response = await dio.get(endpoint);

    if (response.statusCode == 200) {
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data.toString()) as Map<String, dynamic>;
      final list = (data['recipes'] as List<dynamic>?) ?? [];
      return list
          .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Search failed with ${response.statusCode}');
    }
  }
}
