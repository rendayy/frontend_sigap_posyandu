# Plan 1: Implementasi Splash Screen & Login Screen ✅ SELESAI

Berdasarkan analisis desain Figma (`page 1` dan `Login`), aturan PRD, dan dokumentasi API backend.

**Status:** ✅ All items completed. All `lib/pages/` files deleted (moved to `lib/features/pages/`).

---

## A. Aturan & Referensi

### A.1 Aturan PRD

| Aturan | Detail |
|--------|--------|
| **Arsitektur** | Feature-First: Page → Service → ApiClient → Backend |
| **Folder Page** | `lib/features/pages/auth/login_page.dart` |
| **Folder Theme** | `lib/features/themes/app_colors.dart`, `lib/features/themes/theme.dart` |
| **Folder Service** | `lib/core/services/auth/login_service.dart`, `lib/core/services/auth/token_service.dart` |
| **Folder Models** | `lib/core/models/auth/user_model.dart` (untuk response login) |
| **Folder Widgets** | `lib/widgets/common/` |
| **Naming** | file: `snake_case`, class: `PascalCase`, var/func: `camelCase` |
| **Import** | `package:` imports, bukan relative |
| **State** | Local state di `StatefulWidget` saja (tidak pakai Bloc/Riverpod) |
| **Auth** | JWT disimpan di `flutter_secure_storage` via `token_service.dart` |
| **Error** | Validasi client-side di page; error API via `error_handler.dart` |
| **Font** | `google_fonts` — Figma memakai **Plus Jakarta Sans** |

### A.2 Referensi dari dokumentasi `.idea/`

| File | Isi |
|------|-----|
| `errorlist.md` | Standard response API: `success`, `error.code`, `error.message`, opsional `error.details` |
| `models.md` | Model `AnggotaKeluargaModel.nik` (String 16), `AlertModel` & enums |
| `parameter.md` | Struktur pagination (`page`, `limit`, `total`, `total_pages`) |
| `condition.md` | Business logic alert triggers per modul |

---

## B. API Endpoint: POST /api/v1/auth/login

### B.1 Request

| Field | Tipe | Wajib | Contoh |
|-------|------|-------|--------|
| `identifier` | string | Ya | NIK 16 digit (contoh: `3271015505920002`) |
| `password` | string | Ya | Password warga |

### B.2 Response Sukses (200)

```json
{
    "data": {
        "access_token": "eyJhbG... (JWT token)",
        "expires_in": 1800,
        "refresh_token": "eyJhbG... (refresh token)",
        "roles": ["user"],
        "state": "AUTHENTICATED",
        "token_type": "Bearer"
    },
    "message": "Login berhasil",
    "success": true,
    "timestamp": "2026-07-22T13:12:57.770691Z"
}
```

### B.3 Response Error (401)

```json
{
    "success": false,
    "error": {
        "code": 401,
        "message": "Identitas atau kata sandi salah."
    }
}
```

**Sumber:** `Services/Auth/LoginService.py:69` — satu-satunya error message untuk login gagal.

### B.4 Response Error (422 - Validation)

```json
{
    "success": false,
    "error": {
        "code": 422,
        "message": "Terdapat kesalahan pada input",
        "details": { "identifier": ["NIK tidak valid"] }
    }
}
```

### B.5 Standard Format Backend

- **Success:** `{ "success": true, "message": "...", "data": {...}, "timestamp": "..." }`
- **Error:** `{ "success": false, "error": { "code": HTTP_STATUS, "message": "..." } }`
- Opsional `details` field untuk validation errors

---

## C. File yang Dibuat ✅

### 1. `lib/features/themes/app_colors.dart` ✅
Palet warna dari Figma:
```dart
class AppColors {
  static const background = Color(0xFFF5F7FA);     // bg utama
  static const primary = Color(0xFF162DF9);          // tombol, aksen
  static const textPrimary = Color(0xFF1E293B);      // text utama
  static const textSecondary = Color(0xFF64748B);     // text sekunder
  static const inputBg = Color(0xFFF1F5F9);          // bg input field
  static const orange = Color(0xFFF97316);            // badge status
  static const peach = Color(0xFFFFD6A8);             // card bg
  static const success = Color(0xFFDCFCE7);           // sukses
  static const error = Color(0xFFFF2B4E);             // error/danger
  static const cardBg = Color(0xFFE6EFF8);            // card header
  static const splashBackground = Color(0xFF1E3A5F);  // bg splash
  static const white = Colors.white;
}
```

### 2. `lib/features/themes/theme.dart` ✅
- Google Fonts Plus Jakarta Sans sebagai default font
- `ColorScheme.fromSeed`, `useMaterial3: true`
- `inputDecorationTheme` dengan bg = `AppColors.inputBg`, radius 12
- `elevatedButtonTheme` dengan bg = `AppColors.primary`, radius 20
- `textButtonTheme` dengan warna `AppColors.textPrimary`

### 3. `lib/core/models/auth/user_model.dart` ✅
```dart
class LoginResponse {
  final String accessToken;
  final int expiresIn;
  final String refreshToken;
  final List<String> roles;
  final String state;
  final String tokenType;
  final String message;

  factory LoginResponse.fromJson(Map<String, dynamic> json) { ... }
}
```

### 4. `lib/widgets/common/app_text_field.dart` ✅
- Label di atas field (NIK, Kata Sandi)
- `TextFormField` dengan theme global
- `maxLength`, `obscureText`, `validator`
- `keyboardType: TextInputType.number` untuk NIK

### 5. `lib/widgets/common/primary_button.dart` ✅
- Full-width ElevatedButton
- Loading state dengan CircularProgressIndicator
- `onPressed` null = disabled

### 6. `lib/core/services/auth/login_service.dart` ✅
- `login(identifier, password)` → POST /api/v1/auth/login
- Parsing `success`, `data.access_token`, `data.refresh_token`, `data.roles`
- Error dari `error.message` atau `DioException` → throw Exception

### 7. `lib/core/services/auth/token_service.dart` ✅
- `flutter_secure_storage` untuk `access_token`, `refresh_token`, `roles`
- `saveTokens()`, `getAccessToken()`, `getRefreshToken()`, `clearTokens()`, `isLoggedIn()`

### 8. `lib/core/services/auth/auth_service.dart` ✅
- Orchestrator: login → save token
- Method: `login()`, `logout()`, `isLoggedIn()`, `getRoles()`, `getAccessToken()`

### 9. `lib/core/api/api_client.dart` ✅
- Dio instance dengan `AppConfig.apiBaseUrl`
- Interceptor: inject Bearer token dari `TokenService`
- Auto-refresh token on 401 via `/api/v1/auth/refresh`

### 10. `lib/features/pages/auth/login_page.dart` ✅
Stack layout sesuai Figma:
```
┌─────────────────────────┐
│  Status bar (native)     │
│                         │
│       ┌────────┐        │
│       │  LOGO  │        │
│       └────────┘        │
│    Selamat Datang        │  ← sz=24, w=800
│ Masuk ke SIGAP Posyandu │  ← sz=14, w=400
│       Warga              │
│                         │
│  NIK                    │  ← Label sz=12, w=700
│ ┌─────────────────────┐ │
│ │ 3271015505920002    │ │  ← Input bg=#F1F5F9, sz=14
│ └─────────────────────┘ │
│                         │
│  Kata Sandi             │  ← Label sz=12, w=700
│ ┌─────────────────────┐ │
│ │ ************        │ │  ← Input obscure, sz=14
│ └─────────────────────┘ │
│                         │
│          Lupa Kata Sandi?│  ← TextButton, sz=14, w=700
│                         │
│ ┌─────────────────────┐ │
│ │       Masuk         │ │  ← Button #162DF9, radius=20
│ └─────────────────────┘ │
│                         │
│ Kategori Anda ditentukan│  ← Footer, sz=12, w=400
│ otomatis oleh sistem... │
└─────────────────────────┘
```

**State:** `_loading`, `_error`, `_nikController`, `_passwordController` di `StatefulWidget`.

**Alur Login:**
1. User input NIK + Password → listener trigger `setState()`
2. Button "Masuk" aktif hanya jika: NIK 16 digit angka + password tidak kosong (`_isFormValid`)
3. Validasi client-side via `FormValidator`
4. Tampilkan loading di button
5. Panggil `AuthService.login(identifier, password)`
6. Jika sukses → simpan token → **daftarkan FCM token** (`FCMService().registerCurrentToken()`) → navigasi ke `/home`
7. Jika gagal (401) → tampilkan "Identitas atau kata sandi salah."
8. Jika error lain → tampilkan pesan error dari API
9. Hilangkan loading

### 11. `lib/features/pages/splash_page.dart` ✅ (dipindah dari `lib/pages/splash_page.dart`)
- Layout sesuai Figma page 1 (Splash):
```
┌─────────────────────────┐
│  Status bar (native)     │
│                         │
│       ┌────────┐        │
│       │  LOGO  │        │
│       └────────┘        │
│       SIGAP             │  ← sz=30, w=800
│   Posyandu Warga        │  ← sz=14, w=600
│  Sistem Informasi       │
│  Kesehatan Warga        │  ← sz=12, w=400
│      Posyandu           │
│                         │
└─────────────────────────┘
```
- Fade-in animation (FadeTransition + AnimationController, 1.2 detik)
- Setelah 2 detik: cek token → jika ada → `/home`, jika tidak → `/login`
- **Perubahan dari Plan Awal:** Hanya logo + teks (dot indicator dihilangkan karena tidak ada di Figma asli)

### 12. `lib/features/pages/dashboard/dashboard_page.dart` ✅ (BARU — placeholder /home)
- Halaman sementara setelah login sukses
- Tampilkan "Selamat Datang" + info FCM status
- Tombol "Daftarkan Ulang FCM" untuk retry manual
- Tombol logout → clear FCM token + clear auth token → redirect ke `/login`

---

## D. File yang Diubah ✅

### 13. `pubspec.yaml` ✅
Tambah dependensi:
```yaml
dependencies:
  google_fonts: ^6.3.3
  flutter_secure_storage: ^10.0.0
  jwt_decoder: ^2.0.1
  shared_preferences: ^2.1.1
```

### 14. `lib/main.dart` ✅
- Theme: `AppTheme.light`
- Routes:
  - `/` → `SplashPage`
  - `/login` → `LoginPage`
  - `/home` → `DashboardPage`
- Hapus route `/login-test`

### 15. `lib/config.dart` ✅
- Tidak diubah (`AppConfig.apiBaseUrl` dari `.env`)

### 16. `android/app/build.gradle.kts` ✅
- `compileSdk = 36` (dari 34)

### 17. `android/app/src/main/AndroidManifest.xml` ✅
- Tambah `android:usesCleartextTraffic="true"` untuk HTTP ke backend

---

## E. Urutan Implementasi (Execution Log)

| Step | File | Status |
|------|------|--------|
| 1 | `pubspec.yaml` | ✅ |
| 2 | `app_colors.dart` | ✅ |
| 3 | `theme.dart` | ✅ |
| 4 | `user_model.dart` | ✅ |
| 5 | `token_service.dart` | ✅ |
| 6 | `api_client.dart` | ✅ |
| 7 | `login_service.dart` | ✅ |
| 8 | `auth_service.dart` | ✅ (+ tambah `getAccessToken()`) |
| 9 | `app_text_field.dart` | ✅ |
| 10 | `primary_button.dart` | ✅ |
| 11 | `splash_page.dart` | ✅ → pindah ke `lib/features/pages/splash_page.dart` |
| 12 | `login_page.dart` | ✅ (+ FCM integration, + controller listeners) |
| 13 | `main.dart` | ✅ |
| 14 | `dashboard_page.dart` | ✅ (BARU — placeholder `/home`) |
| 15 | Android configs | ✅ (compileSdk=36, cleartextTraffic) |

---

## F. Catatan Tambahan

- **Logo SIGAP**: Figma menggunakan heart icon (`Icons.favorite`) — sesuai dengan ikon palang merah.
- **Status bar**: Tidak perlu diimplementasi (native).
- **Lupa Kata Sandi**: Navigasi ke `/forgot-password` (halaman akan diimplementasi terpisah).
- **Font**: Plus Jakarta Sant via `google_fonts: ^6.3.3`.
- **Error login**: Backend hanya mengembalikan 1 message: "Identitas atau kata sandi salah."
- **Token handling**: refresh_token untuk auto-refresh (expired 1800 detik = 30 menit).
- **FCM Integration**: Setelah login sukses, langsung daftarkan FCM token ke `POST /api/v1/alert/fcm-token`.
- **lib/pages/**: Semua file dihapus (`home_page.dart`, `login_test_page.dart`, `splash_page.dart`).
- **Splash → /home**: Kembali menggunakan auth check (setelah `/home` route tersedia).
