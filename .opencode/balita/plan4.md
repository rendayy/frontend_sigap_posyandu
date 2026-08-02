# Plan: Modul Balita — Fase 4: Grafik KMS (Growth Chart & Riwayat Grafik)

**Status:** ✅ **Selesai** — 152 test pass

> **Catatan 1:** `url_launcher` tidak bisa membuka `file://` URI di mobile (Android/iOS). Solusi: `open_filex` package.
> **Catatan 2:** GrowthChartPage sekarang menggunakan stale-while-revalidate (30 detik) + `IndexedStack` di RiwayatPemantauanPage agar tidak re-fetch saat ganti tab.

---

## A. Aturan & Referensi

| Aturan | Detail |
|--------|--------|
| **Arsitektur** | Feature-First: Page → Service → ApiClient → Backend |
| **State** | Local state di `StatefulWidget` + `CacheManager<T>` + stale-while-revalidate |
| **Font** | Google Fonts Plus Jakarta Sans |
| **Package** | `package:frontend_posyandu` |
| **Naming** | file: `snake_case`, class: `PascalCase`, var/func: `camelCase` |
| **Import** | `package:` imports |
| **Simpan data** | `CacheManager<T>` + `SharedPreferences` |
| **Navigasi** | `Navigator.push` untuk standalone; embedded via tab di `RiwayatPemantauanPage` |
| **Standar Modul** | Lihat `standar-modul.md` (skeleton, cache, offline banner, pull-to-refresh, 401 redirect) |
| **Chart Library** | `fl_chart: ^0.70.0` — sudah terpakai di `widgets/charts/growth_chart.dart` |
| **File Opener** | `open_filex: ^4.7.0` — untuk membuka file PDF KMS di native viewer (menggantikan `url_launcher` yang tidak support `file://` di mobile) |

---

## B. API Endpoint

### B.1 Login (existing — sudah berfungsi)

POST `/api/v1/auth/login` — sudah diintegrasikan di `auth_service.dart` + `api_client.dart` (interceptor JWT + refresh token otomatis).

### B.2 GET `/api/balita/{balita_id}/growth-chart`

**Service:** `BalitaService.getGrowthChart(String idBalita)` — **SUDAH ADA** di `lib/core/services/balita/balita_service.dart:45`

**Model:** `GrowthChartResponse` — **SUDAH ADA** di `lib/core/models/balita/growth_chart_model.dart`

**Widget Chart:** `GrowthChart` widget — **SUDAH ADA** di `lib/widgets/charts/growth_chart.dart`

**Halaman:** `GrowthChartPage` — **SUDAH ADA** di `lib/features/pages/balita/growth_chart_page.dart`

### B.3 GET `/api/balita/{balita_id}/download-kms`

**Service:**
- `BalitaService.getDownloadKmsUrl(String idBalita)` — return URL string (untuk referensi)
- `BalitaService.downloadKms(String idBalita)` — download file via `dio.download` ke temp directory, return `File`

**UI:** Button "Download KMS" di `GrowthChartPage` → `_downloadKms()` panggil `downloadKms()` → `OpenFilex.open(file.path)` untuk membuka PDF via native viewer.

### Status Saat Ini

| Komponen | Status | Keterangan |
|----------|--------|------------|
| Model `GrowthChartResponse` + `toJson()` | ✅ Selesai | Sudah include `GrowthMeasurement`, `StandardCurvePoint`, `zoneLabels`, `standardSource`, cache-ready |
| Service `getGrowthChart()` | ✅ Selesai | Sudah di-test |
| Service `getDownloadKmsUrl()` + `downloadKms()` | ✅ Selesai | `downloadKms()` via `dio.download` → `File` (dengan auth token) |
| Widget `GrowthChart` (fl_chart) | ✅ Selesai | Support 7 kurva, range navigasi, touch disabled, font size fix |
| Halaman `GrowthChartPage` (embedded mode) | ✅ Selesai | standalone + embedded, skeleton, cache, range prev/next, Download KMS button |
| **Tab "Grafik" di RiwayatPemantauanPage** | ✅ **Selesai** | Menggunakan `GrowthChartPage(embedded: true, ...)` |
| **Download KMS loading state** | ✅ **Selesai** | `_isDownloading` — button disable + spinner saat download |
| **Stale-While-Revalidate** | ✅ **Selesai** | `_lastFetchTime` + `_staleAfter` (30s) + `_silentRefreshIfStale()` + silent mode di `_loadData()` |
| **IndexedStack di tab Grafik** | ✅ **Selesai** | `RiwayatPemantauanPage` pakai `IndexedStack` agar `GrowthChartPage` tetap alive saat ganti tab |
| **Test untuk Grafik & Download** | ✅ **Selesai** | 152 test total — semua pass |

---

## C. Analisis Figma — Node `1:1678` "Riwayat pemeriksaan Grafik KMS"

### C.1 Struktur Layout Figma (dari Figma MCP)

```
┌─── Status Bar ──────────────────────────┐
│ 9:41                          100%  ░░  │
├─── Top Bar ─────────────────────────────┤
│ Riwayat Pemeriksaan                    │
├─── Tab Bar (3 tabs) ───────────────────┤
│ [Pertumbuhan] [Imunisasi] [Grafik]     │  ← orange active: Grafik
├─── Sub-filter Bar ─────────────────────┤
│ [Berat Badan] [Tinggi Badan] [KMS]     │  ← horizontal filter tabs
├─── Content ────────────────────────────┤
│                                         │
│  ┌ KMS Card ──────────────────────────┐│
│  │ Kartu Menuju Sehat (KMS)           ││  ← title EB 12px
│  │ BB vs standar WHO anak laki-laki   ││  ← subtitle Regular 10px
│  │ (0–24 bulan)                       ││
│  │                                     ││
│  │  ┌ Chart ───────────────────────┐  ││
│  │  │ 18 ┤                          │  ││
│  │  │ 10 ┤    ╱╲                    │  ││
│  │  │  5 ┤  ╱  ╲  ╱╲              │  ││
│  │  │  0 ┤─╲────╲─╱──╲──          │  ││
│  │  │    └─┴─┴─┴─┴─┴─┴─┴─┴─┴─    │  ││
│  │  │    0 3 6 9 12 15 18 21 24    │  ││
│  │  │          Usia (bln)          │  ││
│  │  └──────────────────────────────┘  ││
│  │                                     ││
│  │  ● Berat Arjuna (biru)             ││  ← legend
│  │  ─ Median WHO (hijau)              ││
│  │  ─ Batas Normal (±2SD) (abu)       ││
│  │                                     ││
│  │  Status: Berat Badan Normal ✓     ││  ← EB 10px
│  │  Berat Arjuna berada dalam zona    ││  ← Regular 10px
│  │  normal WHO (antara -2SD dan +2SD) ││
│  └─────────────────────────────────────┘│
│                                         │
└─── Bottom Nav ──────────────────────────┘
│ Beranda | Riwayat | Jadwal | Notif | Profil  │
└───────────────────────────────────────────────┘
```

### C.2 Perbedaan Figma vs Current Code

| Aspek | Figma | Current Code |
|-------|-------|-------------|
| **Jumlah Tab** | 3: Pertumbuhan, **Imunisasi**, Grafik | 2: Pertumbuhan, Grafik |
| **Sub-filter di Grafik** | Berat Badan / Tinggi Badan / KMS | Tidak ada |
| **Range chart** | 0-24 bulan (fixed) | 0-24 / 24-60 (segmented button) |
| **Legend** | Berat Arjuna, Median WHO, Batas Normal (±2SD) | Normal, Waspada, Bahaya (zona warna) |
| **Status text** | "Status: Berat Badan Normal ✓" + deskripsi | Tidak ada |
| **Download KMS** | Tidak terlihat di design ini | Via `getDownloadKmsUrl()` |
| **Imunisasi tab** | Ada di Figma | Belum ada di kode |

---

## D. Ringkasan Perubahan File

### File Diubah

| # | File | Perubahan |
|---|------|-----------|
| 1 | `lib/features/pages/balita/riwayat_pemantauan_page.dart` | Ganti placeholder "Grafik" dengan `GrowthChartPage(embedded: true, ...)`. Tambah parameter `balitaService`. Gunakan `IndexedStack` untuk kedua tab (Pertumbuhan + Grafik) agar widget tetap alive saat ganti tab. |
| 2 | `lib/features/pages/balita/growth_chart_page.dart` | Refactor: tambah `embedded` mode, range prev/next, skeleton, Download KMS button (+ loading state), stale-while-revalidate (`_lastFetchTime`, `_staleAfter`, `_silentRefreshIfStale`), hapus zone description. Ganti `url_launcher` → `open_filex`. |
| 3 | `lib/core/services/balita/balita_service.dart` | Tambah method `downloadKms(String idBalita) → Future<File>` via `dio.download`. |
| 4 | `lib/core/models/balita/growth_chart_model.dart` | Tambah method `toJson()` di `GrowthMeasurement`, `StandardCurvePoint`, `GrowthChartResponse` untuk cache. |

### File Baru (0-1 file, tergantung keputusan)

| # | File | Isi |
|---|------|-----|
| (?) | N/A | Mungkin tidak perlu file baru — semua bisa diakomodasi di file existing |

### File Test Diubah / Ditambah

| # | File | Perubahan |
|---|------|-----------|
| 3 | `test/features/pages/balita/riwayat_pemantauan_page_test.dart` | Update test Grafik tab (ganti placeholder test dengan growth chart test). Tambah mock `downloadKms`. |
| 4 | `test/features/pages/balita/growth_chart_page_test.dart` | BUAT BARU: 6 test — standalone data, service loading, error, range nav, measurement history, embedded. |
| 5 | `test/features/pages/balita/balita_page_test.dart` | Tambah `dart:io` import + mock `downloadKms`. |

---

## E. Analisis File Test yang Ada

### E.1 Test Existing yang Relevan

| File Test | Isi | Relevansi |
|-----------|-----|-----------|
| `test/core/services/balita/balita_service_test.dart` | ✅ Test `getGrowthChart` (success, error, network error) + `getDownloadKmsUrl` | **Tidak perlu diubah** |
| `test/features/pages/balita/riwayat_pemantauan_page_test.dart` | Test halaman riwayat: skeleton, error, cache, **tab Grafik placeholder** (baris 176-190), tab Grafik findsNothing, navigasi ke detail page | **WAJIB diubah & ditambah** |
| `test/features/pages/balita/balita_detail_page_test.dart` | Test detail pemeriksaan | Tidak relevan |
| `test/widgets/balita/pemantauan_card_test.dart` | Test widget card | Tidak relevan |

### E.2 Test Baru yang Diperlukan

| File Test | Alasan |
|-----------|--------|
| `test/features/pages/balita/growth_chart_page_test.dart` | Belum ada test untuk `GrowthChartPage` standalone — perlu dibuat |
| (tambah di existing) | Test untuk tab Imunisasi, sub-filter Grafik, loading state Grafik |

---

## F. Pertanyaan Diskusi

Berdasarkan analisis Figma di atas, saya perlu konfirmasi:

1. **Tab "Imunisasi"**: Figma menampilkan 3 tab (Pertumbuhan, Imunisasi, Grafik). Apakah tab Imunisasi perlu diimplementasikan sekarang? Jika ya, apakah endpoint API untuk data imunisasi sudah ada atau perlu dibahas terpisah?

2. **Sub-filter Berat Badan / Tinggi Badan / KMS**: 
   - API `growth-chart` saat ini hanya mengembalikan satu `chart_type` (contoh: `"BB/U"`).
   - Apakah sub-filter ini akan memanggil API ulang dengan parameter berbeda? Atau cukup menampilkan data yang sudah ada dengan tampilan berbeda?
   - Atau apakah API akan mendukung parameter `?type=BB/U|TB/U|BB/TB`?

3. ~~**Download KMS**: Di Figma tidak terlihat tombol download KMS. Apakah fitur download KMS (PDF) tetap diperlukan? Jika ya, di mana posisinya?~~ ✅ **Sudah diimplementasikan:** Button download KMS di bagian bawah chart KMS card. Menggunakan `open_filex` untuk membuka file.

4. **Range chart**: Figma hanya menampilkan 0-24 bulan, sedangkan kode saat ini punya segmented button 0-24 / 24-60. Apakah perlu tetap dipertahankan atau ikut Figma (0-24 saja)?

5. **Prioritas**: Mana yang ingin dikerjakan lebih dulu?
   - A: Grafik tab (ganti placeholder)
   - B: Imunisasi tab (tab baru)
   - C: Sub-filter BB/TB/KMS + status deskripsi
   - D: Download KMS

---

## G. Urutan Implementasi (Sudah Selesai)

| Step | File | Tindakan | Status |
|------|------|----------|--------|
| 1 | `lib/features/pages/balita/growth_chart_page.dart` | Refactor: pisahkan body content dari Scaffold, tambah `embedded` mode, skeleton, range, download KMS button, ganti `url_launcher` → `open_filex` | ✅ |
| 2 | `lib/features/pages/balita/riwayat_pemantauan_page.dart` | Ganti placeholder Grafik dengan `GrowthChartPage(embedded: true)`, tambah `balitaService` parameter | ✅ |
| 3 | `lib/core/services/balita/balita_service.dart` | Tambah `downloadKms()` method via `dio.download` | ✅ |
| 4 | `lib/core/models/balita/growth_chart_model.dart` | Tambah `toJson()` untuk cache | ✅ |
| 5 | `pubspec.yaml` | Ganti `url_launcher` → `open_filex: ^4.7.0` | ✅ |
| 6 | Semua test files | Update mock + test untuk `downloadKms()` | ✅ |
