import 'package:flutter/material.dart';

class LancamentosPage extends StatelessWidget {
  const LancamentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lançamentos")),
      body: Center(
        child: Text("Aqui vão seus ganhos e despesas"),
      ),
    );
  }
}