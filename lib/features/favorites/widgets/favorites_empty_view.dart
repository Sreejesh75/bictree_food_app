import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class FavoritesEmptyView extends StatelessWidget {
  final VoidCallback? onExploreMenu;

  const FavoritesEmptyView({
    super.key,
    this.onExploreMenu,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Layered Aura Illustration with Floating Heart Badges
          Center(
            child: SizedBox(
              width: 240,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer subtle radial aura
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFCDD2).withValues(alpha: 0.35),
                          const Color(0xFFFFF5F5).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),

                  // Middle warm halo
                  Container(
                    width: 136,
                    height: 136,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFEBEE).withValues(alpha: 0.85),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE53935).withValues(alpha: 0.10),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  // Core warm glowing circle
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFF9F9),
                          Color(0xFFFFCDD2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE53935).withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 46,
                      color: Color(0xFFE53935),
                    ),
                  ),

                  // Floating badge top-left: 💖 Loved
                  Positioned(
                    top: 14,
                    left: 6,
                    child: _buildFloatingBadge('💖', 'Loved Bites'),
                  ),

                  // Floating badge top-right: ⭐ 4.9
                  Positioned(
                    top: 20,
                    right: 4,
                    child: _buildFloatingBadge('⭐', 'Top Rated'),
                  ),

                  // Floating badge bottom-right: ⚡ Quick
                  Positioned(
                    bottom: 16,
                    right: 14,
                    child: _buildFloatingBadge('⚡', 'Quick Reorder'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Friendly pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('✨', style: TextStyle(fontSize: 13)),
                SizedBox(width: 6),
                Text(
                  'Keep your favorites in one place',
                  style: TextStyle(
                    color: Color(0xFFC62828),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Screen Heading
          Text(
            'No favorites yet',
            style: AppTextStyles.screenHeading.copyWith(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle description
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              'Tap the heart icon on any mouth-watering recipe to save it here for fast re-ordering!',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySubtitle.copyWith(
                fontSize: 13.5,
                height: 1.5,
                color: const Color(0xFF6E6E73),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Premium "Explore Menu" CTA Button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onExploreMenu ?? () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant_menu_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Explore Menu',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Popular choices divider
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFEBEBEB), thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'POPULAR CATEGORIES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFEBEBEB), thickness: 1)),
            ],
          ),

          const SizedBox(height: 16),

          // Category Shortcut Pills
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildCategoryShortcut(context, '🍕 Snacks'),
              _buildCategoryShortcut(context, '🍲 Meals'),
              _buildCategoryShortcut(context, '🥤 Drinks'),
              _buildCategoryShortcut(context, '🍰 Desserts'),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFloatingBadge(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryShortcut(BuildContext context, String label) {
    return InkWell(
      onTap: onExploreMenu ?? () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E5EA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
