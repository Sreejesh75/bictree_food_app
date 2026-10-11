# Bictree Food Delivery App

A clean, production-ready Flutter application built for the **Bictree IT Team - Flutter Developer Task**.

---

## 🏗️ Architecture & Project Structure

The project follows a clean, feature-first structure with **BLoC** state management, centralized API endpoints, direct DummyJSON integration, and persistent local storage:

```text
lib/
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart         # Centralized API URLs (dummyjson.com/recipes & /auth)
│   │   ├── app_colors.dart            # Figma theme color palette
│   │   ├── app_dimensions.dart        # Padding, margin, border-radius constants
│   │   ├── app_strings.dart           # English strings & copy
│   │   └── app_text_styles.dart       # GoogleFonts (Poppins) typography
│   ├── storage/
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
│   │   ├── bloc/                      # AuthBloc, AuthEvent, AuthState
│   │   ├── models/                    # AuthUser model
│   │   ├── repository/                # AuthRepository (DummyJSON login, persistent signups)
│   │   └── screens/                   # LoginScreen, SignUpScreen
│   │
│   └── home/
│       ├── bloc/                      # HomeBloc, HomeEvent, HomeState (pagination, search, sort)
│       ├── models/                    # RecipeModel
│       ├── repository/                # RecipeRepository (dummyjson.com/recipes)
│       ├── widgets/
│       │   ├── banner_carousel.dart   # Auto-changing PageView using assets/images/
│       │   ├── best_seller_section.dart# Horizontal best seller cards with price tags
│       │   ├── category_chips.dart    # Snacks, Meal, Vegan, Dessert, Drinks chips
│       │   ├── home_header.dart       # Top banner, search pill, action icons, greeting
│       │   ├── recipe_card.dart       # 2-column food card with rating & price badges
│       │   ├── recipe_shimmer.dart    # Shimmer skeleton loading placeholder
│       │   └── sort_bottom_sheet.dart # Modal bottom sheet for sorting recipes
│       └── screens/
│           └── home_screen.dart       # Main home dashboard matching Figma UI
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

## 🧪 Testing

Run the automated test suite:
```bash
flutter test
```
All 10 tests pass (AuthBloc tests, HomeBloc tests, and widget smoke tests).
