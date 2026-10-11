import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Header Title ("Log In", "New Account")
  static TextStyle headerTitle = GoogleFonts.poppins(
    fontSize: 26.0,
    fontWeight: FontWeight.w800,
    color: AppColors.textWhite,
    letterSpacing: 0.2,
  );

  // Screen Main Heading ("Welcome")
  static TextStyle screenHeading = GoogleFonts.poppins(
    fontSize: 26.0,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  // Subtitle / Body text
  static TextStyle bodySubtitle = GoogleFonts.poppins(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  // Field Labels ("Full name", "Password", etc.)
  static TextStyle fieldLabel = GoogleFonts.poppins(
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  // Input Field Text
  static TextStyle inputText = GoogleFonts.poppins(
    fontSize: 14.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  // Input Field Placeholder/Hint
  static TextStyle inputHint = GoogleFonts.poppins(
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    color: AppColors.inputHint,
  );

  // Primary Button Text ("Log In", "Sign Up")
  static TextStyle primaryButton = GoogleFonts.poppins(
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    letterSpacing: 0.3,
  );

  // Action Links ("Forget Password", "Log in", "Sign Up")
  static TextStyle orangeLink = GoogleFonts.poppins(
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryOrange,
  );

  // Subtle Prompt ("or sign up with", "Don't have an account?")
  static TextStyle promptText = GoogleFonts.poppins(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  // Terms and conditions
  static TextStyle termsNotice = GoogleFonts.poppins(
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.35,
  );
}
