import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../auth/model/user_model.dart';
import '../model/update_profile_request_model.dart';

class ProfileService {
  final ApiClient apiClient;
  final LocalStorageService localStorageService;

  ProfileService({
    required this.apiClient,
    required this.localStorageService,
  });

  Future<User> updateProfile({
    required String token,
    required UpdateProfileRequestModel request,
  }) async {
    final response = await apiClient.put(
      ApiEndpoints.profile,
      request.toJson(),
      token: token,
    );

    final updatedUser = User.fromStoredJson({
      ...response['user'] as Map<String, dynamic>,
      'token': token,
    });

    await localStorageService.saveUserJson(updatedUser.toJson());
    return updatedUser;
  }
}
