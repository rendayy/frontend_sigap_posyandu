# Riwayat Pemeriksaan Balita — Design Document

## Sumber
- Figma node 1:638 (tidak dapat diakses langsung; digunakan deskripsi tekstual dari user)
- Plan: `.opencode/balita/plan2.md`

## Layout Card (`PemantauanCard`)

```
┌─────────────────────────────────────────────┐
│  ⭕ (34)    18 Juli 2026         Kurang    > │
│   bln                                         │
│                                               │
│  ⚖ 12.0 kg  📏 80.0 cm  📐 48.0 cm         │
└─────────────────────────────────────────────┘
```

### Komponen
1. **Avatar (lingkaran oranye)**
   - `usiaBulan` (angka), font 14, weight 800, warna `#F97316`
   - label "bln", font 9, weight 600, warna `#F97316` (opacity 0.6)
   - HANYA di sini usia_bulan muncul (tidak duplikat di baris tanggal)

2. **Baris 1 (tanggal + status gizi)**
   - Kiri: tanggal (format "d MMMM yyyy"), font 13, weight 600, warna `#1E293B`
   - Kanan: `StatusGiziBadge(compact: true)` — langsung teks label status (tanpa prefix "Status Gizi: ")
   - Tidak ada teks "34 bln" di baris ini

3. **Baris 2 (measurements)**
   - Ikon SVG + value + satuan, font 13, weight 600, warna `#475569`
   - Berat: ikon timbangan (stroke `#FF2B4E`) + `X.X kg`
   - Tinggi: ikon centang/tinggi (stroke `#00C950`) + `X.X cm`
   - Lingkar kepala: ikon lingkar (stroke `#AD46FF`) + `X.X cm` (atau "-" bila null)
   - Ikon ukuran 13x13px

### Ukuran font measurement (dibesarkan)
- Sebelum: 12px → Sesudah: **13px**

### Status Gizi
- Menggunakan `StatusGiziBadge(compact: true)` yang hanya menampilkan label (mis. "Kurang", "Baik", "Lebih")
- Posisi: di sebelah kanan tanggal (menggantikan slot "34 bln" yang dihapus)
- Warna label sesuai status:
  - `gizi_baik` → hijau (`#22C55E`)
  - `gizi_kurang` → oranye (`#F97316`)
  - `gizi_buruk` → merah (`#EF4444`)
  - `gizi_lebih` → kuning (`#EAB308`)
  - `resiko_gizi_lebih` → amber (`#F59E0B`)

## Navigation
- `RiwayatPemantauanPage` memiliki `HomeBottomNav` di bagian bawah
- `_navIndex = 1` (Riwayat) saat pertama kali
- Tap Beranda → `Navigator.pop()` (kembali ke BalitaPage)
- Tap Riwayat → stay
- Tap lainnya → snackbar "segera hadir"

## SVG Icons
Sumber: user-provided SVG strings, inline via `SvgPicture.string()`.
- `flutter_svg: ^2.0.17` sudah tersedia di pubspec.yaml
- Import: `package:flutter_svg/flutter_svg.dart`

## File Terkait
- `lib/widgets/balita/pemantauan_card.dart` — card widget
- `lib/widgets/balita/status_gizi_badge.dart` — badge status gizi (dengan `compact` param)
- `lib/widgets/balita/home_bottom_nav.dart` — bottom navigation (reusable)
- `lib/features/pages/balita/riwayat_pemantauan_page.dart` — halaman riwayat

## Stale-While-Revalidate
- `ModulePageHelper.lastFetchTime` + `isStale(Duration)` untuk deteksi basi
- `loadModuleData` dengan `staleAfter`:
  - Skip fetch jika data masih segar
  - Silent background refresh jika data basi (tanpa skeleton)
  - Force fetch via pull-to-refresh
- Threshold: 30 detik

## Navigation (IndexedStack)
- `BalitaPage` menggunakan `IndexedStack` dengan 2 child:
  - index 0: home content (GreetingSection, ProfileSummaryCard, dll)
  - index 1: `RiwayatPemantauanPage(embedded: true)`
- Tidak ada `Navigator.push` untuk tab Riwayat — view tetap alive
- Header dinamis: HomeBalitaHeader untuk Beranda, custom header dengan back arrow untuk Riwayat
- `RiwayatPemantauanPage` punya parameter `embedded` yang menghilangkan Scaffold/AppBar/BottomNav

## Test
- `test/widgets/balita/pemantauan_card_test.dart`
- `test/features/pages/balita/riwayat_pemantauan_page_test.dart`
- `test/features/pages/balita/balita_page_test.dart`