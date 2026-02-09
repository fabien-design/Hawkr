import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hawklap/models/vote_count.dart';

class VoteService {
  final _supabase = Supabase.instance.client;

  /// Get the current user's vote for a menu item (returns 1 for upvote, -1 for downvote, null for no vote)
  Future<int?> getUserMenuItemVote(String menuItemId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('menu_item_votes')
          .select('vote')
          .eq('user_id', userId)
          .eq('menu_item_id', menuItemId)
          .maybeSingle();

      if (response == null) return null;
      return response['vote'] as int?;
    } catch (e) {
      return null;
    }
  }

  /// Submit or update a vote for a menu item (1 for upvote, -1 for downvote)
  Future<void> voteMenuItem(String menuItemId, int vote) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User must be logged in to vote');
    }

    if (vote != 1 && vote != -1) {
      throw Exception('Vote must be 1 (upvote) or -1 (downvote)');
    }

    try {
      // Use upsert with explicit conflict resolution on (user_id, menu_item_id)
      await _supabase.from('menu_item_votes').upsert(
        {
          'user_id': userId,
          'menu_item_id': menuItemId,
          'vote': vote,
        },
        onConflict: 'user_id,menu_item_id',
      );
    } catch (e) {
      print('Error submitting vote: $e');
      rethrow;
    }
  }

  /// Remove a vote for a menu item
  Future<void> removeMenuItemVote(String menuItemId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User must be logged in to remove vote');
    }

    try {
      await _supabase
          .from('menu_item_votes')
          .delete()
          .eq('user_id', userId)
          .eq('menu_item_id', menuItemId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get aggregated vote counts for a menu item from the view
  Future<VoteCount> getMenuItemVotes(String menuItemId) async {
    try {
      final response = await _supabase
          .from('menu_item_vote_stats')
          .select('upvotes, downvotes')
          .eq('menu_item_id', menuItemId)
          .maybeSingle();

      if (response == null) {
        return VoteCount(upvotes: 0, downvotes: 0);
      }

      return VoteCount(
        upvotes: response['upvotes'] as int? ?? 0,
        downvotes: response['downvotes'] as int? ?? 0,
      );
    } catch (e) {
      return VoteCount(upvotes: 0, downvotes: 0);
    }
  }

  /// Get vote counts for multiple menu items at once from the view
  Future<Map<String, VoteCount>> getMenuItemVotesBatch(
    List<String> menuItemIds,
  ) async {
    if (menuItemIds.isEmpty) {
      return {};
    }

    try {
      final response = await _supabase
          .from('menu_item_vote_stats')
          .select('menu_item_id, upvotes, downvotes')
          .inFilter('menu_item_id', menuItemIds);

      final Map<String, VoteCount> voteCounts = {};

      for (final row in response) {
        final itemId = row['menu_item_id'] as String;
        voteCounts[itemId] = VoteCount(
          upvotes: row['upvotes'] as int? ?? 0,
          downvotes: row['downvotes'] as int? ?? 0,
        );
      }

      return voteCounts;
    } catch (e) {
      return {};
    }
  }

  /// Get the current user's vote for a street food stall (returns 1 for upvote, -1 for downvote, null for no vote)
  Future<int?> getUserStreetFoodVote(String streetFoodId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('street_food_votes')
          .select('vote')
          .eq('user_id', userId)
          .eq('street_food_id', streetFoodId)
          .maybeSingle();

      if (response == null) return null;
      return response['vote'] as int?;
    } catch (e) {
      return null;
    }
  }

  /// Submit or update a vote for a street food stall (1 for upvote, -1 for downvote)
  Future<void> voteStreetFood(String streetFoodId, int vote) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User must be logged in to vote');
    }

    if (vote != 1 && vote != -1) {
      throw Exception('Vote must be 1 (upvote) or -1 (downvote)');
    }

    try {
      await _supabase.from('street_food_votes').upsert(
        {
          'user_id': userId,
          'street_food_id': streetFoodId,
          'vote': vote,
        },
        onConflict: 'user_id,street_food_id',
      );
    } catch (e) {
      print('Error submitting street food vote: $e');
      rethrow;
    }
  }

  /// Remove a vote for a street food stall
  Future<void> removeStreetFoodVote(String streetFoodId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User must be logged in to remove vote');
    }

    try {
      await _supabase
          .from('street_food_votes')
          .delete()
          .eq('user_id', userId)
          .eq('street_food_id', streetFoodId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get aggregated vote counts for a street food stall from the view
  Future<VoteCount> getStreetFoodVotes(String streetFoodId) async {
    try {
      final response = await _supabase
          .from('street_food_votes_stats')
          .select('upvotes, downvotes')
          .eq('street_food_id', streetFoodId)
          .maybeSingle();

      if (response == null) {
        return VoteCount(upvotes: 0, downvotes: 0);
      }

      return VoteCount(
        upvotes: response['upvotes'] as int? ?? 0,
        downvotes: response['downvotes'] as int? ?? 0,
      );
    } catch (e) {
      return VoteCount(upvotes: 0, downvotes: 0);
    }
  }

  /// Get vote counts for multiple street foods at once
  /// Returns empty VoteCount objects until street_food_votes_stats view is available
  Future<Map<String, VoteCount>> getStreetFoodVotesBatch(
    List<String> streetFoodIds,
  ) async {
    if (streetFoodIds.isEmpty) {
      return {};
    }

    try {
      // Try to query street_food_votes_stats view
      final response = await _supabase
          .from('street_food_votes_stats')
          .select('street_food_id, upvotes, downvotes')
          .inFilter('street_food_id', streetFoodIds);

      final Map<String, VoteCount> voteCounts = {};

      for (final row in response) {
        final foodId = row['street_food_id'] as String;
        voteCounts[foodId] = VoteCount(
          upvotes: row['upvotes'] as int? ?? 0,
          downvotes: row['downvotes'] as int? ?? 0,
        );
      }

      return voteCounts;
    } catch (e) {
      // If view doesn't exist yet, return empty map
      return {};
    }
  }
}
