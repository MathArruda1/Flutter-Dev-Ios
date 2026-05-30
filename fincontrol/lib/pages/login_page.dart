import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _carregando = false;

  // FUNÇÃO DE LOGIN
  void fazerLogin(BuildContext context) async {
    setState(() {
      _carregando = true;
    });

    String email = _emailController.text.trim();
    String senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos!")),
      );
      setState(() {
        _carregando = false;
      });
      return;
    }

    String resultado = await AuthService.fazerLogin(username: email, password: senha);

    setState(() {
      _carregando = false;
    });

    if (resultado == "sucesso") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } 
    else if (resultado == "sucesso_offline") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("API indisponível. Entrando com a Conta de Testes Offline! 💻"),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } 
    else if (resultado == "credenciais_invalidas") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuário ou senha incorretos. Verifique os dados! 🔒"),
          backgroundColor: Colors.red,
        ),
      );
    } 
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Falha na ligação com o servidor (Erro 502/Timeout). 🌐"),
          backgroundColor: Colors.amber.shade900,
        ),
      );
    }
  }

  // 🚀 CORRIGIDO: Agora com 'c' para bater certinho com a chamada do botão
  void executarCadastro(BuildContext context) async {
    String email = _emailController.text.trim();
    String senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Digite o E-mail/Usuário e Senha que deseja cadastrar! 📝"),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    setState(() {
      _carregando = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tentando realizar cadastro na API..."),
        duration: Duration(seconds: 4),
      ),
    );

    String loginNome = email.split('@')[0];

    bool sucesso = await AuthService.register(
      name: "Usuario",
      surname: "FinControl",
      login: loginNome,
      email: email.contains('@') ? email : "$email@fincontrol.com",
      password: senha,
    );

    setState(() {
      _carregando = false;
    });

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cadastro realizado com sucesso! Use os dados para Entrar. 🎉"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _mostrarDialogoErroCadastro(context);
    }
  }

  void _mostrarDialogoErroCadastro(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.orange),
            SizedBox(width: 10),
            Text("Instabilidade na API"),
          ],
        ),
        content: const Text(
          "O servidor de autenticação externa retornou um erro de validação (sistema_id/400).\n\n"
          "Deseja pular essa etapa e acessar o sistema em Modo de Demonstração Offline?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            child: const Text("Entrar Offline 🚀"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "FinControl IA",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const Text(
                "Gerencie suas finanças de forma inteligente",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "E-mail ou Usuário",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _carregando ? null : () => fazerLogin(context),
                  child: _carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Entrar", style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: _carregando ? null : () => executarCadastro(context),
                  child: const Text(
                    "Não tem uma conta? Cadastre-se aqui",
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}