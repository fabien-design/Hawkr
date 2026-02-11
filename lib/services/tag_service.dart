import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hawklap/models/predefined_tag.dart';

class TagService {
  final _supabase = Supabase.instance.client;

  Future<List<PredefinedTag>> getAll() async {
    final response =
        await _supabase.from('predefined_tags').select().order('name');

    return (response as List)
        .map((json) => PredefinedTag.fromJson(json))
        .toList();
  }

  Future<void> assignTagsToMenuItem(
    String menuItemId,
    List<String> tagIds,
  ) async {
    if (tagIds.isEmpty) return;

    final rows = tagIds.map((tagId) => {
      'menu_item_id': menuItemId,
      'tag_id': tagId,
    }).toList();

    await _supabase.from('menu_items_tags').insert(rows);
  }

  /// Get tag names for multiple menu items at once
  Future<Map<String, List<String>>> getTagsForMenuItemsBatch(
    List<String> menuItemIds,
  ) async {
    if (menuItemIds.isEmpty) return {};

    try {
      final response = await _supabase
          .from('menu_items_tags')
          .select('menu_item_id, predefined_tags(name)')
          .inFilter('menu_item_id', menuItemIds);

      final Map<String, List<String>> tagsMap = {};

      for (final row in response) {
        final itemId = row['menu_item_id'] as String;
        final tagName = row['predefined_tags']?['name'] as String?;
        if (tagName != null) {
          tagsMap.putIfAbsent(itemId, () => []).add(tagName);
        }
      }

      return tagsMap;
    } catch (e) {
      return {};
    }
  }
}
