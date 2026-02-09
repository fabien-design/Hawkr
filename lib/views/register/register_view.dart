import 'package:flutter/material.dart';
import 'package:hawklap/components/app_bar/custom_app_bar.dart';
import 'package:hawklap/core/auth/auth_service.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'package:hawklap/core/utils/error_handler.dart';

class RegisterView extends StatefulWidget {
  final AuthService? authService;

  const RegisterView({super.key, this.authService});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final AuthService authService = widget.authService ?? AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void register() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    try {
      await authService.signUp(email: email.trim(), password: password.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Account created successfully! Please check your email to verify.",
            ),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorHandler.getErrorMessage(
          e,
          fallbackMessage: "An error occurred during registration",
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      appBar: const CustomAppBar(title: 'Sign Up', showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm Password'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: register, child: const Text("Sign Up")),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: Text.rich(
                TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(color: colors.textSecondary),
                  children: const [
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.brandPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
