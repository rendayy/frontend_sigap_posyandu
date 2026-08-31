# PRD — Layar Riwayat Pemeriksaan "SIGAP Posyandu"

## 1. Ringkasan
Dokumen ini mendeskripsikan spesifikasi desain layar **Riwayat Pemeriksaan** aplikasi **SIGAP Posyandu**. Layar ini menampilkan histori seluruh kunjungan ANC (Antenatal Care) ibu hamil dalam dua mode tampilan yang dapat ditukar melalui tab:

1. **Kunjungan ANC** — daftar (list) riwayat setiap kunjungan pemeriksaan secara kronologis (terbaru di atas).
2. **Grafik** — visualisasi tren indikator vital (Berat Badan, Tekanan Darah, Tinggi Fundus) dari waktu ke waktu dalam bentuk line chart.

Tujuan dokumen: menjadi acuan implementasi front-end (mobile app) agar hasil build sesuai dengan desain referensi (`Riwayat_Kujugan_ANC.png` dan `Riwayat_Kujugan_Grafik_Berat_Badan.png`).

Dokumen ini merupakan kelanjutan dari **PRD Beranda "SIGAP Posyandu"** dan menggunakan konvensi data, palet warna dasar, serta struktur teknis yang sama kecuali disebutkan berbeda.

## 2. Target Pengguna
- Ibu hamil yang terdaftar di Posyandu / Puskesmas.
- Konteks pemakaian: menelusuri riwayat pemeriksaan ANC secara detail (per kunjungan) maupun melihat tren perkembangan kondisi kesehatan (grafik) selama masa kehamilan.

## 3. Platform & Teknis
- **Platform**: Mobile (iOS/Android), portrait only.
- **Framework**: Flutter + Dart.
- **HTTP Client**: Dio (dengan interceptor JWT Bearer token + auto-refresh).
- **API Base URL**: dikonfigurasi via file `.env` (`API_BASE_URL`).
- **Endpoint prefix**: semua endpoint menggunakan `/api/v1/...`
- **Charting library**: disarankan `fl_chart` (line chart dengan area gradient, dot marker, dan grid garis putus-putus horizontal).
- **Bahasa**: Bahasa Indonesia (seluruh label & konten).

## 4. Struktur Layar (Top → Bottom)

### 4.1 Mode "Kunjungan ANC" (default/tab kiri aktif)
```
┌───────────────────────────────┐
│ Status Bar                    │
├───────────────────────────────┤
│ Header: "Riwayat Pemeriksaan" │
├───────────────────────────────┤
│ Tab Switcher: [Kunjungan ANC] [Grafik] │
├───────────────────────────────┤
│ Label ringkasan: "N kunjungan tercatat" │
├───────────────────────────────┤
│ List Card Kunjungan (scroll)  │
│  ├ Card ANC ke-6              │
│  ├ Card ANC ke-5              │
│  ├ Card ANC ke-4              │
│  └ Card ANC ke-3 ... dst      │
├───────────────────────────────┤
│ Bottom Navigation (5 tab)     │
└───────────────────────────────┘
```

### 4.2 Mode "Grafik" (tab kanan aktif)
```
┌───────────────────────────────┐
│ Status Bar                    │
├───────────────────────────────┤
│ Header: "Riwayat Pemeriksaan" │
├───────────────────────────────┤
│ Tab Switcher: [Kunjungan ANC] [Grafik] │
├───────────────────────────────┤
│ Sub-tab: [Berat Badan][Tekanan Darah][Tinggi Fundus] │
├───────────────────────────────┤
│ Card Grafik:                  │
│  ├ Judul + label "per kunjungan" │
│  ├ Sub-teks info ideal         │
│  ├ Line Chart (area+dot)       │
│  ├ Divider                     │
│  └ Ringkasan: Awal|Terakhir|Kenaikan │
├───────────────────────────────┤
│ Info Box edukasi (biru)       │
├───────────────────────────────┤
│ Bottom Navigation (5 tab)     │
└───────────────────────────────┘
```

Seluruh konten di bawah tab switcher bersifat **scrollable** (kecuali header, tab switcher jika di-pin, dan bottom nav yang fixed/sticky).

---

## 5. Spesifikasi Komponen

### 5.1 Header Layar
- Background: putih.
- Judul halaman: **"Riwayat Pemeriksaan"** (bold, ~18px, hitam/abu gelap), rata kiri.
- Tinggi: ~56px, padding horizontal 16px.
- Tidak ada tombol back eksplisit pada mock (mengikuti navigasi bottom tab "Riwayat").

### 5.2 Tab Switcher Utama
Dua pill/segmented button sejajar horizontal, lebar penuh (mengisi container, masing-masing ~50%), radius penuh (pill), tinggi ~40px.

| Tab | State Aktif | State Nonaktif |
|---|---|---|
| **Kunjungan ANC** | Background oranye solid (`#F97316`/`#FB923C`), teks putih bold | Background abu-biru muda (`#E5EDFB`), teks abu-biru (`#64748B`) |
| **Grafik** | Sama seperti di atas — hanya salah satu aktif dalam satu waktu | — |

- Tap salah satu tab → toggle konten di bawahnya (list vs grafik), state tab lain otomatis nonaktif.
- Container tab: padding ~4px, background abu sangat muda (`#F3F4F6`) sebagai track.

### 5.3 Mode "Kunjungan ANC" — Label Ringkasan
- Teks kecil abu (`#6B7280`, ~13px): `"{N} kunjungan tercatat"`, contoh `6 kunjungan tercatat`.
- `N` = total kunjungan pemeriksaan yang sudah tercatat (bukan target 6 standar ANC, melainkan jumlah aktual — pada mock kebetulan bernilai 6).

### 5.4 Mode "Kunjungan ANC" — Card Riwayat Kunjungan
List vertikal, tiap item berupa card putih, radius ~16px, shadow ringan, padding ~16px, margin bawah antar-card ~12px. Urutan **descending** berdasarkan tanggal (kunjungan terbaru di paling atas).

**Layout per card (flex row):**
- **Kolom kiri** — badge tanggal bulat/rounded-square (pink muda `#FCE7F3` sebagai background):
  - Angka tanggal (bold, besar, warna pink `#DB2777`), contoh `20`
  - Nama bulan singkat di bawahnya (kecil, warna pink), contoh `Mar`
- **Kolom kanan (flex, isi utama)**:
  - Baris 1 (flex row, space-between):
    - Kiri: judul bold `ANC ke-{no}`, contoh `ANC ke-6`
    - Kanan: badge status pill hijau `Selesai` (background `#DCFCE7`, teks `#16A34A`) + ikon chevron abu (`>`) di ujung paling kanan menandakan card dapat di-tap.
  - Baris 2: teks abu (~13px) `Usia {usia_kehamilan} minggu · {tanggal_periksa format DD Mon YYYY}`, contoh `Usia 28 minggu · 20 Mar 2025`
  - Baris 3: baris data vital sejajar horizontal (row, gap antar-item), format `Label Nilai`:
    - `BB {berat_badan} kg`
    - `TD {sistol}/{distol}`
    - `TFU {tinggi_fundus} cm`
    - Label (BB/TD/TFU) berwarna abu, nilai berwarna hitam/abu gelap semi-bold.
  - Baris 4: `LILA {lingkar_lengan} cm` (baris terpisah di bawah baris 3, style sama).
  - Baris 5: teks abu, italic/regular, single-line dengan ellipsis jika kepanjangan: `Keluhan: {keluhan}`, contoh `Keluhan: Kaki sedikit bengkak di sore hari`. Jika `keluhan` kosong/null → tampilkan `Keluhan: Tidak ada keluhan.` (sesuai data ANC ke-5 pada mock: `Tidak ada keluhan. Gerakan janin...`).

> **Catatan data LILA**: sesuai PRD Beranda, `lingkar_lengan` hanya tersedia di endpoint **detail** pemeriksaan, bukan endpoint list. Untuk menampilkan LILA di setiap card list ini, frontend perlu memanggil endpoint detail per item, atau (disarankan) backend memperluas payload endpoint list agar menyertakan `lingkar_lengan` dan `keluhan` langsung — lihat Section 8.2 untuk detail kebutuhan field tambahan.

**Interaksi card**: tap card (atau ikon chevron) → navigasi ke halaman **Detail Pemeriksaan** kunjungan tersebut (menampilkan seluruh field lengkap: letak janin, tablet Fe, rujukan, tindakan, dsb).

**Data dinamis per card:**
```json
{
  "id_periksa": "78ec2194-...",
  "no": 6,
  "tanggal_periksa": "2025-03-20",
  "usia_kehamilan": 28,
  "berat_badan": 63.0,
  "sistol": 110,
  "distol": 70,
  "tinggi_fundus": 26.0,
  "lingkar_lengan": 25.5,
  "keluhan": "Kaki sedikit bengkak di sore hari",
  "status": "Selesai"
}
```

> Field `status` pada mock selalu bernilai `"Selesai"` untuk kunjungan yang sudah lewat/tercatat. Jika di masa depan terdapat kunjungan berstatus lain (mis. dijadwalkan tapi belum periksa), badge warna dapat menyesuaikan (lihat aturan warna status di Section 6).

### 5.5 Mode "Grafik" — Sub-tab Indikator
Tiga pill sejajar horizontal di bawah tab switcher utama, ukuran lebih kecil dari tab switcher utama, mengisi lebar container secara proporsional (3 kolom).

| Sub-tab | State Aktif | State Nonaktif |
|---|---|---|
| **Berat Badan** | Background oranye solid, teks putih bold | Background abu-biru muda, teks abu |
| **Tekanan Darah** | idem | idem |
| **Tinggi Fundus** | idem | idem |

- Default aktif: **Berat Badan**.
- Tap sub-tab → mengganti seluruh konten card grafik di bawahnya (chart, satuan, rentang ideal, dan ringkasan angka) sesuai indikator yang dipilih.

### 5.6 Mode "Grafik" — Card Grafik (contoh: Berat Badan)
Card putih, radius ~16px, shadow ringan, padding ~16–20px.

**Header card (flex row, space-between):**
- Kiri: judul bold `Berat Badan (kg)`
- Kanan: teks kecil abu `per kunjungan`

**Sub-teks info (di bawah judul, abu, ~12–13px, dua baris jika perlu wrap):**
`Penambahan BB ideal: 0.3–0.5 kg/minggu di trimester 3`
> Teks ini dinamis mengikuti trimester ibu hamil saat ini (lihat Section 8.1 `ringkasan_kehamilan.trimester`). Referensi ideal per trimester dapat di-hardcode di frontend atau diambil dari CMS, mengikuti pola Banner Edukasi pada PRD Beranda.

**Line Chart:**
- Sumbu Y (kiri): skala nilai berat badan (kg), auto-scale mengikuti data min–max dengan sedikit padding, contoh gridline `54, 58, 62, 68`.
- Sumbu X (bawah): usia kehamilan per titik data dalam minggu, format `{n}mgg`, contoh `8mgg, 12mgg, 16mgg, 20mgg, 28mgg`. Jumlah titik = jumlah kunjungan yang sudah tercatat (bukan interval tetap).
- Garis (line): warna pink/magenta solid (`#EC4899` atau senada gradient hero card Beranda `#FF6F91`→`#E63950`), lebar ~2–3px, dengan **dot marker** bulat solid warna sama di tiap titik data.
- Area di bawah garis: gradient fill dari pink transparan (atas, dekat garis) memudar ke transparan penuh (bawah).
- Grid horizontal: garis putus-putus tipis abu muda sebagai referensi skala Y.
- Tidak ada grid vertikal.
- Chart bersifat **read-only** (tanpa interaksi zoom/pan pada versi ini); opsional: tap-and-hold pada titik menampilkan tooltip nilai eksak + tanggal.

**Divider** tipis abu horizontal di bawah chart.

**Ringkasan angka (flex row, 3 kolom rata tengah):**
| Kolom | Label (abu, kecil) | Nilai (bold, besar) |
|---|---|---|
| 1 | `Awal` | `{nilai_awal} kg`, warna hitam/abu gelap, contoh `56 kg` |
| 2 | `Terakhir` | `{nilai_terakhir} kg`, warna pink (`#DB2777`/senada line chart), contoh `63 kg` |
| 3 | `Kenaikan` | `+{selisih} kg`, warna hijau (`#16A34A`), contoh `+7.0 kg` |

- `Awal` = nilai pada kunjungan pertama yang tercatat dalam periode grafik.
- `Terakhir` = nilai pada kunjungan paling baru.
- `Kenaikan` = `Terakhir - Awal`, ditampilkan dengan 1 desimal dan prefix `+` bila positif (bila negatif, gunakan warna merah/oranye peringatan, mis. pada indikator yang idealnya tidak boleh naik terlalu drastis).

**Data dinamis card grafik:**
```json
{
  "indikator": "berat_badan",
  "satuan": "kg",
  "info_ideal": "Penambahan BB ideal: 0.3-0.5 kg/minggu di trimester 3",
  "data_points": [
    { "usia_kehamilan": 8,  "nilai": 56.0, "tanggal": "2025-01-09" },
    { "usia_kehamilan": 12, "nilai": 57.8, "tanggal": "2025-01-09" },
    { "usia_kehamilan": 16, "nilai": 59.2, "tanggal": "2025-02-06" },
    { "usia_kehamilan": 20, "nilai": 61.0, "tanggal": "2025-02-27" },
    { "usia_kehamilan": 28, "nilai": 63.0, "tanggal": "2025-03-20" }
  ],
  "ringkasan": {
    "awal": 56.0,
    "terakhir": 63.0,
    "kenaikan": 7.0
  }
}
```

### 5.7 Mode "Grafik" — Sub-tab "Tekanan Darah" (variasi konten)
Menggunakan struktur card yang sama seperti Section 5.6, dengan penyesuaian:
- Judul: `Tekanan Darah (mmHg)`
- Kemungkinan **dua garis** pada satu chart (sistol & distol) dengan warna berbeda (mis. merah untuk sistol, oranye/pink muda untuk distol) + legenda kecil di atas chart.
- Sub-teks info: rentang normal, contoh `Tekanan darah normal: 90/60 – 120/80 mmHg`.
- Ringkasan angka: `Awal` / `Terakhir` menampilkan format `sistol/distol` (bukan angka tunggal), kolom `Kenaikan` dapat diganti label `Perubahan` atau disembunyikan bila tidak relevan untuk dua-nilai sekaligus.

> **Catatan implementasi**: Karena tekanan darah memiliki dua nilai, tim desain perlu memastikan varian visual chart dua-garis ini sebelum development — dokumen ini memberi struktur data namun rincian visual pastinya (posisi legenda, dsb.) mengikuti mock tambahan bila tersedia.

### 5.8 Mode "Grafik" — Sub-tab "Tinggi Fundus" (variasi konten)
Struktur sama seperti Section 5.6:
- Judul: `Tinggi Fundus (cm)`
- Sub-teks info: referensi normal, contoh `TFU normal ≈ usia kehamilan (minggu) ± 2 cm`.
- Line chart tunggal, warna dapat mengikuti aksen oranye (senada kartu Tinggi Fundus pada Beranda: `#F97316`).
- Ringkasan: `Awal` / `Terakhir` / `Kenaikan` dalam cm.

### 5.9 Info Box Edukasi (Mode Grafik)
Card dengan background biru sangat muda (`#EFF6FF`), radius ~12px, padding ~12–14px, border tipis biru muda opsional.
- Ikon informasi bulat (`ℹ️` / `info_outline`) warna biru (`#3B82F6`) di kiri.
- Teks abu gelap/biru tua (~13px): edukasi kontekstual sesuai indikator aktif.
  - Berat Badan: `Kenaikan berat badan selama kehamilan umumnya 11–16 kg untuk BMI normal. Pantau terus setiap kunjungan ANC.`
  - Tekanan Darah & Tinggi Fundus: konten setara, disesuaikan (mis. peringatan preeklampsia untuk tekanan darah tinggi, atau makna deviasi TFU terhadap usia kehamilan).

Konten ini idealnya diambil dari CMS agar dapat diperbarui tanpa rilis ulang aplikasi (pola sama dengan Banner Edukasi Trimester di PRD Beranda).

### 5.10 Bottom Navigation
Identik dengan PRD Beranda — 5 tab (Beranda, Riwayat, Jadwal, Notifikasi, Profil), background putih, shadow tipis di atas, fixed, safe-area aware. Pada layar ini, tab **Riwayat** dalam state aktif (ikon jam, warna biru `#2F6FED`/`#3B82F6`).

---

## 6. Palet Warna

| Elemen | Warna |
|---|---|
| Tab aktif (Kunjungan ANC / Grafik / sub-tab) | background `#F97316` (oranye), teks `#FFFFFF` |
| Tab nonaktif | background `#E5EDFB`, teks `#64748B` |
| Track/container tab switcher | `#F3F4F6` |
| Badge tanggal (list ANC) | background `#FCE7F3`, angka & bulan `#DB2777` |
| Badge status "Selesai" | background `#DCFCE7`, teks `#16A34A` |
| Line chart Berat Badan | garis `#EC4899` (atau gradient `#FF6F91` → `#E63950`), area fill pink transparan menurun |
| Line chart Tinggi Fundus | garis `#F97316` |
| Line chart Tekanan Darah (sistol/distol) | `#EF4444` (sistol) / `#FB923C` (distol) — indikatif, sesuaikan mock final |
| Ringkasan "Terakhir" | teks `#DB2777` |
| Ringkasan "Kenaikan" positif | teks `#16A34A` |
| Ringkasan "Kenaikan" negatif/waspada | teks `#DC2626` atau `#F97316` |
| Info box edukasi | background `#EFF6FF`, ikon & aksen `#3B82F6`, teks `#1E3A8A`/`#374151` |
| Abu teks sekunder | `#6B7280` |
| Teks utama | `#111827` |
| Background layar | `#F9FAFB` |
| Card background | `#FFFFFF` |
| Grid horizontal chart | `#E5E7EB` (putus-putus) |

## 7. Tipografi (perkiraan)
- Judul halaman (`Riwayat Pemeriksaan`): 18–20px, bold.
- Judul card (`ANC ke-6`, `Berat Badan (kg)`): 16px, bold/semibold.
- Angka besar badge tanggal: 18–20px, bold.
- Nilai ringkasan grafik (`Awal`, `Terakhir`, `Kenaikan`): 18–20px, bold.
- Body/label data vital (BB, TD, TFU, LILA): 13px, medium untuk nilai, regular abu untuk label.
- Sub-teks info & keluhan: 12–13px, regular, abu.
- Label sumbu chart & bulan badge tanggal: 11–12px, medium.

## 8. Struktur Data API

### 8.1 Konteks — Ringkasan Kehamilan
Sama seperti PRD Beranda Section 8.1, dipakai untuk menentukan `trimester` (menentukan teks info ideal penambahan BB) dan validasi status masing-masing indikator.

### 8.2 Riwayat Pemeriksaan — List (untuk tab "Kunjungan ANC")
**Endpoint:** `GET /api/v1/ibu-hamil/{id_ibu_hamil}/pemeriksaan`

```json
{
  "success": true,
  "data": [
    {
      "id_periksa": "78ec2194-...",
      "no": 6,
      "tanggal_periksa": "2025-03-20",
      "usia_kehamilan": 28,
      "berat_badan": 63.0,
      "sistol": 110,
      "distol": 70,
      "tinggi_fundus": 26.0,
      "denyut_jantung": 118,
      "tindakan": "-"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 6,
    "total_pages": 1
  }
}
```

> **Kebutuhan tambahan untuk layar ini**: sesuai Section 5.4, card list membutuhkan `lingkar_lengan` dan `keluhan` yang **saat ini tidak tersedia** di endpoint list (hanya ada di endpoint detail). Rekomendasi:
> - **Opsi A (disarankan)**: backend menambahkan kedua field tersebut ke response list agar tidak perlu N+1 request per card.
> - **Opsi B (fallback)**: frontend melakukan fetch detail (`/pemeriksaan/{id_periksa}`) untuk tiap item yang terlihat di viewport (lazy-load saat scroll), dengan caching agar tidak berulang saat re-render.
>
> `pagination.total` = sumber jumlah untuk label `"{N} kunjungan tercatat"`.

### 8.3 Riwayat Pemeriksaan — Detail (navigasi dari tap card)
**Endpoint:** `GET /api/v1/ibu-hamil/{id_ibu_hamil}/pemeriksaan/{id_periksa}`

Struktur identik dengan PRD Beranda Section 8.3 — dipakai penuh saat user tap salah satu card di list untuk membuka halaman Detail Pemeriksaan.

### 8.4 Grafik Berat Badan
**Endpoint:** `GET /api/v1/ibu-hamil/{id_ibu_hamil}/berat-badan-chart`

```json
{
  "success": true,
  "data": {
    "satuan": "kg",
    "points": [
      { "usia_kehamilan": 8,  "nilai": 56.0, "tanggal": "2025-01-09" },
      { "usia_kehamilan": 12, "nilai": 57.8, "tanggal": "2025-01-09" },
      { "usia_kehamilan": 16, "nilai": 59.2, "tanggal": "2025-02-06" },
      { "usia_kehamilan": 20, "nilai": 61.0, "tanggal": "2025-02-27" },
      { "usia_kehamilan": 28, "nilai": 63.0, "tanggal": "2025-03-20" }
    ],
    "ringkasan": { "awal": 56.0, "terakhir": 63.0, "kenaikan": 7.0 }
  }
}
```

### 8.5 Grafik Tinggi Fundus
**Endpoint:** `GET /api/v1/ibu-hamil/{id_ibu_hamil}/tinggi-fundus-chart`

Struktur response mengikuti pola yang sama dengan Section 8.4, `satuan: "cm"`.

### 8.6 Grafik Tekanan Darah
**Endpoint:** *(belum terkonfirmasi di PRD Beranda — perlu endpoint baru, contoh usulan)* `GET /api/v1/ibu-hamil/{id_ibu_hamil}/tekanan-darah-chart`

```json
{
  "success": true,
  "data": {
    "satuan": "mmHg",
    "points": [
      { "usia_kehamilan": 16, "sistol": 105, "distol": 70, "tanggal": "2025-01-09" },
      { "usia_kehamilan": 20, "sistol": 108, "distol": 72, "tanggal": "2025-02-06" },
      { "usia_kehamilan": 28, "sistol": 110, "distol": 70, "tanggal": "2025-03-20" }
    ],
    "ringkasan": { "awal": "105/70", "terakhir": "110/70" }
  }
}
```
> Endpoint ini perlu dikonfirmasi ketersediaannya ke tim backend; belum tercantum di referensi endpoint PRD Beranda.

## 9. Error Handling
Mengikuti standar yang sama dengan PRD Beranda Section 9 (`ServerException`, `NetworkException`, tabel friendly messages berdasarkan status code).

Tambahan khusus layar ini:
- **List kosong** (belum ada riwayat pemeriksaan): tampilkan empty state ramah, mis. ilustrasi + teks `"Belum ada riwayat pemeriksaan"`, bukan card kosong atau list blank.
- **Grafik dengan data < 2 titik**: line chart tidak bisa menggambarkan tren; tampilkan pesan `"Data belum cukup untuk menampilkan grafik. Minimal 2 kunjungan diperlukan."` menggantikan area chart.
- **Field LILA/keluhan gagal dimuat** (bila menggunakan Opsi B pada Section 8.2): tampilkan `-` pada baris tersebut tanpa memblokir render card lainnya.

## 10. Perilaku & Interaksi
- **Tab switcher utama** (`Kunjungan ANC` / `Grafik`): tap untuk berpindah mode; state tab tidak reset scroll position masing-masing daftar/chart bila user bolak-balik dalam satu sesi (opsional, sesuai keputusan tim).
- **Sub-tab grafik** (`Berat Badan` / `Tekanan Darah` / `Tinggi Fundus`): tap untuk mengganti indikator yang ditampilkan; default `Berat Badan` setiap kali masuk ke mode Grafik.
- **Tap card kunjungan** → navigasi ke halaman **Detail Pemeriksaan**.
- **Pull-to-refresh** pada kedua mode → memuat ulang data list/chart dari server.
- **Scroll**: list kunjungan mendukung infinite-scroll/pagination bila total kunjungan banyak (gunakan `pagination.total_pages` dari Section 8.2); pada mock (6 data) seluruhnya kemungkinan muat dalam satu page.
- **Bottom nav** → tab `Riwayat` aktif secara default saat berada di layar ini.

## 11. Non-Functional Requirements
- **Loading state**: skeleton card untuk list kunjungan; skeleton/placeholder area chart (garis putus-putus abu) untuk mode Grafik saat data belum termuat.
- **Empty/error state**: sesuai Section 9.
- **Performa chart**: hindari re-render seluruh chart saat scroll; gunakan `RepaintBoundary` bila menggunakan `fl_chart` di Flutter.
- **Aksesibilitas**: kontras teks pada badge tanggal & badge status minimal AA; target tap card list dan tab switcher ≥44x44px; nilai numerik pada chart tersedia sebagai semantic label untuk screen reader (mis. via tooltip/dialog "Lihat data sebagai tabel").
- **Localization-ready**: seluruh string (label chart, info edukasi) sebaiknya di-external-kan (i18n) meski saat ini hanya Bahasa Indonesia.

## 12. Aset Ikon yang Dibutuhkan
Chevron kanan (`>`) pada card list, ikon info (`info_outline`) pada info box edukasi, 5 ikon bottom nav (rumah, jam/riwayat, kalender, lonceng, profil) — identik dengan PRD Beranda.

---

## 13. Referensi Endpoint

| Endpoint | Method | Auth | Role | Deskripsi |
|---|---|---|---|---|
| `/api/v1/ibu-hamil/{id}/pemeriksaan` | GET | Bearer token | admin, kader, koordinator, user | Riwayat pemeriksaan (list) — sumber tab "Kunjungan ANC" |
| `/api/v1/ibu-hamil/{id}/pemeriksaan/{id_periksa}` | GET | Bearer token | admin, kader, koordinator, user | Detail pemeriksaan (field lengkap, termasuk `lingkar_lengan`, `keluhan`) |
| `/api/v1/ibu-hamil/{id}/berat-badan-chart` | GET | Bearer token | admin, kader, koordinator, user | Grafik Berat Badan |
| `/api/v1/ibu-hamil/{id}/tinggi-fundus-chart` | GET | Bearer token | admin, kader, koordinator, user | Grafik Tinggi Fundus |
| `/api/v1/ibu-hamil/{id}/tekanan-darah-chart` | GET | Bearer token | admin, kader, koordinator, user | *(usulan, perlu konfirmasi backend)* Grafik Tekanan Darah |
| `/api/v1/ibu-hamil/{id}` | GET | Bearer token | admin, kader, koordinator, user | Detail ibu hamil (untuk konteks trimester & info ideal) |

Base URL: dari `API_BASE_URL` di `.env`

---

*Catatan: Dokumen ini disusun berdasarkan mock desain `Riwayat_Kujugan_ANC.png` dan `Riwayat_Kujugan_Grafik_Berat_Badan.png`. Sub-tab "Tekanan Darah" dan "Tinggi Fundus" pada mode Grafik diekstrapolasi dari pola visual "Berat Badan" karena mock yang tersedia hanya mencakup satu varian — mohon konfirmasi ke tim desain bila terdapat mock tambahan untuk kedua sub-tab tersebut sebelum development dimulai.*
