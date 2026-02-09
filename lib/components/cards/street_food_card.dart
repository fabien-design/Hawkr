import 'package:flutter/material.dart';
import 'package:hawklap/components/cards/base_info_card.dart';
import 'package:hawklap/components/common/status_badge.dart';
import 'package:hawklap/components/common/vote_score_chip.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'package:hawklap/models/street_food.dart';
import 'package:hawklap/models/vote_count.dart';

class StreetFoodCard extends StatelessWidget {
  final StreetFood food;
  final AppColorScheme colors;
  final VoteCount voteCount;
  final String? distanceText;
  final bool showSponsoredBadge;
  final bool showBangerBadge;
  final VoidCallback? onTap;

  const StreetFoodCard({
    super.key,
    required this.food,
    required this.colors,
    required this.voteCount,
    this.distanceText,
    this.showSponsoredBadge = false,
    this.showBangerBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BaseInfoCard(
        colors: colors,
        imageChild: _buildImageChild(),
        title: food.name,
        subtitle:
            distanceText != null
                ? '${food.description ?? 'Street Food'} • $distanceText'
                : food.description ?? 'Street Food',
        footer: VoteScoreChip(
          upvotes: voteCount.upvotes,
          downvotes: voteCount.downvotes,
          upvoteColor: colors.actionUpvote,
          downvoteColor: colors.actionDownvote,
        ),
      ),
    );
  }

  Widget _buildImageChild() {
    if (food.imageUrl != null && food.imageUrl!.isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Image.network(
              food.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            ),
          ),
          if (showSponsoredBadge || showBangerBadge) _buildBadges(),
        ],
      );
    }

    return Stack(
      children: [
        _buildPlaceholder(),
        if (showSponsoredBadge || showBangerBadge) _buildBadges(),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        gradient: LinearGradient(
          colors: [
            AppColors.brandPrimary.withValues(alpha: 0.8),
            AppColors.brandSecondary.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.restaurant_menu, size: 42, color: Colors.white),
      ),
    );
  }

  Widget _buildBadges() {
    return Positioned(
      top: 12,
      left: 12,
      child: Row(
        children: [
          if (showSponsoredBadge) ...[
            StatusBadge(
              text: 'Sponsored',
              backgroundColor: colors.statusSponsored,
              foregroundColor: colors.textInverse,
            ),
            const SizedBox(width: 6),
          ],
          if (showBangerBadge) ...[
            StatusBadge(
              text: 'Banger',
              backgroundColor: colors.actionUpvote,
              foregroundColor: colors.textInverse,
            ),
          ],
        ],
      ),
    );
  }
}
