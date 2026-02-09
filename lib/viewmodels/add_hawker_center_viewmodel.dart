import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hawklap/models/address_suggestion.dart';
import 'package:hawklap/models/hawker_center.dart';
import 'package:hawklap/services/address_suggestion_service.dart';
import 'package:hawklap/services/hawker_center_service.dart';
import 'package:hawklap/services/storage_service.dart';

class AddHawkerCenterViewModel extends ChangeNotifier {
  final _service = HawkerCenterService();
  final _addressSuggestionService = AddressSuggestionService();
  final _storageService = StorageService();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  // Coordonnées par défaut (0.0) - sera remplacé par sélection map Leaflet
  double _latitude = 0.0;
  double _longitude = 0.0;

  bool _isLoading = false;
  String? _errorMessage;
  File? _imageFile;

  // Address suggestions state
  List<AddressSuggestion> _suggestions = [];
  bool _isLoadingSuggestions = false;
  Timer? _debounceTimer;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get latitude => _latitude;
  double get longitude => _longitude;
  List<AddressSuggestion> get suggestions => _suggestions;
  bool get isLoadingSuggestions => _isLoadingSuggestions;
  File? get imageFile => _imageFile;

  // TODO: Sera appelé par la map Leaflet
  void setLocation(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
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

  void searchAddress(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    _isLoadingSuggestions = true;
    notifyListeners();

    try {
      _suggestions = await _addressSuggestionService.search(query, limit: 5);
    } catch (e) {
      _suggestions = [];
    }

    _isLoadingSuggestions = false;
    notifyListeners();
  }

  void selectSuggestion(AddressSuggestion suggestion) {
    addressController.text = suggestion.displayName;
    _latitude = suggestion.latitude;
    _longitude = suggestion.longitude;
    _suggestions = [];
    notifyListeners();
  }

  void clearSuggestions() {
    _suggestions = [];
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
      String? imageUrl;

      if (_imageFile != null) {
        final ext = _imageFile!.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
        imageUrl = await _storageService.uploadStallImage(
          fileName,
          _imageFile!,
        );
      }

      final hawkerCenter = HawkerCenter(
        name: nameController.text,
        address: addressController.text,
        latitude: _latitude,
        longitude: _longitude,
        description: descriptionController.text.isEmpty
            ? null
            : descriptionController.text,
        imageUrl: imageUrl,
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
    _debounceTimer?.cancel();
    nameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
