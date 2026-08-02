# Plan 2: Kategori Pengguna dari Backend (Opsi 1)

**Status:** ✅ Selesai

Backend telah dimodifikasi dan mengembalikan field `user.kategori_anggota` di response login. Frontend membaca kategori langsung dari response, bukan manual dari dialog.

---

## Ringkasan File

### File Baru (Dibuat)

| # | File | Isi |
|---|------|-----|
| 1 | `lib/core/services/auth/logout_service.dart` | Panggil `POST /api/v1/auth/logout` dengan `refresh_token` |
| 2 | `lib/widgets/common/category_picker_dialog.dart` | Widget dialog pilih kategori (untuk ganti kategori di dashboard) |
| 3 | `lib/features/pages/balita/balita_page.dart` | Halaman stub Balita (dengan tombol logout) |
| 4 | `lib/features/pages/remaja/remaja_page.dart` | Halaman stub Remaja (dengan tombol logout) |
| 5 | `lib/features/pages/posbindu/posbindu_page.dart` | Halaman stub Posbindu (dengan tombol logout) |
| 6 | `lib/features/pages/lansia/lansia_page.dart` | Halaman stub Lansia (dengan tombol logout) |
| 7 | `lib/features/pages/ibu_hamil/ibu_hamil_page.dart` | Halaman stub Ibu Hamil (dengan tombol logout) |

### File yang Dimodifikasi

| # | File | Perubahan |
|---|------|-----------|
| 1 | `lib/core/models/auth/user_model.dart` | Tambah enum `UserCategory` + class `UserInfo` + field `user` di `LoginResponse` |
| 2 | `lib/core/services/auth/token_service.dart` | Tambah `saveCategory()` / `getCategory()` / `clearCategory()` via SharedPreferences |
| 3 | `lib/core/services/auth/auth_service.dart` | Tambah auto-save kategori dari response login + method delegasi + `logout()` panggil backend via LogoutService |
| 4 | `lib/features/pages/auth/login_page.dart` | Baca kategori dari `response.user.kategoriAnggota`, langsung navigasi |
| 5 | `lib/features/pages/splash_page.dart` | Redirect berdasarkan kategori tersimpan (atau /home fallback) |
| 6 | `lib/main.dart` | Tambah 5 routes untuk kategori |
| 7 | `lib/features/pages/dashboard/dashboard_page.dart` | Tampilkan kategori aktif + tombol "Ganti" (pakai dialog picker) |

---

## A. Aturan & Referensi

### A.1 Aturan dari Plan 1 (tetap berlaku)

| Aturan | Detail |
|--------|--------|
| **Arsitektur** | Feature-First: Page → Service → ApiClient → Backend |
| **Folder Page** | `lib/features/pages/` |
| **Folder Service** | `lib/core/services/` |
| **Folder Models** | `lib/core/models/` |
| **Folder Widgets** | `lib/widgets/common/` |
| **Naming** | file: `snake_case`, class: `PascalCase`, var/func: `camelCase` |
| **Import** | `package:` imports |
| **State** | Local state di `StatefulWidget` (tidak pakai Bloc/Riverpod) |
| **Auth** | JWT di `flutter_secure_storage` via `TokenService` |
| **Font** | Google Fonts Plus Jakarta Sans |
| **Theme** | `AppColors`, `AppTheme` dari theme existing |

### A.2 Aturan Baru untuk Plan 2

| Aturan | Detail |
|--------|--------|
| **Kategori** | 5 kategori: `Balita`, `Remaja`, `Posbindu`, `Lansia`, `IbuHamil` |
| **Sumber Kategori** | Response login → `data.user.kategori_anggota` (string: `"balita"`, `"remaja"`, dll) |
| **Penyimpanan Kategori** | `SharedPreferences` (key: `user_category`) — tidak perlu dienkripsi |
| **Alur Login Baru** | Login sukses → `AuthService` otomatis simpan kategori dari response → navigasi ke halaman sesuai kategori |
| **Alur Splash Baru** | Cek token → Cek kategori tersimpan → Langsung ke halaman sesuai kategori |
| **Logout** | `POST /api/v1/auth/logout` (dengan refresh_token) → hapus token (FlutterSecureStorage) → hapus kategori (SharedPreferences) |

### A.3 Module & Route Mapping

| Kategori | Enum | Route | Halaman Tujuan |
|----------|------|-------|----------------|
| Balita | `UserCategory.balita` | `/balita` | Halaman Balita (stub) |
| Remaja | `UserCategory.remaja` | `/remaja` | Halaman Remaja (stub) |
| Posbindu | `UserCategory.posbindu` | `/posbindu` | Halaman Posbindu (stub) |
| Lansia | `UserCategory.lansia` | `/lansia` | Halaman Lansia (stub) |
| Ibu Hamil | `UserCategory.ibuHamil` | `/ibu-hamil` | Halaman Ibu Hamil (stub) |

---

## B. API Endpoint: POST /api/v1/auth/login

### B.1 Response (field `user` sekarang ada)

```json
{
    "data": {
        "access_token": "eyJhbG...",
        "expires_in": 1800,
        "refresh_token": "eyJhbG...",
        "roles": ["offline_access", "default-roles-sigap-posyandu", "uma_authorization", "user"],
        "state": "AUTHENTICATED",
        "token_type": "Bearer",
        "user": {
            "id_anggota": "aaaa4420-1793-40d4-942a-9c466013a47c",
            "kategori_anggota": "balita",
            "module_id": "1d16bdec-943b-4336-a222-06181251d5f0",
            "module_type": "balita",
            "nama": "Eunola Myers",
            "user_type": "anggota_keluarga"
        }
    },
    "message": "Login berhasil",
    "success": true,
    "timestamp": "2026-07-23T02:44:04.661577Z"
}
```

---

## B.2 API Endpoint: POST /api/v1/auth/logout

### Request

| Field | Tipe | Wajib | Contoh |
|-------|------|-------|--------|
| `refresh_token` | string | Ya | `"eyJhbG..."` |

### Response Sukses

```json
{
    "data": {},
    "message": "Logout berhasil",
    "success": true,
    "timestamp": "2026-07-23T02:56:17.733361Z"
}
```

**Catatan:** Jika panggilan backend gagal, `LogoutService` tetap throw `DioException` yang di-catch di `AuthService.logout()` — proses hapus token lokal tetap dilanjutkan.

---

### B.3 Model Baru: `UserInfo`

| Field JSON | Dart Field | Tipe | Contoh |
|------------|-----------|------|--------|
| `id_anggota` | `idAnggota` | String | `"aaaa4420-..."` |
| `kategori_anggota` | `kategoriAnggota` | String | `"balita"` |
| `module_id` | `moduleId` | String | `"1d16bdec-..."` |
| `module_type` | `moduleType` | String | `"balita"` |
| `nama` | `nama` | String | `"Eunola Myers"` |
| `user_type` | `userType` | String | `"anggota_keluarga"` |

---

## C. File yang Dibuat

### 1. `lib/core/services/auth/logout_service.dart` — Logout API

- Memanggil `POST /api/v1/auth/logout` dengan body `{ "refresh_token": "..." }`
- `DioException` di-catch agar tetap lanjut ke logout lokal meskipun backend gagal

### 2. `lib/widgets/common/category_picker_dialog.dart` — Dialog Pilih Kategori

Digunakan di dashboard untuk **ganti kategori** (bukan untuk login).
- ListView dengan 5 tile kategori
- Setiap tile: icon + label + arrow
- `CategoryPickerDialog.show(BuildContext context) → Future<UserCategory?>`

### 3–7. Lima halaman stub (dengan logout)

`balita_page.dart`, `remaja_page.dart`, `posbindu_page.dart`, `lansia_page.dart`, `ibu_hamil_page.dart` — masing-masing `Scaffold` + `AppBar` + teks placeholder + **tombol logout** di AppBar.

---

## D. File yang Diubah

### 7. `lib/core/models/auth/user_model.dart`

**Tambah:**
- Enum `UserCategory` dengan 5 nilai (`balita`, `remaja`, `posbindu`, `lansia`, `ibuHamil`)
- Getter `route` → mengembalikan path route masing-masing
- Static `fromString()` → mapping string `"balita"` ke enum
- Class `UserInfo` dengan field `idAnggota`, `kategoriAnggota`, `moduleId`, `moduleType`, `nama`, `userType`
- Field `user` (nullable `UserInfo`) di `LoginResponse`

### 8. `lib/core/services/auth/token_service.dart`

**Tambah method:**
- `saveCategory(UserCategory category)` → simpan ke SharedPreferences key `user_category`
- `getCategory()` → baca dari SharedPreferences, return `UserCategory?`
- `clearCategory()` → hapus dari SharedPreferences

### 9. `lib/core/services/auth/auth_service.dart`

**Perubahan:**
- `login()` → setelah simpan token, otomatis baca `response.user.kategoriAnggota` dan simpan kategori
- `logout()` → ambil `refresh_token` dari TokenService → panggil `LogoutService.logout(refresh_token)` → baru `clearTokens()` + `clearCategory()`
- Tambah method `saveCategory()`, `getCategory()` (delegasi ke TokenService)

### 10. `lib/features/pages/auth/login_page.dart`

**Perubahan di `_login()`:**
```dart
final category = response.user != null
    ? UserCategory.fromString(response.user!.kategoriAnggota)
    : null;
Navigator.pushReplacementNamed(context, category?.route ?? '/home');
```
Tidak ada dialog picker — kategori otomatis dari backend.

### 11. `lib/features/pages/splash_page.dart`

**Perubahan:**
```dart
if (isLoggedIn) {
  final category = await authService.getCategory();
  if (category != null) {
    Navigator.pushReplacementNamed(context, category.route);
  } else {
    Navigator.pushReplacementNamed(context, '/home');
  }
} else {
  Navigator.pushReplacementNamed(context, '/login');
}
```

### 12. `lib/main.dart`

**Tambah routes:**
```dart
'/balita': (context) => const BalitaPage(),
'/remaja': (context) => const RemajaPage(),
'/posbindu': (context) => const PosbinduPage(),
'/lansia': (context) => const LansiaPage(),
'/ibu-hamil': (context) => const IbuHamilPage(),
```

### 13. `lib/features/pages/dashboard/dashboard_page.dart`

**Perubahan:**
- Tampilkan kartu "Kategori" dengan nama kategori aktif
- Tombol "Ganti" → buka `CategoryPickerDialog` → simpan kategori baru → navigasi ke route baru
- Kartu "Status FCM" tetap ada

---

## E. Urutan Implementasi ✅

| Step | File | Perubahan | Status |
|------|------|-----------|--------|
| 1 | `lib/core/models/auth/user_model.dart` | Tambah enum `UserCategory` + class `UserInfo` | ✅ |
| 2 | `lib/core/services/auth/token_service.dart` | Tambah `saveCategory()` / `getCategory()` / `clearCategory()` | ✅ |
| 3 | `lib/core/services/auth/auth_service.dart` | Auto-save kategori dari response login + integrasi LogoutService | ✅ |
| 4 | `lib/core/services/auth/logout_service.dart` | BUAT BARU: panggil `POST /api/v1/auth/logout` | ✅ |
| 5 | `lib/widgets/common/category_picker_dialog.dart` | BUAT BARU: dialog pilih kategori | ✅ |
| 6–10 | Lima halaman stub | BUAT BARU (dengan tombol logout) | ✅ |
| 11 | `lib/features/pages/auth/login_page.dart` | Baca kategori dari `response.user.kategoriAnggota` | ✅ |
| 12 | `lib/features/pages/splash_page.dart` | Redirect berdasarkan kategori tersimpan | ✅ |
| 13 | `lib/main.dart` | Tambah routes | ✅ |
| 14 | `lib/features/pages/dashboard/dashboard_page.dart` | Tampilkan kategori + ganti kategori | ✅ |

---

## F. Alur Lengkap

### F.1 Login

```
LoginPage
  ↓ Input NIK + Password
  ↓ POST /api/v1/auth/login
  ↓ Sukses → response.data.user.kategori_anggota = "balita"
  ↓ AuthService.login() otomatis simpan kategori ke SharedPreferences
  ↓ FCM registration
  ↓ Navigator.pushReplacementNamed(context, '/balita')
  ↓ Langsung masuk ke halaman Balita
```

### F.2 Membuka App Kembali (Splash)

```
SplashPage
  ↓ Cek token di FlutterSecureStorage
  ↓ Token tidak ada → /login
  ↓ Token ada → baca kategori dari SharedPreferences
     ↓ "balita" → Navigator.pushReplacementNamed(context, '/balita')
     ↓ null (korup) → /home (DashboardPage) → bisa ganti kategori manual
```

### F.3 Ganti Kategori (dari Dashboard)

```
DashboardPage
  ↓ Lihat kartu "Kategori: Balita"
  ↓ Klik "Ganti"
  ↓ CategoryPickerDialog tampil
  ↓ Pilih "Lansia"
  ↓ Simpan kategori baru ke SharedPreferences
  ↓ Navigator.pushReplacementNamed(context, '/lansia')
```

### F.4 Logout

```
Halaman mana pun → klik ikon logout
  ↓ FCMService().clearFcmToken()
  ↓ AuthService().logout()
     ↓ Ambil refresh_token dari FlutterSecureStorage
     ↓ POST /api/v1/auth/logout (body: { "refresh_token": "..." })
     ↓ Hapus token + refresh_token + roles dari FlutterSecureStorage
     ↓ Hapus kategori dari SharedPreferences
  ↓ Navigator.pushReplacementNamed(context, '/login')
```

---

## G. Catatan Tambahan

- **CategoryPickerDialog** tetap dibuat dan bisa digunakan untuk **ganti kategori** di dashboard.
- **UserInfo** model opsional — jika backend belum mengembalikan `user`, fallback ke `/home`.
- **shared_preferences** sudah ada di `pubspec.yaml` sejak Plan 1.
- Nama kategori dari backend (`"balita"`) cocok dengan `UserCategory.balita.name` → `fromString()` langsung match.
- **LogoutService** dipanggil di awal `AuthService.logout()`. Jika request gagal (network error, server error), exception di-catch dan proses logout lokal tetap dijalankan.
- Setiap halaman stub kategori memiliki tombol logout di pojok kanan AppBar.
- `flutter analyze` — **No issues found.**
