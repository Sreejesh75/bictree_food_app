import 'package:equatable/equatable.dart';
import '../../home/models/recipe_model.dart';
import '../models/cart_item.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartEvent extends CartEvent {
  final String? userId;

  const LoadCartEvent({this.userId});

  @override
  List<Object?> get props => [userId];
}

class SaveAndClearCartEvent extends CartEvent {
  const SaveAndClearCartEvent();
}

class AddToCartEvent extends CartEvent {
  final RecipeModel recipe;
  final int quantity;

  const AddToCartEvent({
    required this.recipe,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [recipe, quantity];
}

class UpdateCartQuantityEvent extends CartEvent {
  final int recipeId;
  final int quantity;

  const UpdateCartQuantityEvent({
    required this.recipeId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [recipeId, quantity];
}

class RemoveFromCartEvent extends CartEvent {
  final int recipeId;

  const RemoveFromCartEvent(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}

class RestoreCartItemEvent extends CartEvent {
  final CartItem item;
  final int? index;

  const RestoreCartItemEvent({
    required this.item,
    this.index,
  });

  @override
  List<Object?> get props => [item, index];
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}
