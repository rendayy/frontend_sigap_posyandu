# Plan: Modul Profile — Profil Warga (Lihat & Edit)

**Status:** 📝 **Rencana** — Menunggu persetujuan untuk implementasi

---

## A. Aturan & Referensi

| Aturan | Detail |
|--------|--------|
| **Arsitektur** | Feature-First: Page → Service → ApiClient → Backend |
| **State** | Local state di `StatefulWidget` + `CacheManager<T>` + stale-while-revalidate |
| **Font** | Google Fonts Plus Jakarta Sans (dilarang ukuran 9,10,11,13 — wajib 12/caption atau 14/body) |
| **Package** | `package:frontend_posyandu` |
| **Naming** | file: `snake_case`, class: `PascalCase`, var/func: `camelCase` |
| **Import** | `package:` imports |
| **Simpan data** | `CacheManager<T>` + `SharedPreferences` |
| **Navigasi** | `Navigator.pushNamed` untuk edit profile; profile sebagai tab dalam PageView (swipeable) |
| **Standar Modul** | Lihat `standar-modul.md` (skeleton, cache, offline banner, pull-to-refresh, 401 redirect, error handling) |
| **Font Size Standar** | Body = 14, Caption = 12. Pengecualian: 16 untuk nama, 15 untuk AppBar title (`standar-modul.md#10`) |
| **Referensi Model** | `AnggotaKeluargaModel.py` + `KeluargaModel.py` — mapping field dari backend |
| **Referensi Service** | `balita_service.dart` — pola error handling (ServerException, NetworkException, DioException) |

---

## B. API Endpoint

### B.1 Login (existing — sudah berfungsi)

POST `/api/v1/auth/login` — sudah diintegrasikan di `auth_service.dart` + `api_client.dart` (interceptor JWT + refresh token otomatis).

`id_anggota` didapat dari `g.id_anggota` (diekstrak dari token JWT via Keycloak oleh backend), dikembalikan di response login sebagai `user.id_anggota`.

### B.2 GET `/api/v1/citizens/me` — Ambil Profil Sendiri

**Method:** GET  
**Auth:** `@jwt_required` (tanpa role restriction — semua role bisa)  
**Service baru:** `CitizenService.getMyProfile()` → `Future<ProfileResponse>`  
**Model baru:** `ProfileResponse` + `KeluargaInfo`  

**Response JSON (dari backend `CitizenQueryService.GetCitizenProfile`):**
```json
{
    "success": true,
    "data": {
        "id_anggota": "2d4ecbfe-b33e-404e-b580-339d7ee8fe54",
        "nik": "0821433725931236",
        "nama": "Emma Elizabeth Myers",
        "no_hp": "",
        "tempat_lahir": "Sidoarjo",
        "tanggal_lahir": "2002-04-02",
        "jenis_kelamin": "P",
        "golongan_darah": null,
        "hubungan_keluarga": "istri",
        "kategori_anggota": "remaja",
        "status_aktif": "aktif",
        "status_kesehatan": null,
        "catatan_khusus": null,
        "roles": ["user"],
        "keluarga": {
            "id_keluarga": "35483e13-b4d2-4556-b19a-69a5fdbafed5",
            "no_kk": "0821433725931234",
            "alamat": "JL. Raya",
            "rt": "1",
            "rw": "1",
            "dusun": "Ngaban",
            "cabang": null
        },
        "created_at": "2026-07-22T12:17:10",
        "updated_at": "2026-07-23T02:58:56"
    },
    "message": "Berhasil mendapatkan profil citizen",
    "timestamp": "2026-07-24T22:59:17.430959Z"
}
```

**Mapping field ke tampilan:**

| Section | Field API | Label Tampilan |
|---------|-----------|----------------|
| **Header** | `nama` | Nama lengkap |
| | `nik` | NIK |
| | `kategori_anggota` + `tanggal_lahir` | Kategori & Usia (dihitung dari tanggal_lahir) |
| **Info Pribadi** | `tempat_lahir` | Tempat Lahir |
| | `tanggal_lahir` | Tanggal Lahir |
| | `jenis_kelamin` | Jenis Kelamin (L → Laki-laki, P → Perempuan) |
| | `golongan_darah` | Golongan Darah |
| | `hubungan_keluarga` | Hubungan Keluarga |
| | `no_hp` | No. Telepon |
| | `kategori_anggota` | Kategori Anggota |
| **Info Keluarga** | `keluarga.no_kk` | No. KK |
| | `keluarga.alamat` | Alamat |
| | `keluarga.rt` | RT |
| | `keluarga.rw` | RW |
| | `keluarga.dusun` | Dusun |
| | `keluarga.cabang.nama_posyandu` | Cabang Posyandu (jika ada) |

### B.3 PUT `/api/v1/citizens/me` — Update Profil Sendiri

**Method:** PUT  
**Auth:** `@jwt_required`  
**Service baru:** `CitizenService.updateMyProfile({nama, no_hp})` → `Future<void>`  

**Request Body:**
```json
{
  "nama": "Emma Myers",
  "no_hp": "089876543210"
}
```

**Response:**
```json
{
    "success": true,
    "data": {},
    "message": "Profil berhasil diperbarui.",
    "timestamp": "2026-07-24T23:04:07.982834Z"
}
```

**Catatan dari backend (`CitizenManagementService.py:44`):** Hanya field `nama` dan `no_hp` yang bisa diubah oleh user sendiri. Field lain diabaikan.

---

## C. Analisis Figma — Node `1:7529` "Profile"

### C.1 Struktur Layout Figma (dari Figma API)

```
┌─── AppBar ─────────────────────────────────┐
│ "Profil Saya"                              │  ← title
├─── Avatar & Identitas ─────────────────────┤
│            ┌──────┐                        │
│            │  DP  │  ← CircleAvatar (inisial)
│            └──────┘                        │
│         Dinda Putri                        │  ← nama (16px, w800)
│    NIK: 3271012808080004                   │  ← caption
│    Remaja - 16 Tahun                       │  ← kategori & usia
├─── Menu Items ─────────────────────────────┤
│  > Edit Profil                             │  → /edit-profile
│  > Keluar                                  │  → logout with confirmation
├─── Footer ─────────────────────────────────┤
│  SIGAP Posyandu Warga v1.0.0              │
└────────────────────────────────────────────┘
```

### C.2 Perbedaan Figma vs Implementasi Aktual

| Aspek | Figma | Implementasi |
|-------|-------|-------------|
| **Stats cards** (BMI, Status Gizi, Kegiatan) | Ada (spesifik remaja) | **Tidak dipakai** — terlalu spesifik per modul. Akan dibuat terpisah per modul nanti |
| **Info detail spesifik remaja** (Sekolah, Kelas, Email) | Ada | **Tidak dipakai** — spesifik remaja |
| **Field ditampilkan** | Nama, NIK, Kategori+Usia, TL, GolDar, Sekolah, Kelas, No.Telp, Email | Nama, NIK, Kategori+Usia, TempatLahir, TglLahir, JenisKelamin, GolDar, HubunganKeluarga, No.HP, Alamat, RT, RW, Dusun, No.KK, Cabang |
| **Menu item "Ganti Kata Sandi"** | Ada | **Ditunda** — akan dikerjakan terpisah |
| **Menu item "Pusat Bantuan"** | Ada | **Tidak dibuat** — tidak diperlukan |
| **Logout** | Menu item "Keluar" | Diubah jadi menu item (bukan button merah di bawah) |
| **Bottom Nav** | Beranda \| Riwayat \| Jadwal \| Notifikasi \| Profil | Profile sebagai tab dalam PageView (swipeable) |

### C.3 Layout Akhir Profile Page (Hasil Diskusi)

```
┌─── AppBar ─────────────────────────────────┐
│ "Profil Saya"                              │
├─── Avatar & Identitas ─────────────────────┤
│            ┌──────┐                        │
│            │  E   │  ← CircleAvatar (inisial nama)
│            └──────┘                        │
│         Emma Elizabeth Myers               │  ← nama (16px, w800)
│    NIK: 0821433725931236                   │  ← caption
│    Remaja                                  │  ← kategori
├─── Info Pribadi ───────────────────────────┤
│  Tempat Lahir       Sidoarjo              │
│  Tanggal Lahir      2 April 2002          │
│  Jenis Kelamin      Perempuan             │
│  Golongan Darah     -                     │
│  Hubungan Keluarga  Istri                 │
│  No. Telepon        -                     │
│  Kategori Anggota   Remaja                │
├─── Info Keluarga ──────────────────────────┤
│  No. KK             0821433725931234      │
│  Alamat             JL. Raya              │
│  RT                1                      │
│  RW                1                      │
│  Dusun             Ngaban                 │
│  Cabang            -                      │
├─── Menu Items ─────────────────────────────┤
│  > Edit Profil                             │  → Navigator.pushNamed('/edit-profile')
│  > Keluar                                  │  → dialog konfirmasi + logout + redirect /login
├─── Footer ─────────────────────────────────┤
│  SIGAP Posyandu Warga v1.0.0              │
└────────────────────────────────────────────┘
```

---

## D. Ringkasan Perubahan File

### File Baru

| # | File | Isi |
|---|------|------|
| 1 | `lib/core/models/citizen/citizen_model.dart` | **Model `ProfileResponse`** — mapping response `GET /api/v1/citizens/me`. Field: `idAnggota`, `nik`, `nama`, `noHp`, `tempatLahir`, `tanggalLahir`, `jenisKelamin`, `golonganDarah`, `hubunganKeluarga`, `kategoriAnggota`, `statusAktif`, `statusKesehatan`, `catatanKhusus`, `roles`, `keluarga`, `createdAt`, `updatedAt`. **Model `KeluargaInfo`** — nested: `idKeluarga`, `noKk`, `alamat`, `rt`, `rw`, `dusun`, `cabang`. Dilengkapi `fromJson()` + `toJson()` untuk cache. |
| 2 | `lib/core/services/citizen/citizen_service.dart` | **Service `CitizenService`** — method: `getMyProfile()` (GET → `ProfileResponse`), `updateMyProfile(String nama, String noHp)` (PUT → void). Pattern error handling identik dengan `BalitaService` (`ServerException`, `NetworkException`, `DioException`). |
| 3 | `test/core/services/citizen/citizen_service_test.dart` | **Unit test `CitizenService`** — minimal 4 test: success get, success update, error 401 (session expired), error network. |
| 4 | `test/features/pages/profil/profile_page_test.dart` | **Widget test `ProfilePage`** — minimal 5 test: render skeleton saat loading, render data lengkap, pull-to-refresh, error + cache fallback, logout confirm. |
| 5 | `test/features/pages/profil/edit_profile_page_test.dart` | **Widget test `EditProfilePage`** — minimal 4 test: render form, validasi nama kosong, submit sukses (pop + snackbar), submit error. |

### File Diubah

| # | File | Perubahan |
|---|------|-----------|
| 1 | `lib/features/pages/profil/profile_page.dart` | **REFACTOR TOTAL** — ganti dari baca `AuthService` (token storage — 6 field) jadi panggil `CitizenService.getMyProfile()` via `loadModuleData()`. Implementasi: skeleton loading per section, stale-while-revalidate (30 detik), pull-to-refresh, cache via `CacheManager<ProfileResponse>`, offline banner, error screen. Tampilkan semua field sesuai mapping di C.3. Perbaiki font size (13 → 14/12). Ganti layout logout dari button merah jadi menu item "Keluar" dengan ikon. Tambah menu item "Edit Profil" → navigasi ke `/edit-profile`. |
| 2 | `lib/features/pages/profil/edit_profile_page.dart` | **BUAT DARI NOL** — halaman form dengan 2 field (`nama`, `no_hp`). Validasi: nama required max 100, no_hp optional max 15 digit. Submit panggil `CitizenService.updateMyProfile()`. Loading state di tombol simpan. Snackbar sukses → pop back. Error handling standar (401 redirect, snackbar error). |
| 3 | `lib/router.dart` | **TAMBAH ROUTE** — `/edit-profile` → `EditProfilePage`. |

### File Tidak Diubah (cukup referensi)

| File | Alasan |
|------|--------|
| `lib/core/services/auth/auth_service.dart` | Tidak perlu diubah — login flow sudah benar |
| `lib/core/services/auth/token_service.dart` | Tidak perlu diubah — token storage sudah benar |
| `lib/core/api/api_client.dart` | Tidak perlu diubah — interceptor JWT + refresh sudah benar |
| `lib/config.dart` | Tidak perlu diubah |
| `pubspec.yaml` | Tidak perlu tambah dependensi — `dio`, `shared_preferences`, `flutter_secure_storage`, `google_fonts` sudah ada |

---

## E. Analisis File Test yang Ada

### E.1 Test Existing yang Relevan

| File Test | Isi | Relevansi |
|-----------|-----|-----------|
| `test/core/api/api_client_test.dart` | ✅ Test interceptor JWT + refresh token | **Pola manual mock (`_RequestCapture`)** — akan diikuti di test baru |
| `test/core/services/auth/auth_service_test.dart` | ✅ Test login flow (mock LoginService + TokenService) | Referensi cara mock service |
| `test/core/services/balita/balita_service_test.dart` | ✅ Test BalitaService (getBalitaById, getGrowthChart) | **Pola utama** — akan ditiru persis untuk `CitizenService` test |
| `test/core/utils/cache_manager_test.dart` | ✅ Test CacheManager | Tidak perlu diubah |
| `test/core/utils/module_page_mixin_test.dart` | ✅ Test loadModuleData | Tidak perlu diubah |

### E.2 Test Baru yang Diperlukan

| File Test | Alasan |
|-----------|--------|
| `test/core/services/citizen/citizen_service_test.dart` | **WAJIB BARU** — belum ada test untuk service citizen. Pattern: manual mock Dio via `_RequestCapture` (sama seperti `api_client_test.dart`) |
| `test/features/pages/profil/profile_page_test.dart` | **WAJIB BARU** — belum ada test untuk profile page. Test skeleton, render data, pull-to-refresh, error+cache, logout |
| `test/features/pages/profil/edit_profile_page_test.dart` | **WAJIB BARU** — halaman baru. Test render form, validasi, submit sukses, submit error |

### E.3 Mock Strategy

Mengikuti pattern existing di `api_client_test.dart` — **manual mock tanpa mockito** (mockito tidak ada di pubspec.yaml):

```dart
class _MockDio {
  // Gunakan Dio mock dengan custom interceptor
}

class _MockCitizenService implements CitizenService {
  // Override method untuk test
}
```

---

## H. Stale-While-Revalidate (Auto-refresh)

Mengacu pada `standar-modul.md#8` — setiap halaman dengan data dinamis WAJIB menerapkan stale-while-revalidate.

### H.1 Prinsip

```
[Profile Page]
  ├── Data belum pernah di-fetch        → fetch (tampilkan skeleton)
  ├── Data masih segar (< 30 detik)     → tampilkan langsung (skip fetch)
  ├── Data sudah basi (≥ 30 detik)      → tampilkan data lama + silent fetch di background
  │     ├── sukses: update UI tanpa skeleton
  │     └── gagal: tetap pakai data lama, snackbar error
  └── Pull-to-refresh                   → force fetch (abaikan stale)
```

### H.2 Implementasi di Profile Page

Menggunakan `loadModuleData()` dari `core/utils/module_page_mixin.dart` dengan `staleAfter: const Duration(seconds: 30)`:

```dart
final _helper = ModulePageHelper<ProfileResponse>();
final _cache = CacheManager<ProfileResponse>(
  prefix: 'profile',
  fromJson: ProfileResponse.fromJson,
  toJson: (d) => d.toJson(),
);

Future<void> _loadData({bool force = false}) async {
  await loadModuleData(
    helper: _helper,
    getModuleId: () async => (await AuthService().getUserInfo())?.idAnggota,
    fetchFromApi: (_) => CitizenService().getMyProfile(),
    cacheManager: _cache,
    setState: () => setState(() {}),
    context: context,
    staleAfter: force ? null : const Duration(seconds: 30),
  );
}
```

### H.3 Foreground Refresh via `WidgetsBindingObserver`

Profile Page adalah halaman standalone. WAJIB tambah observer agar refresh saat app kembali ke foreground:

```dart
class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _silentRefreshIfStale();
    }
  }
}
```

### H.4 Refresh Saat Kembali dari Edit Profile

Setelah update profil sukses dan `Navigator.pop` kembali ke Profile Page, paksa re-fetch dengan `_loadData(force: true)`.

Implementasi: `Navigator.pushNamed(context, '/edit-profile').then((_) => _loadData(force: true))`

### H.5 Stale Threshold

Default: `Duration(seconds: 30)` — konsisten dengan modul lain.

---

## I. Profile sebagai Tab Swipeable (PageView)

Berdasarkan arahan, Profile harus bisa di-swipe seperti tab Beranda ↔ Riwayat di modul Balita.

### I.1 Arsitektur

Profile akan menjadi bagian dari `PageView` di halaman utama setiap modul, dengan urutan:

| Index | Tab | Keterangan |
|-------|-----|------------|
| 0 | Beranda | Halaman utama modul |
| 1 | Riwayat | Riwayat data modul |
| 2 | Profil | Profile warga (swipeable) |

### I.2 Pattern PageView (`standar-modul.md#3a`)

```dart
PageView(
  controller: _pageController,
  physics: const AlwaysScrollableScrollPhysics(),
  onPageChanged: (index) => setState(() => _bottomNavIndex = index),
  children: [
    _buildBeranda(),
    _buildRiwayat(),
    _buildProfile(),
  ],
)
```

### I.3 Catatan Integrasi

Integrasi Profile ke dalam PageView setiap modul akan dilakukan sebagai **fase terpisah** (fase integrasi) — karena membutuhkan perubahan di setiap file modul page (Balita, Remaja, Ibu Hamil, Lansia, Posbindu). Pada fase ini, Profile Page tetap bisa diakses via `Navigator.pushNamed(context, '/profile')`.

---

## F. Urutan Implementasi

| Step | File | Tindakan | Status |
|------|------|----------|--------|
| **1** | `lib/core/models/citizen/citizen_model.dart` | **BARU**: model `ProfileResponse` + `KeluargaInfo` dengan `fromJson()` + `toJson()` | 📝 |
| **2** | `lib/core/services/citizen/citizen_service.dart` | **BARU**: service `getMyProfile()` + `updateMyProfile()` | 📝 |
| **3** | `test/core/services/citizen/citizen_service_test.dart` | **BARU**: unit test service | 📝 |
| **4** | `lib/features/pages/profil/profile_page.dart` | **REFACTOR**: panggil citizen API, skeleton, cache, pull-to-refresh, offline banner, font size fix, layout menu (Edit Profil + Keluar) | 📝 |
| **5** | `lib/features/pages/profil/edit_profile_page.dart` | **BARU**: form edit nama & no_hp | 📝 |
| **6** | `lib/router.dart` | **UBAH**: tambah route `/edit-profile` | 📝 |
| **7** | `test/features/pages/profil/profile_page_test.dart` | **BARU**: widget test profile page | 📝 |
| **8** | `test/features/pages/profil/edit_profile_page_test.dart` | **BARU**: widget test edit profile page | 📝 |

---

## G. Catatan Tambahan

### G.1 Circular Dependency Warning
`profile_page.dart` saat ini meng-import `auth_service.dart` untuk logout. Setelah refactor, ia akan meng-import `citizen_service.dart` juga. Tidak ada circular dependency.

### G.2 Perhitungan Usia dari `tanggal_lahir`
Usia dihitung dari `tanggal_lahir` response API. Untuk kategori balita: dalam bulan. Untuk kategori lain: dalam tahun. Contoh:
- `kategori_anggota == "balita"` → "Balita - 24 Bulan"
- `kategori_anggota == "remaja"` → "Remaja - 16 Tahun"

### G.3 Format Tanggal
`tanggal_lahir` dari API format ISO `"2002-04-02"`. Tampilan: `"2 April 2002"` (menggunakan package `intl` — sudah di pubspec.yaml).

### G.4 Label Jenis Kelamin
`jenis_kelamin = "L"` → "Laki-laki", `jenis_kelamin = "P"` → "Perempuan".

### G.5 Label Hubungan Keluarga
`hubungan_keluarga = "kepala"` → "Kepala Keluarga", `"istri"` → "Istri", `"anak"` → "Anak", `"lainnya"` → "Lainnya".

### G.6 Profile sebagai Tab Swipeable (PageView)
Profile akan menjadi bagian dari PageView di halaman utama masing-masing modul. Lihat **Section I** untuk detail arsitektur dan rencana integrasi. Fase ini fokus pada halaman Profile standalone dulu.
