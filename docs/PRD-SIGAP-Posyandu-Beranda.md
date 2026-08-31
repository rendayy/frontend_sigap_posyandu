# PRD — Layar Beranda "SIGAP Posyandu"

## 1. Ringkasan
Dokumen ini mendeskripsikan spesifikasi desain layar **Beranda (Home)** aplikasi **SIGAP Posyandu**, sebuah aplikasi mobile untuk memantau kesehatan ibu hamil (antenatal care / ANC). Layar ini menampilkan ringkasan usia kehamilan, indikator kesehatan terakhir, jadwal pemeriksaan berikutnya, dan edukasi kontekstual berdasarkan trimester.

Tujuan dokumen: menjadi acuan implementasi front-end (mobile app) agar hasil build sesuai dengan desain referensi (`Home.png`).

## 2. Target Pengguna
- Ibu hamil yang terdaftar di Posyandu / Puskesmas.
- Konteks pemakaian: melihat status kehamilan diri sendiri secara ringkas setiap membuka aplikasi.

## 3. Platform & Teknis
- **Platform**: Mobile (iOS/Android), portrait only.
- **Framework**: Flutter + Dart.
- **HTTP Client**: Dio (dengan interceptor JWT Bearer token + auto-refresh).
- **API Base URL**: dikonfigurasi via file `.env` (`API_BASE_URL`), contoh: `http://192.168.0.184:5000`
- **Endpoint prefix**: semua endpoint menggunakan `/api/v1/...`
- **Referensi ukuran layar**: standar mobile ~375–414px lebar.
- **Bahasa**: Bahasa Indonesia (seluruh label & konten).

## 4. Struktur Layar (Top → Bottom)

```
┌───────────────────────────────┐
│ Status Bar                    │
├───────────────────────────────┤
│ App Header (logo + notif)     │
├───────────────────────────────┤
│ Greeting (avatar + nama + tag)│
├───────────────────────────────┤
│ Card: Usia Kehamilan (hero)   │
├───────────────────────────────┤
│ Row 2 Card: Berat Badan | TD  │
├───────────────────────────────┤
│ Row 3 Card: LILA|Fundus|ANC   │
├───────────────────────────────┤
│ Section: Jadwal Berikutnya    │
│  └ Card Jadwal Pemeriksaan    │
├───────────────────────────────┤
│ Banner Edukasi Trimester      │
├───────────────────────────────┤
│ Bottom Navigation (5 tab)     │
└───────────────────────────────┘
```

Seluruh layar bisa **scrollable** (kecuali header & bottom nav yang fixed/sticky).

---

## 5. Spesifikasi Komponen

### 5.1 App Header
- Background: putih.
- Kiri: ikon logo bulat biru (♡/lambang) + teks **"SIGAP Posyandu"** (bold, hitam/abu gelap).
- Kanan: ikon lonceng notifikasi dalam lingkaran abu muda, dengan **badge titik oranye** (indikator notifikasi belum dibaca) di pojok kanan atas ikon.
- Tinggi: ~56–64px, padding horizontal 16px.

### 5.2 Greeting Section
- Avatar bulat (56x56) dengan gradasi pink→merah, berisi inisial nama.
- Teks kanan avatar:
  - Baris 1 (abu, regular): `Selamat pagi,` — dinamis sesuai waktu (pagi/siang/sore/malam).
  - Baris 2 (bold, besar): Nama pengguna, contoh `Siti Rahayu`.
  - Baris 3: badge kecil dengan ikon hati (♥) + label status, contoh `Ibu Hamil`, warna pink.

### 5.3 Hero Card — Usia Kehamilan
Card besar dengan **gradient pink → merah/magenta**, sudut membulat (radius ~20px), padding ~20px, teks putih.

Isi:
- Label kecil: `Usia Kehamilan`
- Ikon bayi dalam lingkaran translucent putih (pojok kanan atas).
- Angka besar (bold, ~40px): `30` + satuan `minggu`.
- Sub-teks: `Trimester 3 · 10 minggu lagi`
- **Progress bar** horizontal:
  - Label kiri: `Minggu 1`
  - Label tengah: persentase, contoh `75%`
  - Label kanan: `Minggu 40`
  - Bar terisi proporsional terhadap `(usia_kehamilan / 40) * 100%`, warna putih solid di atas track putih semi-transparan.
- Divider tipis putih transparan.
- Baris bawah (flex row, space-between):
  - Kiri: label `Hari Perkiraan Lahir (HPL)` + tanggal bold `10 Juli 2025`.
  - Kanan: badge bulat/pill translucent berisi hitungan mundur: `-74` (besar) + `hari lagi` (kecil).

**Data dinamis — dari `ringkasan_kehamilan` di endpoint detail:**
```json
{
  "usia_kehamilan_minggu": 30,
  "trimester": 3,
  "minggu_tersisa": 10,
  "total_minggu_kehamilan": 40,
  "progress_persen": 75,
  "hpl": "2025-07-10",
  "hari_menuju_hpl": 74
}
```
> Field `usia_kehamilan` diambil dari `ringkasan_kehamilan.usia_kehamilan` pada response detail ibu hamil (bukan field `usia_kehamilan_saat_ini`).

### 5.4 Kartu Statistik Baris 2 (2 kolom)
Dua card putih dengan border tipis/shadow ringan, radius ~16px, isi rata kiri.
Kedua card memiliki **tinggi yang sama** — diimplementasikan dengan `CrossAxisAlignment.stretch` pada Row induk.

**Card A — Berat Badan**
- Ikon timbangan warna biru dalam lingkaran biru muda.
- Label: `Berat Badan`
- Nilai besar bold: `63` + satuan kecil `kg`
- Baris indikator: ikon panah naik + teks hijau `+2 kg dari pemeriksaan lalu`
  - Teks delta menggunakan `Flexible` widget agar wrap ke baris baru jika tidak muat dalam satu baris (bukan overflow/ellipsis).
- Badge status: `Normal` (pill hijau, teks hijau, background hijau muda)

**Card B — Tekanan Darah**
- Ikon pulse/heartbeat warna merah dalam lingkaran merah muda.
- Label: `Tekanan Darah`
- Nilai besar bold: `110/70`
- Sub-teks abu: `mmHg · 20 Mar 2025` (tanggal pemeriksaan terakhir)
- Badge status: `Normal` (pill hijau)

> Badge status warna dinamis: hijau = Normal, kuning = Perlu Perhatian, merah = Waspada.

### 5.5 Kartu Statistik Baris 3 (3 kolom)
Tiga card kecil sejajar, masing-masing lebih ringkas (ikon + label + nilai).

| Card | Ikon | Label | Nilai |
|---|---|---|---|
| 1 | Penggaris (pink) | `LILA` | `25.5 cm` atau `-` jika null |
| 2 | Panah tren (oranye) | `Tinggi Fundus` | `26 cm` atau `-` jika null |
| 3 | `check_circle_outline` / `verified` (hijau) | `Kunjungan ANC` | Angka saja bila < 6, `"7 Lengkap"` bila ≥ 6 |

**Ketentuan Kunjungan ANC:**
- **Sumber data**: `pagination.total` dari response list `/pemeriksaan` (bukan `items.length`).
- **Standar target**: 6 kali kunjungan ANC.
- `kunjunganSelesai < 6` → tampilkan angka saja, contoh `3`
- `kunjunganSelesai >= 6` → tampilkan `"{angka} Lengkap"`, contoh `7 Lengkap`; ikon berubah jadi `verified`

> LILA = Lingkar Lengan Atas (indikator status gizi ibu hamil). Data LILA hanya tersedia di endpoint **detail** pemeriksaan (`/pemeriksaan/{id_periksa}`), bukan di endpoint list. Implementasi: setelah mendapat list, fetch detail untuk item terbaru.

### 5.6 Section: Jadwal Pemeriksaan Berikutnya
- Judul section (bold, ~16px): `Jadwal Pemeriksaan Berikutnya`
- Card putih di bawahnya:
  - Ikon lingkaran pink (mis. ikon kesehatan ibu/bayi) di kiri.
  - Judul bold: `Pemeriksaan ANC ke-7`
  - Badge biru muda di kanan atas: `Akan Datang`
  - Baris info kalender: ikon kalender + tanggal `10 Apr 2025` — sejajar kanan: `16 hari lagi`
  - Baris lokasi: ikon pin + `Puskesmas Kec. Suka`

**Data dinamis:**
```json
{
  "kunjungan_ke": 7,
  "status": "Akan Datang",
  "tanggal": "2025-04-10",
  "hari_lagi": 16,
  "lokasi": "Puskesmas Kec. Suka"
}
```

### 5.7 Banner Edukasi (Tips Trimester)
- Card dengan background krem/kuning muda, border/aksen oranye tipis di kiri atau seluruh border, radius ~16px.
- Header: ikon sparkle/bintang + judul bold oranye: `Trimester 3`
- Body teks (abu gelap/oranye tua): paragraf edukasi singkat sesuai trimester berjalan.

Konten ini bersifat hardcode di frontend berdasarkan trimester (1/2/3). Idealnya diambil dari CMS agar bisa diperbarui tanpa rilis ulang aplikasi.

### 5.8 Bottom Navigation
5 tab, ikon + label kecil di bawah ikon:
1. **Beranda** (rumah) — *state aktif*, warna biru (icon + label).
2. **Riwayat** (jam) — abu-abu (inactive).
3. **Jadwal** (kalender) — abu-abu.
4. **Notifikasi** (lonceng) — abu-abu.
5. **Profil** (orang) — abu-abu.

Style: background putih, shadow tipis di atas, fixed di bawah layar, safe-area aware.

---

## 6. Palet Warna

| Elemen | Warna |
|---|---|
| Primary gradient (hero card) | `#FF6F91` → `#E63950` |
| Aksen biru (tab aktif, ikon berat badan) | `#2F6FED` / `#3B82F6` |
| Hijau status Normal | teks `#16A34A`, background `#DCFCE7` |
| Oranye (badge notif, tren, tips) | `#F97316` |
| Kuning krem (banner edukasi) | background `#FEF3C7`, teks `#92400E` |
| Abu teks sekunder | `#6B7280` |
| Teks utama | `#111827` |
| Background layar | `#F9FAFB` |
| Card background | `#FFFFFF` |
| ANC / LILA bg | `#F0FDF4` |
| ANC / LILA icon | `#16A34A` |
| Fundus bg | `#FFF7ED` |
| Fundus icon | `#F97316` |

## 7. Tipografi (perkiraan)
- Judul besar (angka usia kehamilan): 36–40px, bold.
- Judul card / nama: 16–18px, semibold/bold.
- Body / label: 13–14px, regular.
- Label kecil (sub-label, satuan): 11–12px, medium, warna abu.

## 8. Struktur Data API (Aktual)

### 8.1 Detail Ibu Hamil
**Endpoint:** `GET /api/v1/ibu-hamil/{id_ibu_hamil}`

```json
{
  "success": true,
  "data": {
    "id_ibu_hamil": "c79e5748-ab42-4a42-b253-4eb8c844c257",
    "nama": "SITI",
    "nik": "3201092234567003",
    "hpht": "2026-02-20",
    "hpl": "2026-10-20",
    "gravida": 3,
    "para": 2,
    "abortus": 1,
    "tinggi_badan": null,
    "golongan_darah": null,
    "riwayat_penyakit": "Hipertensi",
    "tempat_lahir": "Sido",
    "tanggal_lahir": "2002-03-02",
    "no_hp": "",
    "hubungan_keluarga": "istri",
    "status_aktif": "aktif",
    "ringkasan_kehamilan": {
      "usia_kehamilan": 41,
      "trimester": 3,
      "status_berat_badan": "normal",
      "status_lingkar_lengan": "kurang",
      "status_tekanan_darah": "normal",
      "tablet_fe": "ya",
      "rujukan": "tidak"
    }
  }
}
```

> **Catatan:** `usia_kehamilan` berada di dalam `ringkasan_kehamilan`, bukan field langsung. Model Flutter memetakan: `json['ringkasan_kehamilan']['usia_kehamilan']`.

### 8.2 Pemeriksaan — List
**Endpoint:** `GET /api/v1/ibu-hamil/{id_ibu_hamil}/pemeriksaan`

```json
{
  "success": true,
  "data": [
    {
      "id_periksa": "78ec2194-...",
      "no": 1,
      "tanggal_periksa": "2026-07-10",
      "usia_kehamilan": 41,
      "berat_badan": 55.0,
      "sistol": 120,
      "distol": 67,
      "tinggi_fundus": 41.0,
      "denyut_jantung": 125,
      "tindakan": "banyak tidur"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 5,
    "total": 7,
    "total_pages": 2
  }
}
```

> **Catatan:** Endpoint ini **tidak menerima** query parameter `page`/`per_page`. Field yang dikembalikan **terbatas** — tidak termasuk `lingkar_lengan`, `keluhan`, `letak_janin`, `tablet_fe`, `created_at`, `updated_at`.

### 8.3 Pemeriksaan — Detail
**Endpoint:** `GET /api/v1/ibu-hamil/{id_ibu_hamil}/pemeriksaan/{id_periksa}`

```json
{
  "success": true,
  "data": {
    "id_periksa": "78ec2194-...",
    "tanggal_periksa": "2026-07-10",
    "usia_kehamilan": 41,
    "berat_badan": 55.0,
    "sistol": 120,
    "distol": 67,
    "lingkar_lengan": 21.0,
    "tinggi_fundus": 41.0,
    "letak_janin": "sungsang",
    "denyut_jantung": 125,
    "keluhan": "sakit dikit",
    "tindakan": "banyak tidur",
    "tablet_fe": "ya",
    "rujukan": "tidak",
    "created_at": "2026-07-25T14:39:31",
    "updated_at": "2026-07-25T17:55:47"
  }
}
```

> **Catatan:** Endpoint detail memiliki **field lebih lengkap** dari list. Data `lingkar_lengan` hanya tersedia di sini. Untuk mengisi card LILA di beranda, frontend melakukan fetch detail untuk item pemeriksaan terbaru setelah mendapat list.

## 9. Error Handling

### 9.1 Exception Classes
- `ServerException` — error dari server (4xx/5xx), menampilkan pesan sesuai status code.
- `NetworkException` — error koneksi (timeout, DNS, dll), menampilkan `"Tidak dapat terhubung ke server. Periksa koneksi internet Anda."`

### 9.2 Friendly Messages (ServerException)
| Status Code | Pesan |
|---|---|
| 401 | Sesi Anda telah habis. Silakan login kembali. |
| 403 | Anda tidak memiliki akses ke data ini. |
| 404 | Data tidak ditemukan. |
| 409 | Terjadi bentrokan data. Silakan coba lagi. |
| 422 | Data yang Anda masukkan tidak valid. |
| 429 | Terlalu banyak permintaan. Silakan coba beberapa saat lagi. |
| 500+ | Terjadi gangguan pada server. Silakan coba lagi nanti. |

### 9.3 Catatan Implementasi
- `getBeranda()` memiliki catch blok sendiri yang perlu menangani `DioException` dengan baik (termasuk error 422/404) agar tidak fallback ke `NetworkException`.
- Semua service melempar `ServerException` jika response memiliki `error` object, atau `NetworkException` jika koneksi gagal.

## 10. User Category Routing

Setelah login, user diarahkan ke halaman berdasarkan `kategori_anggota` dari response login.

| API `kategori_anggota` | Enum `UserCategory` | Route |
|---|---|---|
| `"balita"` | `balita` | `/balita` |
| `"remaja"` | `remaja` | `/remaja` |
| `"lansia"` | `lansia` | `/lansia` |
| `"posbindu"` | `posbindu` | `/posbindu` |
| `"ibu_hamil"` / `"ibuHamil"` / `"Ibu Hamil"` | `ibuHamil` | `/ibu-hamil` |

> **Normalisasi:** Method `fromString()` menghapus underscore (`_`) dan membandingkan secara case-insensitive. Contoh: `"ibu_hamil"` → `"ibuhamil"` → cocok dengan `"ibuHamil".toLowerCase()`.

## 11. Perilaku & Interaksi
- **Pull-to-refresh**: menarik ke bawah untuk memuat ulang data dari server (3 panggilan paralel: detail, list pemeriksaan, profile).
- **Tap notifikasi bell** → navigasi ke tab Notifikasi.
- **Tap card jadwal pemeriksaan** → navigasi ke halaman detail jadwal.
- **Tap avatar/nama** → navigasi ke halaman Profil.
- **Bottom nav** → berpindah tab, state aktif mengikuti halaman yang sedang dibuka.
- Semua angka dihitung otomatis dari tanggal HPHT atau HPL, bukan input manual di layar ini.

## 12. Non-Functional Requirements
- **Loading state**: skeleton/placeholder untuk tiap card saat data belum termuat.
- **Empty/error state**: jika data pemeriksaan/vital belum ada, tampilkan pesan ramah (bukan card kosong).
- **Aksesibilitas**: kontras teks di atas gradient minimal AA, ukuran tap target tombol/nav ≥44x44px.
- **Localization-ready**: seluruh string sebaiknya di-external-kan (i18n) meski saat ini hanya Bahasa Indonesia.

## 13. Aset Ikon yang Dibutuhkan
Logo aplikasi, lonceng notifikasi, bayi (kehamilan), tas/timbangan (berat badan), pulse/heartbeat (tekanan darah), penggaris (LILA), panah tren naik, `verified` / `check_circle_outline` (ANC), kalender, pin lokasi, sparkle (tips), serta 5 ikon bottom nav (rumah, jam/riwayat, kalender, lonceng, profil).

---

## 14. Referensi Endpoint

| Endpoint | Method | Auth | Role | Deskripsi |
|---|---|---|---|---|
| `/api/v1/ibu-hamil/{id}` | GET | Bearer token | admin, kader, koordinator, user | Detail ibu hamil |
| `/api/v1/ibu-hamil/{id}/pemeriksaan` | GET | Bearer token | admin, kader, koordinator, user | Riwayat pemeriksaan (list, field terbatas) |
| `/api/v1/ibu-hamil/{id}/pemeriksaan/{id_periksa}` | GET | Bearer token | admin, kader, koordinator, user | Detail pemeriksaan (field lengkap) |
| `/api/v1/ibu-hamil/{id}/berat-badan-chart` | GET | Bearer token | admin, kader, koordinator, user | Grafik berat badan |
| `/api/v1/ibu-hamil/{id}/tinggi-fundus-chart` | GET | Bearer token | admin, kader, koordinator, user | Grafik tinggi fundus |
| `/api/v1/citizens/me` | GET | Bearer token | user | Profil warga |

Base URL: dari `API_BASE_URL` di `.env`

---

*Catatan: Dokumen ini diperbarui berdasarkan implementasi aktual. Jika ada perubahan API dari backend, sesuaikan struktur data di Section 8.*
