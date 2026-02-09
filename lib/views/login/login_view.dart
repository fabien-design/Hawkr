import 'package:flutter/material.dart';
import 'package:hawklap/components/app_bar/custom_app_bar.dart';
import 'package:hawklap/core/auth/auth_service.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'package:hawklap/core/utils/error_handler.dart';
import '../register/register_view.dart';

class LoginView extends StatefulWidget {
  final AuthService? authService;

  const LoginView({super.key, this.authService});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final AuthService authService = widget.authService ?? AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await authService.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorHandler.getErrorMessage(
          e,
          fallbackMessage: "An error occurred during login",
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
      appBar: const CustomAppBar(title: 'Login', showBackButton: true),
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
          const SizedBox(height: 24),
          ElevatedButton(onPressed: login, child: const Text("Login")),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const RegisterView()),
              );
              if (result == true && mounted) {
                Navigator.of(context).pop(true);
              }
            },
            child: Center(
              child: Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(color: colors.textSecondary),
                  children: const [
                    TextSpan(
                      text: 'Sign Up',
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
