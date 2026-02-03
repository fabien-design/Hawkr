import 'package:flutter/material.dart';
import 'package:hawklap/core/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? titleColor;
  final bool showBottomBorder;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.titleColor,
    this.showBottomBorder = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.brandPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: colors.backgroundSurface,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      iconTheme: IconThemeData(color: colors.textPrimary),
      actions: actions,
      shape: showBottomBorder
          ? Border(
              bottom: BorderSide(
                color: colors.borderDefault,
                width: 1,
              ),
            )
          : null,
    );
  }
}
