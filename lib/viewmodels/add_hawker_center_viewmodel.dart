import 'package:flutter/material.dart';
import 'package:hawklap/models/hawker_center.dart';
import 'package:hawklap/services/hawker_center_service.dart';

class AddHawkerCenterViewModel extends ChangeNotifier {
  final _service = HawkerCenterService();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  // Coordonnées par défaut (0.0) - sera remplacé par sélection map Leaflet
  double _latitude = 0.0;
  double _longitude = 0.0;

  bool _isLoading = false;
  String? _errorMessage;

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

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the name';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the address';
    }
    return null;
  }

  Future<bool> submit() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hawkerCenter = HawkerCenter(
        name: nameController.text,
        address: addressController.text,
        latitude: _latitude,
        longitude: _longitude,
        description: descriptionController.text.isEmpty
            ? null
            : descriptionController.text,
      );

      await _service.create(hawkerCenter);

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
    addressController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
