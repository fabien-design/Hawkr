  import 'package:flutter/material.dart';

class VoteScoreChip extends StatelessWidget {
  final int upvotes;
  final int downvotes;
  final Color upvoteColor;
  final Color downvoteColor;

  const VoteScoreChip({
    super.key,
    required this.upvotes,
    required this.downvotes,
    required this.upvoteColor,
    required this.downvoteColor,
  });

  @override
  Widget build(BuildContext context) {
    final total = upvotes + downvotes;

    // No votes at all - show "no ratings" in gray
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'no ratings',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final ratio = (upvotes / total) * 100;
    final isPositive = ratio >= 50;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isPositive ? upvoteColor : downvoteColor).withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${ratio.toStringAsFixed(0)}%',
        style: TextStyle(
          color: isPositive ? upvoteColor : downvoteColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
