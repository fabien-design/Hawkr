import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FilterMenu extends StatefulWidget {
  final double initialRadius;
  final RangeValues initialPriceRange;
  final double? initialRating;
  final Function(double, RangeValues, double?) onApply;

  const FilterMenu({
    super.key,
    required this.initialRadius,
    required this.initialPriceRange,
    required this.onApply,
    this.initialRating,
  });

  @override
  State<FilterMenu> createState() => _FilterMenuState();
}

class _FilterMenuState extends State<FilterMenu> {
  late double _currentRadius;
  late RangeValues _currentPriceRange;
  double? _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRadius = widget.initialRadius;
    _currentPriceRange = widget.initialPriceRange;
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    const Color hawkColor = AppColors.brandPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: colors.backgroundSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Radius Slider
            Text(
              'Search Radius: ${_currentRadius.toStringAsFixed(2)} km',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            Slider(
              value: _currentRadius,
              min: 0.5,
              max: 10.0,
              divisions: 19,
              activeColor: hawkColor,
              inactiveColor: hawkColor.withOpacity(0.2),
              label: '${_currentRadius.toStringAsFixed(2)} km',
              onChanged: (value) {
                setState(() {
                  _currentRadius = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Price Range Slider
            Text(
              'Price Range: \$${_currentPriceRange.start.round()} - \$${_currentPriceRange.end.round()}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            RangeSlider(
              values: _currentPriceRange,
              min: 0,
              max: 50,
              divisions: 50,
              activeColor: hawkColor,
              inactiveColor: hawkColor.withOpacity(0.2),
              labels: RangeLabels(
                '\$${_currentPriceRange.start.round()}',
                '\$${_currentPriceRange.end.round()}',
              ),
              onChanged: (values) {
                setState(() {
                  _currentPriceRange = values;
                });
              },
            ),
            const SizedBox(height: 20),
            // Rating Filter
            Text(
              'Minimum Rating:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRatingCheckbox(60, colors, hawkColor),
                _buildRatingCheckbox(70, colors, hawkColor),
                _buildRatingCheckbox(80, colors, hawkColor),
                _buildRatingCheckbox(90, colors, hawkColor),
              ],
            ),
            const SizedBox(height: 30),
            // Apply Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    _currentRadius,
                    _currentPriceRange,
                    _currentRating,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: hawkColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30), // More bottom padding for safe area
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCheckbox(
    double rating,
    AppColorScheme colors,
    Color hawkColor,
  ) {
    final bool isSelected = _currentRating == rating;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _currentRating = null; // Unselect if already selected
          } else {
            _currentRating = rating;
          }
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? hawkColor : colors.textSecondary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
              color: isSelected ? hawkColor : Colors.transparent,
            ),
            child:
                isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
          ),
          const SizedBox(width: 8),
          Text(
            '+${rating.toInt()}%',
            style: TextStyle(
              color: isSelected ? hawkColor : colors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
