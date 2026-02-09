class MenuItem {
  final String? id;
  final String name;
  final double price;
  final String? description;
  final String stallId;
  final String? imageUrl;
  final DateTime? createdAt;

  MenuItem({
    this.id,
    required this.name,
    required this.price,
    this.description,
    required this.stallId,
    this.imageUrl,
    this.createdAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String?,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      stallId: json['stall_id'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      if (description != null) 'description': description,
      'stall_id': stallId,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }
}
