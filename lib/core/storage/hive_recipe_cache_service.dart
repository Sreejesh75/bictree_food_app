import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/home/models/recipe_model.dart';
import '../errors/failures.dart';

class HiveRecipeCacheService {
  static const String boxName = 'bictree_recipe_cache_box';
  static const String keyFirstPage = 'first_page_recipes';
  static const String keyCachedAt = 'cached_at_timestamp';

  final Box? _customBox;
  bool _isInitialized = false;

  HiveRecipeCacheService({Box? box}) : _customBox = box {
    if (box != null) {
      _isInitialized = true;
    }
  }

  Future<Box> _getBox() async {
    if (_customBox != null && _customBox.isOpen) {
      return _customBox;
    }

    try {
      if (!_isInitialized) {
        await Hive.initFlutter();
        _isInitialized = true;
      }

      if (Hive.isBoxOpen(boxName)) {
        return Hive.box(boxName);
      }
      return await Hive.openBox(boxName);
    } catch (_) {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box(boxName);
      }
      return await Hive.openBox(boxName);
    }
  }

  Future<void> cacheFirstPageRecipes(List<RecipeModel> recipes) async {
    if (recipes.isEmpty) return;
    try {
      final box = await _getBox();
      final jsonList = recipes.map((r) => r.toJson()).toList();
      final encoded = jsonEncode(jsonList);

      await box.put(keyFirstPage, encoded);
      await box.put(keyCachedAt, DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheFailure(
        message: 'Could not write recipes to offline cache.',
        originalError: e,
      );
    }
  }

  Future<List<RecipeModel>> getCachedFirstPageRecipes() async {
    try {
      final box = await _getBox();
      final raw = box.get(keyFirstPage);
      if (raw == null) return [];

      final decoded = jsonDecode(raw as String) as List<dynamic>;
      return decoded
          .map((item) => RecipeModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure(
        message: 'Could not read recipes from offline cache.',
        originalError: e,
      );
    }
  }

  Future<bool> hasCachedRecipes() async {
    try {
      final box = await _getBox();
      final raw = box.get(keyFirstPage);
      return raw != null && (raw as String).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<DateTime?> getCacheTimestamp() async {
    try {
      final box = await _getBox();
      final raw = box.get(keyCachedAt);
      if (raw != null) {
        return DateTime.tryParse(raw as String);
      }
    } catch (_) {}
    return null;
  }

  Future<void> clearCache() async {
    try {
      final box = await _getBox();
      await box.delete(keyFirstPage);
      await box.delete(keyCachedAt);
    } catch (_) {}
  }
}
