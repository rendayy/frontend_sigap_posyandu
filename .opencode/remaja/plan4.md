# Plan: Modul Remaja — Fase 4: Grafik Gula Darah

**Status:** Done — Fase 4 Selesai (2026-07-26)

---

## A. Ringkasan

Implementasi grafik gula darah (GulaDarahChart) untuk modul Remaja sebagai tab baru di halaman `RiwayatPemantauanPage`. Fitur ini mengikuti pola yang sudah ada di modul Balita (GrowthChartPage) dengan penyesuaian untuk data gula darah.

---

## B. Analisis Figma vs Kode Web (useGulaDarahChart.ts & DetailRemaja.tsx)

### B.1 Struktur Chart Gula Darah (dari kode web)

**API Response:**
```json
{
  "data": {
    "gula_darah_zones": [
      {"color": "#43A047", "label": "Normal", "max": 126, "min": 0, "status": "normal"},
      {"color": "#FFA726", "label": "Pra-diabetes", "max": 200, "min": 126, "status": "pra_diabetes"},
      {"color": "#B71C1C", "label": "Diabetes", "max": 999, "min": 200, "status": "diabetes"}
    ],
    "label": "Normal",
    "latest_gula_darah": 95,
    "latest_status": "normal",
    "measurements": [
      {"gula_darah": 94, "tanggal_periksa": "2026-07-04"},
      {"gula_darah": 89, "tanggal_periksa": "2026-07-11"},
      {"gula_darah": 91, "tanggal_periksa": "2026-07-18"},
      {"gula_darah": 95, "tanggal_periksa": "2026-07-22"}
    ]
  }
}
```

**Komponen Utama:**
- Line chart dengan 4 garis: Normal, Pra-diabetes, Diabetes, dan titik data pengukuran
- Warna zona: Hijau (Normal), Oranye (Pra-diabetes), Merah (Diabetes)
- Label status terbaru di header
- Measurements sebagai titik-titik berwarna biru
- Pagination dengan button "Next" untuk menampilkan 5 measurements per halaman

### B.2 Perbedaan dengan GrowthChart Balita

| Aspek | GrowthChart Balita | GulaDarahChart Remaja |
|-------|-------------------|----------------------|
| **API** | `/api/balita/{id}/growth-chart` | `/api/remaja/{id}/gula-darah-chart` |
| **Model** | `GrowthChartResponse` | `GulaDarahChartData` (baru) |
| **Zona** | 7 kurva standar WHO (-3SD sampai +3SD) | 3 zona status (Normal, Pra-diabetes, Diabetes) |
| **Y-axis** | Berat badan (kg) | Gula darah (mg/dL), range 0-200+ |
| **X-axis** | Usia (bulan) | Tanggal periksa |
| **Measurements** | Berat badan vs standar | Gula darah vs zona status |
| **Pagination** | Tidak ada | Ada (5 per halaman) |

---

## C. File yang Perlu Dibuat/Dimodifikasi

### C.1 File Baru (3 file)

| # | File | Isi |
|---|------|-----|
| 1 | `lib/core/models/remaja/gula_darah_chart_model.dart` | Model `GulaDarahChartData`, `GulaDarahZone`, `GulaDarahMeasurement` |
| 2 | `lib/widgets/charts/gula_darah_chart.dart` | Widget chart line untuk gula darah |
| 3 | `lib/features/pages/remaja/gula_darah_chart_page.dart` | Halaman grafik gula darah (standalone + embedded) |

### C.2 File yang Perlu Dimodifikasi (3 file)

| # | File | Perubahan |
|---|------|-----------|
| 1 | `lib/core/services/remaja/pemantauan_remaja_service.dart` | Tambah method `getGulaDarahChart(String idRemaja)` |
| 2 | `lib/features/pages/remaja/riwayat_pemantauan_page.dart` | Ganti placeholder "Grafik" dengan `GulaDarahChartPage(embedded: true, ...)` |
| 3 | `pubspec.yaml` | Pastikan `fl_chart` sudah ada (sudah ada) |

### C.3 File Test Baru/Dimodifikasi (3 file)

| # | File | Perubahan |
|---|------|-----------|
| 1 | `test/core/services/remaja/pemantauan_remaja_service_test.dart` | Tambah test `getGulaDarahChart` |
| 2 | `test/features/pages/remaja/gula_darah_chart_page_test.dart` | **BUAT BARU** - test untuk grafik gula darah |
| 3 | `test/features/pages/remaja/riwayat_pemantauan_page_test.dart` | Tambah test tab Gula Darah |

---

## D. Detail Implementasi

### D.1 Model — `GulaDarahChartData`

**File:** `lib/core/models/remaja/gula_darah_chart_model.dart`

```dart
class GulaDarahZone {
  final String status;
  final String label;
  final int min;
  final int max;
  final String color;

  const GulaDarahZone({
    required this.status,
    required this.label,
    required this.min,
    required this.max,
    required this.color,
  });

  factory GulaDarahZone.fromJson(Map<String, dynamic> json) => GulaDarahZone(
    status: json['status'] as String,
    label: json['label'] as String,
    min: json['min'] as int,
    max: json['max'] as int,
    color: json['color'] as String,
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'label': label,
    'min': min,
    'max': max,
    'color': color,
  };
}

class GulaDarahMeasurement {
  final int gulaDarah;
  final String tanggalPeriksa;

  const GulaDarahMeasurement({
    required this.gulaDarah,
    required this.tanggalPeriksa,
  });

  factory GulaDarahMeasurement.fromJson(Map<String, dynamic> json) =>
    GulaDarahMeasurement(
      gulaDarah: json['gula_darah'] as int,
      tanggalPeriksa: json['tanggal_periksa'] as String,
    );

  Map<String, dynamic> toJson() => {
    'gula_darah': gulaDarah,
    'tanggal_periksa': tanggalPeriksa,
  };
}

class GulaDarahChartData {
  final List<GulaDarahZone> gulaDarahZones;
  final String label;
  final int latestGulaDarah;
  final String latestStatus;
  final List<GulaDarahMeasurement> measurements;

  const GulaDarahChartData({
    required this.gulaDarahZones,
    required this.label,
    required this.latestGulaDarah,
    required this.latestStatus,
    required this.measurements,
  });

  factory GulaDarahChartData.fromJson(Map<String, dynamic> json) {
    final zones = (json['gula_darah_zones'] as List)
        .map((e) => GulaDarahZone.fromJson(e as Map<String, dynamic>))
        .toList();

    final measurements = (json['measurements'] as List)
        .map((e) => GulaDarahMeasurement.fromJson(e as Map<String, dynamic>))
        .toList();

    return GulaDarahChartData(
      gulaDarahZones: zones,
      label: json['label'] as String,
      latestGulaDarah: json['latest_gula_darah'] as int,
      latestStatus: json['latest_status'] as String,
      measurements: measurements,
    );
  }

  Map<String, dynamic> toJson() => {
    'gula_darah_zones': gulaDarahZones.map((z) => z.toJson()).toList(),
    'label': label,
    'latest_gula_darah': latestGulaDarah,
    'latest_status': latestStatus,
    'measurements': measurements.map((m) => m.toJson()).toList(),
  };
}
```

### D.2 Service — Tambah `getGulaDarahChart()`

**File:** `lib/core/services/remaja/pemantauan_remaja_service.dart`

```dart
Future<GulaDarahChartData> getGulaDarahChart(String idRemaja) async {
  try {
    final response = await _apiClient.dio.get(
      '/api/remaja/$idRemaja/gula-darah-chart',
    );

    if (response.data['success'] != true) {
      final errorData = response.data['error'] as Map?;
      final message = errorData?['message'] as String? ?? 'Gagal memuat grafik gula darah';
      final code = errorData?['code'] as int?;
      throw ServerException(statusCode: code, message: message, rawMessage: message);
    }

    return GulaDarahChartData.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  } on DioException catch (e) {
    final statusCode = e.response?.statusCode;
    final errorData = e.response?.data;
    if (errorData != null && errorData is Map) {
      final error = errorData['error'] as Map?;
      final message = error?['message'] as String? ?? 'Gagal memuat grafik gula darah';
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

### D.3 Widget Chart — `GulaDarahChart`

**File:** `lib/widgets/charts/gula_darah_chart.dart`

Desain berdasarkan Figma/web:
- Line chart dengan 3 zona warna (Normal: hijau, Pra-diabetes: oranye, Diabetes: merah)
- Measurements sebagai titik berwarna biru
- X-axis: tanggal periksa (format: dd MMM)
- Y-axis: gula darah (mg/dL), range 0-250
- Pagination dengan button "Next" untuk menampilkan 5 measurements per halaman

**⚠️ Fix: Clamp annotation Diabetes ke chartMaxY**
Zona Diabetes dari API memiliki `max: 999`, tetapi chart hanya menampilkan range 0–250.
`HorizontalRangeAnnotation` dengan y2=999 tidak ter-clip otomatis oleh fl_chart dan bleed ke luar area chart.
Solusi: method `_buildRangeAnnotations` menerima parameter `chartMaxY` dan me-clamp `y2`:

```dart
RangeAnnotations _buildRangeAnnotations(List<GulaDarahZone> zones, double chartMaxY) {
  return RangeAnnotations(
    horizontalRangeAnnotations: zones.map((zone) {
      final y2 = zone.max.toDouble() > chartMaxY ? chartMaxY : zone.max.toDouble();
      return HorizontalRangeAnnotation(
        y1: zone.min.toDouble(),
        y2: y2,  // ← di-clamp ke chartMaxY
        color: _parseColor(zone.color).withValues(alpha: 0.12),
      );
    }).toList(),
  );
}
```

### D.4 Halaman — `GulaDarahChartPage`

**File:** `lib/features/pages/remaja/gula_darah_chart_page.dart`

- Mode standalone (full page) dan embedded (tab)
- Skeleton loading
- Pull-to-refresh
- Offline banner
- Stale-while-revalidate (30 detik)
- Error handling
- Pagination measurements (5 per halaman)

---

## E. Layout Mobile — GulaDarahChartPage

```
┌──────────────────────────────────┐
│ ← Gula Darah                    │  ← TopBar
├──────────────────────────────────┤
│                                  │
│  ┌ Card 1: Header ─────────────┐│
│  │  📊 Gula Darah             ││
│  │  95 mg/dL · Normal         ││
│  └──────────────────────────────┘│
│                                  │
│  ┌ Card 2: Chart ──────────────┐│
│  │  0    50   100   150   200  ││
│  │  │                         ││
│  │  │    ●                   ││
│  │  │  ●                     ││
│  │  │●                       ││
│  │  └───────────────────────  ││
│  │  04  11  18  22  26 Jul   ││
│  └──────────────────────────────┘│
│                                  │
│  ┌ Card 3: Riwayat Pengukuran ─┐│
│  │  22 Jul 2026  95 mg/dL     ││
│  │  18 Jul 2026  91 mg/dL     ││
│  │  11 Jul 2026  89 mg/dL     ││
│  │  04 Jul 2026  94 mg/dL     ││
│  └──────────────────────────────┘│
│                                  │
│  [ Next ]                       ││  ← Button pagination
│                                  │
└──────────────────────────────────┘
```

---

## F. Stale-While-Revalidate (Auto-refresh) ✅ ADA DI STANDAR-MODUL.MD

### F.1 Prinsip

```
[View aktif]
  ├── Data belum pernah di-fetch        → fetch (tampilkan skeleton)
  ├── Data masih segar (< 30 detik)     → tampilkan langsung (skip fetch)
  ├── Data sudah basi (≥ 30 detik)      → tampilkan data lama + silent fetch di background
  │     ├── sukses: update UI tanpa skeleton
  │     └── gagal: tetap pakai data lama, snackbar error
  └── Pull-to-refresh                   → force fetch (abaikan stale)
```

### F.2 Implementasi di GulaDarahChartPage

```dart
DateTime? _lastFetchTime;
static const _staleAfter = Duration(seconds: 30);

bool get _isStale {
  if (_lastFetchTime == null) return true;
  return DateTime.now().difference(_lastFetchTime!) >= _staleAfter;
}

Future<void> _silentRefreshIfStale() async {
  if (!_isStale || _data == null) return;
  await _loadData(silent: true);
}

Future<void> _loadData({bool force = false, bool silent = false}) async {
  // ... implementasi sesuai standar-modul.md
}
```

### F.3 IndexedStack untuk Navigasi Tab

```dart
body: IndexedStack(
  index: _selectedTab,
  children: [
    _buildPemantauanTab(),
    _buildGulaDarahTab(),
  ],
),
```

---

## G. Pagination Measurements

### G.1 State yang Diperlukan

```dart
int _currentPage = 1;
static const _limit = 5;
int get _totalPages => (_data?.measurements.length ?? 0) ~/ _limit + 1;
List<GulaDarahMeasurement> get _currentMeasurements {
  final all = _data?.measurements ?? [];
  final start = (_currentPage - 1) * _limit;
  return all.skip(start).take(_limit).toList();
}
```

### G.2 UI Pagination

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    if (_currentPage > 1)
      TextButton(
        onPressed: () => setState(() => _currentPage--),
        child: const Text('Sebelumnya'),
      ),
    const SizedBox(width: 16),
    Text('$_currentPage / ${_totalPages == 0 ? 1 : _totalPages}'),
    const SizedBox(width: 16),
    if (_currentPage < _totalPages)
      TextButton(
        onPressed: () => setState(() => _currentPage++),
        child: const Text('Selanjutnya'),
      ),
  ],
)
```

---

## H. Testing Strategy

### H.1 Test Service

**File:** `test/core/services/remaja/pemantauan_remaja_service_test.dart`

- `getGulaDarahChart` success → return `GulaDarahChartData`
- `getGulaDarahChart` 404 → throw `ServerException`
- `getGulaDarahChart` 401 → throw `ServerException`
- `getGulaDarahChart` network error → throw `NetworkException`

### H.2 Test Page

**File:** `test/features/pages/remaja/gula_darah_chart_page_test.dart`

- Render skeleton saat loading
- Render chart saat sukses
- Render error screen saat gagal + tidak ada cache
- Render offline banner saat data dari cache
- Pull-to-refresh berfungsi
- Stale-while-revalidate
- Pagination measurements

### H.3 Test Integration

**File:** `test/features/pages/remaja/riwayat_pemantauan_page_test.dart`

- Tab Gula Darah menampilkan chart
- Navigasi antar tab berfungsi

---

## I. Checklist Implementasi

- [x] Buat model `GulaDarahChartData` + `toJson()`
- [x] Tambah method `getGulaDarahChart()` di service
- [x] Buat widget `GulaDarahChart`
- [x] Buat halaman `GulaDarahChartPage`
- [x] Tambah tab "Gula Darah" di `RiwayatPemantauanPage`
- [x] Buat test service
- [x] Buat test page
- [x] Update test integration

**Hasil Test:** 224/224 passed (15 service + 7 page + 28 integration + 174 existing)

---

## J. Pertanyaan untuk Diskusi

1. **Tab mana yang yang aktif?** 
   - Hanya 2 tabs: Pemantauan, Gula Darah
   - Tab Gula Darah menampilkan grafik langsung (tidak ada Imunisasi)

2. **Range Y-axis chart** ✅ (Diputuskan: 0–250 + clamp)
   - API response memiliki zone sampai 999 (Diabetes)
   - Range tetap 0-250 agar konsisten
   - `HorizontalRangeAnnotation` untuk Diabetes di-clamp ke 250 (maxY chart) untuk mencegah bleeding warna ke luar area chart
   - Detail implementasi ada di section D.3

3. **Format tanggal**
   - Web menunjukkan format pendek "04 Jul"
   - Pakai format `dd MMM` dengan bahasa Indonesia

4. **Library yang mempermudah**
   - `fl_chart: ^0.70.0` — sudah ada di pubspec.yaml
   - `intl: ^0.19.0` — untuk format tanggal

---

## K. Referensi File

### File yang sudah ada (bisa dijadakan referensi)

- `lib/widgets/charts/growth_chart.dart` — pola implementasi chart
- `lib/features/pages/balita/growth_chart_page.dart` — pola halaman chart standalone + embedded
- `lib/core/models/balita/growth_chart_model.dart` — pola model chart
- `lib/core/services/balita/balita_service.dart` — pola service dengan download
- `test/features/pages/balita/riwayat_pemantauan_page_test.dart` — pola test

### File yang perlu dibuat

- `lib/core/models/remaja/gula_darah_chart_model.dart`
- `lib/widgets/charts/gula_darah_chart.dart`
- `lib/features/pages/remaja/gula_darah_chart_page.dart`
- `test/features/pages/remaja/gula_darah_chart_page_test.dart`