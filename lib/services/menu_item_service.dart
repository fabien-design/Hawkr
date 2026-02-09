import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hawklap/models/menu_item.dart';

class MenuItemService {
  final _supabase = Supabase.instance.client;
  static const _table = 'menu_items';

  Future<List<MenuItem>> getAll() async {
    final response = await _supabase.from(_table).select().order('name');

    return (response as List).map((json) => MenuItem.fromJson(json)).toList();
  }

  Future<List<MenuItem>> getByStall(String stallId) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('stall_id', stallId)
        .order('name');

    return (response as List).map((json) => MenuItem.fromJson(json)).toList();
  }

  Future<MenuItem?> getById(String id) async {
    final response =
        await _supabase.from(_table).select().eq('id', id).maybeSingle();

    if (response == null) return null;
    return MenuItem.fromJson(response);
  }

  Future<MenuItem> create(MenuItem menuItem) async {
    final response =
        await _supabase
            .from(_table)
            .insert(menuItem.toJson())
            .select()
            .single();

    return MenuItem.fromJson(response);
  }

  Future<MenuItem> update(String id, MenuItem menuItem) async {
    final response =
        await _supabase
            .from(_table)
            .update(menuItem.toJson())
            .eq('id', id)
            .select()
            .single();

    return MenuItem.fromJson(response);
  }

  Future<void> delete(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }
}
