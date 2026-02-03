import 'package:flutter/material.dart';
import 'package:hawklap/models/hawker_center.dart';
import 'package:hawklap/models/street_food.dart';
import 'package:hawklap/services/hawker_center_service.dart';
import 'package:hawklap/services/street_food_service.dart';

class AddStreetFoodViewModel extends ChangeNotifier {
  final _hawkerCenterService = HawkerCenterService();
  final _streetFoodService = StreetFoodService();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  // Coordonnées par défaut (0.0) - sera remplacé par sélection map Leaflet
  double _latitude = 0.0;
  double _longitude = 0.0;

  String? _selectedHawkerCenterId;
  List<HawkerCenter> _hawkerCenters = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? get selectedHawkerCenterId => _selectedHawkerCenterId;
  List<HawkerCenter> get hawkerCenters => _hawkerCenters;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get latitude => _latitude;
  double get longitude => _longitude;

  // TODO: Sera appelé par la map Leaflet
  void setLocation(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  void setSelectedHawkerCenter(String? id) {
    _selectedHawkerCenterId = id;
    notifyListeners();
  }

  Future<void> loadHawkerCenters() async {
    _isLoading = true;
    notifyListeners();

    try {
      _hawkerCenters = await _hawkerCenterService.getAll();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  String? validateHawkerCenter(String? value) {
    if (value == null) {
      return 'Please select a hawker center';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the stall name';
    }
    return null;
  }

  Future<bool> submit() async {
    if (_selectedHawkerCenterId == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final streetFood = StreetFood(
        name: nameController.text,
        longitude: _longitude,
        latitude: _latitude,
        description: descriptionController.text.isEmpty
            ? null
            : descriptionController.text,
        hawkerCenterId: _selectedHawkerCenterId!,
      );

      await _streetFoodService.create(streetFood);

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
    descriptionController.dispose();
    super.dispose();
  }
}
