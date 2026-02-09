import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hawklap/components/app_bar/custom_app_bar.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'package:hawklap/models/hawker_center.dart';
import 'package:hawklap/models/menu_item.dart';
import 'package:hawklap/models/street_food.dart';
import 'package:hawklap/models/vote_count.dart';
import 'package:hawklap/services/hawker_center_service.dart';
import 'package:hawklap/services/location_service.dart';
import 'package:hawklap/services/menu_item_service.dart';
import 'package:hawklap/services/street_food_service.dart';
import 'package:hawklap/services/vote_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final _hawkerCenterService = HawkerCenterService();
  final _streetFoodService = StreetFoodService();
  final _menuItemService = MenuItemService();
  final _locationService = LocationService();
  final _voteService = VoteService();

  List<String> _recentlyViewedIds = [];
  List<HawkerCenter> _hawkerCenters = [];
  List<StreetFood> _streetFoods = [];
  List<MenuItem> _menuItems = [];
  Map<String, String> _stallNames = {};
  Map<String, VoteCount> _menuItemVotes = {};
  Map<String, VoteCount> _streetFoodVotes = {};
  Position? _userPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadRecentlyViewed(),
      _loadUserLocation(),
      _loadHawkerCenters(),
      _loadStreetFoods(),
      _loadMenuItems(),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('recently_viewed_street_foods') ?? [];
    if (mounted) {
      setState(() {
        _recentlyViewedIds = ids;
      });
    }
  }

  Future<void> _loadUserLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _userPosition = position;
      });
    }
  }

  Future<void> _loadHawkerCenters() async {
    try {
      final centers = await _hawkerCenterService.getAll();
      if (mounted) {
        setState(() {
          _hawkerCenters = centers;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> _loadStreetFoods() async {
    try {
      final foods = await _streetFoodService.getAll();
      
      // Fetch vote counts for street foods
      final foodIds = foods.map((food) => food.id!).toList();
      final votes = await _voteService.getStreetFoodVotesBatch(foodIds);
      
      if (mounted) {
        setState(() {
          _streetFoods = foods;
          _streetFoodVotes = votes;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> _loadMenuItems() async {
    try {
      final items = await _menuItemService.getAll();
      
      // Fetch stall names for each menu item
      final stallIds = items.map((item) => item.stallId).toSet().toList();
      final Map<String, String> stallNames = {};
      
      for (final stallId in stallIds) {
        final stall = await _streetFoodService.getById(stallId);
        if (stall != null) {
          stallNames[stallId] = stall.name;
        }
      }

      // Fetch vote counts for menu items
      final itemIds = items.map((item) => item.id!).toList();
      final votes = await _voteService.getMenuItemVotesBatch(itemIds);

      if (mounted) {
        setState(() {
          _menuItems = items;
          _stallNames = stallNames;
          _menuItemVotes = votes;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.backgroundApp,
        appBar: const CustomAppBar(title: 'Search'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      appBar: const CustomAppBar(title: 'Search'),
      body: _buildSearchPage(context, colors),
    );
  }

  Widget _buildSearchPage(BuildContext context, AppColorScheme colors) {
    // Dummy data for filters until backend is ready
    final recentlyViewed = _streetFoods
        .where((food) => _recentlyViewedIds.contains(food.id))
        .toList();
    
    // Featured (sponsored) - using dummy flag for now
    final featured = _streetFoods.take(2).toList(); // First 2 as featured
    
    // Veggie - dummy data for now
    final veggie = _streetFoods.take(3).toList();
    
    // Halal - dummy data for now
    final halal = _streetFoods.skip(1).take(3).toList();
    
    // Nearby - sort by distance if we have user location
    List<StreetFood> nearby = [];
    if (_userPosition != null) {
      nearby = [..._streetFoods]
        ..sort((a, b) {
          final distA = _locationService.calculateDistance(
            _userPosition!.latitude,
            _userPosition!.longitude,
            a.latitude,
            a.longitude,
          );
          final distB = _locationService.calculateDistance(
            _userPosition!.latitude,
            _userPosition!.longitude,
            b.latitude,
            b.longitude,
          );
          return distA.compareTo(distB);
        });
      nearby = nearby.take(4).toList();
    } else {
      nearby = _streetFoods.take(4).toList();
    }
    
    // Top Bangers - for now just take first few until votes are implemented
    final topBangers = _streetFoods.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField(colors),
          const SizedBox(height: 20),
          if (featured.isNotEmpty) ...[
            _buildSectionTitle(
              title: 'Featured (Sponsored)',
              subtitle: 'Boosted by merchants',
              colors: colors,
            ),
            _buildCarousel<StreetFood>(
              height: 240,
              items: featured,
              colors: colors,
              itemBuilder: (context, item) => _buildStreetFoodCard(
                item,
                colors,
                showSponsoredBadge: true,
              ),
            ),
            const SizedBox(height: 26),
          ],
          if (recentlyViewed.isNotEmpty) ...[
            _buildSectionTitle(
              title: 'Recently Viewed',
              subtitle: 'Jump back in quickly',
              colors: colors,
            ),
            _buildCarousel<StreetFood>(
              height: 240,
              items: recentlyViewed,
              colors: colors,
              itemBuilder: (context, item) => _buildStreetFoodCard(
                item,
                colors,
              ),
            ),
            const SizedBox(height: 26),
          ],
          if (topBangers.isNotEmpty) ...[
            _buildSectionTitle(
              title: 'Bangers',
              subtitle: 'Highest community upvote ratio',
              colors: colors,
            ),
            _buildCarousel<StreetFood>(
              height: 240,
              items: topBangers,
              colors: colors,
              itemBuilder: (context, item) => _buildStreetFoodCard(
                item,
                colors,
                showBangerBadge: true,
              ),
            ),
            const SizedBox(height: 26),
          ],
          if (nearby.isNotEmpty) ...[
            _buildSectionTitle(
              title: 'Nearby',
              subtitle: 'Hawker centres around you',
              colors: colors,
            ),
            _buildCarousel<StreetFood>(
              height: 240,
              items: nearby,
              colors: colors,
              itemBuilder: (context, item) =>
                  _buildStreetFoodCard(item, colors),
            ),
            const SizedBox(height: 26),
          ],
          if (veggie.isNotEmpty) ...[
            _buildSectionTitle(
              title: 'Veggie',
              subtitle: 'Plant-based favourites',
              colors: colors,
            ),
            _buildCarousel<StreetFood>(
              height: 240,
              items: veggie,
              colors: colors,
              itemBuilder: (context, item) =>
                  _buildStreetFoodCard(item, colors),
            ),
            const SizedBox(height: 26),
          ],
          if (halal.isNotEmpty) ...[
            _buildSectionTitle(
              title: 'Halal',
              subtitle: 'Halal-certified picks',
              colors: colors,
            ),
            _buildCarousel<StreetFood>(
              height: 240,
              items: halal,
              colors: colors,
              itemBuilder: (context, item) =>
                  _buildStreetFoodCard(item, colors),
            ),
            const SizedBox(height: 26),
          ],
          if (_hawkerCenters.isNotEmpty) ...[
            _buildSectionTitle(
              title: 'Hawker Centres',
              subtitle: 'Discover the best local hubs',
              colors: colors,
            ),
            _buildCarousel<HawkerCenter>(
              height: 240,
              items: _hawkerCenters,
              colors: colors,
              itemBuilder: (context, item) => _buildHawkerCenterCard(
                item,
                colors,
              ),
            ),
            const SizedBox(height: 26),
          ],
          if (_menuItems.isNotEmpty) ...[
            _buildSectionTitle(
              title: 'Menus',
              subtitle: 'Trending dishes near you',
              colors: colors,
            ),
            _buildCarousel<MenuItem>(
              height: 240,
              items: _menuItems,
              colors: colors,
              itemBuilder: (context, item) => _buildMenuItemCard(item, colors),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField(AppColorScheme colors) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stalls, dishes, or centres',
                hintStyle: TextStyle(color: colors.textSecondary),
                border: InputBorder.none,
              ),
              style: TextStyle(color: colors.textPrimary),
            ),
          ),
          Icon(Icons.tune, color: colors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required AppColorScheme colors,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel<T>({
    required double height,
    required List<T> items,
    required AppColorScheme colors,
    required Widget Function(BuildContext, T) itemBuilder,
  }) {
    if (items.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Nothing to show yet',
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
      );
    }

    final controller = PageController(viewportFraction: 0.82);
    return SizedBox(
      height: height + 18,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ScrollConfiguration(
          behavior: const _StretchScrollBehavior(),
          child: PageView.builder(
            controller: controller,
            itemCount: items.length,
            padEnds: false,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: itemBuilder(context, items[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStreetFoodCard(
    StreetFood food,
    AppColorScheme colors, {
    bool showSponsoredBadge = false,
    bool showBangerBadge = false,
  }) {
    // Calculate distance if we have user position
    String? distanceText;
    if (_userPosition != null) {
      final distance = _locationService.calculateDistance(
        _userPosition!.latitude,
        _userPosition!.longitude,
        food.latitude,
        food.longitude,
      );
      distanceText = _locationService.formatDistance(distance);
    }

    // Get real vote counts
    final voteCount = _streetFoodVotes[food.id] ?? VoteCount(upvotes: 0, downvotes: 0);

    return _buildBaseCard(
      colors: colors,
      imageChild: food.imageUrl != null && food.imageUrl!.isNotEmpty
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  child: Image.network(
                    food.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(22),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.brandPrimary.withValues(alpha: 0.8),
                              AppColors.brandSecondary.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant_menu,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (showSponsoredBadge || showBangerBadge)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Row(
                      children: [
                        if (showSponsoredBadge) ...[
                          _buildStatusPill(
                            'Sponsored',
                            colors.statusSponsored,
                            colors.textInverse,
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (showBangerBadge) ...[
                          _buildStatusPill(
                            'Banger',
                            colors.actionUpvote,
                            colors.textInverse,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                gradient: LinearGradient(
                  colors: [
                    AppColors.brandPrimary.withValues(alpha: 0.8),
                    AppColors.brandSecondary.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                  if (showSponsoredBadge || showBangerBadge)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Row(
                        children: [
                          if (showSponsoredBadge) ...[
                            _buildStatusPill(
                              'Sponsored',
                              colors.statusSponsored,
                              colors.textInverse,
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (showBangerBadge) ...[
                            _buildStatusPill(
                              'Banger',
                              colors.actionUpvote,
                              colors.textInverse,
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
      title: food.name,
      subtitle: distanceText != null
          ? '${food.description ?? 'Street Food'} • $distanceText'
          : food.description ?? 'Street Food',
      footer: Row(
        children: [
          _buildScoreChip(
            voteCount.upvotes,
            voteCount.downvotes,
            colors.actionUpvote,
            colors.actionDownvote,
          ),
          const SizedBox(width: 10),
          _buildVoteIndicator(
            Icons.thumb_up_outlined,
            voteCount.upvotes,
            colors.actionUpvote,
          ),
          const SizedBox(width: 8),
          _buildVoteIndicator(
            Icons.thumb_down_outlined,
            voteCount.downvotes,
            colors.actionDownvote,
          ),
        ],
      ),
    );
  }

  Widget _buildHawkerCenterCard(
    HawkerCenter center,
    AppColorScheme colors,
  ) {
    // Calculate distance if we have user position
    String? distanceText;
    if (_userPosition != null) {
      final distance = _locationService.calculateDistance(
        _userPosition!.latitude,
        _userPosition!.longitude,
        center.latitude,
        center.longitude,
      );
      distanceText = _locationService.formatDistance(distance);
    }

    return _buildBaseCard(
      colors: colors,
      imageChild: center.imageUrl != null && center.imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: Image.network(
                center.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.location_city,
                      color: colors.textSecondary,
                      size: 42,
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Icon(
                Icons.location_city,
                color: colors.textSecondary,
                size: 42,
              ),
            ),
      title: center.name,
      subtitle: distanceText != null
          ? '${center.address} • $distanceText'
          : center.address,
      footer: Row(
        children: [
          Icon(
            Icons.map_outlined,
            size: 16,
            color: colors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            'Tap to explore',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItem item, AppColorScheme colors) {
    final stallName = _stallNames[item.stallId] ?? 'Unknown Stall';
    final voteCount = _menuItemVotes[item.id] ?? VoteCount(upvotes: 0, downvotes: 0);

    return _buildBaseCard(
      colors: colors,
      imageChild: item.imageUrl != null && item.imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.ramen_dining,
                      color: colors.textSecondary,
                      size: 36,
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Icon(
                Icons.ramen_dining,
                color: colors.textSecondary,
                size: 36,
              ),
            ),
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
            _buildScoreChip(
              voteCount.upvotes,
              voteCount.downvotes,
              colors.actionUpvote,
              colors.actionDownvote,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBaseCard({
    required AppColorScheme colors,
    required Widget imageChild,
    required String title,
    required String subtitle,
    required Widget footer,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              color: colors.backgroundGreyInformation,
            ),
            child: imageChild,
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                footer,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildScoreChip(int upvotes, int downvotes, Color upColor,
      Color downColor) {
    final total = upvotes + downvotes;
    final ratio = total == 0 ? 0 : (upvotes / total) * 100;
    final isPositive = ratio >= 50;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isPositive ? upColor : downColor).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${ratio.toStringAsFixed(0)}% ($total votes)',
        style: TextStyle(
          color: isPositive ? upColor : downColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVoteIndicator(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }
}

class _StretchScrollBehavior extends ScrollBehavior {
  const _StretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return StretchingOverscrollIndicator(
      axisDirection: details.direction,
      child: child,
      clipBehavior: Clip.none,
    );
  }
}
