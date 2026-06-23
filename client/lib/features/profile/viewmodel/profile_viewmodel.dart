import 'package:flutter/material.dart';
import '../../auth/model/user_model.dart';
import '../model/update_profile_request_model.dart';
import '../service/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService profileService;

  bool _isSaving = false;
  String? _errorMessage;

  ProfileViewModel({required this.profileService});

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<User> updateProfile({
    required User user,
    required String username,
    required String email,
    required String bio,
  }) async {
    _setSaving(true);
    _setError(null);
    try {
      final request = UpdateProfileRequestModel(
        username: username,
        email: email,
        bio: bio,
      );
      final updatedUser = await profileService.updateProfile(
        token: user.token,
        request: request,
        role: user.role,
      );
      return updatedUser;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setSaving(false);
    }
  }
}
