import 'package:flutter/material.dart';
import 'features/pages/splash_page.dart';
import 'features/pages/auth/login_page.dart';
import 'features/pages/dashboard/dashboard_page.dart';
import 'features/pages/balita/balita_page.dart';
import 'features/pages/remaja/remaja_page.dart';
import 'features/pages/posbindu/posbindu_page.dart';
import 'features/pages/lansia/lansia_page.dart';
import 'features/pages/ibu_hamil/ibu_hamil_page.dart';
import 'features/pages/profil/profile_page.dart';
import 'features/pages/profil/edit_profile_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Map<String, Widget Function(BuildContext)> get appRoutes {
  return {
    '/': (context) => const SplashPage(),
    '/login': (context) => const LoginPage(),
    '/home': (context) => const DashboardPage(),
    '/balita': (context) => const BalitaPage(),
    '/remaja': (context) => const RemajaPage(),
    '/posbindu': (context) => const PosbinduPage(),
    '/lansia': (context) => const LansiaPage(),
    '/ibu-hamil': (context) => const IbuHamilPage(),
    '/profile': (context) => const ProfilePage(),
    '/edit-profile': (context) => const EditProfilePage(),
  };
}
