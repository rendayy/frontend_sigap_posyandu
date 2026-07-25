class ServerException implements Exception {
  final int? statusCode;
  final String message;
  final String? rawMessage;

  const ServerException({this.statusCode, required this.message, this.rawMessage});

  String get friendlyMessage {
    if (statusCode == 401) return 'Sesi Anda telah habis. Silakan login kembali.';
    if (statusCode == 403) return 'Anda tidak memiliki akses ke data ini.';
    if (statusCode == 404) return 'Data tidak ditemukan.';
    if (statusCode == 409) return 'Terjadi bentrokan data. Silakan coba lagi.';
    if (statusCode == 422) return 'Data yang Anda masukkan tidak valid.';
    if (statusCode == 429) return 'Terlalu banyak permintaan. Silakan coba beberapa saat lagi.';
    if (statusCode != null && statusCode! >= 500) return 'Terjadi gangguan pada server. Silakan coba lagi nanti.';
    return message;
  }
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.'});
}

String friendlyError(dynamic error) {
  if (error is ServerException) return error.friendlyMessage;
  if (error is NetworkException) return error.message;
  if (error is Exception) {
    final msg = error.toString().replaceFirst('Exception: ', '');
    if (msg == 'SESSION_EXPIRED') return 'Sesi Anda telah habis. Silakan login kembali.';
    if (msg == 'FORBIDDEN') return 'Anda tidak memiliki akses ke data ini.';
    if (msg == 'NETWORK_ERROR') return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    return msg;
  }
  return 'Terjadi kesalahan yang tidak diketahui.';
}

bool isSessionExpired(dynamic error) {
  if (error is ServerException && error.statusCode == 401) return true;
  if (error is Exception) {
    final msg = error.toString().replaceFirst('Exception: ', '');
    return msg == 'SESSION_EXPIRED';
  }
  return false;
}
