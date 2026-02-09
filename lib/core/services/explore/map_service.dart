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
  final int streetFoodCount;

  HawkerCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.description,
    this.streetFoodCount = 0,
  });

  factory HawkerCenter.fromJson(Map<String, dynamic> json) {
    // Supabase returns count as a list of maps usually when using street_foods(count)
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
      streetFoodCount: count,
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
  final int votes;

  StreetFood({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.hawkerCenterId,
    required this.latitude,
    required this.longitude,
    this.votes = 0,
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
      votes: 0,
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
    // We use a join to get the count of street_foods for each hawker_center
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
        .select()
        .eq('hawker_center_id', hawkerCenterId);

    return (response as List).map((json) => StreetFood.fromJson(json)).toList();
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
