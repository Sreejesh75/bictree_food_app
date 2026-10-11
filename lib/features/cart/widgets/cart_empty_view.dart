import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class CartEmptyView extends StatelessWidget {
  final VoidCallback? onExploreMenu;

  const CartEmptyView({
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

          // Layered Aura Illustration Card with Floating Food Badges
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
                          const Color(0xFFFFE082).withValues(alpha: 0.35),
                          const Color(0xFFFFF8E7).withValues(alpha: 0.0),
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
                      color: const Color(0xFFFFF3D2).withValues(alpha: 0.75),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withValues(alpha: 0.08),
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
                          Color(0xFFFFFDF7),
                          Color(0xFFFFE8B0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withValues(alpha: 0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 46,
                      color: AppColors.primaryOrange,
                    ),
                  ),

                  // Floating accent badge top-left: 🍕 Pizza
                  Positioned(
                    top: 14,
                    left: 6,
                    child: _buildFloatingBadge('🍕', 'Tasty Bites'),
                  ),

                  // Floating accent badge top-right: ⭐ 4.9
                  Positioned(
                    top: 20,
                    right: 4,
                    child: _buildFloatingBadge('⭐', '4.9 Rated'),
                  ),

                  // Floating accent badge bottom-right: 🥗 Fresh
                  Positioned(
                    bottom: 16,
                    right: 14,
                    child: _buildFloatingBadge('🥗', '100% Fresh'),
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
              color: const Color(0xFFFFF0E5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD4B8)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('😋', style: TextStyle(fontSize: 13)),
                SizedBox(width: 6),
                Text(
                  'Hungry for something good?',
                  style: TextStyle(
                    color: Color(0xFFD24B1B),
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
            'Your cart is empty',
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
              'Looks like you haven\'t added any mouth-watering dishes to your cart yet.\nExplore our curated chef specials and satisfy your cravings!',
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
                  'POPULAR CHOICES',
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

          const SizedBox(height: 30),

          // 3 Trust & Perk Badges
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPerkItem(Icons.bolt_rounded, '30 Mins', 'Fast Delivery'),
                _buildPerkDivider(),
                _buildPerkItem(Icons.verified_outlined, '100% Fresh', 'Chef Curated'),
                _buildPerkDivider(),
                _buildPerkItem(Icons.local_shipping_outlined, 'Free \$50+', 'Free Delivery'),
              ],
            ),
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

  Widget _buildPerkItem(IconData icon, String title, String subtitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF4EB),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryOrange, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10.5,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPerkDivider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFEEEEEE),
    );
  }
}
