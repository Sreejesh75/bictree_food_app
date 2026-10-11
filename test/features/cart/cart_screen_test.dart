import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bictree_food_app/features/cart/bloc/cart_bloc.dart';
import 'package:bictree_food_app/features/cart/bloc/cart_event.dart';
import 'package:bictree_food_app/features/cart/screens/cart_screen.dart';
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

  group('CartScreen UI Tests', () {
    testWidgets('1. Empty State - Renders illustration, heading, and Explore Menu button', (tester) async {
      final cartBloc = CartBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CartBloc>.value(
            value: cartBloc,
            child: const CartScreen(),
          ),
        ),
      );

      expect(find.text('My Cart'), findsOneWidget);
      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Explore Menu'), findsOneWidget);
    });

    testWidgets('2. Item List & Totals - Displays items and live updates totals on quantity change', (tester) async {
      final cartBloc = CartBloc();
      cartBloc.add(AddToCartEvent(recipe: testRecipe, quantity: 1));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CartBloc>.value(
            value: cartBloc,
            child: const CartScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Classic Margherita Pizza'), findsOneWidget);
      expect(find.text('\$20.0 each'), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);

      // Initial: Subtotal: $20.00, Delivery: $3.50, Tax (5%): $1.00, Total: $24.50
      expect(find.text('\$20.00'), findsOneWidget);
      expect(find.text('\$3.50'), findsOneWidget);
      expect(find.text('\$1.00'), findsOneWidget);
      expect(find.text('\$24.50'), findsOneWidget);
      expect(find.text('Place Order • \$24.50'), findsOneWidget);

      // Increment quantity to 2
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Updated: Subtotal: $40.00, Tax (5%): $2.00, Delivery: $3.50, Total: $45.50
      expect(find.text('\$40.00'), findsOneWidget);
      expect(find.text('\$2.00'), findsOneWidget);
      expect(find.text('\$45.50'), findsOneWidget);
      expect(find.text('Place Order • \$45.50'), findsOneWidget);
    });

    testWidgets('3. Swipe To Delete - Removes item and restores it on UNDO action', (tester) async {
      final cartBloc = CartBloc();
      cartBloc.add(AddToCartEvent(recipe: testRecipe, quantity: 2));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CartBloc>.value(
            value: cartBloc,
            child: const CartScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Classic Margherita Pizza'), findsOneWidget);

      // Swipe left to dismiss
      await tester.drag(find.text('Classic Margherita Pizza'), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      // Undo SnackBar is shown
      expect(find.text('Classic Margherita Pizza removed from cart'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);
      expect(find.text('Your cart is empty'), findsOneWidget);

      // Tap UNDO
      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();

      // Item restored
      expect(find.text('Classic Margherita Pizza'), findsOneWidget);
    });
  });
}
