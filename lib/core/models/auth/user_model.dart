enum UserCategory {
  balita('Balita'),
  remaja('Remaja'),
  posbindu('Posbindu'),
  lansia('Lansia'),
  ibuHamil('Ibu Hamil');

  final String label;
  const UserCategory(this.label);

  String get route {
    switch (this) {
      case UserCategory.balita:
        return '/balita';
      case UserCategory.remaja:
        return '/remaja';
      case UserCategory.posbindu:
        return '/posbindu';
      case UserCategory.lansia:
        return '/lansia';
      case UserCategory.ibuHamil:
        return '/ibu-hamil';
    }
  }

  static UserCategory? fromString(String value) {
    if (value == 'umum') return UserCategory.posbindu;
    final normalized = value.replaceAll('_', '').toLowerCase();
    for (final c in UserCategory.values) {
      if (c.name == value || c.label == value || c.name.toLowerCase() == normalized) return c;
    }
    return null;
  }
}

class UserInfo {
  final String idAnggota;
  final String kategoriAnggota;
  final String moduleId;
  final String moduleType;
  final String nama;
  final String userType;

  const UserInfo({
    required this.idAnggota,
    required this.kategoriAnggota,
    required this.moduleId,
    required this.moduleType,
    required this.nama,
    required this.userType,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    final idAnggota = json['id_anggota'] as String? ?? '';
    final rawModuleId = json['module_id'] as String?;
    final moduleId = (rawModuleId != null && rawModuleId.isNotEmpty)
        ? rawModuleId
        : idAnggota;

    return UserInfo(
      idAnggota: idAnggota,
      kategoriAnggota: json['kategori_anggota'] as String? ?? '',
      moduleId: moduleId,
      moduleType: json['module_type'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      userType: json['user_type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_anggota': idAnggota,
      'kategori_anggota': kategoriAnggota,
      'module_id': moduleId,
      'module_type': moduleType,
      'nama': nama,
      'user_type': userType,
    };
  }
}

class LoginResponse {
  final String accessToken;
  final int expiresIn;
  final String refreshToken;
  final List<String> roles;
  final String state;
  final String tokenType;
  final String message;
  final UserInfo? user;

  const LoginResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
    required this.roles,
    required this.state,
    required this.tokenType,
    required this.message,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LoginResponse(
      accessToken: data['access_token'] as String? ?? '',
      expiresIn: data['expires_in'] as int? ?? 0,
      refreshToken: data['refresh_token'] as String? ?? '',
      roles: data['roles'] != null ? List<String>.from(data['roles'] as List) : [],
      state: data['state'] as String? ?? '',
      tokenType: data['token_type'] as String? ?? 'Bearer',
      message: json['message'] as String? ?? '',
      user: data['user'] != null
          ? UserInfo.fromJson(data['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
