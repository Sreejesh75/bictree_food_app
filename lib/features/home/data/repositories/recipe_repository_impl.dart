import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/hive_recipe_cache_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/recipe_model.dart';
import '../../domain/entities/recipe_page_result.dart';
import '../../domain/repositories/i_recipe_repository.dart';
import '../datasources/recipe_local_data_source.dart';
import '../datasources/recipe_remote_data_source.dart';

class RecipeRepositoryImpl implements IRecipeRepository {
  final RecipeRemoteDataSource remoteDataSource;
  final RecipeLocalDataSource localDataSource;
  final Dio dio;
  final HiveRecipeCacheService cacheService;

  RecipeRepositoryImpl({
    Dio? dio,
    dynamic httpClient,
    HiveRecipeCacheService? cacheService,
    SecureStorageService? storageService,
    RecipeRemoteDataSource? remoteDataSource,
    RecipeLocalDataSource? localDataSource,
  }) : dio = dio ?? DioClient.createDio(storageService: storageService),
       cacheService = cacheService ?? HiveRecipeCacheService(),
       remoteDataSource =
           remoteDataSource ??
           RecipeRemoteDataSourceImpl(
             dio: dio ?? DioClient.createDio(storageService: storageService),
           ),
       localDataSource =
           localDataSource ??
           RecipeLocalDataSourceImpl(
             cacheService: cacheService ?? HiveRecipeCacheService(),
           );

  @override
  Future<RecipePageResult> getRecipes({
    int limit = 10,
    int skip = 0,
    String? category,
  }) async {
    try {
      final data = await remoteDataSource.fetchRecipes(
        limit: limit,
        skip: skip,
        category: category,
      );

      final list = (data['recipes'] as List<dynamic>?) ?? [];
      final recipes = list
          .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final total = data['total'] is int
          ? data['total'] as int
          : recipes.length;
      final currentSkip = data['skip'] is int ? data['skip'] as int : skip;

      if (skip == 0 && (category == null || category == 'All')) {
        try {
          await localDataSource.cacheRecipes(recipes);
        } catch (_) {}
      }

      return RecipePageResult(
        recipes: recipes,
        total: total,
        skip: currentSkip,
        hasMore: (currentSkip + recipes.length) < total,
        isFromCache: false,
      );
    } catch (e) {
      if (e is Failure && e is! NetworkFailure && e is! TimeoutFailure) {
        rethrow;
      }

      if (skip == 0 && (category == null || category == 'All')) {
        final cached = await _getCachedFallback();
        if (cached != null) return cached;
      }

      throw mapExceptionToFailure(e);
    }
  }

  Future<RecipePageResult?> _getCachedFallback() async {
    try {
      final cached = await localDataSource.getCachedRecipes();
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

  @override
  Future<List<RecipeModel>> searchRecipes(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      final res = await getRecipes(limit: 15, skip: 0);
      return res.recipes;
    }

    try {
      return await remoteDataSource.searchRecipes(clean);
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
  }
}

class RecipeRepository extends RecipeRepositoryImpl {
  RecipeRepository({
    super.dio,
    super.httpClient,
    super.cacheService,
    super.storageService,
    super.remoteDataSource,
    super.localDataSource,
  });
}
