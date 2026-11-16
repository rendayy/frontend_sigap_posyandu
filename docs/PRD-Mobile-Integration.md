# PRD: Integrasi Mobile (Flutter Android) — SIGAP Posyandu

## Latar Belakang

Aplikasi mobile **SIGAP Posyandu** untuk warga (role: `user`) yang memungkinkan warga melihat data kesehatan dirinya dan keluarganya secara read-only. Setiap modul hanya bisa diakses via **GET** — tidak ada create/update/delete dari mobile.

---

## 1. Autentikasi & Manajemen Sesi

### 1.1 Flow Login

```
[Mobile App]                    [Keycloak]                    [Backend Flask]
     |                              |                              |
     |--- POST /auth/login -------->|                              |
     |   { username, password }     |                              |
     |<--- access_token, refresh ---|                              |
     |                              |                              |
     |--- GET /auth/profile ------->|---- (validasi token) ------->|
     |   Bearer: access_token       |                              |
     |<--- { id_anggota, nama ...} -|                              |
```

### 1.2 Endpoint Auth

| Method | Endpoint | Header | Body | Response |
|--------|----------|--------|------|----------|
| POST | `/api/v1/auth/login` | - | `{ "username": "nik", "password": "..." }` | `{ "access_token", "refresh_token", "expires_in" }` |
| POST | `/api/v1/auth/refresh` | - | `{ "refresh_token": "..." }` | `{ "access_token", "refresh_token" }` |
| POST | `/api/v1/auth/logout` | `Bearer token` | - | `{ "success": true }` |
| POST | `/api/v1/auth/forgot-password` | - | `{ "username": "nik" }` | `{ "success": true }` |
| POST | `/api/v1/auth/forgot-password-email` | - | `{ "email": "..." }` | `{ "success": true }` |
| POST | `/api/v1/auth/change-password` | `Bearer token` | `{ "old_password", "new_password" }` | `{ "success": true }` |
| GET | `/api/v1/auth/profile` | `Bearer token` | - | `{ "keycloak_id", "username", "roles", "user_type" }` |

### 1.3 Implementasi Flutter

```
lib/
├── core/
│   ├── network/
│   │   ├── api_client.dart           # Dio instance + interceptor
│   │   ├── auth_interceptor.dart     # Auto-attach token, handle 401 → refresh
│   │   └── api_endpoints.dart        # Semua konstanta endpoint
│   ├── storage/
│   │   └── secure_storage.dart       # flutter_secure_storage untuk token
│   └── providers/
│       └── auth_provider.dart        # ChangeNotifier untuk state login
```

**Ketentuan:**
- Token disimpan di **flutter_secure_storage** (encrypted)
- Setiap request menyertakan header `Authorization: Bearer {access_token}`
- Jika response 401, interceptor otomatis refresh token
- Jika refresh gagal → redirect ke halaman login

---

## 2. Modul & API untuk Mobile

### 2.1 Dashboard / Beranda

Tidak ada endpoint dashboard khusus warga. Halaman utama menampilkan:
- Profil warga (dari `/citizens/me`)
- Ringkasan data kesehatan dari semua modul yang terdaftar

**Endpoint terkait:**

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/v1/citizens/me` | Profil warga + data anggota keluarga |
| GET | `/api/v1/logs/me` | Riwayat aktivitas terbaru |

#### Response `/citizens/me`:
```json
{
  "success": true,
  "data": {
    "id_anggota": "uuid",
    "nik": "1234567890123456",
    "nama": "Siti Rahmawati",
    "no_hp": "08123456789",
    "email": "siti@mail.com",
    "tempat_lahir": "Bandung",
    "tanggal_lahir": "1990-01-15",
    "jenis_kelamin": "P",
    "kategori_anggota": "umum",
    "status_kesehatan": "sehat",
    "id_keluarga": "uuid",
    "keluarga": {
      "no_kk": "1234567890123456",
      "alamat": "Jl. Merdeka No. 1",
      "rt": "001",
      "rw": "002",
      "dusun": "Sukamaju"
    }
  }
}
```

### 2.2 Modul Balita

| Method | Endpoint | Deskripsi | Filter |
|--------|----------|-----------|--------|
| GET | `/balita/{id_balita}` | Detail balita | Data milik sendiri |
| GET | `/balita/{id_balita}/pemantauan` | Riwayat pemantauan | Data milik sendiri |
| GET | `/balita/{id_balita}/pemantauan/{id_pantau}` | Detail pemantauan | Data milik sendiri |
| GET | `/balita/{id_balita}/growth-chart` | Data grafik pertumbuhan | Data milik sendiri |
| GET | `/balita/{id_balita}/download-kms` | Download KMS (PDF) | Data milik sendiri |

#### Response Detail Balita:
```json
{
  "success": true,
  "data": {
    "id_balita": "uuid",
    "id_anggota": "uuid",
    "nama": "Budi",
    "nik": "1234567890123456",
    "tanggal_lahir": "2024-01-10",
    "jenis_kelamin": "L",
    "berat_lahir": 3.2,
    "panjang_lahir": 48.0,
    "asi_eksklusif": "ya",
    "imunisasi_dasar": "lengkap",
    "status_gizi": "baik",
    "nama_ibu": "Siti",
    "nama_ayah": "Ahmad"
  }
}
```

#### Response Pemantauan (list):
```json
{
  "success": true,
  "data": [
    {
      "id_pantau": "uuid",
      "tanggal_pantau": "2025-01-15",
      "usia_bulan": 12,
      "berat": 8.5,
      "tinggi": 72.0,
      "lingkar_kepala": 44.0,
      "status_gizi": "gizi_baik",
      "imunisasi": "Polio-4, DPT-HB-Hib-4",
      "vitamin_a": "ya",
      "keluhan": null,
      "saran": "Pertumbuhan normal, lanjutkan ASI"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 10,
    "total": 5,
    "total_pages": 1
  }
}
```

#### Response Growth Chart:
```json
{
  "success": true,
  "data": {
    "balita": {
      "id_balita": "uuid",
      "nama": "Budi",
      "jenis_kelamin": "L"
    },
    "pemantauan": [
      {
        "usia_bulan": 1,
        "berat": 4.0,
        "tinggi": 52.0
      }
    ],
    "standar_who": {
      "median": [...],
      "minus_1sd": [...],
      "minus_2sd": [...],
      "minus_3sd": [...],
      "plus_1sd": [...],
      "plus_2sd": [...],
      "plus_3sd": [...]
    }
  }
}
```

### 2.3 Modul Ibu Hamil

| Method | Endpoint | Deskripsi | Filter |
|--------|----------|-----------|--------|
| GET | `/ibu-hamil/{id}` | Detail ibu hamil | Data milik sendiri |
| GET | `/ibu-hamil/{id}/pemeriksaan` | Riwayat pemeriksaan | Data milik sendiri |
| GET | `/ibu-hamil/{id}/pemeriksaan/{id_periksa}` | Detail pemeriksaan | Data milik sendiri |
| GET | `/ibu-hamil/{id}/berat-badan-chart` | Grafik berat badan | Data milik sendiri |
| GET | `/ibu-hamil/{id}/tinggi-fundus-chart` | Grafik tinggi fundus | Data milik sendiri |

#### Response Detail Ibu Hamil:
```json
{
  "success": true,
  "data": {
    "id_ibu_hamil": "uuid",
    "nama": "Siti Rahmawati",
    "nik": "1234567890123456",
    "hpht": "2025-06-01",
    "hpl": "2026-03-08",
    "gravida": 2,
    "para": 1,
    "abortus": 0,
    "tinggi_badan": 155.0,
    "golongan_darah": "A",
    "riwayat_penyakit": "Tidak ada",
    "usia_kehamilan_saat_ini": 20
  }
}
```

#### Response Pemeriksaan:
```json
{
  "success": true,
  "data": {
    "id_periksa": "uuid",
    "tanggal_periksa": "2025-11-01",
    "usia_kehamilan": 20,
    "berat_badan": 58.0,
    "sistol": 120,
    "distol": 80,
    "lingkar_lengan": 26.0,
    "tinggi_fundus": 18.0,
    "letak_janin": "presentasi kepala",
    "denyut_jantung": 140,
    "keluhan": null,
    "tindakan": "Tablet Fe diberikan",
    "tablet_fe": "ya",
    "rujukan": "tidak"
  }
}
```

### 2.4 Modul Lansia

| Method | Endpoint | Deskripsi | Filter |
|--------|----------|-----------|--------|
| GET | `/lansia/{id}` | Detail lansia | Data milik sendiri |
| GET | `/lansia/{id}/pemeriksaan` | Riwayat pemeriksaan | Data milik sendiri |
| GET | `/lansia/{id}/pemeriksaan/{id_periksa}` | Detail pemeriksaan | Data milik sendiri |
| GET | `/lansia/{id}/berat-badan-chart` | Grafik berat badan | Data milik sendiri |
| GET | `/lansia/{id}/gula-darah-chart` | Grafik gula darah | **⚠️ Perlu tambah role "user"** |

#### Response Detail Lansia:
```json
{
  "success": true,
  "data": {
    "id_lansia": "uuid",
    "nama": "Sukirman",
    "nik": "1234567890123456",
    "tanggal_lahir": "1960-03-20",
    "penyakit_penyerta": "Hipertensi, Diabetes",
    "obat_rutin": "Amlodipin 5mg, Metformin 500mg",
    "perokok": "tidak_aktif",
    "aktifitas_fisik": "ringan",
    "bantuan_keluarga": "ya"
  }
}
```

### 2.5 Modul Remaja

| Method | Endpoint | Deskripsi | Filter |
|--------|----------|-----------|--------|
| GET | `/remaja/{id}` | Detail remaja | Data milik sendiri |
| GET | `/remaja/{id}/pemantauan` | Riwayat pemantauan | Data milik sendiri |
| GET | `/remaja/{id}/pemantauan/{id_pantau}` | Detail pemantauan | Data milik sendiri |
| GET | `/remaja/{id}/bmi-status` | Status BMI | Data milik sendiri |
| GET | `/remaja/{id}/gula-darah-chart` | Grafik gula darah | Data milik sendiri |
| GET | `/kegiatan-remaja` | Daftar kegiatan | Semua (publik) |
| GET | `/kegiatan-remaja/{id}` | Detail kegiatan | Semua (publik) |
| GET | `/kehadiran-remaja` | Riwayat kehadiran | Data milik sendiri |

### 2.6 Modul Posbindu

| Method | Endpoint | Deskripsi | Filter |
|--------|----------|-----------|--------|
| GET | `/posbindu/{id_anggota}` | Riwayat pemeriksaan | Data milik sendiri |
| GET | `/posbindu/{id_anggota}/detail` | Detail pemeriksaan | Data milik sendiri |
| GET | `/posbindu/{id_anggota}/pemeriksaan/{id_periksa}` | Detail periksa | Data milik sendiri |
| GET | `/posbindu/{id_anggota}/bmi-status` | Status BMI | Data milik sendiri |
| GET | `/posbindu/{id_anggota}/gula-darah-chart` | Grafik gula darah | Data milik sendiri |

### 2.7 Modul Pendukung (Referensi)

| Method | Endpoint | Deskripsi | Catatan |
|--------|----------|-----------|---------|
| GET | `/api/v1/wilayah/provinsi` | Daftar provinsi | **⚠️ Perlu tambah role "user"** |
| GET | `/api/v1/wilayah/provinsi/{kode}/kabupaten` | Daftar kab/kota | **⚠️ Perlu tambah role "user"** |
| GET | `/api/v1/wilayah/kabupaten/{kode}/kecamatan` | Daftar kecamatan | **⚠️ Perlu tambah role "user"** |
| GET | `/api/v1/wilayah/kecamatan/{kode}/desa` | Daftar desa/kelurahan | **⚠️ Perlu tambah role "user"** |
| GET | `/cabang` | Daftar posyandu | **⚠️ Perlu tambah role "user"** |
| GET | `/cabang/{id}` | Detail posyandu | **⚠️ Perlu tambah role "user"** |
| POST | `/api/v1/alert/fcm-token` | Registrasi FCM token | Sudah bisa (tanpa role) |

### 2.8 Modul Keluarga & Anggota

Endpoint ini bisa digunakan jika warga perlu melihat data keluarganya sendiri (termasuk anggota lain).

| Method | Endpoint | Deskripsi | Catatan |
|--------|----------|-----------|---------|
| GET | `/api/v1/keluarga/{id}` | Detail keluarga | **⚠️ Perlu tambah role "user" + filter milik sendiri** |
| GET | `/api/v1/citizens/{id}` | Detail anggota lain | **⚠️ Perlu tambah role "user" + filter satu keluarga** |

---

## 3. Alur Navigasi Aplikasi

```
Splash Screen
    │
    ▼
Login Screen ─────────────────────────────┐
    │                                      │
    ▼                                      │
Beranda (Dashboard)  ◄─────────────────────┘
    │
    ├── [Kartu Keluarga]   → Detail Keluarga (anggota)
    │
    ├── [Modul Balita]     → List Balita → Detail Balita → Pemantauan
    │                                              → Grafik Pertumbuhan
    │                                              → Download KMS
    │
    ├── [Modul Ibu Hamil]  → Detail Ibu Hamil → Riwayat Pemeriksaan
    │                                              → Grafik BB
    │                                              → Grafik Fundus
    │
    ├── [Modul Lansia]     → Detail Lansia → Riwayat Pemeriksaan
    │                                              → Grafik BB
    │                                              → Grafik Gula Darah
    │
    ├── [Modul Remaja]     → Detail Remaja → Pemantauan
    │                                       → BMI Status
    │                                       → Grafik Gula Darah
    │                                       → Kegiatan Remaja
    │                                       → Kehadiran
    │
    ├── [Posbindu]         → Detail Posbindu → Riwayat Pemeriksaan
    │                                            → Grafik
    │
    ├── [Profil]           → Profil Warga → Edit Profil
    │                                       → Ganti Password
    │
    └── [Settings]         → Logout
                           → Info Aplikasi
```

---

## 4. Struktur Project Flutter

```
sigap_posyandu/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── app.dart                    # MaterialApp, routing, theme
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart      # Base URL, endpoint paths
│   │   │   ├── color_constants.dart    # Warna tema Posyandu
│   │   │   └── string_constants.dart   # Label-label UI
│   │   ├── network/
│   │   │   ├── api_client.dart         # Dio instance
│   │   │   ├── auth_interceptor.dart   # Token interceptor
│   │   │   └── api_exceptions.dart     # Custom exception handling
│   │   ├── storage/
│   │   │   └── secure_storage.dart     # Token storage
│   │   ├── theme/
│   │   │   └── app_theme.dart          # ThemeData
│   │   └── utils/
│   │       ├── date_formatter.dart
│   │       ├── number_formatter.dart
│   │       └── validators.dart
│   │
│   ├── data/
│   │   ├── models/                     # JSON serialization (fromJson/toJson)
│   │   │   ├── auth_model.dart
│   │   │   ├── user_profile_model.dart
│   │   │   ├── balita_model.dart
│   │   │   ├── pemantauan_balita_model.dart
│   │   │   ├── growth_chart_model.dart
│   │   │   ├── ibu_hamil_model.dart
│   │   │   ├── pemeriksaan_ibu_hamil_model.dart
│   │   │   ├── lansia_model.dart
│   │   │   ├── pemeriksaan_lansia_model.dart
│   │   │   ├── remaja_model.dart
│   │   │   ├── kegiatan_remaja_model.dart
│   │   │   ├── pemantauan_remaja_model.dart
│   │   │   ├── posbindu_model.dart
│   │   │   ├── keluarga_model.dart
│   │   │   ├── wilayah_model.dart
│   │   │   ├── cabang_model.dart
│   │   │   └── alert_model.dart
│   │   └── repositories/               # Business logic layer
│   │       ├── auth_repository.dart
│   │       ├── balita_repository.dart
│   │       ├── ibu_hamil_repository.dart
│   │       ├── lansia_repository.dart
│   │       ├── remaja_repository.dart
│   │       ├── posbindu_repository.dart
│   │       ├── wilayah_repository.dart
│   │       └── cabang_repository.dart
│   │
│   ├── providers/                      # State management (ChangeNotifier)
│   │   ├── auth_provider.dart
│   │   ├── balita_provider.dart
│   │   ├── ibu_hamil_provider.dart
│   │   ├── lansia_provider.dart
│   │   ├── remaja_provider.dart
│   │   ├── posbindu_provider.dart
│   │   ├── wilayah_provider.dart
│   │   └── cabang_provider.dart
│   │
│   ├── features/
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── widgets/
│   │   │       └── login_form.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── module_card.dart        # Card untuk setiap modul
│   │   │       └── profile_summary_card.dart
│   │   ├── balita/
│   │   │   ├── balita_detail_screen.dart
│   │   │   ├── pemantauan_list_screen.dart
│   │   │   ├── pemantauan_detail_screen.dart
│   │   │   ├── growth_chart_screen.dart    # FL Chart
│   │   │   └── widgets/
│   │   ├── ibu_hamil/
│   │   │   ├── ibu_hamil_detail_screen.dart
│   │   │   ├── pemeriksaan_list_screen.dart
│   │   │   ├── pemeriksaan_detail_screen.dart
│   │   │   └── charts/
│   │   │       ├── berat_badan_chart.dart
│   │   │       └── tinggi_fundus_chart.dart
│   │   ├── lansia/
│   │   │   ├── lansia_detail_screen.dart
│   │   │   ├── pemeriksaan_list_screen.dart
│   │   │   ├── pemeriksaan_detail_screen.dart
│   │   │   └── charts/
│   │   │       ├── berat_badan_chart.dart
│   │   │       └── gula_darah_chart.dart
│   │   ├── remaja/
│   │   │   ├── remaja_detail_screen.dart
│   │   │   ├── pemantauan_list_screen.dart
│   │   │   ├── bmi_status_screen.dart
│   │   │   ├── gula_darah_chart_screen.dart
│   │   │   └── kegiatan/
│   │   │       ├── kegiatan_list_screen.dart
│   │   │       ├── kegiatan_detail_screen.dart
│   │   │       └── kehadiran_list_screen.dart
│   │   ├── posbindu/
│   │   │   ├── posbindu_list_screen.dart
│   │   │   ├── posbindu_detail_screen.dart
│   │   │   └── charts/
│   │   ├── keluarga/
│   │   │   └── keluarga_detail_screen.dart
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   ├── edit_profile_screen.dart
│   │   │   └── change_password_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   │
│   └── shared/
│       └── widgets/                     # Widget reusable
│           ├── loading_indicator.dart
│           ├── error_widget.dart
│           ├── empty_state.dart
│           ├── chart_card.dart          # Wrapper untuk FL Chart
│           ├── info_card.dart           # Card informasi kesehatan
│           └── app_drawer.dart
│
├── pubspec.yaml
│   Dependencies:
│   - dio (HTTP client)
│   - flutter_secure_storage (token storage)
│   - provider (state management)
│   - fl_chart (grafik pertumbuhan, BMI, dll)
│   - intl (date/number formatting)
│   - cached_network_image (jika ada foto)
│   - firebase_messaging (push notification)
│   - open_file / flutter_pdfview (lihat KMS PDF)
│   - flutter_svg (jika ada SVG)
│   - lottie (animasi splash)
│
└── .env
    API_BASE_URL=http://192.168.1.100:5000/api/v1
```

---

## 5. Dependency Flutter (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Network
  dio: ^5.4.0
  # Storage
  flutter_secure_storage: ^9.0.0
  # State Management
  provider: ^6.1.1
  # Chart
  fl_chart: ^0.68.0
  # Formatting
  intl: ^0.19.0
  # Firebase Push Notification
  firebase_core: ^3.4.0
  firebase_messaging: ^15.1.0
  # PDF Viewer
  flutter_pdfview: ^1.3.2
  open_file: ^3.5.2
  # File Download
  path_provider: ^2.1.2
  # UI
  lottie: ^3.1.2
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.3.1
  # Picker (edit profil)
  image_picker: ^1.0.7
```

---

## 6. Desain UI (Wireframe)

### 6.1 Halaman Login
```
┌─────────────────────────┐
│                         │
│      [Logo SIGAP]       │
│    SIGAP Posyandu       │
│                         │
│  ┌─────────────────┐    │
│  │   NIK / Username │    │
│  └─────────────────┘    │
│  ┌─────────────────┐    │
│  │   Password       │    │
│  └─────────────────┘    │
│                         │
│  [──── MASUK ────]      │
│                         │
│  Lupa Password?         │
│                         │
└─────────────────────────┘
```

### 6.2 Halaman Beranda
```
┌─────────────────────────┐
│ ☰ Halo, Siti!      🔔  │
│ Selamat datang           │
├─────────────────────────┤
│ ┌─── Info Keluarga ───┐ │
│ │ KK: 1234567890       │ │
│ │ Anggota: 4 orang     │ │
│ │ Posyandu: Melati     │ │
│ └──────────────────────┘ │
│                         │
│ ┌ Modul Kesehatan ────┐ │
│ │                     │ │
│ │ [👶]  [🤰]  [👴]   │ │
│ │ Balita  Hamil  Lansia│ │
│ │                     │ │
│ │ [🧑]  [🏥]         │ │
│ │ Remaja  Posbindu    │ │
│ └──────────────────────┘ │
│                         │
│ ── Aktivitas Terbaru ── │
│ • Pemeriksaan lansia   │
│   12 Jan 2025          │
│ • Pemantauan balita    │
│   10 Jan 2025          │
│                         │
└─────────────────────────┘
```

### 6.3 Halaman Detail Modul (Contoh: Balita)
```
┌─────────────────────────┐
│ ← Detail Balita         │
├─────────────────────────┤
│                         │
│      [Foto/Icon]        │
│      BUDI               │
│      Laki-laki · 12 bln │
│                         │
│ ┌ Ringkasan ──────────┐ │
│ │ Status Gizi    👍 Baik│ │
│ │ Berat          8.5 kg│ │
│ │ Tinggi         72 cm │ │
│ │ Imunisasi    Lengkap │ │
│ └──────────────────────┘ │
│                         │
│ [── Grafik Pertumbuhan─]│
│  ╱╲    ╱╲    ╱╲        │
│ ╱  ╲  ╱  ╲  ╱  ╲       │
│╱    ╲╱    ╲╱    ╲      │
│───┬───┬───┬───┬───┬──  │
│  1   3   6   9   12     │
│                         │
│ [── Riwayat Pemantauan─]│
│ 12 Jan 2025 • 8.5 kg   >│
│ 10 Des 2024 • 7.8 kg   >│
│ 15 Nov 2024 • 7.2 kg   >│
│                         │
│ [  📥 Download KMS   ] │
│                         │
└─────────────────────────┘
```

### 6.4 Halaman Grafik (fl_chart)
```
┌─────────────────────────┐
│ ← Grafik Pertumbuhan    │
├─────────────────────────┤
│          [Budi]          │
│                         │
│   Berat Badan (kg)      │
│ 10 ┤        ┌───        │
│  9 ┤   ┌───┘           │
│  8 ┤┌──┘               │
│  7 ┤│                  │
│  6 ┤┘                  │
│    └─┬──┬──┬──┬──┬──   │
│      1  3  6  9  12    │
│         Usia (bln)      │
│                         │
│ ┌ Legend:              │
│ │ ● Berat Badan        │
│ │ ─ Median WHO         │
│ │ ─ -2SD               │
│ │ ─ +2SD               │
│ └──────────────────────┘ │
│                         │
│ [↻ Grafik Tinggi]      │
│ [↻ Grafik LK]          │
│                         │
└─────────────────────────┘
```

---

## 7. Prioritas Implementasi

### Tahap 1 — Foundation (Minggu 1)
| No | Item | Estimasi |
|----|------|----------|
| 1 | Setup project Flutter + struktur folder | 1 hari |
| 2 | Implementasi Dio + Auth Interceptor | 1 hari |
| 3 | Secure Storage + token management | 0.5 hari |
| 4 | Halaman Login + integrasi API | 1 hari |
| 5 | Halaman Beranda + navigasi drawer | 1.5 hari |
| 6 | **Backend:** Tambah role "user" di Wilayah & Cabang routes | 0.5 hari |

### Tahap 2 — Modul Kesehatan (Minggu 2)
| No | Item | Estimasi |
|----|------|----------|
| 7 | Modul Balita (detail, pemantauan, grafik) | 2 hari |
| 8 | Modul Ibu Hamil (detail, pemeriksaan, grafik) | 2 hari |
| 9 | Modul Lansia (detail, pemeriksaan, grafik) | 2 hari |

### Tahap 3 — Modul Tambahan (Minggu 3)
| No | Item | Estimasi |
|----|------|----------|
| 10 | Modul Remaja (detail, pemantauan, kegiatan, grafik) | 2 hari |
| 11 | Modul Posbindu | 1.5 hari |
| 12 | **Backend:** Tambah role "user" di gula-darah-chart lansia | 0.5 hari |

### Tahap 4 — Polish (Minggu 4)
| No | Item | Estimasi |
|----|------|----------|
| 13 | Profil + Edit Profil + Ganti Password | 1 hari |
| 14 | FCM Push Notification (firebase_messaging) | 1 hari |
| 15 | Download & Lihat KMS PDF | 0.5 hari |
| 16 | Error handling, loading state, empty state | 1 hari |
| 17 | Testing (manual) + bug fixing | 1.5 hari |

---

## 8. Catatan Backend — Perubahan yang Diperlukan

### 8.1 Tambah Role "user" di WilayahRoute.py

**File:** `app/Routes/WilayahRoute.py`

Ubah `role_required` di 4 endpoint GET:

```python
# Sebelum:
@role_required("admin", "koordinator", "kader")

# Sesudah:
@role_required("admin", "koordinator", "kader", "user")
```

### 8.2 Tambah Role "user" di CabangRoute.py

**File:** `app/Routes/ModulCabang/CabangRoute.py`

```python
# Sebelum:
@role_required("admin", "koordinator", "kader")

# Sesudah (GET /cabang dan GET /cabang/<id_cabang>):
@role_required("admin", "koordinator", "kader", "user")
```

### 8.3 Tambah Role "user" di Gula Darah Chart Lansia

**File:** `app/Routes/ModulLansia/LansiaRoute.py`

```python
# Sebelum:
@role_required("admin", "kader", "koordinator")

# Sesudah:
@role_required("admin", "kader", "koordinator", "user")
```

### 8.4 Standarisasi Role (Opsional)

IbuHamil dan Lansia menggunakan "warga" di middleware, sementara Balita/Remaja/Posbindu menggunakan "user". Standarisasi jadi "user" untuk konsistensi.

---

## 9. Ketentuan Tambahan

1. **Format Response:** Semua response mengikuti format `{ "success": bool, "data": ..., "message": "..." }`. Gunakan `api_client.dart` untuk parse response secara konsisten.

2. **Pagination:** Endpoint list mendukung parameter `?page=1&per_page=10`. Response menyertakan `pagination` object dengan `page`, `per_page`, `total`, `total_pages`.

3. **Error Handling:**
   - 401 → refresh token, jika gagal → logout
   - 403 → tampilkan pesan "Akses ditolak"
   - 404 → tampilkan "Data tidak ditemukan"
   - 422 → tampilkan pesan validasi
   - 429 → tampilkan "Terlalu banyak permintaan"
   - 500 → tampilkan "Terjadi kesalahan server"

4. **Grafik Pertumbuhan Balita:** Gunakan `fl_chart` dengan data dari `/growth-chart`. Tampilkan garis median WHO (-2SD, median, +2SD) sebagai background, dan plot berat/tinggi balita di atasnya.

5. **Download KMS:** PDF di-download via `GET /balita/{id}/download-kms` (response binary). Simpan ke file temporary, buka dengan `flutter_pdfview` atau `open_file`.

6. **Push Notification:** Integrasi Firebase Messaging. Token FCM didaftarkan via `POST /api/v1/alert/fcm-token`. Handle incoming notification untuk menampilkan badge atau dialog.

---

## 10. Referensi

- **Backend API Base URL:** `http://{server-ip}:5000/api/v1`
- **Flutter UI Library:** fl_chart (grafik), provider (state management), dio (HTTP)
- **Dokumentasi Lengkap API:** Lihat Postman collections di folder `postman/` dan `tests/postman/`
