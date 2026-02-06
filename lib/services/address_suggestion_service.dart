import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:hawklap/models/address_suggestion.dart';

class AddressSuggestionService {
  static const _baseUrl = 'https://photon.komoot.io/api';

  /// Search for address suggestions using Photon API (OpenStreetMap based)
  Future<List<AddressSuggestion>> search(
    String query, {
    int limit = 5,
    String lang = 'en',
    double? lat,
    double? lon,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final queryParams = {
      'q': query,
      'limit': limit.toString(),
      'lang': lang,
    };

    final biasLat = lat ?? 1.3521;
    final biasLon = lon ?? 103.8198;
    queryParams['lat'] = biasLat.toString();
    queryParams['lon'] = biasLon.toString();

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    try {
      final response = await http.get(
          uri,
        headers: {
          'User-Agent': 'Hawkr/1.0 (fabienrozier60@gmail.com)',
          'Accept': 'application/json',
        }
      );

      debugPrint('${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final features = data['features'] as List? ?? [];

        debugPrint('Address suggestions: $features');

        return features
            .map((feature) => AddressSuggestion.fromPhotonJson(feature))
            .toList();
      } else {
        throw Exception('Failed to fetch suggestions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching address suggestions: $e');
    }
  }
}
