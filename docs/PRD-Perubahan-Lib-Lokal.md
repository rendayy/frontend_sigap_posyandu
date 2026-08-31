# PRD: Catatan Perubahan Lokal — Folder `lib/`

> Dokumen ini merekam **semua perubahan yang belum di-commit** pada folder `lib/`
> agar bisa disesuaikan manual setelah `git pull` dari `main`.

---

## 1. Konteks

| Item | Nilai |
|------|-------|
| Branch aktif | `authmobile` |
| `HEAD` | `1863fc6` (Merge pull request #2 dari rendayy/Alert) |
| `origin/main` | `1863fc6` (sama dengan HEAD — **belum divergen**) |
| `main` lokal | `1863fc6` |
| Status perubahan | Semua perubahan di `lib/` masih **working-tree (belum di-commit)** |
| Risiko pull | Perubahan uncommitted berisiko konflik/tertindih jika main mengubah file yang sama |

**Catatan penting:** Karena belum ada commit lokal yang terpisah, `git pull` akan mencoba
merge ke working-tree saat ini. File yang sama-sama diubah di main dan di sini akan
konflik (lihat checklist §6).

---

## 2. File Dimodifikasi (7)

| # | Path | Perubahan |
|---|------|-----------|
| 1 | `lib/core/models/auth/user_model.dart` | `UserCategory.fromString` di-normalisasi: strip `_` + case-insensitive sebelum pencocokan enum. |
| 2 | `lib/core/models/ibu_hamil/ibu_hamil_model.dart` | Sebelumnya **file kosong (0 baris)** → kini 460 baris berisi model lengkap modul ibu hamil. |
| 3 | `lib/core/services/ibu_hamil/ibu_hamil_service.dart` | Sebelumnya **file kosong (0 baris)** → kini 440 baris service + helper pembangun data beranda. |
| 4 | `lib/features/pages/ibu_hamil/ibu_hamil_page.dart` | Ditulis ulang total: dari `StatelessWidget` (hanya logout) → `StatefulWidget` beranda lengkap (cache, PageView 5 tab, bottom nav). |
| 5 | `lib/features/pages/balita/growth_chart_page.dart` | Minor: `_isReconnecting` diubah menjadi `final bool` (fix lint). |
| 6 | `lib/features/pages/profil/profile_page.dart` | Migrasi API Flutter: `Colors.black.withOpacity(0.02)` → `withValues(alpha: 0.02)`. |
| 7 | `lib/features/themes/app_colors.dart` | +32 konstanta warna: tema pink ibu hamil, warna grafik/chart, tab, status. |

---

## 3. File Baru (14, untracked)

### 3.1 Halaman

| Path | Peran |
|------|-------|
| `lib/features/pages/ibu_hamil/riwayat_pemeriksaan_page.dart` (721 baris) | Halaman riwayat pemeriksaan: tab **Kunjungan ANC** & **Grafik**, pagination (load more), caching, refresh silent saat resume, mode `embedded`. |

### 3.2 Widget `lib/widgets/ibu_hamil/`

| File | Peran |
|------|-------|
| `greeting_ibu_hamil.dart` | Sapaan waktu + avatar inisial + badge "Ibu Hamil" |
| `hero_kehamilan_card.dart` | Kartu hero: usia kehamilan, trimester, progress bar, hitung mundur HPL |
| `stat_row_2_widget.dart` | Baris stat: berat badan (delta) + tekanan darah (status) |
| `stat_row_3_widget.dart` | Baris stat: LILA, tinggi fundus, progres kunjungan ANC |
| `jadwal_berikutnya_card.dart` | Kartu jadwal pemeriksaan berikutnya |
| `banner_edukasi_card.dart` | Banner edukasi per trimester |
| `ibu_hamil_header.dart` | Header halaman (dipanggil di `ibu_hamil_page.dart`) |
| `bottom_nav_ibu_hamil.dart` | Bottom navigation 5 tab (Beranda, Riwayat, Jadwal, Notifikasi, Profil) |
| `card_riwayat_kunjungan.dart` | Kartu item riwayat kunjungan ANC |
| `grafik_card.dart` | Container grafik (pilih indikator BB/TFU) + info edukasi |
| `grafik_berat_badan.dart` | Chart berat badan (CustomPaint) |
| `grafik_tinggi_fundus.dart` | Chart tinggi fundus (CustomPaint) |
| `info_box_edukasi_grafik.dart` | Kotak info edukasi di bawah grafik |

**Catatan:** `lib/widgets/ibu_hamil/ibu_hamil_card.dart` berisi **0 byte (kosong)** — tidak digunakan, bisa dihapus saat rekonsiliasi.

---

## 4. Endpoint Backend yang Dipakai Service

Semua via `ApiClient` (Dio):

| Method | Endpoint | Fungsi |
|--------|----------|--------|
| GET | `/api/v1/ibu-hamil/{id}` | Detail ibu hamil |
| GET | `/api/v1/ibu-hamil/{id}/pemeriksaan` (page, limit) | Riwayat pemeriksaan + pagination |
| GET | `/api/v1/ibu-hamil/{id}/pemeriksaan/{idPeriksa}` | Detail pemeriksaan terbaru (dipakai di `getBeranda`) |
| GET | `/api/v1/ibu-hamil/{id}/berat-badan-chart` | Data chart berat badan |
| GET | `/api/v1/ibu-hamil/{id}/tinggi-fundus-chart` | Data chart tinggi fundus |
| GET | `/citizens/me` (via `CitizenService.getMyProfile`) | Profil warga (nama/inisial) |

---

## 5. Infrastruktur yang Dipakai Ulang (tidak diubah)

- `lib/core/utils/cache_manager.dart` → `CacheManager<T>` untuk cache beranda & riwayat
- `lib/core/utils/module_page_mixin.dart` → `ModulePageHelper<T>` + `loadModuleData` + `buildModuleError`
- `lib/widgets/common/offline_banner.dart` → `OfflineBanner` (mode offline/cache)
- `lib/core/utils/errors.dart` → `isSessionExpired`, `friendlyError`, `ServerException`, `NetworkException`
- `lib/widgets/common/skeleton_widget.dart` → `SkeletonWidget`
- `lib/core/models/citizen/citizen_model.dart` → `ProfileResponse`

---

## 6. Checklist Rekonsiliasi Pasca-Pull

Urutan paling berisiko konflik (file diubah di sini **dan** mungkin diubah di main):

| Peringkat | File | Cara sesuaikan |
|-----------|------|----------------|
| 1 | `lib/features/pages/ibu_hamil/ibu_hamil_page.dart` | Ambil versi main sebagai dasar, terapkan ulang struktur beranda baru (PageView + cache + widgets) |
| 2 | `lib/features/themes/app_colors.dart` | Ambil versi main, tambahkan kembali 32 konstanta warna ibu hamil |
| 3 | `lib/core/models/auth/user_model.dart` | Ambil versi main, terapkan ulang normalisasi `fromString` |
| 4 | `lib/features/pages/profil/profile_page.dart` | `withOpacity` → `withValues(alpha:)` (dipakai juga di widget baru) |
| 5 | `lib/features/pages/balita/growth_chart_page.dart` | Minor, resolve otomatis; jadikan `final` jika ada variabel tak di-assign ulang |

### Langkah yang disarankan sebelum/seusai pull

1. **(Sebelum pull)** Simpan snapshot perubahan:
   ```
   git stash push -m "snapshot-modul-ibu-hamil" -- lib/
   ```
   atau buat branch cadangan: `git checkout -b backup/ibu-hamil-lokal`
2. **Pull:** `git pull origin main`
3. **Resolve conflict** file sesuai tabel di atas.
4. **Ambil kembali file baru:** `git stash pop` (jika pakai stash).
5. **Hapus `android/build/`** dari area untracked bila perlu (artefak build, sebaiknya masuk `.gitignore`).
6. **Verifikasi:** `flutter analyze` + `flutter test` sebelum lanjut.