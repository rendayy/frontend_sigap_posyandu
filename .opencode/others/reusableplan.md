# Reusable Infrastructure Plan (Modul Balita & Remaja) — Implementasi

> **For agentic workers:** REQUIRED SUB-SKILL: Gunakan superpowers:subagent-driven-development (disarankan) atau superpowers:executing-plans untuk mengimplementasikan plan ini task-by-task. Steps menggunakan checkbox (`- [ ]`) untuk tracking.

**Goal:** Menghilangkan duplikasi di frontend Flutter SIGAP Posyandu dengan membuat infrastruktur reusable (BaseService, BalitaBaseService/RemajaBaseService, WargaBase, StatusGiziBadge gabungan, PaginationMeta tunggal) dan me-refactor semua service modul Balita & Remaja agar memakainya — tanpa mengubah perilaku API yang ada.

**Architecture:** Lima service (BalitaService, PemantauanBalitaService, RemajaService, PemantauanRemajaService, KegiatanRemajaService) saat ini mengulang ~20 baris try-catch DioException per method. Pola itu dipindah ke `BaseService` generik (di `lib/core/api/`). Untuk membedakan tempat API tiap modul, dibuat `BalitaBaseService extends BaseService` (di `lib/core/services/balita/`) dan `RemajaBaseService extends BaseService` (di `lib/core/services/remaja/`) — service balita extends BalitaBaseService, service remaja extends RemajaBaseService. Modul baru (lansia/ibu_hamil/cabang/alert) nanti menambah base class-nya sendiri. Dua model detail (Balita & Remaja) berbagi field umum yang dipindah ke `WargaBase`. Dua widget `StatusGiziBadge` (balita/remaja) yang identik strukturnya di-merge ke satu widget `lib/widgets/common/status_gizi_badge.dart` namun mapping label & warna tetap dibedakan per vocab (tidak tercampur). Dua kelas `PaginationMeta` identik di-merge ke satu file. Semua file lama yang sudah tidak terpakai dihapus.

**Tech Stack:** Flutter 3.44.4 (Dart SDK ^3.12.2), `dio`, `package:frontend_posyandu/...`, `flutter_test`.

## Global Constraints

- **Package name:** `frontend_posyandu` (import `package:frontend_posyandu/...`, bukan `sigap_posyandu`).
- **Tidak ada dependensi baru** — hanya stdlib Dart/Flutter + dio yang sudah ada.
- **API contract service tidak berubah:** nama method, parameter, dan tipe return tiap service PERSIS sama seperti sekarang. Test service lama (regression) harus tetap lulus TANPA diedit.
- **Error semantics tidak berubah:** `success != true` → ServerException; DioException dengan `error` map → ServerException; status 401 → ServerException(401); selain itu → NetworkException. String fallback error tiap method dipertahankan.
- **Run verifikasi:** `flutter analyze` dan `flutter test` harus bersih/pass di akhir tiap task dan di akhir plan.
- **Commits:** tiap task di-commit terpisah; hanya stage file yang relevan (jangan stage `.opencode/` docs kecuali memang sengaja).

---

## File Structure

**File baru (create):**
- `lib/core/api/base_service.dart` — class `BaseService` generik (get/post/put/delete + `_send`).
- `lib/core/services/balita/balita_base_service.dart` — class `BalitaBaseService extends BaseService` (base khusus modul balita).
- `lib/core/services/remaja/remaja_base_service.dart` — class `RemajaBaseService extends BaseService` (base khusus modul remaja).
- `lib/core/models/warga_base_model.dart` — class `WargaBase` (field umum balita & remaja).
- `lib/core/models/pagination_meta.dart` — class `PaginationMeta` tunggal (hasil dedup).
- `lib/widgets/common/status_gizi_badge.dart` — widget `StatusGiziBadge` gabungan (vocab balita + remaja).
- `test/core/api/base_service_test.dart`
- `test/core/models/warga_base_model_test.dart`
- `test/widgets/common/status_gizi_badge_test.dart`

**File di-refactor (modify):**
- `lib/core/services/balita/balita_service.dart` → extends `BalitaBaseService`.
- `lib/core/services/balita/pemantauan_balita_service.dart` → extends `BalitaBaseService`.
- `lib/core/services/remaja/remaja_service.dart` → extends `RemajaBaseService`.
- `lib/core/services/remaja/pemantauan_remaja_service.dart` → extends `RemajaBaseService`.
- `lib/core/services/remaja/kegiatan_remaja_service.dart` → extends `RemajaBaseService`.
- `lib/core/models/balita/balita_model.dart` → `BalitaDetailResponse extends WargaBase`.
- `lib/core/models/remaja/remaja_model.dart` → `RemajaDetailResponse extends WargaBase`.
- `lib/core/models/balita/pemantauan_balita_model.dart` → hapus `PaginationMeta` lokal, import `pagination_meta.dart`.
- `lib/core/models/remaja/pemantauan_remaja_model.dart` → hapus `PaginationMeta` lokal, import `pagination_meta.dart`.
- 6 importers badge: `lib/features/pages/balita/balita_detail_page.dart:9`, `lib/features/pages/remaja/pemantauan_detail_page.dart:11`, `lib/widgets/balita/home_balita_sections.dart:5`, `lib/widgets/balita/pemantauan_card.dart:5`, `lib/widgets/remaja/home_remaja_sections.dart:4`, `lib/widgets/remaja/pemantauan_remaja_card.dart:5` → ganti import ke `widgets/common/status_gizi_badge.dart`.
- 2 test importers badge: `test/widgets/common_widgets_test.dart:6`, `test/widgets/remaja/home_remaja_sections_test.dart:5` → ganti import ke `widgets/common/status_gizi_badge.dart`.
- 2 test importers PaginationMeta: `test/features/pages/balita/riwayat_pemantauan_page_test.dart`, `test/features/pages/remaja/riwayat_pemantauan_page_test.dart` → tambah import `core/models/pagination_meta.dart`.

**File dihapus (delete):**
- `lib/widgets/balita/status_gizi_badge.dart`
- `lib/widgets/remaja/status_gizi_badge.dart`
- `lib/core/utils/error_handler.dart` (0 byte, tidak di-import kode mana pun — hanya disebut di PRD.md/docs).

**Tidak disentuh (sudah reusable):** `lib/core/utils/module_page_mixin.dart`, `lib/core/utils/cache_manager.dart`, `lib/core/utils/errors.dart`, `lib/core/api/api_client.dart`, semua test service yang ada.

---

### Task 1: BaseService + BalitaBaseService/RemajaBaseService + test

**Files:**
- Create: `lib/core/api/base_service.dart`
- Create: `lib/core/services/balita/balita_base_service.dart`
- Create: `lib/core/services/remaja/remaja_base_service.dart`
- Test: `test/core/api/base_service_test.dart`

**Interfaces:**
- Produces: class `BaseService` dengan:
  - `BaseService({ApiClient? apiClient})` (field publik `final ApiClient apiClient;`)
  - `Future<T> get<T>(String path, {required T Function(Map<String, dynamic>) fromJson, Map<String, dynamic>? queryParameters, String errorMessage = 'Gagal memuat data', bool fromData = true})`
  - `Future<T> post<T>(String path, {Object? data, required T Function(Map<String, dynamic>) fromJson, String errorMessage = 'Gagal memuat data', bool fromData = true})`
  - `Future<T> put<T>(...)` — signature sama seperti `post`
  - `Future<T> delete<T>(String path, {required T Function(Map<String, dynamic>) fromJson, String errorMessage = 'Gagal memuat data', bool fromData = true})`
- Produces: class `BalitaBaseService extends BaseService` (`BalitaBaseService({ApiClient? apiClient}) : super(apiClient: apiClient)`) di `lib/core/services/balita/`.
- Produces: class `RemajaBaseService extends BaseService` (`RemajaBaseService({ApiClient? apiClient}) : super(apiClient: apiClient)`) di `lib/core/services/remaja/`.
- Consumes (Task 3 & 4): service balita extends `BalitaBaseService`, service remaja extends `RemajaBaseService`.

- [ ] **Step 1: Tulis failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/api/base_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

Dio _mockDio(int statusCode, Object data, {bool throwError = false}) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (throwError) {
        handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        ));
      } else {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: statusCode,
          data: data,
        ));
      }
    },
  ));
  return dio;
}

void main() {
  group('BaseService', () {
    test('get parses body["data"] by default', () async {
      final dio = _mockDio(200, {
        'success': true,
        'data': {'nama': 'Andi'},
      });
      final service = BaseService(apiClient: ApiClient(customDio: dio));
      final result = await service.get(
        '/api/test',
        fromJson: (j) => j['nama'] as String,
      );
      expect(result, 'Andi');
    });

    test('get parses whole body when fromData=false', () async {
      final dio = _mockDio(200, {
        'success': true,
        'nama': 'Andi',
      });
      final service = BaseService(apiClient: ApiClient(customDio: dio));
      final result = await service.get(
        '/api/test',
        fromJson: (j) => j['nama'] as String,
        fromData: false,
      );
      expect(result, 'Andi');
    });

    test('get sends queryParameters', () async {
      Map<String, dynamic>? captured;
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options.queryParameters;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'success': true, 'data': {}},
          ));
        },
      ));
      final service = BaseService(apiClient: ApiClient(customDio: dio));
      await service.get(
        '/api/test',
        queryParameters: {'page': 2, 'limit': 5},
        fromJson: (j) => j,
      );
      expect(captured, {'page': 2, 'limit': 5});
    });

    test('get throws ServerException on success=false with message', () async {
      final dio = _mockDio(200, {
        'success': false,
        'error': {'code': 404, 'message': 'Data tidak ditemukan'},
      });
      final service = BaseService(apiClient: ApiClient(customDio: dio));
      expect(
        () => service.get('/api/test', fromJson: (j) => j),
        throwsA(predicate(
          (e) => e is ServerException && e.message.contains('Data tidak ditemukan'),
        )),
      );
    });

    test('get throws ServerException on 401', () async {
      final dio = _mockDio(401, {
        'success': false,
        'error': {'code': 401, 'message': 'Token JWT tidak valid atau expired'},
      });
      final service = BaseService(apiClient: ApiClient(customDio: dio));
      expect(
        () => service.get('/api/test', fromJson: (j) => j),
        throwsA(predicate((e) => e is ServerException && e.statusCode == 401)),
      );
    });

    test('get throws NetworkException on connection error', () async {
      final dio = _mockDio(0, {}, throwError: true);
      final service = BaseService(apiClient: ApiClient(customDio: dio));
      expect(
        () => service.get('/api/test', fromJson: (j) => j),
        throwsA(predicate((e) => e is NetworkException)),
      );
    });

    test('post/put/delete send data and parse response', () async {
      final dio = _mockDio(200, {
        'success': true,
        'data': {'id': 'x-1'},
      });
      final service = BaseService(apiClient: ApiClient(customDio: dio));
      final postId = await service.post(
        '/api/test',
        data: {'nama': 'A'},
        fromJson: (j) => j['id'] as String,
      );
      final putId = await service.put(
        '/api/test',
        data: {'nama': 'A'},
        fromJson: (j) => j['id'] as String,
      );
      final delId = await service.delete(
        '/api/test',
        fromJson: (j) => j['id'] as String,
      );
      expect(postId, 'x-1');
      expect(putId, 'x-1');
      expect(delId, 'x-1');
    });
  });
}
```

- [ ] **Step 2: Jalankan test untuk pastikan GAGAL**

Run: `flutter test test/core/api/base_service_test.dart`
Expected: FAIL — `Error: Error: Could not resolve the package 'frontend_posyandu' in the package config` / `BaseService` tidak ditemukan.

- [ ] **Step 3: Tulis implementasi minimal**

```dart
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class BaseService {
  final ApiClient apiClient;

  BaseService({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<T> _send<T>(
    Future<Response> Function() request,
    T Function(Map<String, dynamic>) fromJson, {
    required String errorMessage,
    bool fromData = true,
  }) async {
    try {
      final response = await request();
      final body = response.data;
      if (body['success'] != true) {
        final errorData = body['error'] as Map?;
        final message = errorData?['message'] as String? ?? errorMessage;
        final code = errorData?['code'] as int?;
        throw ServerException(
          statusCode: code,
          message: message,
          rawMessage: message,
        );
      }
      final json = fromData ? body['data'] : body;
      return fromJson(json as Map<String, dynamic>);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message = error?['message'] as String? ?? errorMessage;
        throw ServerException(
          statusCode: statusCode,
          message: message,
          rawMessage: message,
        );
      }
      if (statusCode == 401) {
        throw ServerException(
          statusCode: 401,
          message: 'Sesi Anda telah habis. Silakan login kembali.',
        );
      }
      throw NetworkException();
    }
  }

  Future<T> get<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParameters,
    String errorMessage = 'Gagal memuat data',
    bool fromData = true,
  }) {
    return _send(
      () => apiClient.dio.get(path, queryParameters: queryParameters),
      fromJson,
      errorMessage: errorMessage,
      fromData: fromData,
    );
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    required T Function(Map<String, dynamic>) fromJson,
    String errorMessage = 'Gagal memuat data',
    bool fromData = true,
  }) {
    return _send(
      () => apiClient.dio.post(path, data: data),
      fromJson,
      errorMessage: errorMessage,
      fromData: fromData,
    );
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    required T Function(Map<String, dynamic>) fromJson,
    String errorMessage = 'Gagal memuat data',
    bool fromData = true,
  }) {
    return _send(
      () => apiClient.dio.put(path, data: data),
      fromJson,
      errorMessage: errorMessage,
      fromData: fromData,
    );
  }

  Future<T> delete<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    String errorMessage = 'Gagal memuat data',
    bool fromData = true,
  }) {
    return _send(
      () => apiClient.dio.delete(path),
      fromJson,
      errorMessage: errorMessage,
      fromData: fromData,
    );
  }
}
```

- [ ] **Step 4: Jalankan test untuk pastikan PASS**

Run: `flutter test test/core/api/base_service_test.dart`
Expected: PASS (semua 7 test).

- [ ] **Step 5: Buat `lib/core/services/balita/balita_base_service.dart`**

```dart
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/api/base_service.dart';

class BalitaBaseService extends BaseService {
  BalitaBaseService({ApiClient? apiClient}) : super(apiClient: apiClient);
}
```

- [ ] **Step 6: Buat `lib/core/services/remaja/remaja_base_service.dart`**

```dart
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/api/base_service.dart';

class RemajaBaseService extends BaseService {
  RemajaBaseService({ApiClient? apiClient}) : super(apiClient: apiClient);
}
```

- [ ] **Step 7: Jalankan analyze**

Run: `flutter analyze`
Expected: Clean, tidak ada error (kedua file masih belum terpakai, tapi valid).

- [ ] **Step 8: Commit**

```bash
git add lib/core/api/base_service.dart lib/core/services/balita/balita_base_service.dart lib/core/services/remaja/remaja_base_service.dart test/core/api/base_service_test.dart
git commit -m "feat: add BaseService + per-module Balita/Remaja base services"
```

---

### Task 2: WargaBase + refactor model detail

**Files:**
- Create: `lib/core/models/warga_base_model.dart`
- Modify: `lib/core/models/balita/balita_model.dart`, `lib/core/models/remaja/remaja_model.dart`
- Test: `test/core/models/warga_base_model_test.dart`

**Interfaces:**
- Produces: class `WargaBase` dengan field `nik`, `nama`, `jenisKelamin`, `tanggalLahir` (String?), `usia`, `statusAktif`, `statusGizi` (String?), `createdAt`, `updatedAt`; method `Map<String, dynamic> toJson()`.
- Consumes: `BalitaDetailResponse extends WargaBase` (constructor `required super.tanggalLahir` dipertahankan), `RemajaDetailResponse extends WargaBase`.

- [ ] **Step 1: Tulis failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/core/models/warga_base_model.dart';
import 'package:frontend_posyandu/core/models/balita/balita_model.dart';
import 'package:frontend_posyandu/core/models/remaja/remaja_model.dart';

void main() {
  group('WargaBase', () {
    test('toJson outputs common fields', () {
      const base = WargaBase(
        nik: '1234567890123456',
        nama: 'Andi',
        jenisKelamin: 'L',
        tanggalLahir: '2023-01-15',
        usia: 42,
        statusAktif: 'aktif',
      );
      final json = base.toJson();
      expect(json['nik'], '1234567890123456');
      expect(json['nama'], 'Andi');
      expect(json['usia'], 42);
      expect(json['status_aktif'], 'aktif');
    });
  });

  group('BalitaDetailResponse extends WargaBase', () {
    test('fromJson maps common fields', () {
      final balita = BalitaDetailResponse.fromJson({
        'id_balita': 'b-001',
        'id_anggota': 'a-001',
        'nik': '1234567890123456',
        'nama': 'Andi Pratama',
        'jenis_kelamin': 'L',
        'tanggal_lahir': '2023-01-15',
        'usia': 42,
        'berat_lahir': 3.5,
        'panjang_lahir': 50.0,
        'asi_eksklusif': 'ya',
        'imunisasi_dasar': 'lengkap',
        'status_gizi': 'baik',
        'status_aktif': 'aktif',
      });
      expect(balita, isA<WargaBase>());
      expect(balita.nama, 'Andi Pratama');
      expect(balita.tanggalLahir, '2023-01-15');
      expect(balita.idBalita, 'b-001');
    });
  });

  group('RemajaDetailResponse extends WargaBase', () {
    test('fromJson maps common fields', () {
      final remaja = RemajaDetailResponse.fromJson({
        'id_remaja': 'r-001',
        'nik': '1234567890123456',
        'nama': 'Siti',
        'jenis_kelamin': 'P',
        'tanggal_lahir': '2010-01-15',
        'usia': 16,
        'riwayat_anemia': 'tidak',
        'status_aktif': 'aktif',
        'status_gizi': 'berat_badan_normal',
      });
      expect(remaja, isA<WargaBase>());
      expect(remaja.nama, 'Siti');
      expect(remaja.statusGizi, 'berat_badan_normal');
      expect(remaja.idRemaja, 'r-001');
    });
  });
}
```

- [ ] **Step 2: Jalankan test untuk pastikan GAGAL**

Run: `flutter test test/core/models/warga_base_model_test.dart`
Expected: FAIL — `WargaBase` / file tidak ditemukan.

- [ ] **Step 3: Buat `lib/core/models/warga_base_model.dart`**

```dart
class WargaBase {
  final String nik;
  final String nama;
  final String jenisKelamin;
  final String? tanggalLahir;
  final int usia;
  final String statusAktif;
  final String? statusGizi;
  final String? createdAt;
  final String? updatedAt;

  const WargaBase({
    required this.nik,
    required this.nama,
    required this.jenisKelamin,
    this.tanggalLahir,
    required this.usia,
    required this.statusAktif,
    this.statusGizi,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'nik': nik,
      'nama': nama,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir,
      'usia': usia,
      'status_aktif': statusAktif,
      'status_gizi': statusGizi,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
```

- [ ] **Step 4: Ganti isi `lib/core/models/balita/balita_model.dart` dengan versi extends WargaBase**

```dart
import 'package:frontend_posyandu/core/models/warga_base_model.dart';

class BalitaDetailResponse extends WargaBase {
  final String idBalita;
  final String idAnggota;
  final double beratLahir;
  final double panjangLahir;
  final String asiEksklusif;
  final String imunisasiDasar;
  final String? namaAyah;
  final String? namaIbu;
  final String? noHpWa;

  const BalitaDetailResponse({
    required this.idBalita,
    required this.idAnggota,
    required super.nik,
    required super.nama,
    required super.jenisKelamin,
    required super.tanggalLahir,
    required super.usia,
    required this.beratLahir,
    required this.panjangLahir,
    required this.asiEksklusif,
    required this.imunisasiDasar,
    super.statusGizi,
    required super.statusAktif,
    this.namaAyah,
    this.namaIbu,
    this.noHpWa,
    super.createdAt,
    super.updatedAt,
  });

  factory BalitaDetailResponse.fromJson(Map<String, dynamic> json) {
    return BalitaDetailResponse(
      idBalita: json['id_balita'] as String,
      idAnggota: json['id_anggota'] as String,
      nik: json['nik'] as String,
      nama: json['nama'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
      tanggalLahir: json['tanggal_lahir'] as String,
      usia: json['usia'] as int,
      beratLahir: (json['berat_lahir'] as num).toDouble(),
      panjangLahir: (json['panjang_lahir'] as num).toDouble(),
      asiEksklusif: json['asi_eksklusif'] as String,
      imunisasiDasar: json['imunisasi_dasar'] as String,
      statusGizi: json['status_gizi'] as String?,
      statusAktif: json['status_aktif'] as String,
      namaAyah: json['nama_ayah'] as String?,
      namaIbu: json['nama_ibu'] as String?,
      noHpWa: json['no_hp_wa'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'id_balita': idBalita,
      'id_anggota': idAnggota,
      'berat_lahir': beratLahir,
      'panjang_lahir': panjangLahir,
      'asi_eksklusif': asiEksklusif,
      'imunisasi_dasar': imunisasiDasar,
      'nama_ayah': namaAyah,
      'nama_ibu': namaIbu,
      'no_hp_wa': noHpWa,
    };
  }
}
```

- [ ] **Step 5: Ganti isi `lib/core/models/remaja/remaja_model.dart` dengan versi extends WargaBase**

```dart
import 'package:frontend_posyandu/core/models/warga_base_model.dart';

class RemajaDetailResponse extends WargaBase {
  final String idRemaja;
  final String? sekolah;
  final String? kelas;
  final String? prestasi;
  final String? hobi;
  final String riwayatAnemia;
  final double? beratBadan;
  final double? tinggiBadan;
  final String? tanggalPantauTerakhir;
  final String? noHp;

  const RemajaDetailResponse({
    required this.idRemaja,
    required super.nik,
    required super.nama,
    required super.jenisKelamin,
    super.tanggalLahir,
    required super.usia,
    this.sekolah,
    this.kelas,
    this.prestasi,
    this.hobi,
    required this.riwayatAnemia,
    required super.statusAktif,
    super.statusGizi,
    this.beratBadan,
    this.tinggiBadan,
    this.tanggalPantauTerakhir,
    this.noHp,
    super.createdAt,
    super.updatedAt,
  });

  factory RemajaDetailResponse.fromJson(Map<String, dynamic> json) {
    return RemajaDetailResponse(
      idRemaja: json['id_remaja'] as String,
      nik: json['nik'] as String,
      nama: json['nama'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
      tanggalLahir: json['tanggal_lahir'] as String?,
      usia: json['usia'] as int,
      sekolah: json['sekolah'] as String?,
      kelas: json['kelas'] as String?,
      prestasi: json['prestasi'] as String?,
      hobi: json['hobi'] as String?,
      riwayatAnemia: json['riwayat_anemia'] as String,
      statusAktif: json['status_aktif'] as String,
      statusGizi: json['status_gizi'] as String?,
      beratBadan: json['berat_badan'] != null
          ? (json['berat_badan'] as num).toDouble()
          : null,
      tinggiBadan: json['tinggi_badan'] != null
          ? (json['tinggi_badan'] as num).toDouble()
          : null,
      tanggalPantauTerakhir: json['tanggal_pantau_terakhir'] as String?,
      noHp: json['no_hp'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'id_remaja': idRemaja,
      'sekolah': sekolah,
      'kelas': kelas,
      'prestasi': prestasi,
      'hobi': hobi,
      'riwayat_anemia': riwayatAnemia,
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'tanggal_pantau_terakhir': tanggalPantauTerakhir,
      'no_hp': noHp,
    };
  }
}
```

- [ ] **Step 6: Jalankan test untuk pastikan PASS + regression**

Run: `flutter test test/core/models/warga_base_model_test.dart test/core/services/balita/balita_service_test.dart test/core/services/remaja/remaja_service_test.dart`
Expected: PASS semua. (Test service lama memastikan `fromJson`/`toJson` tidak rusak.)

- [ ] **Step 7: Commit**

```bash
git add lib/core/models/warga_base_model.dart lib/core/models/balita/balita_model.dart lib/core/models/remaja/remaja_model.dart test/core/models/warga_base_model_test.dart
git commit -m "refactor: extract WargaBase base model for common fields"
```

---

### Task 3: Refactor service Balita (BalitaService & PemantauanBalitaService)

**Files:**
- Modify: `lib/core/services/balita/balita_service.dart`, `lib/core/services/balita/pemantauan_balita_service.dart`
- Test (regression, TIDAK diubah): `test/core/services/balita/balita_service_test.dart`, `test/core/services/balita/pemantauan_balita_service_test.dart`

**Interfaces:**
- Consumes: `BalitaBaseService` (dari Task 1) → `get`, field `apiClient` (untuk `downloadKms`).
- Produces: API service yang TIDAK berubah secara eksternal.

- [ ] **Step 1: Jalankan test regression (baseline hijau)**

Run: `flutter test test/core/services/balita/balita_service_test.dart test/core/services/balita/pemantauan_balita_service_test.dart`
Expected: PASS (ini kondisi awal, bukan failing test — refactor task).

- [ ] **Step 2: Ganti isi `lib/core/services/balita/balita_service.dart`**

```dart
import 'dart:io';
import 'package:frontend_posyandu/config.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/models/balita/balita_model.dart';
import 'package:frontend_posyandu/core/models/balita/growth_chart_model.dart';
import 'package:frontend_posyandu/core/services/balita/balita_base_service.dart';

class BalitaService extends BalitaBaseService {
  BalitaService({ApiClient? apiClient}) : super(apiClient: apiClient);

  Future<BalitaDetailResponse> getBalitaById(String idBalita) {
    return get(
      '/api/balita/$idBalita',
      fromJson: BalitaDetailResponse.fromJson,
      errorMessage: 'Gagal memuat data balita',
    );
  }

  Future<GrowthChartResponse> getGrowthChart(String idBalita) {
    return get(
      '/api/balita/$idBalita/growth-chart',
      fromJson: GrowthChartResponse.fromJson,
      errorMessage: 'Gagal memuat grafik pertumbuhan',
    );
  }

  String getDownloadKmsUrl(String idBalita) {
    return '${AppConfig.apiBaseUrl}/api/balita/$idBalita/download-kms';
  }

  Future<File> downloadKms(String idBalita) async {
    final url = '/api/balita/$idBalita/download-kms';
    final dir = await Directory.systemTemp.createTemp('kms_');
    final file = File('${dir.path}/kms_$idBalita.pdf');
    await apiClient.dio.download(url, file.path);
    return file;
  }
}
```

- [ ] **Step 3: Ganti isi `lib/core/services/balita/pemantauan_balita_service.dart`**

```dart
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/models/balita/pemantauan_balita_detail_model.dart';
import 'package:frontend_posyandu/core/models/balita/pemantauan_balita_model.dart';
import 'package:frontend_posyandu/core/services/balita/balita_base_service.dart';

class PemantauanBalitaService extends BalitaBaseService {
  PemantauanBalitaService({ApiClient? apiClient}) : super(apiClient: apiClient);

  Future<PemantauanListResponse> getList({
    required String idBalita,
    int page = 1,
    int limit = 5,
  }) {
    return get(
      '/api/balita/$idBalita/pemantauan',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: PemantauanListResponse.fromJson,
      errorMessage: 'Gagal memuat riwayat pemeriksaan',
      fromData: false,
    );
  }

  Future<PemantauanBalitaDetailResponse> getDetail({
    required String idBalita,
    required String idPantau,
  }) {
    return get(
      '/api/balita/$idBalita/pemantauan/$idPantau',
      fromJson: PemantauanBalitaDetailResponse.fromJson,
      errorMessage: 'Gagal memuat detail pemeriksaan',
    );
  }
}
```

- [ ] **Step 4: Jalankan test regression**

Run: `flutter test test/core/services/balita/balita_service_test.dart test/core/services/balita/pemantauan_balita_service_test.dart`
Expected: PASS semua (API contract tidak berubah).

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/balita/balita_service.dart lib/core/services/balita/pemantauan_balita_service.dart
git commit -m "refactor: extend BalitaBaseService in Balita services"
```

---

### Task 4: Refactor service Remaja (RemajaService, PemantauanRemajaService, KegiatanRemajaService)

**Files:**
- Modify: `lib/core/services/remaja/remaja_service.dart`, `lib/core/services/remaja/pemantauan_remaja_service.dart`, `lib/core/services/remaja/kegiatan_remaja_service.dart`
- Test (regression, TIDAK diubah): `test/core/services/remaja/remaja_service_test.dart`, `test/core/services/remaja/pemantauan_remaja_service_test.dart`, `test/core/services/remaja/kegiatan_remaja_service_test.dart`

**Interfaces:**
- Consumes: `RemajaBaseService` (dari Task 1) → `get`.
- Produces: API service yang TIDAK berubah secara eksternal.

- [ ] **Step 1: Jalankan test regression (baseline hijau)**

Run: `flutter test test/core/services/remaja/remaja_service_test.dart test/core/services/remaja/pemantauan_remaja_service_test.dart test/core/services/remaja/kegiatan_remaja_service_test.dart`
Expected: PASS.

- [ ] **Step 2: Ganti isi `lib/core/services/remaja/remaja_service.dart`**

```dart
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/models/remaja/bmi_status_model.dart';
import 'package:frontend_posyandu/core/models/remaja/remaja_model.dart';
import 'package:frontend_posyandu/core/services/remaja/remaja_base_service.dart';

class RemajaService extends RemajaBaseService {
  RemajaService({ApiClient? apiClient}) : super(apiClient: apiClient);

  Future<RemajaDetailResponse> getRemajaById(String idRemaja) {
    return get(
      '/api/remaja/$idRemaja',
      fromJson: RemajaDetailResponse.fromJson,
      errorMessage: 'Gagal memuat data remaja',
    );
  }

  Future<BmiStatusResponse> getBmiStatus(String idRemaja) {
    return get(
      '/api/remaja/$idRemaja/bmi-status',
      fromJson: BmiStatusResponse.fromJson,
      errorMessage: 'Gagal memuat status BMI',
    );
  }
}
```

- [ ] **Step 3: Ganti isi `lib/core/services/remaja/pemantauan_remaja_service.dart`**

```dart
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/core/models/remaja/pemantauan_remaja_detail_model.dart';
import 'package:frontend_posyandu/core/models/remaja/pemantauan_remaja_model.dart';
import 'package:frontend_posyandu/core/services/remaja/remaja_base_service.dart';

class PemantauanRemajaService extends RemajaBaseService {
  PemantauanRemajaService({ApiClient? apiClient}) : super(apiClient: apiClient);

  Future<PemantauanRemajaListResponse> getList({
    required String idRemaja,
    int page = 1,
    int limit = 10,
  }) {
    return get(
      '/api/remaja/$idRemaja/pemantauan',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: PemantauanRemajaListResponse.fromJson,
      errorMessage: 'Gagal memuat riwayat pemantauan',
      fromData: false,
    );
  }

  Future<PemantauanRemajaDetailResponse> getDetail({
    required String idRemaja,
    required String idPantau,
  }) {
    return get(
      '/api/remaja/$idRemaja/pemantauan/$idPantau',
      fromJson: PemantauanRemajaDetailResponse.fromJson,
      errorMessage: 'Gagal memuat detail pemantauan',
    );
  }

  Future<GulaDarahChartData> getGulaDarahChart(String idRemaja) {
    return get(
      '/api/remaja/$idRemaja/gula-darah-chart',
      fromJson: GulaDarahChartData.fromJson,
      errorMessage: 'Gagal memuat grafik gula darah',
    );
  }
}
```

- [ ] **Step 4: Ganti isi `lib/core/services/remaja/kegiatan_remaja_service.dart`**

```dart
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/models/remaja/kegiatan_detail_model.dart';
import 'package:frontend_posyandu/core/models/remaja/kegiatan_remaja_model.dart';
import 'package:frontend_posyandu/core/services/remaja/remaja_base_service.dart';

class KegiatanRemajaService extends RemajaBaseService {
  KegiatanRemajaService({ApiClient? apiClient}) : super(apiClient: apiClient);

  Future<KegiatanRemajaListResponse> getList({int page = 1, int limit = 10}) {
    return get(
      '/api/kegiatan-remaja',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: KegiatanRemajaListResponse.fromJson,
      errorMessage: 'Gagal memuat daftar kegiatan',
      fromData: false,
    );
  }

  Future<KegiatanDetailResponse> getDetail(String idKegiatan) {
    return get(
      '/api/kegiatan-remaja/$idKegiatan',
      fromJson: KegiatanDetailResponse.fromJson,
      errorMessage: 'Gagal memuat detail kegiatan',
    );
  }
}
```

- [ ] **Step 5: Jalankan test regression**

Run: `flutter test test/core/services/remaja/remaja_service_test.dart test/core/services/remaja/pemantauan_remaja_service_test.dart test/core/services/remaja/kegiatan_remaja_service_test.dart`
Expected: PASS semua.

- [ ] **Step 6: Commit**

```bash
git add lib/core/services/remaja/remaja_service.dart lib/core/services/remaja/pemantauan_remaja_service.dart lib/core/services/remaja/kegiatan_remaja_service.dart
git commit -m "refactor: extend RemajaBaseService in Remaja services"
```

---

### Task 5: Merge StatusGiziBadge ke common + hapus duplikat

**Files:**
- Create: `lib/widgets/common/status_gizi_badge.dart`
- Delete: `lib/widgets/balita/status_gizi_badge.dart`, `lib/widgets/remaja/status_gizi_badge.dart`
- Modify (6 importer lib): `lib/features/pages/balita/balita_detail_page.dart:9`, `lib/features/pages/remaja/pemantauan_detail_page.dart:11`, `lib/widgets/balita/home_balita_sections.dart:5`, `lib/widgets/balita/pemantauan_card.dart:5`, `lib/widgets/remaja/home_remaja_sections.dart:4`, `lib/widgets/remaja/pemantauan_remaja_card.dart:5`
- Modify (2 test importer): `test/widgets/common_widgets_test.dart:6`, `test/widgets/remaja/home_remaja_sections_test.dart:5`
- Test: `test/widgets/common/status_gizi_badge_test.dart`

**Interfaces:**
- Produces: `StatusGiziBadge({super.key, String? status, bool compact = false})` — `status` kini nullable (kompatibel dengan kedua vocab). Label/color memetakan vocab balita (`baik`, `gizi_*`, `stunting`) DAN remaja (`berat_badan_*`, `obesitas_1/2`) secara terpisah (mapping per vocab tidak digabung — vocab balita dan remaja berbeda, jadi di-merge hanya widget-nya, bukan mapping label/warnanya). Default label: `'Tidak Diketahui'` (menggantikan `'Belum Ada'` remaja — tidak ada test yang bergantung pada `'Belum Ada'`).
- Consumes: pemanggil badge yang ada (import path di-update).

- [ ] **Step 1: Tulis failing test `test/widgets/common/status_gizi_badge_test.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/widgets/common/status_gizi_badge.dart';

void main() {
  group('StatusGiziBadge', () {
    for (final entry in [
      ('baik', 'Baik'),
      ('gizi_baik', 'Baik'),
      ('kurang', 'Kurang'),
      ('gizi_kurang', 'Kurang'),
      ('berat_badan_kurang', 'Kurang'),
      ('buruk', 'Buruk'),
      ('stunting', 'Stunting'),
      ('berat_badan_normal', 'Normal'),
      ('berat_badan_berlebih', 'Berlebih'),
      ('obesitas_1', 'Obesitas 1'),
      ('obesitas_2', 'Obesitas 2'),
      ('unknown', 'Tidak Diketahui'),
      (null, 'Tidak Diketahui'),
    ]) {
      testWidgets('shows "${entry.$2}" for status "${entry.$1}"', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: StatusGiziBadge(status: entry.$1)),
        ));
        expect(find.textContaining(entry.$2), findsOneWidget);
      });
    }
  });
}
```

- [ ] **Step 2: Jalankan test untuk pastikan GAGAL**

Run: `flutter test test/widgets/common/status_gizi_badge_test.dart`
Expected: FAIL — `StatusGiziBadge` tidak ditemukan di path common.

- [ ] **Step 3: Buat `lib/widgets/common/status_gizi_badge.dart` (gabungan kedua vocab)**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusGiziBadge extends StatelessWidget {
  final String? status;
  final bool compact;

  const StatusGiziBadge({super.key, this.status, this.compact = false});

  String get _raw => status ?? 'unknown';

  Color get _color {
    switch (_raw) {
      case 'baik':
      case 'gizi_baik':
        return const Color(0xFF22C55E);
      case 'kurang':
      case 'gizi_kurang':
        return const Color(0xFFF97316);
      case 'buruk':
      case 'gizi_buruk':
        return const Color(0xFFEF4444);
      case 'stunting':
        return const Color(0xFFE11D48);
      case 'berat_badan_kurang':
        return const Color(0xFF2196F3);
      case 'berat_badan_normal':
        return const Color(0xFF43A047);
      case 'berat_badan_berlebih':
        return const Color(0xFFFFA726);
      case 'obesitas_1':
        return const Color(0xFFEF5350);
      case 'obesitas_2':
        return const Color(0xFFB71C1C);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color get _bgColor {
    switch (_raw) {
      case 'baik':
      case 'gizi_baik':
        return const Color(0xFFF0FDF4);
      case 'kurang':
      case 'gizi_kurang':
        return const Color(0xFFFFF7ED);
      case 'buruk':
      case 'gizi_buruk':
        return const Color(0xFFFEF2F2);
      case 'stunting':
        return const Color(0xFFFFF1F2);
      case 'berat_badan_kurang':
        return const Color(0xFFE3F2FD);
      case 'berat_badan_normal':
        return const Color(0xFFE8F5E9);
      case 'berat_badan_berlebih':
        return const Color(0xFFFFF3E0);
      case 'obesitas_1':
      case 'obesitas_2':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF8FAFC);
    }
  }

  String get _label {
    switch (_raw) {
      case 'baik':
      case 'gizi_baik':
        return 'Baik';
      case 'kurang':
      case 'gizi_kurang':
      case 'berat_badan_kurang':
        return 'Kurang';
      case 'buruk':
      case 'gizi_buruk':
        return 'Buruk';
      case 'stunting':
        return 'Stunting';
      case 'berat_badan_normal':
        return 'Normal';
      case 'berat_badan_berlebih':
        return 'Berlebih';
      case 'obesitas_1':
        return 'Obesitas 1';
      case 'obesitas_2':
        return 'Obesitas 2';
      default:
        return 'Tidak Diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _color.withValues(alpha: 0.3)),
        ),
        child: Text(
          _label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _color,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Hapus 2 file duplikat & update 6 import di lib**

```bash
git rm lib/widgets/balita/status_gizi_badge.dart lib/widgets/remaja/status_gizi_badge.dart
```

Ganti import di 6 file lib berikut (dari path lama ke `package:frontend_posyandu/widgets/common/status_gizi_badge.dart`):
1. `lib/features/pages/balita/balita_detail_page.dart:9`
2. `lib/features/pages/remaja/pemantauan_detail_page.dart:11`
3. `lib/widgets/balita/home_balita_sections.dart:5`
4. `lib/widgets/balita/pemantauan_card.dart:5`
5. `lib/widgets/remaja/home_remaja_sections.dart:4`
6. `lib/widgets/remaja/pemantauan_remaja_card.dart:5`

Contoh (file #1): ganti
`import 'package:frontend_posyandu/widgets/balita/status_gizi_badge.dart';`
menjadi
`import 'package:frontend_posyandu/widgets/common/status_gizi_badge.dart';`

- [ ] **Step 5: Update 2 import di test**

- `test/widgets/common_widgets_test.dart:6`: ganti `widgets/balita/status_gizi_badge.dart` → `widgets/common/status_gizi_badge.dart`.
- `test/widgets/remaja/home_remaja_sections_test.dart:5`: ganti `widgets/remaja/status_gizi_badge.dart` → `widgets/common/status_gizi_badge.dart`.

- [ ] **Step 6: Jalankan test**

Run: `flutter test test/widgets/common/status_gizi_badge_test.dart test/widgets/common_widgets_test.dart test/widgets/remaja/home_remaja_sections_test.dart`
Expected: PASS semua.

- [ ] **Step 7: Verifikasi analyze clean**

Run: `flutter analyze`
Expected: Tidak ada error `uri_does_not_exist` / `undefined_class` / unused import.

- [ ] **Step 8: Commit**

```bash
git add -A lib/widgets test/widgets
git commit -m "refactor: merge StatusGiziBadge into common widget"
```

---

### Task 6: Dedup PaginationMeta

**Files:**
- Create: `lib/core/models/pagination_meta.dart`
- Modify: `lib/core/models/balita/pemantauan_balita_model.dart` (hapus class lokal baris 1-33, tambah import), `lib/core/models/remaja/pemantauan_remaja_model.dart` (hapus class lokal baris 1-33, tambah import)
- Modify (2 test importer): `test/features/pages/balita/riwayat_pemantauan_page_test.dart`, `test/features/pages/remaja/riwayat_pemantauan_page_test.dart` (tambah import `core/models/pagination_meta.dart`)

**Interfaces:**
- Produces: `PaginationMeta` (identik dengan definisi lama: `page`, `limit`, `total`, `totalPages`, `fromJson`, `toJson`, `hasMore`).
- Consumes: `PemantauanListResponse` (balita) & `PemantauanRemajaListResponse` (remaja) via import.

- [ ] **Step 1: Buat `lib/core/models/pagination_meta.dart`**

```dart
class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'total_pages': totalPages,
    };
  }

  bool get hasMore => page < totalPages;
}
```

- [ ] **Step 2: Update `lib/core/models/balita/pemantauan_balita_model.dart`**

Hapus class `PaginationMeta` lokal (baris 1-33). Tambahkan di bagian atas file:
```dart
import 'package:frontend_posyandu/core/models/pagination_meta.dart';
```

- [ ] **Step 3: Update `lib/core/models/remaja/pemantauan_remaja_model.dart`**

Hapus class `PaginationMeta` lokal (baris 1-33). Tambahkan di bagian atas file:
```dart
import 'package:frontend_posyandu/core/models/pagination_meta.dart';
```

- [ ] **Step 4: Update 2 test yang mengkonstruksi `PaginationMeta` langsung**

Tambah import berikut di `test/features/pages/balita/riwayat_pemantauan_page_test.dart` dan `test/features/pages/remaja/riwayat_pemantauan_page_test.dart`:
```dart
import 'package:frontend_posyandu/core/models/pagination_meta.dart';
```

- [ ] **Step 5: Jalankan test regression**

Run: `flutter test test/core/services/balita/pemantauan_balita_service_test.dart test/core/services/remaja/pemantauan_remaja_service_test.dart test/core/services/remaja/kegiatan_remaja_service_test.dart test/features/pages/balita/riwayat_pemantauan_page_test.dart test/features/pages/remaja/riwayat_pemantauan_page_test.dart`
Expected: PASS semua.

- [ ] **Step 6: Commit**

```bash
git add lib/core/models/pagination_meta.dart lib/core/models/balita/pemantauan_balita_model.dart lib/core/models/remaja/pemantauan_remaja_model.dart test/features/pages/balita/riwayat_pemantauan_page_test.dart test/features/pages/remaja/riwayat_pemantauan_page_test.dart
git commit -m "refactor: dedupe PaginationMeta into shared model"
```

---

### Task 7: Hapus file mati error_handler.dart

**Files:**
- Delete: `lib/core/utils/error_handler.dart`

**Interfaces:**
- Tidak ada konsumen (grep `error_handler` hanya muncul di PRD.md & docs plan; tidak ada import di kode).

- [ ] **Step 1: Verifikasi tidak ada import**

Run: `rg "error_handler" lib test`
Expected: Tidak ada hasil di `lib/` atau `test/`.

- [ ] **Step 2: Hapus file**

```bash
git rm lib/core/utils/error_handler.dart
```

- [ ] **Step 3: Jalankan analyze**

Run: `flutter analyze`
Expected: Clean, tidak ada error terkait file yang dihapus.

- [ ] **Step 4: Commit**

```bash
git commit -m "chore: remove unused empty error_handler.dart"
```

---

### Task 8: Verifikasi penuh

**Files:**
- N/A (verification)

- [ ] **Step 1: Run `flutter analyze`**

Run: `flutter analyze`
Expected: 0 issues.

- [ ] **Step 2: Run seluruh test suite**

Run: `flutter test`
Expected: Semua PASS (baseline 248 test sebelum refactor — jumlah bisa bertambah karena test baru Task 1, 2, 5; tidak boleh ada test yang gagal).

- [ ] **Step 3: Cek `git status` bersih dari file tak diinginkan**

Run: `git status`
Expected: Hanya file dari tasks di atas; tidak ada artefak lain.

- [ ] **Step 4: Komit akhir jika ada sisa**

```bash
git add -A
git commit -m "chore: final verification for reusable infrastructure"
```

---

## Self-Review

**1. Spec coverage (hasil brainstorming):**
- "Generic API Service" → Task 1 (BaseService get/post/put/delete) ✓
- "Base model field umum" → Task 2 (WargaBase) ✓
- "Refactor semua yang ada + modul baru" → Task 3 & 4 (5 service extends BalitaBaseService/RemajaBaseService; modul baru siap tinggal extends base class/WargaBase) ✓
- "Bedakan tempat API per modul" → Task 1 (`BalitaBaseService` & `RemajaBaseService`, masing-masing extends `BaseService` inti; modul baru lansia/ibu_hamil menambah base sendiri) ✓
- "Hapus widget duplikat" → Task 5 (StatusGiziBadge merge, mapping per vocab tetap terpisah) ✓ + Task 6 (PaginationMeta dedup) + Task 7 (hapus error_handler.dart)
- "Buat test baru + modifikasi test lama" → test baru Task 1/2/5; test lama di-update import (Task 5/6), sisanya regression tanpa edit ✓
- "Cukup infrastruktur reusable saja (tanpa contoh modul)" → tidak ada modul baru dikoding ✓

**2. Placeholder scan:** Semua code block berisi implementasi lengkap; tidak ada "TBD"/"TODO"/"similar to Task N".

**3. Type consistency:**
- `BaseService.get<T>` signature konsisten dipakai Task 3 & 4 (`fromJson`, `queryParameters`, `errorMessage`, `fromData`).
- `fromData: false` dipakai untuk semua list response (PemantauanListResponse, PemantauanRemajaListResponse, KegiatanRemajaListResponse) karena dariJson-nya membaca seluruh envelope; `fromData` default `true` untuk detail response. Ini cocok dengan implementasi lama.
- `apiClient` field publik di BaseService dipakai `downloadKms` di Task 3.
- `WargaBase` field names (`nik`, `nama`, `jenisKelamin`, `tanggalLahir`, `usia`, `statusAktif`, `statusGizi`, `createdAt`, `updatedAt`) konsisten antara Task 2 test dan model.
- `StatusGiziBadge` constructor `{String? status, bool compact}` konsisten dipakai test dan pemanggil lama.
- `PaginationMeta` (Task 6) signature identik dengan definisi lama — test riwayat page yang memanggil `PaginationMeta(page: 1, limit: 5, ...)` tetap valid.
