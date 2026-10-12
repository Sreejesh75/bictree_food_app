import '../entities/recipe_model.dart';
import '../entities/recipe_page_result.dart';

abstract class IRecipeRepository {
  Future<RecipePageResult> getRecipes({
    int limit = 10,
    int skip = 0,
    String? category,
  });

  Future<List<RecipeModel>> searchRecipes(String query);
}
