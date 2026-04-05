import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const FinControlApp());
}

class FinControlApp extends StatelessWidget {
  const FinControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinControl',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}