# Plan: Diagnosa & Perbaikan Error "Tidak Dapat Terhubung ke Server"

**Status:** ⏳ Draft

---

## A. Aturan & Referensi

| Aturan | Detail |
|--------|--------|
| **Arsitektur** | Feature-First: Page → Service → ApiClient → Backend |
| **Naming** | file: `snake_case`, class: `PascalCase`, var/func: `camelCase` |
| **Import** | `package:` imports |
| **Base URL** | `http://192.168.1.12:5000` (dari `.env`) |
| **Error Message** | "Tidak dapat terhubung ke server. Periksa koneksi internet Anda." dari `NetworkException` di `lib/core/utils/errors.dart:22` |

---

## B. Ringkasan Masalah

### B.1 Gejala

- Login (`POST /api/v1/auth/login`) berhasil → backend 200
- Setelah login, navigasi ke halaman kategori (misal BalitaPage)
- BalitaPage panggil `GET /api/balita/{id}` → gagal
- Muncul error: **"Tidak dapat terhubung ke server. Periksa koneksi internet Anda."**

### B.2 Akar Masalah (Hipotesis)

`NetworkException` dilempar oleh service ketika `DioException` terjadi dengan kondisi:
1. `e.response?.data` bukan `Map` (bisa null, String/HTML, List, dll)
2. `e.response?.statusCode` bukan 401

Alur kode di `BalitaService.getBalitaById()` (balita_service.dart:30-42):

```
DioException terjadi
  ├── response.data ada & berupa Map → parse pesan error → ServerException
  ├── statusCode 401 → ServerException(401)
  └── selain itu → NetworkException ← INI YANG TERJADI
```

**Kemungkinan penyebab:**
1. **Balita endpoint belum ada / salah** → backend return 404 dengan HTML → `response.data` berupa String (HTML), bukan Map → lolos ke `NetworkException`
2. **Balita endpoint error 500** → response body bukan JSON
3. **moduleId null** → tapi ini throw `Exception('ID tidak ditemukan')`, bukan NetworkException

### B.3 Path Endpoint Valid

| Endpoint | Path | Status |
|----------|------|--------|
| Login | `POST /api/v1/auth/login` | ✅ Berhasil 200 |
| Balita | `GET /api/balita/{id}` | ❌ Diduga 404/500 |
| Growth Chart | `GET /api/balita/{id}/growth-chart` | ❌ Diduga sama |
| Pemantauan | `GET /api/balita/{id}/pemantauan` | ❌ Diduga sama |
| Download KMS | `GET /api/balita/{id}/download-kms` | ❌ Diduga sama |

---

## C. Langkah Diagnosa

### C.1 Test Endpoint Balita Langsung

Jalankan dari terminal host:
```bash
curl -v http://192.168.1.12:5000/api/balita/1
```

Periksa:
- Status code (200? 404? 500?)
- Response body (JSON? HTML?)
- Response headers (Content-Type?)

### C.2 Test dengan Token (Jika Endpoint Butuh Auth)

```bash
curl -v http://192.168.1.12:5000/api/balita/1 \
  -H "Authorization: Bearer <access_token>"
```

### C.3 Cek Log Flutter

Jalankan `flutter run` dan cari log `DioException` di console. Tambahkan print sementara jika perlu.

---

## D. Rencana Perbaikan (Setelah Diagnosa)

Tergantung hasil diagnosa:

| Jika backend return | Masalah | Solusi |
|--------------------|---------|--------|
| 404 (HTML) | Route `/api/balita/{id}` belum ada di Flask | Tambah route di backend |
| 500 (HTML/JSON) | Server error di endpoint balita | Fix backend code |
| 200 (JSON valid) | `moduleId` tidak cocok atau token tidak dikirim | Fix Flutter: cek token di header, cek moduleId |
| 200 (JSON `success: false`) | Backend tolak dengan pesan error | Baca pesan error dari response |

---

## E. Catatan

- Path `/api/balita/...` tanpa `/v1/` adalah **sudah benar** — backend tidak pakai prefix `/v1/` untuk modul balita
- Auth & FCM saja yang pakai `/api/v1/...` — ini desain backend, bukan inkonsistensi
- Service lain (remaja, lansia, ibu_hamil, cabang) masih file kosong — belum bisa di-test
