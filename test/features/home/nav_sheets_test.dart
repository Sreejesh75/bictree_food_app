import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bictree_food_app/core/storage/secure_storage_service.dart';
import 'package:bictree_food_app/features/auth/bloc/auth_bloc.dart';
import 'package:bictree_food_app/features/auth/models/auth_user.dart';
import 'package:bictree_food_app/features/auth/repository/auth_repository.dart';
import 'package:bictree_food_app/features/cart/bloc/cart_bloc.dart';
import 'package:bictree_food_app/features/home/bloc/home_bloc.dart';
import 'package:bictree_food_app/features/home/repository/recipe_repository.dart';
import 'package:bictree_food_app/features/home/widgets/order_history_sheet.dart';
import 'package:bictree_food_app/features/home/widgets/profile_sheet.dart';
import 'package:bictree_food_app/features/home/widgets/support_concierge_sheet.dart';

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

void main() {
  group('Navigation Bar Bottom Sheets Tests', () {
    testWidgets(
      '1. OrderHistorySheet renders preview badge, features, and waitlist button',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => OrderHistorySheet.show(context),
                  child: const Text('Open History'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open History'));
        await tester.pumpAndSettle();

        expect(find.text('Order History & Live Tracking'), findsOneWidget);
        expect(find.text('✨ FEATURE PREVIEW'), findsOneWidget);
        expect(find.text('COMING SOON'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
        expect(find.text('Live GPS Telemetry'), findsOneWidget);
        expect(find.text('Digital PDF Receipts'), findsOneWidget);
        expect(find.text('1-Tap Quick Reorder'), findsOneWidget);

        final notifyBtn = find.text('Notify Me When Available');
        expect(notifyBtn, findsOneWidget);
        await tester.ensureVisible(notifyBtn);
        await tester.tap(notifyBtn);
        await tester.pumpAndSettle();

        expect(
          find.text('Waitlist Active • We Will Notify You'),
          findsOneWidget,
        );

        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(OrderHistorySheet), findsNothing);
      },
    );

    testWidgets(
      '2. SupportConciergeSheet renders 24/7 VIP badge, contact options, and expands FAQ',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => SupportConciergeSheet.show(context),
                  child: const Text('Open Support'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Support'));
        await tester.pumpAndSettle();

        expect(find.text('Customer Care & Concierge'), findsOneWidget);
        expect(find.text('🎧 24/7 VIP CONCIERGE'), findsOneWidget);
        expect(find.text('COMING SOON'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
        expect(find.text('Live Concierge Chat'), findsOneWidget);
        expect(find.text('Toll-Free Hotline'), findsOneWidget);
        expect(find.text('VIP Email Assistance'), findsOneWidget);

        final faqQuestion = find.text(
          'How can I track or modify an active order?',
        );
        expect(faqQuestion, findsOneWidget);
        await tester.ensureVisible(faqQuestion);
        await tester.tap(faqQuestion);
        await tester.pumpAndSettle();

        expect(
          find.textContaining('You can view real-time delivery estimates'),
          findsOneWidget,
        );

        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(SupportConciergeSheet), findsNothing);
      },
    );

    testWidgets(
      '3. ProfileSheet renders user info, stats, and handles sign out confirmation',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        const testUser = AuthUser(
          id: 1,
          username: 'emilys',
          email: 'emily.johnson@x.dummyjson.com',
          firstName: 'Emily',
          lastName: 'Johnson',
        );

        final authBloc = AuthBloc(repository: FakeAuthRepo());
        final cartBloc = CartBloc();
        final homeBloc = HomeBloc(repository: FakeRecipeRepo());

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<CartBloc>.value(value: cartBloc),
              BlocProvider<HomeBloc>.value(value: homeBloc),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => ProfileSheet.show(context, user: testUser),
                    child: const Text('Open Profile'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Profile'));
        await tester.pumpAndSettle();

        expect(find.text('Emily Johnson'), findsNWidgets(2));
        expect(
          find.text('@emilys • emily.johnson@x.dummyjson.com'),
          findsOneWidget,
        );
        expect(find.text('⭐ VIP MEMBER'), findsOneWidget);
        expect(find.text('Sign Out of Account'), findsOneWidget);

        final signOutBtn = find.text('Sign Out of Account');
        await tester.ensureVisible(signOutBtn);
        await tester.tap(signOutBtn);
        await tester.pumpAndSettle();

        expect(find.text('Sign Out?'), findsOneWidget);
        expect(find.text('Sign out from @emilys?'), findsOneWidget);

        final confirmBtn = find.widgetWithText(ElevatedButton, 'Sign Out');
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        expect(find.byType(ProfileSheet), findsNothing);
      },
    );
  });
}
