# Plan: Modul Balita — Fase 2: Riwayat Pemeriksaan Balita

**Status:** ✅ Disetujui

---

## A. Aturan & Referensi

| Aturan | Detail |
|--------|--------|
| **Arsitektur** | Feature-First: Page → Service → ApiClient → Backend |
| **State** | Local state di `StatefulWidget` + `ModulePageHelper<T>` |
| **Font** | Google Fonts Plus Jakarta Sans |
| **Theme** | `AppColors`, `AppTheme` |
| **Package** | `package:frontend_posyandu` |
| **Naming** | file: `snake_case`, class: `PascalCase`, var/func: `camelCase` |
| **Import** | `package:` imports |
| **Simpan data** | `CacheManager<T>` + `SharedPreferences` |
| **Standar Modul** | Lihat `standar-modul.md` |

---

## B. Ringkasan Perubahan File

### File Baru (4 file)

| # | File | Isi |
|---|------|------|
| 1 | `lib/core/models/balita/pemantauan_balita_model.dart` | Model `PemantauanBalitaItem`, `PaginationMeta`, `PemantauanListResponse` |
| 2 | `lib/core/services/balita/pemantauan_balita_service.dart` | Service `getList(idBalita, page, limit)` → `PemantauanListResponse` |
| 3 | `lib/widgets/balita/pemantauan_card.dart` | Widget card item riwayat sesuai Figma |
| 4 | `lib/features/pages/balita/riwayat_pemantauan_page.dart` | Halaman Riwayat dengan tab + list + muat lainnya |

### File Diubah (3 file)

| # | File | Perubahan |
|---|------|-----------|
| 5 | `lib/features/pages/balita/balita_page.dart` | Bottom nav tab "Riwayat" → navigasi ke `RiwayatPemantauanPage` |
| 6 | `lib/features/pages/balita/riwayat_pemantauan_page.dart` | Tambah constructor injection `pemantauanService` & `authService` untuk testing |
| 7 | `lib/widgets/balita/status_gizi_badge.dart` | Tambah `gizi_*` prefix handling (`gizi_baik`, `gizi_kurang`, `gizi_buruk`) |

---

## C. API Endpoint

### C.1 GET `/api/balita/{balita_id}/pemantauan?page=1&limit=5`

**Response:**
```json
{
    "data": [
        {
            "berat": 12.0,
            "id_kader": "8a291ec0-...",
            "id_pantau": "0ec0f07c-...",
            "imunisasi": null,
            "lingkar_kepala": 48.0,
            "lingkar_lengan": null,
            "nama_kader": "Zidan Kusuma",
            "no": 1,
            "status_gizi": "gizi_kurang",
            "tanggal_pantau": "2026-07-18",
            "tinggi": 80.0,
            "usia_bulan": 34,
            "vitamin_a": "ya"
        }
    ],
    "pagination": {
        "limit": 5,
        "page": 1,
        "total": 14,
        "total_pages": 3
    },
    "success": true,
    "timestamp": "..."
}
```

### C.2 Model — `PemantauanListResponse`

| JSON Field | Dart Field | Tipe |
|---|---|---|
| `data` | `data` | `List<PemantauanBalitaItem>` |
| `pagination` | `pagination` | `PaginationMeta` |
| `success` | `success` | `bool` |

### C.3 Model — `PemantauanBalitaItem`

| JSON Field | Dart Field | Tipe |
|---|---|---|
| `id_pantau` | `idPantau` | `String` |
| `id_kader` | `idKader` | `String` |
| `nama_kader` | `namaKader` | `String` |
| `no` | `no` | `int` |
| `tanggal_pantau` | `tanggalPantau` | `String` |
| `usia_bulan` | `usiaBulan` | `int` |
| `berat` | `berat` | `double` |
| `tinggi` | `tinggi` | `double` |
| `lingkar_kepala` | `lingkarKepala` | `double?` |
| `lingkar_lengan` | `lingkarLengan` | `double?` |
| `status_gizi` | `statusGizi` | `String` |
| `imunisasi` | `imunisasi` | `String?` |
| `vitamin_a` | `vitaminA` | `String?` |

### C.4 Model — `PaginationMeta`

| JSON Field | Dart Field | Tipe |
|---|---|---|
| `page` | `page` | `int` |
| `limit` | `limit` | `int` |
| `total` | `total` | `int` |
| `total_pages` | `totalPages` | `int` |

---

## D. Layout Card (Figma Reference)

```
┌──────────────────────────────────┐  ← white bg, corner 16, shadow
│  ┌──────┬───────────────────┬──┐ │
│  │  34  │ 18 Jul 2026  34 bln │ >│ │  ← row1: SPACE_BETWEEN
│  │ bln  ├───────────────────┤  │ │
│  │ 🟠   │12 kg│80 cm│48cm│✅│  │ │  ← row2: items + badge gizi
│  └──────┴───────────────────┴──┘ │
│  padding: 16                     │
└──────────────────────────────────┘
```

### D.1 Detail Visual Card

| Bagian | Detail |
|--------|--------|
| **Container** | White `#ffffff`, corner radius `16`, border `#00000014` (8% opacity), shadow 2 layer |
| **Padding dalam** | 16px all sides |
| **Avatar 🟠** | Circle 40x40, bg `#fff7ed`. Atas: `usiaBulan` (ExtraBold 12px `#f97316`?), Bawah: `"bln"` (SemiBold 9px `#f9731699`) |
| **Baris Atas** | Kiri: `tanggalPantau` format "18 Jul 2026". Kanan: `usiaBulan + " bln"`. Layout: `SPACE_BETWEEN` |
| **Baris Bawah** | Items dengan `gap 16`: `berat kg`, `tinggi cm`, `lingkar_kepala cm`, `StatusGiziBadge` |
| **Ikon Kanan** | Chevron arrow `>` untuk indikasi dapat diklik |

### D.2 Warna Status Gizi

| Status | Label | Color |
|--------|-------|-------|
| `gizi_baik` | Baik | `#43A047` hijau |
| `gizi_kurang` | Kurang | `#FFA726` oranye |
| `gizi_buruk` | Buruk | `#EF5350` merah |
| `stunting` | Stunting | `#B71C1C` merah gelap |

---

## E. Tab System

| Tab | Label | Warna | Status |
|-----|-------|-------|--------|
| **Pertumbuhan** | `Pertumbuhan` | `#f97316` orange (active) | ✅ List riwayat berjalan |
| **Imunisasi** | `Imunisasi` | `#64748b` gray (inactive) | ⏸ Placeholder |
| **Grafik** | `Grafik` | `#64748b` gray (inactive) | ⏸ Nanti link ke `GrowthChartPage` |

---

## F. Urutan Implementasi

| Step | File | Tindakan |
|------|------|----------|
| 1 | `lib/core/models/balita/pemantauan_balita_model.dart` | BUAT model `PemantauanBalitaItem`, `PaginationMeta`, `PemantauanListResponse` |
| 2 | `lib/core/services/balita/pemantauan_balita_service.dart` | BUAT service `getList()` |
| 3 | `lib/widgets/balita/pemantauan_card.dart` | BUAT card widget sesuai Figma |
| 4 | `lib/features/pages/balita/riwayat_pemantauan_page.dart` | BUAT halaman Riwayat lengkap |
| 5 | `lib/features/pages/balita/balita_page.dart` | UBAH: bottom nav Riwayat → navigasi ke halaman baru |

---

## G. Halaman `RiwayatPemantauanPage` — Spesifikasi

### G.1 State Variables
```dart
List<PemantauanBalitaItem> _items = [];
PaginationMeta? _pagination;
int _currentPage = 1;
bool _loading = true;
bool _loadingMore = false;
bool _isFromCache = false;
bool _isReconnecting = false;
String? _error;
int _selectedTab = 0;  // 0=Pertumbuhan, 1=Imunisasi, 2=Grafik
```

### G.2 Alur Load Data
```
initState / pull-to-refresh
  → PemantauanBalitaService.getList(idBalita, page=1, limit=5)
    → sukses: simpan items + pagination, simpan cache
    → gagal + cache ada: tampilkan cache + offline banner
    → gagal + cache kosong: tampilkan error screen
```

### G.3 Alur Muat Lainnya
```
tombol "Muat Lainnya" diklik
  → set _loadingMore = true
  → PemantauanBalitaService.getList(idBalita, page=_currentPage+1, limit=5)
    → sukses: append items, update pagination, _currentPage++
    → gagal: snackbar error
  → set _loadingMore = false
```

### G.4 On Tap Card
Navigasi ke halaman detail pemantauan (belum dibahas, placeholder untuk sekarang).

---

## H. Testing

### H.1 Framework
- `flutter_test` (SDK) — tanpa `mockito`/`mocktail`
- Mocking manual: `_mockDio()`, stub class `_MockPemantauanService`, `_MockAuthService`
- Storage: `FlutterSecureStorage.setMockInitialValues({})` + `SharedPreferences.setMockInitialValues({})`

### H.2 File Test Baru (3 file)

| # | File | Test Coverage |
|---|------|---------------|
| 1 | `test/core/services/balita/pemantauan_balita_service_test.dart` | `getList` success (5 test), query params, 404 error, 401 error, network error |
| 2 | `test/widgets/balita/pemantauan_card_test.dart` | Render semua field, null lingkarKepala, avatar usia+bln, onTap, chevron icon |
| 3 | `test/features/pages/balita/riwayat_pemantauan_page_test.dart` | Skeleton→data, error+retry, cache+offline banner, tab placeholder, pagination hide, moduleId null |

### H.3 Jumlah Test
- **Service**: 5 test ✅
- **Widget**: 5 test ✅  
- **Page**: 7 test ✅
- **Total**: **17 test — all passed**

---

## I. Stale-While-Revalidate & IndexedStack

### I.1 Perubahan `module_page_mixin.dart`

| Field/Method | Tipe | Kegunaan |
|---|---|---|
| `lastFetchTime` | `DateTime?` | Waktu fetch terakhir, di-set di `onSuccess()` |
| `isStale(Duration)` | `bool` | `true` jika `lastFetchTime == null` atau sudah lewat threshold |

| Parameter `loadModuleData` | Tipe | Kegunaan |
|---|---|---|
| `staleAfter` | `Duration?` | Jika ada data & belum basi → skip fetch. Jika ada data & basi → silent refresh (tanpa skeleton). `null` = force fetch. |

### I.2 Perubahan `balita_page.dart`

- Body diubah jadi `IndexedStack`:
  - index 0 = home content (GreetingSection + dll)
  - index 1 = `RiwayatPemantauanPage(embedded: true)`
- Header dinamis: index 0 → `HomeBalitaHeader`, index 1 → header custom dengan back arrow + "Riwayat Pemeriksaan"
- Bottom nav `onTap` untuk index 1: `setState(() => _bottomNavIndex = 1)` (tanpa Navigator.push)
- `loadModuleData` dipanggil dengan `staleAfter: const Duration(seconds: 30)`

### I.3 Perubahan `riwayat_pemantauan_page.dart`

- Tambah param `embedded` (default false):
  - `true`: render body langsung (tanpa Scaffold, AppBar, BottomNav)
  - `false`: render seperti sekarang (Scaffold + AppBar + BottomNav)
- Tambah `_lastFetchTime` + stale check di `_loadData()`
- Tambah `WidgetsBindingObserver` untuk foreground refresh (hanya jika `!embedded`)
- Silent refresh: jika data basi, fetch di background tanpa skeleton/ganti data

### I.4 Alur Data

```
Tab Beranda → Tab Riwayat (IndexedStack, view tetap alive)
  ├── Pertama kali (belum pernah fetch)
  │     └── fetch API → skeleton loading
  ├── Data masih segar (< 30 detik)
  │     └── tampilkan langsung (skip fetch)
  └── Data sudah basi (≥ 30 detik)
        └── tampilkan data lama → silent fetch background
              ├── sukses: update UI
              └── gagal: snackbar, tetap pakai data lama
```

---

## J. Standar Modul Checklist

- [x] Skeleton loading per widget (no `CircularProgressIndicator`)
- [x] `CacheManager<PemantauanListResponse>` untuk persist data lokal
- [x] Pull-to-refresh
- [x] Offline banner dengan tombol hubungkan
- [x] 401 → redirect login
- [x] Error message bahasa awam
- [x] State convention manual
- [x] Stale-while-revalidate (`staleAfter: 30s`) di kedua view
- [x] `IndexedStack` untuk navigasi tab tanpa recreate