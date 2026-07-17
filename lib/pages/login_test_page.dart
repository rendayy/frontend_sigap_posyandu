// Hanya testing untuk notifikasi
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config.dart';
import '../services/fcm_service.dart';

class LoginTestPage extends StatefulWidget {
  const LoginTestPage({super.key});

  @override
  State<LoginTestPage> createState() => _LoginTestPageState();
}

class _LoginTestPageState extends State<LoginTestPage> {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));

  bool _loading = false;
  String? _error;
  String? _token;
  String? _fcmStatus;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
      _token = null;
      _fcmStatus = null;
    });

    try {
      final response = await _dio.post(
        '/api/v1/auth/login',
        data: {
          'identifier': _identifierCtrl.text,
          'password': _passwordCtrl.text,
        },
      );

      String? accessToken;
      if (response.data is Map) {
        final data = response.data['data'] as Map?;
        accessToken = data?['access_token'];
      }
      if (accessToken == null) {
        setState(() {
          _error = 'Login gagal: access_token tidak ditemukan di response';
          _loading = false;
        });
        return;
      }

      setState(() => _token = accessToken);
      FCMService().setJwtToken(accessToken);

      // Panggil langsung (tidak via FCMService) untuk debug response
      try {
        final fcmToken = await FCMService().getToken();
        final regResponse =
            await Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl)).post(
              '/api/v1/alert/fcm-token',
              options: Options(
                headers: {'Authorization': 'Bearer $accessToken'},
              ),
              data: {'fcm_token': fcmToken},
            );
        setState(() {
          _fcmStatus = '✅ FCM token terdaftar (${regResponse.statusCode})';
          _loading = false;
        });
      } on DioException catch (e) {
        setState(() {
          _fcmStatus = '❌ ${e.response?.statusCode}: ${e.response?.data}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Login gagal: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Test (Testing)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _identifierCtrl,
              decoration: const InputDecoration(labelText: 'NIK / Identifier'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login & Register FCM'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_token != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Access Token:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_token!, style: const TextStyle(fontSize: 11)),
                    const SizedBox(height: 8),
                    if (_fcmStatus != null) Text(_fcmStatus!),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
