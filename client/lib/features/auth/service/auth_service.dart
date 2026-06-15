import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/local_storage_service.dart';
import '../model/user_model.dart';
import '../model/login_request_model.dart';
import '../model/register_request_model.dart';

class AuthService {
  final ApiClient apiClient;
  final LocalStorageService localStorageService;

  AuthService({
    required this.apiClient,
    required this.localStorageService,
  });

  Future<User> login(LoginRequestModel request) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      request.toJson(),
    );
    final user = User.fromAuthJson(response);
    await localStorageService.saveUserJson(user.toJson());
    return user;
  }

  Future<User> register(RegisterRequestModel request) async {
    final response = await apiClient.post(
      ApiEndpoints.register,
      request.toJson(),
    );
    final user = User.fromAuthJson(response);
    await localStorageService.saveUserJson(user.toJson());
    return user;
  }

  Future<User?> getSavedUser() async {
    final userJson = await localStorageService.getSavedUserJson();
    if (userJson == null) return null;
    return User.fromStoredJson(userJson);
  }

  Future<void> logout() async {
    await localStorageService.clearUser();
  }
}
