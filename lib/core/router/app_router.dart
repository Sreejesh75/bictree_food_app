import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

export 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/models/auth_user.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/favorites/screens/favorites_screen.dart';
import '../../features/home/models/recipe_model.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/recipe_detail_screen.dart';

/// App route path constants for declarative navigation with GoRouter.
abstract class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const recipeDetail = '/recipe-detail';
  static const cart = '/cart';
  static const favorites = '/favorites';
}

/// Listenable adapter that notifies GoRouter whenever the Auth stream emits.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Creates and configures the application GoRouter with auth-aware redirect guards.
GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.login,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;
      final isAuthRoute =
          location == AppRoutes.login || location == AppRoutes.signup;

      if (authState is AuthenticatedState) {
        // Authenticated users on login/signup should be redirected to home
        if (isAuthRoute || location == '/') {
          return AppRoutes.home;
        }
      } else if (authState is UnauthenticatedState) {
        // Unauthenticated users trying to access protected screens should go to login
        if (!isAuthRoute) {
          return AppRoutes.login;
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) {
          AuthUser? user;
          if (state.extra is AuthUser) {
            user = state.extra as AuthUser;
          } else {
            final authState = authBloc.state;
            if (authState is AuthenticatedState) {
              user = authState.user;
            }
          }
          return HomeScreen(
            user: user ??
                const AuthUser(
                  id: 0,
                  username: 'Guest',
                  email: '',
                  firstName: 'Guest',
                  lastName: '',
                ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.recipeDetail,
        name: 'recipeDetail',
        builder: (context, state) {
          RecipeModel? recipe;
          String heroTag = 'dish_detail';

          if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            recipe = map['recipe'] as RecipeModel?;
            heroTag = map['heroTag'] as String? ?? heroTag;
          } else if (state.extra is RecipeModel) {
            recipe = state.extra as RecipeModel;
            heroTag = 'dish_${recipe.id}';
          }

          if (recipe == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Recipe Details')),
              body: const Center(child: Text('Recipe data not found')),
            );
          }

          return RecipeDetailScreen(
            recipe: recipe,
            heroTag: heroTag,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
    ],
  );
}
