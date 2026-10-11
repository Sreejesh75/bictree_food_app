import 'package:equatable/equatable.dart';
import '../models/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final bool isLoading;

  const CartState({
    this.items = const [],
    this.isLoading = false,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => items.isEmpty ? 0.0 : (subtotal > 50.0 ? 0.0 : 3.50);

  double get tax => subtotal * 0.05;

  double get total => subtotal + deliveryFee + tax;

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [items, isLoading];
}
