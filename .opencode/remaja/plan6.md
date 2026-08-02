# Plan: Modul Remaja — Fase 6: Detail Kegiatan Remaja

**Status:** ✅ Disetujui — siap implementasi

---

## A. Ringkasan

Implementasi endpoint `GET /api/kegiatan-remaja/{id_kegiatan}` untuk menampilkan detail kegiatan remaja. Endpoint ini diakses setelah user login (POST /api/v1/auth/login) dan mengembalikan data detail kegiatan lengkap.

---

## B. API Endpoint

### GET `/api/kegiatan-remaja/{{id_kegiatan}}`

**Response:**
```json
{
    "data": {
        "created_at": "2026-07-21T02:00:38",
        "id_kegiatan": "0ec11841-bd2b-411b-8ad8-f95beddde51f",
        "jenis_kegiatan": "edukasi",
        "judul_kegiatan": "Abogoboga",
        "materi": null,
        "narasumber": "Dr. Siti Rahayu",
        "persentase_kehadiran": 0,
        "peserta_target": 2,
        "status": "dibatalkan",
        "tanggal": "2026-07-31",
        "tempat": "Aula Posyandu Melati",
        "total_kehadiran": 0,
        "updated_at": null,
        "waktu": "21:00:00"
    },
    "success": true,
    "timestamp": "2026-07-27T03:18:16.680539Z"
}
```

---

## C. Model Data

### File Baru: `lib/core/models/remaja/kegiatan_detail_model.dart`

**Model `KegiatanDetailResponse`**

| JSON Field | Dart Field | Tipe | Keterangan |
|------------|------------|------|------------|
| `id_kegiatan` | `idKegiatan` | `String` | UUID kegiatan |
| `judul_kegiatan` | `judulKegiatan` | `String` | Nama kegiatan |
| `jenis_kegiatan` | `jenisKegiatan` | `String` | `edukasi`, `skrining`, `konseling`, `olahraga` |
| `tanggal` | `tanggal` | `String` | Tanggal kegiatan (YYYY-MM-DD) |
| `waktu` | `waktu` | `String` | Waktu kegiatan (HH:MM:SS) |
| `tempat` | `tempat` | `String` | Lokasi kegiatan |
| `status` | `status` | `String` | `rencana`, `selesai`, `dibatalkan` |
| `peserta_target` | `pesertaTarget` | `int` | Jumlah peserta yang diharapkan |
| `total_kehadiran` | `totalKehadiran` | `int` | Jumlah peserta yang hadir |
| `persentase_kehadiran` | `persentaseKehadiran` | `double` | Persentase kehadiran |
| `materi` | `materi` | `String?` | Materi kegiatan (nullable) |
| `narasumber` | `narasumber` | `String?` | Nama narasumber (nullable) |
| `created_at` | `createdAt` | `String?` | Timestamp pembuatan |
| `updated_at` | `updatedAt` | `String?` | Timestamp update |

---

## D. Service

### File: `lib/core/services/remaja/kegiatan_remaja_service.dart`

**Tambah method `getDetail(String idKegiatan)`**

```dart
Future<KegiatanDetailResponse> getDetail(String idKegiatan) async {
  try {
    final response = await _apiClient.dio.get(
      '/api/kegiatan-remaja/$idKegiatan',
    );

    if (response.data['success'] != true) {
      final errorData = response.data['error'] as Map?;
      final message = errorData?['message'] as String? ?? 'Gagal memuat detail kegiatan';
      final code = errorData?['code'] as int?;
      throw ServerException(statusCode: code, message: message, rawMessage: message);
    }

    return KegiatanDetailResponse.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  } on DioException catch (e) {
    final statusCode = e.response?.statusCode;
    final errorData = e.response?.data;
    if (errorData != null && errorData is Map) {
      final error = errorData['error'] as Map?;
      final message = error?['message'] as String? ?? 'Gagal memuat detail kegiatan';
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

---

## E. Halaman Detail

### File Baru: `lib/features/pages/remaja/kegiatan_detail_page.dart`

**State Variables:**
```dart
KegiatanDetailResponse? _data;
bool _loading = true;
bool _isFromCache = false;
bool _isReconnecting = false;
String? _error;
DateTime? _lastFetchTime;
```

**Alur Load Data:**
1. Ambil `idKegiatan` dari route arguments
2. Fetch dari API via `KegiatanRemajaService.getDetail()`
3. Simpan ke cache dengan key `kegiatan_{idKegiatan}`
4. Handle error:
   - 401 → logout + redirect login
   - Error + cache ada → tampilkan cache + offline banner
   - Error + tidak ada cache → error screen

**Layout (mengikuti pola BalitaDetailPage):**
- Scaffold dengan AppBar "Detail Kegiatan"
- RefreshIndicator untuk pull-to-refresh
- OfflineBanner saat menampilkan data cache
- Card utama: Informasi kegiatan (tanggal, status, jenis, tempat, waktu)
- Card statistik: Peserta target, total kehadiran, persentase
- Card narasumber: Info narasumber & materi (jika ada)
- Card info tambahan: Created at, updated at

---

## F. Navigasi

### File: `lib/features/pages/remaja/kegiatan_page.dart`

**Perubahan:**
- Tambahkan `onTap` pada `KegiatanRemajaCard` → navigasi ke `KegiatanDetailPage`
- Pass `idKegiatan` sebagai route argument

```dart
onTap: () => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => KegiatanDetailPage(idKegiatan: item.idKegiatan),
  ),
),
```

---

## G. Testing

### File Baru: `test/core/services/remaja/kegiatan_detail_service_test.dart`

**Test Coverage:**
1. `getDetail returns KegiatanDetailResponse on success` - verifikasi semua field
2. `getDetail sends correct id in path` - verifikasi path parameter
3. `throws ServerException on 404` - handling 404
4. `throws ServerException on 401` - handling 401
5. `throws NetworkException on connection error` - handling network error

### File Baru: `test/widgets/remaja/kegiatan_detail_page_test.dart`

**Test Coverage:**
1. `renders loading skeleton when loading` - menampilkan skeleton saat loading
2. `renders error screen when error and no cache` - error screen
3. `renders offline banner when from cache` - offline banner
4. `renders detail content when data loaded` - konten detail
5. `pull-to-refresh triggers reload` - pull-to-refresh
6. `shows snackbar on refresh error` - snackbar error
7. `navigates to login on 401` - redirect login

---

## H. File yang Perlu Dibuat

| No | File | Tipe |
|----|------|------|
| 1 | `lib/core/models/remaja/kegiatan_detail_model.dart` | Model baru |
| 2 | `lib/features/pages/remaja/kegiatan_detail_page.dart` | Halaman baru |
| 3 | `test/core/services/remaja/kegiatan_detail_service_test.dart` | Test service |
| 4 | `test/widgets/remaja/kegiatan_detail_page_test.dart` | Test widget |

---

## I. File yang Perlu Diubah

| No | File | Perubahan |
|----|------|-----------|
| 1 | `lib/core/services/remaja/kegiatan_remaja_service.dart` | Tambah method `getDetail()` |
| 2 | `lib/features/pages/remaja/kegiatan_page.dart` | Tambah `onTap` → navigasi ke detail |

---

## J. Standar Implementasi (sesuai standar-modul.md)

### ✅ Checklist yang Harus Dipatuhi

- [ ] **Skeleton loading per widget** - tidak boleh pakai `CircularProgressIndicator` fullscreen
- [ ] **CacheManager<T>** untuk persist data lokal
- [ ] **Pull-to-refresh** - semua halaman dengan data dinamis
- [ ] **Offline banner** - tampilkan saat data dari cache
- [ ] **401 → redirect login** - otomatis handle session expired
- [ ] **Error message bahasa awam** - tidak teknis
- [ ] **Stale-while-revalidate** - `staleAfter: Duration(seconds: 30)`
- [ ] **Font size standard** - Body: 14px, Caption: 12px

### Font Size Standard
| Kategori | Ukuran | `fontWeight` |
|----------|--------|--------------|
| **Body** | `14` | `w400` / `w600` / `w700` |
| **Caption** | `12` | `w400` / `w600` / `w700` / `w800` |

### Pengecualian Font Size
| Ukuran | Penggunaan |
|--------|-----------|
| `48` | Hero number (usia balita) |
| `18` | Angka hari pada kartu jadwal |
| `16` | Nama balita, inisial, judul section |
| `15` | AppBar title, header judul halaman |

---

## K. Layout Card (Final Design)

```
┌──────────────────────────────────┐  ← white bg, corner 16, shadow
│ 📅 31 Juli 2026                 │  ← date + status badge di kiri
│ 🎯 Dibatalkan                  │  ← badge status
├──────────────────────────────────┤
│ 📚 Abogoboga                    │  ← judul kegiatan (15px, w700)
│                                    │
│ 📍 Aula Posyandu Melati          │  ← tempat (14px, w400)
│ 🕐 21:00                         │  ← waktu (14px, w400)
│                                    │
│ 👥 Peserta: 2 / 0 hadir (0%)     │  ← statistik kehadiran
├──────────────────────────────────┤
│ 🗣️ Dr. Siti Rahayu              │  ← narasumber (jika ada)
│ 📄 Materi: Abogoboga            │  ← materi (jika ada)
├──────────────────────────────────┤
│ 📝 Catatan:                      │  ← info tambahan
│    Dibuat: 21 Juli 2026         │
│    Diperbarui: -                │
└──────────────────────────────────┘
```

### K.1 Detail Visual Card

| Bagian | Detail |
|--------|--------|
| **Container** | White `#ffffff`, corner radius `16`, shadow soft 2 layer (opacity 0.06 + 0.04) |
| **Header Row** | Tanggal (14px, w600, #1E293B) + Status Badge (chip kecil, bg `statusColor.withValues(alpha: 0.12)`) |
| **Judul Kegiatan** | 15px, Weight 700, `#1E293B`, max 2 lines |
| **Icon Info Row** | Icon 14px + label 14px, w400, #475569 |
| **Statistik** | 14px, w500, #1E293B - format: "Peserta: X / Y hadir (Z%)" |
| **Badge Jenis** | Chip kecil: bg `jenisColor.withValues(alpha: 0.12)`, teks 11px Weight 600 warna jenis |
| **Chevron** | `Icons.chevron_right`, 18px, `#CBD5E1` (hanya di list, tidak di detail) |

### K.2 Warna Jenis Kegiatan

| Jenis | Label | Icon | Color |
|-------|-------|------|-------|
| `edukasi` | Edukasi | `menu_book` | `#3B82F6` biru |
| `skrining` | Skrining | `health_and_safety` | `#10B981` hijau |
| `konseling` | Konseling | `chat_bubble_outline` | `#8B5CF6` ungu |
| `olahraga` | Olahraga | `directions_run` | `#F59E0B` oranye |

### K.3 Warna Status Kegiatan

| Status | Label | Color |
|--------|-------|-------|
| `rencana` | Rencana | `#64748B` gray |
| `selesai` | Selesai | `#10B981` hijau |
| `dibatalkan` | Dibatalkan | `#EF4444` red |

---

## L. Font Size Standard (sesuai standar-modul.md)

### Body & Caption Standard

| Kategori | Ukuran | `fontWeight` | Contoh Penggunaan |
|----------|--------|--------------|-------------------|
| **Body** | `14` | `w400` / `w600` / `w700` | Label, value, deskripsi, subtitle, isi konten, judul card, tombol |
| **Caption** | `12` | `w400` / `w600` / `w700` / `w800` | Unit, tag, badge, nav label, stat label, subtitle minor |

### Pengecualian Font Size

| Ukuran | Penggunaan |
|--------|-----------|
| `48` | Hero number (usia balita) |
| `18` | Angka hari pada kartu jadwal |
| `16` | Nama balita, inisial, judul section |
| `15` | AppBar title, header judul halaman |

---

## M. Stale-While-Revalidate (Auto-refresh)

### Prinsip

```
[View aktif]
  ├── Data belum pernah di-fetch        → fetch (tampilkan skeleton)
  ├── Data masih segar (< 30 detik)     → tampilkan langsung (skip fetch)
  ├── Data sudah basi (≥ 30 detik)      → tampilkan data lama + silent fetch di background
  │     ├── sukses: update UI tanpa skeleton
  │     └── gagal: tetap pakai data lama, snackbar error
  └── Pull-to-refresh                   → force fetch (abaikan stale)
```

### Implementasi di Halaman Detail

```dart
bool get _isStale {
  if (_lastFetchTime == null) return true;
  return DateTime.now().difference(_lastFetchTime!) > const Duration(seconds: 30);
}

Future<void> _silentRefreshIfStale() async {
  if (!_isStale || _items.isEmpty) return;
  await _loadData(silent: true);
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    _silentRefreshIfStale();
  }
}
```

---

## N. Error Handling (sesuai standar-modul.md)

### Exception Types

| Exception | Source | Trigger |
|-----------|--------|---------|
| `ServerException` | `core/utils/errors.dart` | Backend merespon error (4xx, 5xx) |
| `NetworkException` | `core/utils/errors.dart` | Tidak dapat terhubung ke server |

### 401 — Sesi Habis → Redirect Login

```dart
if (isSessionExpired(e)) {
  await _cache.clear('${idKegiatan}');
  await AuthService().logout();
  if (context.mounted) {
    Navigator.pushReplacementNamed(context, '/login');
  }
  return;
}
```

### Error Message Bahasa Aman

| HTTP | Pesan Teknis | Pesan Ramah |
|------|-------------|-------------|
| 401 | Token JWT tidak valid / expired | "Sesi Anda telah habis. Silakan login kembali." |
| 404 | Resource tidak ditemukan | "Kegiatan tidak ditemukan." |
| 5xx | Internal server error | "Terjadi gangguan pada server. Silakan coba lagi nanti." |
| — | Network error | "Tidak dapat terhubung ke server. Periksa koneksi internet Anda." |

---

## L. Urutan Implementasi

| Step | File | Tindakan |
|------|------|----------|
| 1 | `lib/core/models/remaja/kegiatan_detail_model.dart` | BUAT model `KegiatanDetailResponse` |
| 2 | `lib/core/services/remaja/kegiatan_remaja_service.dart` | TAMBAH method `getDetail()` |
| 3 | `lib/features/pages/remaja/kegiatan_detail_page.dart` | BUAT halaman detail |
| 4 | `lib/features/pages/remaja/kegiatan_page.dart` | TAMBAH `onTap` → navigasi ke detail |
| 5 | `test/core/services/remaja/kegiatan_detail_service_test.dart` | BUAT test service |
| 6 | `test/widgets/remaja/kegiatan_detail_page_test.dart` | BUAT test widget |

---

## M. Estimasi Waktu

| Komponen | Estimasi |
|----------|----------|
| Model | 15 menit |
| Service | 15 menit |
| Halaman Detail | 45 menit |
| Navigasi | 10 menit |
| Testing Service | 20 menit |
| Testing Widget | 30 menit |
| **Total** | **~2 jam 25 menit** |

---

## N. Pertanyaan yang Perlu Dijawab

1. **Apakah ada field tambahan di response API?** (seperti `id_kader`, `nama_kader`, `nama_posyandu` yang biasanya ada di detail?)
2. **Apakah ingin menambahkan akses ke detail kegiatan untuk role lain selain `user`?**