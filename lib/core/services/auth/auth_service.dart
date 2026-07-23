import 'package:frontend_posyandu/core/models/auth/user_model.dart';
import 'package:frontend_posyandu/core/services/auth/login_service.dart';
import 'package:frontend_posyandu/core/services/auth/logout_service.dart';
import 'package:frontend_posyandu/core/services/auth/token_service.dart';

class AuthService {
  final LoginService _loginService;
  final LogoutService _logoutService;
  final TokenService _tokenService;

  AuthService({
    LoginService? loginService,
    LogoutService? logoutService,
    TokenService? tokenService,
  }) : _loginService = loginService ?? LoginService(),
       _logoutService = logoutService ?? LogoutService(),
       _tokenService = tokenService ?? TokenService();

  Future<LoginResponse> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _loginService.login(
      identifier: identifier,
      password: password,
    );

    await _tokenService.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      roles: response.roles,
    );

    if (response.user != null) {
      final category = UserCategory.fromString(response.user!.kategoriAnggota);
      if (category != null) {
        await _tokenService.saveCategory(category);
      }
      await _tokenService.saveModuleId(response.user!.moduleId);
      await _tokenService.saveUserInfo(response.user!.toJson());
    }

    return response;
  }

  Future<void> logout() async {
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken != null) {
      await _logoutService.logout(refreshToken);
    }
    await _tokenService.clearTokens();
    await _tokenService.clearCategory();
    await _tokenService.clearModuleId();
    await _tokenService.clearUserInfo();
  }

  Future<bool> isLoggedIn() async {
    return await _tokenService.isLoggedIn();
  }

  Future<List<String>> getRoles() async {
    return await _tokenService.getRoles();
  }

  Future<String?> getAccessToken() async {
    return await _tokenService.getAccessToken();
  }

  Future<void> saveCategory(UserCategory category) async {
    await _tokenService.saveCategory(category);
  }

  Future<UserCategory?> getCategory() async {
    return await _tokenService.getCategory();
  }

  Future<String?> getModuleId() async {
    return await _tokenService.getModuleId();
  }

  Future<void> saveUserInfo(UserInfo userInfo) async {
    await _tokenService.saveUserInfo(userInfo.toJson());
  }

  Future<UserInfo?> getUserInfo() async {
    final map = await _tokenService.getUserInfo();
    if (map == null) return null;
    return UserInfo.fromJson(map);
  }
}
