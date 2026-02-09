import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _menuItemStorage = Supabase.instance.client.storage.from('menu-items');
  final _stallStorage = Supabase.instance.client.storage.from('street-food');
  final _hawkerCenterStorage = Supabase.instance.client.storage.from(
    'hawker-centers',
  );

  Future<String> uploadMenuItemImage(String fileName, File file) async {
    await _menuItemStorage.upload(fileName, file);
    return _menuItemStorage.getPublicUrl(fileName);
  }

  Future<void> deleteMenuItemImage(String path) async {
    await _menuItemStorage.remove([path]);
  }

  Future<String> uploadStallImage(String fileName, File file) async {
    await _stallStorage.upload(fileName, file);
    return _stallStorage.getPublicUrl(fileName);
  }

  Future<void> deleteStallImage(String path) async {
    await _stallStorage.remove([path]);
  }

  Future<String> uploadHawkerCenterImage(String fileName, File file) async {
    await _hawkerCenterStorage.upload(fileName, file);
    return _hawkerCenterStorage.getPublicUrl(fileName);
  }

  Future<void> deleteHawkerCenterImage(String path) async {
    await _hawkerCenterStorage.remove([path]);
  }
}
