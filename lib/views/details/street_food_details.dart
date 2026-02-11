import 'package:flutter/material.dart';
import 'package:hawklap/models/menu_item.dart';
import 'package:hawklap/views/details/menu_item_details.dart';
import '../../core/services/explore/map_service.dart';
import '../../core/theme/app_colors.dart';
import '../../components/rating/rating_widget.dart';
import '../../models/vote_count.dart';
import '../../services/vote_service.dart';
import '../../services/tag_service.dart';

class StreetFoodDetailView extends StatefulWidget {
  final String streetFoodId;

  const StreetFoodDetailView({super.key, required this.streetFoodId});

  @override
  State<StreetFoodDetailView> createState() => _StreetFoodDetailViewState();
}

class _StreetFoodDetailViewState extends State<StreetFoodDetailView> {
  final MapService _mapService = MapService();
  final VoteService _voteService = VoteService();
  final TagService _tagService = TagService();
  bool _isLoading = true;
  StreetFood? _streetFood;
  bool _isFavorite = false;

  // Single source of truth for vote state
  bool _isLiked = false;
  bool _isDisliked = false;
  int _upvotes = 0;
  int _downvotes = 0;
  Map<String, List<String>> _menuItemTags = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _mapService.getStreetFoodDetails(widget.streetFoodId),
        _mapService.isStreetFoodFavorite(widget.streetFoodId),
        _voteService.getUserStreetFoodVote(widget.streetFoodId),
        _voteService.getStreetFoodVotes(widget.streetFoodId),
      ]);

      if (mounted) {
        final food = results[0] as StreetFood?;
        final isFav = results[1] as bool;
        final userVote = results[2] as int?;
        final counts = results[3] as VoteCount;

        Map<String, List<String>> tagsMap = {};
        if (food != null) {
          final itemIds = food.menuItems
              .where((i) => i.id != null)
              .map((i) => i.id!)
              .toList();
          tagsMap = await _tagService.getTagsForMenuItemsBatch(itemIds);
        }

        setState(() {
          _streetFood = food;
          _isFavorite = isFav;
          _isLiked = userVote == 1;
          _isDisliked = userVote == -1;
          _upvotes = counts.upvotes;
          _downvotes = counts.downvotes;
          _menuItemTags = tagsMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading details: $e')));
      }
    }
  }

  Future<void> _handleVote(VoteAction action) async {
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
          await _voteService.voteStreetFood(widget.streetFoodId, 1);
          break;
        case VoteAction.downvote:
          await _voteService.voteStreetFood(widget.streetFoodId, -1);
          break;
        case VoteAction.removeVote:
          await _voteService.removeStreetFoodVote(widget.streetFoodId);
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

  void _toggleFavorite() async {
    try {
      await _mapService.toggleStreetFoodFavorite(widget.streetFoodId);
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating favorite: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.backgroundApp,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_streetFood == null) {
      return Scaffold(
        backgroundColor: colors.backgroundApp,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Street food not found')),
      );
    }

    final food = _streetFood!;

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, food, colors),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingSection(food, colors),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food.name,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: colors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  food.hawkerCenter?.name ?? 'Unknown Location',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTags(food, colors),
                  const SizedBox(height: 32),
                  Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...food.menuItems.map(
                    (item) => _buildMenuItemCard(item, colors),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    StreetFood food,
    AppColorScheme colors,
  ) {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(color: colors.backgroundGreyInformation),
          child:
              food.imageUrl != null
                  ? Image.network(food.imageUrl!, fit: BoxFit.cover)
                  : Center(
                    child: Icon(
                      Icons.image,
                      size: 50,
                      color: colors.textDisabled,
                    ),
                  ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                  colors: colors,
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  iconColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required AppColorScheme colors,
    required Color backgroundColor,
    required Color iconColor,
    double size = 40,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildTags(StreetFood food, AppColorScheme colors) {
    final Set<String> allTags = {};
    for (var item in food.menuItems) {
      final itemTags = _menuItemTags[item.id] ?? [];
      allTags.addAll(itemTags);
    }

    final List<String> tags = allTags.toList();
    if (tags.isEmpty) tags.addAll(['Local', 'Popular', 'Cheap']);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          tags
              .take(6)
              .map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.backgroundGreyInformation,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildRatingSection(StreetFood food, AppColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommunityRatingWidget(
          isLiked: _isLiked,
          isDisliked: _isDisliked,
          upvoteCount: _upvotes,
          downvoteCount: _downvotes,
          onVote: _handleVote,
        ),
        _buildCircularIconButton(
          icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
          onTap: _toggleFavorite,
          colors: colors,
          backgroundColor: colors.backgroundCard,
          iconColor: _isFavorite ? Colors.red : colors.actionFavorite,
        ),
      ],
    );
  }

  Widget _buildMenuItemCard(MenuItem item, AppColorScheme colors) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuItemDetailsView(
              item: item,
              stallId: item.stallId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 100,
                height: 100,
                color: colors.backgroundGreyInformation,
                child:
                    item.imageUrl != null
                        ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                        : Center(
                          child: Icon(Icons.fastfood, color: colors.textDisabled),
                        ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${item.price.toStringAsFixed(2)}\$',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description ??
                        'Delicious meal prepared with fresh ingredients.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textSecondary, fontSize: 14),
                  ),
                  if ((_menuItemTags[item.id] ?? []).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children:
                          (_menuItemTags[item.id] ?? [])
                              .map(
                                (tag) => Text(
                                  '#$tag',
                                  style: const TextStyle(
                                    color: AppColors.brandPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
