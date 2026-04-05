import 'package:flutter/material.dart';
import 'lancamentos_page.dart';
import 'sobre_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _paginaAtual = 0;

  final List<Widget> _paginas = [
    const HomeContent(),
    const LancamentosPage(),
    const SobrePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: IndexedStack(
    index: _paginaAtual,
    children: _paginas,
),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        onTap: (index) {
          setState(() {
            _paginaAtual = index;
          });
        },

        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: "Lançamentos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: "Sobre",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          if (_paginaAtual == 1) {

        showDialog(
            context: context,
            builder: (_) => const AddLancamentoDialog(
          ),
        );
          } else {
          setState(() {
            _paginaAtual = 1;
          });
        }
      },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FinControl"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [

            Text(
              "Bem-vindo 👋",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            Text("Saldo atual"),

            SizedBox(height: 10),

            Text(
              "R\$ 0,00",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}