import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hawklap/models/street_food.dart';

class StreetFoodService {
  final _supabase = Supabase.instance.client;
  static const _table = 'street_foods';

  Future<List<StreetFood>> getAll() async {
    final response = await _supabase.from(_table).select().order('name');

    return (response as List).map((json) => StreetFood.fromJson(json)).toList();
  }

  Future<List<StreetFood>> getByHawkerCenter(String hawkerCenterId) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('hawker_center_id', hawkerCenterId)
        .order('name');

    return (response as List).map((json) => StreetFood.fromJson(json)).toList();
  }

  Future<StreetFood?> getById(String id) async {
    final response =
        await _supabase.from(_table).select().eq('id', id).maybeSingle();

    if (response == null) return null;
    return StreetFood.fromJson(response);
  }

  Future<StreetFood> create(StreetFood streetFood) async {
    final response =
        await _supabase
            .from(_table)
            .insert(streetFood.toJson())
            .select()
            .single();

    return StreetFood.fromJson(response);
  }

  Future<StreetFood> update(String id, StreetFood streetFood) async {
    final response =
        await _supabase
            .from(_table)
            .update(streetFood.toJson())
            .eq('id', id)
            .select()
            .single();

    return StreetFood.fromJson(response);
  }

  Future<void> delete(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }
}
