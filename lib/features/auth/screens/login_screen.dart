import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          backgroundColor: AppColors.headerYellow,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header (Yellow with back icon & Log In title)
                AuthHeader(
                  title: AppStrings.logIn,
                  onBack: Navigator.of(context).canPop()
                      ? () => Navigator.of(context).pop()
                      : null,
                ),

                // White Card sheet with rounded top corners
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.radiusXL),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: AppDimensions.cardContentPadding,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome heading
                            Text(
                              AppStrings.welcome,
                              style: AppTextStyles.screenHeading,
                            ),
                            const SizedBox(height: 8.0),

                            // Subtitle in clear English
                            Text(
                              AppStrings.welcomeSubtitle,
                              style: AppTextStyles.bodySubtitle,
                            ),
                            const SizedBox(height: 26.0),

                            // Username / Email Input
                            CustomTextField(
                              label: AppStrings.emailOrMobileLabel,
                              hintText: AppStrings.emailOrMobileHint,
                              controller: _usernameController,
                              keyboardType: TextInputType.text,
                              validator: Validators.validateEmailOrUsername,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 18.0),

                            // Password Input
                            CustomTextField(
                              label: AppStrings.passwordLabel,
                              hintText: AppStrings.passwordHint,
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: Validators.validatePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _onLoginPressed(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.primaryOrange,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),

                            // Forget Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _onForgotPasswordPressed,
                                child: Text(
                                  AppStrings.forgetPassword,
                                  style: AppTextStyles.orangeLink,
                                ),
                              ),
                            ),
                            const SizedBox(height: 26.0),

                            // Log In Primary Button
                            CustomPrimaryButton(
                              text: AppStrings.logIn,
                              isLoading: isLoading,
                              onPressed: _onLoginPressed,
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
                            const SizedBox(height: 22.0),

                            // Don't have an account? Sign Up
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.dontHaveAccount,
                                    style: AppTextStyles.promptText,
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
                                      style: AppTextStyles.orangeLink,
                                    ),
                                  ),
                                ],
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
