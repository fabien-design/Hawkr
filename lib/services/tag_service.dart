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
}
