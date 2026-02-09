import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// The action the user wants to perform.
enum VoteAction { upvote, downvote, removeVote }

/// A fully parent-controlled rating widget.
/// The parent owns `isLiked` / `isDisliked` and handles the callback.
class CommunityRatingWidget extends StatelessWidget {
  final bool isLiked;
  final bool isDisliked;
  final int upvoteCount;
  final int downvoteCount;
  final ValueChanged<VoteAction>? onVote;

  const CommunityRatingWidget({
    super.key,
    this.isLiked = false,
    this.isDisliked = false,
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    this.onVote,
  });

  String get _percentage {
    final total = upvoteCount + downvoteCount;
    if (total == 0) return '0%';
    return '${(upvoteCount / total * 100).toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

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
          // ── Upvote button + count ──
          GestureDetector(
            onTap: () {
              // If already liked → remove vote, else → upvote
              onVote?.call(isLiked ? VoteAction.removeVote : VoteAction.upvote);
            },
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.brandSuccess.withValues(
                      alpha: isLiked ? 0.3 : 0.15,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 20,
                    color: AppColors.brandSuccess,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$upvoteCount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isLiked
                        ? AppColors.brandSuccess
                        : colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // ── Percentage ──
          Text(
            _percentage,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDisliked
                  ? AppColors.brandPrimary
                  : AppColors.brandSuccess,
            ),
          ),
          const SizedBox(width: 16),

          // ── Downvote button + count ──
          GestureDetector(
            onTap: () {
              // If already disliked → remove vote, else → downvote
              onVote?.call(
                  isDisliked ? VoteAction.removeVote : VoteAction.downvote);
            },
            child: Row(
              children: [
                Text(
                  '$downvoteCount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDisliked
                        ? AppColors.brandPrimary
                        : colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withValues(
                      alpha: isDisliked ? 0.25 : 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                    size: 20,
                    color: AppColors.brandPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
