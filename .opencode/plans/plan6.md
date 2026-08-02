# Plan: Full Screen Display — Modul Balita (Revisi)

**Status:** ✅ Selesai

---

## A. Ringkasan Masalah & Solusi

### Masalah
Di halaman manapun (login, balita, halaman lain), terdapat **black bar di bagian atas layar** — yaitu system status bar yang background-nya berwarna hitam/kontras dengan halaman yang berwarna putih/terang.

Akar masalah:
1. **`main.dart`** hanya memanggil `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)` untuk menyembunyikan system bars, tapi **tidak mengatur warna/overlay style** saat system bars muncul kembali (saat user swipe)
2. **`web/index.html:25`** — `<meta name="apple-mobile-web-app-status-bar-style" content="black">` memerintahkan iOS Safari untuk menampilkan status bar dengan background hitam
3. Tidak ada `SystemChrome.setSystemUIOverlayStyle()` yang menyelaraskan warna status bar dengan background aplikasi (putih/terang)

### Solusi
1. **`main.dart`** — Tambah `SystemChrome.setSystemUIOverlayStyle()` dengan `statusBarColor: Colors.transparent` dan `statusBarIconBrightness: Brightness.dark` agar status bar transparan dengan ikon gelap (cocok untuk background putih aplikasi)
2. **`web/index.html`** — Ubah `content="black"` menjadi `content="default"` agar iOS Safari tidak memaksa status bar hitam
3. **`balita_page.dart`** — Kembalikan `SafeArea(top: true)` yang sebelumnya dihapus (SafeArea bukan masalah, masalahnya adalah warna status bar)

---

## B. Aturan & Referensi

| Aturan | Detail |
|--------|--------|
| **Arsitektur** | Feature-First: Page → Service → ApiClient → Backend |
| **Naming** | file: `snake_case`, class: `PascalCase`, var/func: `camelCase` |
| **Import** | `package:` imports |
| **System UI** | `SystemChrome.setSystemUIOverlayStyle()` untuk warna/ikon status bar |
| **Immersive** | `SystemUiMode.immersiveSticky` untuk menyembunyikan system bars (bottom nav + status bar) |
| **SafeArea** | Tetap digunakan untuk mencegah konten overlap dengan notches/system bars |
| **Font** | `GoogleFonts.plusJakartaSans`, body 14, caption 12 |

---

## C. Ringkasan Perubahan

### C.1 Tujuan

1. **Hilangkan black bar** di atas layar — system status bar menyatu dengan background aplikasi
2. **Status bar tetap berfungsi** — ikon jam/baterai terlihat dengan warna gelap di atas background putih
3. **Konsisten di semua platform** — Web, Android, iOS

### C.2 File yang Dimodifikasi

| # | File | Perubahan |
|---|------|-----------|
| 1 | `lib/main.dart` | Tambah `SystemChrome.setSystemUIOverlayStyle()` untuk status bar transparan + ikon gelap |
| 2 | `web/index.html` | Ubah `apple-mobile-web-app-status-bar-style` dari `black` → `default` |
| 3 | `lib/features/pages/balita/balita_page.dart` | Kembalikan `SafeArea(top: true)` |

### C.3 File yang Dibuat

| # | File | Keterangan |
|---|------|------------|
| — | — | Tidak ada file baru yang dibuat |

### C.4 File yang Tidak Diubah

- Modul lain — tidak perlu, karena `SystemChrome.setSystemUIOverlayStyle()` bersifat global
- Router, service, model
- Widget balita (header, sections, bottom nav)

---

## D. Perubahan Detail

### D.1 `main.dart` — Tambah SystemUIOverlayStyle Global

**Lokasi:** `lib/main.dart:18-19`

**Saat ini:**
```dart
await FCMService().initialize();

SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

runApp(const MyApp());
```

**Menjadi:**
```dart
await FCMService().initialize();

SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
));

runApp(const MyApp());
```

> **Penjelasan:** `statusBarColor: Colors.transparent` membuat status bar transparan — background-nya mengikuti halaman di belakangnya (putih/terang). `statusBarIconBrightness: Brightness.dark` mengubah ikon status bar (jam, baterai, sinyal) menjadi gelap agar terlihat di background putih.

---

### D.2 `web/index.html` — Ubah Status Bar Style iOS

**Lokasi:** `web/index.html:25`

**Saat ini:**
```html
<meta name="apple-mobile-web-app-status-bar-style" content="black">
```

**Menjadi:**
```html
<meta name="apple-mobile-web-app-status-bar-style" content="default">
```

> **Penjelasan:** `content="default"` membuat iOS Safari menggunakan status bar style default-nya (putih untuk konten terang, gelap untuk konten gelap), tidak lagi dipaksa hitam.

---

### D.3 `balita_page.dart` — Kembalikan SafeArea

**Lokasi:** `lib/features/pages/balita/balita_page.dart:69-73`

**Saat ini (hasil perubahan sebelumnya):**
```dart
Expanded(
  child: _buildBody(),
),
```

**Kembali menjadi (seperti semula):**
```dart
Expanded(
  child: SafeArea(
    top: true,
    bottom: false,
    child: _buildBody(),
  ),
),
```

Dan pada `_buildContentWithSkeleton`, **kembalikan** `SizedBox(height: MediaQuery.of(context).padding.top + 12)` menjadi `const SizedBox(height: 12)`.

> **Penjelasan:** SafeArea bukan penyebab black bar. Dengan status bar yang sudah transparan dan ikon gelap, SafeArea tetap diperlukan untuk mencegah konten overlap dengan region notches/rounded corners.

---

## E. Daftar Perubahan Kode Lengkap

### E.1 `main.dart`

| Baris | Perubahan |
|-------|-----------|
| 19 | Tambah `SystemChrome.setSystemUIOverlayStyle(...)` setelah `setEnabledSystemUIMode(...)` |

### E.2 `web/index.html`

| Baris | Perubahan |
|-------|-----------|
| 25 | `content="black"` → `content="default"` |

### E.3 `balita_page.dart`

| Baris | Perubahan |
|-------|-----------|
| 69-71 | Kembalikan `SafeArea(top: true, bottom: false, child: _buildBody())` |
| 149 | Kembalikan `const SizedBox(height: 12)` |

---

## F. Risiko & Catatan

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Halaman dengan background gelap memiliki ikon status bar gelap | Ikon tidak terlihat | Tambah `SystemUiOverlayStyle` spesifik per page jika ada halaman gelap |
| `statusBarIconBrightness` tidak didukung di Web | Tidak ada efek (ikon browser tetap sesuai OS) | Aman — tidak error, hanya diabaikan |
| `statusBarColor: Colors.transparent` tidak didukung di iOS < 13 | Status bar tetap hitam | Fallback ke warna putih solid: `Colors.white` |
| `immersiveSticky` menyembunyikan status bar sepenuhnya | User tidak lihat jam/baterai | Itu memang behavior yang diinginkan — system bars muncul jika di-swipe |

---

## G. Tidak Dicakup

- Halaman selain Balita (Login, Dashboard, dll) — status bar akan menyesuaikan secara global dari `main.dart`
- Bottom navigation bar (system) di Android — tidak disentuh
- SafeArea bottom — tidak ada perubahan
