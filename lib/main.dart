import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'providers/user_provider.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
// import 'screens/home_page.dart'; // TODO: Re-add when merging branches
// import 'screens/profile_page.dart'; // TODO: Re-add when merging branches
// import 'screens/booking_history_page.dart'; // TODO: Re-add when merging branches
// import 'screens/admin_dashboard_page.dart'; // TODO: Re-add when merging branches
import 'screens/mitra/mitra_home_page.dart';

void main() {
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
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          // '/home': (context) => const HomePage(), // TODO: Re-add when merging branches
          // '/user/home': (context) => const HomePage(), // TODO: Re-add when merging branches
          '/mitra/home': (context) =>
              const MitraHomePage(), // Original route from main branch
          '/mitra-dashboard': (context) =>
              const MitraHomePage(), // Alias for convenience
          // '/admin/home': (context) => const AdminDashboardPage(), // TODO: Re-add when merging branches
          // '/profile': (context) => const ProfilePage(), // TODO: Re-add when merging branches
          // '/booking-history': (context) => const BookingHistoryPage(), // TODO: Re-add when merging branches
        },
      ),
    );
  }
}
