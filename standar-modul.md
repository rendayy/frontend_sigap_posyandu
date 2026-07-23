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

## 8. Checklist Implementasi Modul Baru

- [ ] Skeleton loading per widget (no `CircularProgressIndicator`)
- [ ] `CacheManager<T>` untuk persist data lokal
- [ ] Pull-to-refresh
- [ ] Offline banner dengan tombol hubungkan
- [ ] 401 → redirect login
- [ ] Error message bahasa awam
- [ ] Gunakan `ModulePageMixin<T>` atau patuhi state convention manual
