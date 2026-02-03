import 'package:flutter/material.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'add_hawker_center_view.dart';
import 'add_street_food_view.dart';
import 'add_menu_item_view.dart';

class AddView extends StatelessWidget {
  const AddView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      appBar: AppBar(
        title: Text(
          'Add',
          style: TextStyle(
            color: AppColors.brandPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: Border(
          bottom: BorderSide(
            color: colors.borderDefault,
            width: 1,
          )
        ),
        backgroundColor: colors.backgroundSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contribute to Hawkr',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help the community discover great street food by adding new hawker centers, stalls, or menu items.',
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            _AddOptionCard(
              icon: Icons.location_on_outlined,
              title: 'Add Hawker Center',
              subtitle: 'Register a new hawker center location',
              colors: colors,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddHawkerCenterView(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _AddOptionCard(
              icon: Icons.restaurant_outlined,
              title: 'Add Street Food',
              subtitle: 'Add a food stall to an existing center',
              colors: colors,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddStreetFoodView(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _AddOptionCard(
              icon: Icons.menu_book_outlined,
              title: 'Add Menu Item',
              subtitle: 'Add dishes to an existing stall',
              colors: colors,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddMenuItemView(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Material(
              color: colors.backgroundGreyInformation,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Icon(
                          Icons.info_outline,
                          color: colors.textSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Community Validation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'All submissions are reviewed by the community. Validated contributions earn badges and increase your reputation.',
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final AppColorScheme colors;

  const _AddOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.backgroundCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.brandPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.brandPrimary,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
