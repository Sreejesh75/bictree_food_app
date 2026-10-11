import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bictree_food_app/features/cart/bloc/cart_bloc.dart';
import 'package:bictree_food_app/features/cart/bloc/cart_event.dart';
import 'package:bictree_food_app/features/cart/models/cart_item.dart';
import 'package:bictree_food_app/features/home/models/recipe_model.dart';

RecipeModel _createRecipe({
  int id = 1,
  String name = 'Classic Margherita Pizza',
  double price = 20.0,
}) {
  return RecipeModel(
    id: id,
    name: name,
    price: price,
    image: '',
    rating: 4.8,
    reviewCount: 95,
    mealType: const ['Dinner'],
    ingredients: const ['Cheese', 'Tomato'],
    instructions: const ['Bake'],
    prepTimeMinutes: 10,
    cookTimeMinutes: 15,
    servings: 2,
    difficulty: 'Easy',
    cuisine: 'Italian',
    caloriesPerServing: 250,
    tags: const ['Pizza'],
    userId: 1,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testRecipe = _createRecipe(price: 20.0);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CartBloc Business Logic Tests', () {
    test('1. Initial State - Cart starts empty with zero items and zero total', () {
      final bloc = CartBloc();
      expect(bloc.state.items, isEmpty);
      expect(bloc.state.totalItemCount, 0);
      expect(bloc.state.total, 0.0);
    });

    test('2. Add Item - Adds item with quantity and calculates subtotal correctly', () async {
      final bloc = CartBloc();

      bloc.add(AddToCartEvent(recipe: testRecipe, quantity: 2));
      await expectLater(
        bloc.stream,
        emits(
          predicate<dynamic>((state) {
            return state.items.length == 1 &&
                state.items.first.quantity == 2 &&
                state.totalItemCount == 2 &&
                state.subtotal == 40.0;
          }),
        ),
      );
    });

    test('3. Update Quantity - Updates quantity and removes item when quantity reaches zero', () async {
      final bloc = CartBloc();

      bloc.add(AddToCartEvent(recipe: testRecipe, quantity: 1));
      await expectLater(
        bloc.stream,
        emits(predicate<dynamic>((state) => state.items.length == 1)),
      );

      bloc.add(const UpdateCartQuantityEvent(recipeId: 1, quantity: 0));
      await expectLater(
        bloc.stream,
        emits(predicate<dynamic>((state) => state.items.isEmpty)),
      );
    });

    test('4. Undo Restore - Restores previously deleted item back to the cart', () async {
      final bloc = CartBloc();
      final cartItem = CartItem(recipe: testRecipe, quantity: 2);

      bloc.add(AddToCartEvent(recipe: testRecipe, quantity: 2));
      await expectLater(
        bloc.stream,
        emits(predicate<dynamic>((state) => state.items.length == 1)),
      );

      bloc.add(const RemoveFromCartEvent(1));
      await expectLater(
        bloc.stream,
        emits(predicate<dynamic>((state) => state.items.isEmpty)),
      );

      bloc.add(RestoreCartItemEvent(item: cartItem, index: 0));
      await expectLater(
        bloc.stream,
        emits(
          predicate<dynamic>((state) {
            return state.items.length == 1 &&
                state.items.first.recipe.id == 1 &&
                state.items.first.quantity == 2;
          }),
        ),
      );
    });

    test('5. Local Persistence - Saves items to SharedPreferences and survives app restart', () async {
      final bloc1 = CartBloc();
      bloc1.add(AddToCartEvent(recipe: testRecipe, quantity: 3));
      await expectLater(
        bloc1.stream,
        emits(predicate<dynamic>((state) => state.items.length == 1)),
      );

      // Simulate app restart with a fresh bloc instance
      final bloc2 = CartBloc();
      bloc2.add(const LoadCartEvent());
      await expectLater(
        bloc2.stream,
        emitsInOrder([
          predicate<dynamic>((state) => state.isLoading == true),
          predicate<dynamic>((state) {
            return state.isLoading == false &&
                state.items.length == 1 &&
                state.items.first.recipe.id == 1 &&
                state.items.first.quantity == 3 &&
                state.subtotal == 60.0;
          }),
        ]),
      );
    });

    test('6. Clear Cart - Empties all items when ClearCartEvent is dispatched', () async {
      final bloc = CartBloc();

      bloc.add(AddToCartEvent(recipe: testRecipe, quantity: 3));
      await expectLater(
        bloc.stream,
        emits(predicate<dynamic>((state) => state.items.isNotEmpty)),
      );

      bloc.add(const ClearCartEvent());
      await expectLater(
        bloc.stream,
        emits(predicate<dynamic>((state) => state.items.isEmpty)),
      );
    });

    test('7. Per-User Persistence - Saves items for user A, clears on signout, and restores on signin', () async {
      final emilyBloc = CartBloc();
      emilyBloc.add(const LoadCartEvent(userId: 'emilys'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      emilyBloc.add(AddToCartEvent(recipe: testRecipe, quantity: 2));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(emilyBloc.state.items.length, 1);

      // Emily signs out: saves and clears in-memory cart
      emilyBloc.add(const SaveAndClearCartEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(emilyBloc.state.items, isEmpty);

      // Another user logs in (john)
      final johnBloc = CartBloc();
      johnBloc.add(const LoadCartEvent(userId: 'john'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(johnBloc.state.items, isEmpty);

      // Emily logs back in with same credentials
      final emilyRestoredBloc = CartBloc();
      emilyRestoredBloc.add(const LoadCartEvent(userId: 'emilys'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(emilyRestoredBloc.state.items.length, 1);
      expect(emilyRestoredBloc.state.items.first.quantity, 2);
    });
  });
}
