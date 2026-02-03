class HawkerCenter {
  final String? id;
  final String name;
  final String address;
  final double longitude;
  final double latitude;
  final String? description;
  final DateTime? createdAt;

  HawkerCenter({
    this.id,
    required this.name,
    required this.address,
    required this.longitude,
    required this.latitude,
    this.description,
    this.createdAt,
  });

  factory HawkerCenter.fromJson(Map<String, dynamic> json) {
    return HawkerCenter(
      id: json['id'] as String?,
      name: json['name'] as String,
      address: json['address'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      if (description != null) 'description': description,
    };
  }
}
