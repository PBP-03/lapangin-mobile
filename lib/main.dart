import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      },
    );
  }
}
