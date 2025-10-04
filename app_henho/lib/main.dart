import 'package:flutter/material.dart';
import 'screen/login_screen.dart'; // Sửa đường dẫn import cho đúng

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Hẹn Hò',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(), // Đặt màn hình đăng nhập là màn hình chính
    );
  }
}
