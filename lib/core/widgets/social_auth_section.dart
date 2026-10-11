import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';

class SocialAuthSection extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onFacebookTap;
  final VoidCallback? onBiometricTap;

  const SocialAuthSection({
    super.key,
    this.onGoogleTap,
    this.onFacebookTap,
    this.onBiometricTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.orSignUpWith,
          style: AppTextStyles.promptText,
        ),
        const SizedBox(height: 14.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialCircleButton(
              onTap: onGoogleTap,
              child: const Text(
                'G',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryOrange,
                  fontFamily: 'serif',
                ),
              ),
            ),
            const SizedBox(width: 18.0),
            _SocialCircleButton(
              onTap: onFacebookTap,
              child: const Text(
                'f',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryOrange,
                  fontFamily: 'sans-serif',
                ),
              ),
            ),
            const SizedBox(width: 18.0),
            _SocialCircleButton(
              onTap: onBiometricTap,
              child: const Icon(
                Icons.fingerprint_rounded,
                size: 26,
                color: AppColors.primaryOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _SocialCircleButton({
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.socialButtonSize / 2),
      child: Container(
        width: AppDimensions.socialButtonSize,
        height: AppDimensions.socialButtonSize,
        decoration: BoxDecoration(
          color: AppColors.socialIconBg,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.socialIconBorder,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
