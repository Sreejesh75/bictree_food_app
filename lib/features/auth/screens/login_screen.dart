import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/auth_header.dart';
import '../../../core/widgets/custom_primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/social_auth_section.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'signup_screen.dart';
import '../../home/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Pre-populate with valid DummyJSON test credentials for instant testing
    _usernameController = TextEditingController(text: 'emilys');
    _passwordController = TextEditingController(text: 'emilyspass');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<AuthBloc>().add(
            LoginSubmittedEvent(
              usernameOrEmail: _usernameController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _onForgotPasswordPressed() {
    UIHelpers.showSnackBar(
      context,
      message: 'Password reset link sent to registered email or mobile number',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          UIHelpers.showSnackBar(context, message: state.message, isError: true);
        } else if (state is AuthenticatedState) {
          if (state.successMessage != null) {
            UIHelpers.showSnackBar(context, message: state.successMessage!);
          }
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomeScreen(user: state.user),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoadingState;

        return Scaffold(
          backgroundColor: AppColors.headerGradientStart,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Premium Branded Header with Badge & Tagline
                AuthHeader(
                  title: AppStrings.logIn,
                  onBack: Navigator.of(context).canPop()
                      ? () => Navigator.of(context).pop()
                      : null,
                  heroWidget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: AppColors.primaryOrange.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/badge_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'FAST & FRESH FOOD DELIVERY',
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // White Card sheet with refined ambient shadow & curved top
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                        vertical: 18.0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Subtle top pull indicator
                            Center(
                              child: Container(
                                width: 44,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 16.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2D9CE),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),

                            // Welcome heading
                            Row(
                              children: [
                                Text(
                                  AppStrings.welcome,
                                  style: AppTextStyles.screenHeading.copyWith(
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                const Text(
                                  '👋',
                                  style: TextStyle(fontSize: 26.0),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6.0),

                            // Subtitle
                            Text(
                              AppStrings.welcomeSubtitle,
                              style: AppTextStyles.bodySubtitle.copyWith(
                                fontSize: 13.0,
                                height: 1.45,
                                color: const Color(0xFF7A6E65),
                              ),
                            ),

                            // Test Credentials Helper Chip
                            Container(
                              margin: const EdgeInsets.only(top: 14.0, bottom: 6.0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: const Color(0xFFFFE6D0),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: AppColors.primaryOrange,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Demo: emilys / emilyspass',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFC2410C),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _usernameController.text = 'emilys';
                                        _passwordController.text = 'emilyspass';
                                      });
                                      UIHelpers.showSnackBar(
                                        context,
                                        message: '✨ Demo credentials filled',
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryOrange,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryOrange
                                                .withValues(alpha: 0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Autofill',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18.0),

                            // Username / Email Input with Prefix Icon
                            CustomTextField(
                              label: AppStrings.emailOrMobileLabel,
                              hintText: AppStrings.emailOrMobileHint,
                              controller: _usernameController,
                              keyboardType: TextInputType.text,
                              validator: Validators.validateEmailOrUsername,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.primaryOrange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 16.0),

                            // Password Input with Lock Icon & Visibility Toggle
                            CustomTextField(
                              label: AppStrings.passwordLabel,
                              hintText: AppStrings.passwordHint,
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: Validators.validatePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _onLoginPressed(),
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.primaryOrange,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.primaryOrange,
                                  size: 21,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),

                            // Forget Password Link with key icon
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _onForgotPasswordPressed,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.lock_reset_rounded,
                                      size: 16,
                                      color: AppColors.primaryOrange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppStrings.forgetPassword,
                                      style: AppTextStyles.orangeLink.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24.0),

                            // Log In Primary Button with Gradient & Arrow
                            CustomPrimaryButton(
                              text: AppStrings.logIn,
                              isLoading: isLoading,
                              onPressed: _onLoginPressed,
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                            const SizedBox(height: 22.0),

                            // Social Auth Section
                            SocialAuthSection(
                              onGoogleTap: () => UIHelpers.showSnackBar(
                                context,
                                message: 'Google Sign-In clicked',
                              ),
                              onFacebookTap: () => UIHelpers.showSnackBar(
                                context,
                                message: 'Facebook Sign-In clicked',
                              ),
                              onBiometricTap: () => UIHelpers.showSnackBar(
                                context,
                                message: 'Biometric Login clicked',
                              ),
                            ),
                            const SizedBox(height: 24.0),

                            // Don't have an account? Sign Up Pill
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF7F2),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFEADBCE),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppStrings.dontHaveAccount,
                                      style: AppTextStyles.promptText.copyWith(
                                        color: const Color(0xFF6B5E55),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => const SignUpScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        AppStrings.signUp,
                                        style: AppTextStyles.orangeLink.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
