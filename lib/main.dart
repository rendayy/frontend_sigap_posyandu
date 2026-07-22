import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';
import 'features/themes/theme.dart';
import 'features/pages/splash_page.dart';
import 'features/pages/auth/login_page.dart';
import 'features/pages/dashboard/dashboard_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FCMService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'SIGAP Posyandu',
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const DashboardPage(),
      },
    );
  }
}
