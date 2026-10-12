import 'recipe_model.dart';

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
