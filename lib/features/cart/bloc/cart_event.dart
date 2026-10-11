import 'package:equatable/equatable.dart';
import '../../home/models/recipe_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartEvent extends CartEvent {
  const LoadCartEvent();
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

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}
