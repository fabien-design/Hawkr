import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hawklap/models/hawker_center.dart';
import 'package:hawklap/models/street_food.dart';
import 'package:hawklap/services/hawker_center_service.dart';
import 'package:hawklap/services/street_food_service.dart';

class AddStreetFoodViewModel extends ChangeNotifier {
  final _hawkerCenterService = HawkerCenterService();
  final _streetFoodService = StreetFoodService();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  // Stall location (selected via map)
  double _latitude = 0.0;
  double _longitude = 0.0;

  // User's current location
  Position? _userPosition;
  bool _isLoadingUserLocation = false;

  // Selected hawker center
  String? _selectedHawkerCenterId;
  HawkerCenter? _selectedHawkerCenter;
  List<HawkerCenter> _hawkerCenters = [];

  bool _isLoading = false;
  String? _errorMessage;

  String? get selectedHawkerCenterId => _selectedHawkerCenterId;
  HawkerCenter? get selectedHawkerCenter => _selectedHawkerCenter;
  List<HawkerCenter> get hawkerCenters => _hawkerCenters;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get latitude => _latitude;
  double get longitude => _longitude;
  Position? get userPosition => _userPosition;
  bool get isLoadingUserLocation => _isLoadingUserLocation;

  /// Update stall location when map is moved
  void setLocation(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  void setSelectedHawkerCenter(String? id) {
    _selectedHawkerCenterId = id;

    // Find the selected hawker center and set initial coordinates
    if (id != null) {
      _selectedHawkerCenter = _hawkerCenters.firstWhere(
        (center) => center.id == id,
        orElse: () => _hawkerCenters.first,
      );
      // Initialize stall location to hawker center location
      _latitude = _selectedHawkerCenter!.latitude;
      _longitude = _selectedHawkerCenter!.longitude;
    } else {
      _selectedHawkerCenter = null;
    }
    notifyListeners();
  }

  Future<void> loadHawkerCenters() async {
    _isLoading = true;
    notifyListeners();

    try {
      _hawkerCenters = await _hawkerCenterService.getAll();
      // Also load user location
      _loadUserLocation();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserLocation() async {
    _isLoadingUserLocation = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLoadingUserLocation = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLoadingUserLocation = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLoadingUserLocation = false;
        notifyListeners();
        return;
      }

      _userPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      // Silently fail - user location is optional
    }

    _isLoadingUserLocation = false;
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
