# Bictree Food Delivery App

A clean, production-ready Flutter application built for the **Bictree IT Team - Flutter Developer Task**.

---

## 🏗️ Architecture & Project Structure

The project strictly adheres to **Layered Clean Architecture (data / domain / presentation)** with the **Repository Pattern**, **BLoC** state management, centralized **Dio** networking with an **AuthInterceptor**, **GoRouter** declarative routing, and local persistence:

```text
lib/
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart         # Centralized API URLs (dummyjson.com/recipes & /auth)
│   │   ├── app_colors.dart            # Figma theme color palette
│   │   ├── app_dimensions.dart        # Padding, margin, border-radius constants
│   │   ├── app_strings.dart           # English strings & copy
│   │   └── app_text_styles.dart       # GoogleFonts (Poppins) typography
│   ├── errors/
│   │   └── failures.dart              # Typed Failure models & DioException mapper
│   ├── network/
│   │   ├── auth_interceptor.dart      # Dio Bearer token injection & 401 handling
│   │   └── dio_client.dart            # Centralized Dio HTTP client factory
│   ├── router/
│   │   └── app_router.dart            # Declarative GoRouter configuration & auth guards
│   ├── storage/
│   │   ├── hive_recipe_cache_service.dart # Offline recipe caching
│   │   └── secure_storage_service.dart# Secure token storage & persistent user registry
│   ├── theme/
│   │   └── app_theme.dart             # Light Material 3 theme
│   ├── utils/
│   │   ├── ui_helpers.dart            # Floating SnackBars & feedback dialogs
│   │   └── validators.dart            # Form validations
│   └── widgets/
│       ├── auth_header.dart           # Yellow header with back button
│       ├── curved_bottom_nav_bar.dart # Curved bottom dock (5 icons)
│       ├── custom_primary_button.dart # Orange pill button with loading state
│       ├── custom_text_field.dart     # Cream rounded input with obscure toggle
│       └── social_auth_section.dart   # Social sign-in buttons (Google, Facebook, Biometrics)
│
├── features/
│   ├── auth/
│   │   ├── data/                      # DATA LAYER: AuthRemoteDataSource (Dio), AuthLocalDataSource, AuthRepoImpl
│   │   ├── domain/                    # DOMAIN LAYER: AuthUser entity, IAuthRepository contract
│   │   └── presentation/              # PRESENTATION LAYER: AuthBloc, LoginScreen, SignUpScreen
│   │
│   ├── home/
│   │   ├── data/                      # DATA LAYER: RecipeRemoteDataSource (Dio), RecipeLocalDataSource (Hive), RecipeRepoImpl
│   │   ├── domain/                    # DOMAIN LAYER: RecipeModel & RecipePageResult entities, IRecipeRepository contract
│   │   └── presentation/              # PRESENTATION LAYER: HomeBloc, HomeScreen, RecipeDetailScreen, Widgets
│   │
│   ├── cart/
│   │   ├── data/                      # DATA LAYER: CartLocalDataSource (SharedPreferences), CartRepoImpl
│   │   ├── domain/                    # DOMAIN LAYER: CartItem entity, ICartRepository contract
│   │   └── presentation/              # PRESENTATION LAYER: CartBloc, CartScreen, Widgets
│   │
│   └── favorites/
│       └── presentation/              # PRESENTATION LAYER: FavoritesScreen, Widgets
└── main.dart
```

---

## 🍽️ Feature 2: Home / Food List Implementation

1. **Centralized API Endpoints**:
   - Centralized in `ApiEndpoints` (`lib/core/constants/api_endpoints.dart`).
   - Base URL: `https://dummyjson.com`
   - Recipes URL: `https://dummyjson.com/recipes`
   - Search URL: `https://dummyjson.com/recipes/search`
   - Category filtering: `https://dummyjson.com/recipes/meal-type/...` and `.../tag/...`

2. **Infinite Scroll Pagination**:
   - Seamlessly fetches batches with `?limit=10&skip=...` as the user scrolls toward the bottom of the list.
   - Smooth loading spinner at the bottom when more items are being fetched.

3. **Debounced Search**:
   - Search text field in `HomeHeader` debounces input by 400ms before triggering API query to prevent excessive network requests.

4. **Category Chips**:
   - Filter chips matching the Figma design:
     - **Snacks**
     - **Meal**
     - **Vegan**
     - **Dessert**
     - **Drinks**
   - Active chip highlight with instant filtered dish updates.

5. **Sort By**:
   - Dedicated filter button opens the `SortBottomSheet` supporting:
     - Top Rated (Rating: High to Low)
     - Price: Low to High
     - Price: High to Low
     - Light & Healthy (Calories: Low to High)

6. **Auto-Changing Promotional Banner Carousel**:
   - Automatically rotates between `assets/images/banner_1.jpg`, `banner_2.jpg`, and `banner_3.jpg` every 4 seconds.
   - Includes page indicator dots with active orange pill indicator.

7. **Skeleton / Shimmer Loading & Pull-to-Refresh**:
   - Skeleton shimmer cards using `shimmer` package shown during initial data loads and category transitions.
   - `RefreshIndicator` supports smooth pull-to-refresh to fetch fresh data.
   - Error state with a "Try Again" retry action button on connectivity issues.

8. **Food Item Details Bottom Sheet**:
   - Tapping any recipe displays a detailed sheet with recipe image, title, rating, cook time, ingredients tags, and "Add to Cart" button.

---

## ⚙️ Setup & Run Instructions

### Prerequisites
- **Flutter Version**: Flutter 3.38.9 (Channel stable)
- **Dart SDK**: Dart 3.10.8
- **Platform**: Android / iOS / Web / macOS / Windows / Linux

### Installation & Run
```bash
# 1. Clone the repository
git clone https://github.com/Sreejesh75/bictree_food_app.git
cd bictree_food_app

# 2. Get dependencies
flutter pub get

# 3. Run the application
flutter run

# 4. (Optional) Build release APK
flutter build apk --release
```

---

## 🏛️ State Management: Why We Chose BLoC
We chose **BLoC (Business Logic Component)** over Riverpod because its explicit, event-driven state streams enforce strict unidirectional data flow and clean decoupling between business rules and UI presentation. This structure makes complex multi-step flows—such as reactive authentication guards with `GoRouter`, debounced pagination, and undoable cart operations—highly predictable, testable, and maintainable.

---

## 💡 Engineering Decisions & Implementation Details

### 1. Mock Pricing Formula & Category Mappings
- **Mock Pricing**: The DummyJSON Recipes API does not provide price fields. To ensure consistent, deterministic prices across user sessions, we compute:
  $$\text{Price} = 10.0 + ((\text{id} \times 7.25) \pmod{95.0})$$
  formatted to 1–2 decimal places (e.g. \$24.50, \$31.80).
- **Category Mappings**:
  - **Snacks** &rarr; `/recipes/meal-type/snack`
  - **Meal** &rarr; `/recipes/meal-type/dinner`
  - **Vegan** &rarr; `/recipes/tag/vegetarian`
  - **Dessert** &rarr; `/recipes/meal-type/dessert`
  - **Drinks** &rarr; `/recipes/meal-type/beverage`

### 2. Architecture: Layered Clean Architecture
- **Domain Layer**: Contains business entities (`AuthUser`, `RecipeModel`, `CartItem`) and abstract repository contracts (`IAuthRepository`, `IRecipeRepository`, `ICartRepository`).
- **Data Layer**: Houses remote data sources (`Dio` with `AuthInterceptor`), local data sources (`Hive`, `SecureStorage`, `SharedPreferences`), and concrete repository implementations.
- **Presentation Layer**: Houses `BLoC` state management, Flutter screens, responsive widgets, and modal bottom sheets.

### 3. Decisions, Trade-offs & Skipped Features
- **Offline-First Resilience**: Integrated Hive caching for instant offline recipe viewing and SharedPreferences for per-user cart persistence across sign-ins.
- **Simulated Payment**: Rather than integrating a real Stripe/PayPal gateway, we implemented a simulated checkout and order placement workflow with feedback animations.
- **Unified Scrolling**: Refactored the Home screen into a unified sliver/scroll view so headers and dish catalogs scroll harmoniously without fixed clipping.

### 4. What We Would Improve With More Time
- **Live Order Tracking**: Integration with Google Maps SDK and WebSockets to show real-time driver delivery movement.
- **Push Notifications**: Firebase Cloud Messaging (FCM) for order updates and flash promotions.
- **Dark Theme**: Complete dark mode palette toggle.

---

## 🧪 Test Results

The test suite covers unit logic, repository contracts, network interceptors, routing guards, and UI widget forms.

### Run All Tests:
```bash
flutter test
```

### Test Coverage Summary (48 Passing Tests):
- **Cart Logic Unit Tests** (`test/features/cart/cart_bloc_test.dart`): Initial empty state, item addition, quantity updates, removal upon zero, undo restore, and per-user local persistence.
- **Repository Unit Tests** (`test/features/home/recipe_repository_test.dart`): Remote data parsing, local caching on first fetch, offline fallback upon network failure, and debounced search.
- **Network & Interceptor Tests** (`test/core/network/auth_interceptor_test.dart`): Bearer token injection, public auth exclusion, and 401 unauthorized handling.
- **Router Guard Tests** (`test/core/router/app_router_test.dart`): Route constants, initial routing, and auth redirect guards.
- **Widget Tests**:
  - Login Form (`test/widget_test.dart`): Form rendering, validation, and layout checks.
  - Cart Screen (`test/features/cart/cart_screen_test.dart`): Empty state, item counters, subtotal updates, and swipe-to-delete.
  - Navigation Sheets (`test/features/home/nav_sheets_test.dart`): Profile, Order History, and VIP Concierge bottom sheets.

---

## ⏱️ Time Spent
- **Total Development Time**: **~15 hours**
  - Project architecture & Figma design system: 3 hours
  - BLoC state management & Dio network layer: 3 hours
  - Persistent Cart, Favorites & User session storage: 3 hours
  - Clean Architecture refactoring & GoRouter navigation: 3 hours
  - Unit & widget test suite and documentation: 3 hours

