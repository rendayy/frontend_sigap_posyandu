# Product Requirements Document (PRD)

## Flutter Setup — Aplikasi SIGAP Posyandu

**Versi:** 1.0  
**Tanggal:** 2026-07-16  
**Platform:** Android, iOS, Web, Windows, macOS, Linux

---

## 1. Pendahuluan

### 1.1 Tujuan
Dokumen ini berisi persyaratan dan spesifikasi teknis untuk setup aplikasi Flutter bernama **sigap_posyandu**, yakni sistem informasi manajemen posyandu terintegrasi yang mencakup modul Balita, Remaja, Ibu Hamil, Lansia, dan Posbindu untuk warga Desa Gelam, Kecamatan Candi, Kabupaten Sidoarjo.

### 1.2 Ruang Lingkup
PRD ini mencakup struktur folder, arsitektur, dependensi, konfigurasi, dan standar kode yang digunakan dalam proyek.

---

## 2. Struktur Folder

```
lib/
├── config.dart                     # Konfigurasi global (base URL API)
├── main.dart                       # Entry point aplikasi
├── router.dart                     # Definisi route & route generator
│
├── core/                           # Infrastructure layer
│   ├── api/
│   │   ├── api_client.dart         # HTTP client (Dio) + interceptor auth
│   │   └── endpoints.dart          # Konstanta endpoint API
│   ├── models/                     # Data model / DTO per modul
│   │   ├── auth/
│   │   │   └── user_model.dart
│   │   ├── balita/
│   │   │   ├── balita_model.dart
│   │   │   └── pemantauan_balita_model.dart
│   │   ├── remaja/
│   │   │   ├── remaja_model.dart
│   │   │   ├── pemantauan_remaja_model.dart
│   │   │   ├── kegiatan_remaja_model.dart
│   │   │   └── kehadiran_remaja_model.dart
│   │   ├── ibu_hamil/
│   │   │   ├── ibu_hamil_model.dart
│   │   │   └── pemeriksaan_ibu_hamil_model.dart
│   │   ├── lansia/
│   │   │   ├── lansia_model.dart
│   │   │   ├── pemeriksaan_lansia_model.dart
│   │   │   └── pemeriksaan_posbindu_model.dart
│   │   ├── cabang/
│   │   │   ├── cabang_model.dart
│   │   │   └── wilayah_cakupan_model.dart
│   │   ├── warga_model.dart
│   │   ├── staff_model.dart
│   │   ├── alert_model.dart
│   │   ├── laporan_model.dart
│   │   └── dashboard_model.dart
│   ├── services/
│   │   ├── auth/
│   │   │   ├── auth_service.dart       # Auth orchestration (login, logout, refresh, register)
│   │   │   ├── login_service.dart
│   │   │   ├── logout_service.dart
│   │   │   ├── register_service.dart
│   │   │   └── token_service.dart      # Token storage & management via flutter_secure_storage
│   │   ├── balita/
│   │   │   ├── balita_service.dart
│   │   │   └── pemantauan_balita_service.dart
│   │   ├── remaja/
│   │   │   ├── remaja_service.dart
│   │   │   ├── pemantauan_remaja_service.dart
│   │   │   ├── kegiatan_remaja_service.dart
│   │   │   └── kehadiran_remaja_service.dart
│   │   ├── ibu_hamil/
│   │   │   ├── ibu_hamil_service.dart
│   │   │   └── pemeriksaan_ibu_hamil_service.dart
│   │   ├── lansia/
│   │   │   ├── lansia_service.dart
│   │   │   └── pemeriksaan_lansia_service.dart
│   │   ├── cabang/
│   │   │   ├── cabang_service.dart
│   │   │   └── wilayah_cakupan_service.dart
│   │   ├── citizen_service.dart       # Manajemen warga (list, detail, activate, deactivate)
│   │   ├── staff_service.dart         # Manajemen kader/staff
│   │   ├── user_management_service.dart
│   │   ├── role_management_service.dart
│   │   ├── alert_service.dart
│   │   ├── laporan_service.dart
│   │   └── dashboard_service.dart
│   └── utils/
│       ├── error_handler.dart
│       ├── local_storage_service.dart
│       └── validators.dart
│
├── features/
│   ├── pages/
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   ├── register_page.dart
│   │   │   ├── forgot_password_page.dart
│   │   │   └── initial_password_page.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_page.dart
│   │   ├── balita/
│   │   │   ├── balita_list_page.dart
│   │   │   ├── balita_detail_page.dart
│   │   │   ├── balita_form_page.dart
│   │   │   ├── pemantauan_balita_list_page.dart
│   │   │   └── pemantauan_balita_form_page.dart
│   │   ├── remaja/
│   │   │   ├── remaja_list_page.dart
│   │   │   ├── remaja_detail_page.dart
│   │   │   ├── remaja_form_page.dart
│   │   │   ├── pemantauan_remaja_list_page.dart
│   │   │   ├── pemantauan_remaja_form_page.dart
│   │   │   ├── kegiatan_remaja_list_page.dart
│   │   │   ├── kegiatan_remaja_form_page.dart
│   │   │   └── kehadiran_remaja_form_page.dart
│   │   ├── ibu_hamil/
│   │   │   ├── ibu_hamil_list_page.dart
│   │   │   ├── ibu_hamil_detail_page.dart
│   │   │   ├── ibu_hamil_form_page.dart
│   │   │   ├── pemeriksaan_ibu_hamil_list_page.dart
│   │   │   └── pemeriksaan_ibu_hamil_form_page.dart
│   │   ├── lansia/
│   │   │   ├── lansia_list_page.dart
│   │   │   ├── lansia_detail_page.dart
│   │   │   ├── lansia_form_page.dart
│   │   │   ├── pemeriksaan_lansia_list_page.dart
│   │   │   └── pemeriksaan_lansia_form_page.dart
│   │   ├── cabang/
│   │   │   ├── cabang_list_page.dart
│   │   │   ├── cabang_detail_page.dart
│   │   │   ├── cabang_form_page.dart
│   │   │   └── wilayah_cakupan_page.dart
│   │   ├── warga/
│   │   │   ├── warga_list_page.dart
│   │   │   ├── warga_detail_page.dart
│   │   │   └── warga_form_page.dart
│   │   ├── staff/
│   │   │   ├── staff_list_page.dart
│   │   │   └── staff_detail_page.dart
│   │   ├── profil/
│   │   │   ├── profile_page.dart
│   │   │   └── edit_profile_page.dart
│   │   ├── alerts/
│   │   │   └── alert_list_page.dart
│   │   ├── laporan/
│   │   │   └── laporan_page.dart
│   │   └── pengaturan/
│   │       └── settings_page.dart
│   └── themes/
│       ├── app_colors.dart
│       └── theme.dart
│
├── resources/
│   ├── fonts/
│   │   └── font.dart
│   └── images/
│       └── logo.png
│
└── widgets/
    ├── auth/
    │   ├── auth_shape.dart
    │   └── role_selector.dart
    ├── common/
    │   ├── app_action_progress.dart
    │   ├── app_bottom_bar.dart
    │   ├── app_carousel.dart
    │   ├── app_dropdown_field.dart
    │   ├── app_header.dart
    │   ├── app_info_cards.dart
    │   ├── app_text_field.dart
    │   ├── app_date_picker.dart
    │   ├── app_search_field.dart
    │   ├── app_filter_drawer.dart
    │   ├── app_pagination.dart
    │   ├── chart_card.dart
    │   ├── notification_helper.dart
    │   ├── secondary_button.dart
    │   ├── submit_button.dart
    │   ├── loading_overlay.dart
    │   └── widgets.dart
    ├── balita/
    │   ├── balita_card.dart
    │   ├── pemantauan_card.dart
    │   └── status_gizi_badge.dart
    ├── remaja/
    │   ├── remaja_card.dart
    │   ├── pemantauan_card.dart
    │   └── kegiatan_card.dart
    ├── ibu_hamil/
    │   ├── ibu_hamil_card.dart
    │   └── pemeriksaan_card.dart
    ├── lansia/
    │   ├── lansia_card.dart
    │   └── pemeriksaan_card.dart
    ├── cabang/
    │   └── cabang_card.dart
    ├── charts/
    │   ├── growth_chart.dart
    │   ├── bmi_chart.dart
    │   ├── tekanan_darah_chart.dart
    │   └── gula_darah_chart.dart
    ├── profile_form.dart
    ├── profile_header.dart
    └── stat_card.dart

static/
├── carousel/
│   ├── 1.jpg
│   ├── 2.jpg
│   └── 3.jpg
└── img/
    └── logo.png

test/
├── widget_test.dart
├── services/
│   ├── auth_service_test.dart
│   ├── balita_service_test.dart
│   └── ...
└── widgets/
    └── common_widgets_test.dart
```

---

## 3. Pola Arsitektur: Feature-First dengan Clean-ish Layers

### 3.1 Lapisan Arsitektur

| Lapisan | Folder | Tanggung Jawab |
|---------|--------|----------------|
| **Entry Point** | `lib/` (root) | `main.dart`, `config.dart`, `router.dart` |
| **Infrastructure** | `lib/core/` | API client, service logic, utilitas |
| **Feature** | `lib/features/` | Halaman (pages), tema (themes), model data |
| **UI Components** | `lib/widgets/` | Widget reusable bersama |
| **Resources** | `lib/resources/` & `static/` | Font, gambar, aset statis |
| **Testing** | `test/` | Unit test & widget test |

### 3.2 Alur Data

```
Page (UI) → Service (Bisnis Logika) → ApiClient (HTTP) → Backend API (Flask)
```

- **Page** hanya bertanggung jawab untuk rendering UI dan menangani input pengguna.
- **Service** berisi logika bisnis, validasi, dan koordinasi panggilan API.
- **ApiClient** (Dio) menangani semua komunikasi HTTP, termasuk interceptor JWT Bearer token dan refresh token otomatis.
- **Auth** menggunakan Keycloak sebagai identity provider dengan token JWT (access + refresh).
- Model data ditempatkan di `lib/features/models/` per modul untuk memudahkan mapping JSON response.

---

## 4. Teknologi & Dependensi

### 4.1 Spesifikasi Lingkungan

| Komponen | Versi / Spesifikasi |
|----------|-------------------|
| Flutter SDK | stable (min. 3.10.x) |
| Dart SDK | ^3.10.3 |
| Target Platform | Android, iOS, Web, Windows, macOS, Linux |

### 4.2 Dependensi Utama

| Package | Fungsi |
|---------|--------|
| `dio: ^5.9.0` | HTTP client untuk REST API |
| `flutter_secure_storage: ^10.0.0` | Penyimpanan token JWT secara aman (terenkripsi) |
| `jwt_decoder: ^2.0.1` | Decode JWT token untuk ekstraksi klaim |
| `shared_preferences: ^2.1.1` | Key-value storage (preferensi pengguna, cache) |
| `carousel_slider: ^5.1.1` | Carousel gambar di halaman dashboard |
| `google_fonts: ^6.3.3` | Font Poppins, Montserrat |
| `convex_bottom_bar: ^3.2.0` | Bottom navigation bar convex |
| `fl_chart: ^0.70.0` | Chart & grafik (growth chart, BMI, tekanan darah, gula darah) |
| `intl: ^0.19.0` | Format tanggal, angka, dan lokalisasi |
| `cached_network_image: ^3.4.0` | Caching gambar profile dari URL |
| `image_picker: ^1.1.0` | Pemilih gambar untuk foto profil |
| `url_launcher: ^6.1.10` | Membuka URL download laporan/KMS PDF |

### 4.3 Dev Dependencies

| Package | Fungsi |
|---------|--------|
| `flutter_test` | Testing framework |
| `flutter_lints: ^6.0.0` | Linting & static analysis |
| `mockito: ^5.4.0` | Mocking untuk unit test |
| `build_runner: ^2.4.0` | Code generation |

---

## 5. Konfigurasi

### 5.1 API Base URL
Berdasarkan environment variable `API_BASE_URL` atau development default — didefinisikan di `lib/config.dart`. Backend berjalan di `http://localhost:5000` saat development.

### 5.2 Endpoint API
Semua endpoint dikelola di `lib/core/api/endpoints.dart`:

| Kategori | Endpoint | Method |
|----------|----------|--------|
| **Auth** | `/api/v1/auth/login` | POST |
| | `/api/v1/auth/refresh` | POST |
| | `/api/v1/auth/logout` | POST |
| | `/api/v1/auth/register-public` | POST |
| | `/api/v1/auth/register-internal` | POST |
| | `/api/v1/auth/forgot-password` | POST |
| | `/api/v1/auth/forgot-password-email` | POST |
| | `/api/v1/auth/change-password` | PUT |
| | `/api/v1/auth/initial-password` | POST |
| | `/api/v1/auth/reset-password` | POST |
| | `/api/v1/auth/validate-token` | POST |
| | `/api/v1/auth/profile` | GET |
| **Warga** | `/api/v1/citizens` | GET |
| | `/api/v1/citizens/me` | GET, PUT |
| | `/api/v1/citizens/{id_anggota}` | GET |
| | `/api/v1/citizens/{id_anggota}/activate` | POST |
| | `/api/v1/citizens/{id_anggota}/deactivate` | POST |
| **Staff** | `/api/v1/staff` | GET |
| | `/api/v1/staff/me` | GET |
| | `/api/v1/staff/{id_kader}` | GET |
| **Users** | `/api/v1/users/{target_id}` | PUT, DELETE |
| | `/api/v1/users/{target_id}/activate` | POST |
| | `/api/v1/users/{target_id}/deactivate` | POST |
| **Roles** | `/api/v1/roles/{target_id}/role` | PATCH |
| **Balita** | `/dashboard/balita/stats` | GET |
| | `/balita` | GET |
| | `/balita/{id_balita}` | GET, PUT |
| | `/balita/{id_balita}/pemantauan` | GET |
| | `/balita/{id_balita}/pemantauan/{id_pantau}` | GET, PUT |
| | `/balita/pemantauan` | POST |
| | `/balita/{id_balita}/growth-chart` | GET |
| | `/balita/{id_balita}/download-kms` | GET |
| **Remaja** | `/dashboard/remaja/stats` | GET |
| | `/remaja` | GET |
| | `/remaja/{id_remaja}` | GET, PUT |
| | `/remaja/{id_remaja}/pemantauan` | GET |
| | `/remaja/{id_remaja}/pemantauan/{id_pantau}` | GET, PUT |
| | `/pemantauan-remaja` | POST |
| | `/remaja/{id_remaja}/bmi-chart` | GET |
| | `/remaja/{id_remaja}/gula-darah-chart` | GET |
| | `/kegiatan-remaja` | GET, POST |
| | `/kegiatan-remaja/{id_kegiatan}` | GET, PUT, DELETE |
| | `/kehadiran-remaja` | POST, PUT |
| **Ibu Hamil** | `/dashboard/ibu-hamil/stats` | GET |
| | `/ibu-hamil` | GET |
| | `/ibu-hamil/{id_ibu_hamil}` | GET, PUT |
| | `/ibu-hamil/{id_ibu_hamil}/pemeriksaan` | GET |
| | `/ibu-hamil/{id_ibu_hamil}/pemeriksaan/{id_periksa}` | GET, PUT |
| | `/pemeriksaan-ibu-hamil` | POST |
| | `/ibu-hamil/{id_ibu_hamil}/berat-badan-chart` | GET |
| | `/ibu-hamil/{id_ibu_hamil}/tinggi-fundus-chart` | GET |
| **Lansia** | `/dashboard/lansia/stats` | GET |
| | `/lansia` | GET |
| | `/lansia/{id_lansia}` | GET, PUT, DELETE |
| | `/lansia/{id_lansia}/pemeriksaan` | GET |
| | `/lansia/{id_lansia}/pemeriksaan/{id_periksa}` | GET, PUT |
| | `/pemeriksaan-lansia` | POST |
| | `/lansia/{id_lansia}/tekanan-darah-chart` | GET |
| | `/lansia/{id_lansia}/gula-darah-chart` | GET |
| **Cabang** | `/cabang` | GET, POST |
| | `/cabang/{id_cabang}` | GET, PUT, DELETE |
| | `/cabang/{id_cabang}/aktifkan` | PATCH |
| | `/cabang/{id_cabang}/nonaktifkan` | PATCH |
| | `/cabang/{id_cabang}/kader` | POST |
| | `/cabang/{id_cabang}/kader/{id_kader}/mutasi` | PATCH |
| | `/cabang/{id_cabang}/cakupan` | GET, POST |
| | `/cabang/{id_cabang}/cakupan/{id_cakupan}` | PUT, DELETE |
| | `/cabang/sebaran` | GET |
| | `/cabang/rekomendasi` | GET |

### 5.3 Aset Statis
- Gambar carousel: `static/carousel/1.jpg`, `2.jpg`, `3.jpg`
- Logo: `static/img/logo.png`
- Didaftarkan di `pubspec.yaml` sebagai `flutter > assets`

---

## 6. Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| **Autentikasi & Manajemen Pengguna** | Login, Register (warga & internal staff), Logout, Forgot/Reset Password, Change Password, Initial Password — semuanya menggunakan Keycloak sebagai Identity Provider. Role: `superuser`, `admin`, `koordinator`, `kader`, `puskesmas`, `user`. |
| **Manajemen Warga** | CRUD data warga (Anggota Keluarga & Keluarga), aktivasi/nonaktifasi akun, pencarian & filter. |
| **Manajemen Staff/Kader** | List & detail kader, penugasan ke cabang posyandu. |
| **Manajemen Role** | Ubah role pengguna (admin/koordinator). |
| **Modul Balita** | CRUD data balita, pemantauan berkala (berat, tinggi, lingkar kepala, status gizi), grafik pertumbuhan (growth chart), download KMS PDF. |
| **Modul Remaja** | CRUD data remaja, pemantauan (berat, tinggi, tekanan darah, gula darah), grafik BMI & gula darah, manajemen kegiatan & kehadiran. |
| **Modul Ibu Hamil** | CRUD data ibu hamil, pemeriksaan kehamilan (berat badan, tekanan darah, tinggi fundus, denyut jantung janin), grafik berat badan & tinggi fundus. |
| **Modul Lansia** | CRUD data lansia, pemeriksaan (tekanan darah, gula darah, kolesterol, asam urat, skrining depresi/jiwa), grafik tekanan darah & gula darah. |
| **Modul Cabang Posyandu** | Manajemen cabang posyandu, wilayah cakupan (RT/RW/dusun), penugasan & mutasi kader, rekomendasi cabang, sebaran geografis. |
| **Dashboard & Statistik** | Ringkasan statistik per modul (jumlah balita, status gizi, cakupan imunisasi, dll). |
| **Alert/Notifikasi** | Daftar alert berdasarkan jenis (imunisasi, pemeriksaan, stunting, anemia, kehamilan, lansia). |
| **Laporan** | Generate & download laporan bulanan/triwulan/tahunan. |
| **Profil** | Lihat & edit profil warga (nama, no_hp). |
| **Grafik & Visualisasi** | Growth chart (BB/U, TB/U, BB/TB), BMI chart, tekanan darah chart, gula darah chart, berat badan chart, tinggi fundus chart — menggunakan `fl_chart`. |

---

## 7. Standar Kode

> **📌 Lihat juga:** [`standar-modul.md`](./standar-modul.md) — standar implementasi UI/UX setiap modul (skeleton loading, cache lokal, offline banner, error handling, pull-to-refresh).

### 7.1 Penamaan
- **File/Directory**: `snake_case`
- **Class/Enum**: `PascalCase`
- **Variable/Function**: `camelCase`
- **Constant**: `camelCase`

### 7.2 Struktur Impor
- Gunakan `package:` imports, bukan relative path.
- Barrel export (`widgets.dart`) untuk widget umum.

### 7.3 State Management & Loading
- Tidak menggunakan state management library khusus (seperti Bloc, Provider, Riverpod).
- State dikelola secara lokal di masing-masing page menggunakan `StatefulWidget` + `ModulePageHelper<T>`.
- Loading menggunakan **skeleton per widget** (bukan `CircularProgressIndicator`). Lihat `SkeletonWidget` dan `standar-modul.md#1-loading-skeleton-per-widget`.
- Data di-cache ke `SharedPreferences` via `CacheManager<T>` dan ditampilkan saat offline dengan banner "Menampilkan data tersimpan". Lihat `standar-modul.md#2-cache-lokal`.

### 7.4 Error Handling
- Semua error API ditangani melalui `core/utils/errors.dart` (`ServerException`, `NetworkException`, `friendlyError()`, `isSessionExpired()`).
- HTTP 401 → redirect ke halaman login. Error lain → tampilkan pesan bahasa awam. Lihat `standar-modul.md#5-error-handling`.
- Gunakan `loadModuleData()` dari `core/utils/module_page_mixin.dart` untuk alur error + cache fallback otomatis.

---

## 8. Non-Functional Requirements

| Kategori | Requirement |
|----------|-------------|
| **Security** | Token JWT (access + refresh) disimpan di `flutter_secure_storage` (terenkripsi). Komunikasi via HTTPS. |
| **Role-Based Access** | UI menyesuaikan berdasarkan role pengguna (`admin`, `koordinator`, `kader`, `user`). Menu/tombol disembunyikan jika tidak memiliki akses. |
| **Performance** | Data di-cache menggunakan `shared_preferences` untuk mengurangi panggilan API berulang. Pagination untuk list data. |
| **Compatibility** | Mendukung Android 5.0+, iOS 12+, dan web browser modern. |
| **Code Quality** | Mengikuti Flutter lints (package `flutter_lints`), tidak ada warning/error. |

---

## 9. Pengembangan ke Depan

- Integrasi state management (Riverpod / Bloc) untuk skala yang lebih besar
- Push notification (FCM) untuk alert imunisasi, pemeriksaan terjadwal
- Dukungan multi-bahasa (i18n)
- Dark mode
- Logging & monitoring (Firebase Crashlytics / Sentry)
- CI/CD pipeline (GitHub Actions)
- Upload foto profil warga & kader langsung dari perangkat
- Pencarian offline untuk data warga yang sudah di-cache
