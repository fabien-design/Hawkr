import 'package:flutter/material.dart';
import 'package:hawklap/core/theme/app_colors.dart';

class FavouritesView extends StatelessWidget {
  const FavouritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      appBar: AppBar(
        title: Text(
          'Favourites',
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
          'Favourites',
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
