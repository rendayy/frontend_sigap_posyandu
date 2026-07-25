import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config.dart';
import 'firebase_options.dart';
import 'core/services/fcm/fcm_service.dart';
import 'features/themes/theme.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FCMService().initialize();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

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
      routes: appRoutes,
    );
  }
}
