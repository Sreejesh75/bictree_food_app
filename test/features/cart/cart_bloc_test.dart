import 'package:flutter_test/flutter_test.dart';
import 'package:bictree_food_app/features/cart/bloc/cart_bloc.dart';
import 'package:bictree_food_app/features/cart/bloc/cart_event.dart';
import 'package:bictree_food_app/features/home/models/recipe_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testRecipe = RecipeModel(
    id: 1,
    name: 'Classic Margherita Pizza',
    ingredients: ['Tomato sauce', 'Mozzarella'],
    instructions: ['Bake at 475°F'],
    prepTimeMinutes: 15,
    cookTimeMinutes: 15,
    servings: 2,
    difficulty: 'Easy',
    cuisine: 'Italian',
    caloriesPerServing: 300,
    tags: ['Pizza', 'Italian'],
    userId: 1,
    image: 'https://cdn.dummyjson.com/recipe-images/1.webp',
    rating: 4.6,
    reviewCount: 98,
    mealType: ['Dinner'],
    price: 17.25,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CartBloc Tests', () {
    test('Initial state is empty', () {
      final bloc = CartBloc();
      expect(bloc.state.items, isEmpty);
      expect(bloc.state.totalItemCount, 0);
      expect(bloc.state.total, 0.0);
    });

    test('Adds item with quantity and calculates total price', () async {
      final bloc = CartBloc();

      bloc.add(const AddToCartEvent(recipe: testRecipe, quantity: 2));
      await expectLater(
        bloc.stream,
        emits(
          predicate<dynamic>((state) {
            return state.items.length == 1 &&
                state.items.first.quantity == 2 &&
                state.totalItemCount == 2 &&
                state.subtotal == 34.5;
          }),
        ),
      );
    });

    test('Updates item quantity and removes when quantity is 0', () async {
      final bloc = CartBloc();

      bloc.add(const AddToCartEvent(recipe: testRecipe, quantity: 1));
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

    test('Clears cart items on ClearCartEvent', () async {
      final bloc = CartBloc();

      bloc.add(const AddToCartEvent(recipe: testRecipe, quantity: 3));
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
  });
}
