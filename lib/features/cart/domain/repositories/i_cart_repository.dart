import '../entities/cart_item.dart';

abstract class ICartRepository {
  Future<List<CartItem>> loadCart({required String userId});

  Future<void> saveCart({
    required String userId,
    required List<CartItem> items,
  });

  Future<void> clearCart({required String userId});
}
