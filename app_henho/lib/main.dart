import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen/login_screen.dart';
import 'screen/user/home_screen.dart';
import 'screen/admin/admin_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Map<String, dynamic>> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final role = prefs.getString('role') ?? 'user';
    return {'isLoggedIn': isLoggedIn, 'role': role};
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartBeat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
      ),
      home: FutureBuilder<Map<String, dynamic>>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final isLoggedIn = snapshot.data!['isLoggedIn'] as bool;
          final role = snapshot.data!['role'] as String;
          if (!isLoggedIn) {
            return LoginScreen();
          }
          if (role == 'admin') {
            return AdminDashboardScreen();
          }
          return HomeScreen();
        },
      ),
    );
  }
}
