import 'package:flutter/material.dart';
import 'package:hawklap/components/app_bar/custom_app_bar.dart';
import 'package:hawklap/core/theme/app_colors.dart';
import 'package:hawklap/services/favorite_service.dart';
import 'package:hawklap/models/hawker_center.dart';
import 'package:hawklap/models/street_food.dart';
import 'package:hawklap/models/menu_item.dart';
import 'package:hawklap/views/details/hawker_center_details.dart';
import 'package:hawklap/views/details/menu_item_details.dart';
import 'package:hawklap/views/login/login_view.dart';
import 'package:hawklap/views/details/street_food_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavouritesView extends StatefulWidget {
  const FavouritesView({super.key});

  @override
  State<FavouritesView> createState() => _FavouritesViewState();
}

class _FavouritesViewState extends State<FavouritesView> {
  final FavoriteService _favoriteService = FavoriteService();
  bool _isLoading = true;
  List<HawkerCenter> _hawkerCenters = [];
  List<StreetFood> _streetFoods = [];
  List<MenuItem> _menuItems = [];
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (_supabase.auth.currentUser == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final results = await Future.wait([
        _favoriteService.getFavoriteHawkerCenters(),
        _favoriteService.getFavoriteStreetFoods(),
        _favoriteService.getFavoriteMenuItems(),
      ]);

      if (mounted) {
        setState(() {
          _hawkerCenters = results[0] as List<HawkerCenter>;
          _streetFoods = results[1] as List<StreetFood>;
          _menuItems = results[2] as List<MenuItem>;
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
        ).showSnackBar(SnackBar(content: Text('Error loading favorites: $e')));
      }
    }
  }

  Future<void> _removeHawkerCenter(String id) async {
    try {
      await _favoriteService.removeHawkerCenterFavorite(id);
      _loadFavorites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _removeStreetFood(String id) async {
    try {
      await _favoriteService.removeStreetFoodFavorite(id);
      _loadFavorites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _removeMenuItem(String id) async {
    try {
      await _favoriteService.removeMenuItemFavorite(id);
      _loadFavorites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: colors.backgroundApp,
        appBar: const CustomAppBar(title: 'Favourites'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please log in to see your favorites',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: colors.textPrimary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginView(),
                      ),
                    );
                    if (result == true) {
                      _loadFavorites();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.backgroundApp,
      appBar: const CustomAppBar(title: 'Favourites'),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadFavorites,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionHeader('Hawker Centers', colors),
                    if (_hawkerCenters.isEmpty)
                      _buildEmptyMessage(
                        'No favorite hawker centers yet.',
                        colors,
                      )
                    else
                      ..._hawkerCenters.map(
                        (hc) => _buildHawkerCard(hc, colors),
                      ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Stalls', colors),
                    if (_streetFoods.isEmpty)
                      _buildEmptyMessage('No favorite stalls yet.', colors)
                    else
                      ..._streetFoods.map((sf) => _buildStallCard(sf, colors)),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Menu Items', colors),
                    if (_menuItems.isEmpty)
                      _buildEmptyMessage('No favorite menu items yet.', colors)
                    else
                      ..._menuItems.map((mi) => _buildMenuCard(mi, colors)),
                  ],
                ),
              ),
    );
  }

  Widget _buildSectionHeader(String title, AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildEmptyMessage(String message, AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        message,
        style: TextStyle(
          color: colors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildHawkerCard(HawkerCenter hc, AppColorScheme colors) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colors.backgroundCard,
      child: ListTile(
        onTap: () async {
          if (hc.id != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => HawkerCenterDetailView(hawkerCenterId: hc.id!),
              ),
            );
            _loadFavorites();
          }
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              hc.imageUrl != null
                  ? Image.network(
                    hc.imageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => _placeholderIcon(),
                  )
                  : _placeholderIcon(),
        ),
        title: Text(
          hc.name,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          hc.address,
          style: TextStyle(color: colors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => _removeHawkerCenter(hc.id!),
        ),
      ),
    );
  }

  Widget _buildStallCard(StreetFood sf, AppColorScheme colors) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colors.backgroundCard,
      child: ListTile(
        onTap: () async {
          if (sf.id != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => StreetFoodDetailView(streetFoodId: sf.id!),
              ),
            );
            _loadFavorites();
          }
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              sf.imageUrl != null
                  ? Image.network(
                    sf.imageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => _placeholderIcon(),
                  )
                  : _placeholderIcon(),
        ),
        title: Text(
          sf.name,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          sf.description ?? 'Local stall',
          style: TextStyle(color: colors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => _removeStreetFood(sf.id!),
        ),
      ),
    );
  }

  Widget _buildMenuCard(MenuItem mi, AppColorScheme colors) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colors.backgroundCard,
      child: ListTile(
        onTap: () async {
          if (mi.id != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MenuItemDetailsView(stallId: mi.stallId, item: mi),
              ),
            );
            _loadFavorites();
          }
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              mi.imageUrl != null
                  ? Image.network(
                    mi.imageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => _placeholderIcon(),
                  )
                  : _placeholderIcon(),
        ),
        title: Text(
          mi.name,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '\$${mi.price.toStringAsFixed(2)}',
          style: const TextStyle(
            color: AppColors.brandPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => _removeMenuItem(mi.id!),
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[300],
      child: const Icon(Icons.restaurant, color: Colors.white),
    );
  }
}
