import 'package:flutter/material.dart';
import 'lancamentos_page.dart';
import 'sobre_page.dart';
import '../Models/lancamento.dart';
import '../database/db_helper.dart';
import '../services/ai_service.dart';
import '../services/auth.dart';
import 'login_page.dart';

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

  // FUNÇÃO REUTILIZÁVEL PARA ABRIR O POP-UP DE QUALQUER LUGAR
  void _abrirModalCadastro() {
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
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      HomeContent(lista: lista), 
      LancamentosPage(
        lista: lista,
        onDeletar: () {
          // 🚀 CONECTADO: Quando a lixeira for clicada lá na outra página, 
          // ela chama essa função aqui e atualiza o banco/saldo na hora!
          carregarDados(); 
        },
      ),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "Lançamentos"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "Sobre"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          if (_paginaAtual == 1) {
            _abrirModalCadastro();
          } else {
            setState(() {
              _paginaAtual = 1;
            });
            _abrirModalCadastro();
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

class HomeContent extends StatefulWidget {
  final List<Lancamento> lista;

  const HomeContent({
    super.key,
    required this.lista,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _textoIA = "Clique no botão abaixo para gerar uma análise das suas finanças com Inteligência Artificial. 🤖✨";
  bool _carregandoIA = false;

  void _consultarIA() async {
    setState(() {
      _carregandoIA = true;
      _textoIA = "A IA está analisando seus lançamentos locais...";
    });

    String resposta = await AIService.obterDicasFinanceiras();

    if (!mounted) return;

    setState(() {
      _carregandoIA = false;
      
      if (resposta == "erro_servidor") {
        _textoIA = "🤖 [FinControl IA]: Não foi possível obter insights. O servidor retornou um Erro 502 (Bad Gateway). 🌐";
      } else if (resposta == "erro_timeout") {
        _textoIA = "🤖 [FinControl IA]: Limite de tempo esgotado (Timeout de 60s). A API não respondeu. ⏳";
      } else {
        _textoIA = resposta;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double saldo = 0;

    for (var item in widget.lista) {
      if (item.isEntrada) {
        saldo += item.valor;
      } else {
        saldo -= item.valor;
      }
    }

    final ultimos = widget.lista.reversed.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("FinControl IA"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bem-vindo 👋",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // CARD DO SALDO DINÂMICO
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
                  const Text("Saldo atual", style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(
                    "R\$ ${saldo.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // CARD DA INTELIGÊNCIA ARTIFICIAL TRATADO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.purple),
                      SizedBox(width: 8),
                      Text("FinControl Insights IA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _textoIA, 
                    style: TextStyle(
                      color: _textoIA.contains("Erro") || _textoIA.contains("esgotado") 
                        ? Colors.red.shade900 
                        : Colors.grey.shade800, 
                      fontSize: 14
                    )
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                      onPressed: _carregandoIA ? null : _consultarIA,
                      icon: _carregandoIA 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.auto_awesome),
                      label: Text(_carregandoIA ? "Analisando..." : "Pedir conselho à IA"),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Últimos lançamentos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // LISTVIEW CONECTADO AO SEU DATABASE HELPER
            Expanded(
              child: ultimos.isEmpty
                  ? const Center(child: Text("Adicione lançamentos para aparecer aqui"))
                  : ListView.builder(
                      itemCount: ultimos.length,
                      itemBuilder: (context, index) {
                        final item = ultimos[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              item.isEntrada ? Icons.arrow_upward : Icons.arrow_downward,
                              color: item.isEntrada ? Colors.green : Colors.red,
                            ),
                            title: Text(item.item),
                            trailing: Text(
                              "R\$ ${item.valor.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: item.isEntrada ? Colors.green : Colors.red,
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