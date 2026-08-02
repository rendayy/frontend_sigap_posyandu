# Plan: Perubahan Modul Balita — Bottom Nav, Tab Riwayat, & Swipe Navigation

**Status:** ⏳ Draft

---

## A. Masalah & Solusi

| # | Masalah | Solusi |
|---|---------|--------|
| 1 | Bottom nav memiliki 5 item (Beranda, Riwayat, Jadwal, Notifikasi, Profil) — Jadwal & Notifikasi belum siap | Hapus 2 item tersebut, sisakan Beranda, Riwayat, Profil |
| 2 | Tab Riwayat Pemeriksaan memiliki 3 tab (Pertumbuhan, Imunisasi, Grafik) — Imunisasi masih placeholder & belum diklik | Hapus tab Imunisasi, jadikan Grafik sebagai tab ke-2 yang bisa diklik |
| 3 | Navigasi antar halaman hanya via tap bottom nav, tidak ada dukungan swipe/slide | Ganti `IndexedStack` dengan `PageView` + `PageController` |
| 4 | `PageView` tidak menjaga state halaman tetap alive — setiap swipe balik ke Riwayat menyebabkan fetch API ulang (stale-while-revalidate tidak berfungsi) | Tambah `AutomaticKeepAliveClientMixin` di state halaman anak agar tetap alive meski tidak visible |
| 5 | Modul lain (Remaja, IbuHamil, dll) belum punya panduan navigasi swipe saat dibangun nanti | Tambah dokumentasi pola `PageView` + `AutomaticKeepAliveClientMixin` di `standar-modul.md` |

---

## B. Aturan & Referensi

| Aturan | Detail |
|--------|--------|
| **Arsitektur** | Feature-First: Page → Service → ApiClient → Backend |
| **Naming** | file: `snake_case`, class: `PascalCase`, var/func: `camelCase` |
| **Import** | `package:` imports |
| **State Management** | `StatefulWidget` + `ModulePageHelper<T>` + `CacheManager<T>` |
| **Navigasi Tab** | `IndexedStack` agar view tetap alive (standar-modul.md:283-295) |
| **Stale-While-Revalidate** | `staleAfter: Duration(seconds: 30)` (standar-modul.md:248-280) |
| **Font** | `GoogleFonts.plusJakartaSans`, body 14, caption 12 |

---

## C. Ringkasan Perubahan

### C.1 Tujuan

1. **Bottom nav**: Hanya Beranda, Riwayat, Profil — hapus Jadwal & Notifikasi
2. **Tab Riwayat**: Hanya Pertumbuhan & Grafik — hapus Imunisasi
3. **Swipe**: Implementasi `PageView` untuk navigasi slide antara Beranda ↔ Riwayat (termasuk update standar-modul.md)

### C.2 File yang Diubah

| # | File | Perubahan |
|---|------|-----------|
| 1 | `lib/widgets/balita/home_bottom_nav.dart` | Hapus item Jadwal & Notifikasi → 3 nav items |
| 2 | `lib/features/pages/balita/riwayat_pemantauan_page.dart` | Hapus tab Imunisasi, update indeks |
| 3 | `lib/features/pages/balita/balita_page.dart` | IndexedStack → PageView + PageController |
| 4 | `standar-modul.md` | Tambah dokumentasi pola swipe PageView |

### C.3 File yang Tidak Diubah

- Modul lain (Remaja, IbuHamil, Lansia, Posbindu) — masih placeholder, akan mengikuti pattern di standar-modul.md nanti
- Router, service, model — tidak ada perubahan logika bisnis

---

## D. Perubahan Detail

### D.1 `home_bottom_nav.dart` — Hapus Jadwal & Notifikasi

**Lokasi:** `lib/widgets/balita/home_bottom_nav.dart:17-23`

**Saat ini (5 items):**
```dart
final items = [
  _NavItem(label: 'Beranda', icon: Icons.home_outlined, activeIcon: Icons.home),
  _NavItem(label: 'Riwayat', icon: Icons.history_outlined, activeIcon: Icons.history),
  _NavItem(label: 'Jadwal', icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month),
  _NavItem(label: 'Notifikasi', icon: Icons.notifications_outlined, activeIcon: Icons.notifications),
  _NavItem(label: 'Profil', icon: Icons.person_outline, activeIcon: Icons.person),
];
```

**Menjadi (3 items):**
```dart
final items = [
  _NavItem(label: 'Beranda', icon: Icons.home_outlined, activeIcon: Icons.home),
  _NavItem(label: 'Riwayat', icon: Icons.history_outlined, activeIcon: Icons.history),
  _NavItem(label: 'Profil', icon: Icons.person_outline, activeIcon: Icons.person),
];
```

**Indeks baru:** Beranda=0, Riwayat=1, Profil=2

---

### D.2 `riwayat_pemantauan_page.dart` — Hapus Tab Imunisasi

**Lokasi:** `lib/features/pages/balita/riwayat_pemantauan_page.dart`

#### D.2.1 Tab Bar (line 271-316)

**Saat ini:**
```dart
const tabs = ['Pertumbuhan', 'Imunisasi', 'Grafik'];
```
- Tab index 0: Pertumbuhan (aktif, bisa diklik)
- Tab index 1: Imunisasi (disabled, `onTap: null`)
- Tab index 2: Grafik (disabled, `onTap: null`)

**Menjadi:**
```dart
const tabs = ['Pertumbuhan', 'Grafik'];
```
- Tab index 0: Pertumbuhan (aktif, bisa diklik)
- Tab index 1: Grafik (aktif, bisa diklik — `onTap` semua tab aktif)

#### D.2.2 Body (line 318-357)

**Saat ini:**
```dart
if (_selectedTab == 1) return _buildPlaceholder('Halaman Imunisasi');
if (_selectedTab == 2) return _buildPlaceholder('Halaman Grafik');
```

**Menjadi:**
```dart
if (_selectedTab == 1) return _buildPlaceholder('Halaman Grafik');
```

#### D.2.3 `_onNavTap` untuk Standalone Mode (line 212-226)

**Saat ini:** Indeks 0=Beranda (pop), 1=Riwayat (stay), 2=Jadwal, 3=Notifikasi, 4=Profil

**Menjadi:** Indeks 0=Beranda (pop), 1=Riwayat (stay), 2=Profil (pushNamed)

```dart
void _onNavTap(int index) {
  if (index == 0) {
    Navigator.pop(context);
  } else if (index == 2) {
    Navigator.pushNamed(context, '/profile');
  }
}
```

---

### D.3 `balita_page.dart` — Implementasi Swipe (PageView)

**Lokasi:** `lib/features/pages/balita/balita_page.dart`

#### D.3.1 Tambah Variabel & Controller

```dart
late final PageController _pageController;

@override
void initState() {
  _pageController = PageController(initialPage: 0);
  // ... existing code ...
}

@override
void dispose() {
  _pageController.dispose();
  super.dispose();
}
```

#### D.3.2 Update `_onNavTap`

```dart
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
```

#### D.3.3 Update `build` Method

- Hapus `_buildRiwayatHeader()` — tidak perlu lagi karena header akan menyesuaikan via `onPageChanged`
- Atau tetap pakai conditional header berdasarkan `_bottomNavIndex` yang diupdate dari `onPageChanged`

**Header logic:**
```dart
if (_bottomNavIndex == 0)
  HomeBalitaHeader(title: 'SIGAP Posyandu', onLogout: _logout)
else if (_bottomNavIndex == 1)
  _buildRiwayatHeader()
```

#### D.3.4 Ganti `IndexedStack` dengan `PageView`

```dart
body: PageView(
  controller: _pageController,
  physics: const AlwaysScrollableScrollPhysics(),
  onPageChanged: (index) {
    setState(() => _bottomNavIndex = index);
  },
  children: [
    _buildHomeContent(),
    const RiwayatPemantauanPage(embedded: true),
  ],
),
```

#### D.3.5 Update Back Button di Riwayat Header

```dart
onPressed: () {
  _pageController.animateToPage(
    0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
},
```

#### D.3.6 Catatan

- `PageView` hanya berisi 2 halaman (Beranda & Riwayat)
- Profil tetap via `Navigator.pushNamed('/profile')` — bukan bagian dari PageView
- `AlwaysScrollableScrollPhysics()` agar swipe selalu bisa (tidak terhalang scroll di dalam konten)
- Bottom nav `currentIndex` tetap menggunakan `_bottomNavIndex`

---

### D.4 `standar-modul.md` — Dokumentasi Swipe PageView

**Lokasi:** Tambah sub-section setelah section 8.3 (IndexedStack)

#### D.4.1 Sub-section Baru: "8.3a. PageView untuk Navigasi Swipe"

```markdown
### 8.3a. PageView untuk Navigasi Swipe Antar Tab

Untuk mendukung navigasi swipe (slide) antar halaman, gunakan `PageView` + `PageController` sebagai
pengganti (atau pelengkap) `IndexedStack`.

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
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
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
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
```

### Aturan
- PageView hanya untuk halaman yang ingin di-swipe (biasanya Beranda & Riwayat)
- Halaman lain (Profil, detail, form) tetap via `Navigator.push` / `Navigator.pushNamed`
- `onPageChanged` WAJIB dipasang untuk sinkronisasi indeks bottom nav
- `AlwaysScrollableScrollPhysics()` agar swipe tidak terhalang scroll widget di dalamnya
- `PageController` WAJIB di-`dispose` di method `dispose()`
```

---

## E. Daftar Perubahan Kode Lengkap

### E.1 `home_bottom_nav.dart`

| Baris | Perubahan |
|-------|-----------|
| 17-23 | Hapus 2 `_NavItem` (Jadwal, Notifikasi) → 3 items |

### D.2 `riwayat_pemantauan_page.dart`

| Baris | Perubahan |
|-------|-----------|
| 272 | `['Pertumbuhan', 'Imunisasi', 'Grafik']` → `['Pertumbuhan', 'Grafik']` |
| 287 | Hapus conditional `onTap: i == 0` → semua tab bisa diklik |
| 319 | Hapus `_selectedTab == 1` (Imunisasi), ubah `_selectedTab == 2` jadi `_selectedTab == 1` (Grafik) |
| 212-226 | Update `_onNavTap` untuk 3-item bottom nav |
| 49 | `int _selectedTab = 0` (tidak perlu diubah, default 0 sudah benar) |

### E.3 `balita_page.dart`

| Baris | Perubahan |
|-------|-----------|
| ~35 | Tambah `late final PageController _pageController` |
| ~42 | Inisialisasi `_pageController = PageController(initialPage: 0)` di initState |
| ~46 | Tambah `_pageController.dispose()` di dispose |
| 114-120 | Update `_onNavTap` → panggil `_pageController.animateToPage()` untuk index 0 & 1, pushNamed untuk index 2 |
| 66-81 | Update `build` — header tetap conditional, body ganti jadi PageView |
| 122-129 | Ganti `IndexedStack` dengan `PageView` + `onPageChanged` |
| 96-99 | Update back button → `_pageController.animateToPage(0)` |

### E.4 `standar-modul.md`

| Baris | Perubahan |
|-------|-----------|
| ~295 | Tambah section "8.3a. PageView untuk Navigasi Swipe Antar Tab" setelah section 8.3 |

---

## F. Risiko & Catatan

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| `PageView` dan scroll di dalam konten bentrok | Swipe tidak responsif | Gunakan `AlwaysScrollableScrollPhysics()` dan hindari `NeverScrollableScrollPhysics()` |
| Tab Imunisasi masih direferensi di tempat lain | Error kompilasi | Cek seluruh codebase untuk referensi tab Imunisasi — hanya ada di `riwayat_pemantauan_page.dart` |
| Profil page belum siap dengan bottom nav sendiri | Navigasi terputus | Profil sudah ada route `/profile` dan `ProfilePage` di router — aman |
| Modul lain belum diupdate | Inkonsistensi | Cukup dokumentasi di standar-modul.md untuk sekarang |

---

## G. Tidak Dicakup

- Halaman Grafik masih placeholder (`_buildPlaceholder`) — belum ada implementasi grafik sesungguhnya di tab ini
- Modul Remaja, IbuHamil, Lansia, Posbindu belum diimplementasi — akan mengikuti standar-modul.md saat dibangun
- Tidak ada perubahan pada service, model, atau API client
