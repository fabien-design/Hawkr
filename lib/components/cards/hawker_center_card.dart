import 'package:flutter/material.dart';
import 'package:hawklap/components/cards/base_info_card.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'package:hawklap/models/hawker_center.dart';

class HawkerCenterCard extends StatelessWidget {
  final HawkerCenter center;
  final AppColorScheme colors;
  final String? distanceText;

  const HawkerCenterCard({
    super.key,
    required this.center,
    required this.colors,
    this.distanceText,
  });

  @override
  Widget build(BuildContext context) {
    return BaseInfoCard(
      colors: colors,
      imageChild: _buildImageChild(),
      title: center.name,
      subtitle:
          distanceText != null
              ? '${center.address} • $distanceText'
              : center.address,
      footer: Row(
        children: [
          Icon(Icons.map_outlined, size: 16, color: colors.textSecondary),
          const SizedBox(width: 6),
          Text(
            'Tap to explore',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildImageChild() {
    if (center.imageUrl != null && center.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: Image.network(
          center.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(Icons.location_city, color: colors.textSecondary, size: 42),
    );
  }
}
