# Plan: Modul Balita — Fase 1: Detail Balita (Home Balita)

**Status:** ✅ Disetujui

---

## A. Aturan & Referensi

| Aturan | Detail |
|--------|--------|
| **Arsitektur** | Feature-First: Page → Service → ApiClient → Backend |
| **Folder Page** | `lib/features/pages/` |
| **Folder Service** | `lib/core/services/` |
| **Folder Models** | `lib/core/models/` |
| **Folder Widgets** | `lib/widgets/` |
| **Naming** | file: `snake_case`, class: `PascalCase`, var/func: `camelCase` |
| **Import** | `package:` imports |
| **State** | Local state di `StatefulWidget` |
| **Auth** | JWT di `flutter_secure_storage` via `TokenService` |
| **Font** | Google Fonts Plus Jakarta Sans |
| **Theme** | `AppColors`, `AppTheme` |
| **Package Name** | `package:frontend_posyandu` |

---

## B. API Endpoint

### B.1 POST /api/v1/auth/login (existing)

Response `data.user.module_id` = `id_balita`.

### B.2 GET /api/balita/{{balita_id}}

**Response:**
```json
{
    "data": {
        "id_balita": "7f952bf3-...",
        "id_anggota": "5d32d2ba-...",
        "nik": "1234567890123456",
        "nama": "Andi Pratama",
        "jenis_kelamin": "L",
        "tanggal_lahir": "2023-01-15",
        "usia": 42,
        "berat_lahir": 25.0,
        "panjang_lahir": 160.0,
        "asi_eksklusif": "ya",
        "imunisasi_dasar": "lengkap",
        "status_gizi": "kurang",
        "status_aktif": "aktif",
        "nama_ayah": null,
        "nama_ibu": null,
        "no_hp_wa": null,
        "created_at": null,
        "updated_at": "2026-07-21T02:40:39"
    },
    "success": true,
    "timestamp": "..."
}
```

**Catatan:** path `/api/balita/{id}` (tanpa `/v1/`). `usia` dalam bulan.

### B.3 Model `BalitaDetailResponse`

| Field JSON | Dart | Tipe |
|---|---|---|
| `id_balita` | `idBalita` | String |
| `id_anggota` | `idAnggota` | String |
| `nik` | `nik` | String |
| `nama` | `nama` | String |
| `jenis_kelamin` | `jenisKelamin` | String |
| `tanggal_lahir` | `tanggalLahir` | String |
| `usia` | `usia` | int |
| `berat_lahir` | `beratLahir` | double |
| `panjang_lahir` | `panjangLahir` | double |
| `asi_eksklusif` | `asiEksklusif` | String |
| `imunisasi_dasar` | `imunisasiDasar` | String |
| `status_gizi` | `statusGizi` | String |
| `status_aktif` | `statusAktif` | String |
| `nama_ayah` | `namaAyah` | String? |
| `nama_ibu` | `namaIbu` | String? |
| `no_hp_wa` | `noHpWa` | String? |
| `created_at` | `createdAt` | String? |
| `updated_at` | `updatedAt` | String? |

---

## C. File Baru

| # | File | Isi |
|---|------|-----|
| 1 | `lib/core/models/balita/balita_model.dart` | `BalitaDetailResponse` with fromJson |
| 2 | `lib/core/services/balita/balita_service.dart` | `getBalitaById()` |
| 3 | `lib/widgets/balita/status_gizi_badge.dart` | Badge warna status gizi |

## D. File Diubah

| # | File | Perubahan |
|---|------|-----------|
| 4 | `lib/core/services/auth/token_service.dart` | Tambah `saveModuleId/getModuleId/clearModuleId` |
| 5 | `lib/core/services/auth/auth_service.dart` | Delegasi + auto-save moduleId di login |
| 6 | `lib/features/pages/balita/balita_page.dart` | Revisi total: dari stub jadi Home Balita lengkap |

---

## E. Urutan Implementasi

| Step | File | Perubahan |
|------|------|-----------|
| 1 | `lib/core/services/auth/token_service.dart` | Tambah method moduleId |
| 2 | `lib/core/services/auth/auth_service.dart` | Delegasi + auto-save |
| 3 | `lib/core/models/balita/balita_model.dart` | BUAT `BalitaDetailResponse` |
| 4 | `lib/core/services/balita/balita_service.dart` | BUAT `getBalitaById()` |
| 5 | `lib/widgets/balita/status_gizi_badge.dart` | BUAT badge widget |
| 6 | `lib/features/pages/balita/balita_page.dart` | REVISI total |

---

## F. Layout Mobile — Home Balita

```
┌──────────────────────────────────┐
│  🔵 AppBar: "Balita"      [⏻]  │  ← Header + Logout
├──────────────────────────────────┤
│  ┌── Section 2: Profile ───────┐│
│  │  👤 NAMA                    ││  ← font besar, bold
│  │                             ││
│  │  NIK          : 123456...   ││
│  │  Tanggal Lahir: 15 Jan 2023 ││
│  │  Usia         : 42 bulan    ││
│  │  Jenis Kelamin: Laki-laki   ││
│  │  Berat Lahir  : 25.0 kg     ││
│  │  Panjang Lahir: 160 cm      ││
│  └──────────────────────────────┘│
│                                  │
│  ┌── Section 3: Status Gizi ───┐│
│  │    🔴 Status: KURANG        ││  ← badge warna
│  └──────────────────────────────┘│
│                                  │
│  ┌── Section 4: Info Tambahan ─┐│
│  │  🍼 ASI Eksklusif: Ya       ││
│  │  💉 Imunisasi   : Lengkap   ││
│  └──────────────────────────────┘│
│                                  │
│  ┌── Section 5: Orang Tua ─────┐│
│  │  👨 Ayah  : —                ││
│  │  👩 Ibu   : —                ││
│  │  📞 No WA : —                ││
│  └──────────────────────────────┘│
│                                  │
│  ┌── Section 6: Footer ────────┐│
│  │  Diperbarui: 21 Jul 2026    ││
│  └──────────────────────────────┘│
└──────────────────────────────────┘
```

## G. Alur Lengkap

### F.1 Login → Home Balita
```
LoginPage → POST /api/v1/auth/login
  → AuthService simpan moduleId
  → Navigator.pushReplacementNamed('/balita')
```

### F.2 BalitaPage (StatefulWidget)
```
initState → AuthService.getModuleId()
  → BalitaService.getBalitaById(moduleId)
    → GET /api/balita/{id}
    → setState() tampilkan data
```

### F.3 Error
```
DioException → catch → SnackBar error
```
