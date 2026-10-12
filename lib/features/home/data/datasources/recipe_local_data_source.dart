import '../../../../core/storage/hive_recipe_cache_service.dart';
import '../../domain/entities/recipe_model.dart';

abstract class RecipeLocalDataSource {
  Future<List<RecipeModel>> getCachedRecipes();
  Future<void> cacheRecipes(List<RecipeModel> recipes);
}

class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  final HiveRecipeCacheService cacheService;

  RecipeLocalDataSourceImpl({HiveRecipeCacheService? cacheService})
    : cacheService = cacheService ?? HiveRecipeCacheService();

  @override
  Future<List<RecipeModel>> getCachedRecipes() =>
      cacheService.getCachedFirstPageRecipes();

  @override
  Future<void> cacheRecipes(List<RecipeModel> recipes) =>
      cacheService.cacheFirstPageRecipes(recipes);
}
