import 'package:frontend_posyandu/core/models/auth/user_model.dart';
import 'package:frontend_posyandu/core/services/auth/login_service.dart';
import 'package:frontend_posyandu/core/services/auth/token_service.dart';

class AuthService {
  final LoginService _loginService;
  final TokenService _tokenService;

  AuthService({
    LoginService? loginService,
    TokenService? tokenService,
  }) : _loginService = loginService ?? LoginService(),
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

    return response;
  }

  Future<void> logout() async {
    await _tokenService.clearTokens();
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
}
