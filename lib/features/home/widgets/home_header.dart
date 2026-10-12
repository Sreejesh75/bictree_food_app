import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/models/auth_user.dart';

class HomeHeader extends StatefulWidget {
  final AuthUser user;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onCartTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final int cartCount;

  const HomeHeader({
    super.key,
    required this.user,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.onCartTap,
    required this.onNotificationTap,
    required this.onProfileTap,
    this.cartCount = 0,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearchChanged(query);
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingSubtitle() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Rise And Shine! It\'s Breakfast Time';
    if (hour < 17) return 'Hungry? Grab Your Favorite Lunch';
    return 'Time for Delicious Dinner & Treats';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.headerYellow,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6.0,
        left: 18.0,
        right: 18.0,
        bottom: 18.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14.0),
                      const Icon(
                        Icons.search,
                        color: Color(0xFFB09E74),
                        size: 20,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onQueryChanged,
                          style: AppTextStyles.inputText.copyWith(
                            fontSize: 13.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search food or recipes',
                            hintStyle: AppTextStyles.inputHint.copyWith(
                              fontSize: 13.0,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onFilterTap,
                        child: Container(
                          margin: const EdgeInsets.only(right: 4.0),
                          width: 34.0,
                          height: 34.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEB5A24),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              _buildCircleAction(
                icon: Icons.shopping_cart_outlined,
                onTap: widget.onCartTap,
                badgeCount: widget.cartCount,
              ),
              const SizedBox(width: 8.0),
              _buildCircleAction(
                icon: Icons.notifications_none_rounded,
                onTap: widget.onNotificationTap,
              ),
              const SizedBox(width: 8.0),
              _buildCircleAction(
                icon: Icons.person_outline_rounded,
                onTap: widget.onProfileTap,
              ),
            ],
          ),
          const SizedBox(height: 18.0),
          Text(
            _getGreeting(),
            style: AppTextStyles.headerTitle.copyWith(
              fontSize: 26.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            _getGreetingSubtitle(),
            style: const TextStyle(
              color: Color(0xFFE85826),
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction({
    required IconData icon,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFE85826), size: 20),
          ),
          if (badgeCount != null && badgeCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFE85826),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
