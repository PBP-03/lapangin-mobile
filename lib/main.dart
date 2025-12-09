import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/user/user_home_page.dart';
import 'screens/mitra/mitra_home_page.dart';
import 'screens/admin/admin_home_page.dart';
import 'widgets/role_selector_page.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider(
          create: (_) {
            CookieRequest request = CookieRequest();
            return request;
          },
        ),
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
          '/role-selector': (context) => const RoleSelectorPage(),
          '/user/home': (context) => const UserHomePage(),
          '/mitra/home': (context) => const MitraHomePage(),
          '/admin/home': (context) => const AdminHomePage(),
        },
      ),
    );
  }
}
