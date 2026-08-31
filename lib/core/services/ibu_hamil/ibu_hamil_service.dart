import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/models/citizen/citizen_model.dart';
import 'package:frontend_posyandu/core/models/ibu_hamil/ibu_hamil_model.dart';
import 'package:frontend_posyandu/core/services/citizen/citizen_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class IbuHamilService {
  final ApiClient _apiClient;
  final CitizenService _citizenService;

  IbuHamilService({ApiClient? apiClient, CitizenService? citizenService})
    : _apiClient = apiClient ?? ApiClient(),
      _citizenService = citizenService ?? CitizenService();

  Future<IbuHamilDetailResponse> getDetail(String idIbuHamil) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/ibu-hamil/$idIbuHamil',
      );

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message = errorData?['message'] as String? ?? 'Gagal memuat data ibu hamil';
        final code = errorData?['code'] as int?;
        throw ServerException(statusCode: code, message: message, rawMessage: message);
      }

      return IbuHamilDetailResponse.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message = error?['message'] as String? ?? 'Gagal memuat data ibu hamil';
        throw ServerException(statusCode: statusCode, message: message, rawMessage: message);
      }
      if (statusCode == 401) {
        throw ServerException(statusCode: 401, message: 'Sesi Anda telah habis. Silakan login kembali.');
      }
      throw NetworkException();
    }
  }

  Future<PemeriksaanListResponse> getPemeriksaanList(
    String idIbuHamil, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/ibu-hamil/$idIbuHamil/pemeriksaan',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message = errorData?['message'] as String? ?? 'Gagal memuat riwayat pemeriksaan';
        final code = errorData?['code'] as int?;
        throw ServerException(statusCode: code, message: message, rawMessage: message);
      }

      return PemeriksaanListResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message = error?['message'] as String? ?? 'Gagal memuat riwayat pemeriksaan';
        throw ServerException(statusCode: statusCode, message: message, rawMessage: message);
      }
      if (statusCode == 401) {
        throw ServerException(statusCode: 401, message: 'Sesi Anda telah habis. Silakan login kembali.');
      }
      throw NetworkException();
    }
  }

  Future<BeratBadanChartResponse> getBeratBadanChart(String idIbuHamil) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/ibu-hamil/$idIbuHamil/berat-badan-chart',
      );

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message = errorData?['message'] as String? ?? 'Gagal memuat grafik berat badan';
        throw ServerException(message: message);
      }

      return BeratBadanChartResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        throw ServerException(statusCode: 401, message: 'Sesi Anda telah habis. Silakan login kembali.');
      }
      throw NetworkException();
    }
  }

  Future<TinggiFundusChartResponse> getTinggiFundusChart(String idIbuHamil) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/ibu-hamil/$idIbuHamil/tinggi-fundus-chart',
      );

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message = errorData?['message'] as String? ?? 'Gagal memuat grafik tinggi fundus';
        throw ServerException(message: message);
      }

      return TinggiFundusChartResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        throw ServerException(statusCode: 401, message: 'Sesi Anda telah habis. Silakan login kembali.');
      }
      throw NetworkException();
    }
  }

  Future<RiwayatPemeriksaanData> getRiwayatPemeriksaan(String idIbuHamil, {int page = 1, int limit = 10}) async {
    try {
      final results = await Future.wait([
        _apiClient.dio.get('/api/v1/ibu-hamil/$idIbuHamil'),
        _apiClient.dio.get(
          '/api/v1/ibu-hamil/$idIbuHamil/pemeriksaan',
          queryParameters: {'page': page, 'limit': limit},
        ),
      ]);

      final detailResponse = (results[0] as dynamic).data;
      final pemeriksaanResponse = (results[1] as dynamic).data;

      if (detailResponse['success'] != true) {
        throw ServerException(message: 'Gagal memuat data ibu hamil');
      }

      final detail = IbuHamilDetailResponse.fromJson(
        detailResponse['data'] as Map<String, dynamic>,
      );

      int trimester = 1;
      if (detail.usiaKehamilanSaatIni != null) {
        if (detail.usiaKehamilanSaatIni! <= 13) {
          trimester = 1;
        } else if (detail.usiaKehamilanSaatIni! <= 27) {
          trimester = 2;
        } else {
          trimester = 3;
        }
      }

      if (pemeriksaanResponse['success'] == true) {
        final listResponse = PemeriksaanListResponse.fromJson(
          pemeriksaanResponse as Map<String, dynamic>,
        );
        return RiwayatPemeriksaanData(
          items: listResponse.data,
          pagination: listResponse.pagination,
          trimester: trimester,
        );
      }

      throw ServerException(message: 'Gagal memuat riwayat pemeriksaan');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        throw ServerException(statusCode: 401, message: 'Sesi Anda telah habis. Silakan login kembali.');
      }
      throw NetworkException();
    }
  }


  Future<IbuHamilBerandaData> getBeranda(String idIbuHamil) async {
    try {
      final results = await Future.wait([
        _apiClient.dio.get('/api/v1/ibu-hamil/$idIbuHamil'),
        _apiClient.dio.get('/api/v1/ibu-hamil/$idIbuHamil/pemeriksaan'),
        _citizenService.getMyProfile(),
      ]);

      final detailResponse = (results[0] as dynamic).data;
      final pemeriksaanResponse = (results[1] as dynamic).data;
      final profile = results[2] as ProfileResponse;

      IbuHamilDetailResponse detail;
      if (detailResponse['success'] == true) {
        detail = IbuHamilDetailResponse.fromJson(
          detailResponse['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException(message: 'Gagal memuat data ibu hamil');
      }

      List<PemeriksaanIbuHamilItem> items = [];
      if (pemeriksaanResponse['success'] == true) {
        final rawData = pemeriksaanResponse['data'];
        if (rawData is List) {
          items = rawData
              .map((e) => PemeriksaanIbuHamilItem.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (rawData is Map && rawData['data'] is List) {
          items = (rawData['data'] as List)
              .map((e) => PemeriksaanIbuHamilItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      items.sort((a, b) {
        final aDate = a.tanggalPeriksa ?? '';
        final bDate = b.tanggalPeriksa ?? '';
        return bDate.compareTo(aDate);
      });

      if (items.isNotEmpty) {
        try {
          final latestId = items.first.idPeriksa;
          final detailPeriksa = await _apiClient.dio.get(
            '/api/v1/ibu-hamil/$idIbuHamil/pemeriksaan/$latestId',
          );
          if (detailPeriksa.data['success'] == true) {
            items[0] = PemeriksaanIbuHamilItem.fromJson(
              detailPeriksa.data['data'] as Map<String, dynamic>,
            );
          }
        } catch (_) {}
      }

      final totalKunjungan = (pemeriksaanResponse['pagination']?['total'] as num?)?.toInt() ?? items.length;

      final kehamilan = _buildKehamilanInfo(detail);
      final vital = _buildVitalInfo(items, detail, totalKunjungan);
      final jadwal = _buildJadwalInfo(items);
      final edukasi = _buildEdukasiInfo(kehamilan.trimester);
      final nama = profile.nama.isNotEmpty ? profile.nama : detail.nama;
      final inisial = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

      return IbuHamilBerandaData(
        nama: nama,
        inisial: inisial,
        statusLabel: 'Ibu Hamil',
        profile: profile,
        kehamilan: kehamilan,
        vital: vital,
        jadwal: jadwal,
        edukasi: edukasi,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message = error?['message'] as String? ?? 'Gagal memuat data ibu hamil';
        throw ServerException(statusCode: statusCode, message: message, rawMessage: message);
      }
      if (statusCode == 401) {
        throw ServerException(statusCode: 401, message: 'Sesi Anda telah habis. Silakan login kembali.');
      }
      throw NetworkException();
    }
  }

  IbuHamilKehamilanInfo _buildKehamilanInfo(IbuHamilDetailResponse detail) {
    final hphtStr = detail.hpht;
    final hplStr = detail.hpl;

    if (hphtStr == null && hplStr == null) {
      final usia = detail.usiaKehamilanSaatIni ?? 0;
      return IbuHamilKehamilanInfo(
        usiaMinggu: usia,
        trimester: _getTrimester(usia),
        hpl: '-',
        totalMinggu: 40,
        progressPersen: ((usia / 40) * 100).round().clamp(0, 100),
        hariMenujuHpl: 0,
      );
    }

    DateTime? hpht;
    DateTime? hpl;

    try {
      if (hphtStr != null) hpht = DateTime.parse(hphtStr);
    } catch (_) {}
    try {
      if (hplStr != null) hpl = DateTime.parse(hplStr);
    } catch (_) {}

    DateTime? hplFinal = hpl;
    if (hplFinal == null && hpht != null) {
      hplFinal = hpht.add(const Duration(days: 280));
    }

    int usiaMinggu = detail.usiaKehamilanSaatIni ?? 0;
    if (hpht != null && usiaMinggu == 0) {
      final diff = DateTime.now().difference(hpht);
      usiaMinggu = (diff.inDays / 7).floor();
    }

    usiaMinggu = usiaMinggu.clamp(0, 42);

    final trimester = _getTrimester(usiaMinggu);
    final totalMinggu = 40;
    final progress = ((usiaMinggu / totalMinggu) * 100).round().clamp(0, 100);

    int hariMenujuHpl = 0;
    String hplDisplay = '-';
    if (hplFinal != null) {
      hplDisplay = '${hplFinal.day} ${_monthName(hplFinal.month)} ${hplFinal.year}';
      hariMenujuHpl = hplFinal.difference(DateTime.now()).inDays;
    }

    return IbuHamilKehamilanInfo(
      usiaMinggu: usiaMinggu,
      trimester: trimester,
      hpl: hplDisplay,
      totalMinggu: totalMinggu,
      progressPersen: progress,
      hariMenujuHpl: hariMenujuHpl,
    );
  }

  int _getTrimester(int usiaMinggu) {
    if (usiaMinggu <= 13) return 1;
    if (usiaMinggu <= 27) return 2;
    return 3;
  }

  String _monthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  IbuHamilVitalInfo _buildVitalInfo(
    List<PemeriksaanIbuHamilItem> items,
    IbuHamilDetailResponse detail,
    int totalKunjungan,
  ) {
    final latest = items.isNotEmpty ? items.first : null;
    final prev = items.length > 1 ? items[1] : null;

    final bb = latest?.beratBadan;
    final prevBb = prev?.beratBadan;
    double? delta;
    if (bb != null && prevBb != null) {
      delta = bb - prevBb;
    }

    String bbStatus = 'Normal';
    if (bb != null) {
      if (bb < 45 || bb > 100) bbStatus = 'Perlu Perhatian';
    }

    String tdDisplay;
    String tdTanggal = '';
    String tdStatus = 'Normal';
    if (latest?.sistol != null && latest?.distol != null) {
      tdDisplay = '${latest!.sistol}/${latest.distol}';
      try {
        final tgl = DateTime.parse(latest.tanggalPeriksa ?? '');
        tdTanggal = '${tgl.day} ${_monthName(tgl.month)} ${tgl.year}';
      } catch (_) {
        tdTanggal = latest.tanggalPeriksa ?? '';
      }
      if (latest.sistol! >= 140 || latest.distol! >= 90) {
        tdStatus = 'Waspada';
      } else if (latest.sistol! >= 130 || latest.distol! >= 85) {
        tdStatus = 'Perlu Perhatian';
      }
    } else {
      tdDisplay = '-';
    }

    return IbuHamilVitalInfo(
      beratBadanKg: bb,
      beratBadanDeltaKg: delta,
      beratBadanStatus: bbStatus,
      tekananDarah: tdDisplay,
      tekananDarahTanggal: tdTanggal,
      tekananDarahStatus: tdStatus,
      lilaCm: latest?.lingkarLengan,
      tinggiFundusCm: latest?.tinggiFundus,
      kunjunganAnc: KunjunganAncInfo(
        selesai: totalKunjungan,
        target: 9,
      ),
    );
  }

  IbuHamilJadwalInfo _buildJadwalInfo(List<PemeriksaanIbuHamilItem> items) {
    if (items.isEmpty) {
      return const IbuHamilJadwalInfo(
        kunjunganKe: '1',
        status: 'Belum Ada Pemeriksaan',
      );
    }

    return IbuHamilJadwalInfo(
      kunjunganKe: '${items.length + 1}',
      status: 'Akan Datang',
    );
  }

  IbuHamilEdukasiInfo _buildEdukasiInfo(int trimester) {
    switch (trimester) {
      case 1:
        return const IbuHamilEdukasiInfo(
          trimester: 1,
          konten: 'Selamat! Anda memasuki trimester pertama. Perbanyak konsumsi asam folat, '
              'istirahat cukup, dan lakukan pemeriksaan kehamilan rutin ke bidan atau dokter kandungan.',
        );
      case 2:
        return const IbuHamilEdukasiInfo(
          trimester: 2,
          konten: 'Trimester kedua adalah masa paling nyaman bagi ibu hamil. '
              'Nikmati momen ini, lakukan senam hamil ringan, dan persiapkan kebutuhan persalinan. '
              'Gerakan janin mulai terasa di usia 18-20 minggu.',
        );
      case 3:
        return const IbuHamilEdukasiInfo(
          trimester: 3,
          konten: 'Bayi Anda sedang berkembang pesat. Posisi kepala bayi biasanya sudah mulai '
              'mengarah ke bawah. Persiapkan kebutuhan persalinan dan tas rumah sakit Anda.',
        );
      default:
        return const IbuHamilEdukasiInfo(
          trimester: 1,
          konten: 'Perhatikan asupan gizi dan lakukan pemeriksaan kehamilan secara rutin.',
        );
    }
  }
}