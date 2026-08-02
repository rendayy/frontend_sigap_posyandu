# Plan: Modul Remaja — Fase 3: Detail Pemantauan Remaja

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

## B. API Endpoint

### B.1 Login (existing)

POST `/api/v1/auth/login` — sudah ada dan berfungsi.

### B.2 GET `/api/remaja/{{id_remaja}}/pemantauan/{{id_pantau}}`

**Response:**
```json
{
    "audit": {
        "alert_created": false,
        "recorded": true
    },
    "data": {
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
    },
    "success": true,
    "timestamp": "2026-07-25T23:40:33.379954Z"
}
```

### B.3 Model — `PemantauanRemajaDetailResponse`

| JSON Field | Dart Field | Tipe |
|---|---|---|
| `id_pantau_remaja` | `idPantauRemaja` | `String` |
| `id_kader` | `idKader` | `String` |
| `id_cabang` | `idCabang` | `String` |
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

---

## C. Ringkasan Perubahan File

### File Baru (1 file)

| # | File | Isi |
|---|------|------|
| 1 | `lib/core/models/remaja/pemantauan_remaja_detail_model.dart` | Model `PemantauanRemajaDetailResponse` + fromJson/toJson |

### File Diubah (3 file)

| # | File | Perubahan |
|---|------|-----------|
| 2 | `lib/core/services/remaja/pemantauan_remaja_service.dart` | Tambah method `getDetail(idRemaja, idPantau)` |
| 3 | `lib/features/pages/remaja/pemantauan_detail_page.dart` | **BUAT** halaman detail pemeriksaan lengkap (baru) |
| 4 | `lib/features/pages/remaja/riwayat_pemantauan_page.dart` | Tambah `onTap` pada `PemantauanRemajaCard` → navigasi ke detail |

### Tidak Diubah

| File | Alasan |
|------|--------|
| `router.dart` | Halaman dibuka via `Navigator.push`, bukan static route |
| `pemantauan_remaja_card.dart` | Sudah punya parameter `onTap` |
| `status_gizi_badge.dart` | Sudah support `berat_badan_*` dan `obesitas_*` prefix |

---

## D. Layout Mobile — Detail Pemantauan Remaja (Berdasarkan Figma)

```
┌──────────────────────────────────┐  ← Scaffold bg #F5F7FA
│ ← Detail Pemantauan             │  ← TopBar: back button + title 15px EB
├──────────────────────────────────┤  ← RefreshIndicator + ListView
│                                  │
│  ┌ Card 1: Header ─────────────┐│  ← bg #F0FDF4 (hijau muda), corner 16
│  │  📊 Pemantauan 15 Jan 2025  ││  ← icon + tanggal (14px EB #00C950)
│  │  BMI 20.4 · Normal          ││  ← subtitle (12px #00C950)
│  └──────────────────────────────┘│
│                                  │
│  ┌ Card 2: Detail Pemeriksaan ──┐│  ← white, corner 16, border, shadow
│  │  Tanggal Periksa   15 Jan 2025││  ← row: label kiri, value kanan
│  │  ─────────────────────────  ││  ← separator
│  │  Berat Badan      50.8 kg   ││
│  │  ─────────────────────────  ││
│  │  Tinggi Badan     158 cm    ││
│  │  ─────────────────────────  ││
│  │  BMI              20.4 kg/m²││
│  │  ─────────────────────────  ││
│  │  Status Gizi      Normal    ││
│  │  ─────────────────────────  ││
│  │  Tekanan Darah    111/70 mmHg││
│  │  ─────────────────────────  ││
│  │  Sistolik         111 mmHg  ││
│  │  ─────────────────────────  ││
│  │  Diastolik       70 mmHg   ││
│  │  ─────────────────────────  ││
│  │  Gula Darah       87 mg/dL  ││
│  └──────────────────────────────┘│
│                                  │
│  Data bersifat read-only.        │  ← center 10px #64748B
│  Hubungi petugas untuk koreksi.   │
└──────────────────────────────────┘
```

### D.1 Detail Visual Card (Figma Reference)

| Bagian | Detail |
|--------|--------|
| **Header Card** | bg `#F0FDF4` (hijau muda), corner radius `16`, icon kiri, tanggal + BMI di kanan |
| **Detail Card** | White `#ffffff`, corner radius `16`, border `#00000014` (8% opacity), shadow 2 layer |
| **Padding dalam** | 16px all sides |
| **Row Style** | SPACE_BETWEEN: label (12px Regular #64748B), value (12px ExtraBold #1E293B) |
| **Separator** | border-b `#00000014` (8% opacity) |
| **TopBar** | White bg, back button kiri, title "Detail Pemantauan" (15px EB) |

---

## E. Urutan Implementasi

| Step | File | Tindakan |
|------|------|----------|
| 1 | `lib/core/models/remaja/pemantauan_remaja_detail_model.dart` | BUAT model detail |
| 2 | `lib/core/services/remaja/pemantauan_remaja_service.dart` | TAMBAH `getDetail()` |
| 3 | `lib/features/pages/remaja/pemantauan_detail_page.dart` | BUAT halaman detail |
| 4 | `lib/features/pages/remaja/riwayat_pemantauan_page.dart` | TAMBAH onTap navigasi |

---

## F. Detail Implementasi

### F.1 Model Detail — `PemantauanRemajaDetailResponse`

File: `lib/core/models/remaja/pemantauan_remaja_detail_model.dart`

```dart
class PemantauanRemajaDetailResponse {
  final String idPantauRemaja;
  final String idKader;
  final String idCabang;
  final String namaKader;
  final String namaPosyandu;
  final String tanggalPeriksa;
  final double beratBadan;
  final double tinggiBadan;
  final int? sistol;
  final int? distol;
  final int? gulaDarah;
  final double? bmi;
  final String statusGizi;
  final String? keluhan;
  final String? saran;
  final String? createdAt;
  final String? updatedAt;

  const PemantauanRemajaDetailResponse({
    required this.idPantauRemaja,
    required this.idKader,
    required this.idCabang,
    required this.namaKader,
    required this.namaPosyandu,
    required this.tanggalPeriksa,
    required this.beratBadan,
    required this.tinggiBadan,
    this.sistol,
    this.distol,
    this.gulaDarah,
    this.bmi,
    required this.statusGizi,
    this.keluhan,
    this.saran,
    this.createdAt,
    this.updatedAt,
  });

  factory PemantauanRemajaDetailResponse.fromJson(Map<String, dynamic> json) {
    return PemantauanRemajaDetailResponse(
      idPantauRemaja: json['id_pantau_remaja'] as String,
      idKader: json['id_kader'] as String,
      idCabang: json['id_cabang'] as String,
      namaKader: json['nama_kader'] as String,
      namaPosyandu: json['nama_posyandu'] as String,
      tanggalPeriksa: json['tanggal_periksa'] as String,
      beratBadan: (json['berat_badan'] as num).toDouble(),
      tinggiBadan: (json['tinggi_badan'] as num).toDouble(),
      sistol: json['sistol'] != null ? json['sistol'] as int : null,
      distol: json['distol'] != null ? json['distol'] as int : null,
      gulaDarah: json['gula_darah'] != null ? json['gula_darah'] as int : null,
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      statusGizi: json['status_gizi'] as String,
      keluhan: json['keluhan'] as String?,
      saran: json['saran'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pantau_remaja': idPantauRemaja,
      'id_kader': idKader,
      'id_cabang': idCabang,
      'nama_kader': namaKader,
      'nama_posyandu': namaPosyandu,
      'tanggal_periksa': tanggalPeriksa,
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'sistol': sistol,
      'distol': distol,
      'gula_darah': gulaDarah,
      'bmi': bmi,
      'status_gizi': statusGizi,
      'keluhan': keluhan,
      'saran': saran,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
```

### F.2 Service — Tambah `getDetail()`

File: `lib/core/services/remaja/pemantauan_remaja_service.dart`

Tambahkan method berikut:

```dart
Future<PemantauanRemajaDetailResponse> getDetail({
  required String idRemaja,
  required String idPantau,
}) async {
  try {
    final response = await _apiClient.dio.get(
      '/api/remaja/$idRemaja/pemantauan/$idPantau',
    );

    if (response.data['success'] != true) {
      final errorData = response.data['error'] as Map?;
      final message =
          errorData?['message'] as String? ?? 'Gagal memuat detail pemantauan';
      final code = errorData?['code'] as int?;
      throw ServerException(statusCode: code, message: message, rawMessage: message);
    }

    return PemantauanRemajaDetailResponse.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  } on DioException catch (e) {
    final statusCode = e.response?.statusCode;
    final errorData = e.response?.data;
    if (errorData != null && errorData is Map) {
      final error = errorData['error'] as Map?;
      final message =
          error?['message'] as String? ?? 'Gagal memuat detail pemantauan';
      throw ServerException(
          statusCode: statusCode, message: message, rawMessage: message);
    }
    if (statusCode == 401) {
      throw ServerException(
        statusCode: 401,
        message: 'Sesi Anda telah habis. Silakan login kembali.',
      );
    }
    throw NetworkException();
  }
}
```

### F.3 Halaman Detail — `PemantauanDetailPage`

File: `lib/features/pages/remaja/pemantauan_detail_page.dart`

Halaman detail pemantauan remaja dengan layout:
- Card 1: Header (icon + tanggal pemantauan + BMI)
- Card 2: Detail Pemeriksaan (berat, tinggi, sistol, distol, gula darah, status gizi)
- Offline banner jika data dari cache
- Pull-to-refresh
- Error screen dengan tombol coba lagi

### F.4 Stale-While-Revalidate & State Management

Halaman detail menggunakan state variables:

```dart
PemantauanRemajaDetailResponse? _data;
bool _loading = true;
bool _isFromCache = false;
bool _isReconnecting = false;
String? _error;
DateTime? _lastFetchTime;
```

Alur stale check:
```dart
bool get _isStale {
  if (_lastFetchTime == null) return true;
  return DateTime.now().difference(_lastFetchTime!) > const Duration(seconds: 30);
}
```

### F.5 Error Handling (dari standar-modul.md)

| Exception | Source | Trigger |
|-----------|--------|---------|
| `ServerException` | `core/utils/errors.dart` | Backend merespon error (4xx, 5xx) |
| `NetworkException` | `core/utils/errors.dart` | Tidak dapat terhubung ke server |

HTTP Code → Pesan Ramah:
| HTTP | Pesan Ramah |
|------|-------------|
| 401 | "Sesi Anda telah habis. Silakan login kembali." |
| 403 | "Anda tidak memiliki akses ke data ini." |
| 404 | "Data tidak ditemukan." |
| 409 | "Terjadi bentrokan data. Silakan coba lagi." |
| 422 | "Data yang Anda masukkan tidak valid." |
| 429 | "Terlalu banyak permintaan. Silakan coba beberapa saat lagi." |
| 5xx | "Terjadi gangguan pada server. Silakan coba lagi nanti." |
| — | "Tidak dapat terhubung ke server. Periksa koneksi internet Anda." |

### F.6 Riwayat Pemantauan — Tambah onTap

File: `lib/features/pages/remaja/riwayat_pemantauan_page.dart`

Pada `PemantauanRemajaCard`, tambahkan navigasi:

```dart
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PemantauanDetailPage(
        idPantau: item.idPantauRemaja,
      ),
    ),
  );
},
```

---

## G. Testing

### G.1 File Test Baru (2 file)

| # | File | Test Coverage |
|---|------|---------------|
| 1 | `test/core/services/remaja/pemantauan_remaja_service_test.dart` | Tambah test `getDetail` success, 404 error, 401 error, network error |
| 2 | `test/features/pages/remaja/pemantauan_detail_page_test.dart` | Skeleton→data, error+retry, cache+offline banner, read-only note |

### G.2 Test Cases

**Service Detail:**
- `getDetail` success → return `PemantauanRemajaDetailResponse`
- `getDetail` 404 → throw `ServerException`
- `getDetail` 401 → throw `ServerException`
- `getDetail` network error → throw `NetworkException`

**Page Detail:**
- Render skeleton saat loading
- Render data saat sukses
- Render error screen saat gagal + tidak ada cache
- Render offline banner saat data dari cache
- Pull-to-refresh berfungsi
- Stale-while-revalidate: skip fetch jika data segar, silent refresh jika basi
- Read-only note ditampilkan

---

## H. Ikon SVG yang Dibutuhkan

Berdasarkan Figma, header card membutuhkan ikon chart/analytics:

| Ikon | File SVG | Keterangan |
|------|----------|------------|
| Chart/Analytics | `static/svg/ic_chart.svg` | Icon untuk header card pemantauan |

Jika ikon belum ada, buat di `static/svg/ic_chart.svg` dengan desain:
- Circle background putih dengan opacity 0.6
- Icon chart garis (mirip Figma)

---

## I. Catatan Penting

1. **Response API**: Menggunakan objek `data` tunggal (bukan array dengan pagination)
2. **Field tambahan**: `bmi` muncul di card (tidak ada di balita)
3. **Tekanan darah**: Ditampilkan terpisah (sistol & distol) untuk remaja
4. **Gula darah**: Ditampilkan jika tidak null
5. **Status gizi**: Menggunakan `StatusGiziBadge` yang sudah support `berat_badan_*` dan `obesitas_*`

---

## K. Stale-While-Revalidate (Auto-refresh)

### K.1 Prinsip

```
[View aktif]
  ├── Data belum pernah di-fetch        → fetch (tampilkan skeleton)
  ├── Data masih segar (< 30 detik)     → tampilkan langsung (skip fetch)
  ├── Data sudah basi (≥ 30 detik)      → tampilkan data lama + silent fetch di background
  │     ├── sukses: update UI tanpa skeleton
  │     └── gagal: tetap pakai data lama, snackbar error
  └── Pull-to-refresh                   → force fetch (abaikan stale)
```

### K.2 Stale Threshold

Gunakan `Duration(seconds: 30)` sebagai default. Nilai ini cukup untuk:
- Mencegah re-fetch saat user cepat berpindah halaman
- Memastikan data tidak lebih dari 30 detik basi
- Tidak membebani server dengan request tidak perlu

---

## L. Checklist Implementasi

- [ ] Skeleton loading per widget (no `CircularProgressIndicator`)
- [ ] `CacheManager<PemantauanRemajaDetailResponse>` untuk persist data lokal
- [ ] Pull-to-refresh
- [ ] Offline banner dengan tombol hubungkan
- [ ] 401 → redirect login
- [ ] Error message bahasa awam
- [ ] Stale-while-revalidate dengan `staleAfter: Duration(seconds: 30)`