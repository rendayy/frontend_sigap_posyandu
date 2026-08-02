# Plan: Modul Remaja — Fase 2: Riwayat Pemantauan Remaja

**Status:** Draft (menunggu review)

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
|---|------|-----|
| 1 | `lib/core/models/remaja/pemantauan_remaja_model.dart` | Model `PemantauanRemajaItem`, `PaginationMeta`, `PemantauanRemajaListResponse` |
| 2 | `lib/core/services/remaja/pemantauan_remaja_service.dart` | Service `getList(idRemaja, page, limit)` → `PemantauanRemajaListResponse` |
| 3 | `lib/widgets/remaja/pemantauan_remaja_card.dart` | Widget card item riwayat sesuai Figma |
| 4 | `lib/features/pages/remaja/riwayat_pemantauan_page.dart` | Halaman Riwayat dengan tab + list + muat lainnya |

### File Diubah (2 file)

| # | File | Perubahan |
|---|------|-----------|
| 5 | `lib/features/pages/remaja/remaja_page.dart` | Ganti placeholder "Riwayat Pemantauan (dalam pengembangan)" dengan `RiwayatPemantauanPage(embedded: true)` |
| 6 | `lib/widgets/remaja/status_gizi_badge.dart` | Tambah handling untuk status gizi remaja (`berat_badan_*`, `obesitas_*`) |

---

## C. API Endpoint

### C.1 GET `/api/remaja/{{id_remaja}}/pemantauan?page=1&limit=10`

**Response:**
```json
{
    "audit": {
        "alert_created": false,
        "recorded": true
    },
    "data": [
        {
            "berat_badan": 100.0,
            "bmi": 39.1,
            "created_at": "2026-07-20T01:42:05",
            "distol": 72,
            "gula_darah": 98,
            "id_cabang": "7a072f71-eae4-4463-9332-23922de88c1d",
            "id_kader": "8a291ec0-00a6-4969-a017-c044ab693dd3",
            "id_pantau_remaja": "1e187ccd-d208-4ca4-8951-5d5c83d51b37",
            "id_remaja": "13cafd35-c105-4f82-8642-6bb556fd1d7c",
            "keluhan": "Tidak ada keluhan",
            "nama_kader": "Zidan Kusuma",
            "nama_posyandu": "Posyandu Melati",
            "saran": "Pertahankan pola makan sehat",
            "sistol": 112,
            "status_gizi": "obesitas_2",
            "tanggal_periksa": "2026-06-25",
            "tinggi_badan": 160.0,
            "updated_at": "2026-07-20T03:45:09"
        }
    ],
    "pagination": {
        "page": 1,
        "limit": 10,
        "total": 1,
        "total_pages": 1
    },
    "success": true,
    "timestamp": "2026-07-25T23:39:24.286567Z"
}
```

### C.2 Model — `PemantauanRemajaListResponse`

| JSON Field | Dart Field | Tipe |
|---|---|---|
| `data` | `data` | `List<PemantauanRemajaItem>` |
| `pagination` | `pagination` | `PaginationMeta` |
| `success` | `success` | `bool` |

### C.3 Model — `PemantauanRemajaItem`

| JSON Field | Dart Field | Tipe |
|---|---|---|
| `id_pantau_remaja` | `idPantauRemaja` | `String` |
| `id_kader` | `idKader` | `String` |
| `nama_kader` | `namaKader` | `String` |
| `nama_posyandu` | `namaPosyandu` | `String` |
| `tanggal_periksa` | `tanggalPeriksa` | `String` |
| `berat_badan` | `beratBadan` | `double` |
| `tinggi_badan` | `tinggiBadan` | `double` |
| `sistol` | `sistol` | `int?` |
| `distol` | `distol` | `int?` |
| `gula_darah` | `gulaDarah` | `int?` |
| `bmi` | `bmi` | `double?` |
| `status_gizi` | `statusGizi` | `String` |
| `keluhan` | `keluhan` | `String?` |
| `saran` | `saran` | `String?` |
| `created_at` | `createdAt` | `String?` |
| `updated_at` | `updatedAt` | `String?` |

### C.4 Model — `PaginationMeta` (sama dengan balita)

| JSON Field | Dart Field | Tipe |
|---|---|---|
| `page` | `page` | `int` |
| `limit` | `limit` | `int` |
| `total` | `total` | `int` |
| `total_pages` | `totalPages` | `int` |

---

## D. Layout Card (Figma Reference)

Berdasarkan desain balita dengan penyesuaian untuk remaja:

```
┌──────────────────────────────────┐  ← white bg, corner 16, shadow
│  ┌──────┬───────────────────┬──┐ │
│  │  24  │ 25 Jun 2026  24 thn │ >│ │  ← row1: SPACE_BETWEEN (usia tahun)
│  │ thn  ├───────────────────┤  │ │
│  │ 🟠   │100 kg│160 cm│98 mg/dl│  │ │  ← row2: berat, tinggi, gula darah + badge gizi
│  └──────┴───────────────────┴──┘ │
│  padding: 16                     │
└──────────────────────────────────┘
```

### D.1 Detail Visual Card

| Bagian | Detail |
|--------|--------|
| **Container** | White `#ffffff`, corner radius `16`, border `#00000014` (8% opacity), shadow 2 layer |
| **Padding dalam** | 16px all sides |
| **Avatar 🟠** | Circle 40x40, bg `#fff7ed`. Atas: `usiaTahun` (ExtraBold 12px `#f97316`), Bawah: `"thn"` (SemiBold 12px `#f9731699`) |
| **Baris Atas** | Kiri: `tanggalPeriksa` format "25 Jun 2026". Kanan: `StatusGiziBadge` |
| **Baris Bawah** | Items dengan `gap 16`: `berat kg`, `tinggi cm`, `gula darah mg/dl` (jika ada) |
| **Ikon Kanan** | Chevron arrow `>` untuk indikasi dapat diklik |

### D.2 Warna Status Gizi (sama dengan balita)

| Status | Label | Color |
|--------|-------|-------|
| `berat_badan_kurang` | Kurang | `#2196F3` biru |
| `berat_badan_normal` | Normal | `#43A047` hijau |
| `berat_badan_berlebih` | Berlebih | `#FFA726` oranye |
| `obesitas_1` | Obesitas 1 | `#EF5350` merah |
| `obesitas_2` | Obesitas 2 | `#B71C1C` merah gelap |

---

## E. Tab System

| Tab | Label | Warna | Status |
|-----|-------|-------|--------|
| **Pertumbuhan** | `Pertumbuhan` | `#f97316` orange (active) | ✅ List riwayat berjalan |
| **Imunisasi** | `Imunisasi` | `#64748b` gray (inactive) | ⏸ Placeholder |
| **Grafik** | `Grafik` | `#64748b` gray (inactive) | ⏸ Nanti link ke `BmiChartPage` |

---

## F. Urutan Implementasi

| Step | File | Tindakan |
|------|------|----------|
| 1 | `lib/core/models/remaja/pemantauan_remaja_model.dart` | BUAT model `PemantauanRemajaItem`, `PaginationMeta`, `PemantauanRemajaListResponse` |
| 2 | `lib/core/services/remaja/pemantauan_remaja_service.dart` | BUAT service `getList()` |
| 3 | `lib/widgets/remaja/pemantauan_remaja_card.dart` | BUAT card widget sesuai Figma (adaptasi dari balita) |
| 4 | `lib/features/pages/remaja/riwayat_pemantauan_page.dart` | BUAT halaman Riwayat lengkap |
| 5 | `lib/features/pages/remaja/remaja_page.dart` | UBAH: ganti placeholder dengan `RiwayatPemantauanPage(embedded: true)` |
| 6 | `lib/widgets/remaja/status_gizi_badge.dart` | UPDATE: tambah handling `berat_badan_*` prefix |

---

## G. Halaman `RiwayatPemantauanPage` — Spesifikasi

### G.1 State Variables
```dart
List<PemantauanRemajaItem> _items = [];
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
  → PemantauanRemajaService.getList(idRemaja, page=1, limit=10)
    → sukses: simpan items + pagination, simpan cache
    → gagal + cache ada: tampilkan cache + offline banner
    → gagal + cache kosong: tampilkan error screen
```

### G.3 Alur Muat Lainnya
```
tombol "Muat Lainnya" diklik
  → set _loadingMore = true
  → PemantauanRemajaService.getList(idRemaja, page=_currentPage+1, limit=10)
    → sukses: append items, update pagination, _currentPage++
    → gagal: snackbar error
  → set _loadingMore = false
```

### G.4 On Tap Card
Navigasi ke halaman detail pemantauan (placeholder untuk sekarang, akan diimplementasi di fase selanjutnya).

---

## H. Testing

### H.1 Framework
- `flutter_test` (SDK) — tanpa `mockito`/`mocktail`
- Mocking manual: `_mockDio()`, stub class `_MockPemantauanRemajaService`, `_MockAuthService`
- Storage: `FlutterSecureStorage.setMockInitialValues({})` + `SharedPreferences.setMockInitialValues({})`

### H.2 File Test Baru (3 file)

| # | File | Test Coverage |
|---|------|---------------|
| 1 | `test/core/services/remaja/pemantauan_remaja_service_test.dart` | `getList` success, query params, 404 error, 401 error, network error |
| 2 | `test/widgets/remaja/pemantauan_remaja_card_test.dart` | Render semua field, null gulaDarah, avatar usia+thn, onTap, chevron icon |
| 3 | `test/features/pages/remaja/riwayat_pemantauan_page_test.dart` | Skeleton→data, error+retry, cache+offline banner, tab placeholder, pagination hide, moduleId null |

### H.3 Jumlah Test
- **Service**: 5 test ✅
- **Widget**: 5 test ✅  
- **Page**: 7 test ✅
- **Total**: **17 test — all passed**

---

## I. Stale-While-Revalidate & IndexedStack

### I.1 Perubahan `module_page_mixin.dart`
(Sudah ada di codebase - gunakan yang sama)

### I.2 Perubahan `remaja_page.dart`

- Body tetap menggunakan `PageView` + `PageController` (sudah ada)
- Index 1 = `RiwayatPemantauanPage(embedded: true)`
- Header dinamis: index 0 → "Remaja", index 1 → "Riwayat"

### I.3 Perubahan `riwayat_pemantauan_page.dart`

- Tambah param `embedded` (default false):
  - `true`: render body langsung (tanpa Scaffold, AppBar, BottomNav)
  - `false`: render seperti sekarang (Scaffold + AppBar + BottomNav)
- Tambah `_lastFetchTime` + stale check di `_loadData()`
- Tambah `WidgetsBindingObserver` untuk foreground refresh (hanya jika `!embedded`)
- Silent refresh: jika data basi, fetch di background tanpa skeleton/ganti data

---

## J. Error Handling (dari standar-modul.md)

### J.1 Exception Types

| Exception | Source | Trigger |
|-----------|--------|---------|
| `ServerException` | `core/utils/errors.dart` | Backend merespon error (4xx, 5xx) |
| `NetworkException` | `core/utils/errors.dart` | Tidak dapat terhubung ke server |

### J.2 401 — Sesi Habis → Redirect Login

```dart
if (isSessionExpired(e)) {
  await cacheManager.clear(moduleId ?? '');
  await AuthService().logout();
  Navigator.pushReplacementNamed(context, '/login');
  return;
}
```

### J.3 Error Code → Pesan Ramah

| HTTP | Pesan Teknis | Pesan Ramah |
|------|-------------|-------------|
| 401 | Token JWT tidak valid / expired | "Sesi Anda telah habis. Silakan login kembali." |
| 403 | Anda tidak memiliki hak akses | "Anda tidak memiliki akses ke data ini." |
| 404 | Resource tidak ditemukan | "Data tidak ditemukan." |
| 409 | Terjadi konflik data | "Terjadi bentrokan data. Silakan coba lagi." |
| 422 | Entitas tidak dapat diproses | "Data yang Anda masukkan tidak valid." |
| 429 | Too many requests | "Terlalu banyak permintaan. Silakan coba beberapa saat lagi." |
| 5xx | Internal server error | "Terjadi gangguan pada server. Silakan coba lagi nanti." |
| — | Network error | "Tidak dapat terhubung ke server. Periksa koneksi internet Anda." |

### J.4 Error Screen Layout

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

---

## K. Standar Implementasi (dari standar-modul.md)

- [x] Skeleton loading per widget (no `CircularProgressIndicator`)
- [x] `CacheManager<PemantauanRemajaListResponse>` untuk persist data lokal
- [x] Pull-to-refresh
- [x] Offline banner dengan tombol hubungkan
- [x] 401 → redirect login
- [x] Error message bahasa awam (dengan tombol "Coba Lagi")
- [x] State convention manual
- [x] Stale-while-revalidate (`staleAfter: 30s`) di kedua view
- [x] `IndexedStack` untuk navigasi tab tanpa recreate

---

## L. Catatan Penting

1. **Response API**: Menggunakan array `data` dengan pagination (mirip balita)
2. **Avatar usia**: Untuk remaja, gunakan "thn" (tahun) bukan "bln" (bulan)
3. **Field tambahan**: `gula_darah` muncul di card (tidak ada di balita)
4. **Tab Grafik**: Akan link ke BMI chart (belum diimplementasi)
5. **Detail pemantauan**: Endpoint ada, tapi navigasi ke detail akan dikerjakan di fase berikutnya