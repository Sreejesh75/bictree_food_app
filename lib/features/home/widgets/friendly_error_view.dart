import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/errors/failures.dart';
import '../../../core/widgets/custom_primary_button.dart';

class FriendlyErrorView extends StatelessWidget {
  final Failure? failure;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback? onBrowseCache;
  final bool hasCachedFallback;

  const FriendlyErrorView({
    super.key,
    this.failure,
    this.errorMessage,
    required this.onRetry,
    this.onBrowseCache,
    this.hasCachedFallback = false,
  });

  @override
  Widget build(BuildContext context) {
    final isOffline = failure is NetworkFailure;
    final isServer = failure is ServerFailure;

    final IconData mainIcon = isOffline
        ? Icons.wifi_off_rounded
        : isServer
        ? Icons.cloud_off_rounded
        : Icons.restaurant_rounded;

    final String title = isOffline
        ? 'No Internet Connection'
        : isServer
        ? 'Kitchen Servers Are Busy'
        : 'Couldn\'t Load The Menu';

    final String description = errorMessage != null && errorMessage!.isNotEmpty
        ? errorMessage!
        : isOffline
        ? 'We couldn\'t connect to our food servers. Please verify your Wi-Fi or mobile data connection and try again.'
        : isServer
        ? 'Our kitchen servers encountered a temporary issue. Our chefs are working on it—please retry shortly.'
        : 'An unexpected issue occurred while fetching dishes. Tap retry to reconnect.';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFFFFF3EB), const Color(0xFFFFE0D0)],
                ),
                border: Border.all(color: const Color(0xFFFFD1BC), width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrange.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Icon(mainIcon, size: 52, color: AppColors.primaryOrange),
              ),
            ),
            const SizedBox(height: 24.0),

            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.screenHeading.copyWith(
                fontSize: 22.0,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10.0),

            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF7A6E65),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28.0),

            CustomPrimaryButton(
              text: 'Try Again',
              width: 200,
              height: 48,
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 18,
              ),
              onPressed: onRetry,
            ),

            if (hasCachedFallback && onBrowseCache != null) ...[
              const SizedBox(height: 12.0),
              TextButton.icon(
                onPressed: onBrowseCache,
                icon: const Icon(
                  Icons.offline_bolt_rounded,
                  color: AppColors.primaryOrange,
                  size: 18,
                ),
                label: Text(
                  'Browse Offline Dishes',
                  style: GoogleFonts.poppins(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
