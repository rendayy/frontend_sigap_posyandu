import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/core/models/auth/user_model.dart';

void main() {
  group('UserCategory', () {
    test('fromString mapping "umum" returns UserCategory.posbindu with route /posbindu', () {
      final category = UserCategory.fromString('umum');
      expect(category, UserCategory.posbindu);
      expect(category?.route, '/posbindu');
    });

    test('fromString mapping standard names and labels', () {
      expect(UserCategory.fromString('balita'), UserCategory.balita);
      expect(UserCategory.fromString('Balita'), UserCategory.balita);
      expect(UserCategory.fromString('remaja'), UserCategory.remaja);
      expect(UserCategory.fromString('Remaja'), UserCategory.remaja);
      expect(UserCategory.fromString('posbindu'), UserCategory.posbindu);
      expect(UserCategory.fromString('Posbindu'), UserCategory.posbindu);
      expect(UserCategory.fromString('lansia'), UserCategory.lansia);
      expect(UserCategory.fromString('ibuHamil'), UserCategory.ibuHamil);
      expect(UserCategory.fromString('Ibu Hamil'), UserCategory.ibuHamil);
      expect(UserCategory.fromString('unknown'), isNull);
    });
  });

  group('LoginResponse & UserInfo null-safety', () {
    test('parses json safely even when user fields or state are null', () {
      final json = {
        'success': true,
        'data': {
          'access_token': 'test_token',
          'expires_in': 3600,
          'refresh_token': 'refresh_token',
          'roles': ['user'],
          'state': null,
          'token_type': 'Bearer',
          'user': {
            'id_anggota': '1f67e7f7-bd46-44d6-aad4-89a6c96272cb',
            'kategori_anggota': 'umum',
            'module_id': '1f67e7f7-bd46-44d6-aad4-89a6c96272cb',
            'module_type': null,
            'nama': 'Mochamad Ramadhan Alfikri',
            'user_type': null,
          },
        },
      };

      final response = LoginResponse.fromJson(json);

      expect(response.accessToken, 'test_token');
      expect(response.user, isNotNull);
      expect(response.user!.kategoriAnggota, 'umum');
      expect(response.user!.moduleType, '');
      expect(response.user!.userType, '');
    });
  });
}
