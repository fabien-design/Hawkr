class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.createdAt,
  });

  factory AppUser.fromSupabase({
    required String id,
    required String email,
    Map<String, dynamic>? profile,
  }) {
    return AppUser(
      id: id,
      email: email,
      displayName: profile?['display_name'] as String?,
      createdAt: profile?['created_at'] != null
          ? DateTime.parse(profile!['created_at'] as String)
          : null,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: (json['email'] as String?) ?? '',
      displayName: json['display_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (displayName != null) 'display_name': displayName,
    };
  }

  String get nameOrEmail => displayName ?? email;

  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
