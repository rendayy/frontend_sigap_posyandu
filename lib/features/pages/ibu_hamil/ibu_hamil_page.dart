import 'package:flutter/material.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';

class IbuHamilPage extends StatelessWidget {
  const IbuHamilPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ibu Hamil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: const Center(child: Text('Halaman Ibu Hamil (dalam pengembangan)')),
    );
  }
}
