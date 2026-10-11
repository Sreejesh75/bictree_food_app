import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/cart/bloc/cart_bloc.dart';
import 'features/cart/bloc/cart_event.dart';
import 'features/home/bloc/home_bloc.dart';
import 'features/home/bloc/home_event.dart';
import 'features/home/repository/recipe_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final secureStorage = SecureStorageService();
  final authRepository = AuthRepository(storageService: secureStorage);

  runApp(
    BictreeFoodApp(authRepository: authRepository),
  );
}

class BictreeFoodApp extends StatelessWidget {
  final AuthRepository authRepository;
  final RecipeRepository? recipeRepository;

  const BictreeFoodApp({
    super.key,
    required this.authRepository,
    this.recipeRepository,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRecipeRepo = recipeRepository ?? RecipeRepository();

    return RepositoryProvider<AuthRepository>.value(
      value: authRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              repository: authRepository,
            )..add(const CheckAuthStatusEvent()),
          ),
          BlocProvider<CartBloc>(
            create: (context) => CartBloc()..add(const LoadCartEvent()),
          ),
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(
              repository: effectiveRecipeRepo,
            )..add(const FetchInitialRecipesEvent()),
          ),
        ],
        child: MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );
  }
}
