import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'providers/user_provider.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/user/venue_list_page.dart';
import 'screens/admin/admin_home_page.dart';
import 'screens/admin/admin_mitra_list_page.dart';
import 'screens/admin/admin_earnings_list_page.dart';
import 'widgets/bottom_nav_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure Indonesian locale formatting works (esp. Flutter Web).
  Intl.defaultLocale = 'id_ID';
  await initializeDateFormatting('id_ID');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) {
            CookieRequest request = CookieRequest();
            return request;
          },
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()..initialize()),
      ],
      child: MaterialApp(
        title: 'LapangIN',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5409DA),
            primary: const Color(0xFF5409DA),
            secondary: const Color(0xFF4E71FF),
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            foregroundColor: Color(0xFF5409DA),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const MainScaffold(initialIndex: 0),
          '/user/home': (context) => const MainScaffold(initialIndex: 0),
          '/mitra/home': (context) => const MainScaffold(initialIndex: 0),
          '/user/venues': (context) => const VenueListPage(),
          '/admin/home': (context) => const AdminHomePage(),
          '/admin/kelola-pengguna': (context) => const AdminMitraListPage(),
          '/admin/pendapatan-mitra': (context) => const AdminEarningsListPage(),
        },
      ),
    );
  }
}
