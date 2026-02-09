import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

class HawkerCenter {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? description;
  final String? imageUrl;
  final int streetFoodCount;

  HawkerCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.description,
    this.imageUrl,
    this.streetFoodCount = 0,
  });

  factory HawkerCenter.fromJson(Map<String, dynamic> json) {
    int count = 0;
    if (json['street_foods'] != null) {
      if (json['street_foods'] is List && json['street_foods'].isNotEmpty) {
        count = json['street_foods'][0]['count'] ?? 0;
      } else if (json['street_foods'] is Map) {
        count = json['street_foods']['count'] ?? 0;
      }
    }

    return HawkerCenter(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      description: json['description'],
      imageUrl: json['image_url'],
      streetFoodCount: count,
    );
  }
}

class MenuItem {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final String stallId;
  final List<String> tags;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    required this.stallId,
    this.tags = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    List<String> tags = [];
    if (json['menu_items_tags'] != null) {
      final tagsList = json['menu_items_tags'] as List;
      for (var tagMap in tagsList) {
        if (tagMap['predefined_tags'] != null) {
          tags.add(tagMap['predefined_tags']['name']);
        }
      }
    }

    return MenuItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      imageUrl: json['image_url'],
      stallId: json['stall_id'],
      tags: tags,
    );
  }
}

class StreetFood {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String hawkerCenterId;
  final double latitude;
  final double longitude;
  final HawkerCenter? hawkerCenter;
  final List<MenuItem> menuItems;
  final int upvotes;
  final int downvotes;

  StreetFood({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.hawkerCenterId,
    required this.latitude,
    required this.longitude,
    this.hawkerCenter,
    this.menuItems = const [],
    this.upvotes = 0,
    this.downvotes = 0,
  });

  factory StreetFood.fromJson(Map<String, dynamic> json) {
    return StreetFood(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      hawkerCenterId: json['hawker_center_id'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      hawkerCenter:
          json['hawker_centers'] != null
              ? HawkerCenter.fromJson(json['hawker_centers'])
              : null,
      menuItems:
          json['menu_items'] != null
              ? (json['menu_items'] as List)
                  .map((i) => MenuItem.fromJson(i))
                  .toList()
              : [],
    );
  }
}

class MapService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<HawkerCenter>> getNearbyHawkerCenters(
    Position userPosition,
    double radiusInKm,
  ) async {
    final response = await _supabase
        .from('hawker_centers')
        .select('*, street_foods(count)');

    final List<HawkerCenter> allCenters =
        (response as List).map((json) => HawkerCenter.fromJson(json)).toList();

    final Distance distance = const Distance();

    return allCenters.where((center) {
      final double dist = distance.as(
        LengthUnit.Meter,
        LatLng(userPosition.latitude, userPosition.longitude),
        LatLng(center.latitude, center.longitude),
      );
      return dist <= radiusInKm * 1000;
    }).toList();
  }

  Future<List<StreetFood>> getStreetFoodsByHawkerCenter(
    String hawkerCenterId,
  ) async {
    final response = await _supabase
        .from('street_foods')
        .select(
          '*, hawker_centers(*), menu_items(*, menu_items_tags(predefined_tags(name)))',
        )
        .eq('hawker_center_id', hawkerCenterId);

    return (response as List).map((json) => StreetFood.fromJson(json)).toList();
  }

  Future<StreetFood> getStreetFoodDetails(String id) async {
    final response =
        await _supabase
            .from('street_foods')
            .select(
              '*, hawker_centers(*), menu_items(*, menu_items_tags(predefined_tags(name)))',
            )
            .eq('id', id)
            .single();

    return StreetFood.fromJson(response);
  }

  Future<bool> isStreetFoodFavorite(String streetFoodId) async {
    final user = currentUser;
    if (user == null) return false;

    final response =
        await _supabase
            .from('user_favorite_street_foods')
            .select()
            .eq('user_id', user.id)
            .eq('street_food_id', streetFoodId)
            .maybeSingle();

    return response != null;
  }

  Future<void> toggleStreetFoodFavorite(String streetFoodId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not logged in');

    final isFavorite = await isStreetFoodFavorite(streetFoodId);

    if (isFavorite) {
      await _supabase
          .from('user_favorite_street_foods')
          .delete()
          .eq('user_id', user.id)
          .eq('street_food_id', streetFoodId);
    } else {
      await _supabase.from('user_favorite_street_foods').insert({
        'user_id': user.id,
        'street_food_id': streetFoodId,
      });
    }
  }

  Future<List<String>> getUserFavoriteStreetFoodIds() async {
    final user = currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('user_favorite_street_foods')
        .select('street_food_id')
        .eq('user_id', user.id);

    return (response as List)
        .map((item) => item['street_food_id'] as String)
        .toList();
  }
}
