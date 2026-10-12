import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/timed_snack_bar.dart';

class UIHelpers {
  UIHelpers._();

  static void showTimedSnackBar(
    BuildContext context, {
    required String message,
    Widget? icon,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    Color progressColor = AppColors.primaryOrange,
    Color backgroundColor = const Color(0xFF1E2022),
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.error : backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
        content: TimedSnackBarContent(
          message: message,
          icon: icon,
          actionLabel: actionLabel,
          onAction: onAction,
          duration: duration,
          progressColor: isError ? Colors.white : progressColor,
        ),
      ),
    );
  }

  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    showTimedSnackBar(
      context,
      message: message,
      isError: isError,
      duration: duration,
      icon: isError
          ? const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            )
          : const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF4CAF50),
              size: 20,
            ),
      progressColor: isError ? Colors.white : AppColors.primaryOrange,
      backgroundColor: const Color(0xFF1E2022),
    );
  }
}
