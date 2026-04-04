import 'package:flutter/material.dart';
import 'lancamentos_page.dart';
import 'sobre_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FinControl IA")),

      body: Center(
        child: Text("Bem-vindo ao FinControl 💰"),
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text("Menu")),

            ListTile(
              title: Text("Lançamentos"),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => LancamentosPage()));
              },
            ),

            ListTile(
              title: Text("Sobre"),
              onTap: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => SobrePage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}