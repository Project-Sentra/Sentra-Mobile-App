import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/sentra_logo.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/facilities');
          } else if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        // Logo
                        const SentraLogo(
                          size: 120,
                          isDark: true,
                          showText: false,
                        ),
                        const SizedBox(height: 48),
                        // Sign up / Sign in toggle
                        _buildAuthToggle(isSignIn: true),
                        const SizedBox(height: 32),
                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // Password field
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'password',
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textHint,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Sign In button
                        _buildPrimaryButton(
                          text: 'Sign In',
                          isLoading: state.status == AuthStatus.loading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                AuthSignInRequested(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        // Divider
                        _buildDivider(),
                        const SizedBox(height: 24),
                        // Google Sign In
                        _buildSocialButton(
                          text: 'SIGN IN WITH GOOGLE',
                          icon: Icons.g_mobiledata_rounded,
                          isGoogle: true,
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              const AuthGoogleSignInRequested(),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        // Apple Sign In
                        _buildSocialButton(
                          text: 'SIGN IN WITH APPLE',
                          icon: Icons.apple,
                          isGoogle: false,
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              const AuthAppleSignInRequested(),
                            );
                          },
                        ),
                        const SizedBox(height: 60),
                        // Bottom Sentra text
                        const SentraTextLogo(
                          fontSize: 20,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthToggle({required bool isSignIn}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textDark, width: 1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => context.go('/sign-up'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: !isSignIn ? AppColors.textDark : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Sign up',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: !isSignIn ? AppColors.white : AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSignIn ? AppColors.textDark : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Sign in',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSignIn ? AppColors.white : AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textDark),
                ),
              )
            : Text(
                text,
                style: AppTextStyles.buttonText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.textHint, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.textHint, height: 1)),
      ],
    );
  }

  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required bool isGoogle,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.textDark, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isGoogle ? 28 : 22, color: AppColors.textDark),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
