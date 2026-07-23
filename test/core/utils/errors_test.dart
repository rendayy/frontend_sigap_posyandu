import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

void main() {
  group('ServerException', () {
    test('friendlyMessage for 401', () {
      final e = ServerException(statusCode: 401, message: 'Token JWT tidak valid');
      expect(e.friendlyMessage, 'Sesi Anda telah habis. Silakan login kembali.');
    });

    test('friendlyMessage for 403', () {
      final e = ServerException(statusCode: 403, message: 'Forbidden');
      expect(e.friendlyMessage, 'Anda tidak memiliki akses ke data ini.');
    });

    test('friendlyMessage for 404', () {
      final e = ServerException(statusCode: 404, message: 'Not found');
      expect(e.friendlyMessage, 'Data tidak ditemukan.');
    });

    test('friendlyMessage for 409', () {
      final e = ServerException(statusCode: 409, message: 'Conflict');
      expect(e.friendlyMessage, 'Terjadi bentrokan data. Silakan coba lagi.');
    });

    test('friendlyMessage for 422', () {
      final e = ServerException(statusCode: 422, message: 'Unprocessable');
      expect(e.friendlyMessage, 'Data yang Anda masukkan tidak valid.');
    });

    test('friendlyMessage for 429', () {
      final e = ServerException(statusCode: 429, message: 'Too many requests');
      expect(e.friendlyMessage, 'Terlalu banyak permintaan. Silakan coba beberapa saat lagi.');
    });

    test('friendlyMessage for 500', () {
      final e = ServerException(statusCode: 500, message: 'Internal server error');
      expect(e.friendlyMessage, 'Terjadi gangguan pada server. Silakan coba lagi nanti.');
    });

    test('friendlyMessage for unknown status code uses message', () {
      final e = ServerException(statusCode: 418, message: 'I am a teapot');
      expect(e.friendlyMessage, 'I am a teapot');
    });

    test('friendlyMessage for null status uses message', () {
      final e = ServerException(message: 'Custom error');
      expect(e.friendlyMessage, 'Custom error');
    });
  });

  group('NetworkException', () {
    test('default message', () {
      expect(
        const NetworkException().message,
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    });
  });

  group('friendlyError', () {
    test('returns ServerException.friendlyMessage for ServerException', () {
      final e = ServerException(statusCode: 401, message: 'x');
      expect(friendlyError(e), 'Sesi Anda telah habis. Silakan login kembali.');
    });

    test('returns NetworkException.message for NetworkException', () {
      final e = const NetworkException();
      expect(friendlyError(e), contains('Tidak dapat terhubung ke server'));
    });

    test('returns plain message for plain Exception', () {
      final e = Exception('Something went wrong');
      expect(friendlyError(e), 'Something went wrong');
    });

    test('handles SESSION_EXPIRED message', () {
      final e = Exception('SESSION_EXPIRED');
      expect(friendlyError(e), 'Sesi Anda telah habis. Silakan login kembali.');
    });

    test('handles NETWORK_ERROR message', () {
      final e = Exception('NETWORK_ERROR');
      expect(friendlyError(e), contains('Periksa koneksi internet'));
    });

    test('handles FORBIDDEN message', () {
      final e = Exception('FORBIDDEN');
      expect(friendlyError(e), 'Anda tidak memiliki akses ke data ini.');
    });

    test('returns default message for unknown type', () {
      expect(friendlyError('not an exception'), 'Terjadi kesalahan yang tidak diketahui.');
    });
  });

  group('isSessionExpired', () {
    test('returns true for 401 ServerException', () {
      expect(isSessionExpired(ServerException(statusCode: 401, message: 'x')), isTrue);
    });

    test('returns false for other ServerException', () {
      expect(isSessionExpired(ServerException(statusCode: 403, message: 'x')), isFalse);
    });

    test('returns true for SESSION_EXPIRED Exception', () {
      expect(isSessionExpired(Exception('SESSION_EXPIRED')), isTrue);
    });

    test('returns false for regular Exception', () {
      expect(isSessionExpired(Exception('something else')), isFalse);
    });
  });
}
