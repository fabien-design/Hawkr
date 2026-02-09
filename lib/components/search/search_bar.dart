import 'package:flutter/material.dart';
import 'package:hawklap/core/theme/app_colors.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final AppColorScheme colors;
  final VoidCallback? onFilterTap;

  const SearchBar({
    super.key,
    required this.controller,
    required this.colors,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Search stalls, dishes, or centres',
                hintStyle: TextStyle(color: colors.textSecondary),
                border: InputBorder.none,
              ),
              style: TextStyle(color: colors.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: onFilterTap,
            child: Icon(Icons.tune, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
