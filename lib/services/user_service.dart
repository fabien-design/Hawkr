import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hawklap/models/app_user.dart';

class UserService {
  final _supabase = Supabase.instance.client;
  static const _table = 'profiles';

  Future<AppUser?> getCurrentUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    try {
      final profile = await _supabase
          .from(_table)
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      return AppUser.fromSupabase(
        id: authUser.id,
        email: authUser.email ?? '',
        profile: profile,
      );
    } catch (e) {
      // Profile might not exist yet, return basic user
      return AppUser(
        id: authUser.id,
        email: authUser.email ?? '',
      );
    }
  }

  Future<AppUser?> getById(String id) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();

    return response != null ? AppUser.fromJson(response) : null;
  }

  Future<AppUser> updateProfile({
    required String userId,
    String? displayName,
  }) async {
    final data = <String, dynamic>{
      'id': userId,
    };

    if (displayName != null) {
      data['display_name'] = displayName.isEmpty ? null : displayName;
    }

    final authUser = _supabase.auth.currentUser;

    final response = await _supabase
        .from(_table)
        .update(data)
        .eq('id', userId)
        .select()
        .single();
    return AppUser.fromSupabase(
      id: userId,
      email: authUser?.email ?? '',
      profile: response,
    );
  }

  Future<void> createProfile(String userId, String email) async {
    await _supabase.from(_table).upsert({
      'id': userId,
      'email': email,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteProfile(String userId) async {
    await _supabase.from(_table).delete().eq('id', userId);
  }
}
