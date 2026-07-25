import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_posyandu/core/models/auth/user_model.dart';
import 'package:frontend_posyandu/core/services/auth/token_service.dart';

void main() {
  group('TokenService', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
    });

    group('tokens', () {
      test('saveTokens stores access token, refresh token, and roles', () async {
        final service = TokenService();
        await service.saveTokens(
          accessToken: 'at-123',
          refreshToken: 'rt-456',
          roles: ['user', 'kader'],
        );

        expect(await service.getAccessToken(), 'at-123');
        expect(await service.getRefreshToken(), 'rt-456');
        expect(await service.getRoles(), ['user', 'kader']);
      });

      test('isLoggedIn returns true when token exists', () async {
        FlutterSecureStorage.setMockInitialValues({'access_token': 'exists'});
        final service = TokenService();
        expect(await service.isLoggedIn(), isTrue);
      });

      test('isLoggedIn returns false when no token', () async {
        final service = TokenService();
        expect(await service.isLoggedIn(), isFalse);
      });

      test('clearTokens removes all token data', () async {
        final service = TokenService();
        await service.saveTokens(
          accessToken: 'at',
          refreshToken: 'rt',
          roles: ['user'],
        );
        await service.clearTokens();

        expect(await service.getAccessToken(), isNull);
        expect(await service.getRefreshToken(), isNull);
        expect(await service.getRoles(), isEmpty);
      });

      test('getRoles returns empty list when no roles stored', () async {
        final service = TokenService();
        expect(await service.getRoles(), isEmpty);
      });
    });

    group('category', () {
      test('saveCategory and getCategory roundtrip', () async {
        final service = TokenService();
        await service.saveCategory(UserCategory.balita);
        expect(await service.getCategory(), UserCategory.balita);
      });

      test('getCategory returns null when not set', () async {
        final service = TokenService();
        expect(await service.getCategory(), isNull);
      });

      test('clearCategory removes stored category', () async {
        final service = TokenService();
        await service.saveCategory(UserCategory.remaja);
        await service.clearCategory();
        expect(await service.getCategory(), isNull);
      });
    });

    group('moduleId', () {
      test('saveModuleId and getModuleId roundtrip', () async {
        final service = TokenService();
        await service.saveModuleId('mod-456');
        expect(await service.getModuleId(), 'mod-456');
      });

      test('getModuleId returns null when not set', () async {
        final service = TokenService();
        expect(await service.getModuleId(), isNull);
      });

      test('clearModuleId removes stored module id', () async {
        final service = TokenService();
        await service.saveModuleId('mod-789');
        await service.clearModuleId();
        expect(await service.getModuleId(), isNull);
      });
    });

    group('userInfo', () {
      test('saveUserInfo and getUserInfo roundtrip', () async {
        final service = TokenService();
        final info = {'id_anggota': 'a-001', 'nama': 'Test'};
        await service.saveUserInfo(info);
        expect(await service.getUserInfo(), info);
      });

      test('getUserInfo returns null when not set', () async {
        final service = TokenService();
        expect(await service.getUserInfo(), isNull);
      });

      test('clearUserInfo removes stored user info', () async {
        final service = TokenService();
        await service.saveUserInfo({'id_anggota': 'a-002'});
        await service.clearUserInfo();
        expect(await service.getUserInfo(), isNull);
      });
    });
  });
}
