import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MenuItemDetails extends StatefulWidget {
  const MenuItemDetails({super.key});

  @override
  State<MenuItemDetails> createState() => _MenuItemDetailsState();
}


class _MenuItemDetailsState extends State<MenuItemDetails> {
  bool _isLiked = false;
  bool _isDisliked = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay buttons
            _buildImageSection(context, colors, screenWidth),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildCommunityRatingCard(colors),
                      const Spacer(flex: 2),

                      // Favorite button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.backgroundCard,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 20,
                          color: colors.actionFavorite,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Chili Crab Noodle',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Vegetarian tag
                  Row(
                    children: [
                      Text(
                        '🌿',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'vegetarian',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.brandSuccess,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Category chips
                  _buildCategoryChips(colors),
                  const SizedBox(height: 18),

                  // Description
                  Text(
                    'Chili Crab Noodles are a popular Singaporean dish combining tender noodles with fresh crab meat in a rich, sweet, and spicy tomato-chili sauce, often enhanced with garlic and egg for a savory, comforting flavor.',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Allergen section
                  _buildAllergenSection(colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(
      BuildContext context, AppColorScheme colors, double screenWidth) {
    return SizedBox(
      height: 300,
      width: screenWidth,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // fake image
          Container(
            decoration: BoxDecoration(
              color: colors.borderDefault,
            ),
            child: Icon(
              Icons.restaurant,
              size: 80,
              color: colors.textDisabled,
            ),
          ),

          // Gradient overlay at top for status bar readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.backgroundCard,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(AppColorScheme colors) {
    final categories = ['Local', 'Noodle', 'Crab'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.borderDefault),
          ),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 13,
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllergenSection(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Allergen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildAllergenItem(Icons.water_drop_outlined, 'Mollusc'),
            const SizedBox(width: 20),
            _buildAllergenItem(Icons.grass, 'Soyan'),
            const SizedBox(width: 20),
            _buildAllergenItem(Icons.egg_outlined, 'Peanuts'),
          ],
        ),
      ],
    );
  }

  Widget _buildAllergenItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFDE8E0),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: AppColors.brandPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityRatingCard(AppColorScheme colors) {
    return Container(
        decoration: BoxDecoration(
          color: colors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbs up button
            GestureDetector(
              onTap: () {
                setState(() {
                  _isLiked = !_isLiked;
                  if (_isLiked) _isDisliked = false;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brandSuccess.withValues(alpha: _isLiked ? 0.3 : 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  size: 20,
                  color: AppColors.brandSuccess,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Percentage
            Text(
              '96%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isDisliked ? AppColors.brandPrimary : AppColors.brandSuccess,
              ),
            ),
            const SizedBox(width: 16),
            // Thumbs down button
            GestureDetector(
              onTap: () {
                setState(() {
                  _isDisliked = !_isDisliked;
                  if (_isDisliked) _isLiked = false;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: _isDisliked ? 0.25 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                  size: 20,
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
          ],
        ),
    );
  }
}
