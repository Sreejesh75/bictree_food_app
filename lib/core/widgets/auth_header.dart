import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const AuthHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.headerYellow,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.0,
        left: 16.0,
        right: 16.0,
        bottom: 24.0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaryOrange,
                  size: 22,
                ),
              ),
            ),
          Center(
            child: Text(
              title,
              style: AppTextStyles.headerTitle,
            ),
          ),
        ],
      ),
    );
  }
}
