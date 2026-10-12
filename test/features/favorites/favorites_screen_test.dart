import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bictree_food_app/features/home/bloc/home_bloc.dart';
import 'package:bictree_food_app/features/home/repository/recipe_repository.dart';
import 'package:bictree_food_app/features/cart/bloc/cart_bloc.dart';
import 'package:bictree_food_app/features/favorites/screens/favorites_screen.dart';
import 'package:bictree_food_app/features/favorites/widgets/favorite_item_card.dart';
import 'package:bictree_food_app/core/widgets/curved_bottom_nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bictree_food_app/features/home/models/recipe_model.dart';
import 'package:bictree_food_app/features/home/screens/home_screen.dart';
import 'package:bictree_food_app/features/auth/bloc/auth_bloc.dart';
import 'package:bictree_food_app/features/auth/repository/auth_repository.dart';
import 'package:bictree_food_app/core/storage/secure_storage_service.dart';
import 'package:bictree_food_app/features/auth/models/auth_user.dart';

class MockStorage extends SecureStorageService {
  @override
  Future<String?> getAccessToken() async => null;
  @override
  Future<String?> getUserData() async => null;
  @override
  Future<void> clearSession() async {}
}

class FakeAuthRepo extends AuthRepository {
  FakeAuthRepo() : super(storageService: MockStorage());
  @override
  Future<void> logout() async {}
}

class FakeRecipeRepo extends RecipeRepository {
  FakeRecipeRepo() : super();

  @override
  Future<RecipePageResult> getRecipes({
    int limit = 10,
    int skip = 0,
    String? category,
  }) async {
    return const RecipePageResult(
      recipes: [],
      total: 0,
      skip: 0,
      hasMore: false,
    );
  }
}

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
    isFavorite: true,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testRecipe = _createRecipe();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FavoritesScreen Tests', () {
    testWidgets(
      '1. Empty State - Renders illustration and No favorites yet message',
      (tester) async {
        final homeBloc = HomeBloc(repository: FakeRecipeRepo());
        final cartBloc = CartBloc();

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<HomeBloc>.value(value: homeBloc),
              BlocProvider<CartBloc>.value(value: cartBloc),
            ],
            child: const MaterialApp(home: FavoritesScreen()),
          ),
        );

        expect(find.text('My Favorites'), findsOneWidget);
        expect(find.text('No favorites yet'), findsOneWidget);
        expect(find.text('Explore Menu'), findsOneWidget);
      },
    );

    testWidgets(
      '2. Populated State - Displays favorite recipe and supports removal with UNDO',
      (tester) async {
        final homeBloc = HomeBloc(repository: FakeRecipeRepo());
        final cartBloc = CartBloc();

        homeBloc.emit(homeBloc.state.copyWith(favorites: [testRecipe]));

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<HomeBloc>.value(value: homeBloc),
              BlocProvider<CartBloc>.value(value: cartBloc),
            ],
            child: const MaterialApp(home: FavoritesScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('1 Saved Dish'), findsOneWidget);
        expect(find.text('Classic Margherita Pizza'), findsOneWidget);
        expect(find.text('\$20.0'), findsOneWidget);

        final cardHeart = find.descendant(
          of: find.byType(FavoriteItemCard),
          matching: find.byIcon(Icons.favorite_rounded),
        );
        await tester.tap(cardHeart);
        await tester.pumpAndSettle();

        expect(
          find.text('Classic Margherita Pizza removed from favorites'),
          findsOneWidget,
        );
        expect(find.text('UNDO'), findsOneWidget);
        expect(find.text('No favorites yet'), findsOneWidget);

        await tester.tap(find.text('UNDO'));
        await tester.pumpAndSettle();

        expect(find.text('Classic Margherita Pizza'), findsOneWidget);
      },
    );

    testWidgets(
      '3. Navigation - Tapping favorites in HomeScreen pushes FavoritesScreen without provider error',
      (tester) async {
        final authBloc = AuthBloc(repository: FakeAuthRepo());
        final homeBloc = HomeBloc(repository: FakeRecipeRepo());
        final cartBloc = CartBloc();

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<HomeBloc>.value(value: homeBloc),
              BlocProvider<CartBloc>.value(value: cartBloc),
            ],
            child: const MaterialApp(
              home: HomeScreen(
                user: AuthUser(
                  id: 1,
                  username: 'emilys',
                  email: 'emilys@test.com',
                  firstName: 'Emily',
                  lastName: 'Johnson',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final favNavIcon = find.descendant(
          of: find.byType(CurvedBottomNavBar),
          matching: find.byType(SvgPicture),
        );
        expect(favNavIcon, findsNWidgets(5));
        await tester.tap(favNavIcon.at(2));
        await tester.pumpAndSettle();

        expect(find.text('My Favorites'), findsOneWidget);
        expect(find.byType(FavoritesScreen), findsOneWidget);
      },
    );
  });
}
