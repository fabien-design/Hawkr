import 'package:flutter/material.dart';
import 'package:hawklap/core/theme/app_colors.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      appBar: AppBar(
        title: Text(
          'Search',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colors.backgroundSurface,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Search',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
