import '../entities/recipe_model.dart';
import '../entities/recipe_page_result.dart';

/// Abstract Domain Repository Contract for fetching and searching recipes.
abstract class IRecipeRepository {
  /// Fetches a paginated batch of recipes optionally filtered by category.
  Future<RecipePageResult> getRecipes({
    int limit = 10,
    int skip = 0,
    String? category,
  });

  /// Searches recipes by name or ingredients.
  Future<List<RecipeModel>> searchRecipes(String query);
}
