import 'package:flutter/material.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/services/fcm/fcm_service.dart';

class PosbinduPage extends StatelessWidget {
  const PosbinduPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FCMService().clearFcmToken();
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posbindu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: const Center(child: Text('Halaman Posbindu (dalam pengembangan)')),
    );
  }
}
