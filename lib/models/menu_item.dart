class MenuItem {
  final String? id;
  final String name;
  final double price;
  final String? description;
  final String stallId;
  final String? imageUrl;
  final DateTime? createdAt;
  final List<String> tags;
  final int upvotes;
  final int downvotes;

  MenuItem({
    this.id,
    required this.name,
    required this.price,
    this.description,
    required this.stallId,
    this.imageUrl,
    this.createdAt,
    this.tags = const [],
    this.upvotes = 0,
    this.downvotes = 0,
  });

  double get positivePercentage {
    if (upvotes + downvotes == 0) return 0;
    return (upvotes / (upvotes + downvotes)) * 100;
  }

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

    int ups = 0;
    int downs = 0;
    if (json['menu_item_votes'] != null) {
      final votes = json['menu_item_votes'] as List;
      for (var v in votes) {
        if (v['vote'] == 1) {
          ups++;
        } else if (v['vote'] == -1) {
          downs++;
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
      upvotes: ups,
      downvotes: downs,
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
      'tags': tags,
      'upvotes': upvotes,
      'downvotes': downvotes,
    };
  }
}
