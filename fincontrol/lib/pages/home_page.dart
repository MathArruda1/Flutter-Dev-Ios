import 'package:flutter/material.dart';
import 'lancamentos_page.dart';
import 'sobre_page.dart';
import '../Models/lancamento.dart';
import '../database/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _paginaAtual = 0;

  List<Lancamento> lista = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  void carregarDados() async {
    final dados = await DBHelper.instance.getAll();

    setState(() {
      lista = dados;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      HomeContent(lista: lista), // AGORA PASSA A LISTA
      LancamentosPage(lista: lista),
      const SobrePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _paginaAtual,
        children: paginas,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        onTap: (index) {
          setState(() {
            _paginaAtual = index;
          });
        },
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
              builder: (_) => AddLancamentoDialog(
                onSalvar: (novo) async {
                  await DBHelper.instance.insert(novo);

                  final dados = await DBHelper.instance.getAll();

                  setState(() {
                    lista = dados;
                  });
                },
              ),
            );
          } else {
            setState(() {
              _paginaAtual = 1;
            });
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<Lancamento> lista;

  const HomeContent({
    super.key,
    required this.lista,
  });

  @override
  Widget build(BuildContext context) {

    // CALCULAR SALDO
    double saldo = 0;

    for (var item in lista) {
      if (item.isEntrada) {
        saldo += item.valor;
      } else {
        saldo -= item.valor;
      }
    }

    // pegar últimos 5 lançamentos
    final ultimos = lista.reversed.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("FinControl"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Bem-vindo 👋",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // CARD SALDO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Saldo atual",
                    style: TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "R\$ ${saldo.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Últimos lançamentos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ultimos.isEmpty
                  ? const Center(
                      child: Text(
                        "Adicione lançamentos para aparecer aqui",
                      ),
                    )

                  : ListView.builder(
                      itemCount: ultimos.length,
                      itemBuilder: (context, index) {
                        final item = ultimos[index];

                        return Card(
                          child: ListTile(
                            leading: Icon(
                              item.isEntrada
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: item.isEntrada
                                  ? Colors.green
                                  : Colors.red,
                            ),

                            title: Text(item.item),

                            trailing: Text(
                              "R\$ ${item.valor.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: item.isEntrada
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}