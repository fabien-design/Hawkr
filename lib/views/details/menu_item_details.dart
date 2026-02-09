import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../components/rating/rating_widget.dart';
import '../../models/menu_item.dart';
import '../../models/vote_count.dart';
import '../../services/vote_service.dart';

class MenuItemDetails extends StatefulWidget {
  final MenuItem item;
  final String? stallName;
  final String stallId;

  const MenuItemDetails({
    super.key,
    required this.item,
    this.stallName,
    required this.stallId,
  });

  @override
  State<MenuItemDetails> createState() => _MenuItemDetailsState();
}

class _MenuItemDetailsState extends State<MenuItemDetails> {
  final _voteService = VoteService();

  // Single source of truth for vote state
  bool _isLiked = false;
  bool _isDisliked = false;
  int _upvotes = 0;
  int _downvotes = 0;
  bool _isVoting = false; // prevent double-tap

  @override
  void initState() {
    super.initState();
    _loadVoteData();
  }

  /// Fetch fresh vote counts + user's own vote from the database.
  Future<void> _loadVoteData() async {
    if (widget.item.id == null) return;

    try {
      final results = await Future.wait([
        _voteService.getUserMenuItemVote(widget.item.id!),
        _voteService.getMenuItemVotes(widget.item.id!),
      ]);

      if (mounted) {
        final userVote = results[0] as int?;
        final counts = results[1] as VoteCount;

        setState(() {
          _isLiked = userVote == 1;
          _isDisliked = userVote == -1;
          _upvotes = counts.upvotes;
          _downvotes = counts.downvotes;
        });
      }
    } catch (e) {
      // Silently handle — we still show the UI with defaults
    }
  }

  Future<void> _handleVote(VoteAction action) async {
    if (widget.item.id == null || _isVoting) return;

    setState(() => _isVoting = true);

    try {
      switch (action) {
        case VoteAction.upvote:
          // Insert or update to 1
          await _voteService.voteMenuItem(widget.item.id!, 1);
          break;
        case VoteAction.downvote:
          // Insert or update to -1
          await _voteService.voteMenuItem(widget.item.id!, -1);
          break;
        case VoteAction.removeVote:
          // Delete the row
          await _voteService.removeMenuItemVote(widget.item.id!);
          break;
      }

      // Always re-fetch from database so UI is truthful
      await _loadVoteData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not update vote: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVoting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay buttons
            _buildImageSection(context, colors, screenWidth),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CommunityRatingWidget(
                        isLiked: _isLiked,
                        isDisliked: _isDisliked,
                        upvoteCount: _upvotes,
                        downvoteCount: _downvotes,
                        onVote: _handleVote,
                      ),
                      const Spacer(flex: 2),

                      // Favorite button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.backgroundCard,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 20,
                          color: colors.actionFavorite,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price
                  Text(
                    '\$${widget.item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    widget.item.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Clickable Stall name
                  if (widget.stallName != null)
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to stall details page
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => StallDetails(stallId: widget.stallId),
                        //   ),
                        // );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Navigating to ${widget.stallName} (Not implemented yet)'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'From: ${widget.stallName!}',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.brandPrimary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColors.brandPrimary,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),

                  // Description
                  if (widget.item.description != null) ...[
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.item.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    AppColorScheme colors,
    double screenWidth,
  ) {
    return SizedBox(
      height: 300,
      width: screenWidth,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image or placeholder
          if (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty)
            Image.network(
              widget.item.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: colors.borderDefault,
                    child: Icon(
                      Icons.restaurant,
                      size: 80,
                      color: colors.textDisabled,
                    ),
                  ),
            )
          else
            Container(
              decoration: BoxDecoration(color: colors.borderDefault),
              child: Icon(
                Icons.restaurant,
                size: 80,
                color: colors.textDisabled,
              ),
            ),

          // Gradient overlay at top for status bar readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.backgroundCard,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
