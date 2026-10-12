import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
import '../../home/screens/home_screen.dart';
import '../../../core/router/app_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _dobController;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _dobController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1930),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrange,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final formatted = DateFormat('dd / MM / yyyy').format(pickedDate);
      setState(() {
        _dobController.text = formatted;
      });
    }
  }

  void _onSignUpPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<AuthBloc>().add(
        SignUpSubmittedEvent(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          mobileNumber: _mobileController.text.trim(),
          password: _passwordController.text,
          dateOfBirth: _dobController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          UIHelpers.showSnackBar(
            context,
            message: state.message,
            isError: true,
          );
        } else if (state is AuthenticatedState) {
          if (state.successMessage != null) {
            UIHelpers.showSnackBar(context, message: state.successMessage!);
          }
          if (GoRouter.maybeOf(context) != null) {
            context.go(AppRoutes.home, extra: state.user);
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => HomeScreen(user: state.user)),
              (route) => false,
            );
          }
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
                AuthHeader(
                  title: AppStrings.newAccount,
                  onBack: () => Navigator.of(context).pop(),
                ),

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
                            CustomTextField(
                              label: AppStrings.fullNameLabel,
                              hintText: AppStrings.fullNameHint,
                              controller: _fullNameController,
                              keyboardType: TextInputType.name,
                              validator: Validators.validateFullName,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 14.0),

                            CustomTextField(
                              label: AppStrings.passwordLabel,
                              hintText: AppStrings.passwordHint,
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: Validators.validatePassword,
                              textInputAction: TextInputAction.next,
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
                            const SizedBox(height: 14.0),

                            CustomTextField(
                              label: AppStrings.emailLabel,
                              hintText: AppStrings.emailHint,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 14.0),

                            CustomTextField(
                              label: AppStrings.mobileNumberLabel,
                              hintText: AppStrings.mobileNumberHint,
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              validator: Validators.validateMobileNumber,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 14.0),

                            CustomTextField(
                              label: AppStrings.dateOfBirthLabel,
                              hintText: AppStrings.dateOfBirthHint,
                              controller: _dobController,
                              readOnly: true,
                              onTap: _selectDateOfBirth,
                              validator: Validators.validateDateOfBirth,
                              suffixIcon: IconButton(
                                onPressed: _selectDateOfBirth,
                                icon: const Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.primaryOrange,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),

                            Center(
                              child: Text(
                                'By continuing, you agree to Terms of Use and Privacy Policy.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.termsNotice,
                              ),
                            ),
                            const SizedBox(height: 18.0),

                            CustomPrimaryButton(
                              text: AppStrings.signUp,
                              isLoading: isLoading,
                              onPressed: _onSignUpPressed,
                            ),
                            const SizedBox(height: 18.0),

                            SocialAuthSection(
                              onGoogleTap: () => UIHelpers.showSnackBar(
                                context,
                                message: 'Google Sign-Up clicked',
                              ),
                              onFacebookTap: () => UIHelpers.showSnackBar(
                                context,
                                message: 'Facebook Sign-Up clicked',
                              ),
                              onBiometricTap: () => UIHelpers.showSnackBar(
                                context,
                                message: 'Biometric Sign-Up clicked',
                              ),
                            ),
                            const SizedBox(height: 18.0),

                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.alreadyHaveAccount,
                                    style: AppTextStyles.promptText,
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Text(
                                      AppStrings.logIn,
                                      style: AppTextStyles.orangeLink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16.0),
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
