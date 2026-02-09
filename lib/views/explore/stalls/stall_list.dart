import 'package:flutter/material.dart';
import '../../../core/services/explore/map_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../register/register_view.dart';
import '../../details/street_food_details.dart';

class StallListView extends StatefulWidget {
  final HawkerCenter hawkerCenter;
  final ScrollController scrollController;

  const StallListView({
    super.key,
    required this.hawkerCenter,
    required this.scrollController,
  });

  @override
  State<StallListView> createState() => _StallListViewState();
}

class _StallListViewState extends State<StallListView> {
  final MapService _mapService = MapService();
  final Map<String, bool> _favorites = {};
  List<StreetFood>? _streetFoods;
  bool _isLoadingFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final foods = await _mapService.getStreetFoodsByHawkerCenter(
        widget.hawkerCenter.id,
      );
      if (mounted) {
        setState(() {
          _streetFoods = foods;
        });
        _loadFavorites();
      }
    } catch (e) {
      // Error handling can be added here if needed
    }
  }

  Future<void> _loadFavorites() async {
    if (_mapService.currentUser == null || _streetFoods == null || _isLoadingFavorites) return;
    
    _isLoadingFavorites = true;
    
    // Load all favorites at once without triggering setState multiple times
    final Map<String, bool> newFavorites = {};
    for (final food in _streetFoods!) {
      if (!_favorites.containsKey(food.id)) {
        try {
          final isFav = await _mapService.isStreetFoodFavorite(food.id);
          newFavorites[food.id] = isFav;
        } catch (e) {
          // Silently handle individual favorite check errors
        }
      }
    }
    
    // Update all favorites in a single setState
    if (mounted && newFavorites.isNotEmpty) {
      setState(() {
        _favorites.addAll(newFavorites);
      });
    }
    
    _isLoadingFavorites = false;
  }

  void _toggleFavorite(String streetFoodId) async {
    if (_mapService.currentUser == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterView()),
      );
      return;
    }

    try {
      await _mapService.toggleStreetFoodFavorite(streetFoodId);
      if (mounted) {
        setState(() {
          _favorites[streetFoodId] = !(_favorites[streetFoodId] ?? false);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    if (_streetFoods == null) {
      return Center(
        child: CircularProgressIndicator(color: colors.borderFocused),
      );
    }

    if (_streetFoods!.isEmpty) {
      return Center(
        child: Text(
          'No street foods found here.',
          style: TextStyle(color: colors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: EdgeInsets.zero,
      itemCount: _streetFoods!.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          // Header with drag handle and title
          return Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.borderDefault,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.hawkerCenter.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          );
        }
        final food = _streetFoods![index - 1];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildStreetFoodCard(food, colors),
        );
      },
    );
  }

  Widget _buildStreetFoodCard(StreetFood food, AppColorScheme colors) {
    final bool isFav = _favorites[food.id] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StreetFoodDetailView(streetFoodId: food.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: colors.backgroundCard,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: colors.backgroundGreyInformation,
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
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.statusOpen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Open',
                      style: TextStyle(
                        color: colors.textInverse,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color:
                              isFav
                                  ? colors.actionFavorite
                                  : colors.textDisabled,
                          size: 28,
                        ),
                        onPressed: () => _toggleFavorite(food.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    food.description ?? 'Local Specialty',
                    style: TextStyle(color: colors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.thumb_up_outlined,
                        color: colors.actionUpvote,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '+3152',
                        style: TextStyle(
                          color: colors.actionUpvote,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
