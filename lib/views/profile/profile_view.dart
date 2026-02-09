import 'package:flutter/material.dart';
import 'package:hawklap/components/app_bar/custom_app_bar.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'package:hawklap/core/theme/theme_provider.dart';
import 'package:hawklap/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..loadProfile(),
      child: const _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent();

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final viewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      appBar: const CustomAppBar(title: 'Profile'),
      body:
          viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: Text(
                          viewModel.user?.initials ?? '?',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.user?.nameOrEmail ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (viewModel.user?.displayName != null)
                        Text(
                          viewModel.user!.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Edit profile section
                      if (viewModel.isEditing) ...[
                        Form(
                          key: _formKey,
                          child: SizedBox(
                            width: double.infinity,
                            child: TextFormField(
                              controller: viewModel.displayNameController,
                              decoration: const InputDecoration(
                                labelText: 'Display Name',
                              ),
                              validator: viewModel.validateDisplayName,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: viewModel.toggleEditMode,
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    viewModel.isSaving
                                        ? null
                                        : () async {
                                          if (!_formKey.currentState!
                                              .validate())
                                            return;
                                          try {
                                            final success =
                                                await viewModel.saveProfile();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  success
                                                      ? 'Profile saved successfully'
                                                      : 'Failed to save profile',
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'An error occurred while saving the profile',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                child:
                                    viewModel.isSaving
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              _buildActionTile(
                                icon: Icons.edit,
                                label: 'Edit Profile',
                                colors: colors,
                                onTap: viewModel.toggleEditMode,
                              ),
                              _buildThemeTile(context, colors),
                              _buildActionTile(
                                icon: Icons.logout,
                                label: 'Sign Out',
                                colors: colors,
                                isDestructive: true,
                                onTap:
                                    () =>
                                        _showSignOutDialog(context, viewModel),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required AppColorScheme colors,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? colors.statusError : colors.textPrimary;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildThemeTile(BuildContext context, AppColorScheme colors) {
    final themeProvider = context.watch<ThemeProvider>();

    return ListTile(
      leading: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: colors.textPrimary,
      ),
      title: Text('Dark Mode', style: TextStyle(color: colors.textPrimary)),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (_) => themeProvider.toggleTheme(),
        activeTrackColor: AppColors.brandPrimary.withValues(alpha: 0.5),
        activeThumbColor: AppColors.brandPrimary,
      ),
      onTap: () => themeProvider.toggleTheme(),
    );
  }

  void _showSignOutDialog(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  viewModel.signOut();
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );
  }
}
