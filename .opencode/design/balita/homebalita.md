# Home Balita — Figma Implementation Plan

## Source
- Figma node: `1:343` — `"Home Balita"`
- Frame: 361×1139, bg=#F5F7FA
- Design sibling frames: Home (Ibu), Home (Remaja), Home (Lansia), etc. share similar layout pattern

---

## Page Structure (Top→Bottom)

```
┌─ Status Bar ─────────────────────────────┐ 36×47
│ 9:41                         [] 100%     │
├─ Header ─────────────────────────────────┤ 36×58
│ (🔵) SIGAP Posyandu           (🔔)       │
├─ Greeting ───────────────────────────────┤ 329×60
│ [🟠AP] Halo,                              │
│        Arjuan Prtama                      │
│        ┌─Balita─┐                        │
├─ Profile Summary Card ───────────────────┤ 329×211 (gradient)
│ ┌──────────────────────────────────────┐ │
│ │ Usia Blita                    🍼     │ │
│ │ 8  Bulan                             │ │
│ │ Satataus Imunisasi                   │ │
│ │ ████████████████████░░░ 12/13        │ │
│ │ ──────────────────────────────────   │ │
│ │ Pemantauan Terakhir: 10 Juli 2025    │ │
│ └──────────────────────────────────────┘ │
├─ Quick Stats ────────────────────────────┤ 329×92
│ ┌─TB──┐ ┌─BB───┐ ┌─LK────┐             │
│ │ 25.5│ │ 7    │ │ 48,5  │             │
│ │ cm  │ │ kg   │ │ cm    │             │
│ └─────┘ └──────┘ └───────┘             │
├─ Status Gizi Card ──────────────────────┤ 329×72
│ 🟢 Status Gizi            ┌─Normal─┐   │
│    Berat badan menurut us │        │   │
├─ Riwayat Imunisasi Card ────────────────┤ 329×136
│ 🟠 Status Imunisasi      12/13         │
│    Imunisasi dasar & lanjutan 92%       │
│ ████████████████████████████░░░         │
│ ┌─🔍 Lihat Detail───────────────────┐  │
│ │ Berikutnya: Campak Lanjutan - 24bn │  │
├─ Section Title ─────────────────────────┤ 329×30
│ Jadwal Pemeriksaan Berikutnya          │
├─ Jadwal Posyandu Card ──────────────────┤ 329×118
│ 📅 Jadwal Posyandu Berikutnya       >  │
│ ┌─15 ─┐                                │
│ │ Feb │ Posyandu Bulanan               │
│ └─────┘ 08:00-10:00                    │
│         Balai RW 03                    │
├─ Perkembangan Card ─────────────────────┤ 329×148 (gradient)
│ ⭐ Perkembangan 8 bulan                 │
│ Si kecil kini bisa berlari, menaiki     │
│ tangga, dan mengucapkan 20+ kata!       │
│ ┌─Motorik Kasar─┐ ┌─Bahasa─┐ ┌─Kognitif│
├─ Bottom Nav ────────────────────────────┤ 361×63
│ [🏠Beranda][📋Riwayat][📅Jadwal]       │
│ [🔔Notifikasi][👤Profil]               │
```

---

## Color Palette (From Figma API)

| Role | Hex | Usage |
|------|-----|-------|
| Page BG | `#F5F7FA` | Scaffold background |
| White | `#FFFFFF` | Cards, top bar, bottom nav |
| Text Primary | `#1E293B` | Headings, labels, values |
| Text Secondary | `#64748B` | Subtitles, hints |
| Primary Blue | `#162DF9` | Logo icon, active bottom tab |
| Orange | `#F97316` | Notification dot, date values, progress fill, "Lihat Detail" accent |
| Gold/Orange gradient | `#FFAE3C`→`#F97316`→`#E8BF39` | Profile summary card bg |
| Pink Light | `#FCE7F3` | Age label bg on gradient card |
| Green Light | `#F0FDF4` | Lingkar Kepala card bg, Status Gizi icon bg, Normal badge bg |
| Purple Light | `#FAF5FF` | Tinggi Badan card bg |
| Orange Light | `#FFF7ED` | Berat Badan card bg, Imunisasi card icon bg, Date bg |
| Green (Normal) | `#008236` | Status Gizi "Normal" text |
| Pink (Balita tag) | `#E60076` | "Balita" badge text & icon |
| Purple (Perkembangan) | `#8200DB` | "Perkembangan X bulan" title |
| Purple Tag | `#F3E8FF` bg / `#9810FA` text | Perkembangan category tags |
| Purple Chart bg | `#FAF5FF`→`#EEF2FF` | Perkembangan card gradient |
| Dark Orange | `#9A3412` | "Berikutnya: Campak Lanjutan" text |
| Signal bars | `#1E293B` | Status bar elements |

---

## Typography

| Element | Size | Weight | Line H | Color |
|---------|------|--------|--------|-------|
| Status bar time | 12pt | 800 | - | #1E293B |
| Status bar % | 10pt | 800 | - | #1E293B |
| Header title | 14pt | 800 | 1.4x | #1E293B |
| Greeting "Halo," | 12pt | 400 | 1.3x | #64748B |
| Greeting name | 16pt | 800 | 1.2x | #1E293B |
| "Balita" badge | 12pt | 700 | 1.3x | #E60076 |
| Label "Usia Blita" | 12pt | 600 | - | #FCE7F3 |
| Age number "8" | 48pt | 800 | - | #FFFFFF |
| Age unit "Bulan" | 14pt | 400 | - | #FCE7F3 |
| Sub-label | 12pt | 400 | - | #FCE7F3 |
| Progress label | 10pt | 400 | - | #FFFFFF |
| Progress count | 10pt | 400 | - | #FCE7F3 |
| Last checkup | 10pt | - | - | #FCE7F3 |
| Last checkup date | 12pt | - | - | #FFFFFF |
| Stats title | 10pt | 400 | 1.2x | #64748B |
| Stats value | 14pt | 800 | 1.4x | #1E293B |
| Stats unit | 10pt | 400 | 1.4x | #64748B |
| Card section title | 12pt | 800 | 1.3x | #1E293B |
| Card subtitle | 10pt | 400 | 1.5x | #64748B |
| Badge text | 14pt | 800 | 1.4x | #008236 |
| "Lihat Detail" | 10pt | 400 | - | #9A3412 |
| Section title | 14pt | 800 | 1.4x | #1E293B |
| Schedule title | 12pt | 800 | 1.3x | #F97316 |
| Date number | 18pt | 800 | 1.0x | #F97316 |
| Date month | 9pt | 800 | 1.5x | #F97316 (70%) |
| Event title | 14pt | 700 | - | #1E293B |
| Event time/place | 12pt | 400 | - | #64748B |
| Dev title | 12pt | 800 | 1.3x | #8200DB |
| Dev description | 12pt | 400 | 1.6x | #64748B |
| Dev tag | 10pt | 800 | 1.5x | #9810FA |
| Bottom nav label | 10pt | 700 | 1.5x | #162DF9/#64748B |

---

## Data Mapping

### Available from `GET /api/balita/{id}` (BalitaDetailResponse):
| Figma Field | Model Field | Notes |
|------------|-------------|-------|
| Avatar initial | `nama[0]` | First letter |
| "Halo, [name]" | `nama` | Full name |
| "Balita" tag | Hardcoded | Static |
| Usia "X Bulan" | `usia` | Already in months |
| NIK | `nik` | Not shown in Figma (extra) |
| Tanggal Lahir | `tanggalLahir` | Not shown in Figma (extra) |
| Jenis Kelamin | `jenisKelamin` | Not shown in Figma |
| Status Gizi | `statusGizi` | For badge |
| ASI Eksklusif | `asiEksklusif` | Not shown in Figma |
| Imunisasi Dasar | `imunisasiDasar` | For "Status Imunisasi" |

### Not yet available (need new API or placeholder):
| Figma Field | Proposal |
|------------|----------|
| Tinggi Badan value | New field in BalitaDetail or separate endpoint |
| Berat Badan value | New field in BalitaDetail or separate endpoint |
| Lingkar Kepala value | New field in BalitaDetail or separate endpoint |
| Pemantauan Terakhir date | From latest growth measurement |
| Imunisasi progress (12/13) | From imunisasi endpoint |
| Next vaccine detail | From imunisasi endpoint |
| Jadwal Posyandu | From jadwal endpoint |
| Perkembangan description | From perkembangan endpoint |
| Perkembangan tags | From perkembangan endpoint |

---

## Implementation Phases

### Phase 1: Layout Shell
- Rewrite `BalitaPage` with proper Scaffold (no AppBar)
- Add scrollable body with correct spacing
- Status bar with time + signal (custom widget)
- Header with "SIGAP Posyandu" + notification bell
- Bottom navigation bar with 5 tabs (all routes exist?)

### Phase 2: Content Sections
- Greeting section with gradient avatar + name + "Balita" tag
- Profile Summary Card with gradient bg, age display, imunisasi progress bar
- Quick Stats Grid (3 cards with icons)
- Status Gizi Info Card (icon + subtitle + badge)
- Riwayat Imunisasi Card (progress bar + "Lihat Detail")
- Jadwal Pemeriksaan section
- Perkembangan Card (gradient bg + tags)

### Phase 3: Data Integration
- Add missing fields to BalitaDetailResponse (tinggi_badan, berat_badan, lingkar_kepala, last_checkup, imunisasi_count, imunisasi_total)
- Create models for Jadwal and Perkembangan
- Add corresponding service methods
- Wire placeholder data → real API data

### Phase 4: Polish
- Loading skeletons matching Figma layout
- Pull-to-refresh on all sections
- Navigation from "Lihat Detail" → detail pages
- Notification bell → notification page
- Bottom nav tab switching

---

## Files to Create/Modify

| File | Action |
|------|--------|
| `lib/features/pages/balita/balita_page.dart` | REWRITE — complete layout matching Figma |
| `lib/core/models/balita/balita_model.dart` | ADD fields for TB, BB, LK, last checkup, imunisasi count |
| `lib/core/services/balita/balita_service.dart` | ADD methods for jadwal, perkembangan (or create new services) |
| `lib/widgets/balita/home_balita_header.dart` | NEW — status bar + header |
| `lib/widgets/balita/greeting_section.dart` | NEW — avatar + "Halo," + name + tag |
| `lib/widgets/balita/profile_summary_card.dart` | NEW — gradient card with age + imunisasi |
| `lib/widgets/balita/quick_stats_grid.dart` | NEW — 3 stat cards |
| `lib/widgets/balita/imunisasi_card.dart` | NEW — imunisasi progress card |
| `lib/widgets/balita/jadwal_card.dart` | NEW — schedule card |
| `lib/widgets/balita/perkembangan_card.dart` | NEW — development card |
| `lib/widgets/balita/home_bottom_nav.dart` | NEW — bottom navigation bar |

---

## Spacing & Layout Constants

| Measure | Value |
|---------|-------|
| Page horizontal padding | 16px |
| Section vertical gap | 16px |
| Card border radius | 16px |
| Card padding | 20px |
| Badge corner radius | 999 (pill) |
| Avatar size | 56px |
| Small avatar (header) | 28px |
| Icon container | 36px (radius 20px) |
| Stat card | 104×92px |
| Bottom nav height | 63px |
| Bottom nav tab | 72×61px |
