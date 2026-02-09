import 'package:flutter/material.dart';
import '../../core/services/explore/map_service.dart';
import '../../core/theme/app_colors.dart';

class HawkerCenterPanel extends StatelessWidget {
  final List<HawkerCenter> hawkerCenters;
  final ScrollController scrollController;
  final Function(HawkerCenter) onCenterTap;

  const HawkerCenterPanel({
    super.key,
    required this.hawkerCenters,
    required this.scrollController,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.zero,
        itemCount: hawkerCenters.isEmpty ? 2 : hawkerCenters.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Interaction handle
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.borderDefault,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            );
          }

          if (hawkerCenters.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'No hawker centers found in this area.',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            );
          }

          final center = hawkerCenters[index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildHawkerCenterCard(context, center, colors),
          );
        },
      ),
    );
  }

  Widget _buildHawkerCenterCard(
    BuildContext context,
    HawkerCenter center,
    AppColorScheme colors,
  ) {
    return GestureDetector(
      onTap: () => onCenterTap(center),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.borderDefault.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(19),
              ),
              child: Container(
                width: 100,
                height: 100,
                color: colors.backgroundGreyInformation,
                child:
                    center.imageUrl != null
                        ? Image.network(center.imageUrl!, fit: BoxFit.cover)
                        : Icon(
                          Icons.restaurant,
                          color: colors.textDisabled,
                          size: 30,
                        ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      center.address,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.fastfood,
                          size: 14,
                          color: AppColors.brandPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${center.streetFoodCount} Stalls',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.brandPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: colors.textDisabled),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
