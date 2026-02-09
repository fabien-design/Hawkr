import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FilterMenu extends StatefulWidget {
  final double initialRadius;
  final ValueChanged<double> onRadiusChanged;

  const FilterMenu({
    super.key,
    required this.initialRadius,
    required this.onRadiusChanged,
  });

  @override
  State<FilterMenu> createState() => _FilterMenuState();
}

class _FilterMenuState extends State<FilterMenu> {
  late double _currentRadius;

  @override
  void initState() {
    super.initState();
    _currentRadius = widget.initialRadius;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    const Color hawkColor = AppColors.brandPrimary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.backgroundSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              widget.onRadiusChanged(value);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
