import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';
import 'screens/booking_history_page.dart';
import 'screens/admin_dashboard_page.dart';
import 'screens/mitra_dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
          '/profile': (context) => const ProfilePage(),
          '/booking-history': (context) => const BookingHistoryPage(),
          '/admin-dashboard': (context) => const AdminDashboardPage(),
          '/mitra-dashboard': (context) => const MitraDashboardPage(),
        },
      ),
    );
  }
}
