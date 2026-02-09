import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hawklap/models/vote_count.dart';

class VoteService {
  final _supabase = Supabase.instance.client;

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

  /// Placeholder for street food votes (to be implemented when backend is ready)
  /// For now returns dummy data
  Future<VoteCount> getStreetFoodVotes(String streetFoodId) async {
    // TODO: Implement when street_food_votes table is created
    // For now, return dummy data
    return VoteCount(upvotes: 0, downvotes: 0);
  }

  /// Get vote counts for multiple street foods at once
  /// Returns empty VoteCount objects until street_food_vote_stats view is available
  Future<Map<String, VoteCount>> getStreetFoodVotesBatch(
    List<String> streetFoodIds,
  ) async {
    if (streetFoodIds.isEmpty) {
      return {};
    }

    try {
      // Try to query street_food_vote_stats view
      final response = await _supabase
          .from('street_food_vote_stats')
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
