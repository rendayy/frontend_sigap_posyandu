import 'package:flutter/material.dart';
import 'dart:developer';
import '../services/fcm_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _fcmToken;
  String? _testNotifResult;

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  void _initFCM() async {
    String? token = await FCMService().getToken();
    setState(() {
      _fcmToken = token;
    });

    FCMService().setOnNotificationTap((data) {
      log('Notification tapped: $data', name: 'HomePage');
    });

    FCMService().setOnMessageReceived((title, body) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📩 $title${body != null ? ': $body' : ''}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    FCMService().handleInitialMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('SIGAP Posyandu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Selamat datang di SIGAP Posyandu'),
            const SizedBox(height: 20),
            if (_fcmToken != null) ...[
              const Text('FCM Token:'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _fcmToken!,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/login-test'),
              icon: const Icon(Icons.login),
              label: const Text('Login & Daftarkan FCM'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final ok = await FCMService().showTestNotification();
                setState(() => _testNotifResult =
                    ok ? '✅ Notifikasi test dikirim' : '❌ Gagal');
              },
              icon: const Icon(Icons.notifications),
              label: const Text('Test Notifikasi Lokal'),
            ),
            if (_testNotifResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(_testNotifResult!,
                    style: const TextStyle(fontSize: 12)),
              ),
            const SizedBox(height: 4),
            Text(
              '(Halaman testing — akan diganti dengan auth asli)',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
