class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://dummyjson.com';

  // Auth Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String authMe = '$baseUrl/auth/me';
  static const String usersAdd = '$baseUrl/users/add';

  // Recipes Endpoints
  static const String recipes = '$baseUrl/recipes';
  static const String recipeSearch = '$baseUrl/recipes/search';
  static const String recipeTags = '$baseUrl/recipes/tags';
  
  static String recipeById(int id) => '$baseUrl/recipes/$id';
  static String recipeByMealType(String mealType) => '$baseUrl/recipes/meal-type/$mealType';
  static String recipeByTag(String tag) => '$baseUrl/recipes/tag/$tag';
}
