import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hawklap/components/app_bar/custom_app_bar.dart';
import 'package:hawklap/components/cards/hawker_center_card.dart';
import 'package:hawklap/components/cards/menu_item_card.dart';
import 'package:hawklap/components/cards/street_food_card.dart';
import 'package:hawklap/views/details/hawker_center_details.dart';
import 'package:hawklap/views/details/menu_item_details.dart';
import 'package:hawklap/components/search/horizontal_carousel.dart';
import 'package:hawklap/components/search/search_bar.dart' as custom;
import 'package:hawklap/components/search/section_header.dart';
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
import 'package:hawklap/views/details/street_food_details.dart';
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

  /// Refresh just the menu item vote counts (called when returning from details).
  Future<void> _refreshMenuItemVotes() async {
    try {
      final itemIds = _menuItems
          .where((item) => item.id != null)
          .map((item) => item.id!)
          .toList();
      if (itemIds.isEmpty) return;

      final votes = await _voteService.getMenuItemVotesBatch(itemIds);
      if (mounted) {
        setState(() {
          _menuItemVotes = votes;
        });
      }
    } catch (e) {
      // Silently handle
    }
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
    
    // Top Bangers - TODO : for now just take first few until votes are implemented
    final topBangers = _streetFoods.take(5).toList();

    final streetFoodSections = [
      (title: 'Featured (Sponsored)', subtitle: 'Boosted by merchants', items: featured, showSponsoredBadge: true, showBangerBadge: false),
      (title: 'Recently Viewed', subtitle: 'Jump back in quickly', items: recentlyViewed, showSponsoredBadge: false, showBangerBadge: false),
      (title: 'Bangers', subtitle: 'Highest community upvote ratio', items: topBangers, showSponsoredBadge: false, showBangerBadge: true),
      (title: 'Nearby', subtitle: 'Hawker centres around you', items: nearby, showSponsoredBadge: false, showBangerBadge: false),
      (title: 'Veggie', subtitle: 'Plant-based favourites', items: veggie, showSponsoredBadge: false, showBangerBadge: false),
      (title: 'Halal', subtitle: 'Halal-certified picks', items: halal, showSponsoredBadge: false, showBangerBadge: false),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          for (final section in streetFoodSections)
            if (section.items.isNotEmpty) ...[
              _buildStreetFoodSection(
                title: section.title,
                subtitle: section.subtitle,
                items: section.items,
                colors: colors,
                showSponsoredBadge: section.showSponsoredBadge,
                showBangerBadge: section.showBangerBadge,
              ),
              const SizedBox(height: 26),
            ],
          if (_hawkerCenters.isNotEmpty) ...[
            _buildHawkerCenterSection(colors),
            const SizedBox(height: 26),
          ],
          if (_menuItems.isNotEmpty)
            _buildMenuItemSection(colors),
        ],
      ),
    );
  }

  Widget _buildStreetFoodSection({
    required String title,
    required String subtitle,
    required List<StreetFood> items,
    required AppColorScheme colors,
    bool showSponsoredBadge = false,
    bool showBangerBadge = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, subtitle: subtitle, colors: colors),
        HorizontalCarousel<StreetFood>(
          height: 240,
          items: items,
          colors: colors,
          itemBuilder: (context, item) => StreetFoodCard(
            food: item,
            colors: colors,
            voteCount: _streetFoodVotes[item.id] ?? VoteCount(upvotes: 0, downvotes: 0),
            distanceText: _getDistanceText(item.latitude, item.longitude),
            showSponsoredBadge: showSponsoredBadge,
            showBangerBadge: showBangerBadge,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StreetFoodDetailView(
                    streetFoodId: item.id!,
                  ),
                ),
              );
              _refreshMenuItemVotes();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHawkerCenterSection(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Hawker Centres',
          subtitle: 'Discover the best local hubs',
          colors: colors,
        ),
        HorizontalCarousel<HawkerCenter>(
          height: 240,
          items: _hawkerCenters,
          colors: colors,
          itemBuilder: (context, item) => HawkerCenterCard(
            center: item,
            colors: colors,
            distanceText: _getDistanceText(item.latitude, item.longitude),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HawkerCenterDetailView(
                    hawkerCenterId: item.id!,
                  ),
                ),
              );
              _refreshMenuItemVotes();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemSection(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Menus',
          subtitle: 'Trending dishes near you',
          colors: colors,
        ),
        HorizontalCarousel<MenuItem>(
          height: 240,
          items: _menuItems,
          colors: colors,
          itemBuilder: (context, item) => MenuItemCard(
            item: item,
            colors: colors,
            stallName: _stallNames[item.stallId] ?? 'Unknown Stall',
            voteCount: _menuItemVotes[item.id] ?? VoteCount(upvotes: 0, downvotes: 0),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuItemDetailsView(
                    item: item,
                    stallId: item.stallId,
                  ),
                ),
              );
              _refreshMenuItemVotes();
            },
          ),
        ),
      ],
    );
  }

  String? _getDistanceText(double latitude, double longitude) {
    if (_userPosition == null) return null;
    
    final distance = _locationService.calculateDistance(
      _userPosition!.latitude,
      _userPosition!.longitude,
      latitude,
      longitude,
    );
    return _locationService.formatDistance(distance);
  }
}
