import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/cart_item.dart';

abstract class CartLocalDataSource {
  Future<List<CartItem>> loadCart(String userId);
  Future<void> saveCart(String userId, List<CartItem> items);
  Future<void> clearCart(String userId);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const String _storagePrefix = 'user_cart_';

  @override
  Future<List<CartItem>> loadCart(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_storagePrefix$userId';
      final jsonString = prefs.getString(key);
      if (jsonString != null && jsonString.isNotEmpty) {
        final decoded = jsonDecode(jsonString) as List<dynamic>;
        return decoded
            .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> saveCart(String userId, List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_storagePrefix$userId';
      final encoded = jsonEncode(items.map((i) => i.toJson()).toList());
      await prefs.setString(key, encoded);
    } catch (_) {}
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_storagePrefix$userId';
      await prefs.remove(key);
    } catch (_) {}
  }
}
