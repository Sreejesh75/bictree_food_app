import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/i_cart_repository.dart';
import '../datasources/cart_local_data_source.dart';

/// Concrete Data Layer implementation of [ICartRepository].
class CartRepositoryImpl implements ICartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({CartLocalDataSource? localDataSource})
      : localDataSource = localDataSource ?? CartLocalDataSourceImpl();

  @override
  Future<List<CartItem>> loadCart({required String userId}) =>
      localDataSource.loadCart(userId);

  @override
  Future<void> saveCart({
    required String userId,
    required List<CartItem> items,
  }) =>
      localDataSource.saveCart(userId, items);

  @override
  Future<void> clearCart({required String userId}) =>
      localDataSource.clearCart(userId);
}
