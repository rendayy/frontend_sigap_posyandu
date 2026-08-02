# Plan: Modul Remaja — Fase 5: Jadwal & Kegiatan Remaja

**Status:** ✅ Selesai — semua fitur dan test passed

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

### File Baru (5 file)

| # | File | Isi |
|---|------|-----|
| 1 | `lib/core/models/remaja/kegiatan_remaja_model.dart` | Model `KegiatanRemajaItem`, `KegiatanRemajaListResponse` |
| 2 | `lib/core/services/remaja/kegiatan_remaja_service.dart` | Service `getList(page, limit)` → `KegiatanRemajaListResponse` |
| 3 | `lib/widgets/remaja/kegiatan_remaja_card.dart` | Widget card item kegiatan (icon avatar, date+time 1 line, accent kiri) |
| 4 | `lib/features/pages/remaja/kegiatan_page.dart` | Halaman Kegiatan dengan list + muat lainnya |
| 5 | `lib/widgets/remaja/home_bottom_nav_remaja.dart` | Bottom navigation bar 4 tab khusus modul remaja (warna aktif: hijau emerald) |

### File Diubah (3 file)

| # | File | Perubahan |
|---|------|-----------|
| 6 | `lib/features/pages/remaja/remaja_page.dart` | Tambah tab "Kegiatan" di PageView (index 2), gunakan `HomeBottomNavRemaja`, header dinamis, fetch kegiatan untuk home, urutan section (Anemia sebelum Akademik) |
| 7 | `lib/widgets/remaja/home_remaja_sections.dart` | Tambah `KegiatanHomeCard` (header tanpa icon, avatar icon jenis, button hijau), `AnemiaCard`, `StatusGiziInfoCard` |
| 8 | `lib/widgets/remaja/home_bottom_nav_remaja.dart` | Warna aktif dari orange → `AppColors.emerald` (hijau) |

---

## C. API Endpoint

### C.1 GET `/api/kegiatan-remaja?page=1&limit=10`

**Response:**
```json
{
    "data": [
        {
            "id_kegiatan": "0ec11841-bd2b-411b-8ad8-f95beddde51f",
            "jenis_kegiatan": "edukasi",
            "nama_kegiatan": "Abogoboga",
            "no": 1,
            "status": "dibatalkan",
            "tanggal": "2026-07-31",
            "tempat": "Aula Posyandu Melati",
            "waktu": "21:00:00"
        }
    ],
    "pagination": {
        "limit": 10,
        "page": 1,
        "total": 11,
        "total_pages": 2
    },
    "success": true,
    "timestamp": "2026-07-26T12:58:24.425483Z"
}
```

### C.2 Model — `KegiatanRemajaListResponse`

| JSON Field | Dart Field | Tipe |
|---|---|---|
| `data` | `data` | `List<KegiatanRemajaItem>` |
| `pagination` | `pagination` | `PaginationMeta` |
| `success` | `success` | `bool` |

### C.3 Model — `KegiatanRemajaItem`

| JSON Field | Dart Field | Tipe |
|---|---|---|
| `id_kegiatan` | `idKegiatan` | `String` |
| `jenis_kegiatan` | `jenisKegiatan` | `String` |
| `nama_kegiatan` | `namaKegiatan` | `String` |
| `no` | `no` | `int` |
| `status` | `status` | `String` |
| `tanggal` | `tanggal` | `String` |
| `tempat` | `tempat` | `String` |
| `waktu` | `waktu` | `String` |

### C.4 Enum Values

| Field | Valid Values |
|-------|--------------|
| `jenis_kegiatan` | `edukasi`, `skrining`, `konseling`, `olahraga` |
| `status` | `rencana`, `selesai`, `dibatalkan` |

---

## D. Layout Card (Final Design)

```
┌──────────────────────────────────┐  ← white bg, corner 16, shadow
│ ┃ ┌──────┐ Penyuluhan Gizi       │  ← avatar icon jenis + nama kegiatan
│ ┃ │ 📘  │                        │
│ ┃ └──────┘                        │
│ ┃ 📅 31 Juli 2026 • 🕐 09:00     │  ← date + time satu baris
│ ┃ 📍 Aula Posyandu Melati        │  ← tempat
│ ┃ [Edukasi] [Rencana]            │  ← badge jenis + badge status
│ ┃                          ›     │  ← chevron right
│ ┃ = 4px accent kiri (warna jenis)│  ← left accent stripe (DIHAPUS setelah redesign)
└──────────────────────────────────┘
```

> **Catatan:** Left accent stripe (`4px Container` warna jenis) telah dihapus pada redesign akhir.

### D.1 Detail Visual Card

| Bagian | Detail |
|--------|--------|
| **Container** | White `#ffffff`, corner radius `16`, shadow soft 2 layer (opacity 0.06 + 0.04) |
| **Avatar** | Circle 44x44, bg `jenisColor.withValues(alpha: 0.12)`, icon jenis kegiatan 22px warna jenis. Icon: `menu_book` (edukasi/biru), `health_and_safety` (skrining/hijau), `chat_bubble_outline` (konseling/ungu), `directions_run` (olahraga/oranye) |
| **Nama Kegiatan** | 15px, Weight 700, `#1E293B`, max 2 lines |
| **Date row** | 12px, Weight 500, `#64748B` — format: "31 Juli 2026 • 09:00" (waktu dipotong 5 karakter pertama) |
| **Location row** | 12px, Weight 400, `#64748B` |
| **Badge Jenis** | Chip kecil: bg `jenisColor.withValues(alpha: 0.12)`, teks 11px Weight 600 warna jenis |
| **Badge Status** | Chip kecil: bg `statusColor.withValues(alpha: 0.12)`, teks 11px Weight 600 warna status |
| **Chevron** | `Icons.chevron_right`, 18px, `#CBD5E1` |

### D.2 Warna Jenis Kegiatan

| Jenis | Label | Icon | Color |
|-------|-------|------|-------|
| `edukasi` | Edukasi | `menu_book` | `#3B82F6` biru |
| `skrining` | Skrining | `health_and_safety` | `#10B981` hijau |
| `konseling` | Konseling | `chat_bubble_outline` | `#8B5CF6` ungu |
| `olahraga` | Olahraga | `directions_run` | `#F59E0B` oranye |

### D.3 Warna Status Kegiatan

| Status | Label | Color |
|--------|-------|-------|
| `rencana` | Rencana | `#64748B` gray |
| `selesai` | Selesai | `#10B981` hijau |
| `dibatalkan` | Dibatalkan | `#EF4444` red |

---

## E. Bottom Navigation (Final)

Berdasarkan Figma: 4 tab di bottom nav, warna aktif **hijau emerald**.

| Tab | Label | Icon | Warna | Status |
|-----|-------|------|-------|--------|
| **Beranda** | `Beranda` | home | `#64748B` gray (inactive) / `#43A047` emerald (active) | ✅ |
| **Riwayat** | `Riwayat` | history | `#64748B` gray (inactive) / `#43A047` emerald (active) | ✅ |
| **Kegiatan** | `Kegiatan` | event | `#64748B` gray (inactive) / `#43A047` emerald (active) | ✅ |
| **Profil** | `Profil` | person | `#64748B` gray (inactive) / `#43A047` emerald (active) | ✅ |

### E.1 Perubahan `remaja_page.dart`

- PageView children: index 0 → Home, index 1 → Riwayat, index 2 → Kegiatan, index 3 → Profil
- Header dinamis: index 0 → "Remaja", index 1 → "Riwayat", index 2 → "Kegiatan", index 3 → "Profil"

---

## F. Urutan Implementasi

| Step | File | Tindakan |
|------|------|----------|
| 1 | `lib/core/models/remaja/kegiatan_remaja_model.dart` | BUAT model `KegiatanRemajaItem`, `KegiatanRemajaListResponse` |
| 2 | `lib/core/services/remaja/kegiatan_remaja_service.dart` | BUAT service `getList(page, limit)` |
| 3 | `lib/widgets/remaja/kegiatan_remaja_card.dart` | BUAT card widget (redesign: icon avatar, date+time 1 line, accent kiri → lalu dihapus) |
| 4 | `lib/widgets/remaja/home_bottom_nav_remaja.dart` | BUAT bottom nav 4 tab (warna aktif: emerald) |
| 5 | `lib/features/pages/remaja/kegiatan_page.dart` | BUAT halaman Kegiatan lengkap (fix: OutlinedButton, onPressed selalu enabled) |
| 6 | `lib/features/pages/remaja/remaja_page.dart` | UPDATE: tambah tab Kegiatan, urutan section (Anemia sebelum Akademik) |
| 7 | `lib/widgets/remaja/home_remaja_sections.dart` | UPDATE: tambah `KegiatanHomeCard` (header tanpa icon, avatar icon jenis, button hijau) |

---

## G. Halaman `KegiatanPage` — Spesifikasi

### G.1 State Variables
```dart
List<KegiatanRemajaItem> _items = [];
PaginationMeta? _pagination;
int _currentPage = 1;
bool _loading = true;
bool _loadingMore = false;
bool _isFromCache = false;
bool _isReconnecting = false;
String? _error;
```

### G.2 Alur Load Data
```
initState / pull-to-refresh
  → KegiatanRemajaService.getList(page=1, limit=10)
    → sukses: simpan items + pagination, simpan cache
    → gagal + cache ada: tampilkan cache + offline banner
    → gagal + cache kosong: tampilkan error screen
```

### G.3 Alur Muat Lainnya
```
tombol "Muat Lainnya" diklik
  → guard: if _loadingMore return
  → set _loadingMore = true
  → KegiatanRemajaService.getList(page=_currentPage+1, limit=10)
    → sukses: append items, update pagination, _currentPage++
    → gagal: snackbar error
  → set _loadingMore = false
```
> **Fix:** Button menggunakan `OutlinedButton` dengan `onPressed: _loadMore` (selalu enabled, guard di dalam method) agar tidak berubah warna saat loading (mencegah disabled state biru).

---

## H. Testing

### H.1 File Test (2 file)

| # | File | Test Coverage |
|---|------|---------------|
| 1 | `test/core/services/remaja/kegiatan_remaja_service_test.dart` | `getList` success, query params, 404 error, 401 error, network error |
| 2 | `test/widgets/remaja/kegiatan_remaja_card_test.dart` | Render semua field (nama, tgl, tempat, waktu "09:00", badge jenis, badge status), icon avatar by jenis (edukasi→`menu_book`, skrining→`health_and_safety`), onTap, chevron |

### H.2 Jumlah Test
- **Service**: 5 test ✅
- **Widget**: 7 test ✅
- **Total**: **12 test — all passed**

---

## I. Stale-While-Revalidate & Bottom Navigation

### I.1 Perubahan `remaja_page.dart`

- PageView children: index 0 → Home, index 1 → Riwayat, index 2 → Kegiatan, index 3 → Profil
- Header dinamis: index 0 → "Remaja", index 1 → "Riwayat", index 2 → "Kegiatan", index 3 → "Profil"
- BottomNav: 4 tab (Beranda, Riwayat, Kegiatan, Profil), warna aktif emerald

### I.2 Perubahan `kegiatan_page.dart`

- Tambah param `embedded` (default false):
  - `true`: render body langsung (tanpa Scaffold, AppBar, BottomNav)
  - `false`: render seperti sekarang (Scaffold + AppBar + BottomNav)
- Tambah `_lastFetchTime` + stale check di `_loadData()`
- Tambah `WidgetsBindingObserver` untuk foreground refresh (hanya jika `!embedded`)

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

---

## K. Standar Implementasi (dari standar-modul.md)

- [x] Skeleton loading per widget (no `CircularProgressIndicator`)
- [x] `CacheManager<KegiatanRemajaListResponse>` untuk persist data lokal
- [x] Pull-to-refresh
- [x] Offline banner dengan tombol hubungkan
- [x] 401 → redirect login
- [x] Error message bahasa awam (dengan tombol "Coba Lagi")
- [x] State convention manual
- [x] Stale-while-revalidate (`staleAfter: 30s`) di kedua view
- [x] `IndexedStack` untuk navigasi tab tanpa recreate

---

## L. Catatan Penting

1. **Response API**: Menggunakan array `data` dengan pagination (mirip pemantauan)
2. **Field yang digunakan**: Hanya field yang ada di response JSON (tidak ada `peserta_target`, `materi`, `narasumber` di response)
3. **Badge Jenis & Status**: Dibuat sebagai chip kecil di dalam konten card
4. **Avatar**: Icon jenis kegiatan (`menu_book`, `health_and_safety`, `chat_bubble_outline`, `directions_run`) bukan angka hari
5. **Navigasi detail**: Belum ada endpoint detail kegiatan di response, akan dikerjakan di fase berikutnya
6. **Bottom Navigation**: 4 tab dengan warna aktif hijau `AppColors.emerald` (#43A047)
7. **Button "Muat Lainnya"**: `OutlinedButton` putih + border hijau + spinner hijau, `onPressed` selalu enabled (guard di `_loadMore`)
8. **KegiatanHomeCard (Home)**: Header tanpa icon, avatar icon jenis kegiatan, button "Lihat Semua Kegiatan" hijau emerald
9. **Aksen kiri card**: 4px stripe warna jenis — **dihapus** pada redesign akhir
