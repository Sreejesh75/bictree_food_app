import '../entities/cart_item.dart';

/// Abstract Domain Repository Contract for Cart persistence operations.
abstract class ICartRepository {
  /// Loads persisted cart items for a given user identifier.
  Future<List<CartItem>> loadCart({required String userId});

  /// Saves cart items locally for a given user identifier.
  Future<void> saveCart({required String userId, required List<CartItem> items});

  /// Clears stored cart items for a given user identifier.
  Future<void> clearCart({required String userId});
}
