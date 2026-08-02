# Plan: Tweak Awal Aplikasi — Login Flow, Logout, Status Bar, & Warna Lingkaran

**Status:** ⏳ Draft

---

## A. Aturan & Referensi

| Aturan | Detail |
|--------|--------|
| **Arsitektur** | Feature-First: Page → Service → ApiClient → Backend |
| **Folder Page** | `lib/features/pages/` |
| **Folder Service** | `lib/core/services/` |
| **Folder Models** | `lib/core/models/` |
| **Folder Widgets** | `lib/widgets/` |
| **Naming** | file: `snake_case`, class: `PascalCase`, var/func: `camelCase` |
| **Import** | `package:` imports |
| **State** | Local state di `StatefulWidget` |
| **Auth** | JWT di `flutter_secure_storage` via `TokenService` |
| **Font** | Google Fonts Plus Jakarta Sans |
| **Theme** | `AppColors`, `AppTheme` |
| **Package Name** | `package:frontend_posyandu` |

---

## B. Ringkasan Masalah & Solusi

### B.1 Masalah 1: Token Expired & Alur Buka App

**Skema yang diinginkan:**

```
Buka app (pertama kali)
  → Splash → Login → fetch server → dashboard/modul

Tutup app → Buka lagi (token masih berlaku)
  → Splash → cek token valid → LANGSUNG dashboard/modul
  → Halaman fetch data dari server (fresh)

Tutup app → Buka lagi (token expired)
  → Splash → cek token ada → dashboard/modul
  → Halaman panggil API → 401 → Dio auto-refresh token
  → Jika refresh berhasil → data masuk
  → Jika refresh gagal (expired semua) → redirect ke login
```

**Akar masalah sebelumnya:** Halaman dashboard/modul tidak fetch data fresh dari server saat diinit, sehingga user mengira skip login berarti tidak bisa ambil data.

**Solusi:** Kembalikan navigasi splash ke skema semula (cek token → redirect), dan pastikan data user dari login response tersimpan agar bisa digunakan oleh halaman manapun.

### B.2 Masalah 2: Data User Tidak Tersimpan Setelah Login

Setelah login sukses, `AuthService.login()` sudah menyimpan `moduleId` dan `category` ke SharedPreferences. Tapi data user lainnya (`nama`, `user_type`, `kategori_anggota`, `id_anggota`) belum disimpan — hanya tersedia di response login saja.

**Solusi:** Tambah method `saveUserInfo()` dan `getUserInfo()` di `TokenService` + `AuthService` untuk menyimpan seluruh data user sebagai JSON.

### B.3 Masalah 3: Belum Ada Halaman Profil & Logout

- File `lib/features/pages/profil/edit_profile_page.dart` masih kosong
- Dashboard sudah punya tombol logout, user ingin logout di halaman profil

**Solusi:** Buat halaman profil yang membaca data user dari TokenService + tombol logout.

### B.4 Masalah 4: Status Bar (Waktu, Baterai, Jaringan)

User ingin status bar disembunyikan.

**Solusi:** Gunakan `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)` di `main()`.

### B.5 Masalah 5: Warna Lingkaran Splash Terlalu Putih

Lingkaran di pojok kanan atas dan kiri bawah `SplashPage` menggunakan `AppColors.white` (`#FFFFFF`).

**Solusi:** Ganti dengan warna light blue (`#D6E4FF`).

---

## C. Ringkasan Perubahan File

### C.1 File Diubah

| # | File | Perubahan |
|---|------|-----------|
| 1 | `lib/features/themes/app_colors.dart` | Tambah konstanta `circleLight = Color(0xFFD6E4FF)` |
| 2 | `lib/features/pages/splash_page.dart` | Ganti warna lingkaran `white` → `circleLight`; **kembalikan navigasi cek token** (tidak selalu redirect ke login) |
| 3 | `lib/main.dart` | Tambah `SystemChrome.setEnabledSystemUIMode(immersiveSticky)`; tambah import & route `/profile` |
| 4 | `lib/core/models/auth/user_model.dart` | Tambah method `toJson()` di `UserInfo`; tambah `UserInfo.fromSharedPrefs()` / `toSharedPrefsMap()` |
| 5 | `lib/core/services/auth/token_service.dart` | Tambah `saveUserInfo(UserInfo)` dan `getUserInfo()` untuk simpan/ambil data user sebagai JSON |
| 6 | `lib/core/services/auth/auth_service.dart` | Tambah delegasi `saveUserInfo()` / `getUserInfo()`; update `login()` untuk simpan data user lengkap |

### C.2 File Baru

| # | File | Isi |
|---|------|-----|
| 7 | `lib/features/pages/profil/profile_page.dart` | Halaman profil dengan info user dari TokenService + tombol logout |

---

## D. Detail Implementasi Per File

### D.1 `lib/features/themes/app_colors.dart`

Tambah satu baris di akhir class `AppColors`:

```dart
static const circleLight = Color(0xFFD6E4FF);
```

### D.2 `lib/features/pages/splash_page.dart`

#### D.2.1 Ganti Warna Lingkaran

```dart
// Sebelum:
decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle)

// Sesudah:
decoration: const BoxDecoration(color: AppColors.circleLight, shape: BoxShape.circle)
```

Ulangi untuk lingkaran kedua.

#### D.2.2 Kembalikan Navigasi Cek Token

`_navigateNext()` kembali ke skema **semula** (cek token → redirect ke kategori / home / login):

```dart
Future<void> _navigateNext() async {
  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();
  if (!mounted) return;

  if (!isLoggedIn) {
    Navigator.pushReplacementNamed(context, '/login');
    return;
  }

  final category = await authService.getCategory();
  if (!mounted) return;

  if (category != null) {
    Navigator.pushReplacementNamed(context, category.route);
  } else {
    Navigator.pushReplacementNamed(context, '/home');
  }
}
```

### D.3 `lib/main.dart`

```dart
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FCMService().initialize();

  // Sembunyikan status bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}
```

Tambah route `/profile`:

```dart
routes: {
  '/': (context) => const SplashPage(),
  '/login': (context) => const LoginPage(),
  '/home': (context) => const DashboardPage(),
  '/balita': (context) => const BalitaPage(),
  '/remaja': (context) => const RemajaPage(),
  '/posbindu': (context) => const PosbinduPage(),
  '/lansia': (context) => const LansiaPage(),
  '/ibu-hamil': (context) => const IbuHamilPage(),
  '/profile': (context) => const ProfilePage(),  // BARU
},
```

### D.4 `lib/core/models/auth/user_model.dart`

Tambah method `toJson()` di class `UserInfo` dan `toPrefsMap()`:

```dart
class UserInfo {
  // ... existing fields ...

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

  static UserInfo? fromPrefs(Map<String, String>? map) {
    if (map == null) return null;
    return UserInfo(
      idAnggota: map['id_anggota'] ?? '',
      kategoriAnggota: map['kategori_anggota'] ?? '',
      moduleId: map['module_id'] ?? '',
      moduleType: map['module_type'] ?? '',
      nama: map['nama'] ?? '',
      userType: map['user_type'] ?? '',
    );
  }
}
```

### D.5 `lib/core/services/auth/token_service.dart`

Tambah konstanta key dan method untuk menyimpan/mengambil UserInfo sebagai JSON:

```dart
static const _userInfoKey = 'user_info';

Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_userInfoKey, jsonEncode(userInfo));
}

Future<Map<String, dynamic>?> getUserInfo() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_userInfoKey);
  if (raw == null) return null;
  return jsonDecode(raw) as Map<String, dynamic>;
}

Future<void> clearUserInfo() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_userInfoKey);
}

Future<void> clearTokens() async {
  await Future.wait([
    _storage.delete(key: _accessTokenKey),
    _storage.delete(key: _refreshTokenKey),
    _storage.delete(key: _rolesKey),
  ]);
  await clearUserInfo();
}
```

### D.6 `lib/core/services/auth/auth_service.dart`

Tambah method delegasi `saveUserInfo` / `getUserInfo` dan update `login()`:

```dart
Future<void> saveUserInfo(UserInfo userInfo) async {
  await _tokenService.saveUserInfo(userInfo.toJson());
}

Future<UserInfo?> getUserInfo() async {
  final map = await _tokenService.getUserInfo();
  if (map == null) return null;
  return UserInfo.fromPrefs(
    map.map((k, v) => MapEntry(k, v.toString())),
  );
}

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
```

### D.7 `lib/features/pages/profil/profile_page.dart` (BARU)

Halaman profil membaca data dari `AuthService.getUserInfo()` dan menampilkannya:

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/services/fcm_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();

  String? _nama;
  String? _userType;
  String? _kategoriAnggota;
  String? _moduleId;
  String? _moduleType;
  List<String> _roles = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final roles = await _authService.getRoles();
    final category = await _authService.getCategory();
    final moduleId = await _authService.getModuleId();
    final userInfo = await _authService.getUserInfo();

    if (!mounted) return;
    setState(() {
      _roles = roles;
      _nama = userInfo?.nama;
      _userType = userInfo?.userType;
      _kategoriAnggota = category?.label ?? userInfo?.kategoriAnggota;
      _moduleId = moduleId ?? userInfo?.moduleId;
      _moduleType = userInfo?.moduleType;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FCMService().clearFcmToken();
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (_nama ?? 'U').substring(0, 1).toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nama ?? 'User',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _roles.join(', '),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Akun',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _infoRow('Tipe User', _userType),
                    _infoRow('Kategori', _kategoriAnggota),
                    _infoRow('Module Type', _moduleType),
                    _infoRow('Module ID', _moduleId),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## E. Alur Lengkap

```
Buka app (pertama kali)
  → main(): hide status bar (immersiveSticky)
  → SplashPage (2 detik, lingkaran light blue)
  → _navigateNext(): cek token → tidak ada → /login
  → LoginPage: POST /api/v1/auth/login
  → AuthService: saveTokens + saveCategory + saveModuleId + saveUserInfo
  → Navigator.pushReplacementNamed(category.route)
  → BalitaPage/RemajaPage/dll: initState → getModuleId() → fetch data dari server

Tutup app → Buka lagi (token valid)
  → SplashPage → cek token → ada → getCategory() → langsung ke halaman kategori
  → Halaman: initState → fetch data dari server (fresh)

Token expired
  → Halaman panggil API → 401 → Dio interceptor refresh token
  → Berhasil → lanjut request
  → Gagal → redirect ke /login

Dari halaman manapun
  → User bisa navigasi ke /profile
  → ProfilePage: tampilkan data user dari TokenService
  → Tekan Logout → konfirmasi → hapus semua data → redirect ke /login
```

---

## F. Urutan Implementasi

| Step | File | Perubahan |
|------|------|-----------|
| 1 | `lib/features/themes/app_colors.dart` | Tambah `circleLight` |
| 2 | `lib/features/pages/splash_page.dart` | Ganti warna lingkaran; kembalikan navigasi cek token |
| 3 | `lib/main.dart` | Tambah `SystemChrome` + route `/profile` |
| 4 | `lib/core/models/auth/user_model.dart` | Tambah `toJson()` + `fromPrefs()` di `UserInfo` |
| 5 | `lib/core/services/auth/token_service.dart` | Tambah `saveUserInfo/getUserInfo/clearUserInfo` |
| 6 | `lib/core/services/auth/auth_service.dart` | Tambah delegasi userInfo; update `login()` simpan userInfo |
| 7 | `lib/features/pages/profil/profile_page.dart` | BUAT halaman profil + logout |

---

## G. Catatan

- Tidak ada perubahan di backend
- Tidak ada perubahan di splash page terkait animasi/durasi (hanya warna + navigasi)
- Saat splash kembali menggunakan navigasi cek token, pastikan `AuthService` import sudah ada di `splash_page.dart` (perlu ditambahkan kembali jika dihapus)
- Dio interceptor sudah menangani 401 auto-refresh token — butuh dicek apakah sudah handle kasus refresh gagal dan redirect ke login
