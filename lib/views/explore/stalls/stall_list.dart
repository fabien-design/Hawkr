import 'package:flutter/material.dart';
import '../../../core/services/explore/map_service.dart';
import '../../register/register_view.dart';

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

  Future<void> _checkFavoriteStatus(String streetFoodId) async {
    if (_mapService.currentUser != null &&
        !_favorites.containsKey(streetFoodId)) {
      final isFav = await _mapService.isStreetFoodFavorite(streetFoodId);
      if (mounted) {
        setState(() {
          _favorites[streetFoodId] = isFav;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            widget.hawkerCenter.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<StreetFood>>(
            future: _mapService.getStreetFoodsByHawkerCenter(
              widget.hawkerCenter.id,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final streetFoods = snapshot.data ?? [];
              if (streetFoods.isEmpty) {
                return const Center(child: Text('No street foods found here.'));
              }
              return ListView.builder(
                controller: widget.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: streetFoods.length,
                itemBuilder: (context, index) {
                  final food = streetFoods[index];
                  _checkFavoriteStatus(food.id);
                  return _buildStreetFoodCard(food);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStreetFoodCard(StreetFood food) {
    final bool isFav = _favorites[food.id] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.white),
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
                    color: const Color(0xFF42C18C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Open',
                    style: TextStyle(
                      color: Colors.white,
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.grey,
                        size: 28,
                      ),
                      onPressed: () => _toggleFavorite(food.id),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  food.description ?? 'Local Specialty',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(
                      Icons.thumb_up_outlined,
                      color: Color(0xFF42C18C),
                      size: 18,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '+3152',
                      style: TextStyle(
                        color: Color(0xFF42C18C),
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
    );
  }
}
