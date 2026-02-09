class PredefinedTag {
  final String id;
  final String name;

  PredefinedTag({required this.id, required this.name});

  factory PredefinedTag.fromJson(Map<String, dynamic> json) {
    return PredefinedTag(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
