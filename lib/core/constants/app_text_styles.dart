import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle headerTitle = GoogleFonts.poppins(
    fontSize: 26.0,
    fontWeight: FontWeight.w800,
    color: AppColors.textWhite,
    letterSpacing: 0.2,
  );

  static TextStyle screenHeading = GoogleFonts.poppins(
    fontSize: 26.0,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static TextStyle bodySubtitle = GoogleFonts.poppins(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle fieldLabel = GoogleFonts.poppins(
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle inputText = GoogleFonts.poppins(
    fontSize: 14.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static TextStyle inputHint = GoogleFonts.poppins(
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    color: AppColors.inputHint,
  );

  static TextStyle primaryButton = GoogleFonts.poppins(
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    letterSpacing: 0.3,
  );

  static TextStyle orangeLink = GoogleFonts.poppins(
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryOrange,
  );

  static TextStyle promptText = GoogleFonts.poppins(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static TextStyle termsNotice = GoogleFonts.poppins(
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.35,
  );
}
