import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/models/auth/user_model.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/services/auth/login_service.dart';
import 'package:frontend_posyandu/core/services/auth/logout_service.dart';
import 'package:frontend_posyandu/core/services/auth/token_service.dart';

LoginResponse _makeLoginResponse({Map<String, dynamic>? user}) {
  return LoginResponse(
    accessToken: 'at-1',
    expiresIn: 3600,
    refreshToken: 'rt-1',
    roles: ['user'],
    state: 'active',
    tokenType: 'Bearer',
    message: '',
    user: user != null ? UserInfo.fromJson(user) : null,
  );
}

class _MockLoginService extends LoginService {
  final LoginResponse Function()? onLogin;
  _MockLoginService({this.onLogin}) : super();

  @override
  Future<LoginResponse> login({required String identifier, required String password}) async {
    if (onLogin != null) return onLogin!();
    throw Exception('not mocked');
  }
}

class _MockLogoutService extends LogoutService {
  String? capturedRefreshToken;
  _MockLogoutService() : super();

  @override
  Future<void> logout(String refreshToken) async {
    capturedRefreshToken = refreshToken;
  }
}

void main() {
  group('AuthService', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
    });

    group('login', () {
      test('login with user info saves tokens, category, moduleId, userInfo', () async {
        final mockLogin = _MockLoginService(
          onLogin: () => _makeLoginResponse(user: {
            'id_anggota': 'a-001',
            'kategori_anggota': 'balita',
            'module_id': 'mod-001',
            'module_type': 'balita',
            'nama': 'Budi',
            'user_type': 'warga',
          }),
        );
        final mockLogout = _MockLogoutService();
        final tokenService = TokenService();
        final authService = AuthService(
          loginService: mockLogin,
          logoutService: mockLogout,
          tokenService: tokenService,
        );

        await authService.login(identifier: 'test', password: 'pass');

        expect(await tokenService.getAccessToken(), 'at-1');
        expect(await tokenService.getRefreshToken(), 'rt-1');
        expect(await tokenService.getRoles(), ['user']);
        expect(await tokenService.getCategory(), UserCategory.balita);
        expect(await tokenService.getModuleId(), 'mod-001');
        final info = await tokenService.getUserInfo();
        expect(info?['nama'], 'Budi');
      });

      test('login without user info skips category, moduleId, userInfo', () async {
        final mockLogin = _MockLoginService(
          onLogin: () => _makeLoginResponse(user: null),
        );
        final tokenService = TokenService();
        final authService = AuthService(
          loginService: mockLogin,
          tokenService: tokenService,
        );

        await authService.login(identifier: 'test', password: 'pass');

        expect(await tokenService.getAccessToken(), 'at-1');
        expect(await tokenService.getCategory(), isNull);
        expect(await tokenService.getModuleId(), isNull);
        expect(await tokenService.getUserInfo(), isNull);
      });
    });

    group('logout', () {
      test('logout with refresh token calls service and clears all', () async {
        final mockLogin = _MockLoginService(
          onLogin: () => _makeLoginResponse(user: {
            'id_anggota': 'a-001',
            'kategori_anggota': 'balita',
            'module_id': 'mod-001',
            'module_type': 'balita',
            'nama': 'Budi',
            'user_type': 'warga',
          }),
        );
        final mockLogout = _MockLogoutService();
        final tokenService = TokenService();
        final authService = AuthService(
          loginService: mockLogin,
          logoutService: mockLogout,
          tokenService: tokenService,
        );

        await authService.login(identifier: 'test', password: 'pass');
        await authService.logout();

        expect(mockLogout.capturedRefreshToken, 'rt-1');
        expect(await tokenService.getAccessToken(), isNull);
        expect(await tokenService.getCategory(), isNull);
        expect(await tokenService.getModuleId(), isNull);
        expect(await tokenService.getUserInfo(), isNull);
      });

      test('logout without refresh token skips API call but still clears', () async {
        final mockLogout = _MockLogoutService();
        final tokenService = TokenService();
        final authService = AuthService(
          logoutService: mockLogout,
          tokenService: tokenService,
        );

        await authService.logout();

        expect(mockLogout.capturedRefreshToken, isNull);
        expect(await tokenService.getAccessToken(), isNull);
      });
    });

    group('delegation', () {
      test('isLoggedIn delegates to TokenService', () async {
        final tokenService = TokenService();
        final authService = AuthService(tokenService: tokenService);
        expect(await authService.isLoggedIn(), isFalse);
      });

      test('getRoles delegates to TokenService', () async {
        FlutterSecureStorage.setMockInitialValues({'roles': 'admin,koordinator'});
        final authService = AuthService();
        expect(await authService.getRoles(), ['admin', 'koordinator']);
      });

      test('saveCategory and getCategory roundtrip', () async {
        final authService = AuthService();
        await authService.saveCategory(UserCategory.lansia);
        expect(await authService.getCategory(), UserCategory.lansia);
      });

      test('getModuleId delegates to TokenService', () async {
        final tokenService = TokenService();
        await tokenService.saveModuleId('mod-999');
        final authService = AuthService(tokenService: tokenService);
        expect(await authService.getModuleId(), 'mod-999');
      });

      test('saveUserInfo and getUserInfo roundtrip', () async {
        final authService = AuthService();
        final info = UserInfo(
          idAnggota: 'a-007',
          kategoriAnggota: 'remaja',
          moduleId: 'mod-007',
          moduleType: 'remaja',
          nama: 'Siti',
          userType: 'warga',
        );
        await authService.saveUserInfo(info);
        final result = await authService.getUserInfo();
        expect(result?.idAnggota, 'a-007');
        expect(result?.nama, 'Siti');
      });

      test('getUserInfo returns null when not set', () async {
        final authService = AuthService();
        expect(await authService.getUserInfo(), isNull);
      });
    });
  });
}
