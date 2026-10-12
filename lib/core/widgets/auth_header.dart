import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? heroWidget;
  final Widget? subtitleWidget;

  const AuthHeader({
    super.key,
    required this.title,
    this.onBack,
    this.heroWidget,
    this.subtitleWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.headerGradientStart,
            AppColors.headerGradientEnd,
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Ambient soft background circles for premium visual depth
          Positioned(
            top: -24,
            right: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          // Main Header Content
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 6.0,
              left: 16.0,
              right: 16.0,
              bottom: heroWidget != null ? 18.0 : 22.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (onBack != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.28),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: onBack,
                            padding: const EdgeInsets.only(right: 2),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    Center(
                      child: Text(
                        title,
                        style: AppTextStyles.headerTitle.copyWith(
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (heroWidget != null) ...[
                  const SizedBox(height: 12.0),
                  heroWidget!,
                ],
                if (subtitleWidget != null) ...[
                  const SizedBox(height: 6.0),
                  subtitleWidget!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
