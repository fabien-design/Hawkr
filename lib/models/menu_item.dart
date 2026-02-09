class MenuItem {
  final String? id;
  final String name;
  final double price;
  final String? description;
  final String stallId;
  final String? imageUrl;
  final DateTime? createdAt;
  final List<String> tags;

  MenuItem({
    this.id,
    required this.name,
    required this.price,
    this.description,
    required this.stallId,
    this.imageUrl,
    this.createdAt,
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
      id: json['id'] as String?,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      stallId: json['stall_id'] as String,
      imageUrl: (json['image_url'] as String?)?.trim(),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      tags: tags,
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
