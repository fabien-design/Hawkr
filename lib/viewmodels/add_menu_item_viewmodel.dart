import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hawklap/models/menu_item.dart';
import 'package:hawklap/models/street_food.dart';
import 'package:hawklap/services/menu_item_service.dart';
import 'package:hawklap/services/storage_service.dart';
import 'package:hawklap/services/street_food_service.dart';

class AddMenuItemViewModel extends ChangeNotifier {
  final _streetFoodService = StreetFoodService();
  final _menuItemService = MenuItemService();
  final _storageService = StorageService();

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  String? _selectedStallId;
  List<StreetFood> _stalls = [];
  bool _isLoading = false;
  String? _errorMessage;
  File? _imageFile;

  String? get selectedStallId => _selectedStallId;
  List<StreetFood> get stalls => _stalls;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get imageFile => _imageFile;

  void setSelectedStall(String? id) {
    _selectedStallId = id;
    notifyListeners();
  }

  Future<void> loadStalls() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stalls = await _streetFoodService.getAll();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setImage(File file) {
    _imageFile = file;
    notifyListeners();
  }

  void removeImage() {
    _imageFile = null;
    notifyListeners();
  }

  String? validateStall(String? value) {
    if (value == null) {
      return 'Please select a stall';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the dish name';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the price';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid price';
    }
    return null;
  }

  Future<bool> submit() async {
    if (_selectedStallId == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? imageUrl;

      if (_imageFile != null) {
        final ext = _imageFile!.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
        imageUrl = await _storageService.uploadMenuItemImage(
          fileName,
          _imageFile!,
        );
      }

      final menuItem = MenuItem(
        name: nameController.text,
        price: double.parse(priceController.text),
        description: descriptionController.text.isEmpty
            ? null
            : descriptionController.text,
        stallId: _selectedStallId!,
        imageUrl: imageUrl,
      );

      await _menuItemService.create(menuItem);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
