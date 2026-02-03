class StreetFood {
  final String? id;
  final String name;
  final double longitude;
  final double latitude;
  final String? description;
  final String hawkerCenterId;
  final DateTime? createdAt;

  StreetFood({
    this.id,
    required this.name,
    required this.longitude,
    required this.latitude,
    this.description,
    required this.hawkerCenterId,
    this.createdAt,
  });

  factory StreetFood.fromJson(Map<String, dynamic> json) {
    return StreetFood(
      id: json['id'] as String?,
      name: json['name'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      description: json['description'] as String?,
      hawkerCenterId: json['hawker_center_id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'longitude': longitude,
      'latitude': latitude,
      if (description != null) 'description': description,
      'hawker_center_id': hawkerCenterId,
    };
  }
}
