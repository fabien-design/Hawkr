class AddressSuggestion {
  final String displayName;
  final String? street;
  final String? city;
  final String? country;
  final double latitude;
  final double longitude;

  AddressSuggestion({
    required this.displayName,
    this.street,
    this.city,
    this.country,
    required this.latitude,
    required this.longitude,
  });

  factory AddressSuggestion.fromPhotonJson(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>;
    final geometry = json['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List;

    // Build display name from available properties
    final parts = <String>[];
    if (properties['name'] != null) parts.add(properties['name']);
    if (properties['street'] != null) parts.add(properties['street']);
    if (properties['city'] != null) parts.add(properties['city']);
    if (properties['country'] != null) parts.add(properties['country']);

    return AddressSuggestion(
      displayName: parts.isNotEmpty ? parts.join(', ') : 'Unknown location',
      street: properties['street'],
      city: properties['city'],
      country: properties['country'],
      longitude: (coordinates[0] as num).toDouble(),
      latitude: (coordinates[1] as num).toDouble(),
    );
  }
}
