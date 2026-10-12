import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_strings.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/cart/bloc/cart_bloc.dart';
import 'features/cart/bloc/cart_event.dart';
import 'features/home/bloc/home_bloc.dart';
import 'features/home/bloc/home_event.dart';
import 'features/home/repository/recipe_repository.dart';

import 'core/router/app_router.dart';

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

  try {
    await Hive.initFlutter();
  } catch (_) {}

  runApp(
    BictreeFoodApp(authRepository: authRepository),
  );
}

class BictreeFoodApp extends StatefulWidget {
  final AuthRepository authRepository;
  final RecipeRepository? recipeRepository;

  const BictreeFoodApp({
    super.key,
    required this.authRepository,
    this.recipeRepository,
  });

  @override
  State<BictreeFoodApp> createState() => _BictreeFoodAppState();
}

class _BictreeFoodAppState extends State<BictreeFoodApp> {
  late final AuthBloc _authBloc;
  late final CartBloc _cartBloc;
  late final HomeBloc _homeBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(
      repository: widget.authRepository,
    )..add(const CheckAuthStatusEvent());

    _cartBloc = CartBloc()..add(const LoadCartEvent());

    _homeBloc = HomeBloc(
      repository: widget.recipeRepository ?? RecipeRepository(),
    )..add(const FetchInitialRecipesEvent());

    _router = createRouter(_authBloc);
  }

  @override
  void dispose() {
    _router.dispose();
    _authBloc.close();
    _cartBloc.close();
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>.value(
      value: widget.authRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBloc),
          BlocProvider<CartBloc>.value(value: _cartBloc),
          BlocProvider<HomeBloc>.value(value: _homeBloc),
        ],
        child: MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: _router,
        ),
      ),
    );
  }
}

