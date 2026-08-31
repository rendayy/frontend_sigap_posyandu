# PRD — Modul Ibu Hamil (App Warga)

Dokumen ini merangkum modul **Ibu Hamil** pada aplikasi Flutter warga (`frontend_posyandu`),
mencakup fitur, integrasi backend, bug yang ditemukan beserta perbaikannya, dan cakupan
pengujian otomatis. Berlaku untuk build pada tanggal 2026-08-29.

## 1. Latar Belakang & Tujuan

Modul menampilkan ringkasan kehamilan warga: progres usia kehamilan (trimester, HPL,
prosentase menuju HPL), vital terbaru (BB + delta, tekanan darah), LILA, tinggi fundus,
jumlah kunjungan ANC, jadwal pemeriksaan berikutnya, banner edukasi per trimester, riwayat
pemeriksaan, dan grafik perkembangan **Berat Badan** serta **Tinggi Fundus**.

Tujuan: warga dapat memantau kehamilannya secara mandiri dan melihat standar/normalitas
ukurannya tanpa perlu datang ke posyandu.

## 2. Integrasi Backend (API Live)

- Base URL aktif: `http://192.168.0.184:5000` (idap, sudah dikoreksi di `.env`).
- Endpoint yang dipakai (via `IbuHamilService`):
  - `GET /pemeriksaan/ibu-hamil/{id}` → detail ringkasan kehamilan.
  - `GET /pemeriksaan/ibu-hamil/{id}/pemeriksaan?page=&limit=` → daftar kunjungan ANC.
  - `GET /pemeriksaan/ibu-hamil/{id}/pemeriksaan/{idPeriksa}` → detail per pemeriksaan (untuk delta BB terbaru).
  - `GET /charts/berat-badan` → data grafik BB (`measurements`, `batas_atas`, `batas_bawah`).
  - `GET /charts/tinggi-fundus` → data grafik TFU (`measurements`, `standar`).
- Halaman riwayat juga menampilkan tab **Grafik** (BB & TFU) dari endpoint chart.

## 3. Fitur Utama

| Fitur | Lokasi | Keterangan |
| --- | --- | --- |
| Beranda ringkasan | `lib/features/pages/ibu_hamil/ibu_hamil_page.dart` | Greeting, Hero kehamilan (usia, trimester, HPL, progress), StatRow BB/TD, StatRow LILA/TFU/ANC, Jadwal berikutnya, Banner edukasi, Riwayat singkat, Bottom nav |
| Riwayat + Grafik | `lib/features/pages/ibu_hamil/riwayat_pemeriksaan_page.dart` | List kunjungan (`Muat lebih banyak`), tab Grafik BB & TFU dengan `InfoBoxEdukasiGrafik` |
| Cache offline | `lib/core/utils/cache_manager.dart` + `module_page_mixin.dart` | Key `ibu_hamil_cache_<moduleId>`, `riwayat_periksa_cache_<moduleId>`; fallback data tersimpan + `OfflineBanner` (tombol `Hubungkan`) |
| Sesi kedaluwarsa | `errors.dart` | `ServerException(401)` → `isSessionExpired` → redirect ke `/login` |
| Profil | Bottom nav | Tab Profil memuat `ProfilePage` (logout konfirmasi) |

## 4. Bug yang Ditemukan & Diperbaiki

1. **TypeError saat parsing usia kehamilan.**
   `ibu_hamil_model.dart:45` mem-cast `usia_kehamilan` sebagai `as int?` padahal backend
   mengirim `num` (mis. `74.5`) → `TypeError` saat runtime yang mematikan beranda.
   Perbaikan: `((json['ringkasan_kehamilan'] as Map?)?['usia_kehamilan'] as num?)?.toInt()`.

2. **Crash unwrap `data` chart.**
   `BeratBadanChartResponse`/`TinggiFundusChartResponse.fromJson` mem-cast `json['data']`
   langsung sebagai `Map<String, dynamic>?`; JSON hasil decode dio bisa berupa
   `Map<dynamic, dynamic>` → crash. Perbaikan: helper `_unwrapData(json)` di akhir file model
   (`Map<String, dynamic>.from(...)` untuk map generik, fallback ke `json`).

3. **Spinner tersembunyi berputar selamanya di tab Grafik.**
   `riwayat_pemeriksaan_page.dart::_buildGrafikTab` — karena `IndexedStack` membangun semua
   tab sekaligus, tab Grafik dengan data chart null merender `GrafikCard(null)` yang
   menampilkan `CircularProgressIndicator` (spinner indeterminat, animasi tak berujung) di
   balik layar. Akibat: `pumpAndSettle` di test hang dan boros baterai di produksi.
   Perbaikan: tambah cabang `else if (_bbChart == null && _tfuChart == null)`
   `_buildChartSkeleton()` sebelum merender `GrafikCard`.

4. **File kosong (0 byte) tidak terpakai** — `ibu_hamil_detail_page.dart` dan
   `ibu_hamil_card.dart` dihapus (tidak ada referensi di kode, hanya di dokumen).

## 5. Cakupan Pengujian Otomatis

Total suite hijau: **421 test** (`flutter test`), `flutter analyze` bersih.

### Model — `test/core/models/ibu_hamil/ibu_hamil_model_test.dart` (16)
- `DetailIbuHamilResponse.fromJson` (length/rs detail, ringkasan usia kehamilan numerik, index-spacing)
- `PemeriksaanIbuHamil` item & list (pagination metadata preserved)
- `BeratBadanChartResponse` / `TinggiFundusChartResponse` (measurements, batas atas/bawah, standar; wrap non-Map `data`; toleransi `num`)
- `RiwayatPemeriksaanResponse` roundtrip ke JSON

### Service — `test/core/services/ibu_hamil/ibu_hamil_service_test.dart` (26)
- `getDetail`, `getPemeriksaanList` (sukses/empty/404/401/network)
- `getBeratBadanChart` (sukses/sukses tanpa data/404/401/network)
- `getTinggiFundusChart`, `getRiwayatPemeriksaan`
- `getBeranda`: build lengkap dari `Future.wait` (detail + list + profil), hitung delta BB dari
  pemeriksaan kedua, nilai null untuk data absen

### Halaman — `test/features/pages/ibu_hamil/*` (10)
- `ibu_hamil_page_test.dart`: skeleton→data, error+retry, cache+offline banner, bottom-nav pindah tab
- `riwayat_pemeriksaan_page_test.dart`: list + jumlah, empty, error+retry, 401→login,
  grafik saat pindah tab, pesan "data belum cukup" bila < 2 pengukuran

### Widget komponen — `test/widgets/ibu_hamil/widgets_ibu_hamil_test.dart` (28)
- GreetingIbuHamil, HeroKehamilanCard (ages, trimester, HPL, progress), StatRow2Widget
  (delta BB, status Normal/Waspada, placeholder), StatRow3Widget (LILA, TFU, kunjungan,
  label Lengkap), JadwalBerikutnyaCard (jadwal, kosong, skeleton), BannerEdukasiCard,
  CardRiwayatKunjungan (field, fallback tanggal/keluhan, onTap), GrafikCard (indikator 0/1,
  fallback loading), GrafikBeratBadan & GrafikTinggiFundus (legend/ringkasan, insufficient),
  InfoBoxEdukasiGrafik, IbuHamilHeader, BottomNavIbuHamil (5 item, indeks tap)

## 6. Konvensi Test yang Dipakai

- Mock Dio per-path (`_mockDioByPath`): path dicocokkan persis; non-2xx ditolak sebagai
  `DioException(badResponse)` meniru Dio asli; 2xx di-resolve. `_throwDio()` untuk simulasi
  `NetworkException`. `ApiClient(customDio:)` melewati interceptor auth → tanpa token.
- Mock layanan: subclass `AuthService` (override `getModuleId`, `logout`) dan
  `IbuHamilService` (override methods).
- Env test: `SharedPreferences.setMockInitialValues` + `FlutterSecureStorage.setMockInitialValues`.
- Sesi kedaluwarsa: `MaterialApp` berisi route `/login` untuk memverifikasi redirect.
- Grafik pakai pump durasi tetap (`pump(400ms)`) — tidak mengandalkan `pumpAndSettle`
  pada animasi chart.

## 7. Catatan Lain

- Struktur file: `lib/core/models/ibu_hamil/`, `lib/core/services/ibu_hamil/`,
  `lib/features/pages/ibu_hamil/`, `lib/widgets/ibu_hamil/`.
- Perilaku `IndexedStack` (semua tab ikut dibangun) adalah jebakan umum untuk animasi
  tersembunyi — pengecekan data-null sebelum merender komponen beranimasi disarankan.