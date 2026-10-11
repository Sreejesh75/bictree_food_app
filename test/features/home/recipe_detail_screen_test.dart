import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bictree_food_app/features/home/screens/recipe_detail_screen.dart';
import 'package:bictree_food_app/features/home/models/recipe_model.dart';
import 'package:bictree_food_app/features/cart/bloc/cart_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testRecipe = RecipeModel(
    id: 1,
    name: 'Tomato Basil Bruschetta',
    ingredients: ['Baguette', 'Tomatoes', 'Fresh basil'],
    instructions: ['Slice baguette', 'Top with diced tomatoes and basil'],
    prepTimeMinutes: 10,
    cookTimeMinutes: 15,
    servings: 2,
    difficulty: 'Easy',
    cuisine: 'Italian',
    caloriesPerServing: 220,
    tags: ['Snack', 'Italian'],
    userId: 1,
    image: 'https://cdn.dummyjson.com/recipe-images/1.webp',
    rating: 4.7,
    reviewCount: 95,
    mealType: ['Snack'],
    price: 60.8,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('RecipeDetailScreen displays recipe details and adds to cart', (tester) async {
    final cartBloc = CartBloc();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartBloc>.value(
          value: cartBloc,
          child: const RecipeDetailScreen(
            recipe: testRecipe,
            heroTag: 'test_tag_1',
          ),
        ),
      ),
    );

    expect(find.text('Food Details'), findsOneWidget);
    expect(find.text('Tomato Basil Bruschetta'), findsOneWidget);
    expect(find.text('\$60.8'), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Baguette'), findsOneWidget);
    expect(find.text('Instructions'), findsOneWidget);
    expect(find.text('Slice baguette'), findsOneWidget);
    expect(find.text('Add to Cart • \$60.8'), findsOneWidget);

    // Tap + to increment quantity
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Add to Cart • \$121.6'), findsOneWidget);
  });
}
