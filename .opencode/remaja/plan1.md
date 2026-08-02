# Plan: Modul Remaja — Fase 1: Home Remaja (Update)

**Status:** Draft (menunggu review)

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

## B. API Endpoint

### B.1 POST /api/v1/auth/login (existing)

Response `data.user.module_id` = `id_remaja`.

### B.2 GET /api/remaja/{{remaja_id}}

**Response:**
```json
{
    "data": {
        "berat_badan": null,
        "created_at": "2026-07-22T12:17:10",
        "hobi": "Melukis",
        "id_remaja": "3031e5ba-fca7-465d-adfb-4c04db5ff44a",
        "jenis_kelamin": "P",
        "kelas": "Kelas 12",
        "nama": "Emma Myers",
        "nik": "0821433725931236",
        "no_hp": "089876543210",
        "prestasi": null,
        "riwayat_anemia": "tidak",
        "saran": null,
        "sekolah": "SMA Sidoarjo",
        "status_aktif": "aktif",
        "status_gizi": null,
        "tanggal_pantau_terakhir": null,
        "tinggi_badan": null,
        "updated_at": "2026-07-22T12:17:10",
        "usia": 24
    },
    "success": true,
    "timestamp": "2026-07-25T05:02:32.118438Z"
}
```

### B.3 GET /api/remaja/{{id_remaja}}/bmi-status

**Response:**
```json
{
    "data": {
        "bmi": 22.3,
        "color": "#43A047",
        "label": "Berat Badan Normal",
        "status_gizi": "berat_badan_normal"
    },
    "success": true,
    "timestamp": "2026-07-25T06:14:51.895522Z"
}
```

### B.4 Model `RemajaDetailResponse`

| Field JSON | Dart | Tipe |
|---|---|---|
| `id_remaja` | `idRemaja` | String |
| `nik` | `nik` | String |
| `nama` | `nama` | String |
| `jenis_kelamin` | `jenisKelamin` | String |
| `tanggal_lahir` | `tanggalLahir` | String? |
| `usia` | `usia` | int |
| `sekolah` | `sekolah` | String? |
| `kelas` | `kelas` | String? |
| `prestasi` | `prestasi` | String? |
| `hobi` | `hobi` | String? |
| `riwayat_anemia` | `riwayatAnemia` | String |
| `status_aktif` | `statusAktif` | String |
| `berat_badan` | `beratBadan` | double? |
| `tinggi_badan` | `tinggiBadan` | double? |
| `tanggal_pantau_terakhir` | `tanggalPantauTerakhir` | String? |
| `no_hp` | `noHp` | String? |
| `created_at` | `createdAt` | String? |
| `updated_at` | `updatedAt` | String? |

### B.5 Model `BmiStatusResponse`

| Field JSON | Dart | Tipe |
|---|---|---|
| `bmi` | `bmi` | double |
| `color` | `color` | String |
| `label` | `label` | String |
| `status_gizi` | `statusGizi` | String |

---

## C. File Baru

| # | File | Isi |
|---|------|-----|
| 1 | `lib/core/models/remaja/bmi_status_model.dart` | `BmiStatusResponse` with fromJson |
| 2 | `lib/core/services/remaja/remaja_service.dart` | Tambah `getBmiStatus()` |
| 3 | `lib/widgets/remaja/status_gizi_badge.dart` | Badge warna status gizi (warna hijau) |
| 4 | `lib/widgets/remaja/home_remaja_header.dart` | Header dengan nama modul & logout |
| 5 | `lib/widgets/remaja/home_remaja_sections.dart` | Section: ProfileSummaryCard (BMI), QuickStatsGrid, AnemiaCard, HobiCard |

## D. File Diubah

| # | File | Perubahan |
|---|------|-----------|
| 6 | `lib/features/pages/remaja/remaja_page.dart` | Revisi: tambah BMI, hobi, ubah layout |

---

## E. Urutan Implementasi

| Step | File | Perubahan |
|------|------|-----------|
| 1 | `lib/core/models/remaja/bmi_status_model.dart` | BUAT `BmiStatusResponse` |
| 2 | `lib/core/services/remaja/remaja_service.dart` | TAMBAH `getBmiStatus()` |
| 3 | `lib/widgets/remaja/status_gizi_badge.dart` | UPDATE warna hijau |
| 4 | `lib/widgets/remaja/home_remaja_header.dart` | UPDATE header dengan nama modul |
| 5 | `lib/widgets/remaja/home_remaja_sections.dart` | UPDATE sections |
| 6 | `lib/features/pages/remaja/remaja_page.dart` | REVISI total |

---

## F. Layout Mobile — Home Remaja (Update)

```
┌──────────────────────────────────┐
│  🔵 AppBar: "Remaja"        [⏻] │  ← Header + Logout
├──────────────────────────────────┤
│  ┌── Section 1: Greeting ─────┐│
│  │  👤 Emma Myers             ││  ← Nama + inisial
│  │  Remaja                    ││  ← Nama Modul
│  └──────────────────────────────┘│
│                                  │
│  ┌── Section 2: BMI Card ──────┐│
│  │  BMI: 22.3                 ││
│  │  Status: Berat Badan Normal  ││
│  └──────────────────────────────┘│
│                                  │
│  ┌── Section 3: Stats ─────────┐│
│  │  Usia: 24 Tahun            ││
│  │  Tinggi: - cm               ││
│  │  Berat: - kg                ││
│  └──────────────────────────────┘│
│                                  │
│  ┌── Section 4: Info ──────────┐│
│  │  Sekolah: SMA Sidoarjo      ││
│  │  Kelas: Kelas 12            ││
│  │  Hobi: Melukis              ││
│  │  Riwayat Anemia: Tidak     ││
│  └──────────────────────────────┘│
│                                  │
│  ┌── Section 5: Footer ────────┐│
│  │  Diperbarui: 22 Jul 2026    ││
│  └──────────────────────────────┘│
└──────────────────────────────────┘
```

---

## G. Standar Implementasi (dari standar-modul.md)

### G.1 Loading
- Gunakan skeleton per widget via `SkeletonWidget`
- Tidak menggunakan `CircularProgressIndicator` fullscreen

### G.2 Cache Lokal
- Gunakan `CacheManager<RemajaDetailResponse>` & `CacheManager<BmiStatusResponse>`
- Prefix: `'remaja'`

### G.3 Offline Banner
- Tampilkan `OfflineBanner` ketika data dari cache

### G.4 Pull-to-refresh
- `RefreshIndicator` di halaman home

### G.5 Stale-while-revalidate
- `staleAfter: Duration(seconds: 30)`
- Silent refresh di background

### G.6 PageView + Bottom Nav
- Tab 0: Beranda (Home)
- Tab 1: Riwayat (placeholder)
- Tab 2: Profil (ProfilePage)

### G.7 Error Handling Detail
- 401 → redirect login + clear cache + logout
- Gunakan `buildModuleError(message, onRetry)` untuk tampilan error dengan tombol "Coba Lagi"
- Pesan ramah via `friendlyError(e)` - contoh: "Sesi Anda telah habis. Silakan login kembali.", "Tidak dapat terhubung ke server. Periksa koinksi internet Anda."
- SnackBar untuk error silent refresh: warna oranye (`#FFFFA726`), floating, durasi 3 detik
- Error screen layout:
  ```dart
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
  ```

### G.8 State Variables
```dart
RemajaDetailResponse? _data;
BmiStatusResponse? _bmiData;
bool _loading = true;
bool _isFromCache = false;
bool _isReconnecting = false;
String? _error;
```

### G.9 Font Size Standard
- Body: 14 (w400/w600/w700)
- Caption: 12 (w400/w600/w700/w800)
- Hero number (usia): 48
- Unit "Tahun" di samping hero: 16

---

## H. Warna Tema Remaja (Hijau)

| Status Gizi | Warna Badge | Warna Background |
|-------------|-------------|------------------|
| `berat_badan_kurang` | `#2196F3` (blue) | `#E3F2FD` |
| `berat_badan_normal` | `#43A047` (green) | `#E8F5E9` |
| `berat_badan_berlebih` | `#FFA726` (orange) | `#FFF3E0` |
| `obesitas_1` | `#EF5350` (red) | `#FFEBEE` |
| `obesitas_2` | `#B71C1C` (dark red) | `#FFEBEE` |
| `null` | `#94A3B8` (slate) | `#F8FAFC` |

Gradient header: hijau (misal: `#43A047` ke `#26A69A`)

---

## H.1 Update Warna Gradient ProfileSummaryCard

Ubah dari gradient biru-ungu menjadi hijau:
```dart
// SEBELUM (biru-ungu):
const LinearGradient(
  colors: [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF6366F1),
  ],
  stops: [0.0, 0.5, 1.0],
)

// SESUDAH (hijau):
const LinearGradient(
  colors: [
    Color(0xFF43A047),  // emerald green
    Color(0xFF26A69A),  // teal
  ],
  stops: [0.0, 1.0],
)
```

Warna teks diubah dari `Color(0xFFBFDBFE)` ke `Color(0xFFE8F5E9)` (light green)

---

## H.2 Integrasi BMI di Home Page

Tambahkan state untuk BMI:
```dart
BmiStatusResponse? _bmiData;
final _bmiCache = CacheManager<BmiStatusResponse>(
  prefix: 'remaja_bmi',
  fromJson: BmiStatusResponse.fromJson,
  toJson: (d) => d.toJson(),
);
```

Load BMI di `_loadData()`:
```dart
final bmiFetched = await _remajaService.getBmiStatus(moduleId);
if (bmiFetched != null) {
  await _bmiCache.save(moduleId, bmiFetched);
  _bmiData = bmiFetched;
}
```

Tampilkan di UI:
```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: StatusGiziInfoCard(
    statusGizi: _bmiData?.statusGizi,
    bmi: _bmiData?.bmi,
    isLoading: _helper.showSkeleton,
  ),
)
```

---

## H.3 Nama Modul di Greeting Section

Update `GreetingSection` untuk menampilkan nama modul:
```dart
// Tambahkan parameter moduleName
final String moduleName;

// Di widget:
Text(
  moduleName,
  style: GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  ),
),
```

---

## I. Checklist Implementasi

- [x] Skeleton loading per widget
- [x] Cache lokal
- [x] Pull-to-refresh
- [x] Offline banner
- [x] 401 → redirect login
- [x] Error message bahasa awam (dengan tombol "Coba Lagi")
- [x] Stale-while-revalidate
- [x] PageView + BottomNav
- [x] Font size standard
- [x] Gradient hijau di ProfileSummaryCard
- [x] BMI endpoint integration
- [x] Nama modul di GreetingSection