import 'package:flutter/material.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sobre")),
      body: Center(
        child: Text("FinControl v1.0\nApp de controle financeiro"),
      ),
    );
  }
}