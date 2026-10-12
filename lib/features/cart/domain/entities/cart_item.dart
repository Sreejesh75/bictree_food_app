import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/recipe_model.dart';

class CartItem extends Equatable {
  final RecipeModel recipe;
  final int quantity;

  const CartItem({required this.recipe, required this.quantity});

  double get totalPrice => recipe.price * quantity;

  CartItem copyWith({RecipeModel? recipe, int? quantity}) {
    return CartItem(
      recipe: recipe ?? this.recipe,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {'recipe': recipe.toJson(), 'quantity': quantity};
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      recipe: RecipeModel.fromJson(json['recipe'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  @override
  List<Object?> get props => [recipe, quantity];
}
