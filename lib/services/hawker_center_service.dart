import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hawklap/models/hawker_center.dart';

class HawkerCenterService {
  final _supabase = Supabase.instance.client;
  static const _table = 'hawker_centers';

  Future<List<HawkerCenter>> getAll() async {
    final response = await _supabase
        .from(_table)
        .select()
        .order('name');

    return (response as List)
        .map((json) => HawkerCenter.fromJson(json))
        .toList();
  }

  Future<HawkerCenter?> getById(String id) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();

    return response != null ? HawkerCenter.fromJson(response) : null;
  }

  Future<HawkerCenter> create(HawkerCenter hawkerCenter) async {
    final response = await _supabase
        .from(_table)
        .insert(hawkerCenter.toJson())
        .select()
        .single();

    return HawkerCenter.fromJson(response);
  }

  Future<HawkerCenter> update(String id, HawkerCenter hawkerCenter) async {
    final response = await _supabase
        .from(_table)
        .update(hawkerCenter.toJson())
        .eq('id', id)
        .select()
        .single();

    return HawkerCenter.fromJson(response);
  }

  Future<void> delete(String id) async {
    await _supabase
        .from(_table)
        .delete()
        .eq('id', id);
  }
}
