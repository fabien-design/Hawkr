import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CommunityRatingWidget extends StatefulWidget {
  final String percentage;
  final bool initialIsLiked;
  final bool initialIsDisliked;
  final Function(bool isLiked, bool isDisliked)? onRatingChanged;

  const CommunityRatingWidget({
    super.key,
    required this.percentage,
    this.initialIsLiked = false,
    this.initialIsDisliked = false,
    this.onRatingChanged,
  });

  @override
  State<CommunityRatingWidget> createState() => _CommunityRatingWidgetState();
}

class _CommunityRatingWidgetState extends State<CommunityRatingWidget> {
  late bool _isLiked;
  late bool _isDisliked;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialIsLiked;
    _isDisliked = widget.initialIsDisliked;
  }

  void _updateRating(bool isLiked, bool isDisliked) {
    setState(() {
      _isLiked = isLiked;
      _isDisliked = isDisliked;
    });
    if (widget.onRatingChanged != null) {
      widget.onRatingChanged!(_isLiked, _isDisliked);
    }
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
          // Thumbs up button
          GestureDetector(
            onTap: () {
              bool newLiked = !_isLiked;
              bool newDisliked = _isDisliked;
              if (newLiked) newDisliked = false;
              _updateRating(newLiked, newDisliked);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.brandSuccess.withValues(
                  alpha: _isLiked ? 0.3 : 0.15,
                ),
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
            widget.percentage,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:
                  _isDisliked ? AppColors.brandPrimary : AppColors.brandSuccess,
            ),
          ),
          const SizedBox(width: 16),
          // Thumbs down button
          GestureDetector(
            onTap: () {
              bool newDisliked = !_isDisliked;
              bool newLiked = _isLiked;
              if (newDisliked) newLiked = false;
              _updateRating(newLiked, newDisliked);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(
                  alpha: _isDisliked ? 0.25 : 0.12,
                ),
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
