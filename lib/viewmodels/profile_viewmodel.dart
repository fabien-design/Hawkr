import 'package:flutter/material.dart';
import 'package:hawklap/core/auth/auth_service.dart';
import 'package:hawklap/models/app_user.dart';
import 'package:hawklap/services/user_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final _authService = AuthService();
  final _userService = UserService();

  final displayNameController = TextEditingController();

  AppUser? _user;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  bool _isEditing = false;
  bool _disposed = false;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get isEditing => _isEditing;
  bool get isLoggedIn => _authService.isLoggedIn();

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userService.getCurrentUser();

      if (_user != null) {
        displayNameController.text = _user!.displayName ?? '';
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleEditMode() {
    _isEditing = !_isEditing;

    // Reset controllers if canceling edit
    if (!_isEditing && _user != null) {
      displayNameController.text = _user!.displayName ?? '';
    }

    notifyListeners();
  }

  Future<bool> saveProfile() async {
    if (_user == null) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _userService.updateProfile(
        userId: _user!.id,
        displayName:
            displayNameController.text.trim().isEmpty
                ? null
                : displayNameController.text.trim(),
      );

      debugPrint('Updated user: $updatedUser');

      _user = updatedUser;
      _isEditing = false;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error saving profile: $e');
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  String? validateDisplayName(String? value) {
    if (value != null && value.length > 3 && value.length > 50) {
      return 'Display name must be more than 3 chars and less than 50 chars';
    }
    return null;
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    displayNameController.dispose();
    super.dispose();
  }
}
