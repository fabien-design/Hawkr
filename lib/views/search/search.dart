import 'package:flutter/material.dart';
import 'package:hawklap/components/app_bar/custom_app_bar.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentlyViewedIds = [];

  final List<SearchHawkerCenter> _hawkerCenters = const [
    SearchHawkerCenter(
      id: 'hc_1',
      name: 'Maxwell Food Centre',
      location: 'Chinatown',
      imageUrl: null,
    ),
    SearchHawkerCenter(
      id: 'hc_2',
      name: 'Tekka Centre',
      location: 'Little India',
      imageUrl: null,
    ),
    SearchHawkerCenter(
      id: 'hc_3',
      name: 'Old Airport Road',
      location: 'Kallang',
      imageUrl: null,
    ),
  ];

  final List<SearchMenuItem> _menuItems = const [
    SearchMenuItem(
      id: 'mi_1',
      name: 'Chili Crab Noodles',
      price: 8.5,
      stallName: 'Ocean Wok',
      imageUrl: null,
    ),
    SearchMenuItem(
      id: 'mi_2',
      name: 'Char Kway Teow',
      price: 6.0,
      stallName: 'Wok Master',
      imageUrl: null,
    ),
    SearchMenuItem(
      id: 'mi_3',
      name: 'Hainanese Chicken Rice',
      price: 5.5,
      stallName: 'Golden Rice',
      imageUrl: null,
    ),
  ];

  final List<SearchStreetFood> _streetFoods = const [
    SearchStreetFood(
      id: 'sf_1',
      name: 'Satay Skewers',
      cuisine: 'Malay',
      imageUrl: null,
      upvotes: 482,
      downvotes: 31,
      isOpen: true,
      isVeggie: false,
      isHalal: true,
      hawkerCenter: 'Lau Pa Sat',
      isSponsored: false,
    ),
    SearchStreetFood(
      id: 'sf_2',
      name: 'Laksa Lemak',
      cuisine: 'Peranakan',
      imageUrl: null,
      upvotes: 612,
      downvotes: 44,
      isOpen: false,
      isVeggie: false,
      isHalal: false,
      hawkerCenter: 'Katong',
      isSponsored: true,
    ),
    SearchStreetFood(
      id: 'sf_3',
      name: 'Veggie Dumplings',
      cuisine: 'Chinese',
      imageUrl: null,
      upvotes: 219,
      downvotes: 18,
      isOpen: true,
      isVeggie: true,
      isHalal: false,
      hawkerCenter: 'Chinatown Complex',
      isSponsored: false,
    ),
    SearchStreetFood(
      id: 'sf_4',
      name: 'Roti Prata',
      cuisine: 'Indian',
      imageUrl: null,
      upvotes: 734,
      downvotes: 52,
      isOpen: true,
      isVeggie: true,
      isHalal: true,
      hawkerCenter: 'Tekka Centre',
      isSponsored: false,
    ),
    SearchStreetFood(
      id: 'sf_5',
      name: 'Nasi Lemak',
      cuisine: 'Malay',
      imageUrl: null,
      upvotes: 501,
      downvotes: 23,
      isOpen: false,
      isVeggie: false,
      isHalal: true,
      hawkerCenter: 'Geylang Serai',
      isSponsored: true,
    ),
    SearchStreetFood(
      id: 'sf_6',
      name: 'Tofu Salad Bowl',
      cuisine: 'Fusion',
      imageUrl: null,
      upvotes: 188,
      downvotes: 12,
      isOpen: true,
      isVeggie: true,
      isHalal: false,
      hawkerCenter: 'Tiong Bahru',
      isSponsored: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentlyViewed();
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      appBar: const CustomAppBar(title: 'Search'),
      body: _buildSearchPage(context, colors),
    );
  }

  Widget _buildSearchPage(BuildContext context, AppColorScheme colors) {
    final recentlyViewed = _streetFoods
        .where((food) => _recentlyViewedIds.contains(food.id))
        .toList();
    final veggie = _streetFoods.where((food) => food.isVeggie).toList();
    final halal = _streetFoods.where((food) => food.isHalal).toList();
    final nearby = _streetFoods.take(4).toList();
    final featured = _streetFoods.where((food) => food.isSponsored).toList();
    final topBangers = [..._streetFoods]
      ..sort((a, b) => b.upvoteRatio.compareTo(a.upvoteRatio));

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
            _buildCarousel<SearchStreetFood>(
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
            _buildCarousel<SearchStreetFood>(
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
            _buildCarousel<SearchStreetFood>(
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
            _buildCarousel<SearchStreetFood>(
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
            _buildCarousel<SearchStreetFood>(
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
            _buildCarousel<SearchStreetFood>(
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
            _buildCarousel<SearchHawkerCenter>(
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
            _buildCarousel<SearchMenuItem>(
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
    SearchStreetFood food,
    AppColorScheme colors, {
    bool showSponsoredBadge = false,
    bool showBangerBadge = false,
  }) {
    return _buildBaseCard(
      colors: colors,
      imageChild: Container(
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
            Positioned(
              top: 12,
              left: 12,
              child: Row(
                children: [
                  _buildStatusPill(
                    food.isOpen ? 'Open' : 'Closed',
                    food.isOpen ? colors.statusOpen : colors.statusClosed,
                    colors.textInverse,
                  ),
                  if (showSponsoredBadge || food.isSponsored) ...[
                    const SizedBox(width: 6),
                    _buildStatusPill(
                      'Sponsored',
                      colors.statusSponsored,
                      colors.textInverse,
                    ),
                  ],
                  if (showBangerBadge) ...[
                    const SizedBox(width: 6),
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
      subtitle: '${food.cuisine} • ${food.hawkerCenter}',
      footer: Row(
        children: [
          _buildScoreChip(
            food.upvotes,
            food.downvotes,
            colors.actionUpvote,
            colors.actionDownvote,
          ),
          const SizedBox(width: 10),
          _buildVoteIndicator(
            Icons.thumb_up_outlined,
            food.upvotes,
            colors.actionUpvote,
          ),
          const SizedBox(width: 8),
          _buildVoteIndicator(
            Icons.thumb_down_outlined,
            food.downvotes,
            colors.actionDownvote,
          ),
        ],
      ),
    );
  }

  Widget _buildHawkerCenterCard(
    SearchHawkerCenter center,
    AppColorScheme colors,
  ) {
    return _buildBaseCard(
      colors: colors,
      imageChild: Center(
        child: Icon(
          Icons.location_city,
          color: colors.textSecondary,
          size: 42,
        ),
      ),
      title: center.name,
      subtitle: center.location,
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

  Widget _buildMenuItemCard(SearchMenuItem item, AppColorScheme colors) {
    return _buildBaseCard(
      colors: colors,
      imageChild: Center(
        child: Icon(
          Icons.ramen_dining,
          color: colors.textSecondary,
          size: 36,
        ),
      ),
      title: item.name,
      subtitle: item.stallName,
      footer: Text(
        '\$${item.price.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.brandPrimary,
        ),
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

class SearchStreetFood {
  final String id;
  final String name;
  final String cuisine;
  final String? imageUrl;
  final int upvotes;
  final int downvotes;
  final bool isOpen;
  final bool isVeggie;
  final bool isHalal;
  final String hawkerCenter;
  final bool isSponsored;

  const SearchStreetFood({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.imageUrl,
    required this.upvotes,
    required this.downvotes,
    required this.isOpen,
    required this.isVeggie,
    required this.isHalal,
    required this.hawkerCenter,
    required this.isSponsored,
  });

  double get upvoteRatio {
    final total = upvotes + downvotes;
    if (total == 0) return 0;
    return upvotes / total;
  }
}

class SearchHawkerCenter {
  final String id;
  final String name;
  final String location;
  final String? imageUrl;

  const SearchHawkerCenter({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
  });
}

class SearchMenuItem {
  final String id;
  final String name;
  final double price;
  final String stallName;
  final String? imageUrl;

  const SearchMenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.stallName,
    required this.imageUrl,
  });
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
      clipBehavior: Clip.none,
      child: child,
    );
  }
}
