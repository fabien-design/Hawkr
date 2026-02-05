import 'package:flutter/material.dart';

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
    const Color hawkColor = Color(0xFFF26A2E);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Filters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Search Radius: ${_currentRadius.toStringAsFixed(1)} km',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Slider(
            value: _currentRadius,
            min: 0.5,
            max: 10.0,
            divisions: 19, // (10 - 0.5) / 0.5 = 19 divisions for 0.5 steps
            activeColor: hawkColor,
            inactiveColor: hawkColor.withOpacity(0.2),
            label: '${_currentRadius.toStringAsFixed(1)} km',
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
