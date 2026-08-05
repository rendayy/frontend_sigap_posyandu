# Standar Implementasi Modul — SIGAP Posyandu Mobile

## 1. Loading (Skeleton per Widget)

Setiap halaman modul WAJIB menampilkan skeleton placeholder per widget (bukan `CircularProgressIndicator`) saat data sedang dimuat.

```dart
// ✅ WAJIB — skeleton per widget
GreetingSection(isLoading: isLoading)
ProfileSummaryCard(isLoading: isLoading)
QuickStatsGrid(isLoading: isLoading)

// ❌ DILARANG — spinner fullscreen
if (_loading) return const Center(child: CircularProgressIndicator());
```

### Aturan
- Layout halaman langsung di-render saat `initState()`.
- Setiap widget menerima `isLoading` untuk menampilkan skeleton-nya sendiri.
- Skeleton menggunakan `SkeletonWidget` dari `widgets/common/skeleton_widget.dart`.
- Skeleton harus menyerupai bentuk widget asli (lingkaran, teks, progress bar, dll).

### Reusable Widget
`widgets/common/skeleton_widget.dart` — gray rounded rectangle:
```dart
SkeletonWidget(width: 56, height: 56, borderRadius: 28)  // lingkaran
SkeletonWidget(width: 140, height: 16)                     // teks
SkeletonWidget(width: double.infinity, height: 8, borderRadius: 20)  // progress bar
```

---

## 2. Cache Lokal

Setiap modul WAJIB menyimpan data terakhir ke penyimpanan lokal (SharedPreferences) agar bisa ditampilkan saat offline.

### Cara Pakai

```dart
final cache = CacheManager<BalitaDetailResponse>(
  prefix: 'balita',
  fromJson: BalitaDetailResponse.fromJson,
  toJson: (d) => d.toJson(),
);

// Simpan
await cache.save(moduleId, data);

// Baca
final cached = await cache.load(moduleId);

// Hapus
await cache.clear(moduleId);
```

### Alur Load Data
```
loadData()
  ├── fetch API sukses
  │     ├── save ke cache
  │     └── tampilkan data
  └── fetch API gagal
        ├── cache tersedia → tampilkan + offline banner
        └── tidak ada cache → tampilkan error screen
```

---

## 3. Offline Banner

Saat menampilkan data dari cache (karena gagal fetch API), WAJIB menampilkan banner kuning dengan tombol "Hubungkan".

| State | Tampilan |
|-------|----------|
| Menampilkan data cache | Banner kuning + ikon wifi_off + teks "Menampilkan data tersimpan" + tombol "Hubungkan" |
| Sedang menghubungkan | Tombol "Hubungkan" berubah jadi spinner putih |
| Berhasil hubungkan | Banner hilang, data baru tampil |
| Gagal hubungkan | Banner tetap, snackbar error muncul |

### Reusable Widget
`widgets/common/offline_banner.dart`:
```dart
OfflineBanner(
  isReconnecting: _isReconnecting,
  onTap: _loadData,
)
```

State yang diperlukan:
```dart
bool _isFromCache = false;   // apakah data dari cache?
bool _isReconnecting = false; // sedang menghubungkan?
```

---

## 4. Pull-to-refresh

Semua halaman dengan data dinamis WAJIB mendukung pull-to-refresh.

```dart
RefreshIndicator(
  onRefresh: _loadData,
  child: ListView(/* or SingleChildScrollView */),
)
```

### Aturan
- `onRefresh` memanggil `loadData()` yang sama dengan load awal.
- Saat refresh gagal, fallback ke cache (sama seperti load awal).
- Pull-to-refresh tetap bisa dilakukan walaupun sedang menampilkan data cache.

---

## 5. Error Handling

### 5.1. Exception Types

| Exception | Source | Trigger |
|-----------|--------|---------|
| `ServerException` | `core/utils/errors.dart` | Backend merespon error (4xx, 5xx) |
| `NetworkException` | `core/utils/errors.dart` | Tidak dapat terhubung ke server |

### 5.2. 401 — Sesi Habis → Redirect Login

```dart
if (isSessionExpired(e)) {
  await cacheManager.clear(moduleId ?? '');
  await AuthService().logout();
  Navigator.pushReplacementNamed(context, '/login');
  return;
}
```

### 5.3. Error Code → Pesan Ramah

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

### 5.4. Alur Error

```
Error terjadi
  ├── 401 (sesi habis)
  │     ├── hapus cache modul
  │     ├── logout (clear tokens)
  │     └── redirect /login
  │
  ├── Error lain + cache tersedia
  │     ├── tampilkan data cache
  │     ├── set _isFromCache = true
  │     └── show snackbar pesan ramah
  │
  └── Error lain + tidak ada cache
        └── tampilkan error screen dengan pesan ramah
```

Gunakan helper:
```dart
String friendlyError(dynamic error)     // ubah exception ke pesan ramah
bool isSessionExpired(dynamic error)   // cek 401
```

---

## 6. State Management

Setiap halaman modul WAJIB memiliki state variables berikut:

```dart
T? _data;              // data dari API atau cache
bool _loading = true;   // sedang loading pertama atau refresh
bool _isFromCache = false;  // data berasal dari cache
bool _isReconnecting = false; // sedang mencoba hubungkan ulang
String? _error;         // pesan error (jika tidak ada cache)
```

### Reusable Helper

Gunakan `ModulePageHelper<T>` + `loadModuleData()` dari `core/utils/module_page_mixin.dart`:

```dart
class _BalitaPageState extends State<BalitaPage> {
  final _helper = ModulePageHelper<BalitaDetailResponse>();
  final _cache = CacheManager<BalitaDetailResponse>(
    prefix: 'balita',
    fromJson: BalitaDetailResponse.fromJson,
    toJson: (d) => d.toJson(),
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await loadModuleData(
      helper: _helper,
      getModuleId: () => AuthService().getModuleId(),
      fetchFromApi: (id) => BalitaService().getBalitaById(id),
      cacheManager: _cache,
      setState: () => setState(() {}),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_helper.error != null && _helper.data == null) {
      return buildModuleError(_helper.error!, _loadData);
    }
    if (_helper.data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return buildContent(_helper.data!);
  }

  Widget buildContent(BalitaDetailResponse data) {
    // render layout dengan data
  }
}
```

---

## 7. Dependency

Pastikan `pubspec.yaml` memiliki:

```yaml
dependencies:
  shared_preferences: ^2.1.1
```

---

## 8. Stale-While-Revalidate (Auto-refresh)

Setiap modul dengan data dinamis WAJIB menerapkan stale-while-revalidate untuk menghindari re-fetch tidak perlu saat navigasi tab.

### 8.1. Prinsip

```
[View aktif]
  ├── Data belum pernah di-fetch        → fetch (tampilkan skeleton)
  ├── Data masih segar (< 30 detik)     → tampilkan langsung (skip fetch)
  ├── Data sudah basi (≥ 30 detik)      → tampilkan data lama + silent fetch di background
  │     ├── sukses: update UI tanpa skeleton
  │     └── gagal: tetap pakai data lama, snackbar error
  └── Pull-to-refresh                   → force fetch (abaikan stale)
```

### 8.2. Menggunakan `loadModuleData` dengan `staleAfter`

```dart
Future<void> _loadData({bool force = false}) async {
  await loadModuleData(
    helper: _helper,
    getModuleId: () => AuthService().getModuleId(),
    fetchFromApi: (id) => BalitaService().getBalitaById(id),
    cacheManager: _cache,
    setState: () => setState(() {}),
    context: context,
    staleAfter: force ? null : const Duration(seconds: 30),
  );
}
```

`staleAfter` otomatis:
- Skip fetch jika data ada dan belum basi
- Silent refresh (tanpa skeleton) jika data ada dan sudah basi
- Tampilkan skeleton jika belum pernah fetch

### 8.3. IndexedStack untuk Navigasi Tab

Gunakan `IndexedStack` agar view tetap alive saat berpindah tab (tidak recreate → tidak re-fetch).

```dart
body: IndexedStack(
  index: _currentTab,
  children: [
    HomeView(),
    RiwayatView(),  // dibuat sekali, tetap alive
  ],
),
```

### 8.3a. PageView untuk Navigasi Swipe Antar Tab

Untuk mendukung navigasi swipe (slide) antar halaman, gunakan `PageView` + `PageController` sebagai pengganti (atau pelengkap) `IndexedStack`. Pattern ini WAJIB diterapkan di modul yang memiliki halaman Beranda dan Riwayat agar user bisa swipe.

```dart
class _ModulPageState extends State<ModulPage> {
  late final PageController _pageController;
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 0 || index == 1) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (index == 2) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_bottomNavIndex == 0)
            _buildHomeHeader()
          else
            _buildRiwayatHeader(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const AlwaysScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _bottomNavIndex = index);
              },
              children: [
                _buildHomeContent(),
                _buildRiwayatContent(),
              ],
            ),
          ),
          HomeBottomNav(
            currentIndex: _bottomNavIndex,
            onTap: _onNavTap,
          ),
        ],
      ),
    );
  }
}
```

#### Aturan
- `PageView` hanya untuk halaman yang ingin di-swipe (biasanya Beranda & Riwayat)
- Halaman lain (Profil, detail, form) tetap via `Navigator.push` / `Navigator.pushNamed`, bukan bagian dari `PageView`
- `onPageChanged` WAJIB dipasang untuk sinkronisasi indeks bottom nav
- `AlwaysScrollableScrollPhysics()` agar swipe tidak terhalang scroll widget di dalamnya
- `PageController` WAJIB di-`dispose` di method `dispose()`
- Header di luar `PageView` dan berubah sesuai `_bottomNavIndex` — bukan di dalam masing-masing halaman
- Back button di riwayat header memanggil `_pageController.animateToPage(0)` untuk kembali ke Beranda
- State halaman anak (`RiwayatView`, dll) **WAJIB** menggunakan `AutomaticKeepAliveClientMixin` agar state tetap alive dan `stale-while-revalidate` berfungsi:

  ```dart
  class _RiwayatViewState extends State<RiwayatView>
      with AutomaticKeepAliveClientMixin {

    @override
    bool get wantKeepAlive => true;

    @override
    Widget build(BuildContext context) {
      updateKeepAlive();
      // ... build content ...
    }
  }
  ```

---

### 8.4. Foreground Refresh via `WidgetsBindingObserver`

Untuk halaman standalone (bukan embedded), tambahkan observer agar refresh saat app kembali ke foreground:

```dart
class _PageState extends State<Page> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _silentRefreshIfStale();
    }
  }
}
```

### 8.5. Stale Threshold

Gunakan `Duration(seconds: 30)` sebagai default. Nilai ini cukup untuk:
- Mencegah re-fetch saat user cepat berpindah tab
- Memastikan data tidak lebih dari 30 detik basi
- Tidak membebani server dengan request tidak perlu

### 8.6. Aturan

- `staleAfter` HARUS dilewati (null) saat pull-to-refresh
- Silent refresh yang gagal TIDAK boleh menampilkan error screen — hanya snackbar
- Data cache (SharedPreferences) tetap menjadi fallback ketika API gagal total
- Halaman standalone (dibuka via Navigator.push) TETAP perlu stale check di initState

---

## 9. Checklist Implementasi Modul Baru

- [ ] Skeleton loading per widget (no `CircularProgressIndicator`)
- [ ] `CacheManager<T>` untuk persist data lokal
- [ ] Pull-to-refresh
- [ ] Offline banner dengan tombol hubungkan
- [ ] 401 → redirect login
- [ ] Error message bahasa awam
- [ ] Gunakan `ModulePageMixin<T>` atau patuhi state convention manual
- [ ] Stale-while-revalidate dengan `staleAfter: Duration(seconds: 30)`
- [ ] `IndexedStack` untuk navigasi tab dalam satu halaman
- [ ] Semua field model nullable jika ada kemungkinan `null` dari server (lihat §11)
- [ ] Empty state widget untuk setiap list yang mungkin kosong (lihat §12)

---

## 10. Font Size Standard

Semua teks dalam modul WAJIB menggunakan dua ukuran font standar berikut:

| Kategori | Ukuran | `fontWeight` | Contoh |
|----------|--------|--------------|--------|
| **Body** | `14` | `w400` / `w600` / `w700` | Label, value, deskripsi, subtitle, isi konten, judul card, tombol |
| **Caption** | `12` | `w400` / `w600` / `w700` / `w800` | Unit, tag, badge, nav label, stat label, subtitle minor |

### Pengecualian (sengaja dibesarkan)

Ukuran berikut BOLEH berbeda dan digunakan untuk hierarki visual:

| Ukuran | Penggunaan |
|--------|-----------|
| `48` | Hero number (usia balita) |
| `18` | Angka hari pada kartu jadwal |
| `16` | Nama balita, inisial, judul section ("Riwayat Pengukuran"), unit "Bulan" di samping hero |
| `15` | AppBar title, header judul halaman |

### Aturan

- DILARANG menggunakan ukuran font **9, 10, 11, 13** di modul mana pun — harus dinaikkan ke 12 (caption) atau 14 (body).
- `fontWeight` tidak dibatasi — boleh disesuaikan dengan kebutuhan hierarki visual (semakin tebal = semakin penting).
- Semua teks WAJIB menggunakan `GoogleFonts.plusJakartaSans`.
- Ukuran di luar tabel pengecualian hanya boleh digunakan jika ada persetujuan tim. Jika ragu, gunakan 14 untuk body, 12 untuk caption.

---

## 11. Null Safety & Model Contracts

Setiap model yang menerima data dari API WAJIB mempertimbangkan kemungkinan field `null` dari server, terutama untuk data yang belum diisi pengguna.

### 11.1. Aturan Nullable Field

| Kondisi Field | Deklarasi Dart | Contoh |
|--------------|----------------|--------|
| Selalu ada dari server (PK, FK, status) | `String` / `int` (non-nullable) | `idRemaja`, `nik`, `statusAktif` |
| Bisa null karena belum diisi user | `String?` / `int?` / `double?` | `sekolah`, `kelas`, `hobi`, `riwayatAnemia` |
| Bisa null karena belum ada data terkait | `String?` / `int?` / `double?` | `latestStatus`, `latestGulaDarah`, `bmi` |

### 11.2. Cara Penulisan `fromJson` yang Benar

```dart
// ✅ BENAR — null-safe dengan fallback
factory ModelX.fromJson(Map<String, dynamic> json) {
  return ModelX(
    // Field yang PASTI ada (dari tabel utama, non-nullable di DB)
    idItem: json['id_item'] as String,
    nama: json['nama'] as String,

    // Field nullable di DB atau mungkin null sebelum data diisi
    sekolah: json['sekolah'] as String?,
    kelas: json['kelas'] as String?,

    // Field numerik yang bisa null (belum ada data pengukuran)
    bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
    gulaDarah: json['gula_darah'] as int?,

    // Field agregat yang null jika sub-data masih kosong
    latestStatus: json['latest_status'] as String?,
  );
}

// ❌ SALAH — akan crash jika server kirim null
factory ModelX.fromJson(Map<String, dynamic> json) {
  return ModelX(
    sekolah: json['sekolah'] as String,       // crash jika null!
    bmi: (json['bmi'] as num).toDouble(),     // crash jika null!
    latestStatus: json['latest_status'] as String, // crash jika null!
  );
}
```

### 11.3. Cara Penanganan di Widget/Page

```dart
// ✅ BENAR — gunakan ?? untuk fallback display
Text(data.riwayatAnemia ?? 'tidak')          // default value
Text(data.bmi?.toStringAsFixed(1) ?? '—')   // dash jika null
Text(data.latestStatus ?? 'Belum ada data') // pesan informatif

// ✅ BENAR — sembunyikan bagian jika null (untuk info opsional)
if (data.prestasi != null)
  Text(data.prestasi!)

// ❌ SALAH — force unwrap tanpa guard
Text(data.riwayatAnemia!)  // crash jika null!
```

### 11.4. Panduan Field Berdasarkan Tabel DB

Sebagai referensi cepat saat membuat model, field yang **WAJIB nullable** adalah:

| Tabel | Field Nullable |
|-------|---------------|
| `REMAJA` | `sekolah`, `kelas`, `prestasi`, `hobi`, `riwayat_anemia` |
| `BALITA` | `status_gizi`, `nama_ayah`, `nama_ibu`, `no_hp_wa` |
| `PEMANTAUAN_REMAJA` | `keluhan`, `saran`, semua field pengukuran jika dari endpoint agregat |
| `PEMANTAUAN_BALITA` | `imunisasi`, `keluhan`, `saran`, `lingkar_kepala`, `lingkar_lengan` |
| Endpoint chart/agregat | `latest_status`, `latest_gula_darah`, `bmi`, `color`, `label` (null jika belum ada data) |

---

## 12. Empty State

Setiap list atau area yang menampilkan data dinamis WAJIB menangani kondisi data kosong dengan `EmptyStateWidget`, bukan membiarkan layar blank.

### 12.1. Kapan Menggunakan Empty State

| Kondisi | Tampilan |
|---------|----------|
| List API berhasil tapi `data: []` | `EmptyStateWidget` |
| Chart/grafik tanpa data pengukuran | Banner "Belum ada pengukuran" di atas area chart |
| Field nullable yang null di card | Tampilkan `"—"` |
| Error parse / API gagal | Error screen dengan tombol "Coba Lagi" (bukan empty state) |

**Penting:** Empty state ≠ error screen. Empty state tidak memiliki tombol "Coba Lagi".

### 12.2. Cara Pakai

```dart
// Reusable widget
import 'package:frontend_posyandu/widgets/common/empty_state_widget.dart';

// Penggunaan minimal
EmptyStateWidget(
  icon: Icons.monitor_heart_outlined,
  title: 'Belum ada data pemantauan',
)

// Dengan subtitle
EmptyStateWidget(
  icon: Icons.child_care_outlined,
  title: 'Belum ada data pertumbuhan',
  subtitle: 'Data akan muncul setelah pemantauan pertama dilakukan oleh kader.',
)
```

### 12.3. Pola Implementasi di Page

```dart
Widget _buildListContent() {
  // 1. Loading state → skeleton
  if (_loading && _items.isEmpty) {
    return _buildSkeleton();
  }

  // 2. Error state (tanpa cache) → error screen
  if (_error != null && _items.isEmpty) {
    return _buildError();
  }

  // 3. Empty state — data berhasil dimuat tapi kosong
  if (_items.isEmpty) {
    return EmptyStateWidget(
      icon: Icons.list_alt_outlined,
      title: 'Belum ada data',
      subtitle: 'Data akan muncul setelah kader melakukan pencatatan.',
    );
  }

  // 4. Data ada → tampilkan list
  return ListView.builder(
    itemCount: _items.length,
    itemBuilder: (_, i) => ItemCard(item: _items[i]),
  );
}
```

### 12.4. Reusable Widget

`widgets/common/empty_state_widget.dart`:

```dart
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(title, /* style: body 14 w600 textSecondary */),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, /* style: caption 12 w400 textSecondary */),
            ],
          ],
        ),
      ),
    );
  }
}
```
