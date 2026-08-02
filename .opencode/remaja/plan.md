# Plan: Modul Remaja — Fase 1: Home Remaja

**Status:** ✅ Implementasi Selesai

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

**Catatan:** path `/api/remaja/{id}` (tanpa `/v1/`). `usia` dalam tahun.

### B.3 Model `RemajaDetailResponse`

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
| `status_gizi` | `statusGizi` | String? |
| `berat_badan` | `beratBadan` | double? |
| `tinggi_badan` | `tinggiBadan` | double? |
| `tanggal_pantau_terakhir` | `tanggalPantauTerakhir` | String? |
| `no_hp` | `noHp` | String? |
| `created_at` | `createdAt` | String? |
| `updated_at` | `updatedAt` | String? |

---

## C. File Baru

| # | File | Isi |
|---|------|-----|
| 1 | `lib/core/models/remaja/remaja_model.dart` | `RemajaDetailResponse` with fromJson |
| 2 | `lib/core/services/remaja/remaja_service.dart` | `getRemajaById()` |
| 3 | `lib/widgets/remaja/status_gizi_badge.dart` | Badge warna status gizi (adaptasi untuk Remaja) |
| 4 | `lib/widgets/remaja/home_remaja_header.dart` | Header dengan nama modul & logout |
| 5 | `lib/widgets/remaja/home_remaja_sections.dart` | Section sections: ProfileSummaryCard, QuickStatsGrid, StatusGiziInfoCard, AnemiaCard |
| 6 | `lib/widgets/remaja/home_bottom_nav.dart` | Bottom navigation (reuse dari balita) |

## D. File Diubah

| # | File | Perubahan |
|---|------|-----------|
| 7 | `lib/features/pages/remaja/remaja_page.dart` | Revisi total: dari stub jadi Home Remaja lengkap |

---

## E. Urutan Implementasi

| Step | File | Perubahan |
|------|------|-----------|
| 1 | `lib/core/models/remaja/remaja_model.dart` | BUAT `RemajaDetailResponse` |
| 2 | `lib/core/services/remaja/remaja_service.dart` | BUAT `getRemajaById()` |
| 3 | `lib/widgets/remaja/status_gizi_badge.dart` | BUAT badge widget (adaptasi untuk Remaja) |
| 4 | `lib/widgets/remaja/home_remaja_header.dart` | BUAT header widget |
| 5 | `lib/widgets/remaja/home_remaja_sections.dart` | BUAT section widgets |
| 6 | `lib/widgets/remaja/home_bottom_nav.dart` | BUAT bottom nav (reuse dari balita) |
| 7 | `lib/features/pages/remaja/remaja_page.dart` | REVISI total - implementasi lengkap |

---

## F. Layout Mobile — Home Remaja

```
┌──────────────────────────────────┐
│  🔵 AppBar: "Remaja"        [⏻] │  ← Header + Logout
├──────────────────────────────────┤
│  ┌── Section 1: Greeting ─────┐│
│  │  👤 Emma Myers             ││  ← Nama + inisial
│  └──────────────────────────────┘│
│                                  │
│  ┌── Section 2: Profile ──────┐│
│  │  Usia: 24 Tahun            ││
│  │  Sekolah: SMA Sidoarjo      ││
│  │  Kelas: Kelas 12            ││
│  │  Hobi: Melukis              ││
│  │  Riwayat Anemia: Tidak     ││
│  └──────────────────────────────┘│
│                                  │
│  ┌── Section 3: Status Gizi ───┐│
│  │    ⚪ Status: Belum Ada      ││  ← badge warna (null)
│  └──────────────────────────────┘│
│                                  │
│  ┌── Section 4: Stats ─────────┐│
│  │  Tinggi: - cm               ││
│  │  Berat: - kg                ││
│  │  Terakhir: -                ││
│  └──────────────────────────────┘│
│                                  │
│  ┌── Section 5: Footer ────────┐│
│  │  Diperbarui: 22 Jul 2026    ││
│  └──────────────────────────────┘│
└──────────────────────────────────┘
```

---

## G. Alur Lengkap

### G.1 Login → Home Remaja
```
LoginPage → POST /api/v1/auth/login
  → AuthService simpan moduleId
  → Navigator.pushReplacementNamed('/remaja')
```

### G.2 RemajaPage (StatefulWidget)
```
initState → AuthService.getModuleId()
  → RemajaService.getRemajaById(moduleId)
    → GET /api/remaja/{id}
    → setState() tampilkan data
```

### G.3 Error
```
DioException → catch → SnackBar error
```

---

## H. Standar Implementasi (dari standar-modul.md)

### H.1 Loading
- Gunakan skeleton per widget via `SkeletonWidget`
- Tidak menggunakan `CircularProgressIndicator` fullscreen

### H.2 Cache Lokal
- Gunakan `CacheManager<RemajaDetailResponse>`
- Prefix: `'remaja'`

### H.3 Offline Banner
- Tampilkan `OfflineBanner` ketika data dari cache

### H.4 Pull-to-refresh
- `RefreshIndicator` di halaman home

### H.5 Stale-while-revalidate
- `staleAfter: Duration(seconds: 30)`
- Silent refresh di background

### H.6 PageView + Bottom Nav
- Tab 0: Beranda (Home)
- Tab 1: Riwayat (RiwayatPemantauanPage)
- Tab 2: Profil (ProfilePage)

### H.7 Error Handling Detail
- 401 → redirect login + clear cache + logout
- Pesan ramah: "Sesi Anda telah habis. Silakan login kembali." untuk 401
- Pesan ramah: "Data tidak ditemukan." untuk 404
- Pesan ramah: "Tidak dapat terhubung ke server. Periksa koneksi internet Anda." untuk network error

### H.8 State Variables
```dart
RemajaDetailResponse? _data;
bool _loading = true;
bool _isFromCache = false;
bool _isReconnecting = false;
String? _error;
```

### H.9 Font Size Standard
- Body: 14 (w400/w600/w700) untuk label, value, deskripsi
- Caption: 12 (w400/w600/w700/w800) untuk unit, tag, badge
- Hero number (usia): 48
- Unit "Tahun" di samping hero: 16
- AppBar title, header judul halaman: 15

---

## I. Catatan API Response Mapping

| Field | Keterangan |
|-------|------------|
| `usia` | Dalam tahun (bukan bulan seperti balita) |
| `status_gizi` | Null jika belum ada pemantauan, enum: `berat_badan_kurang`, `berat_badan_normal`, `berat_badan_berlebih`, `obesitas_1`, `obesitas_2` |
| `berat_badan`, `tinggi_badan` | Dari pemantauan terakhir, null jika belum ada |
| `tanggal_pantau_terakhir` | Tanggal pemantauan terakhir, null jika belum ada |
| `riwayat_anemia` | Enum: `ya`, `tidak` |

---

## J. Warna Tema Remaja

Berdasarkan jawaban Anda, warna gradient untuk Remaja akan berbeda dari Balita:

| Status Gizi | Warna Badge | Warna Background |
|-------------|-------------|------------------|
| `berat_badan_kurang` | `#F97316` (orange) | `#FFF7ED` |
| `berat_badan_normal` | `#22C55E` (green) | `#F0FDF4` |
| `berat_badan_berlebih` | `#FBBF24` (amber) | `#FEFCE8` |
| `obesitas_1` | `#EF4444` (red) | `#FEF2F2` |
| `obesitas_2` | `#DC2626` (red dark) | `#FEF2F2` |
| `null` | `#94A3B8` (slate) | `#F8FAFC` |

Gradient header: biru/purple (misal: `#3B82F6` ke `#8B5CF6`)

---

## K. Testing Files

| File Existing | Keterangan |
|---------------|------------|
| `test/services/balita_service_test.dart` | Template untuk `remaja_service_test.dart` |
| `test/widgets/home_balita_sections_test.dart` | Template untuk `home_remaja_sections_test.dart` |

Files baru yang perlu dibuat:
- `test/services/remaja_service_test.dart`
- `test/widgets/remaja/home_remaja_sections_test.dart`

---

## L. Checklist Implementasi (dari standar-modul.md)

- [x] Skeleton loading per widget (no `CircularProgressIndicator`)
- [x] `CacheManager<T>` untuk persist data lokal
- [x] Pull-to-refresh
- [x] Offline banner dengan tombol hubungkan
- [x] 401 → redirect login
- [x] Error message bahasa awam
- [x] Gunakan `ModulePageMixin<T>` atau patuhi state convention manual
- [x] Stale-while-revalidate dengan `staleAfter: Duration(seconds: 30)`
- [x] `IndexedStack`/`PageView` untuk navigasi tab dalam satu halaman
- [x] Font size standard (14 body, 12 caption, hero 48)