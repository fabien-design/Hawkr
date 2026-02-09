import 'package:flutter/material.dart';
import 'package:hawklap/components/cards/base_info_card.dart';
import 'package:hawklap/components/common/vote_score_chip.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'package:hawklap/models/menu_item.dart';
import 'package:hawklap/models/vote_count.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final AppColorScheme colors;
  final String stallName;
  final VoteCount voteCount;
  final VoidCallback? onTap;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.colors,
    required this.stallName,
    required this.voteCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BaseInfoCard(
        colors: colors,
        imageChild: _buildImageChild(),
        title: item.name,
        subtitle: stallName,
      footer: Row(
        children: [
          Text(
            '\$${item.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.brandPrimary,
            ),
          ),
          if (voteCount.total > 0) ...[
            const SizedBox(width: 10),
            VoteScoreChip(
              upvotes: voteCount.upvotes,
              downvotes: voteCount.downvotes,
              upvoteColor: colors.actionUpvote,
              downvoteColor: colors.actionDownvote,
            ),
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildImageChild() {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: Image.network(
          item.imageUrl!,
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
      child: Icon(Icons.ramen_dining, color: colors.textSecondary, size: 36),
    );
  }
}
