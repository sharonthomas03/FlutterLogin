import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage_service.dart';
import '../features/auth/service/auth_service.dart';
import '../features/auth/viewmodel/auth_view_model.dart';
import '../features/profile/service/profile_service.dart';
import '../features/profile/viewmodel/profile_viewmodel.dart';

class AppProvider {
  static List<SingleChildWidget> get providers {
    return [
      // Core services
      Provider<ApiClient>(
        create: (_) => ApiClient(),
      ),
      Provider<LocalStorageService>(
        create: (_) => LocalStorageService(),
      ),

      // Feature services dependency on core services
      ProxyProvider2<ApiClient, LocalStorageService, AuthService>(
        update: (_, apiClient, localStorage, _) => AuthService(
          apiClient: apiClient,
          localStorageService: localStorage,
        ),
      ),
      ProxyProvider2<ApiClient, LocalStorageService, ProfileService>(
        update: (_, apiClient, localStorage, _) => ProfileService(
          apiClient: apiClient,
          localStorageService: localStorage,
        ),
      ),

      // ViewModels dependency on services
      ChangeNotifierProxyProvider<AuthService, AuthViewModel>(
        create: (context) => AuthViewModel(
          authService: context.read<AuthService>(),
        ),
        update: (_, authService, previous) => previous ?? AuthViewModel(
          authService: authService,
        ),
      ),
      ChangeNotifierProxyProvider<ProfileService, ProfileViewModel>(
        create: (context) => ProfileViewModel(
          profileService: context.read<ProfileService>(),
        ),
        update: (_, profileService, previous) => previous ?? ProfileViewModel(
          profileService: profileService,
        ),
      ),
    ];
  }
}
