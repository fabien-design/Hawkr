import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../components/rating/rating_widget.dart';
import '../../models/menu_item.dart';
import '../../models/vote_count.dart';
import '../../services/favorite_service.dart';
import '../../services/street_food_service.dart';
import '../../services/vote_service.dart';
import 'street_food_details.dart';

class MenuItemDetailsView extends StatefulWidget {
  final MenuItem item;
  final String stallId;

  const MenuItemDetailsView({
    super.key,
    required this.item,
    required this.stallId,
  });

  @override
  State<MenuItemDetailsView> createState() => _MenuItemDetailsViewState();
}

class _MenuItemDetailsViewState extends State<MenuItemDetailsView> {
  final _voteService = VoteService();
  final _streetFoodService = StreetFoodService();
  final _favoriteService = FavoriteService();

  // Single source of truth for vote state
  bool _isLiked = false;
  bool _isDisliked = false;
  int _upvotes = 0;
  int _downvotes = 0;
  String? _stallName;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadVoteData();
    _loadStallName();
    _loadFavoriteStatus();
  }

  Future<void> _loadStallName() async {
    try {
      final stall = await _streetFoodService.getById(widget.stallId);
      if (mounted && stall != null) {
        setState(() {
          _stallName = stall.name;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadFavoriteStatus() async {
    if (widget.item.id == null) return;
    try {
      final isFav = await _favoriteService.isMenuItemFavorite(widget.item.id!);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    if (widget.item.id == null) return;
    try {
      await _favoriteService.toggleMenuItemFavorite(widget.item.id!);
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating favorite: $e')),
        );
      }
    }
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
    if (widget.item.id == null) return;

    // Save previous state for rollback
    final prevLiked = _isLiked;
    final prevDisliked = _isDisliked;
    final prevUpvotes = _upvotes;
    final prevDownvotes = _downvotes;

    // Apply optimistic update immediately
    setState(() {
      switch (action) {
        case VoteAction.upvote:
          _upvotes += 1;
          if (_isDisliked) _downvotes -= 1;
          _isLiked = true;
          _isDisliked = false;
          break;
        case VoteAction.downvote:
          _downvotes += 1;
          if (_isLiked) _upvotes -= 1;
          _isDisliked = true;
          _isLiked = false;
          break;
        case VoteAction.removeVote:
          if (_isLiked) _upvotes -= 1;
          if (_isDisliked) _downvotes -= 1;
          _isLiked = false;
          _isDisliked = false;
          break;
      }
    });

    // Fire DB call in background — revert on failure
    try {
      switch (action) {
        case VoteAction.upvote:
          await _voteService.voteMenuItem(widget.item.id!, 1);
          break;
        case VoteAction.downvote:
          await _voteService.voteMenuItem(widget.item.id!, -1);
          break;
        case VoteAction.removeVote:
          await _voteService.removeMenuItemVote(widget.item.id!);
          break;
      }
    } catch (e) {
      // Rollback to previous state
      if (mounted) {
        setState(() {
          _isLiked = prevLiked;
          _isDisliked = prevDisliked;
          _upvotes = prevUpvotes;
          _downvotes = prevDownvotes;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not update vote: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
                      GestureDetector(
                        onTap: _toggleFavorite,
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
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: _isFavorite ? Colors.red : colors.actionFavorite,
                          ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Clickable Stall name
                  if (_stallName != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StreetFoodDetailView(
                              streetFoodId: widget.stallId,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              'From: $_stallName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.brandPrimary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
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
