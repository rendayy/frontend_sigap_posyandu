# Plan: Modul Balita — Fase 3: Detail Pemeriksaan Balita

**Status:** ✅ Disetujui

---

## A. Aturan & Referensi

| Aturan | Detail |
|--------|--------|
| **Arsitektur** | Feature-First: Page → Service → ApiClient → Backend |
| **State** | Local state di `StatefulWidget` (tanpa stale-while-revalidate, langsung fetch tiap push) |
| **Font** | Google Fonts Plus Jakarta Sans |
| **Package** | `package:frontend_posyandu` |
| **Naming** | file: `snake_case`, class: `PascalCase`, var/func: `camelCase` |
| **Import** | `package:` imports |
| **Simpan data** | `CacheManager<T>` + `SharedPreferences` |
| **Navigasi** | `Navigator.push` (bukan `IndexedStack`) |
| **Standar Modul** | Lihat `standar-modul.md` (skeleton, cache, offline banner, pull-to-refresh, 401 redirect) |

---

## B. API Endpoint

### B.1 Login (existing)

POST `/api/v1/auth/login` — sudah ada dan berfungsi.

### B.2 GET `/api/balita/{balita_id}/pemantauan/{pemantauan_id}`

**Response:**
```json
{
    "data": {
        "berat": 12.8,
        "created_at": "2026-07-05T01:41:35",
        "id_cabang": "7a072f71-...",
        "id_kader": "8a291ec0-...",
        "id_pantau": "bc6261a7-...",
        "imunisasi": "BCG, DPT, Polio, Campak",
        "keluhan": "Keluhan diperbarui",
        "lingkar_kepala": 48.8,
        "lingkar_lengan": 18.2,
        "nama_kader": "Zidan Kusuma",
        "nama_posyandu": "Posyandu Melati",
        "saran": "Saran diperbarui",
        "status_gizi": "gizi_baik",
        "tanggal_pantau": "2026-06-15",
        "tinggi": 86.0,
        "updated_at": "2026-07-19T13:27:51",
        "usia_bulan": 6,
        "vitamin_a": "ya"
    },
    "success": true,
    "timestamp": "..."
}
```

### B.3 Model — `PemantauanBalitaDetailResponse`

| JSON Field | Dart Field | Tipe |
|---|---|---|
| `id_pantau` | `idPantau` | `String` |
| `id_kader` | `idKader` | `String` |
| `id_cabang` | `idCabang` | `String` |
| `nama_kader` | `namaKader` | `String` |
| `nama_posyandu` | `namaPosyandu` | `String` |
| `tanggal_pantau` | `tanggalPantau` | `String` |
| `usia_bulan` | `usiaBulan` | `int` |
| `berat` | `berat` | `double` |
| `tinggi` | `tinggi` | `double` |
| `lingkar_kepala` | `lingkarKepala` | `double?` |
| `lingkar_lengan` | `lingkarLengan` | `double?` |
| `status_gizi` | `statusGizi` | `String` |
| `imunisasi` | `imunisasi` | `String?` |
| `vitamin_a` | `vitaminA` | `String?` |
| `keluhan` | `keluhan` | `String?` |
| `saran` | `saran` | `String?` |
| `created_at` | `createdAt` | `String?` |
| `updated_at` | `updatedAt` | `String?` |

---

## C. Ringkasan Perubahan File

### File Baru (1 file)

| # | File | Isi |
|---|------|------|
| 1 | `lib/core/models/balita/pemantauan_balita_detail_model.dart` | Model `PemantauanBalitaDetailResponse` + fromJson/toJson |

### File Diubah (3 file)

| # | File | Perubahan |
|---|------|-----------|
| 2 | `lib/core/services/balita/pemantauan_balita_service.dart` | Tambah method `getDetail(idBalita, idPantau)` |
| 3 | `lib/features/pages/balita/balita_detail_page.dart` | **ISI** halaman detail pemeriksaan lengkap (sekarang 0 baris) |
| 4 | `lib/features/pages/balita/riwayat_pemantauan_page.dart` | Tambah `onTap` pada `PemantauanCard` → navigasi |

### Tidak Diubah

| File | Alasan |
|------|--------|
| `router.dart` | Halaman dibuka via `Navigator.push`, bukan static route |
| `pemantauan_card.dart` | Sudah punya parameter `onTap` |
| `status_gizi_badge.dart` | Sudah support `gizi_*` prefix |

---

## D. Layout Mobile — Detail Pemeriksaan

```
┌──────────────────────────────────┐  ← Scaffold bg #F5F7FA
│  ← Detail pemeriksaan            │  ← AppBar white, back arrow
│                                  │     title (EB 15px #1E293B)
├──────────────────────────────────┤  ← RefreshIndicator + ListView
│                                  │
│  ┌ Card 1: Pemeriksaan ────────┐│  ← white, corner 16, border, shadow
│  │  15 Jun 2026         6 bln  ││  ← tgl kiri, usia+badge kanan
│  │  ─────────────────────────  ││  ← separator line
│  │  ⚖ Berat Badan     12.8 kg ││
│  │  ─────────────────────────  ││
│  │  📏 Tinggi Badan     86.0 cm││
│  │  ─────────────────────────  ││
│  │  📐 Lingkar Kepala   48.8 cm││
│  │  ─────────────────────────  ││
│  │  📏 Lingkar Lengan   18.2 cm││
│  │  ─────────────────────────  ││
│  │  🟢 Status Gizi: Baik       ││  ← StatusGiziBadge
│  │  ─────────────────────────  ││
│  │  💉 Imunisasi: BCG, DPT,... ││
│  │  💊 Vitamin A: Ya           ││
│  └──────────────────────────────┘│
│                                  │
│  ┌ Card 2: Catatan Petugas ────┐│  ← white, corner 16, shadow
│  │  Catatan Petugas            ││  ← header EB 12px #1E293B
│  │                             ││
│  │  Keluhan:                   ││  ← ditampilkan jika tidak null
│  │  Keluhan diperbarui         ││
│  │  Saran:                     ││  ← ditampilkan jika tidak null
│  │  Saran diperbarui           ││
│  └──────────────────────────────┘│
│                                  │
│  ┌ Card 3: Info Kader ─────────┐│  ← white, corner 16, shadow
│  │  Info Kader & Posyandu      ││  ← header EB 12px #1E293B
│  │  👤 Kader     : Zidan K.    ││
│  │  🏥 Posyandu  : Melati      ││
│  │  🕐 Diperbarui: 19 Jul 2026 ││
│  └──────────────────────────────┘│
│                                  │
│  Data ini bersifat read-only.    │  ← center R 10px #64748B
│  Hubungi bidan untuk koreksi.    │
└──────────────────────────────────┘
```

---

## E. Urutan Implementasi

| Step | File | Tindakan |
|------|------|----------|
| 1 | `lib/core/models/balita/pemantauan_balita_detail_model.dart` | BUAT model |
| 2 | `lib/core/services/balita/pemantauan_balita_service.dart` | TAMBAH `getDetail()` |
| 3 | `lib/features/pages/balita/balita_detail_page.dart` | ISI halaman |
| 4 | `lib/features/pages/balita/riwayat_pemantauan_page.dart` | TAMBAH onTap |
