import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hawklap/models/hawker_center.dart';
import 'package:hawklap/models/street_food.dart';
import 'package:hawklap/models/menu_item.dart';

class FavoriteService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  // Hawker Centers Favorites
  Future<List<HawkerCenter>> getFavoriteHawkerCenters() async {
    final user = currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('user_favorite_hawker_centers')
        .select('hawker_centers(*)')
        .eq('user_id', user.id);

    return (response as List)
        .where((item) => item['hawker_centers'] != null)
        .map((item) => HawkerCenter.fromJson(item['hawker_centers']))
        .toList();
  }

  Future<void> removeHawkerCenterFavorite(String hawkerCenterId) async {
    final user = currentUser;
    if (user == null) return;

    await _supabase
        .from('user_favorite_hawker_centers')
        .delete()
        .eq('user_id', user.id)
        .eq('hawker_center_id', hawkerCenterId);
  }

  // Street Foods Favorites
  Future<List<StreetFood>> getFavoriteStreetFoods() async {
    final user = currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('user_favorite_street_foods')
        .select('street_foods(*)')
        .eq('user_id', user.id);

    return (response as List)
        .where((item) => item['street_foods'] != null)
        .map((item) => StreetFood.fromJson(item['street_foods']))
        .toList();
  }

  Future<void> removeStreetFoodFavorite(String streetFoodId) async {
    final user = currentUser;
    if (user == null) return;

    await _supabase
        .from('user_favorite_street_foods')
        .delete()
        .eq('user_id', user.id)
        .eq('street_food_id', streetFoodId);
  }

  // Menu Items Favorites
  Future<List<MenuItem>> getFavoriteMenuItems() async {
    final user = currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('user_favorite_menu_items')
        .select('menu_items(*)')
        .eq('user_id', user.id);

    return (response as List)
        .where((item) => item['menu_items'] != null)
        .map((item) => MenuItem.fromJson(item['menu_items']))
        .toList();
  }

  Future<void> removeMenuItemFavorite(String menuItemId) async {
    final user = currentUser;
    if (user == null) return;

    await _supabase
        .from('user_favorite_menu_items')
        .delete()
        .eq('user_id', user.id)
        .eq('menu_item_id', menuItemId);
  }

  Future<bool> isMenuItemFavorite(String menuItemId) async {
    final user = currentUser;
    if (user == null) return false;

    final response = await _supabase
        .from('user_favorite_menu_items')
        .select()
        .eq('user_id', user.id)
        .eq('menu_item_id', menuItemId)
        .maybeSingle();

    return response != null;
  }

  Future<void> toggleMenuItemFavorite(String menuItemId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not logged in');

    final isFavorite = await isMenuItemFavorite(menuItemId);

    if (isFavorite) {
      await _supabase
          .from('user_favorite_menu_items')
          .delete()
          .eq('user_id', user.id)
          .eq('menu_item_id', menuItemId);
    } else {
      await _supabase.from('user_favorite_menu_items').insert({
        'user_id': user.id,
        'menu_item_id': menuItemId,
      });
    }
  }
}
